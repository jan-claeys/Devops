import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../l10n/l10n.dart';
import '../models/dashboard_summary.dart';
import '../models/pipeline_run.dart';
import '../models/pull_request.dart';
import '../models/run_estimates.dart';
import '../models/work_item.dart';
import '../services/app_state.dart';
import '../services/devops_api.dart';
import '../services/logging.dart';
import '../widgets/empty_state.dart';
import '../widgets/pipeline_visuals.dart';
import '../widgets/pull_request_visuals.dart';
import '../widgets/section_card.dart';
import '../widgets/work_item_visuals.dart';
import 'pipeline_run_screen.dart';
import 'pull_request_screen.dart';
import 'settings_screen.dart';
import 'work_item_detail_screen.dart';

final _log = Logger('DashboardScreen');

enum _Source { builds, releases, pullRequests, tickets }

/// What waits for the user: pull requests to review or to finish, failed
/// runs they started, approvals, their runs and their open tickets.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.onShowTickets,
    this.onShowPullRequests,
    this.onShowPipelines,
  });

  /// How often the overview is refreshed while it is shown.
  static const refreshInterval = Duration(minutes: 1);

  /// The most open tickets that are loaded.
  static const ticketLimit = 500;

  /// How many of their latest builds of the user are loaded, besides the
  /// latest builds of everyone.
  static const myRunLimit = 20;

  final VoidCallback? onShowTickets;
  final VoidCallback? onShowPullRequests;
  final VoidCallback? onShowPipelines;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _wideBreakpoint = 840.0;
  static const _maxRuns = 5;
  static const _maxPullRequests = 5;
  static const _maxTickets = 8;

  DashboardSummary? _summary;
  RunEstimates _estimates = RunEstimates(const []);
  Map<_Source, Object> _errors = const {};

  /// When the overview last loaded, and why a background refresh since failed.
  DateTime? _updated;
  Object? _refreshError;
  bool _loading = false;
  String? _loadedFor;
  Timer? _refresh;
  bool _visible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    final key = '${state.organization}|${state.projects.join('|')}';
    // Hidden behind another tab or route: refresh once shown again.
    final visible = TickerMode.valuesOf(context).enabled;
    if (key != _loadedFor) {
      _loadedFor = key;
      _summary = null;
      _load();
    } else if (visible && !_visible) {
      _load(silent: true);
    }
    _visible = visible;
  }

  @override
  void dispose() {
    _refresh?.cancel();
    super.dispose();
  }

  /// A [silent] refresh keeps the overview as is, without a progress bar.
  Future<void> _load({bool silent = false}) async {
    _refresh?.cancel();
    final state = AppScope.read(context);
    final api = state.api;
    final projects = state.projects;
    if (api == null || projects.isEmpty) return;
    if (!silent) setState(() => _loading = true);

    // Each part loads on its own, so a missing token scope only hides that part.
    final errors = <_Source, Object>{};
    Future<List<T>> guard<T>(_Source source, Future<List<T>> future) =>
        future.catchError((Object e, StackTrace st) {
          logFailure(_log, 'Loading ${source.name} failed', e, st);
          errors[source] = e;
          return <T>[];
        });
    final me = await api.getCurrentUserId().then<String?>((id) => id, onError: (Object _) => null);
    final (builds, myBuilds, releases, pullRequests, tickets) = await (
      // The latest builds of everyone tell whether a failed build of the
      // user has been fixed since, and how long a running one will take.
      guard(_Source.builds, api.getPipelineRuns(projects: projects)),
      guard(
          _Source.builds,
          me == null
              ? Future.value(<PipelineRun>[])
              : api.getPipelineRuns(
                  projects: projects, requestedFor: me, top: DashboardScreen.myRunLimit)),
      guard(_Source.releases, api.getReleases(projects: projects)),
      guard(_Source.pullRequests,
          api.getPullRequests(projects: projects, scope: PullRequestScope.mine)),
      // The open tickets assigned to the user.
      guard(_Source.tickets,
          api.queryWorkItems(projects: projects, top: DashboardScreen.ticketLimit)),
    ).wait;
    if (!mounted) return;

    final runs = {
      for (final r in [...builds, ...myBuilds, ...releases]) (r.kind, r.project, r.id): r,
    }.values.toList()
      ..sort((a, b) => (b.queueTime ?? DateTime(0)).compareTo(a.queueTime ?? DateTime(0)));
    final failed =
        [_Source.builds, _Source.pullRequests, _Source.tickets].every(errors.containsKey);
    setState(() {
      _loading = false;
      // A failed background refresh keeps showing what it has.
      if (failed && silent && _summary != null) {
        _refreshError = errors.values.first;
        return;
      }
      _refreshError = null;
      _errors = errors;
      _summary = failed
          ? null
          : DashboardSummary(runs: runs, pullRequests: pullRequests, tickets: tickets, me: me);
      _estimates = RunEstimates(runs);
      if (!failed) _updated = DateTime.now();
    });
    _refresh = Timer(DashboardScreen.refreshInterval, () {
      if (mounted && _visible) _load(silent: true);
    });
  }

  void _openRun(PipelineRun run) => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PipelineRunScreen(project: run.project, id: run.id, kind: run.kind),
      ));

  void _openPullRequest(PullRequest pr) => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PullRequestScreen(project: pr.project, id: pr.id),
      ));

  void _openTicket(WorkItem ticket) => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => WorkItemDetailScreen(id: ticket.id),
      ));

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final page = _buildPage();
      if (constraints.maxWidth < _wideBreakpoint) return page;
      // A rounded panel on a darker background, like the lists of the other tabs.
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(borderRadius: BorderRadius.circular(24), child: page),
          ),
        ),
      );
    });
  }

  Widget _buildPage() {
    final l10n = context.l10n;
    final summary = _summary;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // No title: the navigation bar already shows which screen this is.
            SliverAppBar(
              floating: true,
              actions: [
                IconButton(
                  tooltip: l10n.refresh,
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  tooltip: l10n.settings,
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            if (_loading)
              const SliverToBoxAdapter(child: LinearProgressIndicator())
            else
              const SliverToBoxAdapter(child: SizedBox(height: 4)),
            if (summary == null && _errors.isNotEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: l10n.loadDashboardFailed,
                  message: l10n.error(_errors.values.first),
                  action: FilledButton.tonalIcon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ),
              )
            else if (summary != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: _buildOverview(summary),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview(DashboardSummary summary) {
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= _wideBreakpoint;
      final left = [
        _buildWaiting(summary),
        if (!_errors.containsKey(_Source.pullRequests)) _buildPullRequests(summary),
      ];
      final right = [
        if (!_errors.containsKey(_Source.builds)) _buildRuns(summary),
        if (!_errors.containsKey(_Source.tickets)) _buildTickets(summary),
      ];
      return _spaced([
        if ((_refreshError, _updated) case (final error?, final updated?))
          _StaleWarning(error: error, updated: updated),
        if (summary.failingOnMain.isNotEmpty) _buildFailingOnMain(summary),
        for (final MapEntry(key: source, value: error) in _errors.entries)
          _ErrorCard(source: source, error: error),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _spaced(left)),
              const SizedBox(width: 12),
              Expanded(child: _spaced(right)),
            ],
          )
        else ...[
          left.first,
          ...right.take(1),
          ...left.skip(1),
          ...right.skip(1),
        ],
      ]);
    });
  }

  /// [children] below each other, 12 pixels apart.
  static Widget _spaced(List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            child,
          ],
        ],
      );

  /// A muted line for a section without anything to show.
  Widget _emptyLine(String text, {IconData? icon, Color? iconColor}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(text,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
      ],
    );
  }

  Widget _showAll(int count, VoidCallback? onPressed) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton(onPressed: onPressed, child: Text(context.l10n.showAll(count))),
      );

  Widget _buildFailingOnMain(DashboardSummary summary) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = RunStatusStyle.of(RunStatus.failed, theme.colorScheme).color;
    final failing = summary.failingOnMain;
    // A card, so the tiles show their ink on its color.
    return Card.filled(
      color: color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.failingOnMain(failing.length),
                      style: theme.textTheme.titleSmall),
                ),
              ],
            ),
            for (final run in failing)
              _runTile(run, '${run.project} · ${run.branch} · '
                  '${formatRelative(l10n, run.finishTime ?? run.queueTime)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildWaiting(DashboardSummary summary) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final items = [
      for (final pr in summary.toReview)
        _pullRequestTile(
          pr,
          leading: Icon(Icons.rate_review_outlined,
              color: RunStatusStyle.of(RunStatus.running, scheme).color),
          subtitle: '${l10n.waitingForYourReview} · ${pr.repositoryName} · '
              '${formatRelative(l10n, pr.creationDate)}',
        ),
      for (final pr in summary.needChanges)
        if (DashboardSummary.blockingReviewer(pr) case final reviewer?)
          _pullRequestTile(
            pr,
            leading: ReviewerAvatar(reviewer),
            subtitle: '${reviewVoteLabel(l10n, reviewer.vote)} · '
                '${reviewer.identity.displayName}',
          )
        else
          _pullRequestTile(
            pr,
            leading: Icon(Icons.warning_amber,
                color: RunStatusStyle.of(RunStatus.partiallySucceeded, scheme).color),
            subtitle: '${l10n.mergeConflicts} · ${pr.repositoryName}',
          ),
      for (final pr in summary.readyToComplete)
        _pullRequestTile(
          pr,
          leading: Icon(Icons.check_circle,
              color: RunStatusStyle.of(RunStatus.succeeded, scheme).color),
          subtitle: '${l10n.readyToComplete} · ${pr.repositoryName}',
        ),
      for (final run in summary.myFailedRuns)
        _runTile(run, [
          runStatusLabel(l10n, run.status),
          ?run.branch,
          formatRelative(l10n, run.finishTime ?? run.queueTime),
        ].join(' · ')),
      for (final run in summary.myApprovals)
        _runTile(run, '${l10n.yourApproval} · ${run.buildNumber}'),
    ];
    return SectionCard(
      filled: true,
      title: summary.waitingCount == 0
          ? l10n.waitingForYou
          : '${l10n.waitingForYou} (${summary.waitingCount})',
      child: items.isEmpty
          ? _emptyLine(l10n.nothingWaiting,
              icon: Icons.check_circle_outline,
              iconColor: RunStatusStyle.of(RunStatus.succeeded, scheme).color)
          : Column(children: items),
    );
  }

  Widget _runTile(PipelineRun run, String subtitle) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: RunStatusIcon(run.status),
        title: Text(run.pipelineName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: () => _openRun(run),
      );

  Widget _pullRequestTile(PullRequest pr,
          {required Widget leading, required String subtitle, Widget? trailing}) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: leading,
        title: Text(pr.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: trailing,
        onTap: () => _openPullRequest(pr),
      );

  Widget _buildRuns(DashboardSummary summary) {
    final l10n = context.l10n;
    final runs = summary.myRuns;
    return SectionCard(
      filled: true,
      title: l10n.myRuns,
      child: runs.isEmpty
          ? _emptyLine(l10n.noRecentRuns)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final run in runs.take(_maxRuns)) ...[
                  _runTile(run, [
                    run.buildNumber,
                    ?run.branch,
                    if (run.status.isFinished)
                      formatRelative(l10n, run.finishTime ?? run.queueTime)
                    else if (run.startTime != null)
                      formatDuration(run.duration()),
                  ].join(' · ')),
                  if (run.status == RunStatus.running)
                    if (_estimates.of(run) case final estimate?)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: EstimatedProgress(status: run.status, estimate: estimate),
                      ),
                ],
                if (runs.length > _maxRuns) _showAll(runs.length, widget.onShowPipelines),
              ],
            ),
    );
  }

  Widget _buildPullRequests(DashboardSummary summary) {
    final l10n = context.l10n;
    final prs = summary.openPullRequests;
    return SectionCard(
      filled: true,
      title: l10n.myPullRequests,
      child: prs.isEmpty
          ? _emptyLine(l10n.noPullRequestsTitle)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final pr in prs.take(_maxPullRequests))
                  _pullRequestTile(
                    pr,
                    leading: PersonAvatar(pr.createdBy, radius: 18),
                    subtitle: [
                      if (pr.status == PullRequestStatus.draft) l10n.prDraft,
                      pr.repositoryName,
                      formatRelative(l10n, pr.creationDate),
                    ].join(' · '),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final r in pr.reviewers.where((r) => !r.isGroup).take(3))
                          ReviewerAvatar(r),
                      ],
                    ),
                  ),
                if (prs.length > _maxPullRequests)
                  _showAll(prs.length, widget.onShowPullRequests),
              ],
            ),
    );
  }

  Widget _buildTickets(DashboardSummary summary) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    final stale = RunStatusStyle.of(RunStatus.partiallySucceeded, scheme).color;
    // The tickets being worked on first, then by priority and the most
    // recently changed.
    bool isNew(WorkItem t) => stateCategory(t.state) == StateCategory.proposed;
    final tickets = [...summary.tickets]..sort((a, b) {
        if (isNew(a) != isNew(b)) return isNew(a) ? 1 : -1;
        final priority = (a.priority ?? 99).compareTo(b.priority ?? 99);
        if (priority != 0) return priority;
        return (b.changedDate ?? DateTime(0)).compareTo(a.changedDate ?? DateTime(0));
      });
    return SectionCard(
      filled: true,
      title: l10n.myTickets,
      child: tickets.isEmpty
          ? _emptyLine(l10n.noTicketsTitle)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final t in tickets.take(_maxTickets))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: TypeIcon(t.type, size: 36),
                    title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: '#${t.id} · ${t.state}'),
                        if (summary.staleFor(t) case final idle?)
                          TextSpan(
                            text: ' · ${l10n.noChangesFor(idle.inDays)}',
                            style: TextStyle(color: stale),
                          ),
                      ]),
                      style: muted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: switch (t.priority) {
                      final p? when p <= 2 => _PriorityBadge(p, urgent: t.isBug),
                      _ => null,
                    },
                    onTap: () => _openTicket(t),
                  ),
                if (tickets.length > _maxTickets) _showAll(tickets.length, widget.onShowTickets),
              ],
            ),
    );
  }
}

