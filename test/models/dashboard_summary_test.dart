import 'package:devops/models/dashboard_summary.dart';
import 'package:devops/models/pipeline_run.dart';
import 'package:devops/models/pull_request.dart';
import 'package:devops/models/work_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

final now = DateTime.utc(2026, 10, 22, 12);

PipelineRun build(
  int id, {
  int definition = 1,
  String pipeline = 'CI',
  String branch = 'refs/heads/feature/login',
  String status = 'completed',
  String? result = 'succeeded',
  bool mine = true,
  int hour = 10,
  int day = 22,
}) {
  final time = '2026-10-${'$day'.padLeft(2, '0')}T${'$hour'.padLeft(2, '0')}:00:00Z';
  final json = runJson(id,
      pipeline: pipeline,
      branch: branch,
      status: status,
      result: result,
      queueTime: time,
      finishTime: status == 'completed' ? time : null);
  (json['definition'] as Map)['id'] = definition;
  json['requestedFor'] = mine ? {'displayName': 'Me', 'id': meId} : {'displayName': 'Ann'};
  return PipelineRun.fromJson(json);
}

DashboardSummary summary({
  List<PipelineRun> runs = const [],
  List<PipelineRun> defaultBranchRuns = const [],
  List<Map<String, dynamic>> pullRequests = const [],
  List<WorkItem> tickets = const [],
}) =>
    DashboardSummary(
      runs: runs,
      defaultBranchRuns: defaultBranchRuns,
      pullRequests: [for (final pr in pullRequests) PullRequest.fromJson(pr)],
      tickets: tickets,
      me: meId,
      now: now,
    );

void main() {
  group('runs', () {
    test('lists only the runs the user started', () {
      final s = summary(runs: [build(2, mine: false), build(1)]);
      expect(s.myRuns.map((r) => r.id), [1]);
    });

    test('lists failed runs of the user until the pipeline succeeds on that branch', () {
      expect(summary(runs: [build(1, result: 'failed')]).myFailedRuns.map((r) => r.id), [1]);

      // Fixed since, by anyone.
      expect(
          summary(runs: [build(2, mine: false, hour: 11), build(1, result: 'failed')])
              .myFailedRuns,
          isEmpty);

      // A run still going, or one on another branch, doesn't fix it.
      expect(
          summary(runs: [
            build(3, status: 'inProgress', result: null, hour: 12),
            build(2, branch: 'refs/heads/other', hour: 11),
            build(1, result: 'failed'),
          ]).myFailedRuns.map((r) => r.id),
          [1]);

      // Failed again, by someone else: no longer the user's.
      expect(
          summary(runs: [build(2, mine: false, result: 'failed', hour: 11), build(1, result: 'failed')])
              .myFailedRuns,
          isEmpty);
    });

    test('forgets failed runs after a week', () {
      expect(summary(runs: [build(1, result: 'failed', day: 14)]).myFailedRuns, isEmpty);
    });

    test('finds the pipelines whose last result on the default branch failed', () {
      final s = summary(defaultBranchRuns: [
        build(4, pipeline: 'Nightly', definition: 2, branch: 'refs/heads/main', result: 'failed',
            mine: false),
        build(3, branch: 'refs/heads/main', hour: 11),
        build(2, branch: 'refs/heads/main', result: 'failed', hour: 9),
        // Canceled doesn't count as a result.
        build(5, pipeline: 'Docs', definition: 3, branch: 'refs/heads/develop', result: 'canceled',
            hour: 8),
        build(1, pipeline: 'Docs', definition: 3, branch: 'refs/heads/develop', result: 'failed',
            hour: 7),
      ]);
      expect(s.failingOnMain.map((r) => r.pipelineName), ['Nightly', 'Docs']);
    });

    test('forgets pipelines failing on the default branch after a month', () {
      final failed = [build(2, branch: 'refs/heads/main', result: 'failed')];
      expect(DashboardSummary(defaultBranchRuns: failed, now: now).failingOnMain, hasLength(1));
      expect(
          DashboardSummary(defaultBranchRuns: failed, now: now.add(const Duration(days: 31)))
              .failingOnMain,
          isEmpty);
    });

    test('finds the releases waiting for the approval of the user', () {
      Map<String, dynamic> release(int id, String approverId) {
        final env = environmentJson(1, 'Production', status: 'notStarted', pendingApprovers: ['X']);
        ((env['preDeployApprovals'] as List).single['approver'] as Map)['id'] = approverId;
        return releaseJson(id, environments: [env]);
      }

      final s = summary(runs: [
        PipelineRun.fromRelease(release(1, meId)),
        PipelineRun.fromRelease(release(2, 'someone-else')),
      ]);
      expect(s.myApprovals.map((r) => r.id), [1]);
    });
  });

  group('pull requests', () {
    test('lists the ones to review, waiting longest first', () {
      final s = summary(pullRequests: [
        pullRequestJson(1, creationDate: '2026-10-21T10:00:00Z', reviewers: [('Me', 0)]),
        pullRequestJson(2, creationDate: '2026-10-18T10:00:00Z', reviewers: [('Me', 0)]),
        pullRequestJson(3, reviewers: [('Me', 10)]),
        pullRequestJson(4, isDraft: true, reviewers: [('Me', 0)]),
      ]);
      expect(s.toReview.map((pr) => pr.id), [2, 1]);
    });

    test('finds the ones of the user that need changes or can be completed', () {
      final s = summary(pullRequests: [
        pullRequestJson(1, createdById: meId, reviewers: [('Ann', 10), ('Bob', -5)]),
        pullRequestJson(2, createdById: meId, mergeStatus: 'conflicts', reviewers: [('Ann', 10)]),
        pullRequestJson(3, createdById: meId, reviewers: [('Ann', 10), ('Bob', 0)]),
        pullRequestJson(4, createdById: meId, reviewers: [('Ann', 0)]),
        pullRequestJson(5, createdById: meId, isDraft: true, reviewers: [('Ann', 10)]),
        pullRequestJson(6, reviewers: [('Ann', 10)]),
      ]);
      expect(s.needChanges.map((pr) => pr.id), [1, 2]);
      expect(DashboardSummary.blockingReviewer(s.needChanges.first)?.vote,
          ReviewVote.waitingForAuthor);
      expect(s.readyToComplete.map((pr) => pr.id), [3]);
      expect(s.waitingCount, 3);
    });

    test('waits for the required reviewers before completing', () {
      final json = pullRequestJson(1, createdById: meId, reviewers: [('Ann', 10), ('Bob', 0)]);
      ((json['reviewers'] as List)[1] as Map)['isRequired'] = true;
      expect(summary(pullRequests: [json]).readyToComplete, isEmpty);
    });
  });

  test('marks tickets without changes for two weeks as stale', () {
    final s = summary();
    WorkItem ticket(String changed) =>
        WorkItem.fromJson(workItemJson(1, fields: {'System.ChangedDate': changed}));

    expect(s.staleFor(ticket('2026-10-01T12:00:00Z'))?.inDays, 21);
    expect(s.staleFor(ticket('2026-10-20T12:00:00Z')), isNull);
  });
}
