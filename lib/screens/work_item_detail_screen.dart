import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../l10n/l10n.dart';
import '../models/work_item.dart';
import '../services/app_state.dart';
import '../services/links.dart';
import '../services/logging.dart';
import '../widgets/assignee_picker.dart';
import '../widgets/attachments.dart';
import '../widgets/comment_composer.dart';
import '../widgets/devops_html.dart';
import '../widgets/devops_markdown.dart';
import '../widgets/error_action.dart';
import '../widgets/section_card.dart';
import '../widgets/work_item_visuals.dart';

final _log = Logger('WorkItemDetailScreen');

class WorkItemDetailScreen extends StatefulWidget {
  const WorkItemDetailScreen({
    super.key,
    required this.id,
    this.embedded = false,
    this.onOpenWorkItem,
    this.onChanged,
  });

  final int id;

  /// Called after the work item was changed here, such as its assignee.
  final VoidCallback? onChanged;

  /// True when shown in the detail pane of the wide layout.
  final bool embedded;

  /// Opens a linked work item. Defaults to pushing a new route.
  final ValueChanged<int>? onOpenWorkItem;

  @override
  State<WorkItemDetailScreen> createState() => _WorkItemDetailScreenState();
}

class _WorkItemDetailScreenState extends State<WorkItemDetailScreen> {
  late Future<_Detail> _future;
  bool _assigning = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _load();
  }

  Future<_Detail> _load() async {
    try {
      return await _fetch();
    } catch (e, st) {
      logFailure(_log, 'Loading work item ${widget.id} failed', e, st);
      rethrow;
    }
  }

  Future<_Detail> _fetch() async {
    final api = AppScope.read(context).api!;
    final item = await api.getWorkItem(widget.id);
    final linkedIds = [?item.parentId, ...item.childIds];
    final results = await Future.wait([
      api.getComments(item.project, item.id).catchError((Object e, StackTrace st) {
        logFailure(_log, 'Loading comments of ${item.id} failed', e, st);
        return <WorkItemComment>[];
      }),
      api
          .getWorkItems(linkedIds, fields: const [
            'System.Id',
            'System.Title',
            'System.State',
            'System.WorkItemType',
          ])
          .catchError((Object e, StackTrace st) {
            logFailure(_log, 'Loading linked items of ${item.id} failed', e, st);
            return <WorkItem>[];
          }),
    ]);
    final linked = {for (final w in results[1] as List<WorkItem>) w.id: w};
    return _Detail(
      item: item,
      comments: results[0] as List<WorkItemComment>,
      parent: item.parentId == null ? null : linked[item.parentId],
      children: [for (final id in item.childIds) ?linked[id]],
    );
  }

  // A block body: setState must not get the Future back from the closure.
  void _reload() => setState(() {
        _future = _load();
      });

  Future<bool> _comment(WorkItem item, String text) async {
    try {
      await AppScope.read(context).api!.addWorkItemComment(item, text);
      if (mounted) _reload();
      return true;
    } catch (e, st) {
      logFailure(_log, 'Commenting on work item ${item.id} failed', e, st);
      if (mounted) showActionError(context, e, scopeHint: context.l10n.workItemScopeHint);
      return false;
    }
  }

  Future<void> _changeAssignee(WorkItem item) async {
    final choice = await showAssigneePicker(context, item);
    if (choice == null || !mounted) return;
    final l10n = context.l10n;
    setState(() => _assigning = true);
    try {
      await AppScope.read(context).api!.assignWorkItem(item, choice.assignee);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(switch (choice.assignee) {
          final assignee? => l10n.assignedToName(assignee.displayName),
          null => l10n.ticketUnassigned,
        }),
      ));
      widget.onChanged?.call();
      _reload();
    } catch (e, st) {
      logFailure(_log, 'Assigning work item ${item.id} failed', e, st);
      if (mounted) showActionError(context, e, scopeHint: l10n.assignScopeHint);
    } finally {
      if (mounted) setState(() => _assigning = false);
    }
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
    if (!await Links.openInBrowser(Uri.parse(url)) &&
        mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.browserOpenFailed)));
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
                  label: Text(context.l10n.openInDevOps),
                ),
          body: RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _future;
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                            Text(context.l10n.error(snapshot.error!),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ErrorAction(error: snapshot.error!, onRetry: _reload),
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

  bool _isBlankField(WorkItem item, String field) =>
      isBlankContent(item.fields[field] as String?, markdown: item.isMarkdown(field));

  List<Widget> _buildBody(_Detail detail) {
    final item = detail.item;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    // Bugs always show their tracking fields, like the DevOps bug form does.
    final sections = <(String, String)>[
      (l10n.description, WorkItem.descriptionField),
      if (!item.isBug) (l10n.reproSteps, WorkItem.reproStepsField),
      (l10n.acceptanceCriteria, WorkItem.acceptanceCriteriaField),
    ].where((s) => !_isBlankField(item, s.$2)).followedBy([
      if (item.isBug) ...[
        (l10n.reproSteps, WorkItem.reproStepsField),
        (l10n.symptom, WorkItem.symptomField),
        (l10n.systemInfo, WorkItem.systemInfoField),
        (l10n.proposedFix, WorkItem.proposedFixField),
      ],
    ]);

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
      SectionCard(
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _assigning ? null : () => _changeAssignee(item),
              child: InfoRow(
                icon: Icons.person_outline,
                label: l10n.assignedTo,
                valueWidget: Row(
                  children: [
                    PersonAvatar(item.assignedTo, radius: 12),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.assignedTo?.displayName ?? l10n.unassigned)),
                    if (_assigning)
                      const SizedBox.square(
                          dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      Icon(Icons.edit_outlined,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                          semanticLabel: l10n.changeAssignee),
                  ],
                ),
              ),
            ),
            if (item.priority != null)
              InfoRow(icon: Icons.flag_outlined, label: l10n.priority, value: '${item.priority}'),
            if (item.storyPoints != null)
              InfoRow(icon: Icons.speed, label: l10n.effort, value: '${item.storyPoints}'),
            if (item.originalEstimate != null)
              InfoRow(
                  icon: Icons.schedule,
                  label: l10n.originalEstimate,
                  value: l10n.hours('${item.originalEstimate}')),
            if (item.remainingWork != null)
              InfoRow(
                  icon: Icons.hourglass_bottom,
                  label: l10n.remainingWork,
                  value: l10n.hours('${item.remainingWork}')),
            if (item.completedWork != null)
              InfoRow(
                  icon: Icons.task_alt,
                  label: l10n.completedWork,
                  value: l10n.hours('${item.completedWork}')),
            InfoRow(icon: Icons.account_tree_outlined, label: l10n.area, value: item.areaPath),
            InfoRow(icon: Icons.event_repeat, label: l10n.iteration, value: item.iterationPath),
            InfoRow(
                icon: Icons.add_circle_outline,
                label: l10n.created,
                value: l10n.createdOnBy(formatDateTime(l10n, item.createdDate),
                    item.createdBy?.displayName ?? '-')),
            InfoRow(
                icon: Icons.update,
                label: l10n.changed,
                value: formatDateTime(l10n, item.changedDate)),
          ],
        ),
      ),
      for (final (title, field) in sections) ...[
        const SizedBox(height: 16),
        SectionCard(
          title: title,
          child: _isBlankField(item, field)
              ? Text(l10n.emptyField,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic))
              : item.isMarkdown(field)
                  ? DevOpsMarkdown(
                      item.fields[field] as String,
                      onOpenWorkItem: _openLinked,
                      imageHeaders: AppScope.read(context).api?.headersFor,
                    )
                  : DevOpsHtml(
                      item.fields[field] as String?,
                      imageHeaders: AppScope.read(context).api?.headersFor,
                    ),
        ),
      ],
      if (detail.parent != null || detail.children.isNotEmpty) ...[
        const SizedBox(height: 16),
        SectionCard(
          title: l10n.linkedItems,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              if (detail.parent != null)
                _LinkedTile(
                    item: detail.parent!,
                    relation: l10n.parent,
                    onTap: () => _openLinked(detail.parent!.id)),
              for (final child in detail.children)
                _LinkedTile(
                    item: child, relation: l10n.child, onTap: () => _openLinked(child.id)),
            ],
          ),
        ),
      ],
      if (item.attachments case final attachments when attachments.isNotEmpty) ...[
        const SizedBox(height: 16),
        SectionCard(
          title: l10n.attachmentsCount(attachments.length),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [for (final a in attachments) AttachmentTile(a)],
          ),
        ),
      ],
      const SizedBox(height: 16),
      SectionCard(
        title: l10n.commentsCount(detail.comments.length),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The newest comment comes first, so a new one is written on top.
            CommentComposer(hint: l10n.writeComment, onSend: (text) => _comment(item, text)),
            const SizedBox(height: 16),
            if (detail.comments.isEmpty)
              Text(l10n.noComments,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
            else
              for (final (i, c) in detail.comments.indexed) ...[
                if (i > 0) const Divider(height: 24),
                _CommentView(comment: c, onOpenWorkItem: _openLinked),
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
  const _CommentView({required this.comment, required this.onOpenWorkItem});

  final WorkItemComment comment;
  final ValueChanged<int> onOpenWorkItem;

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
                      text: comment.createdBy?.displayName ?? context.l10n.unknownPerson,
                      style: theme.textTheme.labelLarge),
                  TextSpan(
                      text: '  ${formatRelative(context.l10n, comment.createdDate)}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ]),
              ),
              const SizedBox(height: 4),
              if (comment.isMarkdown)
                DevOpsMarkdown(
                  comment.text,
                  mentions: comment.mentions,
                  onOpenWorkItem: onOpenWorkItem,
                  imageHeaders: AppScope.read(context).api?.headersFor,
                )
              else
                DevOpsHtml(
                  comment.text,
                  mentionStyle: TextStyle(
                      color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                  imageHeaders: AppScope.read(context).api?.headersFor,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
