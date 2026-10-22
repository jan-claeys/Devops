import 'pipeline_run.dart';
import 'pull_request.dart';
import 'work_item.dart';

/// What waits for the user: from the latest pipeline runs, the pull requests
/// they created or review and their open tickets.
class DashboardSummary {
  DashboardSummary({
    this.runs = const [],
    this.pullRequests = const [],
    this.tickets = const [],
    this.me,
    DateTime? now,
  }) : now = now ?? DateTime.now();

  /// Builds and releases, newest first.
  final List<PipelineRun> runs;
  final List<PullRequest> pullRequests;
  final List<WorkItem> tickets;

  /// Id of the signed in user.
  final String? me;
  final DateTime now;

  /// How long a failed run of the user stays on the list.
  static const failedRunAge = Duration(days: 7);

  /// After how long without changes a ticket counts as stale.
  static const staleAfter = Duration(days: 14);

  static const mainBranches = {'main', 'master'};

  static const _results = {
    RunStatus.succeeded,
    RunStatus.partiallySucceeded,
    RunStatus.failed,
  };

  bool _isMine(Identity? identity) => me != null && identity?.id == me;

  /// The pipeline of a run, and the branch it ran on.
  static Object _pipelineBranch(PipelineRun r) =>
      (r.kind, r.project, r.definitionId ?? r.pipelineName, r.branch);

  /// The runs the user started, newest first.
  late final List<PipelineRun> myRuns = [
    for (final r in runs)
      if (_isMine(r.requestedFor)) r,
  ];

  /// Recent runs of the user that failed, and whose pipeline hasn't
  /// succeeded on that branch since.
  late final List<PipelineRun> myFailedRuns = () {
    final seen = <Object>{};
    return [
      for (final r in runs)
        // Only the last result of a pipeline on a branch counts.
        if (_results.contains(r.status) && seen.add(_pipelineBranch(r)))
          if (r.status == RunStatus.failed &&
              _isMine(r.requestedFor) &&
              now.difference(r.finishTime ?? r.queueTime ?? now) < failedRunAge)
            r,
    ];
  }();

  /// Releases waiting for the approval of the user.
  late final List<PipelineRun> myApprovals = [
    for (final r in runs)
      if (r.status == RunStatus.waitingForApproval && r.pendingApproverIds.contains(me)) r,
  ];

  /// Builds whose last result on the main branch failed.
  late final List<PipelineRun> failingOnMain = () {
    final seen = <Object>{};
    return [
      for (final r in runs)
        if (!r.isRelease && mainBranches.contains(r.branch) && _results.contains(r.status))
          if (seen.add(_pipelineBranch(r)) && r.status == RunStatus.failed) r,
    ];
  }();

  late final List<PullRequest> openPullRequests =
      pullRequests.where((pr) => pr.isOpen).toList();

  /// Pull requests, not drafts, the user has yet to vote on; the ones
  /// waiting longest first.
  late final List<PullRequest> toReview = [
    for (final pr in openPullRequests)
      if (pr.status == PullRequestStatus.active &&
          pr.reviewers.any((r) => _isMine(r.identity) && r.vote == ReviewVote.none))
        pr,
  ]..sort((a, b) => (a.creationDate ?? now).compareTo(b.creationDate ?? now));

  late final List<PullRequest> myPullRequests = [
    for (final pr in openPullRequests)
      if (_isMine(pr.createdBy)) pr,
  ];

  /// The most serious vote on [pr]: rejected, or waiting for the author.
  static Reviewer? blockingReviewer(PullRequest pr) =>
      pr.reviewers.where((r) => r.vote == ReviewVote.rejected).firstOrNull ??
      pr.reviewers.where((r) => r.vote == ReviewVote.waitingForAuthor).firstOrNull;

  /// Pull requests of the user a reviewer asked changes on, or that have
  /// merge conflicts.
  late final List<PullRequest> needChanges = [
    for (final pr in myPullRequests)
      if (pr.hasConflicts || blockingReviewer(pr) != null) pr,
  ];

  /// Pull requests of the user that every required reviewer approved and
  /// nobody blocks, so they can be completed.
  late final List<PullRequest> readyToComplete = [
    for (final pr in myPullRequests)
      if (pr.status == PullRequestStatus.active &&
          !pr.hasConflicts &&
          blockingReviewer(pr) == null &&
          pr.reviewers.any((r) => _approved(r.vote)) &&
          pr.reviewers.where((r) => r.isRequired).every((r) => _approved(r.vote)))
        pr,
  ];

  static bool _approved(ReviewVote vote) =>
      vote == ReviewVote.approved || vote == ReviewVote.approvedWithSuggestions;

  /// Everything that waits for the user to act.
  int get waitingCount =>
      toReview.length +
      needChanges.length +
      readyToComplete.length +
      myFailedRuns.length +
      myApprovals.length;

  /// How long [ticket] hasn't changed, when that makes it stale.
  Duration? staleFor(WorkItem ticket) {
    final changed = ticket.changedDate;
    if (changed == null) return null;
    final idle = now.difference(changed);
    return idle >= staleAfter ? idle : null;
  }
}
