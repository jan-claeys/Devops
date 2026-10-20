import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/work_item.dart';
import '../services/app_state.dart';
import '../widgets/work_item_visuals.dart';

class WorkItemDetailScreen extends StatefulWidget {
  const WorkItemDetailScreen({
    super.key,
    required this.id,
    this.embedded = false,
    this.onOpenWorkItem,
  });

  final int id;

  /// True when shown in the detail pane of the wide layout.
  final bool embedded;

  /// Opens a linked work item. Defaults to pushing a new route.
  final ValueChanged<int>? onOpenWorkItem;

  @override
  State<WorkItemDetailScreen> createState() => _WorkItemDetailScreenState();
}

class _WorkItemDetailScreenState extends State<WorkItemDetailScreen> {
  late Future<_Detail> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _load();
  }

  Future<_Detail> _load() async {
    final api = AppScope.read(context).api!;
    final item = await api.getWorkItem(widget.id);
    final linkedIds = [?item.parentId, ...item.childIds];
    final results = await Future.wait([
      api.getComments(item.project, item.id).catchError((_) => <WorkItemComment>[]),
      api
          .getWorkItems(linkedIds, fields: const [
            'System.Id',
            'System.Title',
            'System.State',
            'System.WorkItemType',
          ])
          .catchError((_) => <WorkItem>[]),
    ]);
    final linked = {for (final w in results[1] as List<WorkItem>) w.id: w};
    return _Detail(
      item: item,
      comments: results[0] as List<WorkItemComment>,
      parent: item.parentId == null ? null : linked[item.parentId],
      children: [for (final id in item.childIds) ?linked[id]],
    );
  }

  void _openLinked(int id) {
    if (widget.onOpenWorkItem != null) {
      widget.onOpenWorkItem!(id);
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => WorkItemDetailScreen(id: id)));
    }
  }

  Future<void> _openInBrowser(WorkItem item) async {
    final url = AppScope.read(context).api!.webUrl(item);
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Kon de browser niet openen')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Detail>(
      future: _future,
      builder: (context, snapshot) {
        final detail = snapshot.data;
        return Scaffold(
          floatingActionButton: detail == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _openInBrowser(detail.item),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open in DevOps'),
                ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() => _future = _load());
              await _future;
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar.medium(
                  automaticallyImplyLeading: !widget.embedded,
                  title: Text(detail == null
                      ? '#${widget.id}'
                      : '${detail.item.type} ${detail.item.id}'),
                ),
                if (snapshot.hasError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: Theme.of(context).colorScheme.error),
                            const SizedBox(height: 12),
                            Text(snapshot.error.toString(), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            FilledButton.tonal(
                              onPressed: () => setState(() => _future = _load()),
                              child: const Text('Opnieuw proberen'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (detail == null)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    sliver: SliverList.list(children: _buildBody(detail)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildBody(_Detail detail) {
    final item = detail.item;
    final theme = Theme.of(context);
    final sections = <(String, String?)>[
      ('Beschrijving', item.description),
      ('Stappen om te reproduceren', item.reproSteps),
      ('Acceptatiecriteria', item.acceptanceCriteria),
    ].where((s) => htmlToText(s.$2).isNotEmpty);

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TypeIcon(item.type, size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: SelectableText(item.title, style: theme.textTheme.headlineSmall),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          StateBadge(item.state),
          if (item.reason != null)
            Text(item.reason!,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          for (final tag in item.tags)
            Chip(
              label: Text(tag),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
        ],
      ),
      const SizedBox(height: 16),
      _SectionCard(
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Toegewezen aan',
              valueWidget: Row(
                children: [
                  PersonAvatar(item.assignedTo, radius: 12),
                  const SizedBox(width: 8),
                  Flexible(child: Text(item.assignedTo?.displayName ?? 'Niet toegewezen')),
                ],
              ),
            ),
            if (item.priority != null)
              _InfoRow(icon: Icons.flag_outlined, label: 'Prioriteit', value: '${item.priority}'),
            if (item.storyPoints != null)
              _InfoRow(icon: Icons.speed, label: 'Inspanning', value: '${item.storyPoints}'),
            if (item.remainingWork != null)
              _InfoRow(
                  icon: Icons.hourglass_bottom,
                  label: 'Resterend werk',
                  value: '${item.remainingWork} u'),
            _InfoRow(icon: Icons.account_tree_outlined, label: 'Area', value: item.areaPath),
            _InfoRow(icon: Icons.event_repeat, label: 'Iteratie', value: item.iterationPath),
            _InfoRow(
                icon: Icons.add_circle_outline,
                label: 'Aangemaakt',
                value:
                    '${formatDateTime(item.createdDate)} door ${item.createdBy?.displayName ?? '-'}'),
            _InfoRow(
                icon: Icons.update, label: 'Gewijzigd', value: formatDateTime(item.changedDate)),
          ],
        ),
      ),
      for (final (title, html) in sections) ...[
        const SizedBox(height: 16),
        _SectionCard(
          title: title,
          child: SelectableText(htmlToText(html), style: theme.textTheme.bodyMedium),
        ),
      ],
      if (detail.parent != null || detail.children.isNotEmpty) ...[
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Gekoppelde items',
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              if (detail.parent != null)
                _LinkedTile(
                    item: detail.parent!,
                    relation: 'Bovenliggend',
                    onTap: () => _openLinked(detail.parent!.id)),
              for (final child in detail.children)
                _LinkedTile(
                    item: child, relation: 'Onderliggend', onTap: () => _openLinked(child.id)),
            ],
          ),
        ),
      ],
      const SizedBox(height: 16),
      _SectionCard(
        title: 'Opmerkingen (${detail.comments.length})',
        child: detail.comments.isEmpty
            ? Text('Nog geen opmerkingen.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
            : Column(
                children: [
                  for (final (i, c) in detail.comments.indexed) ...[
                    if (i > 0) const Divider(height: 24),
                    _CommentView(comment: c),
                  ],
                ],
              ),
      ),
    ];
  }
}

class _Detail {
  const _Detail({
    required this.item,
    required this.comments,
    required this.parent,
    required this.children,
  });

  final WorkItem item;
  final List<WorkItemComment> comments;
  final WorkItem? parent;
  final List<WorkItem> children;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.title, this.padding});

  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
            ],
            Padding(padding: padding ?? EdgeInsets.zero, child: child),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, this.value, this.valueWidget});

  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(child: valueWidget ?? Text(value ?? '-', style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _LinkedTile extends StatelessWidget {
  const _LinkedTile({required this.item, required this.relation, required this.onTap});

  final WorkItem item;
  final String relation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: TypeIcon(item.type, size: 32),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('$relation · #${item.id} · ${item.state}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _CommentView extends StatelessWidget {
  const _CommentView({required this.comment});

  final WorkItemComment comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PersonAvatar(comment.createdBy, radius: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: comment.createdBy?.displayName ?? 'Onbekend',
                      style: theme.textTheme.labelLarge),
                  TextSpan(
                      text: '  ${formatRelative(comment.createdDate)}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ]),
              ),
              const SizedBox(height: 4),
              SelectableText.rich(htmlToSpan(
                comment.text,
                style: theme.textTheme.bodyMedium,
                mentionStyle: TextStyle(
                    color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
              )),
            ],
          ),
        ),
      ],
    );
  }
}
