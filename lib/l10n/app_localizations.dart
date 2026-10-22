import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('uk'),
    Locale('zh'),
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @connectionSaved.
  ///
  /// In en, this message translates to:
  /// **'Connection saved'**
  String get connectionSaved;

  /// No description provided for @onboardingIntro.
  ///
  /// In en, this message translates to:
  /// **'Connect to Azure DevOps to get started.'**
  String get onboardingIntro;

  /// No description provided for @connection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connection;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @organizationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. mycompany or https://dev.azure.com/mycompany'**
  String get organizationHint;

  /// No description provided for @organizationRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your organization'**
  String get organizationRequired;

  /// No description provided for @personalAccessToken.
  ///
  /// In en, this message translates to:
  /// **'Personal Access Token'**
  String get personalAccessToken;

  /// No description provided for @tokenAlreadyStored.
  ///
  /// In en, this message translates to:
  /// **'A token is already stored. Enter it again to change it.'**
  String get tokenAlreadyStored;

  /// No description provided for @requiredScopes.
  ///
  /// In en, this message translates to:
  /// **'Required scopes'**
  String get requiredScopes;

  /// No description provided for @tokenRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your token'**
  String get tokenRequired;

  /// No description provided for @tokenHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'How do I create a token?'**
  String get tokenHelpTitle;

  /// No description provided for @tokenHelpStep1.
  ///
  /// In en, this message translates to:
  /// **'In Azure DevOps, open User settings → Personal access tokens and select New Token.'**
  String get tokenHelpStep1;

  /// No description provided for @tokenHelpStep2.
  ///
  /// In en, this message translates to:
  /// **'Pick your organization and an expiration date.'**
  String get tokenHelpStep2;

  /// No description provided for @tokenHelpStep3.
  ///
  /// In en, this message translates to:
  /// **'Under Scopes, choose Custom defined and enable only the scopes listed above, each with Read.'**
  String get tokenHelpStep3;

  /// No description provided for @tokenHelpStep4.
  ///
  /// In en, this message translates to:
  /// **'Select Create, copy the token and paste it above. It is shown only once.'**
  String get tokenHelpStep4;

  /// No description provided for @tokenHelpPermissions.
  ///
  /// In en, this message translates to:
  /// **'A token never has more rights than your account: you need at least Stakeholder access and read access to the projects you want to see.'**
  String get tokenHelpPermissions;

  /// No description provided for @tokenHelpDocs.
  ///
  /// In en, this message translates to:
  /// **'Microsoft documentation'**
  String get tokenHelpDocs;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @colorAzureBlue.
  ///
  /// In en, this message translates to:
  /// **'Azure blue'**
  String get colorAzureBlue;

  /// No description provided for @colorSystem.
  ///
  /// In en, this message translates to:
  /// **'System color'**
  String get colorSystem;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get languageSystem;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @madeBy.
  ///
  /// In en, this message translates to:
  /// **'Made by {name}'**
  String madeBy(String name);

  /// No description provided for @sendErrorReports.
  ///
  /// In en, this message translates to:
  /// **'Send error reports'**
  String get sendErrorReports;

  /// No description provided for @sendErrorReportsHint.
  ///
  /// In en, this message translates to:
  /// **'Sends anonymous crash and error details so bugs can be fixed. Your token is never sent.'**
  String get sendErrorReportsHint;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @selectTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a ticket'**
  String get selectTicketTitle;

  /// No description provided for @selectTicketMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a ticket on the left to see its details.'**
  String get selectTicketMessage;

  /// No description provided for @chooseProjects.
  ///
  /// In en, this message translates to:
  /// **'Choose projects'**
  String get chooseProjects;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @searchTicketsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by title, ID, tag or person'**
  String get searchTicketsHint;

  /// No description provided for @scopeAssignedToMe.
  ///
  /// In en, this message translates to:
  /// **'Assigned to me'**
  String get scopeAssignedToMe;

  /// No description provided for @scopeCreatedByMe.
  ///
  /// In en, this message translates to:
  /// **'Created by me'**
  String get scopeCreatedByMe;

  /// No description provided for @scopeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get scopeAll;

  /// No description provided for @openOnly.
  ///
  /// In en, this message translates to:
  /// **'Open only'**
  String get openOnly;

  /// No description provided for @loadTicketsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load tickets'**
  String get loadTicketsFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @noProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'No projects selected'**
  String get noProjectsTitle;

  /// No description provided for @noProjectsMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose one or more projects to view tickets.'**
  String get noProjectsMessage;

  /// No description provided for @noTicketsTitle.
  ///
  /// In en, this message translates to:
  /// **'No tickets'**
  String get noTicketsTitle;

  /// No description provided for @noTicketsMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no tickets matching the filters.'**
  String get noTicketsMessage;

  /// No description provided for @ticketCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 ticket} other{{count} tickets}}'**
  String ticketCount(int count);

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @projectCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 project} other{{count} projects}}'**
  String projectCount(int count);

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @searchProjectHint.
  ///
  /// In en, this message translates to:
  /// **'Search project'**
  String get searchProjectHint;

  /// No description provided for @loadProjectsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load projects'**
  String get loadProjectsFailed;

  /// No description provided for @browserOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the browser'**
  String get browserOpenFailed;

  /// No description provided for @openInDevOps.
  ///
  /// In en, this message translates to:
  /// **'Open in DevOps'**
  String get openInDevOps;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @reproSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps to reproduce'**
  String get reproSteps;

  /// No description provided for @acceptanceCriteria.
  ///
  /// In en, this message translates to:
  /// **'Acceptance criteria'**
  String get acceptanceCriteria;

  /// No description provided for @symptom.
  ///
  /// In en, this message translates to:
  /// **'Symptom'**
  String get symptom;

  /// No description provided for @systemInfo.
  ///
  /// In en, this message translates to:
  /// **'System info'**
  String get systemInfo;

  /// No description provided for @proposedFix.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get proposedFix;

  /// No description provided for @emptyField.
  ///
  /// In en, this message translates to:
  /// **'No content'**
  String get emptyField;

  /// No description provided for @assignedTo.
  ///
  /// In en, this message translates to:
  /// **'Assigned to'**
  String get assignedTo;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @effort.
  ///
  /// In en, this message translates to:
  /// **'Effort'**
  String get effort;

  /// No description provided for @originalEstimate.
  ///
  /// In en, this message translates to:
  /// **'Original estimate'**
  String get originalEstimate;

  /// No description provided for @remainingWork.
  ///
  /// In en, this message translates to:
  /// **'Remaining work'**
  String get remainingWork;

  /// No description provided for @completedWork.
  ///
  /// In en, this message translates to:
  /// **'Completed work'**
  String get completedWork;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'{value} h'**
  String hours(String value);

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @iteration.
  ///
  /// In en, this message translates to:
  /// **'Iteration'**
  String get iteration;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @createdOnBy.
  ///
  /// In en, this message translates to:
  /// **'{date} by {name}'**
  String createdOnBy(String date, String name);

  /// No description provided for @changed.
  ///
  /// In en, this message translates to:
  /// **'Changed'**
  String get changed;

  /// No description provided for @linkedItems.
  ///
  /// In en, this message translates to:
  /// **'Linked items'**
  String get linkedItems;

  /// No description provided for @parent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parent;

  /// No description provided for @child.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get child;

  /// No description provided for @commentsCount.
  ///
  /// In en, this message translates to:
  /// **'Comments ({count})'**
  String commentsCount(int count);

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get noComments;

  /// No description provided for @unknownPerson.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownPerson;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} d ago'**
  String daysAgo(int count);

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Not authorized. Check your Personal Access Token.'**
  String get errorUnauthorized;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found. Check the organization or the project.'**
  String get errorNotFound;

  /// No description provided for @errorHttp.
  ///
  /// In en, this message translates to:
  /// **'Error {code} from Azure DevOps'**
  String errorHttp(int code);

  /// No description provided for @errorUnexpectedResponse.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response. Check the organization and your token.'**
  String get errorUnexpectedResponse;

  /// No description provided for @widgetSetupRequired.
  ///
  /// In en, this message translates to:
  /// **'Open the app to set up'**
  String get widgetSetupRequired;

  /// No description provided for @tickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get tickets;

  /// No description provided for @pipelines.
  ///
  /// In en, this message translates to:
  /// **'Pipelines'**
  String get pipelines;

  /// No description provided for @searchRunsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by pipeline, branch or person'**
  String get searchRunsHint;

  /// No description provided for @activeOnly.
  ///
  /// In en, this message translates to:
  /// **'Active only'**
  String get activeOnly;

  /// No description provided for @loadRunsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load pipeline runs'**
  String get loadRunsFailed;

  /// No description provided for @noRunsTitle.
  ///
  /// In en, this message translates to:
  /// **'No pipeline runs'**
  String get noRunsTitle;

  /// No description provided for @noRunsMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no pipeline runs matching the filters.'**
  String get noRunsMessage;

  /// No description provided for @runCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 run} other{{count} runs}}'**
  String runCount(int count);

  /// No description provided for @selectRunTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a pipeline run'**
  String get selectRunTitle;

  /// No description provided for @selectRunMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a run on the left to follow its progress.'**
  String get selectRunMessage;

  /// No description provided for @runPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get runPending;

  /// No description provided for @runQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get runQueued;

  /// No description provided for @runRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get runRunning;

  /// No description provided for @runCancelling.
  ///
  /// In en, this message translates to:
  /// **'Cancelling'**
  String get runCancelling;

  /// No description provided for @runSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Succeeded'**
  String get runSucceeded;

  /// No description provided for @runPartiallySucceeded.
  ///
  /// In en, this message translates to:
  /// **'Partially succeeded'**
  String get runPartiallySucceeded;

  /// No description provided for @runFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get runFailed;

  /// No description provided for @runCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get runCanceled;

  /// No description provided for @runSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get runSkipped;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @tasksProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} tasks done'**
  String tasksProgress(int done, int total);

  /// No description provided for @branch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branch;

  /// No description provided for @requestedBy.
  ///
  /// In en, this message translates to:
  /// **'Requested by'**
  String get requestedBy;

  /// No description provided for @queued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get queued;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @stages.
  ///
  /// In en, this message translates to:
  /// **'Stages'**
  String get stages;

  /// No description provided for @noStagesYet.
  ///
  /// In en, this message translates to:
  /// **'The stages appear once the run starts.'**
  String get noStagesYet;

  /// No description provided for @runWaitingForApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get runWaitingForApproval;

  /// No description provided for @runNotDeployed.
  ///
  /// In en, this message translates to:
  /// **'Not deployed'**
  String get runNotDeployed;

  /// No description provided for @builds.
  ///
  /// In en, this message translates to:
  /// **'Builds'**
  String get builds;

  /// No description provided for @releases.
  ///
  /// In en, this message translates to:
  /// **'Releases'**
  String get releases;

  /// No description provided for @loadReleasesFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the releases'**
  String get loadReleasesFailed;

  /// No description provided for @releaseScopeHint.
  ///
  /// In en, this message translates to:
  /// **'Releases need the Release (Read) scope on your token.'**
  String get releaseScopeHint;

  /// No description provided for @artifact.
  ///
  /// In en, this message translates to:
  /// **'Artifact'**
  String get artifact;

  /// No description provided for @waitingForApprovalBy.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval by {names}'**
  String waitingForApprovalBy(String names);

  /// No description provided for @pullRequests.
  ///
  /// In en, this message translates to:
  /// **'Pull requests'**
  String get pullRequests;

  /// No description provided for @searchPullRequestsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by title, ID, branch or person'**
  String get searchPullRequestsHint;

  /// No description provided for @scopeReviewing.
  ///
  /// In en, this message translates to:
  /// **'Reviewing'**
  String get scopeReviewing;

  /// No description provided for @loadPullRequestsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load pull requests'**
  String get loadPullRequestsFailed;

  /// No description provided for @codeScopeHint.
  ///
  /// In en, this message translates to:
  /// **'Pull requests need the Code (Read) scope on your token.'**
  String get codeScopeHint;

  /// No description provided for @noPullRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'No pull requests'**
  String get noPullRequestsTitle;

  /// No description provided for @noPullRequestsMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no pull requests matching the filters.'**
  String get noPullRequestsMessage;

  /// No description provided for @pullRequestCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pull request} other{{count} pull requests}}'**
  String pullRequestCount(int count);

  /// No description provided for @selectPullRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a pull request'**
  String get selectPullRequestTitle;

  /// No description provided for @selectPullRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a pull request on the left to see its details.'**
  String get selectPullRequestMessage;

  /// No description provided for @prDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get prDraft;

  /// No description provided for @prActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get prActive;

  /// No description provided for @prCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get prCompleted;

  /// No description provided for @prAbandoned.
  ///
  /// In en, this message translates to:
  /// **'Abandoned'**
  String get prAbandoned;

  /// No description provided for @mergeConflicts.
  ///
  /// In en, this message translates to:
  /// **'Merge conflicts'**
  String get mergeConflicts;

  /// No description provided for @repository.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get repository;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @reviewers.
  ///
  /// In en, this message translates to:
  /// **'Reviewers'**
  String get reviewers;

  /// No description provided for @noReviewers.
  ///
  /// In en, this message translates to:
  /// **'No reviewers'**
  String get noReviewers;

  /// No description provided for @requiredReviewer.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredReviewer;

  /// No description provided for @voteApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get voteApproved;

  /// No description provided for @voteApprovedWithSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Approved with suggestions'**
  String get voteApprovedWithSuggestions;

  /// No description provided for @voteNone.
  ///
  /// In en, this message translates to:
  /// **'No vote'**
  String get voteNone;

  /// No description provided for @voteWaitingForAuthor.
  ///
  /// In en, this message translates to:
  /// **'Waiting for author'**
  String get voteWaitingForAuthor;

  /// No description provided for @voteRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get voteRejected;

  /// No description provided for @threadResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get threadResolved;

  /// No description provided for @runErrors.
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get runErrors;

  /// No description provided for @viewLog.
  ///
  /// In en, this message translates to:
  /// **'View log'**
  String get viewLog;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all ({count})'**
  String showAll(int count);

  /// No description provided for @copyLog.
  ///
  /// In en, this message translates to:
  /// **'Copy log'**
  String get copyLog;

  /// No description provided for @logCopied.
  ///
  /// In en, this message translates to:
  /// **'Log copied'**
  String get logCopied;

  /// No description provided for @logEmpty.
  ///
  /// In en, this message translates to:
  /// **'This log is empty.'**
  String get logEmpty;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @onlyErrorsAndWarnings.
  ///
  /// In en, this message translates to:
  /// **'Only errors and warnings'**
  String get onlyErrorsAndWarnings;

  /// No description provided for @noLogIssues.
  ///
  /// In en, this message translates to:
  /// **'No errors or warnings in this log.'**
  String get noLogIssues;

  /// No description provided for @previousError.
  ///
  /// In en, this message translates to:
  /// **'Previous error'**
  String get previousError;

  /// No description provided for @nextError.
  ///
  /// In en, this message translates to:
  /// **'Next error'**
  String get nextError;

  /// No description provided for @errorPosition.
  ///
  /// In en, this message translates to:
  /// **'Error {current} of {total}'**
  String errorPosition(int current, int total);

  /// No description provided for @errorCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 error} other{{count} errors}}'**
  String errorCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'it',
    'ja',
    'ko',
    'nl',
    'pl',
    'pt',
    'ru',
    'tr',
    'uk',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
