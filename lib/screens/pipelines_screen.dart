import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../l10n/l10n.dart';
import '../models/pipeline_run.dart';
import '../services/app_state.dart';
import '../services/logging.dart';
import '../widgets/empty_state.dart';
import '../widgets/pipeline_visuals.dart';
import '../widgets/work_item_visuals.dart';
import 'pipeline_run_screen.dart';
import 'settings_screen.dart';

final _log = Logger('PipelinesScreen');

/// A pipeline by kind, project and definition id, with the name of a stage
/// for a release.
typedef _DurationKey = (RunKind, String, int, String?);

/// When a running build or release stage started and how long it is
/// expected to take.
typedef _Estimate = ({DateTime start, Duration expected});

/// The latest pipeline runs, refreshed while some of them are still running.
class PipelinesScreen extends StatefulWidget {
  const PipelinesScreen({super.key});

  /// How often the list is refreshed while a run hasn't finished.
  static const refreshInterval = Duration(seconds: 15);

  @override
  State<PipelinesScreen> createState() => _PipelinesScreenState();
}

class _PipelinesScreenState extends State<PipelinesScreen> {
  static const _wideBreakpoint = 840.0;

  final _search = TextEditingController();
  bool _activeOnly = false;

  /// Only builds or only releases; null shows both.
  RunKind? _kind;

  List<PipelineRun>? _runs;

  /// How long the last successful build of each pipeline, or deployment of
  /// each release stage, took; running ones estimate their progress from it.
  Map<_DurationKey, Duration> _lastDurations = {};

  /// Share of the tasks that finished, by kind, project and id, of the
  /// running builds and releases that have no last duration to estimate
  /// from. For a release, only its running stages count.
  Map<(RunKind, String, int), double> _taskProgress = {};
  Object? _error;

