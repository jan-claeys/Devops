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
  String get onboardingIntro => 'Połącz się z Azure DevOps, aby zacząć.';

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
  String get organizationInsecure =>
      'Użyj adresu https://, aby token nie był wysyłany bez szyfrowania';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'Token jest już zapisany. Wpisz go ponownie, aby go zmienić.';

  @override
  String get requiredScopes => 'Wymagane zakresy';

  @override
  String get tokenRequired => 'Podaj swój token';

  @override
  String get tokenHelpTitle => 'Jak utworzyć token?';

  @override
  String get tokenHelpStep1 =>
      'W Azure DevOps otwórz User settings → Personal access tokens i wybierz New Token.';

  @override
  String get tokenHelpStep2 => 'Wybierz organizację i datę wygaśnięcia.';

  @override
  String get tokenHelpStep3 =>
      'W sekcji Scopes wybierz Custom defined i zaznacz tylko zakresy wymienione powyżej, każdy z opcją Read.';

  @override
  String get tokenHelpStep4 =>
      'Wybierz Create, skopiuj token i wklej go powyżej. Jest wyświetlany tylko raz.';

  @override
  String get tokenHelpPermissions =>
      'Token nigdy nie ma więcej uprawnień niż Twoje konto: potrzebujesz co najmniej dostępu Stakeholder i uprawnień do odczytu projektów, które chcesz widzieć.';

  @override
  String get tokenHelpDocs => 'Dokumentacja Microsoft';

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
  String get about => 'O aplikacji';

  @override
  String appVersion(String version) {
    return 'Wersja $version';
  }

  @override
  String madeBy(String name) {
    return 'Autor: $name';
  }

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
  String get chooseProjects => 'Wybierz projekty';

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
  String get noProjectsTitle => 'Nie wybrano projektów';

  @override
  String get noProjectsMessage =>
      'Wybierz jeden lub więcej projektów, aby zobaczyć zgłoszenia.';

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
  String get projects => 'Projekty';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projektu',
      many: '$count projektów',
      few: '$count projekty',
      one: '1 projekt',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Zastosuj';

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
  String get symptom => 'Objaw';

  @override
  String get systemInfo => 'Informacje o systemie';

  @override
  String get proposedFix => 'Poprawka';

  @override
  String get emptyField => 'Brak treści';

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
  String attachmentsCount(int count) {
    return 'Załączniki ($count)';
  }

  @override
  String get openFile => 'Otwórz plik';

  @override
  String get download => 'Pobierz';

  @override
  String get downloadLargeTitle => 'Pobrać duży plik?';

  @override
  String downloadLargeBody(String name, String size) {
    return '$name ma $size. Pobieranie może chwilę potrwać i zużyć dane komórkowe.';
  }

  @override
  String get noAppForFile =>
      'Żadna aplikacja na tym urządzeniu nie może otworzyć tego pliku.';

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
      'Twój Personal Access Token jest nieprawidłowy lub wygasł. Utwórz nowy w ustawieniach.';

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

  @override
  String get tickets => 'Zgłoszenia';

  @override
  String get pipelines => 'Potoki';

  @override
  String get searchRunsHint => 'Szukaj po potoku, gałęzi lub osobie';

  @override
  String get activeOnly => 'Tylko aktywne';

  @override
  String get loadRunsFailed => 'Nie udało się wczytać uruchomień';

  @override
  String get noRunsTitle => 'Brak uruchomień potoków';

  @override
  String get noRunsMessage => 'Brak uruchomień potoków pasujących do filtrów.';

  @override
  String runCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uruchomienia',
      many: '$count uruchomień',
      few: '$count uruchomienia',
      one: '1 uruchomienie',
    );
    return '$_temp0';
  }

  @override
  String get selectRunTitle => 'Wybierz uruchomienie';

  @override
  String get selectRunMessage =>
      'Wybierz uruchomienie po lewej, aby śledzić postęp.';

  @override
  String get runPending => 'Oczekuje';

  @override
  String get runQueued => 'W kolejce';

  @override
  String get runRunning => 'W toku';

  @override
  String get runCancelling => 'Anulowanie';

  @override
  String get runSucceeded => 'Powodzenie';

  @override
  String get runPartiallySucceeded => 'Częściowe powodzenie';

  @override
  String get runFailed => 'Niepowodzenie';

  @override
  String get runCanceled => 'Anulowano';

  @override
  String get runSkipped => 'Pominięto';

  @override
  String get progress => 'Postęp';

  @override
  String tasksProgress(int done, int total) {
    return 'Ukończono $done z $total zadań';
  }

  @override
  String get branch => 'Gałąź';

  @override
  String get requestedBy => 'Zlecone przez';

  @override
  String get queued => 'Dodano do kolejki';

  @override
  String get started => 'Rozpoczęto';

  @override
  String get finished => 'Zakończono';

  @override
  String get duration => 'Czas trwania';

  @override
  String get stages => 'Etapy';

  @override
  String get noStagesYet => 'Etapy pojawią się po rozpoczęciu uruchomienia.';

  @override
  String get runWaitingForApproval => 'Oczekuje na zatwierdzenie';

  @override
  String get runNotDeployed => 'Nie wdrożono';

  @override
  String get builds => 'Kompilacje';

  @override
  String get releases => 'Wydania';

  @override
  String get loadReleasesFailed => 'Nie udało się wczytać wydań';

  @override
  String get releaseScopeHint =>
      'Wydania wymagają zakresu Release (Read) w tokenie.';

  @override
  String get artifact => 'Artefakt';

  @override
  String waitingForApprovalBy(String names) {
    return 'Oczekuje na zatwierdzenie przez: $names';
  }

  @override
  String get pullRequests => 'Pull requesty';

  @override
  String get searchPullRequestsHint =>
      'Szukaj według tytułu, ID, gałęzi lub osoby';

  @override
  String get scopeReviewing => 'Do przeglądu';

  @override
  String get loadPullRequestsFailed => 'Nie udało się wczytać pull requestów';

  @override
  String get codeScopeHint =>
      'Pull requesty wymagają zakresu Code (Read) w tokenie.';

  @override
  String get noPullRequestsTitle => 'Brak pull requestów';

  @override
  String get noPullRequestsMessage =>
      'Brak pull requestów pasujących do filtrów.';

  @override
  String pullRequestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pull requesta',
      many: '$count pull requestów',
      few: '$count pull requesty',
      one: '1 pull request',
    );
    return '$_temp0';
  }

  @override
  String get selectPullRequestTitle => 'Wybierz pull request';

  @override
  String get selectPullRequestMessage =>
      'Wybierz pull request po lewej, aby zobaczyć szczegóły.';

  @override
  String get prDraft => 'Wersja robocza';

  @override
  String get prActive => 'Aktywny';

  @override
  String get prCompleted => 'Ukończony';

  @override
  String get prAbandoned => 'Porzucony';

  @override
  String get mergeConflicts => 'Konflikty scalania';

  @override
  String get repository => 'Repozytorium';

  @override
  String get closed => 'Zamknięty';

  @override
  String get reviewers => 'Recenzenci';

  @override
  String get noReviewers => 'Brak recenzentów';

  @override
  String get requiredReviewer => 'Wymagany';

  @override
  String get voteApproved => 'Zatwierdzono';

  @override
  String get voteApprovedWithSuggestions => 'Zatwierdzono z sugestiami';

  @override
  String get voteNone => 'Brak głosu';

  @override
  String get voteWaitingForAuthor => 'Oczekuje na autora';

  @override
  String get voteRejected => 'Odrzucono';

  @override
  String get threadResolved => 'Rozwiązany';

  @override
  String get runErrors => 'Błędy';

  @override
  String get viewLog => 'Pokaż log';

  @override
  String showAll(int count) {
    return 'Pokaż wszystkie ($count)';
  }

  @override
  String get copyLog => 'Kopiuj log';

  @override
  String get logCopied => 'Skopiowano log';

  @override
  String get logEmpty => 'Ten log jest pusty.';

  @override
  String get showMore => 'Pokaż więcej';

  @override
  String get showLess => 'Pokaż mniej';

  @override
  String get onlyErrorsAndWarnings => 'Tylko błędy i ostrzeżenia';

  @override
  String get noLogIssues => 'Brak błędów i ostrzeżeń w tym logu.';

  @override
  String get previousError => 'Poprzedni błąd';

  @override
  String get nextError => 'Następny błąd';

  @override
  String errorPosition(int current, int total) {
    return 'Błąd $current z $total';
  }

  @override
  String errorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count błędu',
      many: '$count błędów',
      few: '$count błędy',
      one: '1 błąd',
    );
    return '$_temp0';
  }

  @override
  String get dashboard => 'Przegląd';

  @override
  String refreshFailed(String time) {
    return 'Nie udało się odświeżyć. Dane z: $time.';
  }

  @override
  String get loadDashboardFailed => 'Nie udało się wczytać przeglądu';

  @override
  String get myPullRequests => 'Moje pull requesty';

  @override
  String get myTickets => 'Moje otwarte zgłoszenia';

  @override
  String get waitingForYourReview => 'Czeka na twoją recenzję';

  @override
  String get waitingForYou => 'Czeka na ciebie';

  @override
  String get nothingWaiting => 'Nic teraz na ciebie nie czeka.';

  @override
  String get readyToComplete => 'Zatwierdzony, gotowy do ukończenia';

  @override
  String get yourApproval => 'Czeka na twoje zatwierdzenie';

  @override
  String get myRuns => 'Moje uruchomienia';

  @override
  String get noRecentRuns => 'Brak twoich ostatnich uruchomień.';

  @override
  String failingOnMain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count potoku kończy się niepowodzeniem na gałęzi main',
      many: '$count potoków kończy się niepowodzeniem na gałęzi main',
      few: '$count potoki kończą się niepowodzeniem na gałęzi main',
      one: '1 potok kończy się niepowodzeniem na gałęzi main',
    );
    return '$_temp0';
  }

  @override
  String noChangesFor(int count) {
    return 'Bez zmian od $count d';
  }
}
