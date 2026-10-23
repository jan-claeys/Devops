import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:logging/logging.dart';

import '../l10n/l10n.dart';
import '../models/dashboard_summary.dart';
import '../models/devops_link.dart';
import '../models/pipeline_run.dart';
import '../models/pull_request.dart';
import '../models/work_item.dart';
import '../widgets/pipeline_visuals.dart';
import '../widgets/work_item_visuals.dart';
import 'app_state.dart';
import 'devops_api.dart';
import 'logging.dart';

final _log = Logger('HomeWidgets');

/// The Android home screen widgets. Each shows a list of rows; Kotlin
/// (ListWidgetProvider.kt) only renders what is stored here.
enum HomeWidgetKind {
  /// My open work items.
  tickets('TicketsWidgetProvider', ''),

  /// Pull requests waiting for my review.
  pullRequests('PullRequestsWidgetProvider', 'pullRequests.'),

  /// The latest run of each pipeline on each branch.
  pipelines('PipelinesWidgetProvider', 'pipelines.');

  const HomeWidgetKind(this.androidName, this.keyPrefix);

  final String androidName;

  /// Prefix of the stored keys, as in ListWidget.kt. The tickets widget
  /// keeps the unprefixed keys it had before there were other widgets.
  final String keyPrefix;
}

/// Feeds the Android home screen widgets.
///
/// Fetching always happens in Dart, either from the app or from the
/// background callback when a widget asks for a refresh.
class HomeWidgets {
  /// Max number of rows handed to a widget.
  static const _maxItems = 50;

  /// Bar colour of a pull request row: Azure blue.
  static const _pullRequestColor = Color(0xFF0078D4);

  /// Gives statuses without a colour of their own a neutral grey.
  static final _scheme = ColorScheme.fromSeed(seedColor: _pullRequestColor);

  /// Only Android has home screen widgets.
  static bool get isSupported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// What a tapped row opens: devops://workitem/123,
  /// devops://pullrequest/Contoso/45, devops://build/Contoso/67 or
  /// devops://release/Contoso/89.
  static DevOpsLink? linkFromUri(Uri? uri) {
    if (uri == null || uri.scheme != 'devops') return null;
    final segments = uri.pathSegments;
    final id = segments.isEmpty ? null : int.tryParse(segments.last);
    if (id == null) return null;
    if (uri.host == 'workitem') return segments.length == 1 ? DevOpsLink(DevOpsLinkKind.workItem, id) : null;
    final kind = switch (uri.host) {
      'pullrequest' => DevOpsLinkKind.pullRequest,
      'build' => DevOpsLinkKind.build,
      'release' => DevOpsLinkKind.release,
      _ => null,
    };
    if (kind == null || segments.length != 2) return null;
    return DevOpsLink(kind, id, project: segments.first);
  }

  static Uri _uri(String host, [String? project, int? id]) =>
      Uri(scheme: 'devops', host: host, pathSegments: [?project, ?id?.toString()]);

  static Future<void> registerBackgroundRefresh() async {
    try {
      await HomeWidget.registerInteractivityCallback(homeWidgetBackgroundCallback);
    } catch (_) {
      // Not supported on this platform.
    }
  }

  /// Stores my open [items] for the tickets widget.
  static Future<void> updateTickets({
    required List<String> projects,
    List<WorkItem>? items,
    String? error,
  }) =>
      _update(
        HomeWidgetKind.tickets,
        projects: projects,
        count: items?.length,
        error: error,
        rows: items == null
            ? null
            : [
                for (final w in items.take(_maxItems))
                  {
                    'id': w.id,
                    'title': w.title,
                    'meta': ['#${w.id}', w.type, w.state].where((s) => s.isNotEmpty).join(' · '),
                    'color': _hex(WorkItemTypeStyle.of(w.type).color),
                    'uri': _uri('workitem', null, w.id).toString(),
                  },
              ],
      );

  /// Stores the pull requests waiting for my review, as in
  /// [DashboardSummary.toReview].
  static Future<void> updatePullRequests({
    required List<String> projects,
    List<PullRequest>? toReview,
    String? error,
  }) =>
      _update(
        HomeWidgetKind.pullRequests,
        projects: projects,
        count: toReview?.length,
        error: error,
        rows: toReview == null
            ? null
            : [
                for (final pr in toReview.take(_maxItems))
                  {
                    'id': pr.id,
                    'title': pr.title,
                    'meta': ['!${pr.id}', pr.repositoryName, ?pr.createdBy?.displayName]
                        .where((s) => s.isNotEmpty)
                        .join(' · '),
                    'color': _hex(_pullRequestColor),
                    'uri': _uri('pullrequest', pr.project, pr.id).toString(),
                  },
              ],
      );

