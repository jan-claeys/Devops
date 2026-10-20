// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get welcome => 'Selamat datang';

  @override
  String get settings => 'Pengaturan';

  @override
  String get connectionSaved => 'Koneksi disimpan';

  @override
  String get onboardingIntro =>
      'Hubungkan ke Azure DevOps untuk melihat tiket Anda.';

  @override
  String get connection => 'Koneksi';

  @override
  String get organization => 'Organisasi';

  @override
  String get organizationHint =>
      'mis. perusahaanku atau https://dev.azure.com/perusahaanku';

  @override
  String get organizationRequired => 'Masukkan organisasi Anda';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'Token sudah tersimpan. Masukkan lagi untuk mengubahnya.';

  @override
  String get tokenScopeHint =>
      'Cakupan yang diperlukan: Work Items (Read) dan Project and Team (Read)';

  @override
  String get tokenRequired => 'Masukkan token Anda';

  @override
  String get connecting => 'Menghubungkan…';

  @override
  String get connect => 'Hubungkan';

  @override
  String get appearance => 'Tampilan';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeDark => 'Gelap';

  @override
  String get colorAzureBlue => 'Biru Azure';

  @override
  String get colorSystem => 'Warna sistem';

  @override
  String get language => 'Bahasa';

  @override
  String get languageSystem => 'Bahasa sistem';

  @override
  String get signOut => 'Keluar';

  @override
  String get selectTicketTitle => 'Pilih tiket';

  @override
  String get selectTicketMessage =>
      'Pilih tiket di sebelah kiri untuk melihat detailnya.';

  @override
  String get chooseProject => 'Pilih proyek';

  @override
  String get refresh => 'Muat ulang';

  @override
  String get searchTicketsHint => 'Cari berdasarkan judul, ID, tag, atau orang';

  @override
  String get scopeAssignedToMe => 'Untuk saya';

  @override
  String get scopeCreatedByMe => 'Oleh saya';

  @override
  String get scopeAll => 'Semua';

  @override
  String get openOnly => 'Hanya yang terbuka';

  @override
  String get loadTicketsFailed => 'Tidak dapat memuat tiket';

  @override
  String get retry => 'Coba lagi';

  @override
  String get noProjectTitle => 'Tidak ada proyek dipilih';

  @override
  String get noProjectMessage => 'Pilih proyek untuk melihat tiket.';

  @override
  String get noTicketsTitle => 'Tidak ada tiket';

  @override
  String get noTicketsMessage => 'Tidak ada tiket yang cocok dengan filter.';

  @override
  String ticketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tiket',
    );
    return '$_temp0';
  }

  @override
  String get unassigned => 'Belum ditugaskan';

  @override
  String get chooseAProject => 'Pilih proyek';

  @override
  String get searchProjectHint => 'Cari proyek';

  @override
  String get loadProjectsFailed => 'Tidak dapat memuat proyek';

  @override
  String get browserOpenFailed => 'Tidak dapat membuka browser';

  @override
  String get openInDevOps => 'Buka di DevOps';

  @override
  String get description => 'Deskripsi';

  @override
  String get reproSteps => 'Langkah reproduksi';

  @override
  String get acceptanceCriteria => 'Kriteria penerimaan';

  @override
  String get assignedTo => 'Ditugaskan ke';

  @override
  String get priority => 'Prioritas';

  @override
  String get effort => 'Usaha';

  @override
  String get originalEstimate => 'Estimasi awal';

  @override
  String get remainingWork => 'Sisa pekerjaan';

  @override
  String get completedWork => 'Pekerjaan selesai';

  @override
  String hours(String value) {
    return '$value jam';
  }

  @override
  String get area => 'Area';

  @override
  String get iteration => 'Iterasi';

  @override
  String get created => 'Dibuat';

  @override
  String createdOnBy(String date, String name) {
    return '$date oleh $name';
  }

  @override
  String get changed => 'Diubah';

  @override
  String get linkedItems => 'Item tertaut';

  @override
  String get parent => 'Induk';

  @override
  String get child => 'Anak';

  @override
  String commentsCount(int count) {
    return 'Komentar ($count)';
  }

  @override
  String get noComments => 'Belum ada komentar.';

  @override
  String get unknownPerson => 'Tidak dikenal';

  @override
  String get justNow => 'baru saja';

  @override
  String minutesAgo(int count) {
    return '$count mnt lalu';
  }

  @override
  String hoursAgo(int count) {
    return '$count jam lalu';
  }

  @override
  String daysAgo(int count) {
    return '$count hr lalu';
  }

  @override
  String get errorUnauthorized =>
      'Tidak diizinkan. Periksa Personal Access Token Anda.';

  @override
  String get errorNotFound =>
      'Tidak ditemukan. Periksa organisasi atau proyek.';

  @override
  String errorHttp(int code) {
    return 'Kesalahan $code dari Azure DevOps';
  }

  @override
  String get errorUnexpectedResponse =>
      'Respons tidak terduga. Periksa organisasi dan token Anda.';

  @override
  String get widgetSetupRequired => 'Buka aplikasi untuk menyiapkan';
}