/// Tells that the overview shows older data, as refreshing it failed.
class _StaleWarning extends StatelessWidget {
  const _StaleWarning({required this.error, required this.updated});

  final Object error;
  final DateTime updated;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Tooltip(
      message: l10n.error(error),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 18, color: muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(l10n.refreshFailed(formatRelative(l10n, updated)),
                style: theme.textTheme.bodySmall?.copyWith(color: muted)),
          ),
        ],
      ),
    );
  }
}

/// Small pill with a high priority; red for an [urgent] one, such as a bug.
class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge(this.priority, {this.urgent = false});

  final int priority;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = urgent
        ? RunStatusStyle.of(RunStatus.failed, scheme).color
        : scheme.onSurfaceVariant;
    return Tooltip(
      message: '${context.l10n.priority} $priority',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: urgent ? color.withValues(alpha: 0.12) : null,
          border: Border.all(color: urgent ? color : scheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('P$priority', style: theme.textTheme.labelMedium?.copyWith(color: color)),
      ),
    );
  }
}

/// Tells which part of the overview couldn't be loaded, and why.
class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.source, required this.error});

  final _Source source;
  final Object error;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final (title, hint) = switch (source) {
      _Source.builds => (l10n.loadRunsFailed, null),
      _Source.releases => (l10n.loadReleasesFailed, l10n.releaseScopeHint),
      _Source.pullRequests => (l10n.loadPullRequestsFailed, l10n.codeScopeHint),
      _Source.tickets => (l10n.loadTicketsFailed, null),
    };
    return Card.filled(
      color: scheme.errorContainer,
      child: ListTile(
        leading: Icon(Icons.warning_amber, color: scheme.onErrorContainer),
        textColor: scheme.onErrorContainer,
        title: Text(title),
        subtitle: Text([l10n.error(error), ?hint].join('\n')),
      ),
    );
  }
}
