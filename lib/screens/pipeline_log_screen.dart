import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import '../l10n/l10n.dart';
import '../models/pipeline_log.dart';
import '../services/app_state.dart';
import '../services/logging.dart';
import '../widgets/pipeline_visuals.dart';

final _log = Logger('PipelineLogScreen');

/// The log of one step of a pipeline run, opened at its first error, or at
/// its end when it has none.
class PipelineLogScreen extends StatefulWidget {
  const PipelineLogScreen({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<PipelineLogScreen> createState() => _PipelineLogScreenState();
}

class _PipelineLogScreenState extends State<PipelineLogScreen> {
  final _scroll = ScrollController();
  final _targetKey = GlobalKey();
  List<LogLine>? _lines;
  Object? _error;

  /// Only the errors and warnings are shown.
  bool _issuesOnly = false;

  /// The error that was jumped to, as an index in [_errors].
  int? _current;

  /// The line that is being scrolled to, as an index in [_shown].
  int? _target;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_lines == null && _error == null) _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final text = await AppScope.read(context).api!.getLog(widget.url);
      if (!mounted) return;
      setState(() => _lines = LogLine.parse(text));
      if (_errors.isNotEmpty) {
        _jumpToError(0);
      } else {
        _scrollToEnd();
      }
    } catch (e, st) {
      logFailure(_log, 'Loading log ${widget.url} failed', e, st);
      if (mounted) setState(() => _error = e);
    }
  }

  List<LogLine> get _shown {
    final lines = _lines ?? const [];
    return _issuesOnly ? lines.where((l) => l.isIssue).toList() : lines;
  }

  /// The indexes of the error lines in [_shown].
  List<int> get _errors => [
        for (final (i, line) in _shown.indexed)
          if (line.kind == LogLineKind.error) i,
      ];

  void _jumpToError(int error) {
    setState(() => _current = error);
    _scrollTo(_errors[error]);
  }

  /// The lines are built lazily and wrap, so their offset isn't known up
  /// front: jump to an estimate until the line is built, then reveal it.
  Future<void> _scrollTo(int index) async {
    setState(() => _target = index);
    for (var attempt = 0; attempt < 10; attempt++) {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || !_scroll.hasClients || _target != index) return;
      final line = _targetKey.currentContext;
      if (line != null && line.mounted) {
        await Scrollable.ensureVisible(line, alignment: 0.3);
        return;
      }
      final position = _scroll.position;
      final average = (position.maxScrollExtent + position.viewportDimension) / _shown.length;
      position.jumpTo((index * average - position.viewportDimension * 0.3)
          .clamp(0.0, position.maxScrollExtent));
    }
  }

  /// The length of the list grows while it is built, so keep jumping until
  /// the end stays put.
  Future<void> _scrollToEnd() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || !_scroll.hasClients) return;
      final position = _scroll.position;
      if (position.pixels >= position.maxScrollExtent) return;
      position.jumpTo(position.maxScrollExtent);
    }
  }

  void _toggleIssuesOnly() {
    setState(() {
      _issuesOnly = !_issuesOnly;
      _current = null;
      _target = null;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _copy(List<LogLine> lines) async {
    await Clipboard.setData(ClipboardData(text: lines.map((l) => l.text).join('\n')));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.logCopied)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lines = _lines;
    final shown = _shown;
    final errors = _errors;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (lines != null && lines.isNotEmpty) ...[
            IconButton(
              tooltip: l10n.onlyErrorsAndWarnings,
              isSelected: _issuesOnly,
              icon: const Icon(Icons.filter_list),
              selectedIcon: const Icon(Icons.filter_list_off),
              onPressed: _toggleIssuesOnly,
            ),
            IconButton(
              tooltip: l10n.copyLog,
              icon: const Icon(Icons.copy),
              onPressed: () => _copy(lines),
            ),
          ],
        ],
      ),
      bottomNavigationBar: errors.isEmpty
          ? null
          : BottomAppBar(
              height: 64,
              child: Row(
                children: [
                  Icon(Icons.cancel, size: 20, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_current == null
                        ? l10n.errorCount(errors.length)
                        : l10n.errorPosition(_current! + 1, errors.length)),
                  ),
                  IconButton(
                    tooltip: l10n.previousError,
                    icon: const Icon(Icons.keyboard_arrow_up),
                    onPressed: (_current ?? 0) > 0 ? () => _jumpToError(_current! - 1) : null,
                  ),
                  IconButton(
                    tooltip: l10n.nextError,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: (_current ?? -1) < errors.length - 1
                        ? () => _jumpToError((_current ?? -1) + 1)
                        : null,
                  ),
                ],
              ),
            ),
      body: switch ((lines, _error)) {
        (_, final error?) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 12),
                  Text(l10n.error(error), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.tonal(onPressed: _load, child: Text(l10n.retry)),
                ],
              ),
            ),
          ),
        (null, _) => const Center(child: CircularProgressIndicator()),
        (final lines?, _) when lines.isEmpty => Center(child: Text(l10n.logEmpty)),
        _ when shown.isEmpty => Center(child: Text(l10n.noLogIssues)),
        _ => SelectionArea(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: shown.length,
              itemBuilder: (context, i) => LogLineView(
                shown[i],
                key: i == _target ? _targetKey : null,
                highlighted: _current != null && i == errors[_current!],
              ),
            ),
          ),
      },
    );
  }
}
