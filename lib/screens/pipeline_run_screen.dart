import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../l10n/l10n.dart';
import '../models/pipeline_log.dart';
import '../models/pipeline_run.dart';
import '../services/app_state.dart';
import '../services/devops_api.dart';
import '../services/links.dart';
import '../services/logging.dart';
import '../widgets/error_action.dart';
import '../widgets/pipeline_visuals.dart';
import '../widgets/section_card.dart';
import '../widgets/work_item_visuals.dart';
import 'pipeline_log_screen.dart';

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
  List<PendingApproval> _approvals = const [];

  /// The approval that is being approved or rejected.
  String? _responding;
  Object? _error;
  Timer? _refresh;
  bool _visible = true;
  late final AppLifecycleListener _lifecycle;

  /// The lines around the first error in the logs of failed tasks, by log
  /// URL; empty while loading or when the log couldn't be loaded.
  final _excerpts = <String, List<LogLine>>{};

  /// Logs are fetched for this many failed tasks at most.
  static const _maxExcerpts = 5;

  @override
  void initState() {
    super.initState();
    // Back from the background: the run may have moved on meanwhile.
    _lifecycle = AppLifecycleListener(onResume: () {
      if (mounted && _visible) _load();
    });
  }

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
    _lifecycle.dispose();
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
      final approvals = run.isRelease ? run.approvals : await _buildApprovals(api, records);
      if (!mounted) return;
      setState(() {
        _run = run;
        _timeline = records;
        _approvals = approvals;
        _error = null;
      });
      unawaited(_loadExcerpts(records));
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

  Future<List<PendingApproval>> _buildApprovals(DevOpsApi api, Timeline timeline) async {
    try {
      return await api.getApprovals(widget.project, timeline.pendingApprovals);
    } catch (e, st) {
      logFailure(_log, 'Loading the approvals of run ${widget.id} failed', e, st);
      return _approvals;
    }
  }

  Future<void> _respond(PendingApproval approval, bool approve) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final comment = await showDialog<String>(
      context: context,
      builder: (_) => _ApprovalDialog(stage: approval.stage, approve: approve),
    );
    if (comment == null || !mounted) return;
    setState(() => _responding = approval.id);
    try {
      await AppScope.read(context)
          .api!
          .respondToApproval(widget.project, approval, approve: approve, comment: comment);
      messenger.showSnackBar(
          SnackBar(content: Text(approve ? l10n.stageApproved : l10n.stageRejected)));
      if (mounted) await _load();
    } catch (e, st) {
      logFailure(_log, 'Responding to approval ${approval.id} failed', e, st);
      if (mounted) {
        showActionError(context, e,
            scopeHint: approval.isRelease ? l10n.releaseScopeHint : l10n.buildScopeHint);
      }
    }
    if (mounted) setState(() => _responding = null);
  }

  /// The log of a task is complete once it finished, so it is fetched once.
  Future<void> _loadExcerpts(Timeline timeline) async {
    final api = AppScope.read(context).api!;
    final urls = {
      for (final (record, _) in timeline.errors)
        if (record.isTask && record.status.isFinished) ?record.logUrl,
    }.take(_maxExcerpts).where((url) => !_excerpts.containsKey(url)).toList();
    for (final url in urls) {
      _excerpts[url] = const [];
    }
    await Future.wait([
      for (final url in urls)
        api.getLog(url).then((text) {
          if (mounted) setState(() => _excerpts[url] = LogLine.excerpt(LogLine.parse(text)));
        }, onError: (Object e, StackTrace st) {
          logFailure(_log, 'Loading log $url failed', e, st);
        }),
    ]);
  }

  Future<void> _openInBrowser(PipelineRun run) async {
    final url = AppScope.read(context).api!.runWebUrl(run);
    if (!await Links.openInBrowser(Uri.parse(url)) && mounted) {
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
                        ErrorAction(error: _error!, onRetry: _load),
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
    final errors = [
      for (final issue in run.issues)
        if (issue.isError) (null, issue),
      ...timeline.errors,
    ];
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
      if (_approvals.isNotEmpty) ...[
        const SizedBox(height: 16),
        _ApprovalsCard(approvals: _approvals, responding: _responding, onRespond: _respond),
      ],
      if (errors.isNotEmpty) ...[
        const SizedBox(height: 16),
        _ErrorsCard(errors: errors, timeline: timeline, excerpts: _excerpts),
      ],
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

/// The approvals the stages wait for, each with buttons to approve or
/// reject it.
class _ApprovalsCard extends StatelessWidget {
  const _ApprovalsCard({required this.approvals, required this.responding, required this.onRespond});

  final List<PendingApproval> approvals;

  /// The id of the approval that is being responded to.
  final String? responding;
  final void Function(PendingApproval approval, bool approve) onRespond;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return SectionCard(
      title: l10n.approvals,
      color: const Color(0xFFFF9D00).withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, approval) in approvals.indexed) ...[
            if (i > 0) const Divider(height: 24),
            if (approval.stage.isNotEmpty)
              Text(approval.stage, style: theme.textTheme.titleSmall),
            if (approval.approvers.isNotEmpty)
              Text(l10n.waitingForApprovalBy(approval.approvers.join(', ')), style: muted),
            if (approval.instructions != null) ...[
              const SizedBox(height: 4),
              SelectableText(approval.instructions!),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: responding == null ? () => onRespond(approval, true) : null,
                  icon: responding == approval.id
                      ? const SizedBox.square(
                          dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check),
                  label: Text(l10n.voteApprove),
                ),
                OutlinedButton.icon(
                  onPressed: responding == null ? () => onRespond(approval, false) : null,
                  icon: const Icon(Icons.close),
                  label: Text(l10n.voteReject),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Asks to confirm a response to an approval, with an optional comment.
/// Pops the comment, or null when canceled.
class _ApprovalDialog extends StatefulWidget {
  const _ApprovalDialog({required this.stage, required this.approve});

  final String stage;
  final bool approve;

  @override
  State<_ApprovalDialog> createState() => _ApprovalDialogState();
}

class _ApprovalDialogState extends State<_ApprovalDialog> {
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.approve ? l10n.approveStage(widget.stage) : l10n.rejectStage(widget.stage)),
      content: TextField(
        controller: _comment,
        autofocus: true,
        minLines: 1,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: l10n.approvalCommentHint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_comment.text.trim()),
          child: Text(widget.approve ? l10n.voteApprove : l10n.voteReject),
        ),
      ],
    );
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
        onTap: record.logUrl == null ? null : () => _openLog(context, record),
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

void _openLog(BuildContext context, TimelineRecord record) => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PipelineLogScreen(title: record.name, url: record.logUrl!)),
    );

