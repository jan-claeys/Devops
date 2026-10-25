import 'dart:convert';

/// Whether a line of a diff is unchanged, added or removed.
enum DiffKind { context, added, removed }

/// A line of a unified diff, with its number in the old and the new file.
class DiffLine {
  const DiffLine(this.kind, this.text, {this.oldNumber, this.newNumber});

  final DiffKind kind;
  final String text;
  final int? oldNumber;
  final int? newNumber;
}

/// A group of changed lines with the unchanged lines around them.
class DiffHunk {
  const DiffHunk(this.lines);

  final List<DiffLine> lines;

  int get oldStart => lines.map((l) => l.oldNumber).nonNulls.firstOrNull ?? 0;
  int get newStart => lines.map((l) => l.newNumber).nonNulls.firstOrNull ?? 0;
  int get oldCount => lines.where((l) => l.kind != DiffKind.added).length;
  int get newCount => lines.where((l) => l.kind != DiffKind.removed).length;

  /// The `@@ -1,3 +1,4 @@` line that starts the hunk in a unified diff.
  String get header => '@@ -$oldStart,$oldCount +$newStart,$newCount @@';
}

/// The changes between two versions of a text file, as the hunks of a
/// unified diff; empty for files that can't be compared as text.
class FileDiff {
  const FileDiff({
    this.hunks = const [],
    this.added = 0,
    this.removed = 0,
    this.isBinary = false,
    this.isTooLarge = false,
  });

  final List<DiffHunk> hunks;
  final int added;
  final int removed;
  final bool isBinary;

  /// Too large to download or to compare on the phone.
  final bool isTooLarge;

  /// Files larger than this aren't compared.
  static const maxBytes = 1024 * 1024;

  /// Files with more lines than this, together, aren't compared.
  static const maxLines = 20000;

  /// Beyond this many differences, the rest of the files are shown as
  /// removed and added as a whole: correct, though not the shortest diff.
  static const maxDifferences = 1000;

  /// Compares the contents of a file before and after; null for a file
  /// that didn't exist on that side.
  factory FileDiff.compare(List<int>? before, List<int>? after, {int context = 3}) {
    if ((before?.length ?? 0) > maxBytes || (after?.length ?? 0) > maxBytes) {
      return const FileDiff(isTooLarge: true);
    }
    if (_isBinary(before) || _isBinary(after)) return const FileDiff(isBinary: true);
    final a = _lines(before);
    final b = _lines(after);
    if (a.length + b.length > maxLines) return const FileDiff(isTooLarge: true);
    final lines = _diff(a, b);
    return FileDiff(
      hunks: _hunks(lines, context),
      added: lines.where((l) => l.kind == DiffKind.added).length,
      removed: lines.where((l) => l.kind == DiffKind.removed).length,
    );
  }

  /// Git takes a file with a NUL byte near the start as binary.
  static bool _isBinary(List<int>? bytes) =>
      bytes != null && bytes.take(8000).any((b) => b == 0);

  static List<String> _lines(List<int>? bytes) {
    if (bytes == null || bytes.isEmpty) return const [];
    return const LineSplitter().convert(utf8.decode(bytes, allowMalformed: true));
  }

  /// All lines of both files, in order, each marked as unchanged, added or
  /// removed.
  static List<DiffLine> _diff(List<String> a, List<String> b) {
    var prefix = 0;
    while (prefix < a.length && prefix < b.length && a[prefix] == b[prefix]) {
      prefix++;
    }
    var suffix = 0;
    while (suffix < a.length - prefix &&
        suffix < b.length - prefix &&
        a[a.length - 1 - suffix] == b[b.length - 1 - suffix]) {
      suffix++;
    }
    final kinds = [
      for (var i = 0; i < prefix; i++) DiffKind.context,
      ..._myers(a.sublist(prefix, a.length - suffix), b.sublist(prefix, b.length - suffix)),
      for (var i = 0; i < suffix; i++) DiffKind.context,
    ];
    var x = 0;
    var y = 0;
    return [
      for (final kind in kinds)
        switch (kind) {
          DiffKind.context => DiffLine(kind, a[x], oldNumber: ++x, newNumber: ++y),
          DiffKind.removed => DiffLine(kind, a[x], oldNumber: ++x),
          DiffKind.added => DiffLine(kind, b[y], newNumber: ++y),
        },
    ];
  }

  /// The shortest edit script from [a] to [b] (Myers, 1986), as the kinds of
  /// the lines in order.
  static List<DiffKind> _myers(List<String> a, List<String> b) {
    final n = a.length;
    final m = b.length;
    if (n == 0 || m == 0) return _replace(n, m);
    final offset = n + m + 1;
    final v = List<int>.filled(2 * offset + 1, 0);
    // The furthest x on each diagonal k before step d, for k in -d..d.
    final trace = <List<int>>[];
    for (var d = 0; d <= n + m; d++) {
      if (d > maxDifferences) return _replace(n, m);
      trace.add(v.sublist(offset - d, offset + d + 1));
      for (var k = -d; k <= d; k += 2) {
        var x = k == -d || (k != d && v[offset + k - 1] < v[offset + k + 1])
            ? v[offset + k + 1]
            : v[offset + k - 1] + 1;
        var y = x - k;
        while (x < n && y < m && a[x] == b[y]) {
          x++;
          y++;
        }
        v[offset + k] = x;
        if (x >= n && y >= m) return _backtrack(trace, n, m);
      }
    }
    throw StateError('unreachable');
  }

  /// Removes all [n] old lines and adds the [m] new ones.
  static List<DiffKind> _replace(int n, int m) => [
        for (var i = 0; i < n; i++) DiffKind.removed,
        for (var i = 0; i < m; i++) DiffKind.added,
      ];

  static List<DiffKind> _backtrack(List<List<int>> trace, int n, int m) {
    final kinds = <DiffKind>[];
    var x = n;
    var y = m;
    for (var d = trace.length - 1; d > 0; d--) {
      final v = trace[d];
      final k = x - y;
      final previousK = k == -d || (k != d && v[k - 1 + d] < v[k + 1 + d]) ? k + 1 : k - 1;
      final previousX = v[previousK + d];
      final previousY = previousX - previousK;
      while (x > previousX && y > previousY) {
        kinds.add(DiffKind.context);
        x--;
        y--;
      }
      if (x == previousX) {
        kinds.add(DiffKind.added);
      } else {
        kinds.add(DiffKind.removed);
      }
      x = previousX;
      y = previousY;
    }
    for (; x > 0; x--) {
      kinds.add(DiffKind.context);
    }
    return kinds.reversed.toList();
  }

  /// The changed lines with [context] unchanged lines around them; changes
  /// closer together than twice that share a hunk.
  static List<DiffHunk> _hunks(List<DiffLine> lines, int context) {
    final hunks = <DiffHunk>[];
    var start = -1;
    var end = -1;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].kind == DiffKind.context) continue;
      final from = i - context < 0 ? 0 : i - context;
      if (start >= 0 && from > end) {
        hunks.add(DiffHunk(lines.sublist(start, end)));
        start = -1;
      }
      if (start < 0) start = from;
      end = i + context + 1 > lines.length ? lines.length : i + context + 1;
    }
    if (start >= 0) hunks.add(DiffHunk(lines.sublist(start, end)));
    return hunks;
  }
}
