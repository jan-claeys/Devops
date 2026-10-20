import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

String formatRelative(DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'zojuist';
  if (diff.inHours < 1) return '${diff.inMinutes} min geleden';
  if (diff.inDays < 1) return '${diff.inHours} u geleden';
  if (diff.inDays < 7) return '${diff.inDays} d geleden';
  return DateFormat('d MMM yyyy', 'nl').format(date);
}

String formatDateTime(DateTime? date) =>
    date == null ? '-' : DateFormat('d MMM yyyy, HH:mm', 'nl').format(date);

/// Converts the HTML that Azure DevOps stores into readable plain text.
String htmlToText(String? html) {
  if (html == null) return '';
  var text = html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</(p|div|h[1-6]|tr)>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\n• ')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&amp;', '&');
  text = text.replaceAll(RegExp(r'[ \t]+\n'), '\n').replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return text.trim();
}