/// The errors that made a run fail, each with the step that logged it and a
/// link to the log of that step.
class _ErrorsCard extends StatefulWidget {
  const _ErrorsCard({required this.errors, required this.timeline, required this.excerpts});

  /// The record is null for an error of the pipeline itself.
  final List<(TimelineRecord?, RunIssue)> errors;
  final Timeline timeline;

  /// Log excerpts by log URL, shown with the first error of each task.
  final Map<String, List<LogLine>> excerpts;

  /// How many errors are shown before "show all".
  static const collapsedCount = 5;

  @override
  State<_ErrorsCard> createState() => _ErrorsCardState();
}

class _ErrorsCardState extends State<_ErrorsCard> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final errors = widget.errors;
    final shown = _showAll ? errors : errors.take(_ErrorsCard.collapsedCount);
    // The errors of a step are listed under its path, which is shown once.
    final groups = <(TimelineRecord?, List<RunIssue>)>[];
    for (final (record, issue) in shown) {
      if (groups.isNotEmpty && groups.last.$1 == record) {
        groups.last.$2.add(issue);
      } else {
        groups.add((record, [issue]));
      }
    }
    return SectionCard(
      title: l10n.runErrors,
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, (record, issues)) in groups.indexed) ...[
            if (record != null)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 12, bottom: 2),
                child: Text(
                  widget.timeline.path(record).join(' › '),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            for (final (j, issue) in issues.indexed)
              _ErrorEntry(
                message: issue.message,
                // The excerpt leads up to the first error of the step.
                excerpt: switch (record?.logUrl) {
                  final url? when j == 0 => widget.excerpts[url] ?? const [],
                  _ => const [],
                },
                onViewLog: record?.logUrl == null ? null : () => _openLog(context, record!),
              ),
          ],
          if (!_showAll && errors.length > _ErrorsCard.collapsedCount)
            TextButton(
              onPressed: () => setState(() => _showAll = true),
              child: Text(l10n.showAll(errors.length)),
            ),
        ],
      ),
    );
  }
}

/// One error, collapsed to the start of its first line so long messages
/// don't push the rest of the card, and its log button, out of view.
class _ErrorEntry extends StatefulWidget {
  const _ErrorEntry({required this.message, this.excerpt = const [], this.onViewLog});

  final String message;

  /// The lines of the log that lead up to the error, shown once expanded: a
  /// glimpse of the cause, the whole log is one tap away.
  final List<LogLine> excerpt;
  final VoidCallback? onViewLog;

  /// Lines of the first line of the message shown while collapsed.
  static const collapsedLines = 2;

  @override
  State<_ErrorEntry> createState() => _ErrorEntryState();
}

class _ErrorEntryState extends State<_ErrorEntry> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final style = theme.textTheme.bodyMedium;
    final title = widget.message.split('\n').first.trim();
    return LayoutBuilder(builder: (context, constraints) {
      final painter = TextPainter(
        text: TextSpan(text: title, style: style),
        maxLines: _ErrorEntry.collapsedLines,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: constraints.maxWidth - _iconWidth - _toggleWidth);
      // The log is only offered once expanded, so a step with a log can
      // always be expanded.
      final expandable = title != widget.message ||
          painter.didExceedMaxLines ||
          widget.excerpt.isNotEmpty ||
          widget.onViewLog != null;
      painter.dispose();
      void toggle() => setState(() => _expanded = !_expanded);
      return InkWell(
        onTap: expandable ? toggle : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _iconWidth,
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.cancel, size: 20, color: theme.colorScheme.error),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_expanded)
                      SelectableText(widget.message, style: style)
                    else
                      Text(
                        title,
                        style: style,
                        maxLines: _ErrorEntry.collapsedLines,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (_expanded && widget.excerpt.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Material(
                          color: theme.colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(color: theme.colorScheme.outlineVariant),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: widget.onViewLog,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final line in widget.excerpt)
                                    LogLineView(line, maxLines: 2),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_expanded && widget.onViewLog != null)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: widget.onViewLog,
                        icon: const Icon(Icons.article_outlined, size: 18),
                        label: Text(l10n.viewLog),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: _toggleWidth,
                child: expandable
                    ? IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        tooltip: _expanded ? l10n.showLess : l10n.showMore,
                        onPressed: toggle,
                        icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    });
  }

  /// The width of the status icon and of the expand button beside the text.
  static const _iconWidth = 32.0;
  static const _toggleWidth = 36.0;
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
