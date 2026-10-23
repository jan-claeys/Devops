import 'package:devops/screens/home_screen.dart';
import 'package:devops/screens/pull_request_screen.dart';
import 'package:devops/screens/pull_requests_screen.dart';
import 'package:devops/screens/work_item_detail_screen.dart';
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
      ..addPullRequest(pullRequestJson(11, title: 'Fix login',
          creationDate: '2026-10-19T10:00:00Z', reviewers: [('Ann', 10)]))
      ..addPullRequest(pullRequestJson(12, title: 'New dashboard', isDraft: true,
          createdById: meId, source: 'refs/heads/feature/dashboard'))
      ..addPullRequest(pullRequestJson(13, title: 'Old cleanup', status: 'completed',
          creationDate: '2026-10-01T10:00:00Z', reviewers: [('Me', 10)]))
      ..addPullRequest(pullRequestJson(14, title: 'Review this', mergeStatus: 'conflicts',
          creationDate: '2026-10-18T10:00:00Z', reviewers: [('Me', 0), ('Bob', -5)]));
  });

  Iterable<Uri> listRequests() => fake.requests
      .where((r) => r.url.path.endsWith('/_apis/git/pullrequests'))
      .map((r) => r.url);

  Future<void> pumpScreen(WidgetTester tester,
      {List<String> projects = const ['Contoso'], Size size = const Size(400, 900)}) async {
    await pumpApp(tester, const PullRequestsScreen(),
        state: connectedState(fake, projects: projects), size: size);
    await tester.pumpAndSettle();
  }

  testWidgets('lists the open pull requests, newest first', (tester) async {
    await pumpScreen(tester);

    expect(find.text(en.pullRequestCount(3)), findsOneWidget);
    expect(find.text('Old cleanup'), findsNothing);
    final dashboard = tester.getTopLeft(find.text('New dashboard'));
    final login = tester.getTopLeft(find.text('Fix login'));
    expect(dashboard.dy, lessThan(login.dy));
    expect(find.text(en.prDraft), findsOneWidget);
    expect(find.text('feature/dashboard → main'), findsOneWidget);
    expect(find.byTooltip(en.mergeConflicts), findsOneWidget);
    expect(listRequests().single.queryParameters['searchCriteria.status'], 'active');
  });

  testWidgets('also shows closed pull requests', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text(en.openOnly));
    await tester.pumpAndSettle();

    expect(find.text('Old cleanup'), findsOneWidget);
    expect(find.text(en.prCompleted), findsOneWidget);
    expect(listRequests().last.queryParameters['searchCriteria.status'], 'all');
  });

  testWidgets('shows the pull requests to review or created by me', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text(en.scopeReviewing));
    await tester.pumpAndSettle();
    expect(find.text('Review this'), findsOneWidget);
    expect(find.text('Fix login'), findsNothing);
    expect(listRequests().last.queryParameters['searchCriteria.reviewerId'], meId);

    await tester.tap(find.text(en.scopeCreatedByMe));
    await tester.pumpAndSettle();
    expect(find.text('New dashboard'), findsOneWidget);
    expect(find.text('Review this'), findsNothing);
    expect(listRequests().last.queryParameters['searchCriteria.creatorId'], meId);

    // The user id is looked up once.
    expect(fake.requests.where((r) => r.url.path.endsWith('/connectionData')), hasLength(1));
  });

  testWidgets('shows the pull requests created by me or to review, once each', (tester) async {
    fake.addPullRequest(pullRequestJson(15, title: 'Mine to review',
        createdById: meId, reviewers: [('Me', 0)]));
    await pumpScreen(tester);

    // Only reachable from the overview, which calls showMine().
    tester.state<PullRequestsScreenState>(find.byType(PullRequestsScreen)).showMine();
    await tester.pumpAndSettle();
    expect(find.text('New dashboard'), findsOneWidget);
    expect(find.text('Review this'), findsOneWidget);
    expect(find.text('Mine to review'), findsOneWidget);
    expect(find.text('Fix login'), findsNothing);
    expect(find.text(en.pullRequestCount(3)), findsOneWidget);
    final last = listRequests().toList().reversed.take(2).map((u) => u.queryParameters);
    expect(last.map((q) => q['searchCriteria.creatorId']), contains(meId));
    expect(last.map((q) => q['searchCriteria.reviewerId']), contains(meId));
  });

  testWidgets('searches by title, branch and person', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(SearchBar), 'dashboard');
    await tester.pumpAndSettle();
    expect(find.text('New dashboard'), findsOneWidget);
    expect(find.text('Fix login'), findsNothing);

    await tester.enterText(find.byType(SearchBar), 'bob');
    await tester.pumpAndSettle();
    expect(find.text('Review this'), findsOneWidget);
    expect(find.text('New dashboard'), findsNothing);
  });

  testWidgets('combines the pull requests of several projects', (tester) async {
    fake.addPullRequest(pullRequestJson(20, title: 'Docs', project: 'Fabrikam'));
    await pumpScreen(tester, projects: ['Contoso', 'Fabrikam']);

    expect(find.text(en.pullRequestCount(4)), findsOneWidget);
    expect(find.text('web · Fabrikam'), findsOneWidget);
    expect(listRequests(), hasLength(2));
  });

  testWidgets('points to the Code scope when not authorized', (tester) async {
    fake.failWith = 401;
    await pumpScreen(tester);

    expect(find.text(en.loadPullRequestsFailed), findsOneWidget);
    expect(find.textContaining(en.codeScopeHint), findsOneWidget);

    fake.failWith = null;
    await tester.tap(find.widgetWithText(FilledButton, en.settings));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Fix login'), findsOneWidget);
  });

  testWidgets('shows the details of a pull request', (tester) async {
    fake
      ..pullRequests[14]!['description'] = 'Fixes the **login** page'
      ..threads[14] = [
        {
          'id': 1,
          'status': 'active',
          'comments': [
            {
              'content': 'Looks good, one question',
              'commentType': 'text',
              'author': {'displayName': 'Bob', 'id': 'id-Bob'},
              'publishedDate': '2026-10-20T09:00:00Z',
            },
            {
              'content': 'Answered',
              'commentType': 'text',
              'author': {'displayName': 'Jan Claeys'},
              'publishedDate': '2026-10-20T10:00:00Z',
            },
          ],
        },
        {
          'id': 2,
          'status': 'fixed',
          'threadContext': {'filePath': '/src/login.dart'},
          'comments': [
            {
              'content': 'Typo here',
              'commentType': 'text',
              'author': {'displayName': 'Ann'},
              'publishedDate': '2026-10-19T09:00:00Z',
            },
          ],
        },
        {
          'id': 3,
          'comments': [
            {'content': 'Bob voted -5', 'commentType': 'system'},
          ],
        },
      ]
      ..pullRequestWorkItems[14] = [5]
      ..add(workItemJson(5, title: 'Login is broken'));
    await pumpScreen(tester);
    await tester.tap(find.text('Review this'));
    await tester.pumpAndSettle();

    expect(find.byType(PullRequestScreen), findsOneWidget);
    expect(find.text('web !14'), findsWidgets);
    expect(find.text(en.mergeConflicts), findsOneWidget);
    expect(find.textContaining('login', findRichText: true), findsWidgets);
    expect(find.text('Me'), findsOneWidget);
    expect(find.text(en.voteNone), findsOneWidget);
    expect(find.text(en.voteWaitingForAuthor), findsOneWidget);

    final scrollable = find
        .descendant(of: find.byType(PullRequestScreen), matching: find.byType(Scrollable))
        .first;
    await tester.scrollUntilVisible(find.text('Typo here', findRichText: true), 300,
        scrollable: scrollable);
    expect(find.text(en.commentsCount(2)), findsOneWidget);
    expect(find.text('Answered', findRichText: true), findsOneWidget);
    expect(find.text('/src/login.dart'), findsOneWidget);
    expect(find.text(en.threadResolved), findsOneWidget);
    expect(find.textContaining('voted'), findsNothing);

    await tester.scrollUntilVisible(find.text('Login is broken'), -300, scrollable: scrollable);
    await tester.tap(find.text('Login is broken'));
    await tester.pumpAndSettle();
    expect(find.byType(WorkItemDetailScreen), findsOneWidget);
  });

  testWidgets('shows the selected pull request next to the list on wide screens',
      (tester) async {
    await pumpScreen(tester, size: const Size(1200, 900));
    expect(find.text(en.selectPullRequestTitle), findsOneWidget);

    await tester.tap(find.text('Fix login'));
    await tester.pumpAndSettle();
    expect(find.byType(PullRequestScreen), findsOneWidget);
    expect(find.text(en.selectPullRequestTitle), findsNothing);
    expect(find.text(en.voteApproved), findsOneWidget);
  });

  testWidgets('has its own tab', (tester) async {
    await pumpApp(tester, const HomeScreen(), state: connectedState(fake));
    await tester.pumpAndSettle();

    await tester.tap(find.text(en.pullRequests));
    await tester.pumpAndSettle();
    expect(find.text('Fix login'), findsOneWidget);
  });
}
