import 'package:devops/screens/settings_screen.dart';
import 'package:devops/services/app_state.dart';
import 'package:devops/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late FakeDevOps fake;
  late AppState state;

  setUp(() {
    mockStorage();
    fake = FakeDevOps();
    state = AppState(httpClient: fake.client);
  });

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  Future<void> fillAndConnect(WidgetTester tester,
      {String org = 'contoso', String pat = 'secret'}) async {
    await tester.enterText(field(en.organization), org);
    await tester.enterText(field(en.personalAccessToken), pat);
    await tester.tap(find.text(en.connect));
    await tester.pumpAndSettle();
  }

  /// Opens the settings from a home page, as the work items screen does.
  Future<void> openSettings(WidgetTester tester) async {
    await pumpApp(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            child: const Text('home'),
          ),
        ),
      ),
      state: state,
      size: const Size(500, 2000),
    );
    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();
  }

  testWidgets('onboarding only shows the connection form', (tester) async {
    await pumpApp(tester, const SettingsScreen(isOnboarding: true), state: state);
    expect(find.text(en.welcome), findsWidgets);
    expect(find.text(en.onboardingIntro), findsOneWidget);
    expect(find.text(en.tokenScopeHint), findsOneWidget);
    expect(find.text(en.appearance), findsNothing);
    expect(find.text(en.signOut), findsNothing);
  });

  testWidgets('requires organization and token', (tester) async {
    await pumpApp(tester, const SettingsScreen(isOnboarding: true), state: state);
    await tester.tap(find.text(en.connect));
    await tester.pumpAndSettle();
    expect(find.text(en.organizationRequired), findsOneWidget);
    expect(find.text(en.tokenRequired), findsOneWidget);
    expect(fake.requests, isEmpty);
  });

  testWidgets('verifies and saves a working connection', (tester) async {
    await pumpApp(tester, const SettingsScreen(isOnboarding: true), state: state);
    await fillAndConnect(tester, org: '  contoso ', pat: ' secret ');

    expect(fake.requests.single.url.host, 'dev.azure.com');
    expect(state.organization, 'contoso');
    expect(state.isConfigured, isTrue);
    expect(await const FlutterSecureStorage().read(key: 'pat'), 'secret');
  });

  testWidgets('shows the error and keeps the old connection when it fails',
      (tester) async {
    fake.failWith = 401;
    await pumpApp(tester, const SettingsScreen(isOnboarding: true), state: state);
    await fillAndConnect(tester);

    expect(find.text(en.errorUnauthorized), findsOneWidget);
    expect(find.text(en.connect), findsOneWidget);
    expect(state.isConfigured, isFalse);
  });

  testWidgets('closes with a confirmation after saving from the app', (tester) async {
    await openSettings(tester);
    expect(find.text(en.settings), findsWidgets);
    await fillAndConnect(tester);

    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.text(en.connectionSaved), findsOneWidget);
  });

  testWidgets('prefills the organization and mentions a stored token', (tester) async {
    mockStorage(prefs: {'organization': 'contoso'}, secure: {'pat': 'secret'});
    await state.load();
    await openSettings(tester);
    expect(find.widgetWithText(TextFormField, 'contoso'), findsOneWidget);
    expect(find.text(en.tokenAlreadyStored), findsOneWidget);
  });

  testWidgets('changes theme and colour', (tester) async {
    await openSettings(tester);
    await tester.tap(find.text(en.themeDark));
    await tester.tap(find.text(en.colorSystem));
    await tester.pumpAndSettle();
    expect(state.themeMode, ThemeMode.dark);
    expect(state.useDynamicColor, isTrue);
  });

  testWidgets('hides the error reports switch without Sentry', (tester) async {
    await openSettings(tester);
    expect(find.text(en.sendErrorReports), findsNothing);
  });

  testWidgets('turns error reports off', (tester) async {
    errorReportingAvailable = true;
    addTearDown(() => errorReportingAvailable = false);
    await openSettings(tester);
    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isTrue);
    await tester.tap(find.text(en.sendErrorReports));
    await tester.pumpAndSettle();
    expect(state.sendErrorReports, isFalse);
    expect(sendErrorReports, isFalse);
  });

  testWidgets('changes the language', (tester) async {
    await openSettings(tester);
    await tester.tap(find.byType(DropdownMenu<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nederlands').last);
    await tester.pumpAndSettle();
    expect(state.locale, const Locale('nl'));
  });

  testWidgets('signs out and returns to the first screen', (tester) async {
    mockStorage(prefs: {'organization': 'contoso', 'project': 'Web'}, secure: {'pat': 'x'});
    await state.load();
    await openSettings(tester);
    await tester.tap(find.text(en.signOut));
    await tester.pumpAndSettle();

    expect(state.isConfigured, isFalse);
    expect(state.project, isNull);
    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });
}
