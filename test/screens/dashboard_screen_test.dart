import 'package:devops/screens/dashboard_screen.dart';
import 'package:devops/screens/home_screen.dart';
import 'package:devops/screens/pipeline_run_screen.dart';
import 'package:devops/screens/pull_request_screen.dart';
import 'package:devops/screens/settings_screen.dart';
import 'package:devops/screens/work_item_detail_screen.dart';
import 'package:devops/services/devops_api.dart';
import 'package:devops/widgets/pipeline_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers.dart';

/// [age] ago, as Azure DevOps writes dates.
String ago(Duration age) => DateTime.now().toUtc().subtract(age).toIso8601String();

Map<String, dynamic> build(
  int id, {
  int definition = 1,
  String pipeline = 'CI',
  String branch = 'refs/heads/feature/login',
  String status = 'completed',
  String? result = 'succeeded',
  bool mine = true,
  Duration age = const Duration(hours: 1),
}) {
  final json = runJson(id,
      pipeline: pipeline,
      branch: branch,
      status: status,
      result: result,
      queueTime: ago(age),
      startTime: ago(age),
      finishTime: status == 'completed' ? ago(age - const Duration(minutes: 2)) : null);
  (json['definition'] as Map)['id'] = definition;
  json['requestedFor'] = mine ? {'displayName': 'Me', 'id': meId} : {'displayName': 'Ann'};
  return json;
}

