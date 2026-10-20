import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'devops_api.dart';

/// Holds the connection settings and exposes a configured [DevOpsApi].
class AppState extends ChangeNotifier {
  static const _orgKey = 'organization';
  static const _projectKey = 'project';
  static const _themeKey = 'themeMode';
  static const _dynamicColorKey = 'useDynamicColor';
  static const _patKey = 'pat';

  final _secure = const FlutterSecureStorage();

  String? organization;
  String? project;
  String? _pat;
  ThemeMode themeMode = ThemeMode.system;

  /// Follow the system accent colour (Material You) instead of Azure blue.
  bool useDynamicColor = false;
  DevOpsApi? api;

  bool get isConfigured => api != null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    organization = prefs.getString(_orgKey);
    project = prefs.getString(_projectKey);
    themeMode = ThemeMode.values[prefs.getInt(_themeKey) ?? ThemeMode.system.index];
    useDynamicColor = prefs.getBool(_dynamicColorKey) ?? false;
    try {
      _pat = await _secure.read(key: _patKey);
    } catch (_) {
      _pat = null;
    }
    _buildApi();
  }

  Future<void> saveConnection({required String organization, required String pat}) async {
    final prefs = await SharedPreferences.getInstance();
    if (organization != this.organization) {
      project = null;
      await prefs.remove(_projectKey);
    }
    this.organization = organization;
    _pat = pat;
    await prefs.setString(_orgKey, organization);
    await _secure.write(key: _patKey, value: pat);
    _buildApi();
    notifyListeners();
  }

  Future<void> selectProject(String project) async {
    this.project = project;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_projectKey, project);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setUseDynamicColor(bool value) async {
    useDynamicColor = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dynamicColorKey, value);
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_projectKey);
    await _secure.delete(key: _patKey);
    _pat = null;
    project = null;
    api = null;
    notifyListeners();
  }

  bool get hasPat => _pat != null && _pat!.isNotEmpty;

  void _buildApi() {
    final org = organization;
    final pat = _pat;
    api = (org != null && org.isNotEmpty && pat != null && pat.isNotEmpty)
        ? DevOpsApi(organization: org, pat: pat)
        : null;
  }
}

/// Makes [AppState] available to the widget tree.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
