import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/l10n.dart';
import '../models/work_item.dart';
import '../services/app_state.dart';
import '../services/devops_api.dart';
import '../services/home_widget_service.dart';
import '../services/logging.dart';
import '../widgets/assignee_picker.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_action.dart';
import '../widgets/work_item_visuals.dart';
import 'settings_screen.dart';
import 'work_item_detail_screen.dart';

final _log = Logger('WorkItemsScreen');

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

  /// The signed in user; tickets already assigned to them can't be swiped
  /// to assign them.
  Identity? _me;

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
    super.dispose();
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
    // The user is only needed for swipe actions, so a failure is no error.
    api.getCurrentUser().then((me) {
      if (mounted) setState(() => _me = me);
    }, onError: (Object e, StackTrace st) {
      logFailure(_log, 'Loading the current user failed', e, st);
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
        builder: (_) => WorkItemDetailScreen(id: item.id, onChanged: _load),
      ));
    }
  }

  void _replace(WorkItem updated) => setState(() => _items = [
        for (final w in _items ?? const <WorkItem>[]) w.id == updated.id ? updated : w,
      ]);

  /// Assigns [item] to [assignee], or to no one; with undo, which assigns it
  /// back to whom it had.
  Future<void> _assign(WorkItem item, Identity? assignee, {bool undoable = true}) async {
    final api = AppScope.read(context).api!;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = await api.assignWorkItem(item, assignee);
      if (!mounted) return;
      _replace(updated);
      messenger.showSnackBar(SnackBar(
        content: Text(switch (assignee) {
          final a? => l10n.assignedToName(a.displayName),
          null => l10n.ticketUnassigned,
        }),
        action: undoable
            ? SnackBarAction(
                label: l10n.undo,
                onPressed: () => _assign(updated, item.assignedTo, undoable: false))
            : null,
      ));
    } catch (e, st) {
      logFailure(_log, 'Assigning work item ${item.id} failed', e, st);
      if (mounted) showActionError(context, e, scopeHint: l10n.assignScopeHint);
    }
  }

  Future<void> _assignToMe(WorkItem item) async {
    try {
      final me = _me ?? await AppScope.read(context).api!.getCurrentUser();
      if (mounted) await _assign(item, me);
    } catch (e, st) {
      logFailure(_log, 'Loading the current user failed', e, st);
      if (mounted) showActionError(context, e, scopeHint: context.l10n.assignScopeHint);
    }
  }

  /// Offers to copy the link to [item] or to share it, such as to Teams or
  /// Slack; [origin] is where the share sheet points to on an iPad.
  Future<void> _shareLink(WorkItem item, Rect origin) async {
    final l10n = context.l10n;
    final url = AppScope.read(context).api!.webUrl(item);
    final share = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(l10n.copyLink),
              subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () => Navigator.of(context).pop(false),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: Text(l10n.shareTicket),
              onTap: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
    if (share == null || !mounted) return;
    if (!share) {
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.linkCopied)));
      }
      return;
    }
    final title = '${item.type} ${item.id}: ${item.title}';
    await SharePlus.instance.share(ShareParams(
      text: '$title\n$url',
      subject: title,
      sharePositionOrigin: origin,
    ));
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
                            onChanged: _load,
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
                  itemBuilder: (context, i) => _Swipeable(
                    key: ValueKey(items[i].id),
                    // Already the user's: only sharing is left.
                    canAssignToMe: !isSamePerson(items[i].assignedTo, _me),
                    onAssignToMe: () => _assignToMe(items[i]),
                    onShare: (origin) => _shareLink(items[i], origin),
                    child: _WorkItemCard(
                      item: items[i],
                      showProject: state.projects.length > 1,
                      selected: wide && items[i].id == _selectedId,
                      onTap: () => _open(items[i], wide),
                    ),
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

/// A ticket that is swiped right to assign it to the user, or left to copy
/// or share its link; it springs back either way.
class _Swipeable extends StatelessWidget {
  const _Swipeable({
    super.key,
    required this.canAssignToMe,
    required this.onAssignToMe,
    required this.onShare,
    required this.child,
  });

  final bool canAssignToMe;
  final VoidCallback onAssignToMe;
  final ValueChanged<Rect> onShare;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Dismissible(
      key: key!,
      direction:
          canAssignToMe ? DismissDirection.horizontal : DismissDirection.endToStart,
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.3,
        DismissDirection.endToStart: 0.3,
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onAssignToMe();
        } else {
          final box = context.findRenderObject() as RenderBox?;
          onShare(box == null ? Rect.zero : box.localToGlobal(Offset.zero) & box.size);
        }
        return false;
      },
      background: _SwipeBackground(
        icon: Icons.person_add_alt_1,
        label: l10n.assignToMe,
        color: scheme.primaryContainer,
        onColor: scheme.onPrimaryContainer,
        alignment: AlignmentDirectional.centerStart,
      ),
      secondaryBackground: _SwipeBackground(
        icon: Icons.share_outlined,
        label: l10n.shareTicket,
        color: scheme.tertiaryContainer,
        onColor: scheme.onTertiaryContainer,
        alignment: AlignmentDirectional.centerEnd,
      ),
      child: child,
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.icon,
    required this.label,
    required this.color,
    required this.onColor,
    required this.alignment,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color onColor;
  final AlignmentDirectional alignment;

  @override
  Widget build(BuildContext context) {
    // Fills the card only, not the margin around it.
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: onColor),
          const SizedBox(width: 8),
          Text(label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: onColor)),
        ],
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
