import 'dart:convert';

import 'package:devops/l10n/l10n.dart';
import 'package:devops/services/app_state.dart';
import 'package:devops/services/devops_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

final en = lookupAppLocalizations(const Locale('en'));

/// Raw work item JSON as returned by Azure DevOps.
Map<String, dynamic> workItemJson(
  int id, {
  String title = 'Ticket',
  String state = 'Active',
  String type = 'Bug',
  String project = 'Contoso',
  Map<String, dynamic> fields = const {},
  List<Map<String, dynamic>> relations = const [],
}) =>
    {
      'id': id,
      'fields': {
        'System.Title': title,
        'System.State': state,
        'System.WorkItemType': type,
        'System.TeamProject': project,
        ...fields,
      },
      'relations': relations,
    };

Map<String, dynamic> relation(String rel, int id) =>
    {'rel': rel, 'url': 'https://dev.azure.com/contoso/_apis/wit/workItems/$id'};

/// A file on the Attachments tab of a work item.
Map<String, dynamic> attachmentRelation(
  String name, {
  String id = 'a1b2c3d4-0000-0000-0000-000000000001',
  int? size,
  String? comment,
}) =>
    {
      'rel': 'AttachedFile',
      'url': 'https://dev.azure.com/contoso/1/_apis/wit/attachments/$id',
      'attributes': {
        'name': name,
        'resourceSize': ?size,
        'comment': ?comment,
        'authorizedDate': '2026-10-20T10:00:00Z',
      },
    };

/// Raw build JSON as returned by Azure DevOps.
Map<String, dynamic> runJson(
  int id, {
  String pipeline = 'CI',
  String project = 'Contoso',
  String status = 'completed',
  String? result = 'succeeded',
  String branch = 'refs/heads/main',
  String queueTime = '2026-10-20T10:00:00Z',
  String? startTime = '2026-10-20T10:00:05Z',
  String? finishTime = '2026-10-20T10:02:05Z',
  String repository = 'repo-1',
}) =>
    {
      'id': id,
      'buildNumber': '20261020.$id',
      'status': status,
      'result': ?result,
      'definition': {'id': 1, 'name': pipeline},
      'project': {'id': '1', 'name': project},
      'repository': {'id': repository, 'type': 'TfsGit'},
      'sourceBranch': branch,
      'requestedFor': {'displayName': 'Jan Claeys'},
      'queueTime': queueTime,
      'startTime': ?startTime,
      'finishTime': ?finishTime,
    };

/// Raw timeline record JSON as returned by Azure DevOps.
Map<String, dynamic> recordJson(
  String id,
  String type,
  String name, {
  String? parent,
  String state = 'completed',
  String? result = 'succeeded',
  int order = 1,
  List<String> errors = const [],
  String? log,
}) =>
    {
      'id': id,
      'parentId': parent,
      'type': type,
      'name': name,
      'state': state,
      'result': result,
      'order': order,
      'errorCount': errors.length,
      'issues': [
        for (final message in errors) {'type': 'error', 'category': 'General', 'message': message},
      ],
      if (log != null) 'log': {'id': 1, 'type': 'Container', 'url': log},
    };

/// Raw release JSON as returned by Azure DevOps, with [environments] from
/// [environmentJson].
Map<String, dynamic> releaseJson(
  int id, {
  String pipeline = 'Deploy web',
  String createdOn = '2026-10-20T11:00:00Z',
  String status = 'active',
  List<Map<String, dynamic>> environments = const [],
}) =>
    {
      'id': id,
      'name': 'Release-$id',
      'status': status,
      'releaseDefinition': {'id': 1, 'name': pipeline},
      'createdOn': createdOn,
      'createdFor': {'displayName': 'Jan Claeys'},
      'environments': environments,
      'artifacts': [
        {
          'isPrimary': true,
          'definitionReference': {
            'branch': {'name': 'refs/heads/main'},
            'version': {'name': '20261020.$id'},
          },
        },
      ],
      '_links': {
        'web': {'href': 'https://dev.azure.com/contoso/Contoso/_releaseProgress?releaseId=$id'},
      },
    };

