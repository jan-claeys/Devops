import 'pipeline_run.dart';

/// What a link opens in the app.
enum DevOpsLinkKind { workItem, pullRequest, build, release }

/// The result of reading a link: an item of the organization, or a link to
/// another organization.
sealed class ParsedLink {
  const ParsedLink();

  /// Reads the first link in [text], such as a URL shared from another app,
  /// against the organization at [baseUrl]. Null when [text] has no link to a
  /// work item, pull request, build or release.
  static ParsedLink? parse(String text, {required String baseUrl}) {
    final match = RegExp(r'https?://\S+').firstMatch(text);
    final uri = match == null ? null : Uri.tryParse(match[0]!);
    if (uri == null) return null;
    final base = Uri.parse(baseUrl);
    final (organization, rest) = _split(uri, base.pathSegments.length);
    final link = DevOpsLink._fromPath(rest, uri.queryParameters);
    if (link == null) return null;
    return organization == _split(base, base.pathSegments.length).$1
        ? link
        : const ForeignLink();
  }

  /// The organization of [uri], as a key to compare, and the path after it.
  /// [baseSegments] is how many segments the organization's own path has on
  /// a server.
  static (String, List<String>) _split(Uri uri, int baseSegments) {
    final segments = [...uri.pathSegments.where((s) => s.isNotEmpty)];
    final host = uri.host.toLowerCase();
    // myorg.visualstudio.com and dev.azure.com/myorg are the same organization.
    if (host == 'dev.azure.com' && segments.isNotEmpty) {
      return ('azure/${segments.first.toLowerCase()}', segments.sublist(1));
    }
    if (host.endsWith('.visualstudio.com')) {
      final rest = segments.firstOrNull?.toLowerCase() == 'defaultcollection'
          ? segments.sublist(1)
          : segments;
      return ('azure/${host.split('.').first}', rest);
    }
    final n = baseSegments.clamp(0, segments.length);
    final collection = segments.take(n).join('/').toLowerCase();
    return ('$host:${uri.port}/$collection', segments.sublist(n));
  }
}

/// A link to an item in another organization than the one signed in to.
final class ForeignLink extends ParsedLink {
  const ForeignLink();
}

/// A work item, pull request, build or release of the organization.
final class DevOpsLink extends ParsedLink {
  const DevOpsLink(this.kind, this.id, {this.project});

  final DevOpsLinkKind kind;
  final int id;

  /// Null for a work item, whose id is unique in the organization.
  final String? project;

  RunKind get runKind => kind == DevOpsLinkKind.release ? RunKind.release : RunKind.build;

  /// From the path after the organization: the project, unless left out,
  /// then for example `_workitems/edit/12` or `_git/repo/pullrequest/34`.
  static DevOpsLink? _fromPath(List<String> path, Map<String, String> query) {
    const markers = {'_workitems', '_git', '_build', '_release', '_releaseprogress'};
    final lower = [for (final s in path) s.toLowerCase()];
    final m = lower.indexWhere(markers.contains);
    if (m < 0 || m > 1) return null;
    final project = m == 1 ? path[0] : null;
    String? at(int i) => i < lower.length ? lower[i] : null;

    switch (lower[m]) {
      case '_workitems' when at(m + 1) == 'edit':
        final id = int.tryParse(at(m + 2) ?? '');
        return id == null ? null : DevOpsLink(DevOpsLinkKind.workItem, id);
      case '_git' when at(m + 2) == 'pullrequest':
        final id = int.tryParse(at(m + 3) ?? '');
        // Without a project, the repository is named after it.
        return id == null
            ? null
            : DevOpsLink(DevOpsLinkKind.pullRequest, id, project: project ?? path[m + 1]);
      case '_build' when at(m + 1) == 'results' && project != null:
        final id = int.tryParse(query['buildId'] ?? '');
        return id == null ? null : DevOpsLink(DevOpsLinkKind.build, id, project: project);
      case '_release' || '_releaseprogress' when project != null:
        final id = int.tryParse(query['releaseId'] ?? '');
        return id == null ? null : DevOpsLink(DevOpsLinkKind.release, id, project: project);
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is DevOpsLink && other.kind == kind && other.id == id && other.project == project;

  @override
  int get hashCode => Object.hash(kind, id, project);

  @override
  String toString() => 'DevOpsLink($kind, $id, project: $project)';
}
