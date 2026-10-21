import 'work_item.dart';

/// Combined status and result of a pipeline run or of a step in it.
enum RunStatus {
  pending,
  queued,
  running,
  cancelling,
  succeeded,
  partiallySucceeded,
  failed,
  canceled,
  skipped;

  bool get isFinished => index >= succeeded.index;

  static RunStatus _fromResult(String? result) => switch (result) {
        'succeeded' => succeeded,
        'partiallySucceeded' || 'succeededWithIssues' => partiallySucceeded,
        'failed' || 'abandoned' => failed,
        'canceled' => canceled,
        'skipped' => skipped,
        _ => succeeded,
      };
}

/// A run of a pipeline (a "build" in the Azure DevOps REST API).
class PipelineRun {
  const PipelineRun({
    required this.id,
    required this.buildNumber,
    required this.status,
    required this.pipelineName,
    required this.project,
    this.sourceBranch,
    this.requestedFor,
    this.queueTime,
    this.startTime,
    this.finishTime,
  });

  final int id;
  final String buildNumber;
  final RunStatus status;
  final String pipelineName;
  final String project;
  final String? sourceBranch;
  final Identity? requestedFor;
  final DateTime? queueTime;
  final DateTime? startTime;
  final DateTime? finishTime;

  factory PipelineRun.fromJson(Map<String, dynamic> json) => PipelineRun(
        id: json['id'] as int,
        buildNumber: json['buildNumber'] as String? ?? '${json['id']}',
        status: switch (json['status']) {
          'completed' => RunStatus._fromResult(json['result'] as String?),
          'inProgress' => RunStatus.running,
          'cancelling' => RunStatus.cancelling,
          _ => RunStatus.queued,
        },
        pipelineName: (json['definition'] as Map?)?['name'] as String? ?? '',
        project: (json['project'] as Map?)?['name'] as String? ?? '',
        sourceBranch: json['sourceBranch'] as String?,
        requestedFor: Identity.fromJson(json['requestedFor']),
        queueTime: _date(json['queueTime']),
        startTime: _date(json['startTime']),
        finishTime: _date(json['finishTime']),
      );

  /// The branch without its refs/heads/ prefix.
  String? get branch => sourceBranch?.replaceFirst(RegExp('^refs/heads/'), '');

  /// How long the run took, or has been running so far.
  Duration? duration([DateTime? now]) {
    final start = startTime;
    if (start == null) return null;
    return (finishTime ?? now ?? DateTime.now()).difference(start);
  }
}

/// A stage, job or task in the timeline of a [PipelineRun].
class TimelineRecord {
  const TimelineRecord({
    required this.id,
    required this.type,
    required this.name,
    required this.status,
    this.parentId,
    this.order = 0,
    this.startTime,
    this.finishTime,
    this.errorCount = 0,
    this.warningCount = 0,
  });

  final String id;
  final String? parentId;
  final String type;
  final String name;
  final RunStatus status;
  final int order;
  final DateTime? startTime;
  final DateTime? finishTime;
  final int errorCount;
  final int warningCount;

  bool get isTask => type == 'Task';

  factory TimelineRecord.fromJson(Map<String, dynamic> json) => TimelineRecord(
        id: json['id'] as String,
        parentId: json['parentId'] as String?,
        type: json['type'] as String? ?? '',
        name: json['name'] as String? ?? '',
        status: switch (json['state']) {
          'completed' => RunStatus._fromResult(json['result'] as String?),
          'inProgress' => RunStatus.running,
          _ => RunStatus.pending,
        },
        order: (json['order'] as num?)?.toInt() ?? 0,
        startTime: _date(json['startTime']),
        finishTime: _date(json['finishTime']),
        errorCount: (json['errorCount'] as num?)?.toInt() ?? 0,
        warningCount: (json['warningCount'] as num?)?.toInt() ?? 0,
      );
}

/// The stages, jobs and tasks of a run, as a tree.
class Timeline {
  Timeline(List<TimelineRecord> records) {
    final ids = {for (final r in records) r.id};
    for (final r in records) {
      final parent = ids.contains(r.parentId) ? r.parentId : null;
      (_children[parent] ??= []).add(r);
    }
    for (final list in _children.values) {
      list.sort((a, b) => a.order.compareTo(b.order));
    }
    tasks = records.where((r) => r.isTask).toList();
  }

  final _children = <String?, List<TimelineRecord>>{};
  late final List<TimelineRecord> tasks;

  List<TimelineRecord> get roots => children(null);

  /// Phases are left out, their jobs take their place; checkpoints such as
  /// approvals are left out altogether.
  List<TimelineRecord> children(String? id) => [
        for (final r in _children[id] ?? const <TimelineRecord>[])
          if (r.type == 'Phase')
            ...children(r.id)
          else if (!r.type.startsWith('Checkpoint'))
            r,
      ];

  int get finishedTasks => tasks.where((t) => t.status.isFinished).length;

  /// Share of the tasks that finished, or null before the tasks are known.
  double? get progress => tasks.isEmpty ? null : finishedTasks / tasks.length;
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;
