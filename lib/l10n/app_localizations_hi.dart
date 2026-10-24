// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get welcome => 'स्वागत है';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get connectionSaved => 'कनेक्शन सहेजा गया';

  @override
  String get onboardingIntro => 'शुरू करने के लिए Azure DevOps से कनेक्ट करें।';

  @override
  String get connection => 'कनेक्शन';

  @override
  String get organization => 'संगठन';

  @override
  String get organizationHint =>
      'जैसे mycompany या https://dev.azure.com/mycompany';

  @override
  String get organizationRequired => 'अपना संगठन दर्ज करें';

  @override
  String get organizationInsecure =>
      'https:// पता उपयोग करें ताकि आपका टोकन बिना एन्क्रिप्शन के न भेजा जाए';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'एक टोकन पहले से सहेजा गया है। बदलने के लिए फिर से दर्ज करें।';

  @override
  String get requiredScopes => 'आवश्यक स्कोप';

  @override
  String get tokenRequired => 'अपना टोकन दर्ज करें';

  @override
  String get tokenHelpTitle => 'टोकन कैसे बनाएँ?';

  @override
  String get tokenHelpStep1 =>
      'Azure DevOps में User settings → Personal access tokens खोलें और New Token चुनें।';

  @override
  String get tokenHelpStep2 => 'अपना संगठन और समाप्ति तिथि चुनें।';

  @override
  String get tokenHelpStep3 =>
      'Scopes में Custom defined चुनें और केवल ऊपर दिए गए स्कोप को उनके बगल में दिखाई गई अनुमति के साथ चालू करें।';

  @override
  String get tokenHelpStep4 =>
      'Create चुनें, टोकन कॉपी करें और ऊपर पेस्ट करें। यह केवल एक बार दिखाया जाता है।';

  @override
  String get tokenHelpPermissions =>
      'टोकन के पास कभी भी आपके खाते से अधिक अधिकार नहीं होते: आपको कम से कम Stakeholder एक्सेस और जिन प्रोजेक्ट्स को देखना है उन पर पढ़ने की अनुमति चाहिए।';

  @override
  String get tokenHelpDocs => 'Microsoft दस्तावेज़';

  @override
  String get connecting => 'कनेक्ट हो रहा है…';

  @override
  String get connect => 'कनेक्ट करें';

  @override
  String get appearance => 'रूप';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeDark => 'डार्क';

  @override
  String get colorAzureBlue => 'Azure नीला';

  @override
  String get colorSystem => 'सिस्टम रंग';

  @override
  String get language => 'भाषा';

  @override
  String get languageSystem => 'सिस्टम भाषा';

  @override
  String get privacy => 'गोपनीयता';

  @override
  String get about => 'परिचय';

  @override
  String appVersion(String version) {
    return 'संस्करण $version';
  }

  @override
  String madeBy(String name) {
    return '$name द्वारा निर्मित';
  }

  @override
  String get sendErrorReports => 'त्रुटि रिपोर्ट भेजें';

  @override
  String get sendErrorReportsHint =>
      'बग ठीक करने के लिए क्रैश और त्रुटियों का गुमनाम विवरण भेजता है। आपका टोकन कभी नहीं भेजा जाता।';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get selectTicketTitle => 'एक टिकट चुनें';

  @override
  String get selectTicketMessage => 'विवरण देखने के लिए बाईं ओर एक टिकट चुनें।';

  @override
  String get chooseProjects => 'प्रोजेक्ट चुनें';

  @override
  String get refresh => 'रीफ़्रेश करें';

  @override
  String get searchTicketsHint => 'शीर्षक, ID, टैग या व्यक्ति से खोजें';

  @override
  String get scopeAssignedToMe => 'मुझे सौंपे गए';

  @override
  String get scopeCreatedByMe => 'मेरे बनाए';

  @override
  String get scopeAll => 'सभी';

  @override
  String get openOnly => 'केवल खुले';

  @override
  String get loadTicketsFailed => 'टिकट लोड नहीं हो सके';

  @override
  String get retry => 'फिर से कोशिश करें';

  @override
  String get noProjectsTitle => 'कोई प्रोजेक्ट नहीं चुना गया';

  @override
  String get noProjectsMessage =>
      'टिकट देखने के लिए एक या अधिक प्रोजेक्ट चुनें।';

  @override
  String get noTicketsTitle => 'कोई टिकट नहीं';

  @override
  String get noTicketsMessage => 'फ़िल्टर से मेल खाने वाला कोई टिकट नहीं है।';

  @override
  String ticketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count टिकट',
    );
    return '$_temp0';
  }

  @override
  String get unassigned => 'असाइन नहीं';

  @override
  String get projects => 'प्रोजेक्ट';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रोजेक्ट',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'लागू करें';

  @override
  String get searchProjectHint => 'प्रोजेक्ट खोजें';

  @override
  String get loadProjectsFailed => 'प्रोजेक्ट लोड नहीं हो सके';

  @override
  String get browserOpenFailed => 'ब्राउज़र नहीं खुल सका';

  @override
  String get openInDevOps => 'DevOps में खोलें';

  @override
  String get description => 'विवरण';

  @override
  String get reproSteps => 'पुनः उत्पन्न करने के चरण';

  @override
  String get acceptanceCriteria => 'स्वीकृति मानदंड';

  @override
  String get symptom => 'लक्षण';

  @override
  String get systemInfo => 'सिस्टम जानकारी';

  @override
  String get proposedFix => 'सुधार';

  @override
  String get emptyField => 'कोई सामग्री नहीं';

  @override
  String get assignedTo => 'सौंपा गया';

  @override
  String get priority => 'प्राथमिकता';

  @override
  String get effort => 'प्रयास';

  @override
  String get originalEstimate => 'मूल अनुमान';

  @override
  String get remainingWork => 'शेष कार्य';

  @override
  String get completedWork => 'पूरा कार्य';

  @override
  String hours(String value) {
    return '$value घं';
  }

  @override
  String get area => 'क्षेत्र';

  @override
  String get iteration => 'इटरेशन';

  @override
  String get created => 'बनाया गया';

  @override
  String createdOnBy(String date, String name) {
    return '$date, $name द्वारा';
  }

  @override
  String get changed => 'बदला गया';

  @override
  String get linkedItems => 'लिंक किए गए आइटम';

  @override
  String get parent => 'पैरेंट';

  @override
  String get child => 'चाइल्ड';

  @override
  String commentsCount(int count) {
    return 'टिप्पणियाँ ($count)';
  }

  @override
  String get noComments => 'अभी कोई टिप्पणी नहीं।';

  @override
  String attachmentsCount(int count) {
    return 'अटैचमेंट ($count)';
  }

  @override
  String get openFile => 'फ़ाइल खोलें';

  @override
  String get download => 'डाउनलोड करें';

  @override
  String get downloadLargeTitle => 'बड़ी फ़ाइल डाउनलोड करें?';

  @override
  String downloadLargeBody(String name, String size) {
    return '$name का आकार $size है। डाउनलोड में समय लग सकता है और मोबाइल डेटा खर्च हो सकता है।';
  }

  @override
  String get noAppForFile => 'इस डिवाइस पर कोई ऐप यह फ़ाइल नहीं खोल सकता।';

  @override
  String get unknownPerson => 'अज्ञात';

  @override
  String get justNow => 'अभी';

  @override
  String minutesAgo(int count) {
    return '$count मिनट पहले';
  }

  @override
  String hoursAgo(int count) {
    return '$count घंटे पहले';
  }

  @override
  String daysAgo(int count) {
    return '$count दिन पहले';
  }

  @override
  String get errorUnauthorized =>
      'आपका Personal Access Token अमान्य है या उसकी समय-सीमा समाप्त हो गई है। सेटिंग्स में नया बनाएँ।';

  @override
  String get errorNotFound => 'नहीं मिला। संगठन या प्रोजेक्ट जाँचें।';

  @override
  String errorHttp(int code) {
    return 'Azure DevOps से त्रुटि $code';
  }

  @override
  String get errorUnexpectedResponse =>
      'अप्रत्याशित प्रतिक्रिया। संगठन और अपना टोकन जाँचें।';

  @override
  String get widgetSetupRequired => 'सेट अप करने के लिए ऐप खोलें';

  @override
  String get tickets => 'टिकट';

  @override
  String get pipelines => 'पाइपलाइन';

  @override
  String get searchRunsHint => 'पाइपलाइन, ब्रांच या व्यक्ति से खोजें';

  @override
  String get activeOnly => 'केवल सक्रिय';

  @override
  String get loadRunsFailed => 'पाइपलाइन रन लोड नहीं हो सके';

  @override
  String get noRunsTitle => 'कोई पाइपलाइन रन नहीं';

  @override
  String get noRunsMessage =>
      'फ़िल्टर से मेल खाने वाला कोई पाइपलाइन रन नहीं है।';

  @override
  String runCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रन',
      one: '1 रन',
    );
    return '$_temp0';
  }

  @override
  String get selectRunTitle => 'एक पाइपलाइन रन चुनें';

  @override
  String get selectRunMessage => 'प्रगति देखने के लिए बाईं ओर एक रन चुनें।';

  @override
  String get runPending => 'प्रतीक्षा में';

  @override
  String get runQueued => 'कतार में';

  @override
  String get runRunning => 'चल रहा है';

  @override
  String get runCancelling => 'रद्द हो रहा है';

  @override
  String get runSucceeded => 'सफल';

  @override
  String get runPartiallySucceeded => 'आंशिक रूप से सफल';

  @override
  String get runFailed => 'विफल';

  @override
  String get runCanceled => 'रद्द किया गया';

  @override
  String get runSkipped => 'छोड़ा गया';

  @override
  String get progress => 'प्रगति';

  @override
  String tasksProgress(int done, int total) {
    return '$total में से $done कार्य पूरे';
  }

  @override
  String get branch => 'ब्रांच';

  @override
  String get requestedBy => 'अनुरोधकर्ता';

  @override
  String get queued => 'कतार में डाला गया';

  @override
  String get started => 'शुरू हुआ';

  @override
  String get finished => 'समाप्त हुआ';

  @override
  String get duration => 'अवधि';

  @override
  String get stages => 'चरण';

  @override
  String get noStagesYet => 'रन शुरू होने पर चरण दिखाई देंगे।';

  @override
  String get runWaitingForApproval => 'अनुमोदन की प्रतीक्षा';

  @override
  String get runNotDeployed => 'डिप्लॉय नहीं हुआ';

  @override
  String get builds => 'बिल्ड';

  @override
  String get releases => 'रिलीज़';

  @override
  String get loadReleasesFailed => 'रिलीज़ लोड नहीं हो सके';

  @override
  String get releaseScopeHint =>
      'रिलीज़ के लिए आपके टोकन में Release (Read) स्कोप चाहिए।';

  @override
  String get artifact => 'आर्टिफ़ैक्ट';

  @override
  String waitingForApprovalBy(String names) {
    return '$names के अनुमोदन की प्रतीक्षा';
  }

  @override
  String get pullRequests => 'पुल रिक्वेस्ट';

  @override
  String get searchPullRequestsHint => 'शीर्षक, ID, ब्रांच या व्यक्ति से खोजें';

  @override
  String get scopeReviewing => 'समीक्षा के लिए';

  @override
  String get loadPullRequestsFailed => 'पुल रिक्वेस्ट लोड नहीं हो सके';

  @override
  String get codeScopeHint =>
      'पुल रिक्वेस्ट के लिए आपके टोकन में Code (Read & write) स्कोप चाहिए।';

  @override
  String get noPullRequestsTitle => 'कोई पुल रिक्वेस्ट नहीं';

  @override
  String get noPullRequestsMessage =>
      'फ़िल्टर से मेल खाने वाला कोई पुल रिक्वेस्ट नहीं है।';

  @override
  String pullRequestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पुल रिक्वेस्ट',
      one: '1 पुल रिक्वेस्ट',
    );
    return '$_temp0';
  }

  @override
  String get selectPullRequestTitle => 'एक पुल रिक्वेस्ट चुनें';

  @override
  String get selectPullRequestMessage =>
      'विवरण देखने के लिए बाईं ओर एक पुल रिक्वेस्ट चुनें।';

  @override
  String get prDraft => 'ड्राफ़्ट';

  @override
  String get prActive => 'सक्रिय';

  @override
  String get prCompleted => 'पूर्ण';

  @override
  String get prAbandoned => 'छोड़ा गया';

  @override
  String get mergeConflicts => 'मर्ज विरोध';

  @override
  String get repository => 'रिपॉज़िटरी';

  @override
  String get closed => 'बंद';

  @override
  String get reviewers => 'समीक्षक';

  @override
  String get noReviewers => 'कोई समीक्षक नहीं';

  @override
  String get requiredReviewer => 'आवश्यक';

  @override
  String get voteApproved => 'स्वीकृत';

  @override
  String get voteApprovedWithSuggestions => 'सुझावों के साथ स्वीकृत';

  @override
  String get voteNone => 'कोई वोट नहीं';

  @override
  String get voteWaitingForAuthor => 'लेखक की प्रतीक्षा';

  @override
  String get voteRejected => 'अस्वीकृत';

  @override
  String get threadResolved => 'हल किया गया';

  @override
  String get voteApprove => 'स्वीकृत करें';

  @override
  String get voteApproveWithSuggestions => 'सुझावों के साथ स्वीकृत करें';

  @override
  String get voteWaitForAuthor => 'लेखक की प्रतीक्षा करें';

  @override
  String get voteReject => 'अस्वीकार करें';

  @override
  String get voteReset => 'वोट रीसेट करें';

  @override
  String get otherVotes => 'अन्य वोट';

  @override
  String get rejectConfirmTitle => 'इस पुल रिक्वेस्ट को अस्वीकार करें?';

  @override
  String get rejectConfirmBody =>
      'जब तक आपका वोट अस्वीकृत है, पुल रिक्वेस्ट पूरा नहीं किया जा सकता।';

  @override
  String get voteSaved => 'वोट सहेजा गया';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get actionDenied =>
      'Azure DevOps ने इसकी अनुमति नहीं दी। जाँचें कि आपके टोकन में सही स्कोप है और आपके खाते को अनुमति है।';

  @override
  String get writeComment => 'टिप्पणी लिखें…';

  @override
  String get send => 'भेजें';

  @override
  String get reply => 'जवाब दें';

  @override
  String get writeReply => 'जवाब लिखें…';

  @override
  String get runErrors => 'त्रुटियाँ';

  @override
  String get viewLog => 'लॉग देखें';

  @override
  String showAll(int count) {
    return 'सभी दिखाएँ ($count)';
  }

  @override
  String get copyLog => 'लॉग कॉपी करें';

  @override
  String get logCopied => 'लॉग कॉपी किया गया';

  @override
  String get logEmpty => 'यह लॉग खाली है।';

  @override
  String get showMore => 'और दिखाएँ';

  @override
  String get showLess => 'कम दिखाएँ';

  @override
  String get onlyErrorsAndWarnings => 'केवल त्रुटियाँ और चेतावनियाँ';

  @override
  String get noLogIssues => 'इस लॉग में कोई त्रुटि या चेतावनी नहीं है।';

  @override
  String get previousError => 'पिछली त्रुटि';

  @override
  String get nextError => 'अगली त्रुटि';

  @override
  String errorPosition(int current, int total) {
    return 'त्रुटि $current / $total';
  }

  @override
  String errorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count त्रुटियाँ',
      one: '1 त्रुटि',
    );
    return '$_temp0';
  }

  @override
  String get dashboard => 'अवलोकन';

  @override
  String refreshFailed(String time) {
    return 'रीफ़्रेश नहीं हो सका। डेटा: $time।';
  }

  @override
  String get loadDashboardFailed => 'अवलोकन लोड नहीं हो सका';

  @override
  String get myPullRequests => 'मेरे पुल रिक्वेस्ट';

  @override
  String get myTickets => 'मेरे खुले टिकट';

  @override
  String get waitingForYourReview => 'आपकी समीक्षा की प्रतीक्षा में';

  @override
  String get waitingForYou => 'आपकी प्रतीक्षा में';

  @override
  String get nothingWaiting => 'अभी कुछ भी आपकी प्रतीक्षा में नहीं है।';

  @override
  String get readyToComplete => 'स्वीकृत, पूरा करने के लिए तैयार';

  @override
  String get yourApproval => 'आपकी स्वीकृति की प्रतीक्षा में';

  @override
  String get myRuns => 'मेरे रन';

  @override
  String get noRecentRuns => 'आपने हाल में कोई रन शुरू नहीं किया।';

  @override
  String failingOnMain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पाइपलाइन मुख्य ब्रांच पर विफल हैं',
      one: '1 पाइपलाइन मुख्य ब्रांच पर विफल है',
    );
    return '$_temp0';
  }

  @override
  String noChangesFor(int count) {
    return '$count दिन से कोई बदलाव नहीं';
  }

  @override
  String get linkNotSupported => 'यह लिंक ऐप में नहीं खोला जा सकता।';

  @override
  String get linkOtherOrganization =>
      'यह लिंक उस संगठन का नहीं है जिससे आप जुड़े हैं।';

  @override
  String get notifications => 'सूचनाएँ';

  @override
  String get runNotificationsHint =>
      'ऐप खुला रहने पर चल रही पाइपलाइनों की प्रगति दिखाता है, और उनके पूरा होने तक बैकग्राउंड में उन्हें फ़ॉलो करता रहता है।';

  @override
  String get runNotificationsOff => 'बंद';

  @override
  String get runNotificationsMine => 'मेरे रन';

  @override
  String get runNotificationsAll => 'सभी रन';

  @override
  String get runNotificationChannel => 'पाइपलाइन की प्रगति';

  @override
  String get notificationsDenied =>
      'Android सेटिंग में इस ऐप के लिए सूचनाएँ बंद हैं।';

  @override
  String runNotificationsRunning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पाइपलाइन चल रही हैं',
      one: '1 पाइपलाइन चल रही है',
    );
    return '$_temp0';
  }
}
