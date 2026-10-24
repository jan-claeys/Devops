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
}
