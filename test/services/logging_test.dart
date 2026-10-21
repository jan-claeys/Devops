import 'dart:async';

import 'package:devops/services/devops_api.dart';
import 'package:devops/services/logging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  Level levelOf(Object error) {
    final log = Logger.detached('test')..level = Level.ALL;
    final records = <LogRecord>[];
    final sub = log.onRecord.listen(records.add);
    logFailure(log, 'failed', error, StackTrace.current);
    sub.cancel();
    return records.single.level;
  }

  test('expected failures are warnings', () {
    expect(levelOf(DevOpsException(DevOpsError.unauthorized, statusCode: 401)), Level.WARNING);
    expect(levelOf(http.ClientException('offline')), Level.WARNING);
    expect(levelOf(TimeoutException('slow')), Level.WARNING);
  });

  test('events are dropped after opting out and never carry credentials', () {
    addTearDown(() => sendErrorReports = true);
    final event = SentryEvent(
      request: SentryRequest(headers: {'Authorization': 'Basic abc', 'Accept': 'json'}),
    );
    expect(filterEvent(event, Hint())!.request!.headers, {'Accept': 'json'});

    sendErrorReports = false;
    expect(filterEvent(SentryEvent(), Hint()), isNull);
  });

  test('anything else is severe so it is reported', () {
    expect(levelOf(StateError('bug')), Level.SEVERE);
    expect(levelOf(const FormatException('bad json')), Level.SEVERE);
  });
}
