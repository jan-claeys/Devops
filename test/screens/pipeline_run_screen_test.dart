import 'dart:convert';

import 'package:devops/models/pipeline_run.dart';
import 'package:devops/screens/pipeline_run_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';

import '../helpers.dart';

void main() {
  setUpAll(initializeDateFormatting);

  late FakeDevOps fake;

  setUp(() {
    mockStorage();
    fake = FakeDevOps()
      ..addRun(runJson(5, status: 'inProgress', result: null, finishTime: null), [
        recordJson('s1', 'Stage', 'Build'),
        recordJson('s2', 'Stage', 'Production', order: 2, state: 'pending', result: null),
        recordJson('c1', 'Checkpoint', 'Checkpoint', parent: 's2', state: 'inProgress',
            result: null),
        recordJson('a1', 'Checkpoint.Approval', 'Approval', parent: 'c1',
            state: 'inProgress', result: null),
      ]);
    fake.approvals.add({
      'id': 'a1',
      'status': 'pending',
      'instructions': 'Check the release notes',
      'steps': [
        {'status': 'pending', 'assignedApprover': {'displayName': 'Release managers'}},
      ],
    });
    fake.releases[3] = releaseJson(3, environments: [
      environmentJson(1, 'Acceptance', status: 'notStarted', pendingApprovers: ['Me']),
    ]);
  });

  Future<void> pumpScreen(WidgetTester tester, int id, {RunKind kind = RunKind.build}) async {
    await pumpApp(tester, PipelineRunScreen(project: 'Contoso', id: id, kind: kind),
        state: connectedState(fake), size: const Size(400, 2000));
    await tester.pumpAndSettle();
  }

  /// Stops the refresh of the running run.
  Future<void> close(WidgetTester tester) => tester.pumpWidget(const SizedBox());

  Future<void> respond(WidgetTester tester, String button, {String comment = ''}) async {
    await tester.tap(find.text(button));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, en.approvalCommentHint), comment);
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text(button)));
    await tester.pumpAndSettle();
  }

  Iterable<http.Request> patches() => fake.requests.where((r) => r.method == 'PATCH');

  testWidgets('approves a stage of a YAML pipeline', (tester) async {
    await pumpScreen(tester, 5);
    expect(find.text(en.approvals), findsOneWidget);
    expect(find.text(en.waitingForApprovalBy('Release managers')), findsOneWidget);
    expect(find.text('Check the release notes'), findsOneWidget);

    await respond(tester, en.voteApprove, comment: 'Ship it');
    expect(patches().single.url.path, '/contoso/Contoso/_apis/pipelines/approvals');
    expect(jsonDecode(patches().single.body), [
      {'approvalId': 'a1', 'status': 'approved', 'comment': 'Ship it'},
    ]);
    expect(find.text(en.stageApproved), findsOneWidget);
    await close(tester);
  });

  testWidgets('asks nothing when the dialog is canceled', (tester) async {
    await pumpScreen(tester, 5);
    await tester.tap(find.text(en.voteReject));
    await tester.pumpAndSettle();
    expect(find.text(en.rejectStage('Production')), findsOneWidget);
    await tester.tap(find.text(en.cancel));
    await tester.pumpAndSettle();
    expect(patches(), isEmpty);
    await close(tester);
  });

  testWidgets('names the Build scope when the token may not approve', (tester) async {
    await pumpScreen(tester, 5);
    fake
      ..failWith = 401
      ..failPath = '/pipelines/approvals';
    await respond(tester, en.voteApprove);
    expect(find.textContaining(en.buildScopeHint), findsOneWidget);
    await close(tester);
  });

  testWidgets('rejects a stage of a release', (tester) async {
    await pumpScreen(tester, 3, kind: RunKind.release);
    await respond(tester, en.voteReject, comment: 'Not now');
    expect(patches().single.url.toString(),
        'https://vsrm.dev.azure.com/contoso/Contoso/_apis/release/approvals/100?api-version=7.1');
    expect(jsonDecode(patches().single.body), {'status': 'rejected', 'comments': 'Not now'});
    await close(tester);
  });

  testWidgets('shows no approvals when nothing waits', (tester) async {
    fake.approvals.clear();
    await pumpScreen(tester, 5);
    expect(find.text(en.approvals), findsNothing);
    await close(tester);
  });

  group('run actions', () {
    testWidgets('cancels a running build after asking', (tester) async {
      await pumpScreen(tester, 5);
      expect(find.text(en.runAgain), findsNothing);
      await tester.tap(find.text(en.cancelRun));
      await tester.pumpAndSettle();
      expect(find.text(en.cancelRunTitle), findsOneWidget);

      await tester.tap(find.text(en.keepRunning));
      await tester.pumpAndSettle();
      expect(patches(), isEmpty);

      await tester.tap(find.text(en.cancelRun));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
          of: find.byType(AlertDialog), matching: find.text(en.cancelRun)));
      await tester.pumpAndSettle();
      expect(patches().single.url.path, '/contoso/Contoso/_apis/build/builds/5');
      expect(jsonDecode(patches().single.body), {'status': 'cancelling'});
      await close(tester);
    });

    testWidgets('runs a failed build again and opens the new run', (tester) async {
      fake.addRun(runJson(6, result: 'failed'), [recordJson('s1', 'Stage', 'Build')]);
      fake.addRun(runJson(1000, pipeline: 'CI again'), [recordJson('s1', 'Stage', 'Build')]);
      await pumpScreen(tester, 6);
      expect(find.text(en.cancelRun), findsNothing);
      await tester.tap(find.text(en.runAgain));
      await tester.pumpAndSettle();

      final post = fake.requests.singleWhere((r) => r.method == 'POST');
      expect(post.url.path, '/contoso/Contoso/_apis/build/builds');
      expect(find.text(en.runStarted), findsOneWidget);
      await tester.tap(find.text(en.open));
      await tester.pumpAndSettle();
      expect(find.text('CI again'), findsOneWidget);
    });

    testWidgets('reruns the failed jobs of a failed build', (tester) async {
      fake.addRun(runJson(6, result: 'failed'), [recordJson('s1', 'Stage', 'Build')]);
      await pumpScreen(tester, 6);
      await tester.tap(find.text(en.rerunFailedJobs));
      await tester.pumpAndSettle();
      expect(patches().single.url.queryParameters['retry'], 'true');
    });

    testWidgets('names the Build scope when the token may not run pipelines', (tester) async {
      fake.addRun(runJson(6), [recordJson('s1', 'Stage', 'Build')]);
      await pumpScreen(tester, 6);
      expect(find.text(en.rerunFailedJobs), findsNothing);
      fake
        ..failWith = 403
        ..failPath = '/builds';
      await tester.tap(find.text(en.runAgain));
      await tester.pumpAndSettle();
      expect(find.textContaining(en.buildScopeHint), findsOneWidget);
    });

    testWidgets('are not offered for releases', (tester) async {
      await pumpScreen(tester, 3, kind: RunKind.release);
      expect(find.text(en.cancelRun), findsNothing);
      expect(find.text(en.runAgain), findsNothing);
    });
  });
}
