import 'package:devops/l10n/l10n.dart';
import 'package:devops/widgets/devops_markdown.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ));

  /// The text spans that make up [text], to inspect their style and taps.
  Iterable<TextSpan> spans(WidgetTester tester, String text) => tester
      .widgetList<SelectableText>(find.byType(SelectableText))
      .expand((r) {
        final spans = <TextSpan>[];
        r.textSpan!.visitChildren((s) {
          if (s is TextSpan && s.text == text) spans.add(s);
          return true;
        });
        return spans;
      });

  void tapSpan(WidgetTester tester, String text) =>
      (spans(tester, text).single.recognizer! as TapGestureRecognizer).onTap!();

  testWidgets('renders GitHub flavored Markdown', (tester) async {
    await pump(tester, const DevOpsMarkdown('''
# Title

Some **bold** and ~~gone~~ text.

- [x] done
- [ ] todo

| Name | Value |
| ---- | ----- |
| a    | 1     |

```
code()
```
'''));
    expect(find.text('Title'), findsOneWidget);
    expect(spans(tester, 'bold').single.style!.fontWeight, FontWeight.bold);
    expect(spans(tester, 'gone').single.style!.decoration, TextDecoration.lineThrough);
    expect(find.byIcon(Icons.check_box), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    expect(find.byType(Table), findsOneWidget);
    expect(find.text('Value'), findsOneWidget);
    expect(find.text('code()'), findsOneWidget);
  });

  testWidgets('highlights code blocks in a known language', (tester) async {
    await pump(tester, const DevOpsMarkdown('''
```sql
SELECT id FROM WorkItems
```

```cs
var x = 1;
```

```nolanguage
plain text
```
'''));
    final keyword = spans(tester, 'SELECT').single.style!.color;
    expect(keyword, isNotNull);
    expect(spans(tester, 'var').single.style!.color, keyword);
    expect(spans(tester, 'plain text').single.style!.color, isNot(keyword));
    expect(find.textContaining('id FROM', findRichText: true), findsOneWidget);
  });

  testWidgets('shows mentions by name', (tester) async {
    await pump(
      tester,
      const DevOpsMarkdown(
        '@<6F9B0A4C-1111-2222-3333-444455556666> and @<00000000-0000-0000-0000-000000000000>',
        mentions: {'6f9b0a4c-1111-2222-3333-444455556666': 'Jan Claeys'},
      ),
    );
    expect(spans(tester, '@Jan Claeys'), hasLength(1));
    expect(spans(tester, '@${en.unknownPerson}'), hasLength(1));
  });

  testWidgets('opens work item references', (tester) async {
    int? opened;
    await pump(
      tester,
      DevOpsMarkdown('Fixed by #42, not `#7` or a#8.', onOpenWorkItem: (id) => opened = id),
    );
    tapSpan(tester, '#42');
    expect(opened, 42);
    expect(spans(tester, '#7').single.recognizer, isNull);
    expect(find.textContaining('a#8', findRichText: true), findsOneWidget);
  });

  testWidgets('leaves work item references alone without a handler', (tester) async {
    await pump(tester, const DevOpsMarkdown('See #42'));
    expect(spans(tester, '#42'), isEmpty);
    expect(find.textContaining('See #42', findRichText: true), findsOneWidget);
  });

  testWidgets('loads images with the given headers', (tester) async {
    Uri? asked;
    await pump(
      tester,
      DevOpsMarkdown(
        '![shot](https://dev.azure.com/contoso/_apis/wit/attachments/1)',
        imageHeaders: (uri) {
          asked = uri;
          return {'Authorization': 'x'};
        },
      ),
    );
    final image = tester.widget<Image>(find.byType(Image)).image as NetworkImage;
    expect(image.headers, {'Authorization': 'x'});
    expect(asked.toString(), 'https://dev.azure.com/contoso/_apis/wit/attachments/1');
  });

  testWidgets('shows the alt text instead of loading other images', (tester) async {
    await pump(
      tester,
      DevOpsMarkdown('![tracker](https://example.com/pixel.png)', imageHeaders: (_) => null),
    );
    expect(find.byType(Image), findsNothing);
    expect(find.text('tracker'), findsOneWidget);
  });
}
