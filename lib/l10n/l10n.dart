import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../services/devops_api.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Language names shown in the language picker, in their own language.
const languageNames = {
  'en': 'English',
  'ar': 'العربية',
  'de': 'Deutsch',
  'es': 'Español',
  'fr': 'Français',
  'hi': 'हिन्दी',
  'id': 'Bahasa Indonesia',
  'it': 'Italiano',
  'ja': '日本語',
  'ko': '한국어',
  'nl': 'Nederlands',
  'pl': 'Polski',
  'pt': 'Português',
  'ru': 'Русский',
  'tr': 'Türkçe',
  'uk': 'Українська',
  'zh': '中文',
};

/// Picks the first system language the app supports, or English otherwise.
Locale resolveLocale(Locale? override, [List<Locale>? system]) {
  bool supported(Locale l) =>
      AppLocalizations.supportedLocales.any((s) => s.languageCode == l.languageCode);
  for (final l in [?override, ...(system ?? PlatformDispatcher.instance.locales)]) {
    if (supported(l)) return Locale(l.languageCode);
  }
  return const Locale('en');
}

extension ErrorText on AppLocalizations {
  /// User-facing message for an error thrown while talking to Azure DevOps.
  String error(Object e) => switch (e) {
        DevOpsException(kind: DevOpsError.unauthorized) => errorUnauthorized,
        DevOpsException(kind: DevOpsError.notFound) => errorNotFound,
        DevOpsException(kind: DevOpsError.unexpectedResponse) => errorUnexpectedResponse,
        DevOpsException(:final serverMessage?) => serverMessage,
        DevOpsException(:final statusCode) => errorHttp(statusCode ?? 0),
        _ => e.toString(),
      };
}
