import 'pipeline_run.dart';

/// A pipeline by kind, project and definition id, with the name of a stage
/// for a release.
typedef _DurationKey = (RunKind, String, int, String?);

/// When a running build or release stage started and how long it is
/// expected to take.
typedef RunEstimate = ({DateTime start, Duration expected});

/// How long running builds and releases are expected to take, from how long
/// the last successful build of each pipeline, or deployment of each release
/// stage, took.
class RunEstimates {
  /// From [runs], which are sorted newest first.
  RunEstimates(List<PipelineRun> runs) : _lastDurations = _durations(runs);

  final Map<_DurationKey, Duration> _lastDurations;

  /// The duration of the newest successful build of each pipeline, and of
  /// the newest successful deployment of each release stage, in [runs].
  static Map<_DurationKey, Duration> _durations(List<PipelineRun> runs) {
    final durations = <_DurationKey, Duration>{};
    for (final r in runs) {
      final definition = r.definitionId;
      if (definition == null) continue;
      if (r.isRelease) {
        for (final s in r.stages) {
          final (start, finish) = (s.startTime, s.finishTime);
          if (s.status != RunStatus.succeeded || start == null || finish == null) continue;
          durations.putIfAbsent(
              (r.kind, r.project, definition, s.name), () => finish.difference(start));
        }
      } else if (r.status == RunStatus.succeeded && r.finishTime != null) {
        durations.putIfAbsent((r.kind, r.project, definition, null), () => r.duration()!);
      }
    }
    return durations;
  }

  /// When the running build, or each running stage of a release, started
  /// and how long it is expected to take; null when one of them can't be
  /// estimated.
  List<RunEstimate>? of(PipelineRun run) {
    final definition = run.definitionId;
    if (definition == null) return null;
    final parts = run.isRelease
        ? [
            for (final s in run.stages)
              if (s.status == RunStatus.running)
                (s.startTime, _lastDurations[(run.kind, run.project, definition, s.name)]),
          ]
        : [(run.startTime, _lastDurations[(run.kind, run.project, definition, null)])];
    final estimate = <RunEstimate>[
      for (final (start, expected) in parts)
        if (start != null && expected != null) (start: start, expected: expected),
    ];
    return estimate.isEmpty || estimate.length < parts.length ? null : estimate;
  }
}
