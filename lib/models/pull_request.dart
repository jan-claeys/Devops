import 'work_item.dart';

/// A draft is an active pull request that isn't ready for review yet.
enum PullRequestStatus { draft, active, completed, abandoned }

/// The vote of a reviewer, from the numeric value Azure DevOps stores.
enum ReviewVote {
  approved,
  approvedWithSuggestions,
  none,
  waitingForAuthor,
  rejected;

  static ReviewVote fromValue(int? value) => switch (value) {
        10 => approved,
        5 => approvedWithSuggestions,
        -5 => waitingForAuthor,
        -10 => rejected,
        _ => none,
      };
}

class Reviewer {
  const Reviewer({
    required this.identity,
    this.vote = ReviewVote.none,
    this.isRequired = false,
    this.isGroup = false,
  });

  final Identity identity;
  final ReviewVote vote;
  final bool isRequired;

  /// A team or group instead of a person.
  final bool isGroup;

  factory Reviewer.fromJson(Map<String, dynamic> json) => Reviewer(
        identity: Identity.fromJson(json)!,
        vote: ReviewVote.fromValue((json['vote'] as num?)?.toInt()),
        isRequired: json['isRequired'] == true,
        isGroup: json['isContainer'] == true,
      );
}

class PullRequest {
  const PullRequest({
    required this.id,
    required this.title,
    required this.status,
    required this.project,
    required this.repositoryId,
    required this.repositoryName,
    this.description,
    this.sourceRefName,
    this.targetRefName,
    this.createdBy,
    this.creationDate,
    this.closedDate,
    this.reviewers = const [],
    this.labels = const [],
    this.hasConflicts = false,
  });

  final int id;
  final String title;
  final PullRequestStatus status;
  final String project;
  final String repositoryId;
  final String repositoryName;

  /// Markdown; lists return only the first part of it.
  final String? description;
  final String? sourceRefName;
  final String? targetRefName;
  final Identity? createdBy;
  final DateTime? creationDate;
  final DateTime? closedDate;
  final List<Reviewer> reviewers;
  final List<String> labels;
  final bool hasConflicts;

  factory PullRequest.fromJson(Map<String, dynamic> json) {
    final repository = (json['repository'] as Map?) ?? const {};
    final status = switch (json['status']) {
      'completed' => PullRequestStatus.completed,
      'abandoned' => PullRequestStatus.abandoned,
      _ when json['isDraft'] == true => PullRequestStatus.draft,
      _ => PullRequestStatus.active,
    };
    final open = status == PullRequestStatus.active || status == PullRequestStatus.draft;
    return PullRequest(
      id: json['pullRequestId'] as int,
      title: json['title'] as String? ?? '',
      status: status,
      project: (repository['project'] as Map?)?['name'] as String? ?? '',
      repositoryId: repository['id'] as String? ?? '',
      repositoryName: repository['name'] as String? ?? '',
      description: json['description'] as String?,
      sourceRefName: json['sourceRefName'] as String?,
      targetRefName: json['targetRefName'] as String?,
      createdBy: Identity.fromJson(json['createdBy']),
      creationDate: _date(json['creationDate']),
      // Open pull requests may carry a placeholder date.
      closedDate: open ? null : _date(json['closedDate']),
      reviewers: [
        for (final r in (json['reviewers'] as List?) ?? const [])
          Reviewer.fromJson(r as Map<String, dynamic>),
      ],
      labels: [
        for (final l in ((json['labels'] as List?) ?? const []).cast<Map<String, dynamic>>())
          if (l['active'] != false) ?l['name'] as String?,
      ],
      hasConflicts: json['mergeStatus'] == 'conflicts',
    );
  }

  bool get isOpen => status == PullRequestStatus.active || status == PullRequestStatus.draft;

  String? get sourceBranch => _branch(sourceRefName);
  String? get targetBranch => _branch(targetRefName);

  static String? _branch(String? ref) => ref?.replaceFirst(RegExp('^refs/heads/'), '');
}

/// A discussion on a pull request, on the whole of it or on a file.
class PullRequestThread {
  const PullRequestThread({required this.comments, this.status, this.filePath});

  /// Comments people wrote, oldest first; system messages are left out.
  final List<PullRequestComment> comments;
  final String? status;
  final String? filePath;

  /// Statuses like fixed, won't fix and closed; active and pending are open.
  bool get isResolved => switch (status) {
        'fixed' || 'wontFix' || 'closed' || 'byDesign' => true,
        _ => false,
      };

  DateTime? get lastUpdated => comments.map((c) => c.publishedDate).nonNulls.lastOrNull;

  /// Null for threads without comments from people, such as vote updates.
  static PullRequestThread? fromJson(Map<String, dynamic> json) {
    if (json['isDeleted'] == true) return null;
    final comments = [
      for (final c in ((json['comments'] as List?) ?? const []).cast<Map<String, dynamic>>())
        if (c['isDeleted'] != true && c['commentType'] != 'system')
          PullRequestComment.fromJson(c),
    ]..sort((a, b) => (a.publishedDate ?? DateTime(0)).compareTo(b.publishedDate ?? DateTime(0)));
    if (comments.isEmpty) return null;
    return PullRequestThread(
      comments: comments,
      status: json['status'] as String?,
      filePath: (json['threadContext'] as Map?)?['filePath'] as String?,
    );
  }
}

class PullRequestComment {
  const PullRequestComment({required this.content, this.author, this.publishedDate});

  /// Markdown.
  final String content;
  final Identity? author;
  final DateTime? publishedDate;

  factory PullRequestComment.fromJson(Map<String, dynamic> json) => PullRequestComment(
        content: json['content'] as String? ?? '',
        author: Identity.fromJson(json['author']),
        publishedDate: _date(json['publishedDate']),
      );
}

DateTime? _date(Object? value) => value is String ? DateTime.tryParse(value)?.toLocal() : null;
