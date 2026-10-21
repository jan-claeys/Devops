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

    test('counts finished tasks', () {
      expect(timeline.tasks, hasLength(4));
      expect(timeline.finishedTasks, 2);
      expect(timeline.progress, 0.5);
      expect(Timeline(const []).progress, isNull);
    });
  });
}
