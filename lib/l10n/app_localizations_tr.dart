// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get welcome => 'Hoş geldiniz';

  @override
  String get settings => 'Ayarlar';

  @override
  String get connectionSaved => 'Bağlantı kaydedildi';

  @override
  String get onboardingIntro => 'Başlamak için Azure DevOps\'a bağlanın.';

  @override
  String get connection => 'Bağlantı';

  @override
  String get organization => 'Kuruluş';

  @override
  String get organizationHint =>
      'örn. sirketim veya https://dev.azure.com/sirketim';

  @override
  String get organizationRequired => 'Kuruluşunuzu girin';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'Zaten kayıtlı bir belirteç var. Değiştirmek için yeniden girin.';

  @override
  String get requiredScopes => 'Gerekli kapsamlar';

  @override
  String get tokenRequired => 'Belirtecinizi girin';

  @override
  String get tokenHelpTitle => 'Nasıl token oluştururum?';

  @override
  String get tokenHelpStep1 =>
      'Azure DevOps\'ta User settings → Personal access tokens\'ı açın ve New Token\'ı seçin.';

  @override
  String get tokenHelpStep2 => 'Kuruluşunuzu ve bir son kullanma tarihi seçin.';

  @override
  String get tokenHelpStep3 =>
      'Scopes altında Custom defined\'ı seçin ve yalnızca yukarıda listelenen kapsamları Read olarak etkinleştirin.';

  @override
  String get tokenHelpStep4 =>
      'Create\'i seçin, token\'ı kopyalayın ve yukarıya yapıştırın. Yalnızca bir kez gösterilir.';

  @override
  String get tokenHelpPermissions =>
      'Bir token hiçbir zaman hesabınızdan fazla yetkiye sahip olmaz: en az Stakeholder erişimine ve görmek istediğiniz projelerde okuma iznine ihtiyacınız var.';

  @override
  String get tokenHelpDocs => 'Microsoft belgeleri';

  @override
  String get connecting => 'Bağlanıyor…';

  @override
  String get connect => 'Bağlan';

  @override
  String get appearance => 'Görünüm';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeDark => 'Koyu';

  @override
  String get colorAzureBlue => 'Azure mavisi';

  @override
  String get colorSystem => 'Sistem rengi';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Sistem dili';

  @override
  String get privacy => 'Gizlilik';

  @override
  String get about => 'Hakkında';

  @override
  String appVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String madeBy(String name) {
    return '$name tarafından yapıldı';
  }

  @override
  String get sendErrorReports => 'Hata raporları gönder';

  @override
  String get sendErrorReportsHint =>
      'Hataların düzeltilebilmesi için çökme ve hata ayrıntılarını anonim olarak gönderir. Belirteciniz asla gönderilmez.';

  @override
  String get signOut => 'Oturumu kapat';

  @override
  String get selectTicketTitle => 'Bir bilet seçin';

  @override
  String get selectTicketMessage =>
      'Ayrıntıları görmek için soldan bir bilet seçin.';

  @override
  String get chooseProjects => 'Projeleri seç';

  @override
  String get refresh => 'Yenile';

  @override
  String get searchTicketsHint => 'Başlık, ID, etiket veya kişiye göre ara';

  @override
  String get scopeAssignedToMe => 'Bana atanan';

  @override
  String get scopeCreatedByMe => 'Oluşturduğum';

  @override
  String get scopeAll => 'Tümü';

  @override
  String get openOnly => 'Yalnızca açık';

  @override
  String get loadTicketsFailed => 'Biletler yüklenemedi';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get noProjectsTitle => 'Proje seçilmedi';

  @override
  String get noProjectsMessage =>
      'Biletleri görmek için bir veya daha fazla proje seçin.';

  @override
  String get noTicketsTitle => 'Bilet yok';

  @override
  String get noTicketsMessage => 'Filtrelere uyan bilet yok.';

  @override
  String ticketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bilet',
    );
    return '$_temp0';
  }

  @override
  String get unassigned => 'Atanmamış';

  @override
  String get projects => 'Projeler';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count proje',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Uygula';

  @override
  String get searchProjectHint => 'Proje ara';

  @override
  String get loadProjectsFailed => 'Projeler yüklenemedi';

  @override
  String get browserOpenFailed => 'Tarayıcı açılamadı';

  @override
  String get openInDevOps => 'DevOps\'ta aç';

  @override
  String get description => 'Açıklama';

  @override
  String get reproSteps => 'Yeniden oluşturma adımları';

  @override
  String get acceptanceCriteria => 'Kabul kriterleri';

  @override
  String get symptom => 'Belirti';

  @override
  String get systemInfo => 'Sistem bilgisi';

  @override
  String get proposedFix => 'Düzeltme';

  @override
  String get emptyField => 'İçerik yok';

  @override
  String get assignedTo => 'Atanan';

  @override
  String get priority => 'Öncelik';

  @override
  String get effort => 'Efor';

  @override
  String get originalEstimate => 'İlk tahmin';

  @override
  String get remainingWork => 'Kalan iş';

  @override
  String get completedWork => 'Tamamlanan iş';

  @override
  String hours(String value) {
    return '$value sa';
  }

  @override
  String get area => 'Alan';

  @override
  String get iteration => 'Yineleme';

  @override
  String get created => 'Oluşturuldu';

  @override
  String createdOnBy(String date, String name) {
    return '$date, $name';
  }

  @override
  String get changed => 'Değiştirildi';

  @override
  String get linkedItems => 'Bağlantılı öğeler';

  @override
  String get parent => 'Üst';

  @override
  String get child => 'Alt';

  @override
  String commentsCount(int count) {
    return 'Yorumlar ($count)';
  }

  @override
  String get noComments => 'Henüz yorum yok.';

  @override
  String get unknownPerson => 'Bilinmiyor';

  @override
  String get justNow => 'az önce';

  @override
  String minutesAgo(int count) {
    return '$count dk önce';
  }

  @override
  String hoursAgo(int count) {
    return '$count sa önce';
  }

  @override
  String daysAgo(int count) {
    return '$count g önce';
  }

  @override
  String get errorUnauthorized =>
      'Yetkisiz. Personal Access Token\'ınızı kontrol edin.';

  @override
  String get errorNotFound => 'Bulunamadı. Kuruluşu veya projeyi kontrol edin.';

  @override
  String errorHttp(int code) {
    return 'Azure DevOps\'tan $code hatası';
  }

  @override
  String get errorUnexpectedResponse =>
      'Beklenmeyen yanıt. Kuruluşu ve belirtecinizi kontrol edin.';

  @override
  String get widgetSetupRequired => 'Kurulum için uygulamayı açın';

  @override
  String get tickets => 'Biletler';

  @override
  String get pipelines => 'İşlem hatları';

  @override
  String get searchRunsHint => 'İşlem hattı, dal veya kişiye göre ara';

  @override
  String get activeOnly => 'Yalnızca etkin';

  @override
  String get loadRunsFailed => 'Çalıştırmalar yüklenemedi';

  @override
  String get noRunsTitle => 'İşlem hattı çalıştırması yok';

  @override
  String get noRunsMessage =>
      'Filtrelerle eşleşen işlem hattı çalıştırması yok.';

  @override
  String runCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count çalıştırma',
    );
    return '$_temp0';
  }

  @override
  String get selectRunTitle => 'Bir çalıştırma seçin';

  @override
  String get selectRunMessage =>
      'İlerlemesini izlemek için soldan bir çalıştırma seçin.';

  @override
  String get runPending => 'Bekliyor';

  @override
  String get runQueued => 'Kuyrukta';

  @override
  String get runRunning => 'Çalışıyor';

  @override
  String get runCancelling => 'İptal ediliyor';

  @override
  String get runSucceeded => 'Başarılı';

  @override
  String get runPartiallySucceeded => 'Kısmen başarılı';

  @override
  String get runFailed => 'Başarısız';

  @override
  String get runCanceled => 'İptal edildi';

  @override
  String get runSkipped => 'Atlandı';

  @override
  String get progress => 'İlerleme';

  @override
  String tasksProgress(int done, int total) {
    return '$total görevden $done tamamlandı';
  }

  @override
  String get branch => 'Dal';

  @override
  String get requestedBy => 'İsteyen';

  @override
  String get queued => 'Kuyruğa alındı';

  @override
  String get started => 'Başladı';

  @override
  String get finished => 'Bitti';

  @override
  String get duration => 'Süre';

  @override
  String get stages => 'Aşamalar';

  @override
  String get noStagesYet => 'Aşamalar çalıştırma başladığında görünür.';

  @override
  String get runWaitingForApproval => 'Onay bekliyor';

  @override
  String get runNotDeployed => 'Dağıtılmadı';

  @override
  String get builds => 'Derlemeler';

  @override
  String get releases => 'Sürümler';

  @override
  String get loadReleasesFailed => 'Sürümler yüklenemedi';

  @override
  String get releaseScopeHint =>
      'Sürümler için belirtecinizde Release (Read) kapsamı gerekir.';

  @override
  String get artifact => 'Yapıt';

  @override
  String waitingForApprovalBy(String names) {
    return '$names onayı bekleniyor';
  }

  @override
  String get pullRequests => 'Çekme istekleri';

  @override
  String get searchPullRequestsHint =>
      'Başlık, kimlik, dal veya kişiye göre ara';

  @override
  String get scopeReviewing => 'İncelenecek';

  @override
  String get loadPullRequestsFailed => 'Çekme istekleri yüklenemedi';

  @override
  String get codeScopeHint =>
      'Çekme istekleri için belirtecinizde Code (Read) kapsamı gerekir.';

  @override
  String get noPullRequestsTitle => 'Çekme isteği yok';

  @override
  String get noPullRequestsMessage => 'Filtrelerle eşleşen çekme isteği yok.';

  @override
  String pullRequestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count çekme isteği',
    );
    return '$_temp0';
  }

  @override
  String get selectPullRequestTitle => 'Bir çekme isteği seçin';

  @override
  String get selectPullRequestMessage =>
      'Ayrıntılarını görmek için soldan bir çekme isteği seçin.';

  @override
  String get prDraft => 'Taslak';

  @override
  String get prActive => 'Etkin';

  @override
  String get prCompleted => 'Tamamlandı';

  @override
  String get prAbandoned => 'Bırakıldı';

  @override
  String get mergeConflicts => 'Birleştirme çakışmaları';

  @override
  String get repository => 'Depo';

  @override
  String get closed => 'Kapatıldı';

  @override
  String get reviewers => 'Gözden geçirenler';

  @override
  String get noReviewers => 'Gözden geçiren yok';

  @override
  String get requiredReviewer => 'Zorunlu';

  @override
  String get voteApproved => 'Onaylandı';

  @override
  String get voteApprovedWithSuggestions => 'Önerilerle onaylandı';

  @override
  String get voteNone => 'Oy yok';

  @override
  String get voteWaitingForAuthor => 'Yazar bekleniyor';

  @override
  String get voteRejected => 'Reddedildi';

  @override
  String get threadResolved => 'Çözüldü';
}
