// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome';

  @override
  String get settings => 'Settings';

  @override
  String get connectionSaved => 'Connection saved';

  @override
  String get onboardingIntro => 'Connect to Azure DevOps to view your tickets.';

  @override
  String get connection => 'Connection';

  @override
  String get organization => 'Organization';

  @override
  String get organizationHint =>
      'e.g. mycompany or https://dev.azure.com/mycompany';

  @override
  String get organizationRequired => 'Enter your organization';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'A token is already stored. Enter it again to change it.';

  @override
  String get tokenScopeHint =>
      'Required scope: Work Items (Read), Build (Read) and Project and Team (Read)';

  @override
  String get tokenRequired => 'Enter your token';

  @override
  String get tokenHelpTitle => 'How do I create a token?';

  @override
  String get tokenHelpStep1 =>
      'In Azure DevOps, open User settings → Personal access tokens and select New Token.';

  @override
  String get tokenHelpStep2 => 'Pick your organization and an expiration date.';

  @override
  String get tokenHelpStep3 =>
      'Under Scopes, choose Custom defined and enable only Work Items: Read, Build: Read and Project and Team: Read.';

  @override
  String get tokenHelpStep4 =>
      'Select Create, copy the token and paste it above. It is shown only once.';

  @override
  String get tokenHelpPermissions =>
      'A token never has more rights than your account: you need at least Stakeholder access and read access to the projects you want to see.';

  @override
  String get tokenHelpDocs => 'Microsoft documentation';

  @override
  String get connecting => 'Connecting…';

  @override
  String get connect => 'Connect';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dark';

  @override
  String get colorAzureBlue => 'Azure blue';

  @override
  String get colorSystem => 'System color';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System language';

  @override
  String get privacy => 'Privacy';

  @override
  String get about => 'About';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String madeBy(String name) {
    return 'Made by $name';
  }

  @override
  String get sendErrorReports => 'Send error reports';

  @override
  String get sendErrorReportsHint =>
      'Sends anonymous crash and error details so bugs can be fixed. Your token is never sent.';

  @override
  String get signOut => 'Sign out';

  @override
  String get selectTicketTitle => 'Select a ticket';

  @override
  String get selectTicketMessage =>
      'Choose a ticket on the left to see its details.';

  @override
  String get chooseProjects => 'Choose projects';

  @override
  String get refresh => 'Refresh';

  @override
  String get searchTicketsHint => 'Search by title, ID, tag or person';

  @override
  String get scopeAssignedToMe => 'Assigned to me';

  @override
  String get scopeCreatedByMe => 'Created by me';

  @override
  String get scopeAll => 'All';

  @override
  String get openOnly => 'Open only';

  @override
  String get loadTicketsFailed => 'Couldn\'t load tickets';

  @override
  String get retry => 'Try again';

  @override
  String get noProjectsTitle => 'No projects selected';

  @override
  String get noProjectsMessage =>
      'Choose one or more projects to view tickets.';

  @override
  String get noTicketsTitle => 'No tickets';

  @override
  String get noTicketsMessage => 'There are no tickets matching the filters.';

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
  String get unassigned => 'Unassigned';

  @override
  String get projects => 'Projects';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projects',
      one: '1 project',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Apply';

  @override
  String get searchProjectHint => 'Search project';

  @override
  String get loadProjectsFailed => 'Couldn\'t load projects';

  @override
  String get browserOpenFailed => 'Couldn\'t open the browser';

  @override
  String get openInDevOps => 'Open in DevOps';

  @override
  String get description => 'Description';

  @override
  String get reproSteps => 'Steps to reproduce';

  @override
  String get acceptanceCriteria => 'Acceptance criteria';

  @override
  String get symptom => 'Symptom';

  @override
  String get systemInfo => 'System info';

  @override
  String get proposedFix => 'Fix';

  @override
  String get emptyField => 'No content';

  @override
  String get assignedTo => 'Assigned to';

  @override
  String get priority => 'Priority';

  @override
  String get effort => 'Effort';

  @override
  String get originalEstimate => 'Original estimate';

  @override
  String get remainingWork => 'Remaining work';

  @override
  String get completedWork => 'Completed work';

  @override
  String hours(String value) {
    return '$value h';
  }

  @override
  String get area => 'Area';

  @override
  String get iteration => 'Iteration';

  @override
  String get created => 'Created';

  @override
  String createdOnBy(String date, String name) {
    return '$date by $name';
  }

  @override
  String get changed => 'Changed';

  @override
  String get linkedItems => 'Linked items';

  @override
  String get parent => 'Parent';

  @override
  String get child => 'Child';

  @override
  String commentsCount(int count) {
    return 'Comments ($count)';
  }

  @override
  String get noComments => 'No comments yet.';

  @override
  String get unknownPerson => 'Unknown';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String daysAgo(int count) {
    return '$count d ago';
  }

  @override
  String get errorUnauthorized =>
      'Not authorized. Check your Personal Access Token.';

  @override
  String get errorNotFound =>
      'Not found. Check the organization or the project.';

  @override
  String errorHttp(int code) {
    return 'Error $code from Azure DevOps';
  }

  @override
  String get errorUnexpectedResponse =>
      'Unexpected response. Check the organization and your token.';

  @override
  String get widgetSetupRequired => 'Open the app to set up';

  @override
  String get tickets => 'Tickets';

  @override
  String get pipelines => 'Pipelines';

  @override
  String get searchRunsHint => 'Search by pipeline, branch or person';

  @override
  String get activeOnly => 'Active only';

  @override
  String get loadRunsFailed => 'Couldn\'t load pipeline runs';

  @override
  String get noRunsTitle => 'No pipeline runs';

  @override
  String get noRunsMessage =>
      'There are no pipeline runs matching the filters.';

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
  String get selectRunTitle => 'Select a pipeline run';

  @override
  String get selectRunMessage =>
      'Choose a run on the left to follow its progress.';

  @override
  String get runPending => 'Waiting';

  @override
  String get runQueued => 'Queued';

  @override
  String get runRunning => 'Running';

  @override
  String get runCancelling => 'Cancelling';

  @override
  String get runSucceeded => 'Succeeded';

  @override
  String get runPartiallySucceeded => 'Partially succeeded';

  @override
  String get runFailed => 'Failed';

  @override
  String get runCanceled => 'Canceled';

  @override
  String get runSkipped => 'Skipped';

  @override
  String get progress => 'Progress';

  @override
  String tasksProgress(int done, int total) {
    return '$done of $total tasks done';
  }

  @override
  String get branch => 'Branch';

  @override
  String get requestedBy => 'Requested by';

  @override
  String get queued => 'Queued';

  @override
  String get started => 'Started';

  @override
  String get finished => 'Finished';

  @override
  String get duration => 'Duration';

  @override
  String get stages => 'Stages';

  @override
  String get noStagesYet => 'The stages appear once the run starts.';
}
