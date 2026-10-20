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

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
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
    return MaterialApp(
      title: 'DevOps Tickets',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: state.themeMode,
      home: state.isConfigured
          ? const WorkItemsScreen()
          : const SettingsScreen(isOnboarding: true),
    );
  }
}
