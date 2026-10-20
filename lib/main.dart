import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/settings_screen.dart';
import 'screens/work_items_screen.dart';
import 'services/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('nl');
  final state = AppState();
  await state.load();
  runApp(AppScope(state: state, child: const DevOpsTicketsApp()));
}

class DevOpsTicketsApp extends StatelessWidget {
  const DevOpsTicketsApp({super.key});

  static const _seed = Color(0xFF0078D4); // Azure blue

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
          title: 'DevOps Tickets',
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