void main() {
  setUpAll(initializeDateFormatting);

  late FakeDevOps fake;

  setUp(() {
    mockStorage();
    final approval = environmentJson(1, 'Production', status: 'notStarted', pendingApprovers: ['Me']);
    ((approval['preDeployApprovals'] as List).single['approver'] as Map)['id'] = meId;
    fake = FakeDevOps()
      ..addRun(build(1, branch: 'refs/heads/main', mine: false, age: const Duration(hours: 5)))
      ..addRun(build(2, result: 'failed', age: const Duration(hours: 3)))
      ..addRun(build(3, status: 'inProgress', result: null, age: const Duration(minutes: 1)))
      ..addRun(build(4, pipeline: 'Nightly', definition: 2, branch: 'refs/heads/main',
          result: 'failed', mine: false, age: const Duration(hours: 2)))
      ..releases[7] = releaseJson(7, pipeline: 'Deploy web', environments: [approval])
      ..addPullRequest(pullRequestJson(11, title: 'Review this', reviewers: [('Me', 0)]))
      ..addPullRequest(pullRequestJson(12, title: 'Fix login', mergeStatus: 'conflicts',
          createdById: meId))
      ..addPullRequest(pullRequestJson(13, title: 'Ready one', createdById: meId,
          reviewers: [('Ann', 10)]))
      ..addPullRequest(pullRequestJson(14, title: 'Rejected one', createdById: meId,
          reviewers: [('Bob', -10)]))
      ..addPullRequest(pullRequestJson(15, title: 'Someone else', reviewers: [('Ann', 0)]))
      ..add(workItemJson(21, title: 'Crash on start', type: 'Bug', state: 'Active', fields: {
        'Microsoft.VSTS.Common.Priority': 1,
        'System.ChangedDate': ago(const Duration(days: 1)),
      }))
      ..add(workItemJson(22, title: 'Old task', type: 'Task', state: 'New', fields: {
        'System.ChangedDate': ago(const Duration(days: 30)),
      }));
  });

  Future<void> pumpScreen(WidgetTester tester, {Size size = const Size(400, 2600)}) async {
    await pumpApp(tester, const DashboardScreen(), state: connectedState(fake), size: size);
    await tester.pumpAndSettle();
  }

  testWidgets('shows what waits for the user', (tester) async {
    await pumpScreen(tester);

    // To review, two needing changes, one ready, a failed run and an approval.
    expect(find.text('${en.waitingForYou} (6)'), findsOneWidget);
    expect(find.textContaining(en.waitingForYourReview), findsOneWidget);
    expect(find.textContaining(en.mergeConflicts), findsOneWidget);
    expect(find.textContaining('${en.voteRejected} · Bob'), findsOneWidget);
    expect(find.textContaining(en.readyToComplete), findsOneWidget);
    expect(find.textContaining('${en.runFailed} · feature/login'), findsOneWidget);
    expect(find.textContaining(en.yourApproval), findsOneWidget);
    expect(find.text('Someone else'), findsNothing);
  });

  testWidgets('warns when the main branch fails', (tester) async {
    await pumpScreen(tester);

    expect(find.text(en.failingOnMain(1)), findsOneWidget);
    expect(find.text('Nightly'), findsOneWidget);
  });

  testWidgets('keeps warning when many newer builds follow', (tester) async {
    for (var id = 100; id < 160; id++) {
      fake.addRun(build(id, pipeline: 'Busy', definition: 5, mine: false,
          age: const Duration(minutes: 30)));
    }
    await pumpScreen(tester);

    expect(find.text(en.failingOnMain(1)), findsOneWidget);
  });

  testWidgets('shows the runs of the user with the progress of a running one', (tester) async {
    await pumpScreen(tester);

    expect(find.text(en.myRuns), findsOneWidget);
    // The failed run is listed under both "waiting for you" and "my runs".
    expect(find.text('CI'), findsNWidgets(3));
    expect(find.byType(EstimatedProgress), findsOneWidget);
  });

  testWidgets('lists the tickets being worked on first, marking stale ones', (tester) async {
    await pumpScreen(tester);

    final crash = tester.getTopLeft(find.text('Crash on start'));
    final old = tester.getTopLeft(find.text('Old task'));
    expect(crash.dy, lessThan(old.dy));
    expect(find.text('P1'), findsOneWidget);
    expect(find.textContaining(en.noChangesFor(30)), findsOneWidget);
  });

  testWidgets('is all caught up when nothing waits', (tester) async {
    fake
      ..runs.clear()
      ..releases.clear()
      ..pullRequests.clear();
    await pumpScreen(tester);

    expect(find.text(en.waitingForYou), findsOneWidget);
    expect(find.text(en.nothingWaiting), findsOneWidget);
    expect(find.text(en.noRecentRuns), findsOneWidget);
    expect(find.text(en.noPullRequestsTitle), findsOneWidget);
    expect(find.text(en.failingOnMain(1)), findsNothing);
  });

  testWidgets('opens pull requests, runs and tickets', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Review this').first);
    await tester.pumpAndSettle();
    expect(find.byType(PullRequestScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining(en.runFailed).first);
    await tester.pumpAndSettle();
    expect(find.byType(PipelineRunScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crash on start'));
    await tester.pumpAndSettle();
    expect(find.byType(WorkItemDetailScreen), findsOneWidget);
  });

  testWidgets('loads the open tickets assigned to the user and their own builds', (tester) async {
    await pumpScreen(tester);

    final wiql = fake.requests.singleWhere((r) => r.url.path.endsWith('/_apis/wit/wiql'));
    expect(wiql.body, contains('[System.AssignedTo] = @me'));
    expect(wiql.body, contains('NOT IN'));
    final builds = fake.requests.where((r) => r.url.path.endsWith('/_apis/build/builds'));
    expect(builds.map((r) => r.url.queryParameters['requestedFor']), contains(meId));
  });

  testWidgets('shows the other parts when one fails to load', (tester) async {
    fake
      ..failWith = 401
      ..failPath = '/_apis/git/';
    await pumpScreen(tester);

    expect(find.text(en.loadPullRequestsFailed), findsOneWidget);
    expect(find.textContaining(en.codeScopeHint), findsOneWidget);
    expect(find.text(en.myPullRequests), findsNothing);
    expect(find.text(en.myRuns), findsOneWidget);
    expect(find.text('Crash on start'), findsOneWidget);
  });

  testWidgets('keeps the data and warns when a refresh fails', (tester) async {
    await pumpScreen(tester);

    fake.failWith = 401;
    await tester.pump(DashboardScreen.refreshInterval);
    await tester.pumpAndSettle();
    expect(find.text(en.refreshFailed(en.justNow)), findsOneWidget);
    expect(find.text('Crash on start'), findsOneWidget);

    fake.failWith = null;
    await tester.pump(DashboardScreen.refreshInterval);
    await tester.pumpAndSettle();
    expect(find.text(en.refreshFailed(en.justNow)), findsNothing);
  });

  testWidgets('shows an error when nothing loads', (tester) async {
    fake.failWith = 401;
    await pumpScreen(tester);

    expect(find.text(en.loadDashboardFailed), findsOneWidget);
    expect(find.text(en.errorUnauthorized), findsOneWidget);

    // Trying again won't help with an expired token: a new one is made in the settings.
    expect(find.text(en.retry), findsNothing);
    fake.failWith = null;
    await tester.tap(find.widgetWithText(FilledButton, en.settings));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('${en.waitingForYou} (6)'), findsOneWidget);
  });

  testWidgets('is the first tab and leads to the pull requests of the user', (tester) async {
    fake.pullRequests.removeWhere((id, _) => id != 11 && id != 15);
    for (var id = 30; id < 36; id++) {
      fake.addPullRequest(pullRequestJson(id, title: 'Mine $id', createdById: meId));
    }
    await pumpApp(tester, const HomeScreen(), state: connectedState(fake),
        size: const Size(1200, 1600));
    await tester.pumpAndSettle();
    expect(find.text('${en.waitingForYou} (3)'), findsOneWidget);

    await tester.tap(find.text(en.showAll(7)));
    await tester.pumpAndSettle();
    expect(find.text('${en.waitingForYou} (3)'), findsNothing);
    expect(find.text(en.pullRequestCount(7)), findsOneWidget);
    expect(find.text('Someone else'), findsNothing);
    final scopes = tester.widget<SegmentedButton<PullRequestScope>>(
        find.byType(SegmentedButton<PullRequestScope>));
    expect(scopes.selected, {PullRequestScope.mine});
  });
}
