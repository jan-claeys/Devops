import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/work_item.dart';
import '../services/app_state.dart';
import '../services/devops_api.dart';
import '../services/home_widget_service.dart';
import '../widgets/work_item_visuals.dart';
import 'settings_screen.dart';
import 'work_item_detail_screen.dart';

class WorkItemsScreen extends StatefulWidget {
  const WorkItemsScreen({super.key});

  @override
  State<WorkItemsScreen> createState() => _WorkItemsScreenState();
}

class _WorkItemsScreenState extends State<WorkItemsScreen> {
  static const _wideBreakpoint = 840.0;

  final _search = TextEditingController();
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
    final key = '${state.organization}|${state.project}';
    if (key != _loadedFor) {
      _loadedFor = key;
      _selectedId = null;
      _types.clear();
      if (state.project == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _pickProject());
      } else {
        _load();
      }
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final state = AppScope.read(context);
    final api = state.api;
    final project = state.project;
    if (api == null || project == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items =
          await api.queryWorkItems(project: project, scope: _scope, openOnly: _openOnly);
      // The home screen widget shows exactly this view, so reuse the result.
      if (_scope == WorkItemScope.assignedToMe && _openOnly) {
        TicketsHomeWidget.update(project: project, items: items);
      }
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickProject() async {
    final state = AppScope.read(context);
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _ProjectPicker(api: state.api!, current: state.project),
    );
    if (picked != null && picked != state.project) {
      _items = null;
      await state.selectProject(picked);
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
                            child: _EmptyState(
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
            SliverAppBar.medium(
              title: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _pickProject,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(state.project ?? l10n.chooseProject,
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
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
                    if (availableTypes.length > 1) ...[
                      const SizedBox(width: 8),
                      const SizedBox(height: 24, child: VerticalDivider()),
                      for (final type in availableTypes)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: FilterChip(
                            avatar: Icon(WorkItemTypeStyle.of(type).icon,
                                color: WorkItemTypeStyle.of(type).color),
                            label: Text(type),
                            selected: _types.contains(type),
                            onSelected: (v) => setState(
                                () => v ? _types.add(type) : _types.remove(type)),
                          ),
                        ),
                    ],
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
                child: _EmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: l10n.loadTicketsFailed,
                  message: l10n.error(_error!),
                  action: FilledButton.tonalIcon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ),
              )
            else if (state.project == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  icon: Icons.folder_open_outlined,
                  title: l10n.noProjectTitle,
                  message: l10n.noProjectMessage,
                  action: FilledButton.icon(
                    onPressed: _pickProject,
                    icon: const Icon(Icons.folder_outlined),
                    label: Text(l10n.chooseProject),
                  ),
                ),
              )
            else if (_items != null && items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
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
  const _WorkItemCard({required this.item, required this.onTap, this.selected = false});

  final WorkItem item;
  final VoidCallback onTap;
  final bool selected;

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

class _ProjectPicker extends StatefulWidget {
  const _ProjectPicker({required this.api, this.current});

  final DevOpsApi api;
  final String? current;

  @override
  State<_ProjectPicker> createState() => _ProjectPickerState();
}

class _ProjectPickerState extends State<_ProjectPicker> {
  late final Future<List<Project>> _projects = widget.api.getProjects();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Row(
              children: [
                Text(context.l10n.chooseAProject, style: theme.textTheme.titleLarge),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchBar(
              hintText: context.l10n.searchProjectHint,
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Project>>(
              future: _projects,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _EmptyState(
                    icon: Icons.error_outline,
                    title: context.l10n.loadProjectsFailed,
                    message: context.l10n.error(snapshot.error!),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final projects = snapshot.data!
                    .where((p) => p.name.toLowerCase().contains(_query))
                    .toList();
                return ListView.builder(
                  controller: controller,
                  itemCount: projects.length,
                  itemBuilder: (context, i) {
                    final p = projects[i];
                    final selected = p.name == widget.current;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        child: Text(p.name[0].toUpperCase()),
                      ),
                      title: Text(p.name),
                      subtitle: p.description == null || p.description!.isEmpty
                          ? null
                          : Text(p.description!,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: selected ? const Icon(Icons.check) : null,
                      selected: selected,
                      onTap: () => Navigator.of(context).pop(p.name),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
