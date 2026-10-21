import 'package:devops/models/pull_request.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  test('parses a pull request', () {
    final pr = PullRequest.fromJson({
      ...pullRequestJson(3, reviewers: [('Ann', 10), ('Bob', 5), ('Cas', -10)]),
      'closedDate': '0001-01-01T00:00:00',
      'labels': [
        {'name': 'urgent', 'active': true},
        {'name': 'old', 'active': false},
      ],
    });

    expect(pr.id, 3);
    expect(pr.status, PullRequestStatus.active);
    expect(pr.isOpen, isTrue);
    expect(pr.project, 'Contoso');
    expect(pr.repositoryName, 'web');
    expect(pr.sourceBranch, 'feature/login');
    expect(pr.targetBranch, 'main');
    expect(pr.closedDate, isNull);
    expect(pr.labels, ['urgent']);
    expect(pr.reviewers.map((r) => r.vote), [
      ReviewVote.approved,
      ReviewVote.approvedWithSuggestions,
      ReviewVote.rejected,
    ]);
  });

  test('maps the status', () {
    PullRequestStatus status(String s, {bool draft = false}) =>
        PullRequest.fromJson(pullRequestJson(1, status: s, isDraft: draft)).status;

    expect(status('active', draft: true), PullRequestStatus.draft);
    expect(status('completed'), PullRequestStatus.completed);
    expect(status('abandoned'), PullRequestStatus.abandoned);
    expect(
        PullRequest.fromJson(pullRequestJson(1, mergeStatus: 'conflicts')).hasConflicts, isTrue);
  });

  test('keeps only the comments people wrote', () {
    expect(
        PullRequestThread.fromJson({
          'comments': [
            {'content': 'Ann voted 10', 'commentType': 'system'},
          ],
        }),
        isNull);
    expect(PullRequestThread.fromJson({'isDeleted': true, 'comments': []}), isNull);

    final thread = PullRequestThread.fromJson({
      'status': 'wontFix',
      'comments': [
        {'content': 'Second', 'publishedDate': '2026-10-20T11:00:00Z'},
        {'content': 'Gone', 'isDeleted': true},
        {'content': 'First', 'publishedDate': '2026-10-20T10:00:00Z'},
      ],
    })!;
    expect(thread.comments.map((c) => c.content), ['First', 'Second']);
    expect(thread.isResolved, isTrue);
    expect(thread.lastUpdated, DateTime.parse('2026-10-20T11:00:00Z').toLocal());
  });
}
