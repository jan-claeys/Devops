import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../l10n/l10n.dart';
import '../models/file_diff.dart';
import '../models/pull_request.dart';
import '../services/app_state.dart';
import '../services/logging.dart';
import 'error_action.dart';
import 'section_card.dart';

final _log = Logger('PullRequestFiles');

const _addedColor = Color(0xFF339933);
const _removedColor = Color(0xFFCC293D);

/// The files a pull request changes, each with the lines it adds and
/// removes, opening to a compact unified diff.
class PullRequestFiles extends StatefulWidget {
  const PullRequestFiles({super.key, required this.pullRequest});

  final PullRequest pullRequest;

  /// The lines of the first files are counted right away; those of the rest
  /// once opened, so a huge pull request doesn't download every file.
  static const countedFiles = 100;

  @override
  State<PullRequestFiles> createState() => _PullRequestFilesState();
}

class _PullRequestFilesState extends State<PullRequestFiles> {
  Future<List<PullRequestChange>>? _changes;
  final _diffs = <String, Future<FileDiff>>{};
  final _downloads = _Limiter(6);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _changes ??= _load();
  }

  Future<List<PullRequestChange>> _load() async {
    try {
      final changes =
          await AppScope.read(context).api!.getPullRequestChanges(widget.pullRequest);
      for (final change in changes.take(PullRequestFiles.countedFiles)) {
        unawaited(_diff(change).then((_) {}, onError: (Object _) {}));
      }
      return changes;
    } catch (e, st) {
      logFailure(_log, 'Loading the files of pull request ${widget.pullRequest.id} failed', e, st);
      rethrow;
    }
  }

  void _reload() => setState(() {
        _diffs.clear();
        _changes = _load();
      });

  Future<FileDiff> _diff(PullRequestChange change) =>
      _diffs[change.path] ??= _downloads.run(() => _compare(change)).catchError(
        (Object e, StackTrace st) {
          logFailure(_log, 'Comparing ${change.path} failed', e, st);
          throw e;
        },
      );

  Future<FileDiff> _compare(PullRequestChange change) async {
    final api = AppScope.read(context).api!;
    final pr = widget.pullRequest;
    final changed = change.kind == FileChangeKind.edit || change.kind == FileChangeKind.rename;
    if (changed && (change.originalObjectId == null || change.objectId == null)) {
      throw StateError('No versions to compare for ${change.path}');
    }
    Future<List<int>?> blob(String? id) async => id == null ? null : api.getBlob(pr, id);
    final [before, after] = await Future.wait([blob(change.originalObjectId), blob(change.objectId)]);
    return FileDiff.compare(before, after);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return FutureBuilder<List<PullRequestChange>>(
      future: _changes,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 12),
                Text(l10n.loadFilesFailed, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(l10n.error(snapshot.error!), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ErrorAction(error: snapshot.error!, onRetry: _reload),
              ],
            ),
          );
        }
        final changes = snapshot.data;
        if (changes == null) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (changes.isEmpty) {
          return SectionCard(
            child: Text(l10n.noFileChanges,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          );
        }
        final counted = [
          for (final change in changes.take(PullRequestFiles.countedFiles)) _diff(change),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l10n.filesChanged(changes.length),
                        style: theme.textTheme.titleSmall),
                  ),
                  // The totals, once the lines of every file are counted.
                  if (changes.length <= PullRequestFiles.countedFiles)
                    FutureBuilder<List<FileDiff>>(
                      future: Future.wait(counted),
                      builder: (context, totals) => switch (totals.data) {
                        final diffs? => _LineCounts(
                            added: diffs.fold(0, (sum, d) => sum + d.added),
                            removed: diffs.fold(0, (sum, d) => sum + d.removed),
                          ),
                        null => const SizedBox.shrink(),
                      },
                    ),
                ],
              ),
            ),
            Card.outlined(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final (i, change) in changes.indexed) ...[
                    if (i > 0) const Divider(height: 1),
                    _FileTile(
                      key: ValueKey(change.path),
                      change: change,
                      diff: _diffs[change.path],
                      // A block body: setState must not get the Future back.
                      onOpen: () => setState(() {
                        _diff(change);
                      }),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Runs at most [max] tasks at a time.
class _Limiter {
  _Limiter(this.max);

  final int max;
  int _running = 0;
  final _waiting = Queue<Completer<void>>();

  Future<T> run<T>(Future<T> Function() task) async {
    if (_running >= max) {
      final turn = Completer<void>();
      _waiting.add(turn);
      await turn.future;
    }
    _running++;
    try {
      return await task();
    } finally {
      _running--;
      if (_waiting.isNotEmpty) _waiting.removeFirst().complete();
    }
  }
}

/// `+12 −3` in green and red.
class _LineCounts extends StatelessWidget {
  const _LineCounts({required this.added, required this.removed});

  final int added;
  final int removed;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
          fontWeight: FontWeight.w600,
        );
    return Text.rich(TextSpan(children: [
      TextSpan(text: '+$added', style: style?.copyWith(color: _addedColor)),
      const TextSpan(text: ' '),
      TextSpan(text: '−$removed', style: style?.copyWith(color: _removedColor)),
    ]));
  }
}

