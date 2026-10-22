import 'package:flutter/material.dart';

/// Outlined card with an optional title, for a section of a detail screen;
/// [filled] like the cards in the lists.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.title,
    this.padding,
    this.color,
    this.filled = false,
  });

  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  /// Background of the card, to make it stand out.
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
          ],
          Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ],
      ),
    );
    return filled
        ? Card.filled(color: color ?? theme.colorScheme.surfaceContainerLow, child: content)
        : Card.outlined(color: color, child: content);
  }
}

/// Icon, label and value on one line.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.label, this.value, this.valueWidget});

  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(child: valueWidget ?? Text(value ?? '-', style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
