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
  String get onboardingIntro => 'اتصل بـ Azure DevOps للبدء.';

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
  String get requiredScopes => 'النطاقات المطلوبة';

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
      'ضمن Scopes، اختر Custom defined وفعّل فقط النطاقات المذكورة أعلاه، كلٌّ منها بصلاحية Read.';

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
  String get chooseProjects => 'اختر المشاريع';

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
  String get noProjectsTitle => 'لم يتم اختيار مشاريع';

  @override
  String get noProjectsMessage => 'اختر مشروعًا واحدًا أو أكثر لعرض التذاكر.';

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
  String get projects => 'المشاريع';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مشروع',
      many: '$count مشروعًا',
      few: '$count مشاريع',
      two: 'مشروعان',
      one: 'مشروع واحد',
      zero: 'لا توجد مشاريع',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'تطبيق';

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

  @override
  String get tickets => 'التذاكر';

  @override
  String get pipelines => 'المسارات';

  @override
  String get searchRunsHint => 'ابحث حسب البنية أو الفرع أو الشخص';

  @override
  String get activeOnly => 'النشطة فقط';

  @override
  String get loadRunsFailed => 'تعذّر تحميل عمليات التشغيل';

  @override
  String get noRunsTitle => 'لا توجد عمليات تشغيل';

  @override
  String get noRunsMessage => 'لا توجد عمليات تشغيل تطابق عوامل التصفية.';

  @override
  String runCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عملية تشغيل',
      many: '$count عملية تشغيل',
      few: '$count عمليات تشغيل',
      two: 'عمليتا تشغيل',
      one: 'عملية تشغيل واحدة',
      zero: 'لا توجد عمليات تشغيل',
    );
    return '$_temp0';
  }

  @override
  String get selectRunTitle => 'اختر عملية تشغيل';

  @override
  String get selectRunMessage => 'اختر عملية تشغيل على اليسار لمتابعة تقدّمها.';

  @override
  String get runPending => 'في الانتظار';

  @override
  String get runQueued => 'في قائمة الانتظار';

  @override
  String get runRunning => 'قيد التشغيل';

  @override
  String get runCancelling => 'جارٍ الإلغاء';

  @override
  String get runSucceeded => 'نجحت';

  @override
  String get runPartiallySucceeded => 'نجحت جزئيًا';

  @override
  String get runFailed => 'فشلت';

  @override
  String get runCanceled => 'أُلغيت';

  @override
  String get runSkipped => 'تم تخطيها';

  @override
  String get progress => 'التقدّم';

  @override
  String tasksProgress(int done, int total) {
    return 'اكتملت $done من $total مهام';
  }

  @override
  String get branch => 'الفرع';

  @override
  String get requestedBy => 'طلبها';

  @override
  String get queued => 'أُضيفت إلى قائمة الانتظار';

  @override
  String get started => 'بدأت';

  @override
  String get finished => 'انتهت';

  @override
  String get duration => 'المدة';

  @override
  String get stages => 'المراحل';

  @override
  String get noStagesYet => 'تظهر المراحل عند بدء التشغيل.';

  @override
  String get runWaitingForApproval => 'بانتظار الموافقة';

  @override
  String get runNotDeployed => 'لم يُنشر';

  @override
  String get builds => 'عمليات البناء';

  @override
  String get releases => 'الإصدارات';

  @override
  String get loadReleasesFailed => 'تعذّر تحميل الإصدارات';

  @override
  String get releaseScopeHint =>
      'تحتاج الإصدارات إلى النطاق Release (Read) في الرمز المميز.';

  @override
  String get artifact => 'العنصر';

  @override
  String waitingForApprovalBy(String names) {
    return 'بانتظار موافقة $names';
  }

  @override
  String get pullRequests => 'طلبات السحب';

  @override
  String get searchPullRequestsHint =>
      'ابحث حسب العنوان أو المعرّف أو الفرع أو الشخص';

  @override
  String get scopeReviewing => 'للمراجعة';

  @override
  String get loadPullRequestsFailed => 'تعذّر تحميل طلبات السحب';

  @override
  String get codeScopeHint =>
      'تحتاج طلبات السحب إلى النطاق Code (Read) في الرمز المميز.';

  @override
  String get noPullRequestsTitle => 'لا توجد طلبات سحب';

  @override
  String get noPullRequestsMessage => 'لا توجد طلبات سحب تطابق عوامل التصفية.';

  @override
  String pullRequestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب سحب',
      many: '$count طلب سحب',
      few: '$count طلبات سحب',
      two: 'طلبا سحب',
      one: 'طلب سحب واحد',
      zero: 'لا توجد طلبات سحب',
    );
    return '$_temp0';
  }

  @override
  String get selectPullRequestTitle => 'اختر طلب سحب';

  @override
  String get selectPullRequestMessage =>
      'اختر طلب سحب على اليسار لعرض تفاصيله.';

  @override
  String get prDraft => 'مسودة';

  @override
  String get prActive => 'نشط';

  @override
  String get prCompleted => 'مكتمل';

  @override
  String get prAbandoned => 'متروك';

  @override
  String get mergeConflicts => 'تعارضات الدمج';

  @override
  String get repository => 'المستودع';

  @override
  String get closed => 'مغلق';

  @override
  String get reviewers => 'المراجعون';

  @override
  String get noReviewers => 'لا يوجد مراجعون';

  @override
  String get requiredReviewer => 'مطلوب';

  @override
  String get voteApproved => 'تمت الموافقة';

  @override
  String get voteApprovedWithSuggestions => 'تمت الموافقة مع اقتراحات';

  @override
  String get voteNone => 'لا يوجد تصويت';

  @override
  String get voteWaitingForAuthor => 'بانتظار المؤلف';

  @override
  String get voteRejected => 'مرفوض';

  @override
  String get threadResolved => 'تم الحل';

  @override
  String get runErrors => 'الأخطاء';

  @override
  String get viewLog => 'عرض السجل';

  @override
  String showAll(int count) {
    return 'عرض الكل ($count)';
  }

  @override
  String get copyLog => 'نسخ السجل';

  @override
  String get logCopied => 'تم نسخ السجل';

  @override
  String get logEmpty => 'هذا السجل فارغ.';

  @override
  String get showMore => 'عرض المزيد';

  @override
  String get showLess => 'عرض أقل';

  @override
  String get onlyErrorsAndWarnings => 'الأخطاء والتحذيرات فقط';

  @override
  String get noLogIssues => 'لا توجد أخطاء أو تحذيرات في هذا السجل.';

  @override
  String get previousError => 'الخطأ السابق';

  @override
  String get nextError => 'الخطأ التالي';

  @override
  String errorPosition(int current, int total) {
    return 'الخطأ $current من $total';
  }

  @override
  String errorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أخطاء',
      one: 'خطأ واحد',
    );
    return '$_temp0';
  }
}
