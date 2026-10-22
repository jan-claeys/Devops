import 'work_item.dart';

/// Combined status and result of a pipeline run or of a step in it.
enum RunStatus {
  pending,
  queued,
  running,
  waitingForApproval,
  cancelling,
  succeeded,
  partiallySucceeded,
  failed,
  canceled,
  skipped,

  /// A release stage that hasn't been deployed (yet).
  notDeployed;

  bool get isFinished => index >= succeeded.index;

  static RunStatus _fromResult(String? result) => switch (result) {
        'succeeded' => succeeded,
        'partiallySucceeded' || 'succeededWithIssues' => partiallySucceeded,
        'failed' || 'abandoned' => failed,
        'canceled' => canceled,
        'skipped' => skipped,
        _ => succeeded,
      };

  /// The statuses of release environments, phases, jobs and tasks.
  static RunStatus _fromRelease(String? status) => switch (status) {
        'queued' || 'scheduled' => queued,
        'inProgress' => running,
        'cancelling' => cancelling,
        'succeeded' || 'success' => succeeded,
        'partiallySucceeded' => partiallySucceeded,
        'failed' || 'failure' || 'rejected' => failed,
        'canceled' => canceled,
        'skipped' => skipped,
        _ => pending,
      };
}

/// Builds come from pipelines (YAML or classic builds), releases from
/// classic release pipelines.
enum RunKind { build, release }

/// A stage of a release with its status, as shown in the list of runs.
typedef StageSummary = ({
  String name,
  RunStatus status,
  DateTime? startTime,
  DateTime? finishTime,
});

/// An error or warning logged by a step of a run, or found while validating
/// the pipeline before the run started.
typedef RunIssue = ({bool isError, String message});

List<RunIssue> _issues(Object? json, String typeKey) => [
      for (final issue in ((json as List?) ?? const []).cast<Map<String, dynamic>>())
        if (issue['message'] case final String message when message.trim().isNotEmpty)
          (
            isError: '${issue[typeKey]}'.toLowerCase() == 'error',
            message: message.trim(),
          ),
    ];

/// A run of a pipeline: a build, or a release of a classic release pipeline.
class PipelineRun {
  const PipelineRun({
    required this.id,
    required this.buildNumber,
    required this.status,
    required this.pipelineName,
    required this.project,
    this.kind = RunKind.build,
    this.definitionId,
    this.sourceBranch,
    this.requestedFor,
    this.queueTime,
    this.startTime,
    this.finishTime,
    this.artifactVersion,
    this.stages = const [],
    this.webUrl,
    this.issues = const [],
  });

  final int id;

  /// The build number, or the name of a release.
  final String buildNumber;
  final RunStatus status;
  final String pipelineName;
  final String project;
  final RunKind kind;

  /// The pipeline the run belongs to, within its [project].
  final int? definitionId;
  final String? sourceBranch;
  final Identity? requestedFor;

  /// When a build was queued or a release was created.
  final DateTime? queueTime;
  final DateTime? startTime;
  final DateTime? finishTime;

  /// The version of the primary artifact of a release.
  final String? artifactVersion;

  /// The stages of a release.
  final List<StageSummary> stages;

  /// Link to the run in Azure DevOps, when the API returns one.
  final String? webUrl;

  /// Problems with the pipeline itself, such as an invalid YAML file, that
  /// keep a build from starting.
  final List<RunIssue> issues;