/// A release environment (stage) with one deployment job running [tasks],
/// each a (name, status) pair.
Map<String, dynamic> environmentJson(
  int id,
  String name, {
  String status = 'succeeded',
  int rank = 1,
  List<(String, String)> tasks = const [],
  List<String> pendingApprovers = const [],
}) =>
    {
      'id': id,
      'name': name,
      'rank': rank,
      'status': status,
      'preDeployApprovals': [
        for (final approver in pendingApprovers)
          {'status': 'pending', 'isAutomated': false, 'approver': {'displayName': approver}},
      ],
      'deploySteps': [
        if (tasks.isNotEmpty)
          {
            'attempt': 1,
            'releaseDeployPhases': [
              {
                'name': 'Agent job',
                'rank': 1,
                'status': status,
                'startedOn': '2026-10-20T11:00:10Z',
                'deploymentJobs': [
                  {
                    'job': {
                      'name': 'Agent job',
                      'status': status,
                      'startTime': '2026-10-20T11:00:10Z',
                    },
                    'tasks': [
                      for (final (i, (task, taskStatus)) in tasks.indexed)
                        {'name': task, 'status': taskStatus, 'rank': i + 1},
                    ],
                  },
                ],
              },
            ],
          },
      ],
    };

/// Id of the signed in user in [FakeDevOps].
const meId = '00000000-0000-0000-0000-00000000000a';

/// Raw pull request JSON as returned by Azure DevOps; [reviewers] are
/// (name, vote) pairs.
Map<String, dynamic> pullRequestJson(
  int id, {
  String title = 'Add feature',
  String project = 'Contoso',
  String repository = 'web',
  String status = 'active',
  bool isDraft = false,
  String source = 'refs/heads/feature/login',
  String target = 'refs/heads/main',
  String createdBy = 'Jan Claeys',
  String? createdById,
  String creationDate = '2026-10-20T10:00:00Z',
  String? description,
  String mergeStatus = 'succeeded',
  List<(String, int)> reviewers = const [],
}) =>
    {
      'pullRequestId': id,
      'title': title,
      'status': status,
      'isDraft': isDraft,
      'repository': {
        'id': 'repo-$repository',
        'name': repository,
        'project': {'id': '1', 'name': project},
      },
      'sourceRefName': source,
      'targetRefName': target,
      'createdBy': {'displayName': createdBy, 'id': createdById ?? 'id-$createdBy'},
      'creationDate': creationDate,
      'description': ?description,
      'mergeStatus': mergeStatus,
      'reviewers': [
        for (final (name, vote) in reviewers)
          {'displayName': name, 'id': name == 'Me' ? meId : 'id-$name', 'vote': vote},
      ],
    };

/// In-memory stand-in for the Azure DevOps REST API.
class FakeDevOps {
  final projects = <Map<String, dynamic>>[
    {'id': '1', 'name': 'Contoso', 'description': 'Main project'},
  ];
  final items = <int, Map<String, dynamic>>{};

  /// Ids returned by WIQL queries, in this order.
  List<int>? queryResult;
  final comments = <int, List<Map<String, dynamic>>>{};

  /// Pipeline runs by id; [timelines] holds their records, missing until a
  /// run starts.
  final runs = <int, Map<String, dynamic>>{};
  final timelines = <int, List<Map<String, dynamic>>>{};

  /// Git repositories, all in Contoso; the pipelines are those of [runs].
  final repositories = <Map<String, dynamic>>[
    {'id': 'repo-1', 'name': 'Contoso', 'defaultBranch': 'refs/heads/main'},
  ];
  final disabledDefinitions = <int>{};

  /// The text of logs, by the path of their URL.
  final logs = <String, String>{};

  /// The content of attachments, by their guid.
  final attachments = <String, List<int>>{};