  /// Stores the latest of [runs] of each pipeline on each branch, newest
  /// first; the count is how many of them failed.
  static Future<void> updatePipelines({
    required List<String> projects,
    List<PipelineRun>? runs,
    String? error,
    required AppLocalizations l10n,
  }) {
    final latest = runs == null ? null : latestPerPipeline(runs);
    return _update(
      HomeWidgetKind.pipelines,
      projects: projects,
      count: latest?.where((r) => r.status == RunStatus.failed).length,
      error: error,
      rows: latest == null
          ? null
          : [
              for (final r in latest.take(_maxItems))
                {
                  // Builds and releases number apart.
                  'id': r.isRelease ? -r.id : r.id,
                  'title': r.pipelineName,
                  'meta': [runStatusLabel(l10n, r.status), ?(r.branch ?? r.artifactVersion)]
                      .join(' · '),
                  'color': _hex(RunStatusStyle.of(r.status, _scheme).color),
                  'uri': _uri(r.isRelease ? 'release' : 'build', r.project, r.id).toString(),
                },
            ],
    );
  }

  /// The newest run of each pipeline on each branch, newest first.
  static List<PipelineRun> latestPerPipeline(List<PipelineRun> runs) {
    final seen = <Object>{};
    final sorted = [...runs]
      ..sort((a, b) => (b.queueTime ?? DateTime(0)).compareTo(a.queueTime ?? DateTime(0)));
    return [
      for (final r in sorted)
        if (seen.add((r.kind, r.project, r.definitionId ?? r.pipelineName, r.branch))) r,
    ];
  }

  static String _hex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  /// Stores [rows] for [projects] and redraws the widget. Without [rows]
  /// the previously stored rows stay visible, e.g. next to an [error].
  static Future<void> _update(
    HomeWidgetKind kind, {
    required List<String> projects,
    List<Map<String, Object?>>? rows,
    int? count,
    String? error,
  }) async {
    final p = kind.keyPrefix;
    try {
      await HomeWidget.saveWidgetData<String>(
          '${p}project', projects.isEmpty ? null : projects.join(', '));
      if (rows != null) {
        await HomeWidget.saveWidgetData<String>('${p}items', jsonEncode(rows));
        await HomeWidget.saveWidgetData<int>('${p}count', count ?? rows.length);
      }
      await HomeWidget.saveWidgetData<String>('${p}error', error);
      await HomeWidget.saveWidgetData<String>(
          '${p}updatedAt', DateTime.now().millisecondsSinceEpoch.toString());
      await HomeWidget.updateWidget(androidName: kind.androidName);
    } catch (_) {
      // No home widget support (e.g. desktop/web); nothing to update.
    }
  }

  /// Fetches the data of the widget of [kind], or of all widgets, with the
  /// saved connection and updates them.
  static Future<void> refresh({HomeWidgetKind? kind, AppState? state}) async {
    if (state == null) {
      state = AppState();
      await state.load();
    }
    final kinds = kind == null ? HomeWidgetKind.values : [kind];
    await Future.wait([for (final k in kinds) _refresh(k, state)]);
  }

  static Future<void> _refresh(HomeWidgetKind kind, AppState state) async {
    final api = state.api;
    final projects = state.projects;
    final l10n = lookupAppLocalizations(resolveLocale(state.locale));
    if (api == null || projects.isEmpty) {
      final error = l10n.widgetSetupRequired;
      await switch (kind) {
        HomeWidgetKind.tickets => updateTickets(projects: const [], items: const [], error: error),
        HomeWidgetKind.pullRequests =>
          updatePullRequests(projects: const [], toReview: const [], error: error),
        HomeWidgetKind.pipelines =>
          updatePipelines(projects: const [], runs: const [], error: error, l10n: l10n),
      };
      return;
    }
    try {
      switch (kind) {
        case HomeWidgetKind.tickets:
          final items = await api.queryWorkItems(
              projects: projects, scope: WorkItemScope.assignedToMe, openOnly: true);
          await updateTickets(projects: projects, items: items);
        case HomeWidgetKind.pullRequests:
          final pullRequests =
              await api.getPullRequests(projects: projects, scope: PullRequestScope.reviewing);
          // Known by now: the reviewing scope asked for it.
          final me = await api.getCurrentUserId();
          final summary = DashboardSummary(pullRequests: pullRequests, me: me);
          await updatePullRequests(projects: projects, toReview: summary.toReview);
        case HomeWidgetKind.pipelines:
          // Without access to release management, the builds still show.
          final releases =
              api.getReleases(projects: projects).catchError((Object e, StackTrace st) {
            logFailure(_log, 'Loading releases for the home widget failed', e, st);
            return <PipelineRun>[];
          });
          final builds = await api.getPipelineRuns(projects: projects);
          await updatePipelines(
              projects: projects, runs: [...builds, ...await releases], l10n: l10n);
      }
    } catch (e, st) {
      logFailure(_log, 'Refreshing the ${kind.name} home widget failed', e, st);
      final message = l10n.error(e);
      await switch (kind) {
        HomeWidgetKind.tickets => updateTickets(projects: projects, error: message),
        HomeWidgetKind.pullRequests => updatePullRequests(projects: projects, error: message),
        HomeWidgetKind.pipelines => updatePipelines(projects: projects, error: message, l10n: l10n),
      };
    }
  }
}

/// Runs in a background isolate when a widget's refresh button is tapped
/// or its data has gone stale, with `devops://refresh/<kind>`. The tickets
/// widget asked with plain devops://refresh before there were others.
@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLogging();
  final name = uri?.pathSegments.firstOrNull;
  await HomeWidgets.refresh(
      kind: HomeWidgetKind.values.where((k) => k.name == name).firstOrNull ??
          HomeWidgetKind.tickets);
}
