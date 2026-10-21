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

/// In-memory stand-in for the Azure DevOps REST API.
class FakeDevOps {
  final projects = <Map<String, dynamic>>[
    {'id': '1', 'name': 'Contoso', 'description': 'Main project'},
  ];
  final items = <int, Map<String, dynamic>>{};

  /// Ids returned by WIQL queries, in this order.
  List<int>? queryResult;
  final comments = <int, List<Map<String, dynamic>>>{};

  /// When set, requests answer with this status code; with [failPath] only
  /// the requests whose path contains it.
  int? failWith;
  String? failPath;
  final requests = <http.Request>[];

  void add(Map<String, dynamic> item) => items[item['id'] as int] = item;

  late final client = MockClient((request) async {
    requests.add(request);
    final path = request.url.path;
    if (failWith != null && (failPath == null || path.contains(failPath!))) {
      return http.Response('{}', failWith!);
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
