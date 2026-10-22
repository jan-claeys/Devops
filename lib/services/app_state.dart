import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'devops_api.dart';
import 'logging.dart' as reporting;

final _log = Logger('AppState');

/// Holds the connection settings and exposes a configured [DevOpsApi].
class AppState extends ChangeNotifier {
  AppState({this.httpClient});

  /// HTTP client for every [DevOpsApi]; null uses a default client.
  final http.Client? httpClient;

  static const _orgKey = 'organization';
  static const _projectsKey = 'projects';

  /// Single project stored by versions before multiple projects were supported.
  static const _legacyProjectKey = 'project';
  static const _themeKey = 'themeMode';
  static const _dynamicColorKey = 'useDynamicColor';
  static const _languageKey = 'language';
  static const _errorReportsKey = 'sendErrorReports';
  static const _patKey = 'pat';

  final _secure = const FlutterSecureStorage();

  String? organization;

  /// Projects whose tickets are shown.
  List<String> projects = const [];
  String? _pat;
  ThemeMode themeMode = ThemeMode.system;

  /// Follow the system accent colour (Material You) instead of Azure blue.
  bool useDynamicColor = false;

  /// Language chosen in the settings; null follows the system language.
  Locale? locale;

  /// Send crash and error reports to Sentry; on unless the user opts out.
  bool sendErrorReports = true;
  DevOpsApi? api;

  bool get isConfigured => api != null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    organization = prefs.getString(_orgKey);
    final legacyProject = prefs.getString(_legacyProjectKey);
    projects = prefs.getStringList(_projectsKey) ??
        (legacyProject == null ? const [] : [legacyProject]);
    themeMode = ThemeMode.values[prefs.getInt(_themeKey) ?? ThemeMode.system.index];
    useDynamicColor = prefs.getBool(_dynamicColorKey) ?? false;
    final language = prefs.getString(_languageKey);
    locale = language == null ? null : Locale(language);
    sendErrorReports = prefs.getBool(_errorReportsKey) ?? true;
    reporting.sendErrorReports = sendErrorReports;
    try {
      _pat = await _secure.read(key: _patKey);
    } catch (e, st) {
      _log.warning('Reading the PAT from secure storage failed', e, st);
      _pat = null;
    }
    _buildApi();
  }

  Future<void> saveConnection({required String organization, required String pat}) async {
    final prefs = await SharedPreferences.getInstance();
    if (organization != this.organization) {
      projects = const [];
      await _removeProjects(prefs);
    }
    this.organization = organization;
    _pat = pat;
    await prefs.setString(_orgKey, organization);
    await _secure.write(key: _patKey, value: pat);
    _buildApi();
    notifyListeners();
  }

  Future<void> setProjects(List<String> projects) async {
    this.projects = List.unmodifiable(projects);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_projectsKey, projects);
    await prefs.remove(_legacyProjectKey);
    notifyListeners();
  }

  Future<void> _removeProjects(SharedPreferences prefs) async {
    await prefs.remove(_projectsKey);
    await prefs.remove(_legacyProjectKey);
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

  Future<void> setLocale(Locale? value) async {
    locale = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_languageKey);
    } else {
      await prefs.setString(_languageKey, value.languageCode);
    }
    notifyListeners();
  }

  Future<void> setSendErrorReports(bool value) async {
    sendErrorReports = value;
    reporting.sendErrorReports = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_errorReportsKey, value);
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await _removeProjects(prefs);
    await _secure.delete(key: _patKey);
    _pat = null;
    projects = const [];
    api = null;
    notifyListeners();
  }

  bool get hasPat => _pat != null && _pat!.isNotEmpty;

  void _buildApi() {
    final org = organization;
    final pat = _pat;
    // An http organization saved by an earlier version asks for a new connection.
    api = (org != null && org.isNotEmpty && DevOpsApi.isSecure(org) &&
            pat != null && pat.isNotEmpty)
        ? DevOpsApi(organization: org, pat: pat, client: httpClient)
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
