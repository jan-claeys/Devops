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
  String get onboardingIntro => 'Connect to Azure DevOps to get started.';

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
  String get organizationInsecure =>
      'Use an https:// address so your token isn\'t sent unencrypted';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'A token is already stored. Enter it again to change it.';

  @override
  String get requiredScopes => 'Required scopes';

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
      'Under Scopes, choose Custom defined and enable only the scopes listed above, each with the permission shown next to it.';

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
  String attachmentsCount(int count) {
    return 'Attachments ($count)';
  }

  @override
  String get openFile => 'Open file';

  @override
  String get download => 'Download';

  @override
  String get downloadLargeTitle => 'Download large file?';

  @override
  String downloadLargeBody(String name, String size) {
    return '$name is $size. Downloading it can take a while and use mobile data.';
  }

  @override
  String get noAppForFile => 'No app on this device can open this file.';

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
      'Your Personal Access Token is invalid or has expired. Create a new one in the settings.';

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

  @override
  String get runWaitingForApproval => 'Waiting for approval';

  @override
  String get runNotDeployed => 'Not deployed';

  @override
  String get builds => 'Builds';

  @override
  String get releases => 'Releases';

  @override
  String get loadReleasesFailed => 'Couldn\'t load the releases';

  @override
  String get releaseScopeHint =>
      'Releases need the Release (Read, write, & execute) scope on your token.';

  @override
  String get artifact => 'Artifact';

  @override
  String waitingForApprovalBy(String names) {
    return 'Waiting for approval by $names';
  }

  @override
  String get approvals => 'Approvals';

  @override
  String approveStage(String stage) {
    return 'Approve $stage?';
  }

  @override
  String rejectStage(String stage) {
    return 'Reject $stage?';
  }

  @override
  String get approvalCommentHint => 'Comment (optional)';

  @override
  String get stageApproved => 'Stage approved';

  @override
  String get stageRejected => 'Stage rejected';

  @override
  String get buildScopeHint =>
      'Acting on pipeline runs needs the Build (Read & execute) scope on your token.';

  @override
  String get cancelRun => 'Cancel run';

  @override
  String get cancelRunTitle => 'Cancel this run?';

  @override
  String get cancelRunBody =>
      'Jobs that are running are stopped and the ones that haven\'t started are skipped.';

  @override
  String get keepRunning => 'Keep running';

  @override
  String get runAgain => 'Run again';

  @override
  String get rerunFailedJobs => 'Rerun failed jobs';

  @override
  String get runStarted => 'Run started';

  @override
  String get open => 'Open';

  @override
  String get pullRequests => 'Pull requests';

  @override
  String get searchPullRequestsHint => 'Search by title, ID, branch or person';

  @override
  String get scopeReviewing => 'Reviewing';

  @override
  String get loadPullRequestsFailed => 'Couldn\'t load pull requests';

  @override
  String get codeScopeHint =>
      'Pull requests need the Code (Read & write) scope on your token.';

  @override
  String get noPullRequestsTitle => 'No pull requests';

  @override
  String get noPullRequestsMessage =>
      'There are no pull requests matching the filters.';

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
  String get selectPullRequestTitle => 'Select a pull request';

  @override
  String get selectPullRequestMessage =>
      'Choose a pull request on the left to see its details.';

  @override
  String get prDraft => 'Draft';

  @override
  String get prActive => 'Active';

  @override
  String get prCompleted => 'Completed';

  @override
  String get prAbandoned => 'Abandoned';

  @override
  String get mergeConflicts => 'Merge conflicts';

  @override
  String get repository => 'Repository';

  @override
  String get closed => 'Closed';

  @override
  String get reviewers => 'Reviewers';

  @override
  String get noReviewers => 'No reviewers';

  @override
  String get requiredReviewer => 'Required';

  @override
  String get voteApproved => 'Approved';

  @override
  String get voteApprovedWithSuggestions => 'Approved with suggestions';

  @override
  String get voteNone => 'No vote';

  @override
  String get voteWaitingForAuthor => 'Waiting for author';

  @override
  String get voteRejected => 'Rejected';

  @override
  String get threadResolved => 'Resolved';

  @override
  String get overviewTab => 'Overview';

  @override
  String get filesTab => 'Files';

  @override
  String filesChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files changed',
      one: '1 file changed',
    );
    return '$_temp0';
  }

  @override
  String get noFileChanges => 'This pull request doesn\'t change any files.';

  @override
  String get loadFilesFailed => 'Couldn\'t load the changed files';

  @override
  String get loadFileFailed => 'Couldn\'t load this file';

  @override
  String get binaryFile => 'Binary file';

  @override
  String get fileTooLarge => 'Too large to compare here';

  @override
  String get noContentChanges => 'No changes to the content';

  @override
  String renamedFrom(String path) {
    return 'Renamed from $path';
  }

  @override
  String get voteApprove => 'Approve';

  @override
  String get voteApproveWithSuggestions => 'Approve with suggestions';

  @override
  String get voteWaitForAuthor => 'Wait for author';

  @override
  String get voteReject => 'Reject';

  @override
  String get voteReset => 'Reset vote';

  @override
  String get otherVotes => 'Other votes';

  @override
  String get rejectConfirmTitle => 'Reject this pull request?';

  @override
  String get rejectConfirmBody =>
      'The pull request can\'t be completed as long as your vote is Rejected.';

  @override
  String get waitForAuthorConfirmTitle => 'Wait for the author?';

  @override
  String get voteReasonHint => 'Reason (optional)';

  @override
  String get voteReasonHelper => 'Posted as a comment on the pull request.';

  @override
  String get voteSaved => 'Vote saved';

  @override
  String get cancel => 'Cancel';

  @override
  String get actionDenied =>
      'Azure DevOps didn\'t allow this. Check that your token has the right scope and that your account has permission.';

  @override
  String get writeComment => 'Write a comment…';

  @override
  String get send => 'Send';

  @override
  String get reply => 'Reply';

  @override
  String get writeReply => 'Write a reply…';

  @override
  String get resolveThread => 'Resolve';

  @override
  String get reactivateThread => 'Reactivate';

  @override
  String get workItemScopeHint =>
      'Commenting on tickets needs the Work Items (Read & write) scope on your token.';

  @override
  String get changeAssignee => 'Change assignee';

  @override
  String get searchPeopleHint => 'Search people';

  @override
  String get assignToMe => 'Assign to me';

  @override
  String assignedToName(String name) {
    return 'Assigned to $name';
  }

  @override
  String get ticketUnassigned => 'Ticket unassigned';

  @override
  String get assignScopeHint =>
      'Assigning tickets needs the Work Items (Read & write) scope on your token.';

  @override
  String get membersLoadFailed =>
      'Couldn\'t load the team members. That needs the Project and Team (Read) scope on your token.';

  @override
  String get noPeopleFound => 'No one found';

  @override
  String get copyLink => 'Copy link';

  @override
  String get shareTicket => 'Share';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get undo => 'Undo';

  @override
  String get runErrors => 'Errors';

  @override
  String get viewLog => 'View log';

  @override
  String showAll(int count) {
    return 'Show all ($count)';
  }

  @override
  String get copyLog => 'Copy log';

  @override
  String get logCopied => 'Log copied';

  @override
  String get logEmpty => 'This log is empty.';

  @override
  String get showMore => 'Show more';

  @override
  String get showLess => 'Show less';

  @override
  String get onlyErrorsAndWarnings => 'Only errors and warnings';

  @override
  String get noLogIssues => 'No errors or warnings in this log.';

  @override
  String get previousError => 'Previous error';

  @override
  String get nextError => 'Next error';

  @override
  String errorPosition(int current, int total) {
    return 'Error $current of $total';
  }

  @override
  String errorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count errors',
      one: '1 error',
    );
    return '$_temp0';
  }

  @override
  String get dashboard => 'Overview';

  @override
  String refreshFailed(String time) {
    return 'Couldn\'t refresh. Showing data from $time.';
  }

  @override
  String get loadDashboardFailed => 'Couldn\'t load the overview';

  @override
  String get myPullRequests => 'My pull requests';

  @override
  String get myTickets => 'My open tickets';

  @override
  String get waitingForYourReview => 'Waiting for your review';

  @override
  String get waitingForYou => 'Waiting for you';

  @override
  String get nothingWaiting => 'Nothing is waiting for you right now.';

  @override
  String get readyToComplete => 'Approved, ready to complete';

  @override
  String get yourApproval => 'Waiting for your approval';

  @override
  String get myRuns => 'My runs';

  @override
  String get noRecentRuns => 'You haven\'t started any runs recently.';

  @override
  String failingOnMain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pipelines fail on the main branch',
      one: '1 pipeline fails on the main branch',
    );
    return '$_temp0';
  }

  @override
  String noChangesFor(int count) {
    return 'No changes for $count d';
  }

  @override
  String get linkNotSupported => 'This link can\'t be opened in the app.';

  @override
  String get linkOtherOrganization =>
      'This link is from another organization than the one you\'re signed in to.';

  @override
  String get notifications => 'Notifications';

  @override
  String get runNotificationsHint =>
      'Shows the progress of running pipelines while the app is open, and keeps following them in the background until they finish.';

  @override
  String get runNotificationsOff => 'Off';

  @override
  String get runNotificationsMine => 'My runs';

  @override
  String get runNotificationsAll => 'All runs';

  @override
  String get runNotificationChannel => 'Pipeline progress';

  @override
  String get notificationsDenied =>
      'Notifications are turned off for this app in the Android settings.';

  @override
  String runNotificationsRunning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pipelines running',
      one: '1 pipeline running',
    );
    return '$_temp0';
  }
}
