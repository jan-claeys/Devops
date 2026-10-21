import 'package:devops/screens/home_screen.dart';
import 'package:devops/screens/pipeline_run_screen.dart';
import 'package:devops/screens/pipelines_screen.dart';
import 'package:devops/widgets/pipeline_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers.dart';

void main() {
  setUpAll(initializeDateFormatting);

  late FakeDevOps fake;

  setUp(() {
    mockStorage();
    fake = FakeDevOps()
      ..addRun(runJson(1, pipeline: 'Nightly', result: 'failed',
          queueTime: '2026-10-19T10:00:00Z'))
      ..addRun(
        runJson(2, pipeline: 'CI', status: 'inProgress', result: null, finishTime: null),
        [
          recordJson('s1', 'Stage', 'Build', state: 'inProgress', result: null),
          recordJson('p1', 'Phase', 'Job', parent: 's1', state: 'inProgress', result: null),
          recordJson('j1', 'Job', 'Compile and test', parent: 'p1',
              state: 'inProgress', result: null),
          recordJson('t1', 'Task', 'Checkout', parent: 'j1'),
          recordJson('t2', 'Task', 'Run tests', parent: 'j1', order: 2,
              state: 'inProgress', result: null),
          recordJson('s2', 'Stage', 'Deploy', order: 2, state: 'pending', result: null),
        ],
      );
  });

  int buildRequests() =>
      fake.requests.where((r) => r.url.path.endsWith('/_apis/build/builds')).length;

  Future<void> pumpScreen(WidgetTester tester,
      {List<String> projects = const ['Contoso'], Size size = const Size(400, 900)}) async {
    await pumpApp(tester, const PipelinesScreen(),
        state: connectedState(fake, projects: projects), size: size);
    await tester.pumpAndSettle();
  }

  testWidgets('lists the latest runs, newest first', (tester) async {
    await pumpScreen(tester);

    expect(find.text(en.runCount(2)), findsOneWidget);
    final ci = tester.getTopLeft(find.text('CI'));
    final nightly = tester.getTopLeft(find.text('Nightly'));
    expect(ci.dy, lessThan(nightly.dy));
    expect(find.text(en.runRunning), findsOneWidget);
    expect(find.text(en.runFailed), findsOneWidget);
    expect(find.text('main'), findsNWidgets(2));
    expect(
        fake.requests
            .firstWhere((r) => r.url.path.endsWith('/_apis/build/builds'))
            .url
            .queryParameters['queryOrder'],
        'queueTimeDescending');
  });

  testWidgets('searches and filters active runs', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text(en.activeOnly));
    await tester.pumpAndSettle();
    expect(find.text('CI'), findsOneWidget);
    expect(find.text('Nightly'), findsNothing);

    await tester.tap(find.text(en.activeOnly));
    await tester.enterText(find.byType(SearchBar), 'night');
    await tester.pumpAndSettle();
    expect(find.text('CI'), findsNothing);
    expect(find.text('Nightly'), findsOneWidget);
  });

  testWidgets('combines the runs of several projects', (tester) async {
    fake.addRun(runJson(3, pipeline: 'Docs', project: 'Fabrikam'));
    await pumpScreen(tester, projects: ['Contoso', 'Fabrikam']);

    expect(find.text(en.runCount(3)), findsOneWidget);
    expect(find.text('Fabrikam'), findsOneWidget);
    expect(buildRequests(), 2);
  });

  testWidgets('shows an error and retries', (tester) async {
    fake.failWith = 500;
    await pumpScreen(tester);
    expect(find.text(en.loadRunsFailed), findsOneWidget);

    fake.failWith = null;
    await tester.tap(find.text(en.retry));
    await tester.pumpAndSettle();
    expect(find.text('CI'), findsOneWidget);
  });

  testWidgets('refreshes while a run is still going', (tester) async {
    await pumpScreen(tester);
    expect(buildRequests(), 1);

    fake.addRun(runJson(2, pipeline: 'CI'));
    await tester.pump(PipelinesScreen.refreshInterval);
    await tester.pumpAndSettle();
    expect(buildRequests(), 2);
    expect(find.text(en.runRunning), findsNothing);
    expect(find.text(en.runSucceeded), findsOneWidget);

    // Everything finished: no more refreshing.
    await tester.pump(PipelinesScreen.refreshInterval * 2);
    expect(buildRequests(), 2);
  });

  testWidgets('follows the progress of a run', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('CI'));
    await tester.pumpAndSettle();

    expect(find.byType(PipelineRunScreen), findsOneWidget);
    expect(find.text('20261020.2'), findsWidgets);
    expect(find.text(en.tasksProgress(1, 2)), findsOneWidget);
    expect(find.text('Build'), findsOneWidget);
    expect(find.text('Deploy'), findsOneWidget);
    // The running stage is expanded up to its tasks; phases are skipped.
    expect(find.text('Compile and test'), findsOneWidget);
    expect(find.text('Run tests'), findsOneWidget);
    expect(find.text('Job'), findsNothing);

    fake.timelines[2]![4] = recordJson('t2', 'Task', 'Run tests',
        parent: 'j1', order: 2);
    await tester.pump(PipelineRunScreen.refreshInterval);
    await tester.pumpAndSettle();
    expect(find.text(en.tasksProgress(2, 2)), findsOneWidget);

    // The list behind the run doesn't refresh while it is covered.
    final before = buildRequests();
    await tester.pump(PipelinesScreen.refreshInterval);
    expect(buildRequests(), before);
  });

  testWidgets('shows a run that hasn\'t started yet', (tester) async {
    fake.addRun(runJson(5, pipeline: 'Queued one', status: 'notStarted', result: null,
        startTime: null, finishTime: null, queueTime: '2026-10-21T10:00:00Z'));
    await pumpScreen(tester);
    await tester.tap(find.text('Queued one'));
    await tester.pumpAndSettle();

    expect(find.text(en.noStagesYet), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(RunStatusBadge), matching: find.text(en.runQueued)),
        findsOneWidget);
  });

  testWidgets('shows the selected run next to the list on wide screens', (tester) async {
    await pumpScreen(tester, size: const Size(1200, 900));
    expect(find.text(en.selectRunTitle), findsOneWidget);

    await tester.tap(find.text('Nightly'));
    await tester.pumpAndSettle();
    expect(find.byType(PipelineRunScreen), findsOneWidget);
    expect(find.text(en.selectRunTitle), findsNothing);
    expect(find.text(en.noStagesYet), findsOneWidget);
  });

  testWidgets('switches between tickets and pipelines', (tester) async {
    await pumpApp(tester, const HomeScreen(), state: connectedState(fake));
    await tester.pumpAndSettle();
    expect(find.text(en.noTicketsTitle), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text(en.pipelines));
    await tester.pumpAndSettle();
    expect(find.text('CI'), findsOneWidget);
    expect(find.text(en.noTicketsTitle), findsNothing);

    // Hidden behind the tickets tab, the pipelines aren't refreshed.
    await tester.tap(find.text(en.tickets));
    await tester.pumpAndSettle();
    final before = buildRequests();
    await tester.pump(PipelinesScreen.refreshInterval * 2);
    expect(buildRequests(), before);

    // Shown again, they are.
    await tester.tap(find.text(en.pipelines));
    await tester.pumpAndSettle();
    expect(buildRequests(), before + 1);
  });

  testWidgets('uses a navigation rail on wide screens', (tester) async {
    await pumpApp(tester, const HomeScreen(),
        state: connectedState(fake), size: const Size(1200, 900));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  group('releases', () {
    setUp(() {
      fake.releases[7] = releaseJson(7, pipeline: 'Deploy web', environments: [
        environmentJson(1, 'Test', tasks: [('Download', 'succeeded'), ('Deploy', 'succeeded')]),
        environmentJson(2, 'Production', rank: 2, status: 'notStarted',
            pendingApprovers: ['Ann']),
      ]);
    });

    int releaseRequests() =>
        fake.requests.where((r) => r.url.path.contains('/_apis/release/')).length;

    testWidgets('lists releases with their stages between the builds', (tester) async {
      await pumpScreen(tester);

      expect(find.text(en.runCount(3)), findsOneWidget);
      expect(find.text('Deploy web'), findsOneWidget);
      expect(find.text('Release-7'), findsOneWidget);
      expect(find.byType(StageChips), findsOneWidget);
      expect(find.text('Production'), findsOneWidget);
      // Newest first: the release was created after the CI build.
      expect(tester.getTopLeft(find.text('Deploy web')).dy,
          lessThan(tester.getTopLeft(find.text('CI')).dy));
    });

    testWidgets('shows only builds or only releases', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text(en.releases));
      await tester.pumpAndSettle();
      expect(find.text('Deploy web'), findsOneWidget);
      expect(find.text('CI'), findsNothing);

      await tester.tap(find.text(en.builds));
      await tester.pumpAndSettle();
      expect(find.text('Deploy web'), findsNothing);
      expect(find.text('CI'), findsOneWidget);

      await tester.tap(find.text(en.scopeAll));
      await tester.pumpAndSettle();
      expect(find.text(en.runCount(3)), findsOneWidget);
    });

    testWidgets('a release waiting for approval counts as active', (tester) async {
      await pumpScreen(tester);
      await tester.tap(find.text(en.activeOnly));
      await tester.pumpAndSettle();

      expect(find.text('Deploy web'), findsOneWidget);
      expect(find.text('CI'), findsOneWidget);
      expect(find.text('Nightly'), findsNothing);
    });

    testWidgets('still shows the builds when the releases fail', (tester) async {
      fake
        ..failWith = 401
        ..failPath = '/_apis/release/';
      await pumpScreen(tester);

      expect(find.text('CI'), findsOneWidget);
      expect(find.text(en.loadReleasesFailed), findsOneWidget);
      expect(find.textContaining(en.releaseScopeHint), findsOneWidget);

      await tester.tap(find.text(en.builds));
      await tester.pumpAndSettle();
      expect(find.text(en.loadReleasesFailed), findsNothing);
    });

    testWidgets('follows a release and who has to approve it', (tester) async {
      await pumpScreen(tester);
      await tester.tap(find.text('Deploy web'));
      await tester.pumpAndSettle();

      expect(find.byType(PipelineRunScreen), findsOneWidget);
      expect(find.text('Release-7'), findsWidgets);
      expect(find.text('20261020.7'), findsOneWidget);
      expect(find.text(en.waitingForApprovalBy('Ann')), findsOneWidget);
      expect(find.text(en.tasksProgress(2, 2)), findsOneWidget);
      expect(fake.requests.last.url.path, '/contoso/Contoso/_apis/release/releases/7');

      // Approved and deployed: refreshing stops.
      fake.releases[7] = releaseJson(7, pipeline: 'Deploy web', environments: [
        environmentJson(1, 'Test', tasks: [('Deploy', 'succeeded')]),
        environmentJson(2, 'Production', rank: 2, tasks: [('Deploy', 'succeeded')]),
      ]);
      final before = releaseRequests();
      await tester.pump(PipelineRunScreen.refreshInterval);
      await tester.pumpAndSettle();
      expect(releaseRequests(), before + 1);
      expect(find.text(en.waitingForApprovalBy('Ann')), findsNothing);
      // The progress bar is left out once a release is done.
      expect(find.text(en.progress), findsNothing);

      await tester.pump(PipelineRunScreen.refreshInterval * 2);
      expect(releaseRequests(), before + 1);
    });
  });
}
