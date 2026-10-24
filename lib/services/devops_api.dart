import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pipeline_run.dart';
import '../models/pull_request.dart';
import '../models/work_item.dart';

enum DevOpsError { unauthorized, notFound, http, unexpectedResponse }

class DevOpsException implements Exception {
  DevOpsException(this.kind, {this.statusCode, this.serverMessage});

  final DevOpsError kind;
  final int? statusCode;

  /// Error message returned by Azure DevOps, if any.
  final String? serverMessage;

  @override
  String toString() => serverMessage ?? 'Azure DevOps error ${kind.name} ($statusCode)';
}

enum WorkItemScope { assignedToMe, createdByMe, all }

/// [mine] are the pull requests the user created or reviews.
enum PullRequestScope { mine, reviewing, createdByMe, all }

/// Thin client for the Azure DevOps REST API (v7.1), authenticated with a PAT.
class DevOpsApi {
  DevOpsApi({required String organization, required String pat, http.Client? client})
      : baseUrl = normalizeOrganization(organization),
        releaseUrl = releaseBaseUrl(normalizeOrganization(organization)),
        _client = client ?? http.Client(),
        _auth = 'Basic ${base64Encode(utf8.encode(':$pat'))}';

  final String baseUrl;

  /// Base URL of the release management API of classic release pipelines.
  final String releaseUrl;
  final http.Client _client;
  final String _auth;
  String? _currentUserId;

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

  /// Whether [organization] is reached over https. The PAT travels in a
  /// header with every request, so over plain http anyone on the network can
  /// read it.
  static bool isSecure(String organization) =>
      Uri.parse(normalizeOrganization(organization)).scheme == 'https';

  String webUrl(WorkItem item) =>
      '$baseUrl/${Uri.encodeComponent(item.project)}/_workitems/edit/${item.id}';

  /// Release management has its own host in Azure DevOps Services; on a
  /// server it lives in the collection itself.
  static String releaseBaseUrl(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final host = switch (uri.host) {
      'dev.azure.com' => 'vsrm.dev.azure.com',
      final h when h.endsWith('.visualstudio.com') =>
        h.replaceFirst(RegExp(r'\.visualstudio\.com$'), '.vsrm.visualstudio.com'),
      final h => h,
    };
    return uri.replace(host: host).toString();
  }

  String runWebUrl(PipelineRun run) => switch (run) {
        PipelineRun(:final webUrl?) => webUrl,
        PipelineRun(kind: RunKind.release) =>
          '$baseUrl/${Uri.encodeComponent(run.project)}/_releaseProgress'
              '?_a=release-pipeline-progress&releaseId=${run.id}',
        _ => '$baseUrl/${Uri.encodeComponent(run.project)}/_build/results?buildId=${run.id}',
      };

  String pullRequestWebUrl(PullRequest pr) =>
      '$baseUrl/${Uri.encodeComponent(pr.project)}/_git/'
      '${Uri.encodeComponent(pr.repositoryName)}/pullrequest/${pr.id}';

  /// Headers to load [uri] with, such as an attachment image in a field.
  /// The PAT is only sent to the organization itself.
  Map<String, String>? headersFor(Uri uri) =>
      _isOrganization(uri, [baseUrl]) ? {'Authorization': _auth} : null;

  /// Whether [uri] has the same scheme, host and port as one of [bases].
  static bool _isOrganization(Uri uri, List<String> bases) => bases.map(Uri.parse).any(
      (base) => uri.scheme == base.scheme && uri.host == base.host && uri.port == base.port);

  Future<List<Project>> getProjects() async {
    final json = await _get('$baseUrl/_apis/projects?\$top=500&api-version=$_apiVersion');
    final projects = (json['value'] as List)
        .cast<Map<String, dynamic>>()
        .map(Project.fromJson)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return projects;
  }

