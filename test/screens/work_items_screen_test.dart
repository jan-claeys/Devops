import 'dart:convert';

import 'package:devops/screens/settings_screen.dart';
import 'package:devops/screens/work_item_detail_screen.dart';
import 'package:devops/screens/work_items_screen.dart';
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
      ..add(workItemJson(1, title: 'Login fails', type: 'Bug', fields: {
        'System.Tags': 'auth; urgent',
        'System.AssignedTo': {'displayName': 'Jan Claeys'},
        'Microsoft.VSTS.Common.Priority': 1,
      }))
      ..add(workItemJson(2, title: 'Write docs', type: 'Task'))
      ..add(workItemJson(3, title: 'Dark mode', type: 'User Story'));
  });

  String lastQuery() => jsonDecode(fake.requests
      .lastWhere((r) => r.url.path.endsWith('/wiql'))
      .body)['query'] as String;

  Future<void> pumpScreen(WidgetTester tester,
      {List<String> projects = const ['Contoso'], Size size = const Size(400, 900)}) async {
    await pumpApp(tester, const WorkItemsScreen(),
        state: connectedState(fake, projects: projects), size: size);
    await tester.pumpAndSettle();
  }

  testWidgets('loads my open tickets', (tester) async {
    await pumpScreen(tester);

    expect(find.text(en.ticketCount(3)), findsOneWidget);
    expect(find.text('Login fails'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('P1'), findsOneWidget);
    expect(find.text('auth · urgent'), findsOneWidget);
    expect(find.text('JC'), findsOneWidget);
    expect(lastQuery(), contains('[System.AssignedTo] = @me'));
    expect(lastQuery(), contains('NOT IN'));
  });

  testWidgets('searches title, id, tags and assignee', (tester) async {
    await pumpScreen(tester);

    Future<void> search(String text) async {
      await tester.enterText(find.byType(SearchBar), text);
      await tester.pumpAndSettle();
    }

    await search('DOCS');
    expect(find.text('Write docs'), findsOneWidget);
    expect(find.text('Login fails'), findsNothing);

    await search('3');
    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text(en.ticketCount(1)), findsOneWidget);

    await search('urgent');
    expect(find.text('Login fails'), findsOneWidget);

    await search('claeys');
    expect(find.text('Login fails'), findsOneWidget);

    await search('nothing matches');
    expect(find.text(en.noTicketsTitle), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text(en.ticketCount(3)), findsOneWidget);
  });

  testWidgets('filters on work item type', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.widgetWithText(FilterChip, 'Task'));
    await tester.pumpAndSettle();
    expect(find.text('Write docs'), findsOneWidget);
    expect(find.text('Login fails'), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, 'Bug'));
    await tester.pumpAndSettle();
    expect(find.text(en.ticketCount(2)), findsOneWidget);
  });

  testWidgets('hides the type filter with only one type', (tester) async {
    fake.queryResult = [1];
    await pumpScreen(tester);
    expect(find.widgetWithText(FilterChip, 'Bug'), findsNothing);
  });

  testWidgets('reloads when scope or open filter change', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text(en.scopeCreatedByMe));
    await tester.pumpAndSettle();
    expect(lastQuery(), contains('[System.CreatedBy] = @me'));

    await tester.tap(find.text(en.scopeAll));
    await tester.pumpAndSettle();
    expect(lastQuery(), isNot(contains('@me')));

    await tester.tap(find.text(en.openOnly));
    await tester.pumpAndSettle();
    expect(lastQuery(), isNot(contains('NOT IN')));
  });

  testWidgets('shows an empty state', (tester) async {
    fake.queryResult = [];
    await pumpScreen(tester);
    expect(find.text(en.noTicketsTitle), findsOneWidget);
    expect(find.text(en.noTicketsMessage), findsOneWidget);
  });

  testWidgets('shows errors and retries', (tester) async {
    fake.failWith = 401;
    await pumpScreen(tester);
    expect(find.text(en.loadTicketsFailed), findsOneWidget);
    expect(find.text(en.errorUnauthorized), findsOneWidget);

    fake.failWith = null;
    await tester.tap(find.text(en.retry));
    await tester.pumpAndSettle();
    expect(find.text('Login fails'), findsOneWidget);
  });

  testWidgets('refresh button reloads', (tester) async {
    await pumpScreen(tester);
    final before = fake.requests.length;
    await tester.tap(find.byTooltip(en.refresh));
    await tester.pumpAndSettle();
    expect(fake.requests.length, greaterThan(before));
  });

  testWidgets('shows the tickets of several projects', (tester) async {
    fake
      ..projects.add({'id': '2', 'name': 'Fabrikam'})
      ..add(workItemJson(4, title: 'Invoice export', project: 'Fabrikam'));
    await pumpScreen(tester, projects: ['Contoso', 'Fabrikam']);

    expect(lastQuery(), contains("[System.TeamProject] IN ('Contoso', 'Fabrikam')"));
    expect(find.text('Invoice export'), findsOneWidget);
    // Every card names its project.
    expect(find.text('Contoso'), findsNWidgets(3));
    expect(find.text('Fabrikam'), findsOneWidget);

    await tester.enterText(find.byType(SearchBar), 'fabrikam');
    await tester.pumpAndSettle();
    expect(find.text(en.ticketCount(1)), findsOneWidget);
  });

  testWidgets('has no title, the navigation bar names the screen', (tester) async {
    await pumpScreen(tester);
    expect(find.text(en.tickets), findsNothing);
    // With a single project the cards don't repeat its name either.
    expect(find.text('Contoso'), findsNothing);
    expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
  });

  testWidgets('opens the details on a phone', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Login fails'));
    await tester.pumpAndSettle();
    expect(find.byType(WorkItemDetailScreen), findsOneWidget);
    expect(find.text('Bug 1'), findsWidgets);
  });

  testWidgets('shows the details next to the list on a wide screen', (tester) async {
    await pumpScreen(tester, size: const Size(1200, 900));
    expect(find.text(en.selectTicketTitle), findsOneWidget);

    await tester.tap(find.text('Write docs'));
    await tester.pumpAndSettle();
    expect(find.text(en.selectTicketTitle), findsNothing);
    expect(find.text('Task 2'), findsWidgets);
    expect(tester.widget<WorkItemDetailScreen>(find.byType(WorkItemDetailScreen)).embedded,
        isTrue);
  });

  testWidgets('opens the settings', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.byTooltip(en.settings));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
