import 'package:devops/models/pipeline_run.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('PipelineRun', () {
    test('parses a build', () {
      final run = PipelineRun.fromJson(runJson(7, pipeline: 'Release'));
      expect(run.id, 7);
      expect(run.buildNumber, '20261020.7');
      expect(run.pipelineName, 'Release');
      expect(run.project, 'Contoso');
      expect(run.branch, 'main');
      expect(run.requestedFor?.displayName, 'Jan Claeys');
      expect(run.duration(), const Duration(minutes: 2));
    });

    test('combines status and result', () {
      RunStatus status(String status, [String? result]) =>
          PipelineRun.fromJson(runJson(1, status: status, result: result)).status;
      expect(status('notStarted'), RunStatus.queued);
      expect(status('inProgress'), RunStatus.running);
      expect(status('cancelling'), RunStatus.cancelling);
      expect(status('completed', 'succeeded'), RunStatus.succeeded);
      expect(status('completed', 'partiallySucceeded'), RunStatus.partiallySucceeded);
      expect(status('completed', 'failed'), RunStatus.failed);
      expect(status('completed', 'canceled'), RunStatus.canceled);
      expect(RunStatus.running.isFinished, isFalse);
      expect(RunStatus.failed.isFinished, isTrue);
    });

    test('a running build lasts until now', () {
      final run = PipelineRun.fromJson(
          runJson(1, status: 'inProgress', result: null, finishTime: null));
      expect(run.duration(run.startTime!.add(const Duration(seconds: 30))),
          const Duration(seconds: 30));
    });

    test('reads the validation errors of a run', () {
      final run = PipelineRun.fromJson({
        ...runJson(1, result: 'failed'),
        'validationResults': [
          {'result': 'error', 'message': '/azure-pipelines.yml: Unexpected value'},
          {'result': 'warning', 'message': 'Deprecated'},
        ],
      });
      expect(run.issues, [
        (isError: true, message: '/azure-pipelines.yml: Unexpected value'),
        (isError: false, message: 'Deprecated'),
      ]);
    });

    test('keeps branches outside refs/heads', () {
      expect(PipelineRun.fromJson(runJson(1, branch: 'refs/pull/4/merge')).branch,
          'refs/pull/4/merge');
    });
  });

  group('Timeline', () {
    final timeline = Timeline([
      for (final json in [
        recordJson('s2', 'Stage', 'Deploy', order: 2, state: 'pending', result: null),
        recordJson('s1', 'Stage', 'Build', order: 1),
        recordJson('p1', 'Phase', 'Build job', parent: 's1'),
        recordJson('c1', 'Checkpoint', 'Approval', parent: 's2'),
        recordJson('j1', 'Job', 'Build job', parent: 'p1'),
        recordJson('t2', 'Task', 'Test', parent: 'j1', order: 2,
            state: 'inProgress', result: null),
        recordJson('t1', 'Task', 'Compile', parent: 'j1', order: 1),
        recordJson('t3', 'Task', 'Publish', parent: 'j1', order: 3,
            state: 'completed', result: 'skipped'),
        recordJson('t4', 'Task', 'Deploy', parent: 'missing', order: 3,
            state: 'pending', result: null),
      ])
        TimelineRecord.fromJson(json),
    ]);

    test('orders the stages', () {
      expect(timeline.roots.map((r) => r.name), ['Build', 'Deploy', 'Deploy']);
    });

    test('skips phases and checkpoints', () {
      expect(timeline.children('s1').map((r) => r.id), ['j1']);
      expect(timeline.children('s2'), isEmpty);
      expect(timeline.children('j1').map((r) => r.name), ['Compile', 'Test', 'Publish']);
    });

    test('maps the state of records', () {
      expect(timeline.children('j1').map((r) => r.status),
          [RunStatus.succeeded, RunStatus.running, RunStatus.skipped]);
      expect(timeline.roots[1].status, RunStatus.pending);
    });

    test('collects the errors of all steps, once each', () {
      final failed = Timeline([
        for (final json in [
          recordJson('s1', 'Stage', 'Build', result: 'failed', errors: ['Stage failed']),
          recordJson('p1', 'Phase', 'Phase', parent: 's1', errors: ['No agent']),
          recordJson('j1', 'Job', 'Build job', parent: 'p1', result: 'failed',
              errors: ['Bash exited with code 1']),
          recordJson('t1', 'Task', 'Compile', parent: 'j1', result: 'failed',
              errors: ['error CS1002: ; expected', 'Bash exited with code 1'],
              log: 'https://dev.azure.com/contoso/1/_apis/build/builds/1/logs/5'),
        ])
          TimelineRecord.fromJson(json),
      ]);
      expect([for (final (r, i) in failed.errors) (r.id, i.message)], [
        ('t1', 'error CS1002: ; expected'),
        ('t1', 'Bash exited with code 1'),
        ('p1', 'No agent'),
        ('s1', 'Stage failed'),
      ]);
      final task = failed.tasks.single;
      expect(failed.path(task), ['Build', 'Build job', 'Compile']);
      expect(task.logUrl, endsWith('/logs/5'));
      expect(timeline.errors, isEmpty);
    });

    test('counts finished tasks', () {
      expect(timeline.tasks, hasLength(4));
      expect(timeline.finishedTasks, 2);
      expect(timeline.progress, 0.5);
      expect(Timeline(const []).progress, isNull);
    });
  });

  group('releases', () {
    final release = releaseJson(9, environments: [
      environmentJson(1, 'Test', tasks: [('Download', 'succeeded'), ('Deploy', 'succeeded')]),
      environmentJson(2, 'Acceptance', rank: 2, status: 'notStarted',
          pendingApprovers: ['Ann', 'Bob']),
      environmentJson(3, 'Production', rank: 3, status: 'notStarted'),
    ]);

    test('parses a release', () {
      final run = PipelineRun.fromRelease(release, project: 'Contoso');
      expect(run.kind, RunKind.release);
      expect(run.isRelease, isTrue);
      expect(run.buildNumber, 'Release-9');
      expect(run.pipelineName, 'Deploy web');
      expect(run.branch, 'main');
      expect(run.artifactVersion, '20261020.9');
      expect(run.requestedFor?.displayName, 'Jan Claeys');
      expect(run.queueTime, DateTime.parse('2026-10-20T11:00:00Z').toLocal());
      expect(run.startTime, DateTime.parse('2026-10-20T11:00:10Z').toLocal());
      expect(run.webUrl, contains('releaseId=9'));
      expect(run.stages, [
        (
          name: 'Test',
          status: RunStatus.succeeded,
          startTime: DateTime.parse('2026-10-20T11:00:10Z').toLocal(),
          finishTime: null,
        ),
        (name: 'Acceptance', status: RunStatus.waitingForApproval, startTime: null, finishTime: null),
        (name: 'Production', status: RunStatus.notDeployed, startTime: null, finishTime: null),
      ]);
    });

    test('takes the status of the busiest or worst stage', () {
      RunStatus status(List<String> stages, {String release = 'active'}) =>
          PipelineRun.fromRelease(releaseJson(1, status: release, environments: [
            for (final (i, s) in stages.indexed) environmentJson(i, 'S$i', status: s),
          ])).status;
      expect(status(['succeeded', 'notStarted']), RunStatus.succeeded);
      expect(status(['succeeded', 'inProgress']), RunStatus.running);
      expect(status(['rejected', 'succeeded']), RunStatus.failed);
      expect(status(['queued', 'failed']), RunStatus.queued);
      expect(status(['notStarted', 'notStarted']), RunStatus.notDeployed);
      expect(status(['inProgress'], release: 'abandoned'), RunStatus.canceled);
      expect(status(['succeeded', 'notStarted']).isFinished, isTrue);
      expect(RunStatus.waitingForApproval.isFinished, isFalse);
    });

    test('turns the stages into a timeline', () {
      final timeline = Timeline.fromRelease(release);
      expect(timeline.roots.map((r) => r.name), ['Test', 'Acceptance', 'Production']);
      expect(timeline.roots[1].approvers, ['Ann', 'Bob']);
      final job = timeline.children(timeline.roots.first.id).single;
      expect(job.type, 'Job');
      expect(timeline.children(job.id).map((t) => (t.name, t.status)),
          [('Download', RunStatus.succeeded), ('Deploy', RunStatus.succeeded)]);
      expect(timeline.progress, 1);
    });

    test('shows the latest deployment attempt', () {
      final env = environmentJson(1, 'Test', tasks: [('Old', 'failed')]);
      final retry = environmentJson(1, 'Test', tasks: [('New', 'succeeded')]);
      env['deploySteps'] = [
        {...(retry['deploySteps'] as List).single as Map<String, dynamic>, 'attempt': 2},
        ...env['deploySteps'] as List,
      ];
      final timeline = Timeline.fromRelease(releaseJson(1, environments: [env]));
      expect(timeline.tasks.map((t) => t.name), ['New']);
    });

    test('counts the issues of tasks', () {
      final env = environmentJson(1, 'Test', tasks: [('Deploy', 'failed')]);
      final task = ((((env['deploySteps'] as List).single['releaseDeployPhases'] as List)
              .single['deploymentJobs'] as List)
          .single['tasks'] as List)
          .single as Map<String, dynamic>;
      task['issues'] = [
        {'issueType': 'Error', 'message': 'Deployment failed'},
        {'issueType': 'Warning'},
        {'issueType': 'Warning'},
      ];
      task['logUrl'] = 'https://vsrm.dev.azure.com/contoso/logs/1';
      final timeline = Timeline.fromRelease(releaseJson(1, environments: [env]));
      final record = timeline.tasks.single;
      expect((record.errorCount, record.warningCount), (1, 2));
      expect(record.status, RunStatus.failed);
      expect(record.logUrl, 'https://vsrm.dev.azure.com/contoso/logs/1');
      expect([for (final (r, i) in timeline.errors) (r.name, i.message)],
          [('Deploy', 'Deployment failed')]);
      expect(timeline.path(record), ['Test', 'Agent job', 'Deploy']);
    });
  });
}
