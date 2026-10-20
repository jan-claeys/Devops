import 'package:devops/l10n/l10n.dart';
import 'package:devops/services/devops_api.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  test('resolveLocale prefers system languages and falls back to English', () {
    expect(resolveLocale(null, const [Locale('nl', 'BE')]), const Locale('nl'));
    expect(resolveLocale(null, const [Locale('sw'), Locale('de')]), const Locale('de'));
    expect(resolveLocale(null, const [Locale('sw')]), const Locale('en'));
    expect(resolveLocale(null, const []), const Locale('en'));
    expect(resolveLocale(const Locale('fr'), const [Locale('nl')]), const Locale('fr'));
    expect(resolveLocale(const Locale('sw'), const [Locale('nl')]), const Locale('nl'));
  });

  test('every supported language has a name in the picker', () {
    expect(languageNames.keys.toSet(),
        AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet());
  });

  test('every language loads its translations', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      expect(l10n.localeName, locale.languageCode);
      expect(l10n.settings, isNotEmpty);
    }
  });

  group('error', () {
    test('translates the known error kinds', () {
      expect(en.error(DevOpsException(DevOpsError.unauthorized, statusCode: 401)),
          en.errorUnauthorized);
      expect(en.error(DevOpsException(DevOpsError.notFound, statusCode: 404)),
          en.errorNotFound);
      expect(en.error(DevOpsException(DevOpsError.unexpectedResponse, statusCode: 200)),
          en.errorUnexpectedResponse);
    });

    test('shows the server message for other HTTP errors', () {
      expect(
          en.error(DevOpsException(DevOpsError.http, statusCode: 400, serverMessage: 'Bad')),
          'Bad');
      expect(en.error(DevOpsException(DevOpsError.http, statusCode: 500)), en.errorHttp(500));
      expect(en.error(DevOpsException(DevOpsError.http)), en.errorHttp(0));
    });

    test('falls back to toString for other errors', () {
      expect(en.error(const FormatException('bad')), 'FormatException: bad');
    });
  });
}
