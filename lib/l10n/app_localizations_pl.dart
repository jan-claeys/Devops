// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get welcome => 'Witaj';

  @override
  String get settings => 'Ustawienia';

  @override
  String get connectionSaved => 'Połączenie zapisane';

  @override
  String get onboardingIntro =>
      'Połącz się z Azure DevOps, aby zobaczyć swoje zgłoszenia.';

  @override
  String get connection => 'Połączenie';

  @override
  String get organization => 'Organizacja';

  @override
  String get organizationHint =>
      'np. mojafirma lub https://dev.azure.com/mojafirma';

  @override
  String get organizationRequired => 'Podaj swoją organizację';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'Token jest już zapisany. Wpisz go ponownie, aby go zmienić.';

  @override
  String get tokenScopeHint =>
      'Wymagany zakres: Work Items (Read) i Project and Team (Read)';

  @override
  String get tokenRequired => 'Podaj swój token';

  @override
  String get connecting => 'Łączenie…';

  @override
  String get connect => 'Połącz';

  @override
  String get appearance => 'Wygląd';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeSystem => 'Systemowy';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get colorAzureBlue => 'Niebieski Azure';

  @override
  String get colorSystem => 'Kolor systemowy';

  @override
  String get language => 'Język';

  @override
  String get languageSystem => 'Język systemu';

  @override
  String get privacy => 'Prywatność';

  @override
  String get sendErrorReports => 'Wysyłaj raporty o błędach';

  @override
  String get sendErrorReportsHint =>
      'Wysyła anonimowe dane o awariach i błędach, aby można je było naprawić. Twój token nigdy nie jest wysyłany.';

  @override
  String get signOut => 'Wyloguj';

  @override
  String get selectTicketTitle => 'Wybierz zgłoszenie';

  @override
  String get selectTicketMessage =>
      'Wybierz zgłoszenie po lewej, aby zobaczyć szczegóły.';

  @override
  String get chooseProject => 'Wybierz projekt';

  @override
  String get refresh => 'Odśwież';

  @override
  String get searchTicketsHint => 'Szukaj po tytule, ID, tagu lub osobie';

  @override
  String get scopeAssignedToMe => 'Przypisane do mnie';

  @override
  String get scopeCreatedByMe => 'Utworzone przeze mnie';

  @override
  String get scopeAll => 'Wszystkie';

  @override
  String get openOnly => 'Tylko otwarte';

  @override
  String get loadTicketsFailed => 'Nie udało się wczytać zgłoszeń';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get noProjectTitle => 'Nie wybrano projektu';

  @override
  String get noProjectMessage => 'Wybierz projekt, aby zobaczyć zgłoszenia.';

  @override
  String get noTicketsTitle => 'Brak zgłoszeń';

  @override
  String get noTicketsMessage => 'Żadne zgłoszenia nie pasują do filtrów.';

  @override
  String ticketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zgłoszenia',
      many: '$count zgłoszeń',
      few: '$count zgłoszenia',
      one: '1 zgłoszenie',
    );
    return '$_temp0';
  }

  @override
  String get unassigned => 'Nieprzypisane';

  @override
  String get chooseAProject => 'Wybierz projekt';

  @override
  String get searchProjectHint => 'Szukaj projektu';

  @override
  String get loadProjectsFailed => 'Nie udało się wczytać projektów';

  @override
  String get browserOpenFailed => 'Nie udało się otworzyć przeglądarki';

  @override
  String get openInDevOps => 'Otwórz w DevOps';

  @override
  String get description => 'Opis';

  @override
  String get reproSteps => 'Kroki do odtworzenia';

  @override
  String get acceptanceCriteria => 'Kryteria akceptacji';

  @override
  String get assignedTo => 'Przypisane do';

  @override
  String get priority => 'Priorytet';

  @override
  String get effort => 'Nakład pracy';

  @override
  String get originalEstimate => 'Pierwotne oszacowanie';

  @override
  String get remainingWork => 'Pozostała praca';

  @override
  String get completedWork => 'Wykonana praca';

  @override
  String hours(String value) {
    return '$value godz.';
  }

  @override
  String get area => 'Obszar';

  @override
  String get iteration => 'Iteracja';

  @override
  String get created => 'Utworzono';

  @override
  String createdOnBy(String date, String name) {
    return '$date przez $name';
  }

  @override
  String get changed => 'Zmieniono';

  @override
  String get linkedItems => 'Powiązane elementy';

  @override
  String get parent => 'Nadrzędny';

  @override
  String get child => 'Podrzędny';

  @override
  String commentsCount(int count) {
    return 'Komentarze ($count)';
  }

  @override
  String get noComments => 'Brak komentarzy.';

  @override
  String get unknownPerson => 'Nieznany';

  @override
  String get justNow => 'przed chwilą';

  @override
  String minutesAgo(int count) {
    return '$count min temu';
  }

  @override
  String hoursAgo(int count) {
    return '$count godz. temu';
  }

  @override
  String daysAgo(int count) {
    return '$count dni temu';
  }

  @override
  String get errorUnauthorized =>
      'Brak autoryzacji. Sprawdź swój Personal Access Token.';

  @override
  String get errorNotFound =>
      'Nie znaleziono. Sprawdź organizację lub projekt.';

  @override
  String errorHttp(int code) {
    return 'Błąd $code z Azure DevOps';
  }

  @override
  String get errorUnexpectedResponse =>
      'Nieoczekiwana odpowiedź. Sprawdź organizację i token.';

  @override
  String get widgetSetupRequired => 'Otwórz aplikację, aby ją skonfigurować';
}
