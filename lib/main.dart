import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'l10n/l10n.dart';
import 'models/devops_link.dart';
import 'screens/home_screen.dart';
import 'screens/pipeline_run_screen.dart';
import 'screens/pull_request_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/work_item_detail_screen.dart';
import 'services/app_state.dart';
import 'services/home_widget_service.dart';
import 'services/links.dart';
import 'services/logging.dart';
import 'services/run_notifications.dart';
import 'services/shortcuts.dart';

Future<void> main() async {
  await runWithErrorReporting(() async {
    // Inside the error reporting zone, the same zone runApp uses.
    WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting();
    final state = AppState();
    await state.load();
    unawaited(HomeWidgets.registerBackgroundRefresh());
    runApp(AppScope(state: state, child: const DevOpsApp()));
  });
}

class DevOpsApp extends StatefulWidget {
  const DevOpsApp({super.key});

  @override
  State<DevOpsApp> createState() => _DevOpsAppState();
}

class _DevOpsAppState extends State<DevOpsApp> {
  static const _seed = Color(0xFF0078D4); // Azure blue

  final _navigator = GlobalKey<NavigatorState>();
  final _messenger = GlobalKey<ScaffoldMessengerState>();
  final _home = GlobalKey<HomeScreenState>();
  StreamSubscription<Uri?>? _widgetClicks;
  StreamSubscription<String>? _links;
  late final RunNotifications _runNotifications;

  @override
  void initState() {
    super.initState();
    _runNotifications = RunNotifications(AppScope.read(context))..start();
    if (Links.isSupported) _links = Links.incoming().listen(_openLink);
    // Tapping a row in a home screen widget, or a run notification, opens
    // its details; the notification of several runs the pipelines. Elsewhere
    // the event channel has no implementation and listening reports a
    // MissingPluginException straight to FlutterError, bypassing onError.
    if (!HomeWidgets.isSupported) return;
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_openFromWidget, onError: (_) {});
    _widgetClicks = HomeWidget.widgetClicked.listen(_openFromWidget, onError: (_) {});
  }

  @override
  void dispose() {
    _widgetClicks?.cancel();
    _links?.cancel();
    _runNotifications.dispose();
    super.dispose();
  }

  /// A tap on a home screen widget row or a run notification, or an app
  /// shortcut.
  void _openFromWidget(Uri? uri) {
    if (uri?.toString() == RunNotifications.pipelinesUri) {
      return _showHome((home) => home.showPipelines());
    }
    if (AppShortcut.fromUri(uri) case final shortcut?) {
      return _showHome((home) => home.showShortcut(shortcut));
    }
    if (HomeWidgets.linkFromUri(uri) case final link?) _open(link);
  }

  /// Shows a tab of the home screen, closing whatever is opened on top of it.
  void _showHome(void Function(HomeScreenState home) show) {
    if (!AppScope.read(context).isConfigured) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigator.currentState?.popUntil((r) => r.isFirst);
      if (_home.currentState case final home?) show(home);
    });
  }

  /// Opens the work item, pull request or run a link opened with the app, or
  /// shared to it, points to.
  void _openLink(String text) {
    final api = AppScope.read(context).api;
    if (api == null) return;
    switch (ParsedLink.parse(text, baseUrl: api.baseUrl)) {
      case final DevOpsLink link:
        _open(link);
      case ForeignLink():
        _showMessage((l10n) => l10n.linkOtherOrganization);
      case null:
        _showMessage((l10n) => l10n.linkNotSupported);
    }
  }

  void _open(DevOpsLink link) {
    if (!AppScope.read(context).isConfigured) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigator.currentState?.push(MaterialPageRoute(
        builder: (_) => switch (link) {
          DevOpsLink(kind: DevOpsLinkKind.workItem) => WorkItemDetailScreen(id: link.id),
          DevOpsLink(kind: DevOpsLinkKind.pullRequest) =>
            PullRequestScreen(project: link.project!, id: link.id),
          _ => PipelineRunScreen(project: link.project!, id: link.id, kind: link.runKind),
        },
      ));
    });
  }

  void _showMessage(String Function(AppLocalizations) message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _navigator.currentContext;
      if (context == null) return;
      _messenger.currentState?.showSnackBar(SnackBar(content: Text(message(context.l10n))));
    });
  }

  ThemeData _theme(Brightness brightness, ColorScheme? dynamicScheme) {
    // Reseed from the system accent so every Material 3 colour role is filled in.
    final scheme = ColorScheme.fromSeed(
      seedColor: dynamicScheme?.primary ?? _seed,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      cardTheme: const CardThemeData(margin: EdgeInsets.zero),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final useDynamic = state.useDynamicColor;
        return MaterialApp(
          navigatorKey: _navigator,
          scaffoldMessengerKey: _messenger,
          // Records screen changes as breadcrumbs for error reports.
          navigatorObservers: [SentryNavigatorObserver()],
          title: 'DevOps',
          // Without a chosen language Flutter picks the first supported system
          // language, falling back to English (first in supportedLocales).
          locale: state.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          theme: _theme(Brightness.light, useDynamic ? lightDynamic : null),
          darkTheme: _theme(Brightness.dark, useDynamic ? darkDynamic : null),
          themeMode: state.themeMode,
          // Onboarding also asks for the projects before showing tickets.
          home: state.isConfigured && state.projects.isNotEmpty
              ? HomeScreen(key: _home)
              : const SettingsScreen(isOnboarding: true),
        );
      },
    );
  }
}