  /// Queries the work items of all [projects] at once.
  Future<List<WorkItem>> queryWorkItems({
    required List<String> projects,
    WorkItemScope scope = WorkItemScope.assignedToMe,
    bool openOnly = true,
    int top = 200,
  }) async {
    if (projects.isEmpty) return const [];
    final conditions = <String>[
      '[System.TeamProject] IN (${projects.map(_quote).join(', ')})',
    ];
    switch (scope) {
      case WorkItemScope.assignedToMe:
        conditions.add('[System.AssignedTo] = @me');
      case WorkItemScope.createdByMe:
        conditions.add('[System.CreatedBy] = @me');
      case WorkItemScope.all:
        break;
    }
    if (openOnly) {
      conditions.add('[System.State] NOT IN (${closedStates.map(_quote).join(', ')})');
    }
    final wiql = 'SELECT [System.Id] FROM WorkItems '
        'WHERE ${conditions.join(' AND ')} '
        'ORDER BY [System.ChangedDate] DESC';

    // At organization level, so the query can span several projects.
    final result = await _post(
      '$baseUrl/_apis/wit/wiql?\$top=$top&api-version=$_apiVersion',
      {'query': wiql},
    );
    final ids = (result['workItems'] as List)
        .map((w) => (w as Map<String, dynamic>)['id'] as int)
        .toList();
    return getWorkItems(ids, fields: listFields);
  }

