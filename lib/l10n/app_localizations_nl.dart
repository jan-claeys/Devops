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
  String get onboardingIntro =>
      'Verbind met Azure DevOps om je tickets te bekijken.';

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
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'Er is al een token opgeslagen. Vul opnieuw in om te wijzigen.';

  @override
  String get tokenScopeHint =>
      'Scope nodig: Work Items (Read), Build (Read) en Project and Team (Read)';

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
      'Kies bij Scopes voor Custom defined en vink alleen Work Items: Read, Build: Read en Project and Team: Read aan.';

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
      'Niet geautoriseerd. Controleer je Personal Access Token.';

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
}
