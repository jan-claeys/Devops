import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_logging/sentry_logging.dart';

import 'devops_api.dart';

/// Sentry project to report errors to, set at build time with
/// `--dart-define=SENTRY_DSN=...`. Without it nothing leaves the device.
const sentryDsn = String.fromEnvironment('SENTRY_DSN');

/// Whether this build can send error reports at all. Tests override it.
bool errorReportingAvailable = sentryDsn.isNotEmpty;

/// The user's choice in the settings, kept in sync by [AppState]. When off,
/// nothing is sent to Sentry anymore, effective immediately.
bool sendErrorReports = true;

/// Prints log records to the console.
void setupLogging() {
  Logger.root.level = kReleaseMode ? Level.INFO : Level.ALL;
  Logger.root.onRecord.listen((r) {
    final error = r.error == null ? '' : ' (${r.error})';
    debugPrint('${r.level.name} ${r.loggerName}: ${r.message}$error');
  });
}

/// Runs the app with logging and, when [sentryDsn] is set, Sentry error
/// reporting. Uncaught errors and `severe` log records become Sentry issues;
/// `info` and `warning` records are kept as breadcrumbs leading up to them.
Future<void> runWithErrorReporting(FutureOr<void> Function() appRunner) async {
  setupLogging();
  if (sentryDsn.isEmpty) {
    await appRunner();
    return;
  }
  if (kIsWeb && Zone.current == Zone.root) {
    // On web Sentry initializes the Flutter binding in the calling zone, but
    // runs appRunner in a zone of its own, so runApp would complain about a
    // zone mismatch. Sentry skips its zone when already inside one, so start
    // our own and report its uncaught errors ourselves.
    final done = Completer<void>();
    runZonedGuarded(
      () => _initSentry(appRunner).whenComplete(done.complete),
      (error, stackTrace) => Sentry.captureException(error, stackTrace: stackTrace),
    );
    return done.future;
  }
  await _initSentry(appRunner);
}

Future<void> _initSentry(FutureOr<void> Function() appRunner) async {
  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.environment = kReleaseMode ? 'production' : 'debug';
      options.sendDefaultPii = false;
      // Performance tracing: sample every session while developing, a fifth in release.
      options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;
      options.addIntegration(LoggingIntegration());
      options.beforeSend = filterEvent;
      options.beforeSendTransaction = (transaction, hint) =>
          sendErrorReports ? transaction : null;
    },
    appRunner: appRunner,
  );
}

/// Drops the event when the user opted out, and never sends credentials,
/// even if a request ends up attached to an event.
@visibleForTesting
SentryEvent? filterEvent(SentryEvent event, Hint hint) {
  if (!sendErrorReports) return null;
  final request = event.request;
  if (request != null) {
    request.headers = {
      for (final h in request.headers.entries)
        if (h.key.toLowerCase() != 'authorization' && h.key.toLowerCase() != 'cookie')
          h.key: h.value,
    };
  }
  return event;
}

/// Logs a caught [error]. Expected failures (Azure DevOps answered with an
/// error, no network) are warnings; anything else is a bug and logged as
/// severe, so it shows up in Sentry.
void logFailure(Logger log, String message, Object error, StackTrace stackTrace) {
  final expected =
      error is DevOpsException || error is http.ClientException || error is TimeoutException;
  log.log(expected ? Level.WARNING : Level.SEVERE, message, error, stackTrace);
}
