import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../l10n/l10n.dart';
import '../models/work_item.dart';
import '../services/app_state.dart';
import '../services/devops_api.dart';
import '../services/home_widget_service.dart';
import '../services/logging.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_action.dart';
import '../widgets/work_item_visuals.dart';
import 'settings_screen.dart';
import 'work_item_detail_screen.dart';

final _log = Logger('WorkItemsScreen');

class WorkItemsScreen extends StatefulWidget {
  const WorkItemsScreen({super.key});

  @override
  State<WorkItemsScreen> createState() => WorkItemsScreenState();
}

class WorkItemsScreenState extends State<WorkItemsScreen> {
  static const _wideBreakpoint = 840.0;

  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  WorkItemScope _scope = WorkItemScope.assignedToMe;
  bool _openOnly = true;
  final Set<String> _types = {};

  List<WorkItem>? _items;
  Object? _error;
  bool _loading = false;
  int? _selectedId;
  String? _loadedFor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    final key = '${state.organization}|${state.projects.join('|')}';
    if (key != _loadedFor) {
      _loadedFor = key;
      _selectedId = null;
      _types.clear();
      _load();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// Puts the cursor in the search field, emptied, as the search shortcut
  /// does.
  void focusSearch() {
    setState(() {
      _search.clear();
      _selectedId = null;
    });
    _searchFocus.requestFocus();
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
      final items =
          await api.queryWorkItems(projects: projects, scope: _scope, openOnly: _openOnly);
      // The home screen widget shows exactly this view, so reuse the result.
      if (_scope == WorkItemScope.assignedToMe && _openOnly) {
        HomeWidgets.updateTickets(projects: projects, items: items);
      }
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e, st) {
      logFailure(_log, 'Loading work items failed', e, st);
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<WorkItem> get _filtered {
    final query = _search.text.trim().toLowerCase();
    return (_items ?? const <WorkItem>[]).where((w) {
      if (_types.isNotEmpty && !_types.contains(w.type)) return false;
      if (query.isEmpty) return true;
      return w.title.toLowerCase().contains(query) ||
          w.id.toString().contains(query) ||
          w.tags.any((t) => t.toLowerCase().contains(query)) ||
          w.project.toLowerCase().contains(query) ||
          (w.assignedTo?.displayName.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void _open(WorkItem item, bool wide) {
    if (wide) {
      setState(() => _selectedId = item.id);
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => WorkItemDetailScreen(id: item.id),
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
                    child: _selectedId == null
                        ? ColoredBox(
                            color: scheme.surface,
                            child: EmptyState(
                              icon: Icons.touch_app_outlined,
                              title: context.l10n.selectTicketTitle,
                              message: context.l10n.selectTicketMessage,
                            ),
                          )
                        : WorkItemDetailScreen(
                            key: ValueKey(_selectedId),
                            id: _selectedId!,
                            embedded: true,
                            onOpenWorkItem: (id) => setState(() => _selectedId = id),
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

  Widget _buildFilterChips(AppLocalizations l10n, List<String> availableTypes) {
    final chips = [
      FilterChip(
        label: Text(l10n.openOnly),
        selected: _openOnly,
        onSelected: (v) {
          setState(() => _openOnly = v);
          _load();
        },
      ),
      if (availableTypes.length > 1) ...[
        const SizedBox(height: 24, child: VerticalDivider(width: 8)),
        for (final type in availableTypes)
          FilterChip(
            avatar: Icon(WorkItemTypeStyle.of(type).icon,
                color: WorkItemTypeStyle.of(type).color),
            label: Text(type),
            selected: _types.contains(type),
            onSelected: (v) =>
                setState(() => v ? _types.add(type) : _types.remove(type)),
          ),
      ],
    ];
    const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    // A mouse can't swipe a horizontal scroll view, so wrap the chips on desktop.
    final desktop = switch (defaultTargetPlatform) {
      TargetPlatform.windows || TargetPlatform.macOS || TargetPlatform.linux => true,
      _ => false,
    };
    if (desktop) {
      return Padding(
        padding: padding,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: chips,
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        spacing: 8,
        children: chips,
      ),
    );
  }

  Widget _buildList(AppState state, bool wide) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final items = _filtered;
    final availableTypes = {for (final w in _items ?? const <WorkItem>[]) w.type}.toList()
      ..sort();

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
                  focusNode: _searchFocus,
                  hintText: l10n.searchTicketsHint,
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
                child: SegmentedButton<WorkItemScope>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                        value: WorkItemScope.assignedToMe,
                        icon: const Icon(Icons.person_outline),
                        label: Text(l10n.scopeAssignedToMe)),
                    ButtonSegment(
                        value: WorkItemScope.createdByMe,
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(l10n.scopeCreatedByMe)),
                    ButtonSegment(
                        value: WorkItemScope.all,
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
            SliverToBoxAdapter(child: _buildFilterChips(l10n, availableTypes)),
            if (_loading)
              const SliverToBoxAdapter(child: LinearProgressIndicator())
            else
              const SliverToBoxAdapter(child: SizedBox(height: 4)),
            if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: l10n.loadTicketsFailed,
                  message: l10n.error(_error!),
                  action: ErrorAction(error: _error!, onRetry: _load),
                ),
              )
            else if (_items != null && items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.inbox_outlined,
                  title: l10n.noTicketsTitle,
                  message: l10n.noTicketsMessage,
                ),
              )
            else ...[
              if (_items != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(l10n.ticketCount(items.length),
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _WorkItemCard(
                    item: items[i],
                    showProject: state.projects.length > 1,
                    selected: wide && items[i].id == _selectedId,
                    onTap: () => _open(items[i], wide),
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

class _WorkItemCard extends StatelessWidget {
  const _WorkItemCard({
    required this.item,
    required this.onTap,
    this.selected = false,
    this.showProject = false,
  });

  final WorkItem item;
  final VoidCallback onTap;
  final bool selected;

  /// Shows the project name, for when tickets of several projects are listed.
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
              TypeIcon(item.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('#${item.id}', style: muted),
                        if (item.priority != null) ...[
                          const SizedBox(width: 8),
                          Text('P${item.priority}', style: muted),
                        ],
                        if (showProject) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(item.project,
                                maxLines: 1, overflow: TextOverflow.ellipsis, style: muted),
                          ),
                        ],
                        const Spacer(),
                        Text(formatRelative(l10n, item.changedDate), style: muted),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StateBadge(item.state),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.tags.join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: muted,
                          ),
                        ),
                        Tooltip(
                          message: item.assignedTo?.displayName ?? l10n.unassigned,
                          child: PersonAvatar(item.assignedTo, radius: 12),
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
