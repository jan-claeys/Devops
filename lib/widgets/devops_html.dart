import 'package:flutter/material.dart';

import 'attachments.dart';
import 'work_item_visuals.dart';

/// Renders the HTML that Azure DevOps stores in work item fields and
/// comments as plain text, with its images, such as pasted screenshots.
class DevOpsHtml extends StatelessWidget {
  const DevOpsHtml(this.html, {super.key, this.mentionStyle, this.imageHeaders});

  final String? html;

  /// Style of @mentions; without it they look like the rest of the text.
  final TextStyle? mentionStyle;

  /// Headers to load an image with, to authenticate attachments; see
  /// [InlineImage.headers].
  final Map<String, String>? Function(Uri uri)? imageHeaders;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    final parts = splitHtmlImages(html);
    if (parts.length <= 1) {
      return SelectableText.rich(htmlToSpan(html, style: style, mentionStyle: mentionStyle));
    }
    final children = <Widget>[];
    for (final part in parts) {
      switch (part) {
        case HtmlText(:final html):
          final span = htmlToSpan(html, style: style, mentionStyle: mentionStyle);
          // The HTML around an image may hold no text, such as a closing tag.
          if (span.children?.isNotEmpty ?? false) children.add(SelectableText.rich(span));
        case HtmlImage(:final src, :final alt):
          children.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: InlineImage(src, alt: alt, headers: imageHeaders),
          ));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }
}
