import 'package:devops/models/work_item.dart';
import 'package:devops/widgets/work_item_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../helpers.dart';

void main() {
  setUpAll(initializeDateFormatting);

  test('stateCategory groups the Azure DevOps states', () {
    expect(stateCategory('New'), StateCategory.proposed);
    expect(stateCategory('To Do'), StateCategory.proposed);
    expect(stateCategory('approved'), StateCategory.proposed);
    expect(stateCategory('Active'), StateCategory.inProgress);
    expect(stateCategory('Committed'), StateCategory.inProgress);
    expect(stateCategory('Resolved'), StateCategory.resolved);
    expect(stateCategory('Closed'), StateCategory.completed);
    expect(stateCategory('DONE'), StateCategory.completed);
    expect(stateCategory('Removed'), StateCategory.removed);
    expect(stateCategory('Cut'), StateCategory.removed);
  });

  test('WorkItemTypeStyle matches types case-insensitively', () {
    expect(WorkItemTypeStyle.of('Bug').icon, Icons.bug_report_outlined);
    expect(WorkItemTypeStyle.of('user story').icon, Icons.menu_book_outlined);
    expect(WorkItemTypeStyle.of('Impediment').icon, WorkItemTypeStyle.of('Issue').icon);
    expect(WorkItemTypeStyle.of('Something else').icon, Icons.description_outlined);
  });

  group('formatRelative', () {
    DateTime ago(Duration d) => DateTime.now().subtract(d);

    test('uses relative units for the last week', () {
      expect(formatRelative(en, null), '');
      expect(formatRelative(en, ago(const Duration(seconds: 20))), en.justNow);
      expect(formatRelative(en, ago(const Duration(minutes: 5))), en.minutesAgo(5));
      expect(formatRelative(en, ago(const Duration(hours: 3))), en.hoursAgo(3));
      expect(formatRelative(en, ago(const Duration(days: 2))), en.daysAgo(2));
    });

    test('shows the date for older items', () {
      final date = DateTime(2020, 5, 17);
      expect(formatRelative(en, date), DateFormat.yMMMd('en').format(date));
    });
  });

  test('formatDateTime', () {
    expect(formatDateTime(en, null), '-');
    expect(formatDateTime(en, DateTime(2026, 1, 2, 14, 5)), 'Jan 2, 2026 14:05');
  });

  group('htmlToText', () {
    test('strips markup', () {
      expect(htmlToText('<div>Hallo&nbsp;<b>wereld</b></div><ul><li>een</li><li>twee</li></ul>'),
          'Hallo wereld\n\n• een\n• twee');
    });

    test('handles null and line breaks', () {
      expect(htmlToText(null), '');
      expect(htmlToText('a<br>b<BR/>c<br />d'), 'a\nb\nc\nd');
      expect(htmlToText('<p>one</p>\n\n\n\n<p>two</p>'), 'one\n\ntwo');
    });

    test('decodes entities, with &amp; last', () {
      expect(htmlToText('&lt;tag&gt; &quot;x&quot; &#39;y&#39; &amp;lt;'), '<tag> "x" \'y\' &lt;');
    });
  });

  test('htmlToSpan highlights mentions', () {
    const mention = TextStyle(fontWeight: FontWeight.bold);
    final span = htmlToSpan(
      '<div>Hi <a href="#" data-vss-mention="version:2.0,1">@Jan Claeys</a>, kijk eens</div>',
      mentionStyle: mention,
    );
    final parts = span.children!.cast<TextSpan>();
    expect(parts.map((p) => p.text), ['Hi ', '@Jan Claeys', ', kijk eens']);
    expect(parts.map((p) => p.style), [null, mention, null]);
    expect(htmlToSpan(null).children, isEmpty);
  });

  group('widgets', () {
    Future<void> pump(WidgetTester tester, Widget child) =>
        tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: child))));

    testWidgets('StateBadge shows the state', (tester) async {
      await pump(tester, const StateBadge('Active'));
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('TypeIcon shows the type icon with a tooltip', (tester) async {
      await pump(tester, const TypeIcon('Bug'));
      expect(find.byIcon(Icons.bug_report_outlined), findsOneWidget);
      expect(find.byTooltip('Bug'), findsOneWidget);
    });

    testWidgets('PersonAvatar shows initials or an empty icon', (tester) async {
      await pump(tester, const PersonAvatar(Identity(displayName: 'Jan Claeys')));
      expect(find.text('JC'), findsOneWidget);
      await pump(tester, const PersonAvatar(null));
      expect(find.byIcon(Icons.person_off_outlined), findsOneWidget);
    });
  });
}
