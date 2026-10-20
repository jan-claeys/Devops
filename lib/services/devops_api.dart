import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/work_item.dart';

class DevOpsException implements Exception {
  DevOpsException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

enum WorkItemScope { assignedToMe, createdByMe, all }

/// Thin client for the Azure DevOps REST API (v7.1), authenticated with a PAT.
class DevOpsApi {
  DevOpsApi({required String organization, required String pat, http.Client? client})
      : baseUrl = normalizeOrganization(organization),
        _client = client ?? http.Client(),
        _auth = 'Basic ${base64Encode(utf8.encode(':$pat'))}';

  final String baseUrl;
  final http.Client _client;
  final String _auth;

  static const _apiVersion = '7.1';

  /// Closed-like states that are hidden when "open only" is selected.
  static const closedStates = ['Closed', 'Done', 'Removed', 'Resolved', 'Completed', 'Cut'];

  static const listFields = [
    'System.Id',
    'System.Title',
    'System.State',
    'System.WorkItemType',
    'System.AssignedTo',
    'System.ChangedDate',
    'System.TeamProject',
    'System.Tags',
    'System.IterationPath',
    'Microsoft.VSTS.Common.Priority',
  ];

  /// Accepts "myorg", "dev.azure.com/myorg", "https://myorg.visualstudio.com"
  /// or a full on-prem collection URL.
  static String normalizeOrganization(String input) {
    var value = input.trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    if (value.contains('.')) return 'https://$value';
    return 'https://dev.azure.com/$value';
  }

  String webUrl(WorkItem item) =>
      '$baseUrl/${Uri.encodeComponent(item.project)}/_workitems/edit/${item.id}';

  Future<List<Project>> getProjects() async {
    final json = await _get('$baseUrl/_apis/projects?\$top=500&api-version=$_apiVersion');
    final projects = (json['value'] as List)
        .cast<Map<String, dynamic>>()
        .map(Project.fromJson)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return projects;
  }

  Future<List<WorkItem>> queryWorkItems({
    required String project,
    WorkItemScope scope = WorkItemScope.assignedToMe,
    bool openOnly = true,
    int top = 200,
  }) async {
    final conditions = <String>['[System.TeamProject] = @project'];
    switch (scope) {
      case WorkItemScope.assignedToMe:
        conditions.add('[System.AssignedTo] = @me');
      case WorkItemScope.createdByMe:
        conditions.add('[System.CreatedBy] = @me');
      case WorkItemScope.all:
        break;
    }
    if (openOnly) {
      conditions.add("[System.State] NOT IN (${closedStates.map((s) => "'$s'").join(', ')})");
    }
    final wiql = 'SELECT [System.Id] FROM WorkItems '
        'WHERE ${conditions.join(' AND ')} '
        'ORDER BY [System.ChangedDate] DESC';

    final result = await _post(
      '$baseUrl/${Uri.encodeComponent(project)}/_apis/wit/wiql?\$top=$top&api-version=$_apiVersion',
      {'query': wiql},
    );
    final ids = (result['workItems'] as List)
        .map((w) => (w as Map<String, dynamic>)['id'] as int)
        .toList();
    return getWorkItems(ids, fields: listFields);
  }

  /// Fetches work items in batches of 200, preserving the order of [ids].
  Future<List<WorkItem>> getWorkItems(List<int> ids, {List<String>? fields}) async {
    if (ids.isEmpty) return const [];
    final items = <WorkItem>[];
    for (var i = 0; i < ids.length; i += 200) {
      final chunk = ids.sublist(i, i + 200 > ids.length ? ids.length : i + 200);
      final json = await _post(
        '$baseUrl/_apis/wit/workitemsbatch?api-version=$_apiVersion',
        {
          'ids': chunk,
          'fields': ?fields,
          'errorPolicy': 'omit',
        },
      );
      items.addAll((json['value'] as List)
          .whereType<Map<String, dynamic>>()
          .map(WorkItem.fromJson));
    }
    final order = {for (var i = 0; i < ids.length; i++) ids[i]: i};
    items.sort((a, b) => order[a.id]!.compareTo(order[b.id]!));
    return items;
  }

  Future<WorkItem> getWorkItem(int id) async {
    final json = await _get(
        '$baseUrl/_apis/wit/workitems/$id?\$expand=relations&api-version=$_apiVersion');
    return WorkItem.fromJson(json);
  }

  Future<List<WorkItemComment>> getComments(String project, int id) async {
    final json = await _get(
        '$baseUrl/${Uri.encodeComponent(project)}/_apis/wit/workItems/$id/comments'
        '?order=desc&api-version=7.1-preview.4');
    return (json['comments'] as List)
        .cast<Map<String, dynamic>>()
        .map(WorkItemComment.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> _get(String url) async {
    final response = await _client.get(Uri.parse(url), headers: _headers);
    return _decode(response);
  }

  Future<Map<String, dynamic>> _post(String url, Object body) async {
    final response = await _client.post(
      Uri.parse(url),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, String> get _headers => {
        'Authorization': _auth,
        'Accept': 'application/json',
      };

  Map<String, dynamic> _decode(http.Response response) {
    final code = response.statusCode;
    if (code == 401 || code == 203 || code == 302) {
      throw DevOpsException(
          'Niet geautoriseerd. Controleer je Personal Access Token.', code);
    }
    if (code == 404) {
      throw DevOpsException('Niet gevonden. Controleer de organisatie of het project.', code);
    }
    if (code < 200 || code >= 300) {
      String message = 'Fout $code van Azure DevOps';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['message'] is String) message = body['message'] as String;
      } catch (_) {}
      throw DevOpsException(message, code);
    }
    try {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } on FormatException {
      // Azure DevOps answers with an HTML sign-in page when the PAT is invalid.
      throw DevOpsException(
          'Onverwacht antwoord. Controleer de organisatie en je token.', code);
    }
  }
}
