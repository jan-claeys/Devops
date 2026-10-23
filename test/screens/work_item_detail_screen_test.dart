import 'package:devops/screens/work_item_detail_screen.dart';
import 'package:flutter/gestures.dart';
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
      ..add(
        workItemJson(
          10,
          title: 'Login fails on Android',
          type: 'Bug',
          state: 'Active',
          fields: {
            'System.Reason': 'Investigating',
            'System.Tags': 'auth; mobile',
            'System.AssignedTo': {'displayName': 'Jan Claeys'},
            'System.CreatedBy': {'displayName': 'Piet Peeters'},
            'System.AreaPath': 'Contoso\\Mobile',
            'System.IterationPath': 'Contoso\\Sprint 4',
            'Microsoft.VSTS.Common.Priority': 2,
            'Microsoft.VSTS.Scheduling.StoryPoints': 3,
            'Microsoft.VSTS.Scheduling.RemainingWork': 4,
            'Microsoft.VSTS.TCM.ReproSteps': '<ol><li>Open app</li><li>Log in</li></ol>',
            'System.Description': '<p>   </p>',
          },
          relations: [
            relation('System.LinkTypes.Hierarchy-Reverse', 1),
            relation('System.LinkTypes.Hierarchy-Forward', 11),
          ],
        ),
      )
      ..add(workItemJson(1, title: 'Authentication', type: 'Feature', state: 'New'))
      ..add(workItemJson(11, title: 'Add logging', type: 'Task', state: 'Closed'));
    fake.comments[10] = [
      {
        'text': '<div><a data-vss-mention="x">@Jan Claeys</a> can you check?</div>',
        'createdBy': {'displayName': 'Piet Peeters'},
        'createdDate': DateTime.now().toUtc().toIso8601String(),
      },
    ];
  });

  Future<void> pumpDetail(
    WidgetTester tester, {
    int id = 10,
    ValueChanged<int>? onOpen,
    Size size = const Size(500, 3000),
  }) async {
    await pumpApp(
      tester,
      WorkItemDetailScreen(id: id, onOpenWorkItem: onOpen),
      state: connectedState(fake),
      size: size,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the work item', (tester) async {
    await pumpDetail(tester);

    expect(find.text('Bug 10'), findsWidgets);
    expect(find.text('Login fails on Android'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Investigating'), findsOneWidget);
    expect(find.widgetWithText(Chip, 'auth'), findsOneWidget);
    expect(find.widgetWithText(Chip, 'mobile'), findsOneWidget);
    expect(find.text('Jan Claeys'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text(en.hours('4')), findsOneWidget);
    expect(find.text(en.originalEstimate), findsNothing);
    expect(find.text('Contoso\\Mobile'), findsOneWidget);
    expect(find.text('Contoso\\Sprint 4'), findsOneWidget);
    expect(find.textContaining('Piet Peeters'), findsWidgets);
    expect(find.text(en.openInDevOps), findsOneWidget);
  });

  testWidgets('shows only sections with content', (tester) async {
    await pumpDetail(tester);
    expect(find.text(en.reproSteps), findsOneWidget);
    expect(find.text('• Open app\n• Log in'), findsOneWidget);
    expect(find.text(en.description), findsNothing);
    expect(find.text(en.acceptanceCriteria), findsNothing);
  });

  testWidgets('always shows the bug fields', (tester) async {
    fake.items[10]!['fields']['Microsoft.VSTS.CMMI.Symptom'] = '<div>Lots not selected</div>';
    await pumpDetail(tester);
    expect(find.text(en.symptom), findsOneWidget);
    expect(find.text('Lots not selected'), findsOneWidget);
    expect(find.text(en.systemInfo), findsOneWidget);
    expect(find.text(en.proposedFix), findsOneWidget);
    expect(find.text(en.emptyField), findsNWidgets(2));
  });

  testWidgets('hides bug fields for other types', (tester) async {
    fake.add(workItemJson(20, title: 'Story', type: 'User Story'));
    await pumpDetail(tester, id: 20);
    expect(find.text(en.reproSteps), findsNothing);
    expect(find.text(en.symptom), findsNothing);
    expect(find.text(en.emptyField), findsNothing);
  });

  testWidgets('shows linked items', (tester) async {
    await pumpDetail(tester);
    expect(find.text(en.linkedItems), findsOneWidget);
    expect(find.text('Authentication'), findsOneWidget);
    expect(find.text('${en.parent} · #1 · New'), findsOneWidget);
    expect(find.text('Add logging'), findsOneWidget);
    expect(find.text('${en.child} · #11 · Closed'), findsOneWidget);
  });

  testWidgets('shows comments with mentions', (tester) async {
    await pumpDetail(tester);
    expect(find.text(en.commentsCount(1)), findsOneWidget);
    expect(find.textContaining('can you check?', findRichText: true), findsOneWidget);
    expect(find.textContaining(en.justNow, findRichText: true), findsOneWidget);
  });

  testWidgets('renders Markdown fields and comments', (tester) async {
    fake.add(workItemJson(20, title: 'Story', type: 'User Story', fields: {
      'System.Description': 'Needs **bold** work, see #10',
    })
      ..['multilineFieldsFormat'] = {'System.Description': 'markdown'});
    fake.comments[20] = [
      {
        'text': '@<6f9b0a4c-1111-2222-3333-444455556666> done in `main`',
        'format': 'markdown',
        'renderedText': '<a data-vss-mention="version:2.0,6f9b0a4c-1111-2222-3333-444455556666">'
            '@Jan Claeys</a> done',
      },
    ];
    int? opened;
    await pumpDetail(tester, id: 20, onOpen: (id) => opened = id);

    expect(find.text(en.description), findsOneWidget);
    expect(find.textContaining('**', findRichText: true), findsNothing);
    expect(find.textContaining('Needs bold work', findRichText: true), findsOneWidget);
    expect(find.textContaining('@Jan Claeys done in main', findRichText: true), findsOneWidget);

    final link = tester
        .widgetList<SelectableText>(find.byType(SelectableText))
        .map((t) => t.textSpan?.children ?? const <InlineSpan>[])
        .expand((spans) => spans)
        .whereType<TextSpan>()
        .singleWhere((span) => span.text == '#10');
    (link.recognizer! as TapGestureRecognizer).onTap!();
    expect(opened, 10);
  });

  testWidgets('works without comments or links', (tester) async {
    fake.add(workItemJson(20, title: 'Lonely'));
    await pumpDetail(tester, id: 20);
    expect(find.text(en.commentsCount(0)), findsOneWidget);
    expect(find.text(en.noComments), findsOneWidget);
    expect(find.text(en.linkedItems), findsNothing);
    expect(find.text(en.unassigned), findsOneWidget);
  });

  testWidgets('still shows the item when comments fail', (tester) async {
    fake
      ..failWith = 500
      ..failPath = '/comments';
    await pumpDetail(tester);
    expect(find.text('Login fails on Android'), findsOneWidget);
    expect(find.text(en.noComments), findsOneWidget);
  });

  testWidgets('opens linked items through the callback', (tester) async {
    int? opened;
    await pumpDetail(tester, onOpen: (id) => opened = id);
    await tester.tap(find.text('Add logging'));
    expect(opened, 11);
  });

  testWidgets('opens linked items as a new page by default', (tester) async {
    await pumpDetail(tester);
    await tester.tap(find.text('Authentication'));
    await tester.pumpAndSettle();
    expect(find.text('Feature 1'), findsWidgets);
  });

  for (final (name, size) in [
    ('long', const Size(500, 700)),
    ('short', const Size(500, 3000)),
  ]) {
    testWidgets('pull to refresh reloads $name content', (tester) async {
      await pumpDetail(tester, size: size);
      fake.items[10]!['fields']['System.Title'] = 'Renamed';
      await tester.fling(find.text('Login fails on Android'), Offset(0, size.height / 2), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Renamed'), findsOneWidget);
    });
  }

  testWidgets('shows errors and retries', (tester) async {
    await pumpDetail(tester, id: 99);
    expect(find.text('#99'), findsWidgets);
    expect(find.text(en.errorNotFound), findsOneWidget);
    expect(find.text(en.openInDevOps), findsNothing);

    fake.add(workItemJson(99, title: 'Found it'));
    await tester.tap(find.text(en.retry));
    await tester.pumpAndSettle();
    expect(find.text('Found it'), findsOneWidget);
  });

  group('images in HTML', () {
    const pasted = 'https://dev.azure.com/contoso/1/_apis/wit/attachments/g1?fileName=shot.png';

    setUp(() {
      fake.add(workItemJson(13, type: 'Task', fields: {
        'System.Description': '<div>Look here:</div><div><img src="$pasted" alt=Image></div>'
            '<div>and <img src="https://tracker.test/pixel.gif" alt="tracker"></div>',
      }));
      fake.comments[13] = [
        {
          'text': '<p>Again: <img src="$pasted"></p>',
          'createdBy': {'displayName': 'Piet Peeters'},
          'createdDate': DateTime.now().toUtc().toIso8601String(),
        },
      ];
    });

    NetworkImage network(Image image) => (image.image as ResizeImage).imageProvider as NetworkImage;

    testWidgets('loads images of the organization with the token', (tester) async {
      await pumpDetail(tester, id: 13);
      expect(find.text('Look here:'), findsOneWidget);
      final images = tester.widgetList<Image>(find.byType(Image)).map(network).toList();
      expect(images.map((i) => i.url), [pasted, pasted]);
      expect(images.first.headers?['Authorization'], startsWith('Basic '));
      // Any other image could tell its server who opened the item.
      expect(find.text('tracker'), findsOneWidget);
    });

    testWidgets('shows a field with only an image', (tester) async {
      fake.items[13]!['fields']['System.Description'] = '<div><img src="$pasted"></div>';
      await pumpDetail(tester, id: 13);
      expect(find.text(en.description), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(2));
    });

    testWidgets('opens an image full screen', (tester) async {
      await pumpDetail(tester, id: 13);
      await tester.tap(find.byType(Image).first);
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.text('shot.png'), findsOneWidget);
    });
  });

  group('attachments', () {
    setUp(() {
      (fake.items[10]!['relations'] as List).addAll(<Map<String, dynamic>>[
        attachmentRelation('screenshot.png', id: 'img', size: 2048, comment: 'Login screen'),
        attachmentRelation('crash.mp4', id: 'vid', size: 300 * 1024 * 1024),
      ]);
    });

    testWidgets('lists the attached files', (tester) async {
      await pumpDetail(tester);
      expect(find.text(en.attachmentsCount(2)), findsOneWidget);
      expect(find.text('screenshot.png'), findsOneWidget);
      expect(find.textContaining('2 KB'), findsOneWidget);
      expect(find.text('Login screen'), findsOneWidget);
      expect(find.text('crash.mp4'), findsOneWidget);
      expect(find.textContaining('300 MB'), findsOneWidget);
    });

    testWidgets('opens images in the app', (tester) async {
      await pumpDetail(tester);
      await tester.tap(find.text('screenshot.png'));
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byTooltip(en.openFile), findsOneWidget);
    });

    testWidgets('asks before downloading a large file', (tester) async {
      await pumpDetail(tester);
      fake.requests.clear();
      await tester.tap(find.text('crash.mp4'));
      await tester.pumpAndSettle();
      expect(find.text(en.downloadLargeTitle), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text(en.downloadLargeTitle), findsNothing);
      expect(fake.requests, isEmpty);
    });

    testWidgets('has no section without attachments', (tester) async {
      fake.add(workItemJson(12));
      await pumpDetail(tester, id: 12);
      expect(find.textContaining('Attachments'), findsNothing);
    });
  });
}
