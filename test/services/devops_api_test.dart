import 'dart:convert';

import 'package:devops/models/pipeline_run.dart';
import 'package:devops/models/work_item.dart';
import 'package:devops/services/devops_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../helpers.dart';

void main() {
  test('isSecure only accepts https organizations', () {
    expect(DevOpsApi.isSecure('contoso'), isTrue);
    expect(DevOpsApi.isSecure('https://tfs.local/tfs/Default'), isTrue);
    expect(DevOpsApi.isSecure('http://tfs.local:8080/tfs/Default'), isFalse);
  });

  group('normalizeOrganization', () {
    test('accepts several formats', () {
      expect(DevOpsApi.normalizeOrganization('contoso'), 'https://dev.azure.com/contoso');
      expect(DevOpsApi.normalizeOrganization('  contoso  '),
          'https://dev.azure.com/contoso');
      expect(DevOpsApi.normalizeOrganization('dev.azure.com/contoso/'),
          'https://dev.azure.com/contoso');
      expect(DevOpsApi.normalizeOrganization('https://contoso.visualstudio.com'),
          'https://contoso.visualstudio.com');
      expect(DevOpsApi.normalizeOrganization('http://tfs.local:8080/tfs/Default//'),
          'http://tfs.local:8080/tfs/Default');
    });
  });

  late FakeDevOps fake;
  late DevOpsApi api;

  setUp(() {
    fake = FakeDevOps();
    api = DevOpsApi(organization: 'contoso', pat: 'secret', client: fake.client);
  });

  test('sends the PAT as basic auth', () async {
    await api.getProjects();
    final headers = fake.requests.single.headers;
    expect(headers['Authorization'], 'Basic ${base64Encode(utf8.encode(':secret'))}');
    expect(headers['Accept'], 'application/json');
  });

  test('webUrl encodes the project', () {
    final item = WorkItem.fromJson(workItemJson(42, project: 'My Project'));
    expect(api.webUrl(item), 'https://dev.azure.com/contoso/My%20Project/_workitems/edit/42');
  });

  test('getProjects sorts case-insensitively', () async {
    fake.projects
      ..clear()
      ..addAll([
        {'id': '1', 'name': 'beta'},
        {'id': '2', 'name': 'Alpha'},
        {'id': '3', 'name': 'Gamma'},
      ]);
    final projects = await api.getProjects();
    expect(projects.map((p) => p.name), ['Alpha', 'beta', 'Gamma']);
    expect(fake.requests.single.url.toString(),
        'https://dev.azure.com/contoso/_apis/projects?\$top=500&api-version=7.1');
  });

  group('queryWorkItems', () {
    String wiql() => jsonDecode(fake.requests.first.body)['query'] as String;

    setUp(() {
      fake
        ..add(workItemJson(1))
        ..add(workItemJson(2));
    });

    test('defaults to my open items', () async {
      final items = await api.queryWorkItems(projects: ['Contoso']);
      expect(items.map((w) => w.id), [1, 2]);
      expect(wiql(), contains("[System.TeamProject] IN ('Contoso')"));
      expect(wiql(), contains('[System.AssignedTo] = @me'));
      expect(
          wiql(),
          contains("[System.State] NOT IN ('Closed', 'Done', 'Removed', 'Resolved', "
              "'Completed', 'Cut')"));
      expect(wiql(), endsWith('ORDER BY [System.ChangedDate] DESC'));
    });

    test('filters on creator', () async {
      await api.queryWorkItems(projects: ['Contoso'], scope: WorkItemScope.createdByMe);
      expect(wiql(), contains('[System.CreatedBy] = @me'));
      expect(wiql(), isNot(contains('[System.AssignedTo]')));
    });

    test('can include everything', () async {
      await api.queryWorkItems(
          projects: ['Contoso'], scope: WorkItemScope.all, openOnly: false);
      expect(wiql(), isNot(contains('@me')));
      expect(wiql(), isNot(contains('NOT IN')));
    });

    test('queries several projects and escapes quotes', () async {
      await api.queryWorkItems(projects: ['Contoso', "Bob's Project"]);
      expect(wiql(), contains("[System.TeamProject] IN ('Contoso', 'Bob''s Project')"));
    });

    test('returns nothing without projects and without calling the server', () async {
      expect(await api.queryWorkItems(projects: []), isEmpty);
      expect(fake.requests, isEmpty);
    });

    test('posts to the organization with top and only fetches list fields', () async {
      await api.queryWorkItems(projects: ['My Project'], top: 50);
      final wiqlRequest = fake.requests.first;
      expect(wiqlRequest.method, 'POST');
      expect(wiqlRequest.headers['Content-Type'], startsWith('application/json'));
      expect(wiqlRequest.url.path, '/contoso/_apis/wit/wiql');
      expect(wiqlRequest.url.queryParameters['\$top'], '50');
      final batch = jsonDecode(fake.requests.last.body);
      expect(batch['fields'], DevOpsApi.listFields);
      expect(batch['errorPolicy'], 'omit');
    });

    test('returns nothing without a batch request when no ids match', () async {
      fake.queryResult = [];
      expect(await api.queryWorkItems(projects: ['Contoso']), isEmpty);
      expect(fake.requests, hasLength(1));
    });
  });

  group('getWorkItems', () {
    test('returns an empty list without calling the server', () async {
      expect(await api.getWorkItems([]), isEmpty);
      expect(fake.requests, isEmpty);
    });

    test('omits fields when none are given', () async {
      fake.add(workItemJson(1));
      await api.getWorkItems([1]);
      expect(jsonDecode(fake.requests.single.body), isNot(contains('fields')));
    });

    test('fetches in batches of 200 and keeps the requested order', () async {
      final ids = [for (var i = 450; i > 0; i--) i];
      for (final id in ids) {
        fake.add(workItemJson(id));
      }
      final items = await api.getWorkItems(ids);
      expect(fake.requests.map((r) => (jsonDecode(r.body)['ids'] as List).length),
          [200, 200, 50]);
      expect(items.map((w) => w.id), ids);
    });

    test('skips items the server omits', () async {
      fake
        ..add(workItemJson(1))
        ..add(workItemJson(3));
      final items = await api.getWorkItems([3, 2, 1]);
      expect(items.map((w) => w.id), [3, 1]);
    });
  });

  test('getWorkItem expands relations', () async {
    fake.add(workItemJson(5, relations: [
      relation('System.LinkTypes.Hierarchy-Forward', 6),
    ]));
    final item = await api.getWorkItem(5);
    expect(item.childIds, [6]);
    expect(fake.requests.single.url.queryParameters['\$expand'], 'relations');
  });

  test('getComments reads the newest first', () async {
    fake.comments[5] = [
      {'text': 'second', 'createdDate': '2026-01-02T00:00:00Z'},
      {'text': 'first', 'createdDate': '2026-01-01T00:00:00Z'},
    ];
    final comments = await api.getComments('My Project', 5);
    expect(comments.map((c) => c.text), ['second', 'first']);
    final url = fake.requests.single.url;
    expect(url.path, '/contoso/My%20Project/_apis/wit/workItems/5/comments');
    expect(url.queryParameters['order'], 'desc');
    expect(url.queryParameters['\$expand'], 'renderedText');
  });

  group('pipelines', () {
    test('getPipelineRuns merges the projects, newest first', () async {
      fake
        ..addRun(runJson(1, queueTime: '2026-10-20T08:00:00Z'))
        ..addRun(runJson(2, project: 'My Project', queueTime: '2026-10-20T09:00:00Z'))
        ..addRun(runJson(3, queueTime: '2026-10-20T10:00:00Z'));
      final runs = await api.getPipelineRuns(projects: ['Contoso', 'My Project'], top: 2);
      expect(runs.map((r) => r.id), [3, 2]);
      expect(fake.requests.map((r) => r.url.path), [
        '/contoso/Contoso/_apis/build/builds',
        '/contoso/My%20Project/_apis/build/builds',
      ]);
      expect(fake.requests.first.url.queryParameters['\$top'], '2');
    });

    test('getPipelineRun and getTimeline read one run', () async {
      fake.addRun(runJson(4, status: 'inProgress', result: null), [
        recordJson('s1', 'Stage', 'Build', state: 'inProgress', result: null),
      ]);
      final run = await api.getPipelineRun('Contoso', 4);
      expect(run.status, RunStatus.running);
      final timeline = await api.getTimeline('Contoso', 4);
      expect(timeline.roots.single.name, 'Build');
    });

    test('a run that hasn\'t started has an empty timeline', () async {
      fake.addRun(runJson(4, status: 'notStarted', result: null));
      expect((await api.getTimeline('Contoso', 4)).roots, isEmpty);
    });

    test('getLog reads the text of a log', () async {
      fake.logs['/contoso/1/_apis/build/builds/4/logs/5'] = 'line 1\nline 2';
      expect(await api.getLog('https://dev.azure.com/contoso/1/_apis/build/builds/4/logs/5'),
          'line 1\nline 2');
      expect(fake.requests.single.headers['Accept'], 'text/plain');
    });

    test('getLog sends the token only to the organization', () async {
      await expectLater(api.getLog('https://example.com/logs/5'),
          throwsA(isA<DevOpsException>()));
      expect(fake.requests, isEmpty);
    });

    test('getLog sends the token only over https', () async {
      await expectLater(api.getLog('http://dev.azure.com/contoso/1/_apis/build/builds/4/logs/5'),
          throwsA(isA<DevOpsException>()));
      expect(fake.requests, isEmpty);
    });

    test('releaseBaseUrl points to release management', () {
      expect(DevOpsApi.releaseBaseUrl('https://dev.azure.com/contoso'),
          'https://vsrm.dev.azure.com/contoso');
      expect(DevOpsApi.releaseBaseUrl('https://contoso.visualstudio.com'),
          'https://contoso.vsrm.visualstudio.com');
      expect(DevOpsApi.releaseBaseUrl('http://tfs.local:8080/tfs/Default'),
          'http://tfs.local:8080/tfs/Default');
    });

    test('getReleases expands the stages, newest first', () async {
      fake.releases
        ..[1] = releaseJson(1, createdOn: '2026-10-20T08:00:00Z')
        ..[2] = releaseJson(2, createdOn: '2026-10-20T09:00:00Z');
      final releases = await api.getReleases(projects: ['My Project']);
      expect(releases.map((r) => (r.id, r.project, r.kind)),
          [(2, 'My Project', RunKind.release), (1, 'My Project', RunKind.release)]);
      final url = fake.requests.single.url;
      expect(url.host, 'vsrm.dev.azure.com');
      expect(url.path, '/contoso/My%20Project/_apis/release/releases');
      expect(url.queryParameters['\$expand'], 'environments,artifacts,approvals');
    });

    test('getRelease reads the release and its timeline', () async {
      fake.releases[3] = releaseJson(3, environments: [
        environmentJson(1, 'Test', status: 'inProgress', tasks: [('Deploy', 'inProgress')]),
      ]);
      final (run, timeline) = await api.getRelease('Contoso', 3);
      expect(run.status, RunStatus.running);
      expect(timeline.tasks.single.status, RunStatus.running);
      expect(fake.requests.single.url.path, '/contoso/Contoso/_apis/release/releases/3');
    });

    test('runWebUrl links to the results page', () {
      final run = PipelineRun.fromJson(runJson(4, project: 'My Project'));
      expect(api.runWebUrl(run),
          'https://dev.azure.com/contoso/My%20Project/_build/results?buildId=4');
      final release = PipelineRun.fromRelease(releaseJson(5)..remove('_links'),
          project: 'My Project');
      expect(api.runWebUrl(release),
          'https://dev.azure.com/contoso/My%20Project/_releaseProgress'
          '?_a=release-pipeline-progress&releaseId=5');
    });
  });

  test('headersFor only authenticates the organization', () {
    expect(api.headersFor(Uri.parse('https://dev.azure.com/contoso/_apis/wit/attachments/1')),
        {'Authorization': 'Basic ${base64Encode(utf8.encode(':secret'))}'});
    expect(api.headersFor(Uri.parse('http://dev.azure.com/x.png')), isNull);
    expect(api.headersFor(Uri.parse('https://example.com/x.png')), isNull);
  });

  test('decodes UTF-8 bodies', () async {
    fake.projects
      ..clear()
      ..add({'id': '1', 'name': 'Café ☕'});
    expect((await api.getProjects()).single.name, 'Café ☕');
  });

  group('errors', () {
    DevOpsApi apiAnswering(http.Response response) => DevOpsApi(
          organization: 'contoso',
          pat: 'secret',
          client: MockClient((_) async => response),
        );

    Matcher throwsDevOps(DevOpsError kind, {int? code, String? message}) =>
        throwsA(isA<DevOpsException>()
            .having((e) => e.kind, 'kind', kind)
            .having((e) => e.statusCode, 'statusCode', code)
            .having((e) => e.serverMessage, 'serverMessage', message));

    for (final code in [401, 203, 302]) {
      test('$code means unauthorized', () {
        expect(apiAnswering(http.Response('', code)).getProjects(),
            throwsDevOps(DevOpsError.unauthorized, code: code));
      });
    }

    test('404 means not found', () {
      expect(apiAnswering(http.Response('', 404)).getWorkItem(1),
          throwsDevOps(DevOpsError.notFound, code: 404));
    });

    test('other status codes carry the server message', () {
      expect(
          apiAnswering(http.Response('{"message":"TF401232: Bad query"}', 400))
              .getProjects(),
          throwsDevOps(DevOpsError.http, code: 400, message: 'TF401232: Bad query'));
    });

    test('other status codes without a JSON message', () {
      expect(apiAnswering(http.Response('<html>oops</html>', 500)).getProjects(),
          throwsDevOps(DevOpsError.http, code: 500));
      expect(apiAnswering(http.Response('{"message":12}', 503)).getProjects(),
          throwsDevOps(DevOpsError.http, code: 503));
    });

    test('a non-JSON success response is unexpected', () {
      expect(apiAnswering(http.Response('<html>Sign in</html>', 200)).getProjects(),
          throwsDevOps(DevOpsError.unexpectedResponse, code: 200));
    });

    test('a sign-in page means unauthorized', () {
      final signIn = http.Response('<html>Sign in</html>', 200,
          headers: {'content-type': 'text/html; charset=utf-8'});
      expect(apiAnswering(signIn).getProjects(),
          throwsDevOps(DevOpsError.unauthorized, code: 200));
      expect(apiAnswering(signIn).getLog('https://dev.azure.com/contoso/1/_apis/build/builds/4/logs/5'),
          throwsDevOps(DevOpsError.unauthorized, code: 200));
    });

    test('toString prefers the server message', () {
      expect(DevOpsException(DevOpsError.http, statusCode: 500, serverMessage: 'Boom')
          .toString(), 'Boom');
      expect(DevOpsException(DevOpsError.notFound, statusCode: 404).toString(),
          'Azure DevOps error notFound (404)');
    });
  });
}