  /// A WIQL string literal; quotes are escaped by doubling them.
  static String _quote(String value) => "'${value.replaceAll("'", "''")}'";

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
        '?order=desc&\$expand=renderedText&api-version=7.1-preview.4');
    return (json['comments'] as List)
        .cast<Map<String, dynamic>>()
        .map(WorkItemComment.fromJson)
        .toList();
  }

  /// Adds a comment of plain [text] to [item]. Comments are HTML: Markdown
  /// needs an API version that Azure DevOps Server doesn't have.
  Future<void> addWorkItemComment(WorkItem item, String text) => _post(
        '$baseUrl/${Uri.encodeComponent(item.project)}/_apis/wit/workItems/${item.id}/comments'
        '?api-version=7.1-preview.4',
        {'text': const HtmlEscape(HtmlEscapeMode.element).convert(text).replaceAll('\n', '<br>')},
      );

  /// The latest runs of the pipelines in all [projects], newest first; only
  /// those requested for the user with id [requestedFor], when given.
  Future<List<PipelineRun>> getPipelineRuns({
    required List<String> projects,
    String? requestedFor,
    int top = 50,
  }) async {
    final filter =
        requestedFor == null ? '' : '&requestedFor=${Uri.encodeQueryComponent(requestedFor)}';
    final perProject = await Future.wait([
      for (final project in projects)
        _get('$baseUrl/${Uri.encodeComponent(project)}/_apis/build/builds'
            '?\$top=$top&queryOrder=queueTimeDescending$filter&api-version=$_apiVersion'),
    ]);
    final runs = [
      for (final json in perProject)
        ...(json['value'] as List).cast<Map<String, dynamic>>().map(PipelineRun.fromJson),
    ]..sort((a, b) => (b.queueTime ?? DateTime(0)).compareTo(a.queueTime ?? DateTime(0)));
    return runs.take(top).toList();
  }

  /// Taken as the default branch when the repository of a build doesn't
  /// tell, such as one on GitHub, or the code can't be read.
  static const fallbackDefaultBranches = {'refs/heads/main', 'refs/heads/master'};

  /// The latest completed builds of the pipelines in all [projects] on the
  /// default branch of their repository, up to [perPipeline] of each that
  /// finished since [minTime], newest first. Disabled pipelines are left out.
  Future<List<PipelineRun>> getDefaultBranchRuns({
    required List<String> projects,
    DateTime? minTime,
    int perPipeline = 5,
  }) async {
    final perProject = await Future.wait([
      for (final project in projects) _defaultBranchRuns(project, minTime, perPipeline),
    ]);
    return [for (final runs in perProject) ...runs]
      ..sort((a, b) => (b.finishTime ?? DateTime(0)).compareTo(a.finishTime ?? DateTime(0)));
  }

  Future<List<PipelineRun>> _defaultBranchRuns(
      String project, DateTime? minTime, int perPipeline) async {
    final apis = '$baseUrl/${Uri.encodeComponent(project)}/_apis';
    // Without access to the code, the usual names will do.
    final defaults = await _get('$apis/git/repositories?api-version=$_apiVersion').then(
      (json) => {
        for (final repo in (json['value'] as List).cast<Map<String, dynamic>>())
          if (repo['defaultBranch'] case final String branch) repo['id'] as String: branch,
      },
      onError: (Object _) => <String, String>{},
    );
    final definitions = await _get('$apis/build/definitions?api-version=$_apiVersion');
    final enabled = [
      for (final d in (definitions['value'] as List).cast<Map<String, dynamic>>())
        if (d['queueStatus'] != 'disabled') d['id'] as int,
    ];
    final since = minTime == null
        ? ''
        : '&minTime=${Uri.encodeQueryComponent(minTime.toUtc().toIso8601String())}';
    // A build query takes one branch; the definitions keep the URL short.
    const chunk = 100;
    final pages = await Future.wait([
      for (final branch in {...defaults.values, ...fallbackDefaultBranches})
        for (var i = 0; i < enabled.length; i += chunk)
          _get('$apis/build/builds'
              '?definitions=${enabled.skip(i).take(chunk).join(',')}'
              '&branchName=${Uri.encodeQueryComponent(branch)}&statusFilter=completed'
              '&maxBuildsPerDefinition=$perPipeline&queryOrder=finishTimeDescending$since'
              '&api-version=$_apiVersion'),
    ]);
    bool onDefaultBranch(Map<String, dynamic> build) {
      final branch = build['sourceBranch'];
      return switch (defaults[(build['repository'] as Map?)?['id']]) {
        final defaultBranch? => branch == defaultBranch,
        null => fallbackDefaultBranches.contains(branch),
      };
    }

    return [
      for (final page in pages)
        for (final build in (page['value'] as List).cast<Map<String, dynamic>>())
          if (onDefaultBranch(build)) PipelineRun.fromJson(build),
    ];
  }

  Future<PipelineRun> getPipelineRun(String project, int id) async {
    final json = await _get('$baseUrl/${Uri.encodeComponent(project)}/_apis/build/builds/$id'
        '?api-version=$_apiVersion');
    return PipelineRun.fromJson(json);
  }

  /// The latest releases of the classic release pipelines in all [projects],
  /// newest first.
  Future<List<PipelineRun>> getReleases({
    required List<String> projects,
    int top = 50,
  }) async {
    final perProject = await Future.wait([
      for (final project in projects)
        _get('$releaseUrl/${Uri.encodeComponent(project)}/_apis/release/releases'
            '?\$top=$top&\$expand=environments,artifacts,approvals'
            '&queryOrder=descending&api-version=$_apiVersion'),
    ]);
    final releases = [
      for (final (i, json) in perProject.indexed)
        for (final release in (json['value'] as List).cast<Map<String, dynamic>>())
          PipelineRun.fromRelease(release, project: projects[i]),
    ]..sort((a, b) => (b.queueTime ?? DateTime(0)).compareTo(a.queueTime ?? DateTime(0)));
    return releases.take(top).toList();
  }

  /// A release with the jobs and tasks of its stages.
  Future<(PipelineRun, Timeline)> getRelease(String project, int id) async {
    final json = await _get('$releaseUrl/${Uri.encodeComponent(project)}'
        '/_apis/release/releases/$id?api-version=$_apiVersion');
    return (PipelineRun.fromRelease(json, project: project), Timeline.fromRelease(json));
  }

  /// The stages, jobs and tasks of a run; empty until the run starts.
  Future<Timeline> getTimeline(String project, int id) async {
    final json = await _get('$baseUrl/${Uri.encodeComponent(project)}/_apis/build/builds/$id'
        '/timeline?api-version=$_apiVersion');
    return Timeline([
      for (final r in (json['records'] as List?) ?? const [])
        TimelineRecord.fromJson(r as Map<String, dynamic>),
    ]);
  }

  /// The text of the log of a step, from [TimelineRecord.logUrl].
  Future<String> getLog(String url) async {
    final uri = Uri.parse(url);
    // The URL comes from the API; still, the PAT only goes to the organization.
    if (!_isOrganization(uri, [baseUrl, releaseUrl])) {
      throw DevOpsException(DevOpsError.unexpectedResponse);
    }
    final response =
        await _client.get(uri, headers: {..._headers, 'Accept': 'text/plain'});
    _check(response);
    // A sign-in page instead of the log when the PAT is invalid.
    if (response.headers['content-type']?.contains('html') ?? false) {
      throw DevOpsException(DevOpsError.unauthorized, statusCode: response.statusCode);
    }
    return utf8.decode(response.bodyBytes, allowMalformed: true);
  }

  /// The content of [attachment], streamed: a video may not fit in memory.
  Future<http.StreamedResponse> downloadAttachment(WorkItemAttachment attachment) async {
    final uri = Uri.parse(attachment.url);
    // The URL comes from the API; still, the PAT only goes to the organization.
    if (!_isOrganization(uri, [baseUrl])) {
      throw DevOpsException(DevOpsError.unexpectedResponse);
    }
    final request = http.Request(
        'GET', uri.replace(queryParameters: {...uri.queryParameters, 'download': 'true'}))
      ..headers['Authorization'] = _auth;
    final response = await _client.send(request);
    final code = response.statusCode;
    if (code < 200 || code >= 300 || code == 203) {
      _check(await http.Response.fromStream(response));
    }
    // A sign-in page instead of the file when the PAT is invalid.
    final html = response.headers['content-type']?.contains('html') ?? false;
    if (html && !{'htm', 'html'}.contains(attachment.extension)) {
      await response.stream.drain<void>();
      throw DevOpsException(DevOpsError.unauthorized, statusCode: code);
    }
    return response;
  }

  /// Id of the user the token belongs to.
  Future<String> getCurrentUserId() async {
    if (_currentUserId case final id?) return id;
    final json = await _get('$baseUrl/_apis/connectionData');
    final id = (json['authenticatedUser'] as Map?)?['id'] as String?;
    if (id == null) throw DevOpsException(DevOpsError.unexpectedResponse);
    return _currentUserId = id;
  }

  /// The pull requests of all [projects], newest first.
  Future<List<PullRequest>> getPullRequests({
    required List<String> projects,
    PullRequestScope scope = PullRequestScope.all,
    bool openOnly = true,
    int top = 100,
  }) async {
    if (scope == PullRequestScope.mine) {
      final results = await Future.wait([
        for (final s in [PullRequestScope.createdByMe, PullRequestScope.reviewing])
          getPullRequests(projects: projects, scope: s, openOnly: openOnly, top: top),
      ]);
      // A pull request the user reviews may also be one they created.
      final byId = {for (final pr in results.expand((prs) => prs)) pr.id: pr};
      return (byId.values.toList()
            ..sort((a, b) =>
                (b.creationDate ?? DateTime(0)).compareTo(a.creationDate ?? DateTime(0))))
          .take(top)
          .toList();
    }
    final me = scope == PullRequestScope.all ? null : await getCurrentUserId();
    final criteria = {
      'searchCriteria.status': openOnly ? 'active' : 'all',
      if (scope == PullRequestScope.createdByMe) 'searchCriteria.creatorId': ?me,
      if (scope == PullRequestScope.reviewing) 'searchCriteria.reviewerId': ?me,
    }.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&');
    final perProject = await Future.wait([
      for (final project in projects)
        _get('$baseUrl/${Uri.encodeComponent(project)}/_apis/git/pullrequests'
            '?$criteria&\$top=$top&api-version=$_apiVersion'),
    ]);
    final pullRequests = [
      for (final json in perProject)
        ...(json['value'] as List).cast<Map<String, dynamic>>().map(PullRequest.fromJson),
    ]..sort((a, b) =>
        (b.creationDate ?? DateTime(0)).compareTo(a.creationDate ?? DateTime(0)));
    return pullRequests.take(top).toList();
  }

  Future<PullRequest> getPullRequest(String project, int id) async {
    final json = await _get('$baseUrl/${Uri.encodeComponent(project)}/_apis/git/pullrequests/$id'
        '?api-version=$_apiVersion');
    return PullRequest.fromJson(json);
  }

  /// The discussions on [pr], most recently active first.
  Future<List<PullRequestThread>> getPullRequestThreads(PullRequest pr) async {
    final json = await _get('${_pullRequestUrl(pr)}/threads?api-version=$_apiVersion');
    return [
      for (final t in ((json['value'] as List?) ?? const []).cast<Map<String, dynamic>>())
        ?PullRequestThread.fromJson(t),
    ]..sort((a, b) => (b.lastUpdated ?? DateTime(0)).compareTo(a.lastUpdated ?? DateTime(0)));
  }

  /// Ids of the work items linked to [pr].
  Future<List<int>> getPullRequestWorkItemIds(PullRequest pr) async {
    final json = await _get('${_pullRequestUrl(pr)}/workitems?api-version=$_apiVersion');
    return [
      for (final w in ((json['value'] as List?) ?? const []).cast<Map<String, dynamic>>())
        ?int.tryParse('${w['id']}'),
    ];
  }

  /// Votes on [pr] as the user the token belongs to, who becomes a reviewer
  /// if they aren't one yet.
  Future<void> votePullRequest(PullRequest pr, ReviewVote vote) async {
    final me = await getCurrentUserId();
    await _send('PUT', '${_pullRequestUrl(pr)}/reviewers/$me?api-version=$_apiVersion',
        {'vote': vote.value});
  }

  /// Starts a discussion on [pr] with a comment in Markdown.
  Future<void> createPullRequestThread(PullRequest pr, String content) =>
      _post('${_pullRequestUrl(pr)}/threads?api-version=$_apiVersion', {
        'comments': [
          {'parentCommentId': 0, 'content': content, 'commentType': 'text'},
        ],
        'status': 'active',
      });

  /// Replies to the comment that started [thread] on [pr], in Markdown.
  Future<void> replyToThread(PullRequest pr, PullRequestThread thread, String content) =>
      _post('${_pullRequestUrl(pr)}/threads/${thread.id}/comments?api-version=$_apiVersion', {
        'parentCommentId': thread.comments.first.id,
        'content': content,
        'commentType': 'text',
      });

  /// Marks [thread] on [pr] as resolved (fixed), or active again.
  Future<void> resolveThread(PullRequest pr, PullRequestThread thread, {bool resolved = true}) =>
      _send('PATCH', '${_pullRequestUrl(pr)}/threads/${thread.id}?api-version=$_apiVersion',
          {'status': resolved ? 'fixed' : 'active'});

  String _pullRequestUrl(PullRequest pr) =>
      '$baseUrl/${Uri.encodeComponent(pr.project)}/_apis/git/repositories/'
      '${pr.repositoryId}/pullRequests/${pr.id}';

  Future<Map<String, dynamic>> _get(String url) async {
    final response = await _client.get(Uri.parse(url), headers: _headers);
    return _decode(response);
  }

  Future<Map<String, dynamic>> _post(String url, Object body) => _send('POST', url, body);

  /// Sends [body] as JSON with [method].
  Future<Map<String, dynamic>> _send(String method, String url, Object body) async {
    final request = http.Request(method, Uri.parse(url))
      ..headers.addAll({..._headers, 'Content-Type': 'application/json'})
      ..body = jsonEncode(body);
    return _decode(await http.Response.fromStream(await _client.send(request)));
  }

  Map<String, String> get _headers => {
        'Authorization': _auth,
        'Accept': 'application/json',
      };

  Map<String, dynamic> _decode(http.Response response) {
    _check(response);
    final code = response.statusCode;
    // The timeline of a run that hasn't started yet is empty or null.
    if (code == 204 || response.bodyBytes.isEmpty) return const {};
    try {
      return (jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>?) ??
          const {};
    } on FormatException {
      // Azure DevOps answers with an HTML sign-in page when the PAT is invalid.
      final signIn = response.headers['content-type']?.contains('html') ?? false;
      throw DevOpsException(
          signIn ? DevOpsError.unauthorized : DevOpsError.unexpectedResponse,
          statusCode: code);
    }
  }

  /// Throws when [response] is an error.
  void _check(http.Response response) {
    final code = response.statusCode;
    if (code == 401 || code == 203 || code == 302) {
      throw DevOpsException(DevOpsError.unauthorized, statusCode: code);
    }
    if (code == 404) {
      throw DevOpsException(DevOpsError.notFound, statusCode: code);
    }
    if (code < 200 || code >= 300) {
      String? message;
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['message'] is String) message = body['message'] as String;
      } catch (_) {}
      throw DevOpsException(DevOpsError.http, statusCode: code, serverMessage: message);
    }
  }
}
