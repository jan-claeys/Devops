import 'dart:convert';

import 'package:devops/models/devops_link.dart';
import 'package:devops/models/pipeline_run.dart';
import 'package:devops/models/work_item.dart';
import 'package:devops/services/home_widget_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('home_widget');
  late Map<String, Object?> saved;
  late List<String> updated;

  void mockHomeWidget() {
    saved = {};
    updated = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final args = call.arguments as Map?;
      switch (call.method) {
        case 'saveWidgetData':
          saved[args!['id'] as String] = args['data'];
          return true;
        case 'getWidgetData':
          return saved[args!['id']];
        case 'updateWidget':
          updated.add(args!['android'] as String);
          return true;
      }
      return null;
    });
  }

  List<Map<String, dynamic>> rows(String key) =>
      (jsonDecode(saved[key] as String) as List).cast<Map<String, dynamic>>();

  setUp(mockHomeWidget);
  tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null));

  test('linkFromUri reads widget deep links', () {
    DevOpsLink? link(String uri) => HomeWidgets.linkFromUri(Uri.parse(uri));
    expect(link('devops://workitem/123'), const DevOpsLink(DevOpsLinkKind.workItem, 123));
    expect(link('devops://pullrequest/My%20Project/45'),
        const DevOpsLink(DevOpsLinkKind.pullRequest, 45, project: 'My Project'));
    expect(link('devops://build/Contoso/67'),
        const DevOpsLink(DevOpsLinkKind.build, 67, project: 'Contoso'));
    expect(link('devops://release/Contoso/89'),
        const DevOpsLink(DevOpsLinkKind.release, 89, project: 'Contoso'));
    expect(HomeWidgets.linkFromUri(null), isNull);
    expect(link('devops://workitem'), isNull);
    expect(link('devops://other/1'), isNull);
    expect(link('devops://workitem/abc'), isNull);
    expect(link('devops://pullrequest/45'), isNull);
    expect(link('https://workitem/1'), isNull);
  });

  test('updateTickets stores at most 50 tickets and the total count', () async {
    final items = [
      for (var i = 1; i <= 60; i++)
        WorkItem.fromJson(workItemJson(i, title: 'T$i', state: 'New', type: 'Task')),
    ];
    await HomeWidgets.updateTickets(projects: ['Contoso'], items: items);

    final stored = rows('items');
    expect(stored, hasLength(50));
    expect(stored.first, {
      'id': 1,
      'title': 'T1',
      'meta': '#1 · Task · New',
      'color': '#F2CB1D',
      'uri': 'devops://workitem/1',
    });
    expect(saved['count'], 60);
    expect(saved['project'], 'Contoso');
    expect(saved['error'], isNull);
    expect(int.tryParse(saved['updatedAt'] as String), isNotNull);
    expect(updated, ['TicketsWidgetProvider']);
  });

  test('an update with only an error keeps the previous rows', () async {
    saved['items'] = '[{"id":1}]';
    await HomeWidgets.updateTickets(projects: ['Contoso'], error: 'Offline');
    expect(saved['items'], '[{"id":1}]');
    expect(saved['error'], 'Offline');
  });

  test('updates ignore platforms without widget support', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await HomeWidgets.updateTickets(projects: ['Contoso'], items: const []);
  });

  test('refresh asks to set up the app when not configured', () async {
    mockStorage();
    await HomeWidgets.refresh();
    for (final prefix in ['', 'pullRequests.', 'pipelines.']) {
      expect(saved['${prefix}error'], en.widgetSetupRequired);
      expect(saved['${prefix}items'], '[]');
    }
    expect(updated, unorderedEquals(HomeWidgetKind.values.map((k) => k.androidName)));
  });

  test('refresh stores my open tickets', () async {
    final fake = FakeDevOps()..add(workItemJson(7, title: 'Fix login'));
    await HomeWidgets.refresh(kind: HomeWidgetKind.tickets, state: connectedState(fake));

    final query = jsonDecode(fake.requests.first.body)['query'] as String;
    expect(query, contains('[System.AssignedTo] = @me'));
    expect(query, contains('NOT IN'));
    expect(rows('items').single['title'], 'Fix login');
    expect(saved['error'], isNull);
    expect(updated, ['TicketsWidgetProvider']);
  });

  test('refresh shows a translated error', () async {
    final fake = FakeDevOps()..failWith = 401;
    await HomeWidgets.refresh(kind: HomeWidgetKind.tickets, state: connectedState(fake));
    expect(saved['error'], en.errorUnauthorized);
    expect(saved['project'], 'Contoso');
  });

  test('refresh shows the names of all projects', () async {
    final fake = FakeDevOps()..add(workItemJson(7));
    await HomeWidgets.refresh(
        kind: HomeWidgetKind.tickets,
        state: connectedState(fake, projects: ['Contoso', 'Fabrikam']));
    expect(saved['project'], 'Contoso, Fabrikam');
  });

  test('refresh stores the pull requests waiting for my vote, oldest first', () async {
    final fake = FakeDevOps()
      ..addPullRequest(pullRequestJson(1,
          title: 'Newer', creationDate: '2026-10-21T10:00:00Z', reviewers: [('Me', 0)]))
      ..addPullRequest(pullRequestJson(2,
          title: 'Older',
          repository: 'api',
          createdBy: 'Ann',
          creationDate: '2026-10-19T10:00:00Z',
          reviewers: [('Me', 0)]))
      ..addPullRequest(pullRequestJson(3, title: 'Voted', reviewers: [('Me', 10)]))
      ..addPullRequest(pullRequestJson(4, title: 'Draft', isDraft: true, reviewers: [('Me', 0)]))
      ..addPullRequest(pullRequestJson(5, title: 'Not mine', reviewers: [('Bob', 0)]));
    await HomeWidgets.refresh(kind: HomeWidgetKind.pullRequests, state: connectedState(fake));

    final stored = rows('pullRequests.items');
    expect(stored.map((r) => r['title']), ['Older', 'Newer']);
    expect(stored.first['meta'], '!2 · api · Ann');
    expect(stored.first['uri'], 'devops://pullrequest/Contoso/2');
    expect(saved['pullRequests.count'], 2);
    expect(saved['pullRequests.error'], isNull);
    expect(saved['items'], isNull, reason: 'the tickets widget is left alone');
    expect(updated, ['PullRequestsWidgetProvider']);
  });

  test('refresh stores the latest run of each pipeline on each branch', () async {
    Map<String, dynamic> run(int id, int definition, String pipeline,
            {String branch = 'refs/heads/main', String? result = 'succeeded', required int day}) =>
        runJson(id,
            pipeline: pipeline,
            branch: branch,
            result: result,
            queueTime: '2026-10-${day}T10:00:00Z')
          ..['definition'] = {'id': definition, 'name': pipeline};
    final fake = FakeDevOps()
      ..addRun(run(1, 1, 'CI', result: 'failed', day: 18))
      ..addRun(run(2, 1, 'CI', day: 20))
      ..addRun(run(3, 1, 'CI', branch: 'refs/heads/feature/x', result: 'failed', day: 19))
      ..addRun(run(4, 2, 'Nightly', result: 'failed', day: 17))
      ..releases[9] = releaseJson(9,
          createdOn: '2026-10-21T10:00:00Z',
          environments: [environmentJson(1, 'Prod', status: 'inProgress')]);
    await HomeWidgets.refresh(kind: HomeWidgetKind.pipelines, state: connectedState(fake));

    final stored = rows('pipelines.items');
    expect(stored.map((r) => (r['title'], r['meta'])), [
      ('Deploy web', '${en.runRunning} · main'),
      ('CI', '${en.runSucceeded} · main'),
      ('CI', '${en.runFailed} · feature/x'),
      ('Nightly', '${en.runFailed} · main'),
    ]);
    expect(stored.first['id'], -9);
    expect(stored.first['uri'], 'devops://release/Contoso/9');
    expect(stored[1]['uri'], 'devops://build/Contoso/2');
    expect(stored[1]['color'], '#339933');
    expect(saved['pipelines.count'], 2, reason: 'the failing ones');
    expect(updated, ['PipelinesWidgetProvider']);
  });

  test('the pipelines widget shows builds when releases fail to load', () async {
    final fake = FakeDevOps()
      ..addRun(runJson(1))
      ..failWith = 401
      ..failPath = '/_apis/release/';
    await HomeWidgets.refresh(kind: HomeWidgetKind.pipelines, state: connectedState(fake));
    expect(rows('pipelines.items').single['title'], 'CI');
    expect(saved['pipelines.error'], isNull);
  });

  test('latestPerPipeline keeps builds and releases of the same id apart', () {
    final runs = [
      PipelineRun.fromJson(runJson(1)),
      PipelineRun.fromRelease(releaseJson(1), project: 'Contoso'),
    ];
    expect(HomeWidgets.latestPerPipeline(runs), hasLength(2));
  });
}
