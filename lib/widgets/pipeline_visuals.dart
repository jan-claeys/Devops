import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/pipeline_run.dart';

/// Colors and icons that match the Azure DevOps pipeline statuses.
class RunStatusStyle {
  const RunStatusStyle(this.color, this.icon);

  final Color color;
  final IconData icon;

  static RunStatusStyle of(RunStatus status, ColorScheme scheme) => switch (status) {
        RunStatus.pending => RunStatusStyle(scheme.outline, Icons.radio_button_unchecked),
        RunStatus.queued => RunStatusStyle(scheme.outline, Icons.schedule),
        RunStatus.running => const RunStatusStyle(Color(0xFF007ACC), Icons.play_circle),
        RunStatus.cancelling => RunStatusStyle(scheme.outline, Icons.pending),
        RunStatus.succeeded => const RunStatusStyle(Color(0xFF339933), Icons.check_circle),
        RunStatus.partiallySucceeded => const RunStatusStyle(Color(0xFFFF9D00), Icons.error),
        RunStatus.failed => const RunStatusStyle(Color(0xFFCC293D), Icons.cancel),
        RunStatus.canceled => RunStatusStyle(scheme.outline, Icons.block),
        RunStatus.skipped => RunStatusStyle(scheme.outlineVariant, Icons.do_not_disturb_on),
      };
}

String runStatusLabel(AppLocalizations l10n, RunStatus status) => switch (status) {
      RunStatus.pending => l10n.runPending,
      RunStatus.queued => l10n.runQueued,
      RunStatus.running => l10n.runRunning,
      RunStatus.cancelling => l10n.runCancelling,
      RunStatus.succeeded => l10n.runSucceeded,
      RunStatus.partiallySucceeded => l10n.runPartiallySucceeded,
      RunStatus.failed => l10n.runFailed,
      RunStatus.canceled => l10n.runCanceled,
      RunStatus.skipped => l10n.runSkipped,
    };

/// Status icon in the color of the status.
class RunStatusIcon extends StatelessWidget {
  const RunStatusIcon(this.status, {super.key, this.size = 24});

  final RunStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = RunStatusStyle.of(status, Theme.of(context).colorScheme);
    return Tooltip(
      message: runStatusLabel(context.l10n, status),
      child: Icon(style.icon, color: style.color, size: size),
    );
  }
}

/// Small tonal pill showing the status with its icon.
class RunStatusBadge extends StatelessWidget {
  const RunStatusBadge(this.status, {super.key});

  final RunStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = RunStatusStyle.of(status, scheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, color: style.color, size: 14),
          const SizedBox(width: 6),
          Text(runStatusLabel(context.l10n, status),
              style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

/// A duration as 1:02:03 or 2:03.
String formatDuration(Duration? duration) {
  if (duration == null || duration.isNegative) return '';
  String two(int n) => n.toString().padLeft(2, '0');
  final h = duration.inHours, m = duration.inMinutes % 60, s = duration.inSeconds % 60;
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '$m:${two(s)}';
}
