import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../l10n/l10n.dart';
import '../models/pull_request.dart';
import '../services/app_state.dart';
import '../services/devops_api.dart';
import '../services/logging.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_action.dart';
import '../widgets/pull_request_visuals.dart';
import '../widgets/work_item_visuals.dart';
import 'pull_request_screen.dart';
import 'settings_screen.dart';

final _log = Logger('PullRequestsScreen');

/// The pull requests of the selected projects.
class PullRequestsScreen extends StatefulWidget {
  const PullRequestsScreen({super.key});

  @override
  State<PullRequestsScreen> createState() => PullRequestsScreenState();
}

class PullRequestsScreenState extends State<PullRequestsScreen> {
  static const _wideBreakpoint = 840.0;

  final _search = TextEditingController();
  PullRequestScope _scope = PullRequestScope.all;
  bool _openOnly = true;

  List<PullRequest>? _pullRequests;
  Object? _error;
  bool _loading = false;
  PullRequest? _selected;
  String? _loadedFor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    final key = '${state.organization}|${state.projects.join('|')}';
    if (key != _loadedFor) {
      _loadedFor = key;
      _selected = null;
      _load();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Shows the open pull requests of the user, as counted on the overview.
  void showMine() {
    _search.clear();
    setState(() {
      _scope = PullRequestScope.mine;
      _openOnly = true;
      _selected = null;
    });
    _load();
  }

  Future<void> _load() async {
    final state = AppScope.read(context);
    final api = state.api;
    final projects = state.projects;
    if (api == null || projects.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pullRequests =
          await api.getPullRequests(projects: projects, scope: _scope, openOnly: _openOnly);
      if (!mounted) return;
      setState(() => _pullRequests = pullRequests);
    } catch (e, st) {
      logFailure(_log, 'Loading pull requests failed', e, st);
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<PullRequest> get _filtered {
    final query = _search.text.trim().toLowerCase();
    return (_pullRequests ?? const <PullRequest>[]).where((pr) {
      if (query.isEmpty) return true;
      return pr.title.toLowerCase().contains(query) ||
          pr.id.toString().contains(query) ||
          pr.repositoryName.toLowerCase().contains(query) ||
          (pr.sourceBranch?.toLowerCase().contains(query) ?? false) ||
          (pr.targetBranch?.toLowerCase().contains(query) ?? false) ||
          pr.project.toLowerCase().contains(query) ||
          (pr.createdBy?.displayName.toLowerCase().contains(query) ?? false) ||
          pr.reviewers.any((r) => r.identity.displayName.toLowerCase().contains(query));
    }).toList();
  }

  void _open(PullRequest pr, bool wide) {
    if (wide) {
      setState(() => _selected = pr);
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PullRequestScreen(project: pr.project, id: pr.id),
      ));
    }
  }

  bool _isSelected(PullRequest pr) =>
      pr.id == _selected?.id && pr.project == _selected?.project;

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
                              title: context.l10n.selectPullRequestTitle,
                              message: context.l10n.selectPullRequestMessage,
                            ),
                          )
                        : PullRequestScreen(
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
    final pullRequests = _filtered;
    final unauthorized = switch (_error) {
      DevOpsException(kind: DevOpsError.unauthorized) => true,
      _ => false,
    };

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
                  hintText: l10n.searchPullRequestsHint,
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
                child: SegmentedButton<PullRequestScope>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                        value: PullRequestScope.reviewing,
                        icon: const Icon(Icons.rate_review_outlined),
                        label: Text(l10n.scopeReviewing)),
                    ButtonSegment(
                        value: PullRequestScope.createdByMe,
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(l10n.scopeCreatedByMe)),
                    ButtonSegment(
                        value: PullRequestScope.all,
                        icon: const Icon(Icons.groups_outlined),
                        label: Text(l10n.scopeAll)),
                  ],
                  selected: {_scope},
                  onSelectionChanged: (s) {
                    setState(() => _scope = s.first);
                    _load();
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(l10n.openOnly),
                      selected: _openOnly,
                      onSelected: (v) {
                        setState(() => _openOnly = v);
                        _load();
                      },
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
                  title: l10n.loadPullRequestsFailed,
                  // Tokens from before the pull requests lack the Code scope.
                  message: unauthorized
                      ? '${l10n.error(_error!)}\n${l10n.codeScopeHint}'
                      : l10n.error(_error!),
                  action: ErrorAction(error: _error!, onRetry: _load),
                ),
              )
            else if (_pullRequests != null && pullRequests.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.call_merge,
                  title: l10n.noPullRequestsTitle,
                  message: l10n.noPullRequestsMessage,
                ),
              )
            else ...[
              if (_pullRequests != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(l10n.pullRequestCount(pullRequests.length),
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                sliver: SliverList.separated(
                  itemCount: pullRequests.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _PullRequestCard(
                    pullRequest: pullRequests[i],
                    showProject: state.projects.length > 1,
                    selected: wide && _isSelected(pullRequests[i]),
                    onTap: () => _open(pullRequests[i], wide),
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

class _PullRequestCard extends StatelessWidget {
  const _PullRequestCard({
    required this.pullRequest,
    required this.onTap,
    this.selected = false,
    this.showProject = false,
  });

  /// Reviewers shown on the card; the details list all of them.
  static const _maxReviewers = 3;

  final PullRequest pullRequest;
  final VoidCallback onTap;
  final bool selected;

  /// Shows the project name, for when pull requests of several projects are listed.
  final bool showProject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final muted = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    final pr = pullRequest;
    final reviewers = pr.reviewers.take(_maxReviewers).toList();
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
              Tooltip(
                message: pr.createdBy?.displayName ?? l10n.unknownPerson,
                child: PersonAvatar(pr.createdBy, radius: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('!${pr.id}', style: muted),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            showProject ? '${pr.repositoryName} · ${pr.project}' : pr.repositoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: muted,
                          ),
                        ),
                        const Spacer(),
                        Text(formatRelative(l10n, pr.creationDate), style: muted),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pr.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        PullRequestStatusBadge(pr.status),
                        if (pr.hasConflicts) ...[
                          const SizedBox(width: 6),
                          Tooltip(
                            message: l10n.mergeConflicts,
                            child: Icon(Icons.warning_amber, size: 16, color: scheme.error),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Icon(Icons.call_split, size: 14, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${pr.sourceBranch ?? ''} → ${pr.targetBranch ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: muted,
                          ),
                        ),
                        for (final reviewer in reviewers)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: ReviewerAvatar(reviewer, radius: 11),
                          ),
                        if (pr.reviewers.length > _maxReviewers)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text('+${pr.reviewers.length - _maxReviewers}', style: muted),
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
