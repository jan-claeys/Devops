// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get welcome => 'Welkom';

  @override
  String get settings => 'Instellingen';

  @override
  String get connectionSaved => 'Verbinding opgeslagen';

  @override
  String get onboardingIntro => 'Verbind met Azure DevOps om te starten.';

  @override
  String get connection => 'Verbinding';

  @override
  String get organization => 'Organisatie';

  @override
  String get organizationHint =>
      'bv. mijnbedrijf of https://dev.azure.com/mijnbedrijf';

  @override
  String get organizationRequired => 'Vul je organisatie in';

  @override
  String get organizationInsecure =>
      'Gebruik een https://-adres zodat je token niet onversleuteld wordt verstuurd';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'Er is al een token opgeslagen. Vul opnieuw in om te wijzigen.';

  @override
  String get requiredScopes => 'Benodigde scopes';

  @override
  String get tokenRequired => 'Vul je token in';

  @override
  String get tokenHelpTitle => 'Hoe maak ik een token aan?';

  @override
  String get tokenHelpStep1 =>
      'Open in Azure DevOps User settings → Personal access tokens en kies New Token.';

  @override
  String get tokenHelpStep2 => 'Kies je organisatie en een vervaldatum.';

  @override
  String get tokenHelpStep3 =>
      'Kies bij Scopes voor Custom defined en vink alleen de scopes hierboven aan, telkens met de rechten die ernaast staan.';

  @override
  String get tokenHelpStep4 =>
      'Kies Create, kopieer het token en plak het hierboven. Het wordt maar één keer getoond.';

  @override
  String get tokenHelpPermissions =>
      'Een token heeft nooit meer rechten dan je account: je hebt minstens Stakeholder-toegang nodig en leesrechten op de projecten die je wilt zien.';

  @override
  String get tokenHelpDocs => 'Documentatie van Microsoft';

  @override
  String get connecting => 'Verbinden…';

  @override
  String get connect => 'Verbinden';

  @override
  String get appearance => 'Weergave';

  @override
  String get themeLight => 'Licht';

  @override
  String get themeSystem => 'Systeem';

  @override
  String get themeDark => 'Donker';

  @override
  String get colorAzureBlue => 'Azure-blauw';

  @override
  String get colorSystem => 'Systeemkleur';

  @override
  String get language => 'Taal';

  @override
  String get languageSystem => 'Systeemtaal';

  @override
  String get privacy => 'Privacy';

  @override
  String get about => 'Over';

  @override
  String appVersion(String version) {
    return 'Versie $version';
  }

  @override
  String madeBy(String name) {
    return 'Gemaakt door $name';
  }

  @override
  String get sendErrorReports => 'Foutrapporten versturen';

  @override
  String get sendErrorReportsHint =>
      'Stuurt anonieme gegevens over crashes en fouten zodat bugs opgelost kunnen worden. Je token wordt nooit verstuurd.';

  @override
  String get signOut => 'Afmelden';

  @override
  String get selectTicketTitle => 'Selecteer een ticket';

  @override
  String get selectTicketMessage =>
      'Kies links een ticket om de details te zien.';

  @override
  String get chooseProjects => 'Kies projecten';

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get searchTicketsHint => 'Zoek op titel, ID, tag of persoon';

  @override
  String get scopeAssignedToMe => 'Aan mij';

  @override
  String get scopeCreatedByMe => 'Door mij';

  @override
  String get scopeAll => 'Alles';

  @override
  String get openOnly => 'Alleen open';

  @override
  String get loadTicketsFailed => 'Kon tickets niet laden';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get noProjectsTitle => 'Geen projecten gekozen';

  @override
  String get noProjectsMessage =>
      'Kies een of meer projecten om tickets te bekijken.';

  @override
  String get noTicketsTitle => 'Geen tickets';

  @override
  String get noTicketsMessage =>
      'Er zijn geen tickets die aan de filters voldoen.';

  @override
  String ticketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tickets',
      one: '1 ticket',
    );
    return '$_temp0';
  }

  @override
  String get unassigned => 'Niet toegewezen';

  @override
  String get projects => 'Projecten';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projecten',
      one: '1 project',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Toepassen';

  @override
  String get searchProjectHint => 'Zoek project';

  @override
  String get loadProjectsFailed => 'Kon projecten niet laden';

  @override
  String get browserOpenFailed => 'Kon de browser niet openen';

  @override
  String get openInDevOps => 'Open in DevOps';

  @override
  String get description => 'Beschrijving';

  @override
  String get reproSteps => 'Stappen om te reproduceren';

  @override
  String get acceptanceCriteria => 'Acceptatiecriteria';

  @override
  String get symptom => 'Symptoom';

  @override
  String get systemInfo => 'Systeeminfo';

  @override
  String get proposedFix => 'Oplossing';

  @override
  String get emptyField => 'Geen inhoud';

  @override
  String get assignedTo => 'Toegewezen aan';

  @override
  String get priority => 'Prioriteit';

  @override
  String get effort => 'Inspanning';

  @override
  String get originalEstimate => 'Oorspronkelijke schatting';

  @override
  String get remainingWork => 'Resterend werk';

  @override
  String get completedWork => 'Voltooid werk';

  @override
  String hours(String value) {
    return '$value u';
  }

  @override
  String get area => 'Area';

  @override
  String get iteration => 'Iteratie';

  @override
  String get created => 'Aangemaakt';

  @override
  String createdOnBy(String date, String name) {
    return '$date door $name';
  }

  @override
  String get changed => 'Gewijzigd';

  @override
  String get linkedItems => 'Gekoppelde items';

  @override
  String get parent => 'Bovenliggend';

  @override
  String get child => 'Onderliggend';

  @override
  String commentsCount(int count) {
    return 'Opmerkingen ($count)';
  }

  @override
  String get noComments => 'Nog geen opmerkingen.';

  @override
  String attachmentsCount(int count) {
    return 'Bijlagen ($count)';
  }

  @override
  String get openFile => 'Bestand openen';

  @override
  String get download => 'Downloaden';

  @override
  String get downloadLargeTitle => 'Groot bestand downloaden?';

  @override
  String downloadLargeBody(String name, String size) {
    return '$name is $size. Downloaden kan even duren en mobiele data verbruiken.';
  }

  @override
  String get noAppForFile => 'Geen app op dit toestel kan dit bestand openen.';

  @override
  String get unknownPerson => 'Onbekend';

  @override
  String get justNow => 'zojuist';

  @override
  String minutesAgo(int count) {
    return '$count min geleden';
  }

  @override
  String hoursAgo(int count) {
    return '$count u geleden';
  }

  @override
  String daysAgo(int count) {
    return '$count d geleden';
  }

  @override
  String get errorUnauthorized =>
      'Je Personal Access Token is ongeldig of verlopen. Maak een nieuwe aan in de instellingen.';

  @override
  String get errorNotFound =>
      'Niet gevonden. Controleer de organisatie of het project.';

  @override
  String errorHttp(int code) {
    return 'Fout $code van Azure DevOps';
  }

  @override
  String get errorUnexpectedResponse =>
      'Onverwacht antwoord. Controleer de organisatie en je token.';

  @override
  String get widgetSetupRequired => 'Open de app om in te stellen';

  @override
  String get tickets => 'Tickets';

  @override
  String get pipelines => 'Pipelines';

  @override
  String get searchRunsHint => 'Zoek op pipeline, branch of persoon';

  @override
  String get activeOnly => 'Alleen actief';

  @override
  String get loadRunsFailed => 'Kon de pipeline-runs niet laden';

  @override
  String get noRunsTitle => 'Geen pipeline-runs';

  @override
  String get noRunsMessage =>
      'Er zijn geen pipeline-runs die aan de filters voldoen.';

  @override
  String runCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count runs',
      one: '1 run',
    );
    return '$_temp0';
  }

  @override
  String get selectRunTitle => 'Selecteer een pipeline-run';

  @override
  String get selectRunMessage =>
      'Kies links een run om de voortgang te volgen.';

  @override
  String get runPending => 'Wachten';

  @override
  String get runQueued => 'In wachtrij';

  @override
  String get runRunning => 'Bezig';

  @override
  String get runCancelling => 'Wordt geannuleerd';

  @override
  String get runSucceeded => 'Geslaagd';

  @override
  String get runPartiallySucceeded => 'Gedeeltelijk geslaagd';

  @override
  String get runFailed => 'Mislukt';

  @override
  String get runCanceled => 'Geannuleerd';

  @override
  String get runSkipped => 'Overgeslagen';

  @override
  String get progress => 'Voortgang';

  @override
  String tasksProgress(int done, int total) {
    return '$done van $total taken klaar';
  }

  @override
  String get branch => 'Branch';

  @override
  String get requestedBy => 'Aangevraagd door';

  @override
  String get queued => 'In wachtrij gezet';

  @override
  String get started => 'Gestart';

  @override
  String get finished => 'Klaar';

  @override
  String get duration => 'Duur';

  @override
  String get stages => 'Stages';

  @override
  String get noStagesYet => 'De stages verschijnen zodra de run start.';

  @override
  String get runWaitingForApproval => 'Wacht op goedkeuring';

  @override
  String get runNotDeployed => 'Niet uitgerold';

  @override
  String get builds => 'Builds';

  @override
  String get releases => 'Releases';

  @override
  String get loadReleasesFailed => 'Kon de releases niet laden';

  @override
  String get releaseScopeHint =>
      'Voor releases heeft je token de scope Release (Read) nodig.';

  @override
  String get artifact => 'Artefact';

  @override
  String waitingForApprovalBy(String names) {
    return 'Wacht op goedkeuring van $names';
  }

  @override
  String get pullRequests => 'Pull requests';

  @override
  String get searchPullRequestsHint => 'Zoek op titel, ID, branch of persoon';

  @override
  String get scopeReviewing => 'Te reviewen';

  @override
  String get loadPullRequestsFailed => 'Kon de pull requests niet laden';

  @override
  String get codeScopeHint =>
      'Voor pull requests heeft je token de scope Code (Read & write) nodig.';

  @override
  String get noPullRequestsTitle => 'Geen pull requests';

  @override
  String get noPullRequestsMessage =>
      'Er zijn geen pull requests die aan de filters voldoen.';

  @override
  String pullRequestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pull requests',
      one: '1 pull request',
    );
    return '$_temp0';
  }

  @override
  String get selectPullRequestTitle => 'Selecteer een pull request';

  @override
  String get selectPullRequestMessage =>
      'Kies links een pull request om de details te zien.';

  @override
  String get prDraft => 'Concept';

  @override
  String get prActive => 'Actief';

  @override
  String get prCompleted => 'Voltooid';

  @override
  String get prAbandoned => 'Afgebroken';

  @override
  String get mergeConflicts => 'Mergeconflicten';

  @override
  String get repository => 'Repository';

  @override
  String get closed => 'Gesloten';

  @override
  String get reviewers => 'Reviewers';

  @override
  String get noReviewers => 'Geen reviewers';

  @override
  String get requiredReviewer => 'Verplicht';

  @override
  String get voteApproved => 'Goedgekeurd';

  @override
  String get voteApprovedWithSuggestions => 'Goedgekeurd met suggesties';

  @override
  String get voteNone => 'Geen stem';

  @override
  String get voteWaitingForAuthor => 'Wacht op auteur';

  @override
  String get voteRejected => 'Afgewezen';

  @override
  String get threadResolved => 'Opgelost';

  @override
  String get voteApprove => 'Goedkeuren';

  @override
  String get voteApproveWithSuggestions => 'Goedkeuren met suggesties';

  @override
  String get voteWaitForAuthor => 'Wachten op auteur';

  @override
  String get voteReject => 'Afwijzen';

  @override
  String get voteReset => 'Stem intrekken';

  @override
  String get otherVotes => 'Andere stemmen';

  @override
  String get rejectConfirmTitle => 'Deze pull request afwijzen?';

  @override
  String get rejectConfirmBody =>
      'De pull request kan niet worden afgerond zolang je stem Afgewezen is.';

  @override
  String get voteSaved => 'Stem opgeslagen';

  @override
  String get cancel => 'Annuleren';

  @override
  String get actionDenied =>
      'Azure DevOps stond dit niet toe. Controleer of je token de juiste scope heeft en of je account de rechten heeft.';

  @override
  String get writeComment => 'Schrijf een reactie…';

  @override
  String get send => 'Versturen';

  @override
  String get runErrors => 'Fouten';

  @override
  String get viewLog => 'Log bekijken';

  @override
  String showAll(int count) {
    return 'Alles tonen ($count)';
  }

  @override
  String get copyLog => 'Log kopiëren';

  @override
  String get logCopied => 'Log gekopieerd';

  @override
  String get logEmpty => 'Deze log is leeg.';

  @override
  String get showMore => 'Meer tonen';

  @override
  String get showLess => 'Minder tonen';

  @override
  String get onlyErrorsAndWarnings => 'Alleen fouten en waarschuwingen';

  @override
  String get noLogIssues => 'Geen fouten of waarschuwingen in deze log.';

  @override
  String get previousError => 'Vorige fout';

  @override
  String get nextError => 'Volgende fout';

  @override
  String errorPosition(int current, int total) {
    return 'Fout $current van $total';
  }

  @override
  String errorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fouten',
      one: '1 fout',
    );
    return '$_temp0';
  }

  @override
  String get dashboard => 'Overzicht';

  @override
  String refreshFailed(String time) {
    return 'Kon niet verversen. Gegevens van $time.';
  }

  @override
  String get loadDashboardFailed => 'Kon het overzicht niet laden';

  @override
  String get myPullRequests => 'Mijn pull requests';

  @override
  String get myTickets => 'Mijn open tickets';

  @override
  String get waitingForYourReview => 'Wacht op jouw review';

  @override
  String get waitingForYou => 'Wacht op jou';

  @override
  String get nothingWaiting => 'Er wacht nu niets op jou.';

  @override
  String get readyToComplete => 'Goedgekeurd, klaar om te voltooien';

  @override
  String get yourApproval => 'Wacht op jouw goedkeuring';

  @override
  String get myRuns => 'Mijn runs';

  @override
  String get noRecentRuns => 'Je hebt de laatste tijd geen runs gestart.';

  @override
  String failingOnMain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pipelines falen op de main-branch',
      one: '1 pipeline faalt op de main-branch',
    );
    return '$_temp0';
  }

  @override
  String noChangesFor(int count) {
    return '$count d niet gewijzigd';
  }

  @override
  String get linkNotSupported => 'Deze link kan niet in de app geopend worden.';

  @override
  String get linkOtherOrganization =>
      'Deze link hoort bij een andere organisatie dan die waarmee je verbonden bent.';

  @override
  String get notifications => 'Meldingen';

  @override
  String get runNotificationsHint =>
      'Toont de voortgang van lopende pipelines zolang de app open is, en volgt ze op de achtergrond verder tot ze klaar zijn.';

  @override
  String get runNotificationsOff => 'Uit';

  @override
  String get runNotificationsMine => 'Mijn runs';

  @override
  String get runNotificationsAll => 'Alle runs';

  @override
  String get runNotificationChannel => 'Voortgang van pipelines';

  @override
  String get notificationsDenied =>
      'Meldingen staan uit voor deze app in de Android-instellingen.';

  @override
  String runNotificationsRunning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pipelines bezig',
      one: '1 pipeline bezig',
    );
    return '$_temp0';
  }
}
