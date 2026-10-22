import 'dart:math';

enum LogLineKind { plain, error, warning, section, command }

/// A line of the log of a step, without its timestamp and logging command.
class LogLine {
  const LogLine(this.text, [this.kind = LogLineKind.plain]);

  final String text;
  final LogLineKind kind;

  bool get isIssue => kind == LogLineKind.error || kind == LogLineKind.warning;

  static final _timestamp = RegExp(r'^﻿?\d{4}-\d\d-\d\dT[\d:.]+Z ');
  static final _command = RegExp(r'^##\[(error|warning|section|command|group|endgroup)\]');

  static List<LogLine> parse(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    if (lines.lastOrNull?.isEmpty ?? false) lines.removeLast();
    return [for (final raw in lines) ?_parse(raw.replaceFirst(_timestamp, ''))];
  }

  static LogLine? _parse(String line) {
    final match = _command.firstMatch(line);
    if (match == null) return LogLine(line);
    final text = line.substring(match.end);
    return switch (match[1]) {
      'error' => LogLine(text, LogLineKind.error),
      'warning' => LogLine(text, LogLineKind.warning),
      'section' || 'group' => LogLine(text, LogLineKind.section),
      'command' => LogLine(text, LogLineKind.command),
      _ => null,
    };
  }

  /// The lines leading up to the first error, where its cause usually is,
  /// with the errors right after it; the end of the log when it has none.
  static List<LogLine> excerpt(List<LogLine> lines, {int before = 3, int errors = 2}) {
    final first = lines.indexWhere((l) => l.kind == LogLineKind.error);
    if (first < 0) return lines.sublist(max(0, lines.length - before));
    var end = first + 1;
    while (end < lines.length && end - first < errors && lines[end].kind == LogLineKind.error) {
      end++;
    }
    return lines.sublist(max(0, first - before), end);
  }
}
