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
  String get onboardingIntro =>
      'अपने टिकट देखने के लिए Azure DevOps से कनेक्ट करें।';

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
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'एक टोकन पहले से सहेजा गया है। बदलने के लिए फिर से दर्ज करें।';

  @override
  String get tokenScopeHint =>
      'आवश्यक स्कोप: Work Items (Read) और Project and Team (Read)';

  @override
  String get tokenRequired => 'अपना टोकन दर्ज करें';

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
  String get signOut => 'साइन आउट';

  @override
  String get selectTicketTitle => 'एक टिकट चुनें';

  @override
  String get selectTicketMessage => 'विवरण देखने के लिए बाईं ओर एक टिकट चुनें।';

  @override
  String get chooseProject => 'प्रोजेक्ट चुनें';

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
  String get noProjectTitle => 'कोई प्रोजेक्ट नहीं चुना गया';

  @override
  String get noProjectMessage => 'टिकट देखने के लिए एक प्रोजेक्ट चुनें।';

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
  String get chooseAProject => 'एक प्रोजेक्ट चुनें';

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
      'अधिकृत नहीं। अपना Personal Access Token जाँचें।';

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
}
