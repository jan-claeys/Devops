import 'dart:convert';
import 'dart:math';

import 'package:devops/models/file_diff.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<int> text(List<String> lines) =>
      lines.isEmpty ? const [] : utf8.encode('${lines.join('\n')}\n');

  /// The lines of the hunks in unified diff notation.
  List<String> unified(FileDiff diff) => [
        for (final hunk in diff.hunks) ...[
          hunk.header,
          for (final line in hunk.lines)
            '${switch (line.kind) {
              DiffKind.context => ' ',
              DiffKind.added => '+',
              DiffKind.removed => '-',
            }}${line.text}',
        ],
      ];

  test('shows a changed line with three lines around it', () {
    final before = [for (var i = 1; i <= 10; i++) 'line $i'];
    final after = [...before]..[4] = 'line five';
    final diff = FileDiff.compare(text(before), text(after));
    expect(diff.added, 1);
    expect(diff.removed, 1);
    expect(unified(diff), [
      '@@ -2,7 +2,7 @@',
      ' line 2',
      ' line 3',
      ' line 4',
      '-line 5',
      '+line five',
      ' line 6',
      ' line 7',
      ' line 8',
    ]);
  });

  test('splits changes far apart into hunks and joins those close together', () {
    final before = [for (var i = 1; i <= 30; i++) '$i'];
    final after = [...before]
      ..removeAt(24)
      ..insert(5, 'new')
      ..insert(1, 'first');
    final diff = FileDiff.compare(text(before), text(after));
    expect(diff.hunks.map((h) => h.header), ['@@ -1,8 +1,10 @@', '@@ -22,7 +24,6 @@']);
    expect((diff.added, diff.removed), (2, 1));
  });

  test('an added or deleted file is all added or removed', () {
    final added = FileDiff.compare(null, text(['a', 'b']));
    expect(unified(added), ['@@ -0,0 +1,2 @@', '+a', '+b']);
    final deleted = FileDiff.compare(text(['a']), null);
    expect((deleted.added, deleted.removed), (0, 1));
  });

  test('ignores the kind of line endings', () {
    final diff = FileDiff.compare(utf8.encode('a\r\nb\r\n'), utf8.encode('a\nb\nc\n'));
    expect(unified(diff), ['@@ -1,2 +1,3 @@', ' a', ' b', '+c']);
  });

  test('does not compare binary or very large files', () {
    expect(FileDiff.compare([0x89, 0x50, 0x00], [0x89]).isBinary, isTrue);
    expect(FileDiff.compare(null, List.filled(FileDiff.maxBytes + 1, 0x61)).isTooLarge, isTrue);
    final many = text([for (var i = 0; i < FileDiff.maxLines; i++) '$i']);
    expect(FileDiff.compare(many, many).isTooLarge, isTrue);
  });

  test('the diff turns the old file into the new one', () {
    final random = Random(7);
    for (var round = 0; round < 200; round++) {
      List<String> lines() =>
          [for (var i = random.nextInt(30); i > 0; i--) '${random.nextInt(5)}'];
      final before = lines();
      final after = lines();
      final diff = FileDiff.compare(text(before), text(after), context: 1000);
      final all = diff.hunks.expand((h) => h.lines).toList();
      expect([for (final l in all) if (l.kind != DiffKind.added) l.text], before);
      expect([for (final l in all) if (l.kind != DiffKind.removed) l.text], after);
    }
  });

  test('falls back to replacing everything after many differences', () {
    final before = [for (var i = 0; i < 1500; i++) 'a$i'];
    final after = [for (var i = 0; i < 1500; i++) 'b$i'];
    final diff = FileDiff.compare(text(before), text(after));
    expect((diff.added, diff.removed), (1500, 1500));
  });
}