  /// Releases of classic release pipelines, by id, all in Contoso.
  final releases = <int, Map<String, dynamic>>{};

  /// Pull requests by id, with their raw threads and linked work item ids.
  final pullRequests = <int, Map<String, dynamic>>{};
  final threads = <int, List<Map<String, dynamic>>>{};
  final pullRequestWorkItems = <int, List<int>>{};

  void addPullRequest(Map<String, dynamic> pr) => pullRequests[pr['pullRequestId'] as int] = pr;

  /// When set, requests answer with this status code; with [failPath] only
  /// the requests whose path contains it.
  int? failWith;
  String? failPath;
  final requests = <http.Request>[];

  void add(Map<String, dynamic> item) => items[item['id'] as int] = item;

  void addRun(Map<String, dynamic> run, [List<Map<String, dynamic>>? records]) {
    runs[run['id'] as int] = run;
    if (records != null) timelines[run['id'] as int] = records;
  }

  late final client = MockClient((request) async {
    requests.add(request);
    final path = request.url.path;
    if (failWith != null && (failPath == null || path.contains(failPath!))) {
      return http.Response('{}', failWith!);
    }
    if (logs[path] case final log?) {
      return http.Response.bytes(utf8.encode(log), 200, headers: {'content-type': 'text/plain'});
    }
    final attachment = RegExp(r'/_apis/wit/attachments/([^/]+)$').firstMatch(path);
    if (attachment != null) {
      final bytes = attachments[attachment[1]!];
      return bytes == null
          ? http.Response('', 404)
          : http.Response.bytes(bytes, 200, headers: {'content-type': 'application/octet-stream'});
    }
    if (path.endsWith('/_apis/projects')) {
      return _json({'value': projects});
    }
    if (path.endsWith('/_apis/wit/wiql')) {
      final ids = queryResult ?? items.keys.toList();
      return _json({
        'workItems': [for (final id in ids) {'id': id}],
      });
    }
    if (path.endsWith('/_apis/wit/workitemsbatch')) {
      final ids = (jsonDecode(request.body)['ids'] as List).cast<int>();
      return _json({
        'value': [for (final id in ids) ?items[id]],
      });
    }
    final comment = RegExp(r'/workItems/(\d+)/comments$').firstMatch(path);
    if (comment != null) {
      return _json({'comments': comments[int.parse(comment[1]!)] ?? []});
    }
    if (path.endsWith('/_apis/connectionData')) {
      return _json({
        'authenticatedUser': {'id': meId, 'providerDisplayName': 'Me'},
      });
    }
    final pullRequestList = RegExp(r'/([^/]+)/_apis/git/pullrequests$').firstMatch(path);
    if (pullRequestList != null) {
      final project = Uri.decodeComponent(pullRequestList[1]!);
      final query = request.url.queryParameters;
      final status = query['searchCriteria.status'];
      final creator = query['searchCriteria.creatorId'];
      final reviewer = query['searchCriteria.reviewerId'];
      return _json({
        'value': [
          for (final pr in pullRequests.values)
            if (((pr['repository'] as Map)['project'] as Map)['name'] == project &&
                (status == 'all' || pr['status'] == (status ?? 'active')) &&
                (creator == null || (pr['createdBy'] as Map)['id'] == creator) &&
                (reviewer == null ||
                    (pr['reviewers'] as List).any((r) => (r as Map)['id'] == reviewer)))
              pr,
        ],
      });
    }
    final pullRequest = RegExp(r'/_apis/git/pullrequests/(\d+)$').firstMatch(path);
    if (pullRequest != null) {
      final json = pullRequests[int.parse(pullRequest[1]!)];
      return json == null ? http.Response('', 404) : _json(json);
    }
    final prThreads = RegExp(r'/pullRequests/(\d+)/threads$').firstMatch(path);
    if (prThreads != null) {
      return _json({'value': threads[int.parse(prThreads[1]!)] ?? []});
    }
    final prWorkItems = RegExp(r'/pullRequests/(\d+)/workitems$').firstMatch(path);
    if (prWorkItems != null) {
      return _json({
        'value': [
          for (final id in pullRequestWorkItems[int.parse(prWorkItems[1]!)] ?? const [])
            {'id': '$id', 'url': 'https://dev.azure.com/contoso/_apis/wit/workItems/$id'},
        ],
      });
    }
    if (path.endsWith('/_apis/release/releases')) {
      return _json({'value': releases.values.toList()});
    }
    final release = RegExp(r'/_apis/release/releases/(\d+)$').firstMatch(path);
    if (release != null) {
      final json = releases[int.parse(release[1]!)];
      return json == null ? http.Response('', 404) : _json(json);
    }
    if (path.endsWith('/_apis/git/repositories')) {
      return _json({'value': repositories});
    }
    final definitions = RegExp(r'/([^/]+)/_apis/build/definitions$').firstMatch(path);
    if (definitions != null) {
      final project = Uri.decodeComponent(definitions[1]!);
      final ids = {
        for (final run in runs.values)
          if ((run['project'] as Map)['name'] == project) (run['definition'] as Map)['id'] as int,
      };
      return _json({
        'value': [
          for (final id in ids)
            {'id': id, 'queueStatus': disabledDefinitions.contains(id) ? 'disabled' : 'enabled'},
        ],
      });
    }
    final builds = RegExp(r'/([^/]+)/_apis/build/builds$').firstMatch(path);
    if (builds != null) {
      final project = Uri.decodeComponent(builds[1]!);
      final query = request.url.queryParameters;
      final branch = query['branchName'];
      final ids = query['definitions']?.split(',').map(int.parse).toSet();
      return _json({
        'value': [
          for (final run in runs.values)
            if ((run['project'] as Map)['name'] == project &&
                (branch == null || run['sourceBranch'] == branch) &&
                (ids == null || ids.contains((run['definition'] as Map)['id'])) &&
                (query['statusFilter'] == null || run['status'] == query['statusFilter']))
              run,
        ],
      });
    }
    final timeline = RegExp(r'/_apis/build/builds/(\d+)/timeline$').firstMatch(path);
    if (timeline != null) {
      final records = timelines[int.parse(timeline[1]!)];
      return records == null ? http.Response('', 204) : _json({'records': records});
    }
    final build = RegExp(r'/_apis/build/builds/(\d+)$').firstMatch(path);
    if (build != null) {
      final run = runs[int.parse(build[1]!)];
      return run == null ? http.Response('', 404) : _json(run);
    }
    final single = RegExp(r'/_apis/wit/workitems/(\d+)$').firstMatch(path);
    if (single != null) {
      final item = items[int.parse(single[1]!)];
      return item == null ? http.Response('', 404) : _json(item);
    }
    return http.Response('', 404);
  });

  http.Response _json(Object body) => http.Response.bytes(
        utf8.encode(jsonEncode(body)),
        200,
        headers: {'content-type': 'application/json'},
      );
}

/// Resets the plugin mocks that [AppState] relies on.
void mockStorage({
  Map<String, Object> prefs = const {},
  Map<String, String> secure = const {},
}) {
  SharedPreferences.setMockInitialValues(prefs);
  FlutterSecureStorage.setMockInitialValues(Map.of(secure));
}

/// An [AppState] connected to [fake] and showing the Contoso project.
AppState connectedState(FakeDevOps fake, {List<String> projects = const ['Contoso']}) {
  return AppState(httpClient: fake.client)
    ..organization = 'contoso'
    ..projects = projects
    ..api = DevOpsApi(organization: 'contoso', pat: 'secret', client: fake.client);
}

Future<void> pumpApp(
  WidgetTester tester,
  Widget home, {
  required AppState state,
  Size size = const Size(400, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(AppScope(
    state: state,
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    ),
  ));
}
