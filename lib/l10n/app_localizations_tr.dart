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
  String get onboardingIntro =>
      'Biletlerinizi görmek için Azure DevOps\'a bağlanın.';

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
  String get tokenScopeHint =>
      'Gerekli kapsam: Work Items (Read) ve Project and Team (Read)';

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
      'Scopes altında Custom defined\'ı seçin ve yalnızca Work Items: Read ile Project and Team: Read\'i etkinleştirin.';

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
}
