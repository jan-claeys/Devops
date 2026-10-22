import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n.dart';
import '../models/work_item.dart';

/// Colors and icons that match the Azure DevOps work item types.
class WorkItemTypeStyle {
  const WorkItemTypeStyle(this.color, this.icon);

  final Color color;
  final IconData icon;

  static WorkItemTypeStyle of(String type) => switch (type.toLowerCase()) {
        'bug' => const WorkItemTypeStyle(Color(0xFFCC293D), Icons.bug_report_outlined),
        'task' => const WorkItemTypeStyle(Color(0xFFF2CB1D), Icons.task_alt),
        'user story' => const WorkItemTypeStyle(Color(0xFF009CCC), Icons.menu_book_outlined),
        'product backlog item' =>
          const WorkItemTypeStyle(Color(0xFF009CCC), Icons.list_alt),
        'requirement' => const WorkItemTypeStyle(Color(0xFF009CCC), Icons.assignment_outlined),
        'feature' => const WorkItemTypeStyle(Color(0xFF773B93), Icons.emoji_events_outlined),
        'epic' => const WorkItemTypeStyle(Color(0xFFFF7B00), Icons.bolt),
        'issue' || 'impediment' =>
          const WorkItemTypeStyle(Color(0xFFB4009E), Icons.report_problem_outlined),
        'test case' => const WorkItemTypeStyle(Color(0xFF004B50), Icons.science_outlined),
        _ => const WorkItemTypeStyle(Color(0xFF607D8B), Icons.description_outlined),
      };
}

enum StateCategory { proposed, inProgress, resolved, completed, removed }

StateCategory stateCategory(String state) => switch (state.toLowerCase()) {
      'new' || 'to do' || 'proposed' || 'approved' || 'design' => StateCategory.proposed,
      'resolved' => StateCategory.resolved,
      'closed' || 'done' || 'completed' => StateCategory.completed,
      'removed' || 'cut' => StateCategory.removed,
      _ => StateCategory.inProgress,
    };

/// Small tonal pill showing the state with a colored dot.
class StateBadge extends StatelessWidget {
  const StateBadge(this.state, {super.key});

  final String state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dot = switch (stateCategory(state)) {
      StateCategory.proposed => scheme.outline,
      StateCategory.inProgress => const Color(0xFF007ACC),
      StateCategory.resolved => const Color(0xFFFF9D00),
      StateCategory.completed => const Color(0xFF339933),
      StateCategory.removed => scheme.outlineVariant,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(state, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

/// Rounded square with the work item type icon.
class TypeIcon extends StatelessWidget {
  const TypeIcon(this.type, {super.key, this.size = 40});

  final String type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = WorkItemTypeStyle.of(type);
    return Tooltip(
      message: type,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: style.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Icon(style.icon, color: style.color, size: size * 0.55),
      ),
    );
  }
}

class PersonAvatar extends StatelessWidget {
  const PersonAvatar(this.identity, {super.key, this.radius = 14});

  final Identity? identity;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.secondaryContainer,
      foregroundColor: scheme.onSecondaryContainer,
      child: identity == null
          ? Icon(Icons.person_off_outlined, size: radius)
          : Text(identity!.initials, style: TextStyle(fontSize: radius * 0.75)),
    );
  }
}

String formatRelative(AppLocalizations l10n, DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return l10n.justNow;
  if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
  if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
  if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
  return DateFormat.yMMMd(l10n.localeName).format(date);
}

String formatDateTime(AppLocalizations l10n, DateTime? date) =>
    date == null ? '-' : DateFormat.yMMMd(l10n.localeName).add_Hm().format(date);

/// A size in bytes as B, KB, MB or GB.
String formatFileSize(AppLocalizations l10n, int bytes) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final number = NumberFormat(unit < 2 ? '0' : '0.#', l10n.localeName).format(value);
  return '$number ${units[unit]}';
}

/// Converts the HTML that Azure DevOps stores into readable plain text.
String htmlToText(String? html) {
  if (html == null) return '';
  var text = html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</(p|div|h[1-6]|tr)>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\n• ')
      .replaceAll(RegExp(r'<[^>]+>'), '');
  text = _decodeEntities(text)
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return text.trim();
}

String _decodeEntities(String text) => text
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&amp;', '&');

final _imageTag = RegExp(r'<img\b[^>]*>', caseSensitive: false);

/// Whether a field or comment has nothing to show, as Markdown or as HTML.
bool isBlankContent(String? text, {bool markdown = false}) => markdown
    ? (text?.trim().isEmpty ?? true)
    : htmlToText(text).isEmpty && !_imageTag.hasMatch(text ?? '');

/// A piece of HTML: text, or an image in between.
sealed class HtmlPart {
  const HtmlPart();
}

final class HtmlText extends HtmlPart {
  const HtmlText(this.html);

  final String html;
}

final class HtmlImage extends HtmlPart {
  const HtmlImage(this.src, {this.alt});

  final Uri src;
  final String? alt;
}

/// Splits [html] at its images, such as screenshots pasted into a field.
/// Images without an absolute URL are left out.
List<HtmlPart> splitHtmlImages(String? html) {
  if (html == null) return const [];
  final parts = <HtmlPart>[];
  var start = 0;
  for (final m in _imageTag.allMatches(html)) {
    parts.add(HtmlText(html.substring(start, m.start)));
    final src = Uri.tryParse(_attribute(m[0]!, 'src') ?? '');
    if (src != null && src.hasScheme) parts.add(HtmlImage(src, alt: _attribute(m[0]!, 'alt')));
    start = m.end;
  }
  parts.add(HtmlText(html.substring(start)));
  return parts;
}

/// The value of attribute [name] of an HTML [tag], quoted or not.
String? _attribute(String tag, String name) {
  final m = RegExp('\\s$name\\s*=\\s*(?:"([^"]*)"|\'([^\']*)\'|([^\\s"\'>]+))',
          caseSensitive: false)
      .firstMatch(tag);
  final value = m == null ? null : m[1] ?? m[2] ?? m[3];
  return value == null ? null : _decodeEntities(value);
}

/// Like [htmlToText], but renders @mentions with [mentionStyle].
TextSpan htmlToSpan(String? html, {TextStyle? style, TextStyle? mentionStyle}) {
  const start = '\u0001', end = '\u0002';
  final marked = html?.replaceAllMapped(
    RegExp(r'<a\b[^>]*data-vss-mention[^>]*>(.*?)</a>', caseSensitive: false, dotAll: true),
    (m) => '$start${m[1]}$end',
  );
  final text = htmlToText(marked);
  final children = <TextSpan>[];
  for (final (i, part) in text.split(RegExp('[$start$end]')).indexed) {
    if (part.isEmpty) continue;
    children.add(TextSpan(text: part, style: i.isOdd ? mentionStyle : null));
  }
  return TextSpan(style: style, children: children);
}
