import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'l10n/l10n.dart';
import 'screens/settings_screen.dart';
import 'screens/work_item_detail_screen.dart';
import 'screens/work_items_screen.dart';
import 'services/app_state.dart';
import 'services/home_widget_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final state = AppState();
  await state.load();
  unawaited(TicketsHomeWidget.registerBackgroundRefresh());
  runApp(AppScope(state: state, child: const DevOpsTicketsApp()));
}

class DevOpsTicketsApp extends StatefulWidget {
  const DevOpsTicketsApp({super.key});

  @override
  State<DevOpsTicketsApp> createState() => _DevOpsTicketsAppState();
}

class _DevOpsTicketsAppState extends State<DevOpsTicketsApp> {
  static const _seed = Color(0xFF0078D4); // Azure blue

  final _navigator = GlobalKey<NavigatorState>();
  StreamSubscription<Uri?>? _widgetClicks;

  @override
  void initState() {
    super.initState();
    // Tapping a ticket in the home screen widget opens its details.
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_openFromWidget, onError: (_) {});
    _widgetClicks = HomeWidget.widgetClicked.listen(_openFromWidget, onError: (_) {});
  }

  @override
  void dispose() {
    _widgetClicks?.cancel();
    super.dispose();
  }

  void _openFromWidget(Uri? uri) {
    final id = TicketsHomeWidget.workItemIdFromUri(uri);
    if (id == null || !AppScope.read(context).isConfigured) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigator.currentState?.push(MaterialPageRoute(
        builder: (_) => WorkItemDetailScreen(id: id),
      ));
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
          home: state.isConfigured
              ? const WorkItemsScreen()
              : const SettingsScreen(isOnboarding: true),
        );
      },
    );
  }
}
