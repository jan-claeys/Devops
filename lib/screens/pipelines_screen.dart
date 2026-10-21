import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../l10n/l10n.dart';
import '../models/pipeline_run.dart';
import '../services/app_state.dart';
import '../services/logging.dart';
import '../widgets/empty_state.dart';
import '../widgets/pipeline_visuals.dart';
import '../widgets/project_picker.dart';
import '../widgets/work_item_visuals.dart';
import 'pipeline_run_screen.dart';
import 'settings_screen.dart';

final _log = Logger('PipelinesScreen');

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

  List<PipelineRun>? _runs;
  Object? _error;
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
      final runs = await api.getPipelineRuns(projects: projects);
      if (!mounted) return;
      setState(() {
        _runs = runs;
        _error = null;
      });
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

  Future<void> _pickProjects() async {
    final state = AppScope.read(context);
    final picked =
        await showProjectPicker(context, api: state.api!, current: state.projects);
    if (picked != null && !listEquals(picked, state.projects)) {
      await state.setProjects(picked);
    }
  }

  List<PipelineRun> get _filtered {
    final query = _search.text.trim().toLowerCase();
    return (_runs ?? const <PipelineRun>[]).where((r) {
      if (_activeOnly && r.status.isFinished) return false;
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
        builder: (_) => PipelineRunScreen(project: run.project, id: run.id),
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
                            key: ValueKey((_selected!.project, _selected!.id)),
                            project: _selected!.project,
                            id: _selected!.id,
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
            SliverAppBar.medium(
              title: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _pickProjects,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                          switch (state.projects) {
                            [] => l10n.chooseProjects,
                            [final project] => project,
                            final projects => l10n.projectCount(projects.length),
                          },
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
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
            else if (state.projects.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.folder_open_outlined,
                  title: l10n.noProjectsTitle,
                  message: l10n.noProjectsMessage,
                  action: FilledButton.icon(
                    onPressed: _pickProjects,
                    icon: const Icon(Icons.folder_outlined),
                    label: Text(l10n.chooseProjects),
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
                    selected: wide &&
                        runs[i].id == _selected?.id &&
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
  });

  final PipelineRun run;
  final VoidCallback onTap;
  final bool selected;

  /// Shows the project name, for when runs of several projects are listed.
  final bool showProject;

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
        child: Padding(
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
                        RunStatusBadge(run.status),
                        const SizedBox(width: 8),
                        if (run.branch != null) ...[
                          Icon(Icons.call_split, size: 14, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 2),
                        ],
                        Expanded(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
