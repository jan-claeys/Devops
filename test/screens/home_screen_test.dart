import 'package:devops/screens/home_screen.dart';
import 'package:devops/services/shortcuts.dart';
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
      ..addRun(runJson(1, pipeline: 'Nightly'))
      ..addRun(runJson(2, pipeline: 'Deploy', status: 'inProgress', result: null, finishTime: null))
      ..addPullRequest(pullRequestJson(11, title: 'Fix login', reviewers: [('Me', 0)]))
      ..addPullRequest(pullRequestJson(12, title: 'Someone else'));
  });

  test('recognizes the links of the app shortcuts', () {
    expect(AppShortcut.fromUri(Uri.parse('devops://shortcut/active-runs')), AppShortcut.activeRuns);
    expect(AppShortcut.fromUri(Uri.parse('devops://shortcut/search')), AppShortcut.search);
    expect(AppShortcut.fromUri(Uri.parse('devops://pipelines')), isNull);
    expect(AppShortcut.fromUri(null), isNull);
  });

  Future<HomeScreenState> pumpHome(WidgetTester tester) async {
    await pumpApp(tester, const HomeScreen(), state: connectedState(fake));
    await tester.pumpAndSettle();
    return tester.state<HomeScreenState>(find.byType(HomeScreen));
  }

  NavigationBar bar(WidgetTester tester) => tester.widget(find.byType(NavigationBar));

  /// Stops the refresh of the running run.
  Future<void> close(WidgetTester tester) => tester.pumpWidget(const SizedBox());

  testWidgets('shows the active runs', (tester) async {
    final home = await pumpHome(tester);
    home.showShortcut(AppShortcut.activeRuns);
    await tester.pumpAndSettle();
    expect(bar(tester).selectedIndex, 3);
    expect(tester.widget<FilterChip>(find.widgetWithText(FilterChip, en.activeOnly)).selected,
        isTrue);
    expect(find.text('Deploy'), findsOneWidget);
    expect(find.text('Nightly'), findsNothing);
    await close(tester);
  });

  testWidgets('shows my open pull requests', (tester) async {
    final home = await pumpHome(tester);
    home.showShortcut(AppShortcut.myPullRequests);
    await tester.pumpAndSettle();
    expect(bar(tester).selectedIndex, 2);
    expect(find.text('Fix login'), findsOneWidget);
    expect(find.text('Someone else'), findsNothing);
    await close(tester);
  });

  testWidgets('puts the cursor in the search field of the tickets', (tester) async {
    final home = await pumpHome(tester);
    home.showShortcut(AppShortcut.search);
    await tester.pumpAndSettle();
    expect(bar(tester).selectedIndex, 1);
    final field = tester.widget<EditableText>(find.descendant(
        of: find.widgetWithText(SearchBar, en.searchTicketsHint),
        matching: find.byType(EditableText)));
    expect(field.focusNode.hasFocus, isTrue);
    await close(tester);
  });
}
