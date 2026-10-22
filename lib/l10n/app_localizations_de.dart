// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get welcome => 'Willkommen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get connectionSaved => 'Verbindung gespeichert';

  @override
  String get onboardingIntro =>
      'Verbinde dich mit Azure DevOps, um loszulegen.';

  @override
  String get connection => 'Verbindung';

  @override
  String get organization => 'Organisation';

  @override
  String get organizationHint =>
      'z. B. meinefirma oder https://dev.azure.com/meinefirma';

  @override
  String get organizationRequired => 'Gib deine Organisation ein';

  @override
  String get organizationInsecure =>
      'Verwende eine https://-Adresse, damit dein Token nicht unverschlüsselt gesendet wird';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'Es ist bereits ein Token gespeichert. Gib es erneut ein, um es zu ändern.';

  @override
  String get requiredScopes => 'Benötigte Bereiche';

  @override
  String get tokenRequired => 'Gib dein Token ein';

  @override
  String get tokenHelpTitle => 'Wie erstelle ich ein Token?';

  @override
  String get tokenHelpStep1 =>
      'Öffne in Azure DevOps User settings → Personal access tokens und wähle New Token.';

  @override
  String get tokenHelpStep2 => 'Wähle deine Organisation und ein Ablaufdatum.';

  @override
  String get tokenHelpStep3 =>
      'Wähle unter Scopes die Option Custom defined und aktiviere nur die oben aufgeführten Bereiche, jeweils mit Read.';

  @override
  String get tokenHelpStep4 =>
      'Wähle Create, kopiere das Token und füge es oben ein. Es wird nur einmal angezeigt.';

  @override
  String get tokenHelpPermissions =>
      'Ein Token hat nie mehr Rechte als dein Konto: Du brauchst mindestens Stakeholder-Zugriff und Leserechte für die Projekte, die du sehen willst.';

  @override
  String get tokenHelpDocs => 'Microsoft-Dokumentation';

  @override
  String get connecting => 'Verbinden…';

  @override
  String get connect => 'Verbinden';

  @override
  String get appearance => 'Darstellung';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get colorAzureBlue => 'Azure-Blau';

  @override
  String get colorSystem => 'Systemfarbe';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'Systemsprache';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get about => 'Über';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String madeBy(String name) {
    return 'Erstellt von $name';
  }

  @override
  String get sendErrorReports => 'Fehlerberichte senden';

  @override
  String get sendErrorReportsHint =>
      'Sendet anonyme Angaben zu Abstürzen und Fehlern, damit Bugs behoben werden können. Dein Token wird nie gesendet.';

  @override
  String get signOut => 'Abmelden';

  @override
  String get selectTicketTitle => 'Ticket auswählen';

  @override
  String get selectTicketMessage =>
      'Wähle links ein Ticket, um die Details zu sehen.';

  @override
  String get chooseProjects => 'Projekte wählen';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get searchTicketsHint => 'Nach Titel, ID, Tag oder Person suchen';

  @override
  String get scopeAssignedToMe => 'Mir zugewiesen';

  @override
  String get scopeCreatedByMe => 'Von mir';

  @override
  String get scopeAll => 'Alle';

  @override
  String get openOnly => 'Nur offene';

  @override
  String get loadTicketsFailed => 'Tickets konnten nicht geladen werden';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get noProjectsTitle => 'Keine Projekte ausgewählt';

  @override
  String get noProjectsMessage =>
      'Wähle ein oder mehrere Projekte, um Tickets zu sehen.';

  @override
  String get noTicketsTitle => 'Keine Tickets';

  @override
  String get noTicketsMessage => 'Keine Tickets entsprechen den Filtern.';

  @override
  String ticketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tickets',
      one: '1 Ticket',
    );
    return '$_temp0';
  }

  @override
  String get unassigned => 'Nicht zugewiesen';

  @override
  String get projects => 'Projekte';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Projekte',
      one: '1 Projekt',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Übernehmen';

  @override
  String get searchProjectHint => 'Projekt suchen';

  @override
  String get loadProjectsFailed => 'Projekte konnten nicht geladen werden';

  @override
  String get browserOpenFailed => 'Browser konnte nicht geöffnet werden';

  @override
  String get openInDevOps => 'In DevOps öffnen';

  @override
  String get description => 'Beschreibung';

  @override
  String get reproSteps => 'Schritte zum Reproduzieren';

  @override
  String get acceptanceCriteria => 'Akzeptanzkriterien';

  @override
  String get symptom => 'Symptom';

  @override
  String get systemInfo => 'Systeminfo';

  @override
  String get proposedFix => 'Lösung';

  @override
  String get emptyField => 'Kein Inhalt';

  @override
  String get assignedTo => 'Zugewiesen an';

  @override
  String get priority => 'Priorität';

  @override
  String get effort => 'Aufwand';

  @override
  String get originalEstimate => 'Ursprüngliche Schätzung';

  @override
  String get remainingWork => 'Verbleibende Arbeit';

  @override
  String get completedWork => 'Erledigte Arbeit';

  @override
  String hours(String value) {
    return '$value Std.';
  }

  @override
  String get area => 'Bereich';

  @override
  String get iteration => 'Iteration';

  @override
  String get created => 'Erstellt';

  @override
  String createdOnBy(String date, String name) {
    return '$date von $name';
  }

  @override
  String get changed => 'Geändert';

  @override
  String get linkedItems => 'Verknüpfte Elemente';

  @override
  String get parent => 'Übergeordnet';

  @override
  String get child => 'Untergeordnet';

  @override
  String commentsCount(int count) {
    return 'Kommentare ($count)';
  }

  @override
  String get noComments => 'Noch keine Kommentare.';

  @override
  String attachmentsCount(int count) {
    return 'Anhänge ($count)';
  }

  @override
  String get openFile => 'Datei öffnen';

  @override
  String get download => 'Herunterladen';

  @override
  String get downloadLargeTitle => 'Große Datei herunterladen?';

  @override
  String downloadLargeBody(String name, String size) {
    return '$name ist $size groß. Das Herunterladen kann dauern und mobile Daten verbrauchen.';
  }

  @override
  String get noAppForFile =>
      'Keine App auf diesem Gerät kann diese Datei öffnen.';

  @override
  String get unknownPerson => 'Unbekannt';

  @override
  String get justNow => 'gerade eben';

  @override
  String minutesAgo(int count) {
    return 'vor $count Min.';
  }

  @override
  String hoursAgo(int count) {
    return 'vor $count Std.';
  }

  @override
  String daysAgo(int count) {
    return 'vor $count T.';
  }

  @override
  String get errorUnauthorized =>
      'Dein Personal Access Token ist ungültig oder abgelaufen. Erstelle ein neues in den Einstellungen.';

  @override
  String get errorNotFound =>
      'Nicht gefunden. Prüfe die Organisation oder das Projekt.';

  @override
  String errorHttp(int code) {
    return 'Fehler $code von Azure DevOps';
  }

  @override
  String get errorUnexpectedResponse =>
      'Unerwartete Antwort. Prüfe die Organisation und dein Token.';

  @override
  String get widgetSetupRequired => 'Öffne die App zum Einrichten';

  @override
  String get tickets => 'Tickets';

  @override
  String get pipelines => 'Pipelines';

  @override
  String get searchRunsHint => 'Nach Pipeline, Branch oder Person suchen';

  @override
  String get activeOnly => 'Nur aktive';

  @override
  String get loadRunsFailed =>
      'Pipeline-Ausführungen konnten nicht geladen werden';

  @override
  String get noRunsTitle => 'Keine Pipeline-Ausführungen';

  @override
  String get noRunsMessage =>
      'Es gibt keine Pipeline-Ausführungen, die den Filtern entsprechen.';

  @override
  String runCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ausführungen',
      one: '1 Ausführung',
    );
    return '$_temp0';
  }

  @override
  String get selectRunTitle => 'Wähle eine Pipeline-Ausführung';

  @override
  String get selectRunMessage =>
      'Wähle links eine Ausführung, um ihren Fortschritt zu verfolgen.';

  @override
  String get runPending => 'Wartend';

  @override
  String get runQueued => 'In Warteschlange';

  @override
  String get runRunning => 'Läuft';

  @override
  String get runCancelling => 'Wird abgebrochen';

  @override
  String get runSucceeded => 'Erfolgreich';

  @override
  String get runPartiallySucceeded => 'Teilweise erfolgreich';

  @override
  String get runFailed => 'Fehlgeschlagen';

  @override
  String get runCanceled => 'Abgebrochen';

  @override
  String get runSkipped => 'Übersprungen';

  @override
  String get progress => 'Fortschritt';

  @override
  String tasksProgress(int done, int total) {
    return '$done von $total Aufgaben erledigt';
  }

  @override
  String get branch => 'Branch';

  @override
  String get requestedBy => 'Angefordert von';

  @override
  String get queued => 'Eingereiht';

  @override
  String get started => 'Gestartet';

  @override
  String get finished => 'Beendet';

  @override
  String get duration => 'Dauer';

  @override
  String get stages => 'Phasen';

  @override
  String get noStagesYet =>
      'Die Phasen erscheinen, sobald die Ausführung startet.';

  @override
  String get runWaitingForApproval => 'Wartet auf Genehmigung';

  @override
  String get runNotDeployed => 'Nicht bereitgestellt';

  @override
  String get builds => 'Builds';

  @override
  String get releases => 'Releases';

  @override
  String get loadReleasesFailed => 'Releases konnten nicht geladen werden';

  @override
  String get releaseScopeHint =>
      'Für Releases braucht dein Token den Bereich Release (Read).';

  @override
  String get artifact => 'Artefakt';

  @override
  String waitingForApprovalBy(String names) {
    return 'Wartet auf Genehmigung von $names';
  }

  @override
  String get pullRequests => 'Pull Requests';

  @override
  String get searchPullRequestsHint =>
      'Nach Titel, ID, Branch oder Person suchen';

  @override
  String get scopeReviewing => 'Zu prüfen';

  @override
  String get scopeMine => 'Meine';

  @override
  String get loadPullRequestsFailed =>
      'Pull Requests konnten nicht geladen werden';

  @override
  String get codeScopeHint =>
      'Für Pull Requests braucht dein Token den Bereich Code (Read).';

  @override
  String get noPullRequestsTitle => 'Keine Pull Requests';

  @override
  String get noPullRequestsMessage =>
      'Es gibt keine Pull Requests, die den Filtern entsprechen.';

  @override
  String pullRequestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Pull Requests',
      one: '1 Pull Request',
    );
    return '$_temp0';
  }

  @override
  String get selectPullRequestTitle => 'Pull Request auswählen';

  @override
  String get selectPullRequestMessage =>
      'Wähle links einen Pull Request, um die Details zu sehen.';

  @override
  String get prDraft => 'Entwurf';

  @override
  String get prActive => 'Aktiv';

  @override
  String get prCompleted => 'Abgeschlossen';

  @override
  String get prAbandoned => 'Verworfen';

  @override
  String get mergeConflicts => 'Mergekonflikte';

  @override
  String get repository => 'Repository';

  @override
  String get closed => 'Geschlossen';

  @override
  String get reviewers => 'Reviewer';

  @override
  String get noReviewers => 'Keine Reviewer';

  @override
  String get requiredReviewer => 'Erforderlich';

  @override
  String get voteApproved => 'Genehmigt';

  @override
  String get voteApprovedWithSuggestions => 'Mit Vorschlägen genehmigt';

  @override
  String get voteNone => 'Keine Stimme';

  @override
  String get voteWaitingForAuthor => 'Wartet auf Autor';

  @override
  String get voteRejected => 'Abgelehnt';

  @override
  String get threadResolved => 'Gelöst';

  @override
  String get runErrors => 'Fehler';

  @override
  String get viewLog => 'Log anzeigen';

  @override
  String showAll(int count) {
    return 'Alle anzeigen ($count)';
  }

  @override
  String get copyLog => 'Log kopieren';

  @override
  String get logCopied => 'Log kopiert';

  @override
  String get logEmpty => 'Dieses Log ist leer.';

  @override
  String get showMore => 'Mehr anzeigen';

  @override
  String get showLess => 'Weniger anzeigen';

  @override
  String get onlyErrorsAndWarnings => 'Nur Fehler und Warnungen';

  @override
  String get noLogIssues => 'Keine Fehler oder Warnungen in diesem Log.';

  @override
  String get previousError => 'Vorheriger Fehler';

  @override
  String get nextError => 'Nächster Fehler';

  @override
  String errorPosition(int current, int total) {
    return 'Fehler $current von $total';
  }

  @override
  String errorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fehler',
      one: '1 Fehler',
    );
    return '$_temp0';
  }

  @override
  String get dashboard => 'Übersicht';

  @override
  String refreshFailed(String time) {
    return 'Aktualisierung fehlgeschlagen. Stand: $time.';
  }

  @override
  String get loadDashboardFailed => 'Übersicht konnte nicht geladen werden';

  @override
  String get myPullRequests => 'Meine Pull Requests';

  @override
  String get myTickets => 'Meine offenen Tickets';

  @override
  String get waitingForYourReview => 'Wartet auf dein Review';

  @override
  String get waitingForYou => 'Wartet auf dich';

  @override
  String get nothingWaiting => 'Gerade wartet nichts auf dich.';

  @override
  String get readyToComplete => 'Genehmigt, bereit zum Abschließen';

  @override
  String get yourApproval => 'Wartet auf deine Genehmigung';

  @override
  String get myRuns => 'Meine Ausführungen';

  @override
  String get noRecentRuns =>
      'Du hast in letzter Zeit keine Ausführungen gestartet.';

  @override
  String failingOnMain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Pipelines schlagen auf dem Main-Branch fehl',
      one: '1 Pipeline schlägt auf dem Main-Branch fehl',
    );
    return '$_temp0';
  }

  @override
  String noChangesFor(int count) {
    return 'Seit $count T unverändert';
  }
}
