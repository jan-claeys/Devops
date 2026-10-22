import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/pipeline_log.dart';
import '../models/pipeline_run.dart';
import '../models/run_estimates.dart';

/// Colors and icons that match the Azure DevOps pipeline statuses.
class RunStatusStyle {
  const RunStatusStyle(this.color, this.icon);

  final Color color;
  final IconData icon;

  static RunStatusStyle of(RunStatus status, ColorScheme scheme) => switch (status) {
        RunStatus.pending => RunStatusStyle(scheme.outline, Icons.radio_button_unchecked),
        RunStatus.queued => RunStatusStyle(scheme.outline, Icons.schedule),
        RunStatus.running => const RunStatusStyle(Color(0xFF007ACC), Icons.play_circle),
        RunStatus.waitingForApproval =>
          const RunStatusStyle(Color(0xFF007ACC), Icons.pending_actions),
        RunStatus.cancelling => RunStatusStyle(scheme.outline, Icons.pending),
        RunStatus.succeeded => const RunStatusStyle(Color(0xFF339933), Icons.check_circle),
        RunStatus.partiallySucceeded => const RunStatusStyle(Color(0xFFFF9D00), Icons.error),
        RunStatus.failed => const RunStatusStyle(Color(0xFFCC293D), Icons.cancel),
        RunStatus.canceled => RunStatusStyle(scheme.outline, Icons.block),
        RunStatus.skipped => RunStatusStyle(scheme.outlineVariant, Icons.do_not_disturb_on),
        RunStatus.notDeployed => RunStatusStyle(scheme.outline, Icons.radio_button_unchecked),
      };
}

String runStatusLabel(AppLocalizations l10n, RunStatus status) => switch (status) {
      RunStatus.pending => l10n.runPending,
      RunStatus.queued => l10n.runQueued,
      RunStatus.running => l10n.runRunning,
      RunStatus.waitingForApproval => l10n.runWaitingForApproval,
      RunStatus.cancelling => l10n.runCancelling,
      RunStatus.succeeded => l10n.runSucceeded,
      RunStatus.partiallySucceeded => l10n.runPartiallySucceeded,
      RunStatus.failed => l10n.runFailed,
      RunStatus.canceled => l10n.runCanceled,
      RunStatus.skipped => l10n.runSkipped,
      RunStatus.notDeployed => l10n.runNotDeployed,
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
          Flexible(
            child: Text(runStatusLabel(context.l10n, status),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium),
          ),
        ],
      ),
    );
  }
}

/// Small pill per release stage, like the stages column in Azure DevOps.
class StageChips extends StatelessWidget {
  const StageChips(this.stages, {super.key});

  final List<StageSummary> stages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final stage in stages)
          Tooltip(
            message: runStatusLabel(context.l10n, stage.status),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: scheme.outlineVariant),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(RunStatusStyle.of(stage.status, scheme).icon,
                      color: RunStatusStyle.of(stage.status, scheme).color, size: 12),
                  const SizedBox(width: 4),
                  Text(stage.name, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          ),
      ],
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

/// A line of a log in a monospaced font, colored by its kind.
class LogLineView extends StatelessWidget {
  const LogLineView(this.line, {super.key, this.highlighted = false, this.maxLines});

  final LogLine line;

  /// Marks the error that was jumped to.
  final bool highlighted;

  /// Cuts the line off with an ellipsis after this many lines.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (color, background) = switch (line.kind) {
      LogLineKind.error => (scheme.onErrorContainer, scheme.errorContainer),
      LogLineKind.warning => (const Color(0xFFFF9D00), null),
      LogLineKind.section => (scheme.primary, null),
      LogLineKind.command => (scheme.onSurfaceVariant, null),
      LogLineKind.plain => (null, null),
    };
    return Container(
      decoration: BoxDecoration(
        color: background,
        border: highlighted ? Border(left: BorderSide(color: scheme.error, width: 3)) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: Text(
        line.text,
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          fontFamilyFallback: const ['Consolas', 'Menlo', 'Courier New'],
          color: color,
          fontWeight: line.kind == LogLineKind.section || highlighted ? FontWeight.bold : null,
        ),
      ),
    );
  }
}

/// The share of the expected time that has passed, updated every second.
/// Stops just short of full, as a run can take longer than the last one.
class EstimatedProgress extends StatefulWidget {
  const EstimatedProgress({super.key, required this.status, required this.estimate});

  final RunStatus status;
  final List<RunEstimate> estimate;

  @override
  State<EstimatedProgress> createState() => _EstimatedProgressState();
}

class _EstimatedProgressState extends State<EstimatedProgress> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    var elapsed = 0, expected = 0;
    for (final e in widget.estimate) {
      elapsed += now.difference(e.start).inMilliseconds;
      expected += e.expected.inMilliseconds;
    }
    final progress = expected <= 0 ? 0.99 : (elapsed / expected).clamp(0.0, 0.99);
    return LinearProgressIndicator(
      value: progress,
      minHeight: 4,
      color: RunStatusStyle.of(widget.status, Theme.of(context).colorScheme).color,
    );
  }
}
