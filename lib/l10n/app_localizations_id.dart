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
  String get onboardingIntro => 'Hubungkan ke Azure DevOps untuk memulai.';

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
  String get requiredScopes => 'Cakupan yang diperlukan';

  @override
  String get tokenRequired => 'Masukkan token Anda';

  @override
  String get tokenHelpTitle => 'Bagaimana cara membuat token?';

  @override
  String get tokenHelpStep1 =>
      'Di Azure DevOps, buka User settings → Personal access tokens lalu pilih New Token.';

  @override
  String get tokenHelpStep2 => 'Pilih organisasi Anda dan tanggal kedaluwarsa.';

  @override
  String get tokenHelpStep3 =>
      'Di Scopes, pilih Custom defined dan aktifkan hanya cakupan yang tercantum di atas, masing-masing dengan Read.';

  @override
  String get tokenHelpStep4 =>
      'Pilih Create, salin token, lalu tempel di atas. Token hanya ditampilkan sekali.';

  @override
  String get tokenHelpPermissions =>
      'Token tidak pernah memiliki hak lebih dari akun Anda: Anda memerlukan setidaknya akses Stakeholder dan izin baca pada proyek yang ingin dilihat.';

  @override
  String get tokenHelpDocs => 'Dokumentasi Microsoft';

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
  String get privacy => 'Privasi';

  @override
  String get about => 'Tentang';

  @override
  String appVersion(String version) {
    return 'Versi $version';
  }

  @override
  String madeBy(String name) {
    return 'Dibuat oleh $name';
  }

  @override
  String get sendErrorReports => 'Kirim laporan kesalahan';

  @override
  String get sendErrorReportsHint =>
      'Mengirim detail anonim tentang crash dan kesalahan agar bug dapat diperbaiki. Token Anda tidak pernah dikirim.';

  @override
  String get signOut => 'Keluar';

  @override
  String get selectTicketTitle => 'Pilih tiket';

  @override
  String get selectTicketMessage =>
      'Pilih tiket di sebelah kiri untuk melihat detailnya.';

  @override
  String get chooseProjects => 'Pilih proyek';

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
  String get noProjectsTitle => 'Tidak ada proyek dipilih';

  @override
  String get noProjectsMessage =>
      'Pilih satu atau beberapa proyek untuk melihat tiket.';

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
  String get projects => 'Proyek';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count proyek',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Terapkan';

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
  String get symptom => 'Gejala';

  @override
  String get systemInfo => 'Info sistem';

  @override
  String get proposedFix => 'Perbaikan';

  @override
  String get emptyField => 'Tidak ada konten';

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

  @override
  String get tickets => 'Tiket';

  @override
  String get pipelines => 'Pipeline';

  @override
  String get searchRunsHint => 'Cari menurut pipeline, branch, atau orang';

  @override
  String get activeOnly => 'Hanya yang aktif';

  @override
  String get loadRunsFailed => 'Tidak dapat memuat run pipeline';

  @override
  String get noRunsTitle => 'Tidak ada run pipeline';

  @override
  String get noRunsMessage =>
      'Tidak ada run pipeline yang cocok dengan filter.';

  @override
  String runCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count run',
    );
    return '$_temp0';
  }

  @override
  String get selectRunTitle => 'Pilih run pipeline';

  @override
  String get selectRunMessage =>
      'Pilih run di sebelah kiri untuk mengikuti progresnya.';

  @override
  String get runPending => 'Menunggu';

  @override
  String get runQueued => 'Dalam antrean';

  @override
  String get runRunning => 'Berjalan';

  @override
  String get runCancelling => 'Membatalkan';

  @override
  String get runSucceeded => 'Berhasil';

  @override
  String get runPartiallySucceeded => 'Berhasil sebagian';

  @override
  String get runFailed => 'Gagal';

  @override
  String get runCanceled => 'Dibatalkan';

  @override
  String get runSkipped => 'Dilewati';

  @override
  String get progress => 'Progres';

  @override
  String tasksProgress(int done, int total) {
    return '$done dari $total tugas selesai';
  }

  @override
  String get branch => 'Branch';

  @override
  String get requestedBy => 'Diminta oleh';

  @override
  String get queued => 'Masuk antrean';

  @override
  String get started => 'Dimulai';

  @override
  String get finished => 'Selesai';

  @override
  String get duration => 'Durasi';

  @override
  String get stages => 'Tahap';

  @override
  String get noStagesYet => 'Tahap muncul setelah run dimulai.';

  @override
  String get runWaitingForApproval => 'Menunggu persetujuan';

  @override
  String get runNotDeployed => 'Belum di-deploy';

  @override
  String get builds => 'Build';

  @override
  String get releases => 'Rilis';

  @override
  String get loadReleasesFailed => 'Tidak dapat memuat rilis';

  @override
  String get releaseScopeHint =>
      'Rilis memerlukan cakupan Release (Read) pada token Anda.';

  @override
  String get artifact => 'Artefak';

  @override
  String waitingForApprovalBy(String names) {
    return 'Menunggu persetujuan dari $names';
  }

  @override
  String get pullRequests => 'Pull request';

  @override
  String get searchPullRequestsHint =>
      'Cari menurut judul, ID, branch, atau orang';

  @override
  String get scopeReviewing => 'Untuk ditinjau';

  @override
  String get loadPullRequestsFailed => 'Tidak dapat memuat pull request';

  @override
  String get codeScopeHint =>
      'Pull request memerlukan cakupan Code (Read) pada token Anda.';

  @override
  String get noPullRequestsTitle => 'Tidak ada pull request';

  @override
  String get noPullRequestsMessage =>
      'Tidak ada pull request yang cocok dengan filter.';

  @override
  String pullRequestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pull request',
    );
    return '$_temp0';
  }

  @override
  String get selectPullRequestTitle => 'Pilih pull request';

  @override
  String get selectPullRequestMessage =>
      'Pilih pull request di sebelah kiri untuk melihat detailnya.';

  @override
  String get prDraft => 'Draf';

  @override
  String get prActive => 'Aktif';

  @override
  String get prCompleted => 'Selesai';

  @override
  String get prAbandoned => 'Ditinggalkan';

  @override
  String get mergeConflicts => 'Konflik merge';

  @override
  String get repository => 'Repositori';

  @override
  String get closed => 'Ditutup';

  @override
  String get reviewers => 'Peninjau';

  @override
  String get noReviewers => 'Tidak ada peninjau';

  @override
  String get requiredReviewer => 'Wajib';

  @override
  String get voteApproved => 'Disetujui';

  @override
  String get voteApprovedWithSuggestions => 'Disetujui dengan saran';

  @override
  String get voteNone => 'Belum memilih';

  @override
  String get voteWaitingForAuthor => 'Menunggu penulis';

  @override
  String get voteRejected => 'Ditolak';

  @override
  String get threadResolved => 'Terselesaikan';

  @override
  String get runErrors => 'Kesalahan';

  @override
  String get viewLog => 'Lihat log';

  @override
  String showAll(int count) {
    return 'Tampilkan semua ($count)';
  }

  @override
  String get copyLog => 'Salin log';

  @override
  String get logCopied => 'Log disalin';

  @override
  String get logEmpty => 'Log ini kosong.';

  @override
  String get showMore => 'Tampilkan lebih banyak';

  @override
  String get showLess => 'Tampilkan lebih sedikit';

  @override
  String get onlyErrorsAndWarnings => 'Hanya kesalahan dan peringatan';

  @override
  String get noLogIssues => 'Tidak ada kesalahan atau peringatan di log ini.';

  @override
  String get previousError => 'Kesalahan sebelumnya';

  @override
  String get nextError => 'Kesalahan berikutnya';

  @override
  String errorPosition(int current, int total) {
    return 'Kesalahan $current dari $total';
  }

  @override
  String errorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kesalahan',
    );
    return '$_temp0';
  }
}
