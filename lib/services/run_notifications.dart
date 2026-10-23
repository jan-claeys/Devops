import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n.dart';
import '../models/pipeline_run.dart';
import '../models/run_estimates.dart';
import '../widgets/pipeline_visuals.dart';
import 'app_state.dart';
import 'devops_api.dart';
import 'logging.dart';

final _log = Logger('RunNotifications');

/// Shows the progress of running pipeline runs in Android notifications,
/// on Android 16 as Live Updates with a chip in the status bar. Several
/// runs at once share one notification; each shows its own result.
///
/// Only follows runs once the app is opened: it polls while the app is open
/// and, as long as a run is running, in the background, where a foreground
/// service keeps the app alive. Kotlin (RunNotifications.kt) only shows
/// what is handed to it.
class RunNotifications {
  RunNotifications(this._state);

  /// How often running runs are refreshed.
  static const refreshInterval = Duration(seconds: 15);

  static const _channel = MethodChannel('devops/run_notifications');

  /// Set once the app asked for permission to post notifications by itself.
  static const _askedKey = 'runNotificationsAsked';

  /// Gives statuses without a colour of their own a neutral grey.
  static final _scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF0078D4));

  /// Only Android shows them.
  static bool get isSupported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  final AppState _state;
  AppLifecycleListener? _lifecycle;
  Timer? _refresh;

  /// The connection and settings the shown runs are for.
  String? _settings;

  /// Increased by every check, so only the latest one shows its result.
  int _generation = 0;

  /// Keys of the runs shown as running, whose result shows once they finish.
  Set<String> _running = {};

  /// Share of the tasks that finished, by key, of the running runs that
  /// have no last duration to estimate from.
  Map<String, double> _taskProgress = {};

  void start() {
    if (!isSupported) return;
    _state.addListener(_onSettingsChanged);
    // Opening the app again starts following the runs that run by then.
    _lifecycle = AppLifecycleListener(onResume: _check);
    _onSettingsChanged();
  }

  void dispose() {
    _refresh?.cancel();
    _lifecycle?.dispose();
    _state.removeListener(_onSettingsChanged);
  }

  /// Asks to post notifications; false when they don't show.
  static Future<bool> requestPermission() async {
    try {
      return await _channel.invokeMethod<bool>('requestPermission') ?? false;
    } on PlatformException catch (e, st) {
      logFailure(_log, 'Asking to post notifications failed', e, st);
      return false;
    }
  }

  void _onSettingsChanged() {
    final settings = [
      _state.organization,
      ..._state.projects,
      _state.runNotifications.name,
      _state.locale?.languageCode,
    ].join('|');
    if (settings == _settings) return;
    _settings = settings;
    _running = {};
    _check();
  }

  static String _key(PipelineRun r) => _uri(r).toString();

  /// Opens the pipelines tab from the notification of several runs.
  static const pipelinesUri = 'devops://pipelines';

  /// What a tap opens, as a home screen widget row: devops://build/Contoso/67.
  static Uri _uri(PipelineRun r) =>
      Uri(scheme: 'devops', host: r.kind.name, pathSegments: [r.project, '${r.id}']);

  static bool _isFollowed(PipelineRun r) => switch (r.status) {
        RunStatus.queued || RunStatus.running || RunStatus.cancelling => true,
        _ => false,
      };

  Future<void> _check() async {
    _refresh?.cancel();
    final generation = ++_generation;
    final api = _state.api;
    final projects = _state.projects;
    final scope = _state.runNotifications;
    final l10n = lookupAppLocalizations(resolveLocale(_state.locale));
    if (api == null || projects.isEmpty || scope == RunNotificationScope.off) {
      _running = {};
      await _show(const [], const [], l10n);
      return;
    }
    try {
      final runs = await _load(api, projects, scope);
      final running = runs.where(_isFollowed).toList();
      final estimates = RunEstimates(runs);
      final taskProgress = await _loadTaskProgress(api, running, estimates);
      if (generation != _generation) return;
      _taskProgress = taskProgress;
      final finished = [
        for (final r in runs)
          if (r.status.isFinished && _running.contains(_key(r))) r,
      ];
      if (running.isNotEmpty) await _askPermissionOnce();
      if (generation != _generation) return;
      _running = {for (final r in running) _key(r)};
      await _show([
        if (running case [final r]) _runningPayload(r, _progress(r, estimates), l10n),
        if (running.length > 1) _summaryPayload(running, estimates, l10n),
      ], [
        for (final r in finished) _finishedPayload(r, l10n),
      ], l10n);
    } catch (e, st) {
      // A network hiccup keeps showing the last progress until the next try.
      logFailure(_log, 'Loading the runs to notify about failed', e, st);
    }
    if (generation == _generation && _running.isNotEmpty) {
      _refresh = Timer(refreshInterval, _check);
    }
  }

  /// Asks for permission the first time there is something to show; the
  /// settings ask again when the user turns the notifications on.
  Future<void> _askPermissionOnce() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_askedKey) ?? false) return;
    await prefs.setBool(_askedKey, true);
    await requestPermission();
  }

  /// The latest runs in [projects], of the user only for
  /// [RunNotificationScope.mine], newest first.
  Future<List<PipelineRun>> _load(
      DevOpsApi api, List<String> projects, RunNotificationScope scope) async {
    final me = scope == RunNotificationScope.mine ? await api.getCurrentUserId() : null;
    // Without access to release management, the builds still show.
    final releases = api.getReleases(projects: projects).catchError((Object e, StackTrace st) {
      logFailure(_log, 'Loading releases failed', e, st);
      return <PipelineRun>[];
    });
    final builds = await api.getPipelineRuns(projects: projects, requestedFor: me);
    return [
      ...builds,
      for (final r in await releases)
        if (me == null || r.requestedFor?.id == me) r,
    ]..sort((a, b) => (b.queueTime ?? DateTime(0)).compareTo(a.queueTime ?? DateTime(0)));
  }

  /// Fetches the timelines of the running runs that [estimates] can't
  /// estimate, as the pipelines screen does.
  Future<Map<String, double>> _loadTaskProgress(
      DevOpsApi api, List<PipelineRun> runs, RunEstimates estimates) async {
    final unestimated = [
      for (final r in runs)
        if (r.status == RunStatus.running && estimates.of(r) == null) r,
    ];
    final progress = await Future.wait([
      for (final r in unestimated)
        (r.isRelease
                ? api.getRelease(r.project, r.id).then((p) => p.$2.runningStagesProgress)
                : api.getTimeline(r.project, r.id).then((t) => t.progress))
            .catchError((Object e, StackTrace st) {
          logFailure(_log, 'Loading timeline of ${r.kind.name} ${r.id} failed', e, st);
          // Keeps the last known progress, so the bar doesn't jump back.
          return _taskProgress[_key(r)];
        }),
    ]);
    return {
      for (final (i, r) in unestimated.indexed)
        if (progress[i] case final double value) _key(r): value,
    };
  }

  /// Between 0 and 1, or null when unknown. An estimate stops just short of
  /// full, as a run can take longer than the last one.
  double? _progress(PipelineRun r, RunEstimates estimates) {
    if (r.status != RunStatus.running) return null;
    if (estimates.of(r) case final estimate?) {
      final now = DateTime.now();
      var elapsed = 0, expected = 0;
      for (final e in estimate) {
        elapsed += now.difference(e.start).inMilliseconds;
        expected += e.expected.inMilliseconds;
      }
      return expected <= 0 ? 0.99 : (elapsed / expected).clamp(0.0, 0.99);
    }
    return _taskProgress[_key(r)];
  }

  static Map<String, Object?> _payload(PipelineRun r, AppLocalizations l10n) => {
        'key': _key(r),
        'title': r.pipelineName,
        'text': [runStatusLabel(l10n, r.status), ?(r.branch ?? r.artifactVersion), r.buildNumber]
            .join(' · '),
        'uri': _uri(r).toString(),
        'color': _hex(RunStatusStyle.of(r.status, _scheme).color),
      };

  static Map<String, Object?> _runningPayload(
          PipelineRun r, double? progress, AppLocalizations l10n) =>
      {
        ..._payload(r, l10n),
        'progress': progress == null ? -1 : (progress * 100).floor(),
        'startTime': r.startTime?.millisecondsSinceEpoch,
      };

  /// One notification for several [running] runs at once, so the status
  /// bar shows a single chip. Its progress is that of the run furthest from
  /// done; a queued run hasn't started yet.
  Map<String, Object?> _summaryPayload(
      List<PipelineRun> running, RunEstimates estimates, AppLocalizations l10n) {
    final progress = [
      for (final r in running)
        if (r.status == RunStatus.queued) 0.0 else ?_progress(r, estimates),
    ];
    final starts = running.map((r) => r.startTime).nonNulls;
    return {
      'key': pipelinesUri,
      'title': l10n.runNotificationsRunning(running.length),
      'text': running.map((r) => r.pipelineName).join(', '),
      'uri': pipelinesUri,
      'color': _hex(RunStatusStyle.of(RunStatus.running, _scheme).color),
      'progress': progress.isEmpty ? -1 : (progress.reduce(min) * 100).floor(),
      // The chip shows how long the first of them has been running.
      'startTime': starts.isEmpty
          ? null
          : starts.reduce((a, b) => a.isBefore(b) ? a : b).millisecondsSinceEpoch,
    };
  }

  static Map<String, Object?> _finishedPayload(PipelineRun r, AppLocalizations l10n) => {
        ..._payload(r, l10n),
        'failed': r.status == RunStatus.failed || r.status == RunStatus.canceled,
      };

  static String _hex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  Future<void> _show(List<Map<String, Object?>> running, List<Map<String, Object?>> finished,
      AppLocalizations l10n) async {
    try {
      await _channel.invokeMethod('update', {
        'running': running,
        'finished': finished,
        'channelName': l10n.runNotificationChannel,
      });
    } on PlatformException catch (e, st) {
      logFailure(_log, 'Showing the run notifications failed', e, st);
    }
  }
}