  bool get isRelease => kind == RunKind.release;

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
        definitionId: (json['definition'] as Map?)?['id'] as int?,
        sourceBranch: json['sourceBranch'] as String?,
        requestedFor: Identity.fromJson(json['requestedFor']),
        queueTime: _date(json['queueTime']),
        startTime: _date(json['startTime']),
        finishTime: _date(json['finishTime']),
        issues: _issues(json['validationResults'], 'result'),
      );

  /// A release, with its environments, artifacts and approvals expanded.
  factory PipelineRun.fromRelease(Map<String, dynamic> json, {String? project}) {
    final environments = _ReleaseEnvironment.all(json);
    final artifacts = ((json['artifacts'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final primary = artifacts.where((a) => a['isPrimary'] == true).firstOrNull ??
        artifacts.firstOrNull;
    final reference = primary?['definitionReference'] as Map?;
    final status = json['status'] == 'abandoned'
        ? RunStatus.canceled
        : _overallStatus([for (final e in environments) e.status]);
    final starts = [for (final e in environments) ?e.startTime]..sort();
    final finishes = [for (final e in environments) ?e.finishTime]..sort();
    return PipelineRun(
      id: json['id'] as int,
      kind: RunKind.release,
      buildNumber: json['name'] as String? ?? '${json['id']}',
      status: status,
      pipelineName: (json['releaseDefinition'] as Map?)?['name'] as String? ?? '',
      project: project ?? (json['projectReference'] as Map?)?['name'] as String? ?? '',
      sourceBranch: (reference?['branch'] as Map?)?['name'] as String?,
      requestedFor: Identity.fromJson(json['createdFor'] ?? json['createdBy']),
      queueTime: _date(json['createdOn']),
      startTime: starts.firstOrNull,
      finishTime: status.isFinished ? finishes.lastOrNull : null,
      artifactVersion: (reference?['version'] as Map?)?['name'] as String?,
      definitionId: (json['releaseDefinition'] as Map?)?['id'] as int?,
      stages: [
        for (final e in environments)
          (name: e.name, status: e.status, startTime: e.startTime, finishTime: e.finishTime),
      ],
      webUrl: (((json['_links'] as Map?)?['web']) as Map?)?['href'] as String?,
    );
  }

  /// The status of a release follows its busiest or worst stage.
  static RunStatus _overallStatus(List<RunStatus> stages) {
    const priority = [
      RunStatus.waitingForApproval,
      RunStatus.running,
      RunStatus.cancelling,
      RunStatus.queued,
      RunStatus.failed,
      RunStatus.partiallySucceeded,
      RunStatus.canceled,
      RunStatus.succeeded,
    ];
    for (final status in priority) {
      if (stages.contains(status)) return status;
    }
    return RunStatus.notDeployed;
  }

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
    this.approvers = const [],
    this.issues = const [],
    this.logUrl,
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

  /// Who still has to approve a release stage.
  final List<String> approvers;

  /// The errors and warnings the step logged; Azure DevOps lists only the
  /// first few, [errorCount] and [warningCount] count them all.
  final List<RunIssue> issues;

  /// Where the log of the step can be downloaded, once it has one.
  final String? logUrl;

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
        issues: _issues(json['issues'], 'type'),
        logUrl: (json['log'] as Map?)?['url'] as String?,
      );
}

/// The stages, jobs and tasks of a run, as a tree.
class Timeline {
  Timeline(List<TimelineRecord> records) {
    final ids = {for (final r in records) r.id};
    for (final r in records) {
      final parent = ids.contains(r.parentId) ? r.parentId : null;
      (_children[parent] ??= []).add(r);
      _records[r.id] = r;
    }
    for (final list in _children.values) {
      list.sort((a, b) => a.order.compareTo(b.order));
    }
    tasks = records.where((r) => r.isTask).toList();
  }

  /// The environments of a release as stages, with the jobs and tasks of
  /// their latest deployment attempt.
  factory Timeline.fromRelease(Map<String, dynamic> json) => Timeline([
        for (final env in _ReleaseEnvironment.all(json)) ...env.records(),
      ]);

  final _children = <String?, List<TimelineRecord>>{};
  final _records = <String, TimelineRecord>{};
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

  /// The errors of all steps in the order they ran, each with the step that
  /// logged it. A message repeated by a parent is shown once, with the
  /// innermost step.
  List<(TimelineRecord, RunIssue)> get errors {
    final seen = <String>{};
    final errors = <(TimelineRecord, RunIssue)>[];
    void visit(TimelineRecord record) {
      for (final child in _children[record.id] ?? const <TimelineRecord>[]) {
        visit(child);
      }
      for (final issue in record.issues) {
        if (issue.isError && seen.add(issue.message)) errors.add((record, issue));
      }
    }

    _children[null]?.forEach(visit);
    return errors;
  }

  /// The names of the stage, job and task that lead to [record]; phases are
  /// left out, as in [children].
  List<String> path(TimelineRecord record) => [
        for (TimelineRecord? r = record; r != null; r = _records[r.parentId])
          if (r.type != 'Phase') r.name,
      ].reversed.toList();

  int get finishedTasks => tasks.where((t) => t.status.isFinished).length;

  /// Share of the tasks that finished, or null before the tasks are known.
  double? get progress => tasks.isEmpty ? null : finishedTasks / tasks.length;

  /// Share of the tasks of the running stages that finished, or null when no
  /// stage with tasks is running.
  double? get runningStagesProgress {
    final stages = {
      for (final r in roots)
        if (r.status == RunStatus.running) r.id,
    };
    bool inRunningStage(TimelineRecord task) {
      for (TimelineRecord? r = task; r != null; r = _records[r.parentId]) {
        if (stages.contains(r.id)) return true;
      }
      return false;
    }

    final running = tasks.where(inRunningStage).toList();
    if (running.isEmpty) return null;
    return running.where((t) => t.status.isFinished).length / running.length;
  }
}

/// An environment (stage) of a release.
class _ReleaseEnvironment {
  _ReleaseEnvironment(this.json) {
    int attempt(Map<String, dynamic> step) => (step['attempt'] as num?)?.toInt() ?? 0;
    // Every redeploy adds an attempt; the last one is the current state.
    final steps = ((json['deploySteps'] as List?) ?? const []).cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) => attempt(a).compareTo(attempt(b)));
    _phases = ((steps.lastOrNull?['releaseDeployPhases'] as List?) ?? const [])
        .cast<Map<String, dynamic>>();
    approvers = [
      for (final key in ['preDeployApprovals', 'postDeployApprovals'])
        for (final a in ((json[key] as List?) ?? const []).cast<Map<String, dynamic>>())
          if (a['status'] == 'pending' && a['isAutomated'] != true)
            ?Identity.fromJson(a['approver'])?.displayName,
    ];
    final raw = json['status'] as String?;
    status = approvers.isNotEmpty
        ? RunStatus.waitingForApproval
        : raw == null || raw == 'notStarted' || raw == 'undefined'
            ? RunStatus.notDeployed
            : RunStatus._fromRelease(raw);
    final jobs = [
      for (final phase in _phases)
        for (final job in ((phase['deploymentJobs'] as List?) ?? const []))
          (job as Map<String, dynamic>)['job'] as Map<String, dynamic>? ?? const {},
    ];
    final starts = [
      for (final phase in _phases) ?_date(phase['startedOn']),
      for (final job in jobs) ?_date(job['startTime']),
    ]..sort();
    final finishes = [for (final job in jobs) ?_date(job['finishTime'])]..sort();
    startTime = starts.firstOrNull;
    // The list of releases leaves out the jobs; the last change to a finished
    // deployment is when it finished.
    finishTime = status.isFinished
        ? finishes.lastOrNull ?? _date(steps.lastOrNull?['lastModifiedOn'])
        : null;
  }

  static List<_ReleaseEnvironment> all(Map<String, dynamic> release) =>
      ((release['environments'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(_ReleaseEnvironment.new)
          .toList();

  final Map<String, dynamic> json;
  late final List<Map<String, dynamic>> _phases;
  late final List<String> approvers;
  late final RunStatus status;
  late final DateTime? startTime;
  late final DateTime? finishTime;

  String get name => json['name'] as String? ?? '';
  String get id => 'env${json['id']}';

  List<TimelineRecord> records() => [
        TimelineRecord(
          id: id,
          type: 'Stage',
          name: name,
          status: status,
          order: (json['rank'] as num?)?.toInt() ?? 0,
          startTime: startTime,
          finishTime: finishTime,
          approvers: approvers,
        ),
        for (final (p, phase) in _phases.indexed) ...[
          TimelineRecord(
            id: '$id-p$p',
            parentId: id,
            type: 'Phase',
            name: phase['name'] as String? ?? '',
            status: RunStatus._fromRelease(phase['status'] as String?),
            order: (phase['rank'] as num?)?.toInt() ?? p,
            issues: [
              if (phase['errorLog'] case final String log when log.trim().isNotEmpty)
                (isError: true, message: log.trim()),
            ],
          ),
          for (final (j, deployment) in ((phase['deploymentJobs'] as List?) ?? const [])
              .cast<Map<String, dynamic>>()
              .indexed) ...[
            _record(deployment['job'] as Map<String, dynamic>? ?? const {},
                id: '$id-p$p-j$j', parentId: '$id-p$p', type: 'Job', order: j),
            for (final (t, task) in ((deployment['tasks'] as List?) ?? const [])
                .cast<Map<String, dynamic>>()
                .indexed)
              _record(task, id: '$id-p$p-j$j-t$t', parentId: '$id-p$p-j$j', type: 'Task',
                  order: (task['rank'] as num?)?.toInt() ?? t),
          ],
        ],
      ];

  static TimelineRecord _record(
    Map<String, dynamic> json, {
    required String id,
    required String parentId,
    required String type,
    required int order,
  }) {
    final types = [
      for (final issue in ((json['issues'] as List?) ?? const []).cast<Map<String, dynamic>>())
        issue['issueType'],
    ];
    return TimelineRecord(
      id: id,
      parentId: parentId,
      type: type,
      name: json['name'] as String? ?? '',
      status: RunStatus._fromRelease(json['status'] as String?),
      order: order,
      startTime: _date(json['startTime']),
      finishTime: _date(json['finishTime']),
      errorCount: types.where((t) => t == 'Error').length,
      warningCount: types.where((t) => t == 'Warning').length,
      issues: _issues(json['issues'], 'issueType'),
      logUrl: json['logUrl'] as String?,
    );
  }
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;
