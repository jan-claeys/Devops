import 'package:devops/models/pipeline_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parse drops timestamps and reads logging commands', () {
    final lines = LogLine.parse('2026-10-19T10:00:01.1234567Z ##[section]Starting: Build\r\n'
        '2026-10-19T10:00:02.1234567Z ##[command]dotnet build\r\n'
        'plain\r\n'
        '##[group]Details\r\n'
        '##[endgroup]\r\n'
        '##[warning]Careful\r\n'
        '##[error]Broken\r\n');
    expect([for (final l in lines) (l.text, l.kind)], [
      ('Starting: Build', LogLineKind.section),
      ('dotnet build', LogLineKind.command),
      ('plain', LogLineKind.plain),
      ('Details', LogLineKind.section),
      ('Careful', LogLineKind.warning),
      ('Broken', LogLineKind.error),
    ]);
  });

  group('excerpt', () {
    List<String> excerpt(String log) =>
        [for (final l in LogLine.excerpt(LogLine.parse(log), before: 2)) l.text];

    test('shows the lines before the first error and the errors after it', () {
      expect(
          excerpt('a\nb\nc\nd\n##[error]e1\n##[error]e2\nf\n##[error]e3\n'),
          ['c', 'd', 'e1', 'e2']);
    });

    test('stops at the start of the log', () {
      expect(excerpt('##[error]e1\nf\n'), ['e1']);
    });

    test('shows the end of a log without errors', () {
      expect(excerpt('a\nb\nc\n'), ['b', 'c']);
      expect(excerpt(''), isEmpty);
    });
  });
}