/// A changed file that opens to its diff.
class _FileTile extends StatefulWidget {
  const _FileTile({super.key, required this.change, required this.diff, required this.onOpen});

  final PullRequestChange change;

  /// The diff, once it is being fetched.
  final Future<FileDiff>? diff;

  /// Starts fetching the diff.
  final VoidCallback onOpen;

  @override
  State<_FileTile> createState() => _FileTileState();
}

class _FileTileState extends State<_FileTile> {
  bool _open = false;

  void _toggle() {
    setState(() => _open = !_open);
    if (_open && widget.diff == null) widget.onOpen();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final change = widget.change;
    final (icon, color) = switch (change.kind) {
      FileChangeKind.add => (Icons.add_circle_outline, _addedColor),
      FileChangeKind.delete => (Icons.remove_circle_outline, _removedColor),
      FileChangeKind.rename => (Icons.drive_file_rename_outline, theme.colorScheme.primary),
      FileChangeKind.edit => (Icons.edit_outlined, theme.colorScheme.onSurfaceVariant),
    };
    final subtitle = [
      if (change.folder.isNotEmpty) change.folder,
      if (change.originalPath case final path?) l10n.renamedFrom(path),
    ];
    return FutureBuilder<FileDiff>(
      future: widget.diff,
      builder: (context, snapshot) {
        final diff = snapshot.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              dense: true,
              leading: Icon(icon, color: color, size: 20),
              title: Text(change.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: subtitle.isEmpty
                  ? null
                  : Text(subtitle.join(' · '), maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  if (diff != null && !diff.isBinary && !diff.isTooLarge)
                    _LineCounts(added: diff.added, removed: diff.removed)
                  else if (snapshot.hasError)
                    Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error)
                  else if (widget.diff != null && diff == null)
                    const SizedBox.square(
                        dimension: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  Icon(_open ? Icons.expand_less : Icons.expand_more, size: 20),
                ],
              ),
              onTap: _toggle,
            ),
            if (_open)
              if (snapshot.hasError)
                _Note(l10n.loadFileFailed)
              else if (diff == null)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (diff.isBinary)
                _Note(l10n.binaryFile)
              else if (diff.isTooLarge)
                _Note(l10n.fileTooLarge)
              else if (diff.hunks.isEmpty)
                _Note(l10n.noContentChanges)
              else
                _DiffView(diff),
          ],
        );
      },
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(text,
          style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic)),
    );
  }
}

/// The hunks of a diff in unified notation, with added and removed lines
/// tinted; long diffs are cut short until asked.
class _DiffView extends StatefulWidget {
  const _DiffView(this.diff);

  final FileDiff diff;

  /// Lines shown before "show all".
  static const collapsedLines = 300;

  @override
  State<_DiffView> createState() => _DiffViewState();
}

class _DiffViewState extends State<_DiffView> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mono = theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace', height: 1.35);
    final total = widget.diff.hunks.fold(0, (sum, h) => sum + h.lines.length + 1);
    var budget = _showAll ? total : _DiffView.collapsedLines;
    final rows = <Widget>[];
    for (final hunk in widget.diff.hunks) {
      if (budget-- <= 0) break;
      rows.add(Container(
        color: scheme.surfaceContainerHigh,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(hunk.header, style: mono?.copyWith(color: scheme.onSurfaceVariant)),
      ));
      for (final line in hunk.lines) {
        if (budget-- <= 0) break;
        final (prefix, tint) = switch (line.kind) {
          DiffKind.context => (' ', null),
          DiffKind.added => ('+', _addedColor.withValues(alpha: 0.15)),
          DiffKind.removed => ('-', _removedColor.withValues(alpha: 0.15)),
        };
        rows.add(Container(
          color: tint,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('$prefix ${line.text}', style: mono),
        ));
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectionArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
          ),
          if (!_showAll && total > _DiffView.collapsedLines)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => setState(() => _showAll = true),
                child: Text(context.l10n.showAll(total)),
              ),
            ),
        ],
      ),
    );
  }
}
