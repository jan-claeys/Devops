import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:re_highlight/languages/all.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n.dart';

/// Renders the Markdown that Azure DevOps stores in work item fields and
/// comments, including GitHub flavored tables, task lists, strikethrough and
/// syntax highlighted code blocks.
class DevOpsMarkdown extends StatelessWidget {
  const DevOpsMarkdown(
    this.data, {
    super.key,
    this.mentions = const {},
    this.onOpenWorkItem,
    this.imageHeaders,
  });

  final String data;

  /// Display names of people mentioned as `@<guid>`, keyed by lowercase guid.
  final Map<String, String> mentions;

  /// Opens `#123` work item references. Without it they stay plain text.
  final ValueChanged<int>? onOpenWorkItem;

  /// Headers to load an image with, to authenticate attachments. Only images
  /// it returns headers for are loaded: any other image could tell its server
  /// who opened the item and when. Those show their alt text instead.
  final Map<String, String>? Function(Uri uri)? imageHeaders;

  /// Schemes a link may open. Anyone who can edit an item can write a link,
  /// so others such as file: or a custom protocol handler are ignored.
  static const _linkSchemes = {'https', 'http', 'mailto'};

  Future<void> _openLink(BuildContext context, String? href) async {
    final uri = href == null ? null : Uri.tryParse(href);
    if (uri == null || uri.scheme == _MentionSyntax.scheme) return;
    if (uri.scheme == _WorkItemSyntax.scheme) {
      onOpenWorkItem?.call(int.parse(uri.path));
      return;
    }
    if (!_linkSchemes.contains(uri.scheme.toLowerCase())) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.browserOpenFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final body = theme.textTheme.bodyMedium;
    final code = body?.copyWith(
      fontFamily: 'monospace',
      fontSize: (body.fontSize ?? 14) * 0.9,
      backgroundColor: scheme.surfaceContainerHighest,
    );
    final styleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
        p: body,
        listBullet: body,
        tableBody: body,
        a: TextStyle(color: scheme.primary),
        code: code,
        codeblockPadding: const EdgeInsets.all(12),
        codeblockDecoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        blockquotePadding: const EdgeInsets.only(left: 12),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: scheme.outlineVariant, width: 4)),
        ),
        tableBorder: TableBorder.all(color: scheme.outlineVariant),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
      );
    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: styleSheet,
      builders: {'code': _CodeBlockBuilder(styleSheet.codeblockPadding)},
      inlineSyntaxes: [
        _MentionSyntax(mentions, context.l10n.unknownPerson),
        if (onOpenWorkItem != null) _WorkItemSyntax(),
      ],
      onTapLink: (text, href, title) => _openLink(context, href),
      imageBuilder: (uri, title, alt) {
        final placeholder =
            Text(alt ?? uri.toString(), style: body?.copyWith(color: scheme.onSurfaceVariant));
        final headers = imageHeaders?.call(uri);
        if (headers == null) return placeholder;
        return Image.network(
          uri.toString(),
          headers: headers,
          semanticLabel: alt,
          errorBuilder: (context, error, stackTrace) => placeholder,
        );
      },
    );
  }
}

/// Highlights fenced code blocks that name a language, like ```sql.
/// Inline code and blocks in an unknown language keep the default rendering.
class _CodeBlockBuilder extends MarkdownElementBuilder {
  _CodeBlockBuilder(this.padding);

  final EdgeInsets? padding;

  static final _highlight = Highlight()..registerLanguages(builtinAllLanguages);

  /// The highlight.js themes without their own background, so the code
  /// block keeps the app's colors.
  static final _lightTheme = _withoutBackground(atomOneLightTheme);
  static final _darkTheme = _withoutBackground(atomOneDarkTheme);

  static Map<String, TextStyle> _withoutBackground(Map<String, TextStyle> theme) =>
      {...theme, 'root': TextStyle(color: theme['root']?.color)};

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final language = element.attributes['class']?.replaceFirst('language-', '').toLowerCase();
    if (language == null || _highlight.getLanguage(language) == null) return null;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final renderer = TextSpanRenderer(preferredStyle, dark ? _darkTheme : _lightTheme);
    _highlight
        .highlight(code: element.textContent.replaceFirst(RegExp(r'\n$'), ''), language: language)
        .render(renderer);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: SelectableText.rich(renderer.span ?? TextSpan(text: element.textContent)),
    );
  }
}

/// `@<guid>`: a person mentioned in a Markdown comment.
class _MentionSyntax extends md.InlineSyntax {
  _MentionSyntax(this.names, this.unknown)
      : super(r'@<([0-9a-fA-F-]{36})>', startCharacter: 0x40);

  static const scheme = 'mention';

  final Map<String, String> names;
  final String unknown;

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final guid = match[1]!.toLowerCase();
    parser.addNode(md.Element.text('a', '@${names[guid] ?? unknown}')
      ..attributes['href'] = '$scheme:$guid');
    return true;
  }
}

/// `#123`: a reference to another work item.
class _WorkItemSyntax extends md.InlineSyntax {
  _WorkItemSyntax() : super(r'(?<![\w#&/])#(\d+)\b', startCharacter: 0x23);

  static const scheme = 'workitem';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('a', match[0]!)..attributes['href'] = '$scheme:${match[1]}');
    return true;
  }
}
