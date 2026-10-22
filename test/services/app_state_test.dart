import 'package:devops/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<String?> storedPat() => const FlutterSecureStorage().read(key: 'pat');

  test('load without saved settings uses defaults', () async {
    mockStorage();
    final state = AppState();
    await state.load();
    expect(state.organization, isNull);
    expect(state.projects, isEmpty);
    expect(state.themeMode, ThemeMode.system);
    expect(state.useDynamicColor, isFalse);
    expect(state.locale, isNull);
    expect(state.sendErrorReports, isTrue);
    expect(state.hasPat, isFalse);
    expect(state.isConfigured, isFalse);
  });

  test('load restores saved settings and builds the api', () async {
    mockStorage(prefs: {
      'organization': 'contoso',
      'projects': ['Web', 'Api'],
      'themeMode': ThemeMode.dark.index,
      'useDynamicColor': true,
      'language': 'nl',
    }, secure: {
      'pat': 'secret',
    });
    final state = AppState();
    await state.load();
    expect(state.organization, 'contoso');
    expect(state.projects, ['Web', 'Api']);
    expect(state.themeMode, ThemeMode.dark);
    expect(state.useDynamicColor, isTrue);
    expect(state.locale, const Locale('nl'));
    expect(state.hasPat, isTrue);
    expect(state.isConfigured, isTrue);
    expect(state.api!.baseUrl, 'https://dev.azure.com/contoso');
  });

  test('load ignores an http organization saved by an earlier version', () async {
    mockStorage(prefs: {'organization': 'http://tfs.local/tfs/Default'}, secure: {'pat': 'secret'});
    final state = AppState();
    await state.load();
    expect(state.isConfigured, isFalse);
  });

  test('load migrates the single project of older versions', () async {
    mockStorage(prefs: {'organization': 'contoso', 'project': 'Web'});
    final state = AppState();
    await state.load();
    expect(state.projects, ['Web']);

    await state.setProjects(['Web', 'Api']);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('projects'), ['Web', 'Api']);
    expect(prefs.getString('project'), isNull);
  });

  test('is not configured without a token', () async {
    mockStorage(prefs: {'organization': 'contoso'});
    final state = AppState();
    await state.load();
    expect(state.isConfigured, isFalse);
  });

  test('saveConnection stores the connection and notifies', () async {
    mockStorage();
    final state = AppState();
    await state.load();
    var notified = 0;
    state.addListener(() => notified++);

    await state.saveConnection(organization: 'contoso', pat: 'secret');

    expect(notified, 1);
    expect(state.isConfigured, isTrue);
    expect(state.hasPat, isTrue);
    expect((await SharedPreferences.getInstance()).getString('organization'), 'contoso');
    expect(await storedPat(), 'secret');
  });

  test('saveConnection keeps the projects for the same organization', () async {
    mockStorage(prefs: {
      'organization': 'contoso',
      'projects': ['Web', 'Api'],
    }, secure: {'pat': 'a'});
    final state = AppState();
    await state.load();
    await state.saveConnection(organization: 'contoso', pat: 'b');
    expect(state.projects, ['Web', 'Api']);
    expect((await SharedPreferences.getInstance()).getStringList('projects'), ['Web', 'Api']);
  });

  test('saveConnection forgets the projects for another organization', () async {
    mockStorage(prefs: {
      'organization': 'contoso',
      'projects': ['Web'],
      'project': 'Web',
    }, secure: {'pat': 'a'});
    final state = AppState();
    await state.load();
    await state.saveConnection(organization: 'fabrikam', pat: 'b');
    expect(state.projects, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('projects'), isNull);
    expect(prefs.getString('project'), isNull);
    expect(state.api!.baseUrl, 'https://dev.azure.com/fabrikam');
  });

  test('preference setters persist and notify', () async {
    mockStorage();
    final state = AppState();
    var notified = 0;
    state.addListener(() => notified++);

    await state.setProjects(['Web', 'Api']);
    await state.setThemeMode(ThemeMode.light);
    await state.setUseDynamicColor(true);
    await state.setLocale(const Locale('de'));
    await state.setSendErrorReports(false);

    expect(notified, 5);
    final reloaded = AppState();
    await reloaded.load();
    expect(reloaded.projects, ['Web', 'Api']);
    expect(reloaded.themeMode, ThemeMode.light);
    expect(reloaded.useDynamicColor, isTrue);
    expect(reloaded.locale, const Locale('de'));
    expect(reloaded.sendErrorReports, isFalse);

    await state.setLocale(null);
    await reloaded.load();
    expect(reloaded.locale, isNull);
  });

  test('signOut forgets the token and projects but keeps the organization', () async {
    mockStorage(prefs: {
      'organization': 'contoso',
      'projects': ['Web'],
    }, secure: {'pat': 'a'});
    final state = AppState();
    await state.load();
    var notified = 0;
    state.addListener(() => notified++);

    await state.signOut();

    expect(notified, 1);
    expect(state.isConfigured, isFalse);
    expect(state.hasPat, isFalse);
    expect(state.projects, isEmpty);
    expect(state.organization, 'contoso');
    expect(await storedPat(), isNull);
    expect((await SharedPreferences.getInstance()).getStringList('projects'), isNull);
  });

  test('the api uses the injected http client', () async {
    final fake = FakeDevOps();
    mockStorage(prefs: {'organization': 'contoso'}, secure: {'pat': 'secret'});
    final state = AppState(httpClient: fake.client);
    await state.load();
    final projects = await state.api!.getProjects();
    expect(projects.single.name, 'Contoso');
    expect(fake.requests, hasLength(1));
  });
}
