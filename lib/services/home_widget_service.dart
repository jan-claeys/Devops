import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../models/work_item.dart';
import 'app_state.dart';
import 'devops_api.dart';

/// Feeds the Android home screen widget with my open work items.
///
/// The widget itself (TicketsWidgetProvider.kt) only renders what is stored
/// here; fetching always happens in Dart, either from the app or from the
/// background callback when the widget asks for a refresh.
class TicketsHomeWidget {
  static const _androidName = 'TicketsWidgetProvider';

  /// Max number of tickets handed to the widget.
  static const _maxItems = 50;

  /// Opened when a ticket in the widget is tapped, e.g. devopstickets://workitem/123.
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

  /// Stores [items] for [project] and redraws the widget. Without [items]
  /// the previously stored tickets stay visible, e.g. next to an [error].
  static Future<void> update({
    required String? project,
    List<WorkItem>? items,
    String? error,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('project', project);
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
    final project = state.project;
    if (api == null || project == null) {
      await update(project: null, items: const [], error:'Open de app om in te stellen');
      return;
    }
    try {
      final items = await api.queryWorkItems(
          project: project, scope: WorkItemScope.assignedToMe, openOnly: true);
      await update(project: project, items: items);
    } catch (e) {
      await update(project: project, error: e.toString());
    }
  }
}

/// Runs in a background isolate when the widget's refresh button is tapped
/// or its data has gone stale.
@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  await TicketsHomeWidget.refresh();
}
