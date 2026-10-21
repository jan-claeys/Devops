import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n.dart';
import '../models/pipeline_run.dart';
import '../services/app_state.dart';
import '../services/logging.dart';
import '../widgets/pipeline_visuals.dart';
import '../widgets/section_card.dart';
import '../widgets/work_item_visuals.dart';

final _log = Logger('PipelineRunScreen');

/// Follows the progress of one pipeline run, refreshing until it finishes.
class PipelineRunScreen extends StatefulWidget {
  const PipelineRunScreen({
    super.key,
    required this.project,
    required this.id,
    this.kind = RunKind.build,
    this.embedded = false,
  });

  final String project;
  final int id;
  final RunKind kind;

  /// True when shown in the detail pane of the wide layout.
  final bool embedded;

  /// How often a run that hasn't finished is refreshed.
  static const refreshInterval = Duration(seconds: 5);

  @override
  State<PipelineRunScreen> createState() => _PipelineRunScreenState();
}

class _PipelineRunScreenState extends State<PipelineRunScreen> {
  PipelineRun? _run;
  Timeline? _timeline;
  Object? _error;
  Timer? _refresh;
  bool _visible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hidden behind another tab or route: refresh once shown again.
    final visible = TickerMode.valuesOf(context).enabled;
    if (_run == null && _error == null) {
      _load();
    } else if (visible && !_visible) {
      _load();
    }
    _visible = visible;
  }

  @override
  void dispose() {
    _refresh?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    _refresh?.cancel();
    final api = AppScope.read(context).api!;
    try {
      final PipelineRun run;
      final Timeline records;
      if (widget.kind == RunKind.release) {
        (run, records) = await api.getRelease(widget.project, widget.id);
      } else {
        final timeline = api.getTimeline(widget.project, widget.id).catchError((
          Object e,
          StackTrace st,
        ) {
          logFailure(_log, 'Loading the timeline of run ${widget.id} failed', e, st);
          return _timeline ?? Timeline(const []);
        });
        run = await api.getPipelineRun(widget.project, widget.id);
        records = await timeline;
      }
      if (!mounted) return;
      setState(() {
        _run = run;
        _timeline = records;
        _error = null;
      });
    } catch (e, st) {
      logFailure(_log, 'Loading run ${widget.id} failed', e, st);
      if (mounted) setState(() => _error = e);
    }
    if (mounted && !(_run?.status.isFinished ?? true)) {
      _refresh = Timer(PipelineRunScreen.refreshInterval, () {
        if (mounted && _visible) _load();
      });
    }
  }

  Future<void> _openInBrowser(PipelineRun run) async {
    final url = AppScope.read(context).api!.runWebUrl(run);
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.browserOpenFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final run = _run;
    final l10n = context.l10n;
    return Scaffold(
      floatingActionButton: run == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openInBrowser(run),
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.openInDevOps),
            ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.medium(
              automaticallyImplyLeading: !widget.embedded,
              title: Text(run?.buildNumber ?? '#${widget.id}'),
            ),
            if (_error != null && run == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 12),
                        Text(l10n.error(_error!), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton.tonal(onPressed: _load, child: Text(l10n.retry)),
                      ],
                    ),
                  ),
                ),
              )
            else if (run == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                sliver: SliverList.list(children: _buildBody(run, _timeline!)),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody(PipelineRun run, Timeline timeline) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    // Determinate, also before the tasks are known, so it doesn't animate.
    final progress = run.status.isFinished ? 1.0 : timeline.progress ?? 0;
    final roots = timeline.roots;
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RunStatusIcon(run.status, size: 48),
          const SizedBox(width: 16),
          Expanded(child: SelectableText(run.pipelineName, style: theme.textTheme.headlineSmall)),
        ],
      ),
      const SizedBox(height: 16),
      Row(children: [RunStatusBadge(run.status)]),
      // A finished release often has stages that are never deployed, so a
      // full bar would say little.
      if (!run.isRelease || !run.status.isFinished) ...[
        const SizedBox(height: 16),
        SectionCard(
          title: l10n.progress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                color: RunStatusStyle.of(run.status, theme.colorScheme).color,
              ),
              if (timeline.tasks.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.tasksProgress(timeline.finishedTasks, timeline.tasks.length),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
      const SizedBox(height: 16),
      SectionCard(
        child: Column(
          children: [
            if (run.artifactVersion != null)
              InfoRow(
                icon: Icons.inventory_2_outlined,
                label: l10n.artifact,
                value: run.artifactVersion,
              ),
            InfoRow(icon: Icons.call_split, label: l10n.branch, value: run.branch),
            InfoRow(
              icon: Icons.person_outline,
              label: l10n.requestedBy,
              valueWidget: Row(
                children: [
                  PersonAvatar(run.requestedFor, radius: 12),
                  const SizedBox(width: 8),
                  Flexible(child: Text(run.requestedFor?.displayName ?? l10n.unknownPerson)),
                ],
              ),
            ),
            InfoRow(
              icon: Icons.schedule,
              label: run.isRelease ? l10n.created : l10n.queued,
              value: formatDateTime(l10n, run.queueTime),
            ),
            InfoRow(
              icon: Icons.play_arrow_outlined,
              label: l10n.started,
              value: formatDateTime(l10n, run.startTime),
            ),
            if (run.finishTime != null)
              InfoRow(
                icon: Icons.flag_outlined,
                label: l10n.finished,
                value: formatDateTime(l10n, run.finishTime),
              ),
            InfoRow(
              icon: Icons.timer_outlined,
              label: l10n.duration,
              value: formatDuration(run.duration()),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SectionCard(
        title: l10n.stages,
        padding: const EdgeInsets.only(top: 4),
        child: roots.isEmpty
            ? Text(
                l10n.noStagesYet,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : Column(
                children: [
                  for (final record in roots) _RecordTile(record: record, timeline: timeline),
                ],
              ),
      ),
    ];
  }
}

/// A stage or job that expands to its jobs or tasks, or a task.
class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record, required this.timeline, this.depth = 0});

  final TimelineRecord record;
  final Timeline timeline;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = timeline.children(record.id);
    final duration = record.startTime == null
        ? null
        : (record.finishTime ?? DateTime.now()).difference(record.startTime!);
    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        if (record.errorCount > 0)
          _Count(Icons.cancel_outlined, record.errorCount, theme.colorScheme.error),
        if (record.warningCount > 0)
          _Count(Icons.warning_amber, record.warningCount, const Color(0xFFFF9D00)),
        Text(
          formatDuration(duration),
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
    final padding = EdgeInsets.only(left: 16.0 * depth);
    final approval = record.approvers.isEmpty
        ? null
        : context.l10n.waitingForApprovalBy(record.approvers.join(', '));
    if (children.isEmpty) {
      return ListTile(
        contentPadding: padding,
        dense: approval == null,
        leading: RunStatusIcon(record.status, size: approval == null ? 20 : 24),
        title: Text(record.name),
        subtitle: approval == null ? null : Text(approval),
        trailing: trailing,
      );
    }
    return ExpansionTile(
      // Keeps the tile open or closed across refreshes.
      key: PageStorageKey(record.id),
      tilePadding: padding,
      shape: const Border(),
      collapsedShape: const Border(),
      initiallyExpanded: record.status == RunStatus.running || record.status == RunStatus.failed,
      leading: RunStatusIcon(record.status),
      title: Text(record.name),
      subtitle: Text([?approval, formatDuration(duration)].where((t) => t.isNotEmpty).join(' · ')),
      children: [
        for (final child in children)
          _RecordTile(record: child, timeline: timeline, depth: depth + 1),
      ],
    );
  }
}

class _Count extends StatelessWidget {
  const _Count(this.icon, this.count, this.color);

  final IconData icon;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 2),
      Text('$count', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
    ],
  );
}
