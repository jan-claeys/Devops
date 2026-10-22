import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../l10n/l10n.dart';
import '../models/pull_request.dart';
import '../models/work_item.dart';
import '../services/app_state.dart';
import '../services/links.dart';
import '../services/logging.dart';
import '../widgets/devops_markdown.dart';
import '../widgets/error_action.dart';
import '../widgets/pull_request_visuals.dart';
import '../widgets/section_card.dart';
import '../widgets/work_item_visuals.dart';
import 'work_item_detail_screen.dart';

final _log = Logger('PullRequestScreen');

/// A pull request with its reviewers, linked work items and discussions.
class PullRequestScreen extends StatefulWidget {
  const PullRequestScreen({
    super.key,
    required this.project,
    required this.id,
    this.embedded = false,
  });

  final String project;
  final int id;

  /// True when shown in the detail pane of the wide layout.
  final bool embedded;

  @override
  State<PullRequestScreen> createState() => _PullRequestScreenState();
}

class _PullRequestScreenState extends State<PullRequestScreen> {
  late Future<_Detail> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _load();
  }

  Future<_Detail> _load() async {
    try {
      return await _fetch();
    } catch (e, st) {
      logFailure(_log, 'Loading pull request ${widget.id} failed', e, st);
      rethrow;
    }
  }

  Future<_Detail> _fetch() async {
    final api = AppScope.read(context).api!;
    final pr = await api.getPullRequest(widget.project, widget.id);
    final results = await Future.wait([
      api.getPullRequestThreads(pr).catchError((Object e, StackTrace st) {
        logFailure(_log, 'Loading the threads of pull request ${pr.id} failed', e, st);
        return <PullRequestThread>[];
      }),
      api
          .getPullRequestWorkItemIds(pr)
          .then((ids) => api.getWorkItems(ids, fields: const [
                'System.Id',
                'System.Title',
                'System.State',
                'System.WorkItemType',
              ]))
          .catchError((Object e, StackTrace st) {
            logFailure(_log, 'Loading the work items of pull request ${pr.id} failed', e, st);
            return <WorkItem>[];
          }),
    ]);
    return _Detail(
      pullRequest: pr,
      threads: results[0] as List<PullRequestThread>,
      workItems: results[1] as List<WorkItem>,
    );
  }

  // A block body: setState must not get the Future back from the closure.
  void _reload() => setState(() {
        _future = _load();
      });

  void _openWorkItem(int id) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => WorkItemDetailScreen(id: id)));

  Future<void> _openInBrowser(PullRequest pr) async {
    final url = AppScope.read(context).api!.pullRequestWebUrl(pr);
    if (!await Links.openInBrowser(Uri.parse(url)) && mounted) {
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
                  onPressed: () => _openInBrowser(detail.pullRequest),
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
                      ? '!${widget.id}'
                      : '${detail.pullRequest.repositoryName} !${widget.id}'),
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

  List<Widget> _buildBody(_Detail detail) {
    final pr = detail.pullRequest;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final api = AppScope.read(context).api;
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final description = pr.description?.trim() ?? '';

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PullRequestStatusStyle.of(pr.status, theme.colorScheme).icon,
              size: 48, color: PullRequestStatusStyle.of(pr.status, theme.colorScheme).color),
          const SizedBox(width: 16),
          Expanded(child: SelectableText(pr.title, style: theme.textTheme.headlineSmall)),
        ],
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          PullRequestStatusBadge(pr.status),
          if (pr.hasConflicts)
            Chip(
              avatar: Icon(Icons.warning_amber, color: theme.colorScheme.error),
              label: Text(l10n.mergeConflicts),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          for (final label in pr.labels)
            Chip(
              label: Text(label),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
        ],
      ),
      const SizedBox(height: 16),
      SectionCard(
        child: Column(
          children: [
            InfoRow(icon: Icons.source_outlined, label: l10n.repository, value: pr.repositoryName),
            InfoRow(
              icon: Icons.call_split,
              label: l10n.branch,
              value: '${pr.sourceBranch ?? '-'} → ${pr.targetBranch ?? '-'}',
            ),
            InfoRow(
              icon: Icons.add_circle_outline,
              label: l10n.created,
              value: l10n.createdOnBy(formatDateTime(l10n, pr.creationDate),
                  pr.createdBy?.displayName ?? '-'),
            ),
            if (pr.closedDate != null)
              InfoRow(
                icon: Icons.flag_outlined,
                label: l10n.closed,
                value: formatDateTime(l10n, pr.closedDate),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SectionCard(
        title: l10n.description,
        child: description.isEmpty
            ? Text(l10n.emptyField, style: muted?.copyWith(fontStyle: FontStyle.italic))
            : DevOpsMarkdown(
                description,
                mentions: detail.mentions,
                onOpenWorkItem: _openWorkItem,
                imageHeaders: api?.headersFor,
              ),
      ),
      const SizedBox(height: 16),
      SectionCard(
        title: l10n.reviewers,
        padding: pr.reviewers.isEmpty ? null : const EdgeInsets.symmetric(vertical: 4),
        child: pr.reviewers.isEmpty
            ? Text(l10n.noReviewers, style: muted)
            : Column(
                children: [
                  for (final reviewer in pr.reviewers) _ReviewerTile(reviewer),
                ],
              ),
      ),
      if (detail.workItems.isNotEmpty) ...[
        const SizedBox(height: 16),
        SectionCard(
          title: l10n.linkedItems,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              for (final item in detail.workItems)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: TypeIcon(item.type, size: 32),
                  title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('#${item.id} · ${item.state}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openWorkItem(item.id),
                ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 16),
      SectionCard(
        title: l10n.commentsCount(detail.threads.length),
        child: detail.threads.isEmpty
            ? Text(l10n.noComments, style: muted)
            : Column(
                children: [
                  for (final (i, thread) in detail.threads.indexed) ...[
                    if (i > 0) const Divider(height: 24),
                    _ThreadView(
                      thread: thread,
                      mentions: detail.mentions,
                      onOpenWorkItem: _openWorkItem,
                    ),
                  ],
                ],
              ),
      ),
    ];
  }
}

class _Detail {
  _Detail({required this.pullRequest, required this.threads, required this.workItems});

  final PullRequest pullRequest;
  final List<PullRequestThread> threads;
  final List<WorkItem> workItems;

  /// Comments only hold the guid of a mentioned person; the people taking
  /// part in the pull request are the ones mentioned most.
  late final Map<String, String> mentions = {
    for (final identity in [
      pullRequest.createdBy,
      for (final r in pullRequest.reviewers) r.identity,
      for (final t in threads)
        for (final c in t.comments) c.author,
    ])
      if (identity?.id case final id?) id.toLowerCase(): identity!.displayName,
  };
}

class _ReviewerTile extends StatelessWidget {
  const _ReviewerTile(this.reviewer);

  final Reviewer reviewer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = ReviewVoteStyle.of(reviewer.vote, Theme.of(context).colorScheme);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: reviewer.isGroup
          ? const CircleAvatar(radius: 16, child: Icon(Icons.groups_outlined, size: 18))
          : PersonAvatar(reviewer.identity, radius: 16),
      title: Text(reviewer.identity.displayName),
      subtitle: Text([
        reviewVoteLabel(l10n, reviewer.vote),
        if (reviewer.isRequired) l10n.requiredReviewer,
      ].join(' · ')),
      trailing: Icon(style.icon, color: style.color),
    );
  }
}

class _ThreadView extends StatelessWidget {
  const _ThreadView({
    required this.thread,
    required this.mentions,
    required this.onOpenWorkItem,
  });

  final PullRequestThread thread;
  final Map<String, String> mentions;
  final ValueChanged<int> onOpenWorkItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final muted = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (thread.filePath != null || thread.isResolved)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                if (thread.filePath != null) ...[
                  Icon(Icons.description_outlined, size: 14, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(thread.filePath!,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: muted),
                  ),
                ] else
                  const Spacer(),
                if (thread.isResolved) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check, size: 14, color: const Color(0xFF339933)),
                  const SizedBox(width: 2),
                  Text(l10n.threadResolved, style: muted),
                ],
              ],
            ),
          ),
        for (final (i, comment) in thread.comments.indexed)
          Padding(
            // Replies are indented below the comment that started the thread.
            padding: EdgeInsets.only(left: i == 0 ? 0 : 44, top: i == 0 ? 0 : 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PersonAvatar(comment.author, radius: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text: comment.author?.displayName ?? l10n.unknownPerson,
                              style: theme.textTheme.labelLarge),
                          TextSpan(
                              text: '  ${formatRelative(l10n, comment.publishedDate)}',
                              style: muted),
                        ]),
                      ),
                      const SizedBox(height: 4),
                      DevOpsMarkdown(
                        comment.content,
                        mentions: mentions,
                        onOpenWorkItem: onOpenWorkItem,
                        imageHeaders: AppScope.read(context).api?.headersFor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
