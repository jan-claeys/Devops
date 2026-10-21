// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get welcome => 'مرحبًا';

  @override
  String get settings => 'الإعدادات';

  @override
  String get connectionSaved => 'تم حفظ الاتصال';

  @override
  String get onboardingIntro => 'اتصل بـ Azure DevOps لعرض تذاكرك.';

  @override
  String get connection => 'الاتصال';

  @override
  String get organization => 'المؤسسة';

  @override
  String get organizationHint =>
      'مثال: mycompany أو https://dev.azure.com/mycompany';

  @override
  String get organizationRequired => 'أدخل مؤسستك';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'يوجد رمز محفوظ بالفعل. أدخله مرة أخرى لتغييره.';

  @override
  String get tokenScopeHint =>
      'النطاق المطلوب: Work Items (Read) و Project and Team (Read)';

  @override
  String get tokenRequired => 'أدخل الرمز';

  @override
  String get tokenHelpTitle => 'كيف أنشئ رمزًا؟';

  @override
  String get tokenHelpStep1 =>
      'في Azure DevOps، افتح User settings ← Personal access tokens واختر New Token.';

  @override
  String get tokenHelpStep2 => 'اختر مؤسستك وتاريخ انتهاء الصلاحية.';

  @override
  String get tokenHelpStep3 =>
      'ضمن Scopes، اختر Custom defined وفعّل فقط Work Items: Read و Project and Team: Read.';

  @override
  String get tokenHelpStep4 =>
      'اختر Create، وانسخ الرمز والصقه أعلاه. يُعرض مرة واحدة فقط.';

  @override
  String get tokenHelpPermissions =>
      'لا يملك الرمز أبدًا صلاحيات أكثر من حسابك: تحتاج على الأقل إلى وصول Stakeholder وصلاحية قراءة المشاريع التي تريد عرضها.';

  @override
  String get tokenHelpDocs => 'وثائق Microsoft';

  @override
  String get connecting => 'جارٍ الاتصال…';

  @override
  String get connect => 'اتصال';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeDark => 'داكن';

  @override
  String get colorAzureBlue => 'أزرق Azure';

  @override
  String get colorSystem => 'لون النظام';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'لغة النظام';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get about => 'حول';

  @override
  String appVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String madeBy(String name) {
    return 'من إنشاء $name';
  }

  @override
  String get sendErrorReports => 'إرسال تقارير الأخطاء';

  @override
  String get sendErrorReportsHint =>
      'يرسل تفاصيل مجهولة الهوية عن الأعطال والأخطاء لإصلاحها. لا يتم إرسال رمزك أبدًا.';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get selectTicketTitle => 'اختر تذكرة';

  @override
  String get selectTicketMessage => 'اختر تذكرة من القائمة لعرض تفاصيلها.';

  @override
  String get chooseProject => 'اختر مشروعًا';

  @override
  String get refresh => 'تحديث';

  @override
  String get searchTicketsHint => 'ابحث بالعنوان أو المعرّف أو الوسم أو الشخص';

  @override
  String get scopeAssignedToMe => 'المسندة إليّ';

  @override
  String get scopeCreatedByMe => 'التي أنشأتها';

  @override
  String get scopeAll => 'الكل';

  @override
  String get openOnly => 'المفتوحة فقط';

  @override
  String get loadTicketsFailed => 'تعذّر تحميل التذاكر';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noProjectTitle => 'لم يتم اختيار مشروع';

  @override
  String get noProjectMessage => 'اختر مشروعًا لعرض التذاكر.';

  @override
  String get noTicketsTitle => 'لا توجد تذاكر';

  @override
  String get noTicketsMessage => 'لا توجد تذاكر تطابق عوامل التصفية.';

  @override
  String ticketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تذكرة',
      many: '$count تذكرة',
      few: '$count تذاكر',
      two: 'تذكرتان',
      one: 'تذكرة واحدة',
      zero: 'لا توجد تذاكر',
    );
    return '$_temp0';
  }

  @override
  String get unassigned => 'غير مسندة';

  @override
  String get chooseAProject => 'اختر مشروعًا';

  @override
  String get searchProjectHint => 'ابحث عن مشروع';

  @override
  String get loadProjectsFailed => 'تعذّر تحميل المشاريع';

  @override
  String get browserOpenFailed => 'تعذّر فتح المتصفح';

  @override
  String get openInDevOps => 'فتح في DevOps';

  @override
  String get description => 'الوصف';

  @override
  String get reproSteps => 'خطوات إعادة الإنتاج';

  @override
  String get acceptanceCriteria => 'معايير القبول';

  @override
  String get symptom => 'العَرَض';

  @override
  String get systemInfo => 'معلومات النظام';

  @override
  String get proposedFix => 'الإصلاح';

  @override
  String get emptyField => 'لا يوجد محتوى';

  @override
  String get assignedTo => 'مسندة إلى';

  @override
  String get priority => 'الأولوية';

  @override
  String get effort => 'الجهد';

  @override
  String get originalEstimate => 'التقدير الأصلي';

  @override
  String get remainingWork => 'العمل المتبقي';

  @override
  String get completedWork => 'العمل المنجز';

  @override
  String hours(String value) {
    return '$value س';
  }

  @override
  String get area => 'المنطقة';

  @override
  String get iteration => 'التكرار';

  @override
  String get created => 'تاريخ الإنشاء';

  @override
  String createdOnBy(String date, String name) {
    return '$date بواسطة $name';
  }

  @override
  String get changed => 'تاريخ التعديل';

  @override
  String get linkedItems => 'العناصر المرتبطة';

  @override
  String get parent => 'الأصل';

  @override
  String get child => 'فرعي';

  @override
  String commentsCount(int count) {
    return 'التعليقات ($count)';
  }

  @override
  String get noComments => 'لا توجد تعليقات بعد.';

  @override
  String get unknownPerson => 'غير معروف';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int count) {
    return 'منذ $count د';
  }

  @override
  String hoursAgo(int count) {
    return 'منذ $count س';
  }

  @override
  String daysAgo(int count) {
    return 'منذ $count ي';
  }

  @override
  String get errorUnauthorized => 'غير مصرّح. تحقّق من Personal Access Token.';

  @override
  String get errorNotFound => 'غير موجود. تحقّق من المؤسسة أو المشروع.';

  @override
  String errorHttp(int code) {
    return 'خطأ $code من Azure DevOps';
  }

  @override
  String get errorUnexpectedResponse =>
      'استجابة غير متوقعة. تحقّق من المؤسسة والرمز.';

  @override
  String get widgetSetupRequired => 'افتح التطبيق للإعداد';
}
