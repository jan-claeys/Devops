import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:logging/logging.dart';

import '../l10n/l10n.dart';
import '../models/work_item.dart';
import 'app_state.dart';
import 'devops_api.dart';
import 'logging.dart';

final _log = Logger('TicketsHomeWidget');

/// Feeds the Android home screen widget with my open work items.
///
/// The widget itself (TicketsWidgetProvider.kt) only renders what is stored
/// here; fetching always happens in Dart, either from the app or from the
/// background callback when the widget asks for a refresh.
class TicketsHomeWidget {
  static const _androidName = 'TicketsWidgetProvider';

  /// Max number of tickets handed to the widget.
  static const _maxItems = 50;

  /// Only Android has a home screen widget (TicketsWidgetProvider.kt).
  static bool get isSupported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Opened when a ticket in the widget is tapped, e.g. devops://workitem/123.
  static int? workItemIdFromUri(Uri? uri) {
    if (uri == null || uri.host != 'workitem' || uri.pathSegments.isEmpty) return null;
    return int.tryParse(uri.pathSegments.first);
  }

  static Future<void> registerBackgroundRefresh() async {
    try {
      await HomeWidget.registerInteractivityCallback(homeWidgetBackgroundCallback);
    } catch (_) {
      // Not supported on this platform.
    }
  }

  /// Stores [items] for [projects] and redraws the widget. Without [items]
  /// the previously stored tickets stay visible, e.g. next to an [error].
  static Future<void> update({
    required List<String> projects,
    List<WorkItem>? items,
    String? error,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>(
          'project', projects.isEmpty ? null : projects.join(', '));
      if (items != null) {
        final data = [
          for (final w in items.take(_maxItems))
            {'id': w.id, 'title': w.title, 'state': w.state, 'type': w.type},
        ];
        await HomeWidget.saveWidgetData<String>('items', jsonEncode(data));
        await HomeWidget.saveWidgetData<int>('count', items.length);
      }
      await HomeWidget.saveWidgetData<String>('error', error);
      await HomeWidget.saveWidgetData<String>(
          'updatedAt', DateTime.now().millisecondsSinceEpoch.toString());
      await HomeWidget.updateWidget(androidName: _androidName);
    } catch (_) {
      // No home widget support (e.g. desktop/web); nothing to update.
    }
  }

  /// Fetches my open work items with the saved connection and updates the widget.
  static Future<void> refresh([AppState? state]) async {
    if (state == null) {
      state = AppState();
      await state.load();
    }
    final api = state.api;
    final projects = state.projects;
    final l10n = lookupAppLocalizations(resolveLocale(state.locale));
    if (api == null || projects.isEmpty) {
      await update(projects: const [], items: const [], error: l10n.widgetSetupRequired);
      return;
    }
    try {
      final items = await api.queryWorkItems(
          projects: projects, scope: WorkItemScope.assignedToMe, openOnly: true);
      await update(projects: projects, items: items);
    } catch (e, st) {
      logFailure(_log, 'Refreshing the home widget failed', e, st);
      await update(projects: projects, error: l10n.error(e));
    }
  }
}

/// Runs in a background isolate when the widget's refresh button is tapped
/// or its data has gone stale.
@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLogging();
  await TicketsHomeWidget.refresh();
}
