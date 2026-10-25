import 'dart:convert';

import 'package:devops/screens/pull_request_screen.dart';
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
      ..addPullRequest(pullRequestJson(7, reviewers: [('Me', 0), ('Ann', 10)]))
      ..addPullRequest(pullRequestJson(8, status: 'completed', reviewers: [('Me', 10)]));
    fake.threads[7] = [
      {
        'id': 3,
        'status': 'active',
        'comments': [
          {
            'id': 1,
            'content': 'Why this change?',
            'author': {'displayName': 'Ann', 'id': 'id-Ann'},
            'publishedDate': '2026-10-20T10:00:00Z',
          },
        ],
      },
    ];
  });

  Future<void> pumpScreen(WidgetTester tester, int id) async {
    await pumpApp(tester, PullRequestScreen(project: 'Contoso', id: id),
        state: connectedState(fake), size: const Size(400, 2000));
    await tester.pumpAndSettle();
  }

  Iterable<Object?> votes() => fake.requests
      .where((r) => r.method == 'PUT' && r.url.path.endsWith('/reviewers/$meId'))
      .map((r) => jsonDecode(r.body));

  group('vote', () {
    testWidgets('approves', (tester) async {
      await pumpScreen(tester, 7);
      await tester.tap(find.text(en.voteApprove));
      await tester.pumpAndSettle();
      expect(votes(), [
        {'vote': 10},
      ]);
      expect(find.text(en.voteSaved), findsOneWidget);
    });

    testWidgets('asks before rejecting', (tester) async {
      await pumpScreen(tester, 7);
      await tester.tap(find.text(en.otherVotes));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.voteReject));
      await tester.pumpAndSettle();
      expect(find.text(en.rejectConfirmTitle), findsOneWidget);

      await tester.tap(find.text(en.cancel));
      await tester.pumpAndSettle();
      expect(votes(), isEmpty);

      await tester.tap(find.text(en.otherVotes));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.voteReject));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, en.voteReject));
      await tester.pumpAndSettle();
      expect(votes(), [
        {'vote': -10},
      ]);
    });

    testWidgets('names the Code scope when the token may not vote', (tester) async {
      await pumpScreen(tester, 7);
      fake
        ..failWith = 401
        ..failPath = '/reviewers/';
      await tester.tap(find.text(en.voteApprove));
      await tester.pumpAndSettle();
      expect(find.textContaining(en.codeScopeHint), findsOneWidget);
    });

    testWidgets('is not offered on a closed pull request', (tester) async {
      await pumpScreen(tester, 8);
      expect(find.text(en.voteApprove), findsNothing);
    });
  });

  group('comment', () {
    Iterable<Object?> posted() => fake.requests
        .where((r) => r.method == 'POST' && r.url.path.endsWith('/threads'))
        .map((r) => (jsonDecode(r.body) as Map)['comments']);

    testWidgets('starts a discussion and clears the field', (tester) async {
      await pumpScreen(tester, 7);
      await tester.enterText(find.widgetWithText(TextField, en.writeComment), 'Nice work');
      await tester.pump();
      await tester.tap(find.byTooltip(en.send));
      await tester.pumpAndSettle();
      expect(posted(), [
        [
          {'parentCommentId': 0, 'content': 'Nice work', 'commentType': 'text'},
        ],
      ]);
      expect(find.text('Nice work'), findsNothing);
    });

    testWidgets('keeps the text when the token may not comment', (tester) async {
      await pumpScreen(tester, 7);
      fake
        ..failWith = 401
        ..failPath = '/threads';
      await tester.enterText(find.widgetWithText(TextField, en.writeComment), 'Nice work');
      await tester.pump();
      await tester.tap(find.byTooltip(en.send));
      await tester.pumpAndSettle();
      expect(find.text('Nice work'), findsOneWidget);
      expect(find.textContaining(en.codeScopeHint), findsOneWidget);
    });
  });

  testWidgets('replies to a discussion', (tester) async {
    await pumpScreen(tester, 7);
    await tester.tap(find.text(en.reply));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, en.writeReply), 'To fix the login');
    await tester.pump();
    await tester.tap(find.byTooltip(en.send).last);
    await tester.pumpAndSettle();

    final reply = fake.requests.singleWhere((r) => r.method == 'POST');
    expect(reply.url.path, endsWith('/pullRequests/7/threads/3/comments'));
    expect(jsonDecode(reply.body),
        {'parentCommentId': 1, 'content': 'To fix the login', 'commentType': 'text'});
    expect(find.widgetWithText(TextField, en.writeReply), findsNothing);
  });

  testWidgets('resolves a discussion', (tester) async {
    await pumpScreen(tester, 7);
    await tester.tap(find.text(en.resolveThread));
    await tester.pumpAndSettle();

    final patch = fake.requests.singleWhere((r) => r.method == 'PATCH');
    expect(patch.url.path, endsWith('/pullRequests/7/threads/3'));
    expect(jsonDecode(patch.body), {'status': 'fixed'});
  });

  testWidgets('reactivates a resolved discussion', (tester) async {
    (fake.threads[7]!.single)['status'] = 'fixed';
    await pumpScreen(tester, 7);
    expect(find.text(en.resolveThread), findsNothing);
    await tester.tap(find.text(en.reactivateThread));
    await tester.pumpAndSettle();
    expect(jsonDecode(fake.requests.singleWhere((r) => r.method == 'PATCH').body),
        {'status': 'active'});
  });

  group('files', () {
    setUp(() {
      fake.changes[7] = [
        {
          'changeType': 'edit',
          'item': {'path': '/config/app.yaml', 'objectId': 'new', 'originalObjectId': 'old'},
        },
        {
          'changeType': 'add',
          'item': {'path': '/docs/notes.md', 'objectId': 'notes'},
        },
        {
          'changeType': 'edit',
          'item': {'path': '/config', 'isFolder': true},
        },
      ];
      fake.blobs.addAll({
        'old': 'name: web\nreplicas: 2\nport: 80\n',
        'new': 'name: web\nreplicas: 3\nport: 80\n',
        'notes': 'one\ntwo\n',
      });
    });

    Future<void> openFiles(WidgetTester tester) async {
      await pumpScreen(tester, 7);
      await tester.tap(find.text(en.filesTab));
      await tester.pumpAndSettle();
    }

    testWidgets('lists the changed files with their added and removed lines', (tester) async {
      await openFiles(tester);
      expect(find.text(en.filesChanged(2)), findsOneWidget);
      expect(find.text('app.yaml'), findsOneWidget);
      expect(find.text('config'), findsOneWidget);
      expect(find.text('notes.md'), findsOneWidget);
      expect(find.text('+1 −1'), findsOneWidget);
      expect(find.text('+2 −0'), findsOneWidget);
      // The totals.
      expect(find.text('+3 −1'), findsOneWidget);
      // The overview is hidden meanwhile.
      expect(find.text(en.reviewers), findsNothing);
    });

    testWidgets('opens the diff of a file', (tester) async {
      await openFiles(tester);
      await tester.tap(find.text('app.yaml'));
      await tester.pumpAndSettle();
      expect(find.text('@@ -1,3 +1,3 @@'), findsOneWidget);
      expect(find.text('- replicas: 2'), findsOneWidget);
      expect(find.text('+ replicas: 3'), findsOneWidget);
      expect(find.text('  port: 80'), findsOneWidget);
    });

    testWidgets('loads the files once, and again on refresh', (tester) async {
      await openFiles(tester);
      int loads() => fake.requests.where((r) => r.url.path.endsWith('/changes')).length;
      expect(loads(), 1);

      await tester.tap(find.text(en.overviewTab));
      await tester.pumpAndSettle();
      expect(find.text(en.reviewers), findsOneWidget);
      await tester.tap(find.text(en.filesTab));
      await tester.pumpAndSettle();
      expect(loads(), 1);

      await tester.fling(find.text('app.yaml'), const Offset(0, 1000), 1000);
      await tester.pumpAndSettle();
      expect(loads(), 2);
    });

    testWidgets('says when a file could not be loaded', (tester) async {
      fake.blobs.remove('notes');
      await openFiles(tester);
      await tester.tap(find.text('notes.md'));
      await tester.pumpAndSettle();
      expect(find.text(en.loadFileFailed), findsOneWidget);
      expect(find.text('+1 −1'), findsOneWidget);
    });

    testWidgets('says when nothing changed', (tester) async {
      fake.changes[7] = [];
      await openFiles(tester);
      expect(find.text(en.noFileChanges), findsOneWidget);
    });
  });
}