  /// Releases that failed to load while the builds did, for example because
  /// the token lacks the Release scope.
  Object? _releaseError;
  bool _loading = false;
  PipelineRun? _selected;
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
      _selected = null;
      _runs = null;
      _load();
    } else if (visible && !_visible) {
      _load(silent: true);
    }
    _visible = visible;
  }

  @override
  void dispose() {
    _refresh?.cancel();
    _search.dispose();
    super.dispose();
  }

  /// A [silent] refresh keeps the list as is, without a progress bar.
  Future<void> _load({bool silent = false}) async {
    _refresh?.cancel();
    final state = AppScope.read(context);
    final api = state.api;
    final projects = state.projects;
    if (api == null || projects.isEmpty) return;
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      Object? releaseError;
      final releases = api.getReleases(projects: projects).catchError((Object e, StackTrace st) {
        logFailure(_log, 'Loading releases failed', e, st);
        releaseError = e;
        return <PipelineRun>[];
      });
      final builds = await api.getPipelineRuns(projects: projects);
      final runs = [...builds, ...await releases]
        ..sort((a, b) => (b.queueTime ?? DateTime(0)).compareTo(a.queueTime ?? DateTime(0)));
      if (!mounted) return;
      setState(() {
        _runs = runs;
        _error = null;
        _releaseError = releaseError;
        _lastDurations = _durations(runs);
      });
      unawaited(_loadTaskProgress(runs));
    } catch (e, st) {
      logFailure(_log, 'Loading pipeline runs failed', e, st);
      // A failed background refresh keeps showing the runs it has.
      if (mounted && !(silent && _runs != null)) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    // Also after a failed refresh, so a network hiccup doesn't stop following.
    if (mounted && (_runs?.any((r) => !r.status.isFinished) ?? false)) {
      _refresh = Timer(PipelinesScreen.refreshInterval, () {
        if (mounted && _visible) _load(silent: true);
      });
    }
  }

  /// The duration of the newest successful build of each pipeline, and of
  /// the newest successful deployment of each release stage, in [runs],
  /// which are sorted newest first.
  static Map<_DurationKey, Duration> _durations(List<PipelineRun> runs) {
    final durations = <_DurationKey, Duration>{};
    for (final r in runs) {
      final definition = r.definitionId;
      if (definition == null) continue;
      if (r.isRelease) {
        for (final s in r.stages) {
          final (start, finish) = (s.startTime, s.finishTime);
          if (s.status != RunStatus.succeeded || start == null || finish == null) continue;
          durations.putIfAbsent(
              (r.kind, r.project, definition, s.name), () => finish.difference(start));
        }
      } else if (r.status == RunStatus.succeeded && r.finishTime != null) {
        durations.putIfAbsent((r.kind, r.project, definition, null), () => r.duration()!);
      }
    }
    return durations;
  }

  /// Fetches the timelines of the running builds and releases that
  /// [_estimate] can't estimate.
  Future<void> _loadTaskProgress(List<PipelineRun> runs) async {
    final api = AppScope.read(context).api;
    if (api == null) return;
    final running = [
      for (final r in runs)
        if (r.status == RunStatus.running && _estimate(r) == null) r,
    ];
    final progress = await Future.wait([
      for (final r in running)
        (r.isRelease
                ? api.getRelease(r.project, r.id).then((p) => p.$2.runningStagesProgress)
                : api.getTimeline(r.project, r.id).then((t) => t.progress))
            .catchError((Object e, StackTrace st) {
          logFailure(_log, 'Loading timeline of ${r.kind.name} ${r.id} failed', e, st);
          // Keeps the last known progress, so the bar doesn't flicker.
          return _taskProgress[(r.kind, r.project, r.id)];
        }),
    ]);
    if (!mounted) return;
    setState(() => _taskProgress = {
          for (final (i, r) in running.indexed)
            if (progress[i] case final double value) (r.kind, r.project, r.id): value,
        });
  }

  /// When the running build, or each running stage of a release, started
  /// and how long it is expected to take; null when one of them can't be
  /// estimated.
  List<_Estimate>? _estimate(PipelineRun run) {
    final definition = run.definitionId;
    if (definition == null) return null;
    final parts = run.isRelease
        ? [
            for (final s in run.stages)
              if (s.status == RunStatus.running)
                (s.startTime, _lastDurations[(run.kind, run.project, definition, s.name)]),
          ]
        : [(run.startTime, _lastDurations[(run.kind, run.project, definition, null)])];
    final estimate = <_Estimate>[
      for (final (start, expected) in parts)
        if (start != null && expected != null) (start: start, expected: expected),
    ];
    return estimate.isEmpty || estimate.length < parts.length ? null : estimate;
  }

  List<PipelineRun> get _filtered {
    final query = _search.text.trim().toLowerCase();
    return (_runs ?? const <PipelineRun>[]).where((r) {
      if (_activeOnly && r.status.isFinished) return false;
      if (_kind != null && r.kind != _kind) return false;
      if (query.isEmpty) return true;
      return r.pipelineName.toLowerCase().contains(query) ||
          r.buildNumber.toLowerCase().contains(query) ||
          (r.branch?.toLowerCase().contains(query) ?? false) ||
          r.project.toLowerCase().contains(query) ||
          (r.requestedFor?.displayName.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void _open(PipelineRun run, bool wide) {
    if (wide) {
      setState(() => _selected = run);
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PipelineRunScreen(project: run.project, id: run.id, kind: run.kind),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= _wideBreakpoint;
      final list = _buildList(state, wide);
      if (!wide) return list;
      final scheme = Theme.of(context).colorScheme;
      return Scaffold(
        backgroundColor: scheme.surfaceContainer,
        body: SafeArea(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                child: SizedBox(
                  width: 420,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: list,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _selected == null
                        ? ColoredBox(
                            color: scheme.surface,
                            child: EmptyState(
                              icon: Icons.touch_app_outlined,
                              title: context.l10n.selectRunTitle,
                              message: context.l10n.selectRunMessage,
                            ),
                          )
                        : PipelineRunScreen(
                            key: ValueKey((_selected!.kind, _selected!.project, _selected!.id)),
                            project: _selected!.project,
                            id: _selected!.id,
                            kind: _selected!.kind,
                            embedded: true,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildList(AppState state, bool wide) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final runs = _filtered;

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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SearchBar(
                  controller: _search,
                  hintText: l10n.searchRunsHint,
                  leading: const Icon(Icons.search),
                  trailing: [
                    if (_search.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(_search.clear),
                      ),
                  ],
                  elevation: const WidgetStatePropertyAll(0),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SegmentedButton<RunKind?>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: null, label: Text(l10n.scopeAll)),
                    ButtonSegment(
                        value: RunKind.build,
                        icon: const Icon(Icons.construction),
                        label: Text(l10n.builds)),
                    ButtonSegment(
                        value: RunKind.release,
                        icon: const Icon(Icons.rocket_launch_outlined),
                        label: Text(l10n.releases)),
                  ],
                  selected: {_kind},
                  onSelectionChanged: (s) => setState(() => _kind = s.first),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(l10n.activeOnly),
                      selected: _activeOnly,
                      onSelected: (v) => setState(() => _activeOnly = v),
                    ),
                  ],
                ),
              ),
            ),
            if (_error == null && _releaseError != null && _kind != RunKind.build)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                  child: Card.filled(
                    color: theme.colorScheme.errorContainer,
                    child: ListTile(
                      leading: Icon(Icons.warning_amber,
                          color: theme.colorScheme.onErrorContainer),
                      textColor: theme.colorScheme.onErrorContainer,
                      title: Text(l10n.loadReleasesFailed),
                      subtitle: Text('${l10n.error(_releaseError!)}\n${l10n.releaseScopeHint}'),
                    ),
                  ),
                ),
              ),
            if (_loading)
              const SliverToBoxAdapter(child: LinearProgressIndicator())
            else
              const SliverToBoxAdapter(child: SizedBox(height: 4)),
            if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: l10n.loadRunsFailed,
                  message: l10n.error(_error!),
                  action: FilledButton.tonalIcon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ),
              )
            else if (_runs != null && runs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.rocket_launch_outlined,
                  title: l10n.noRunsTitle,
                  message: l10n.noRunsMessage,
                ),
              )
            else ...[
              if (_runs != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(l10n.runCount(runs.length),
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                sliver: SliverList.separated(
                  itemCount: runs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _RunCard(
                    run: runs[i],
                    showProject: state.projects.length > 1,
                    estimate: _estimate(runs[i]),
                    taskProgress: _taskProgress[(runs[i].kind, runs[i].project, runs[i].id)],
                    selected: wide &&
                        runs[i].id == _selected?.id &&
                        runs[i].kind == _selected?.kind &&
                        runs[i].project == _selected?.project,
                    onTap: () => _open(runs[i], wide),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RunCard extends StatelessWidget {
  const _RunCard({
    required this.run,
    required this.onTap,
    this.selected = false,
    this.showProject = false,
    this.estimate,
    this.taskProgress,
  });

  final PipelineRun run;
  final VoidCallback onTap;
  final bool selected;

  /// Shows the project name, for when runs of several projects are listed.
  final bool showProject;

  /// When a running build, or the running stages of a release, started and
  /// how long they are expected to take, from the last successful run;
  /// shown as a bar along the bottom of the card.
  final List<_Estimate>? estimate;

  /// Share of the tasks that finished, for a running build or release
  /// without [estimate].
  final double? taskProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final muted = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    return Card.filled(
      color: selected ? scheme.secondaryContainer : scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: RunStatusIcon(run.status, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(run.buildNumber,
                                  maxLines: 1, overflow: TextOverflow.ellipsis, style: muted),
                            ),
                            if (showProject) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(run.project,
                                    maxLines: 1, overflow: TextOverflow.ellipsis, style: muted),
                              ),
                            ],
                            const Spacer(),
                            Text(formatRelative(l10n, run.queueTime), style: muted),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          run.pipelineName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Flexible(flex: 2, child: RunStatusBadge(run.status)),
                            const SizedBox(width: 8),
                            if (run.branch != null) ...[
                              Icon(Icons.call_split, size: 14, color: scheme.onSurfaceVariant),
                              const SizedBox(width: 2),
                            ],
                            Expanded(
                              flex: 3,
                              child: Text(
                                run.branch ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: muted,
                              ),
                            ),
                            if (run.startTime != null) ...[
                              Text(formatDuration(run.duration()), style: muted),
                              const SizedBox(width: 8),
                            ],
                            Tooltip(
                              message: run.requestedFor?.displayName ?? l10n.unknownPerson,
                              child: PersonAvatar(run.requestedFor, radius: 12),
                            ),
                          ],
                        ),
                        if (run.stages.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          StageChips(run.stages),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (run.status == RunStatus.running)
              if (estimate case final estimate?)
                _EstimatedProgress(status: run.status, estimate: estimate)
              else if (taskProgress case final progress?)
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  color: RunStatusStyle.of(run.status, scheme).color,
                ),
          ],
        ),
      ),
    );
  }
}

/// The share of the expected time that has passed, updated every second.
/// Stops just short of full, as a run can take longer than the last one.
class _EstimatedProgress extends StatefulWidget {
  const _EstimatedProgress({required this.status, required this.estimate});

  final RunStatus status;
  final List<_Estimate> estimate;

  @override
  State<_EstimatedProgress> createState() => _EstimatedProgressState();
}

class _EstimatedProgressState extends State<_EstimatedProgress> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    var elapsed = 0, expected = 0;
    for (final e in widget.estimate) {
      elapsed += now.difference(e.start).inMilliseconds;
      expected += e.expected.inMilliseconds;
    }
    final progress = expected <= 0 ? 0.99 : (elapsed / expected).clamp(0.0, 0.99);
    return LinearProgressIndicator(
      value: progress,
      minHeight: 4,
      color: RunStatusStyle.of(widget.status, Theme.of(context).colorScheme).color,
    );
  }
}
