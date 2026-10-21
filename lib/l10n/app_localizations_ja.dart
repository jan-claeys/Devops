// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get welcome => 'ようこそ';

  @override
  String get settings => '設定';

  @override
  String get connectionSaved => '接続を保存しました';

  @override
  String get onboardingIntro => 'Azure DevOps に接続してチケットを表示します。';

  @override
  String get connection => '接続';

  @override
  String get organization => '組織';

  @override
  String get organizationHint =>
      '例: mycompany または https://dev.azure.com/mycompany';

  @override
  String get organizationRequired => '組織を入力してください';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored => 'トークンは保存済みです。変更するには再入力してください。';

  @override
  String get tokenScopeHint =>
      '必要なスコープ: Work Items (Read) と Project and Team (Read)';

  @override
  String get tokenRequired => 'トークンを入力してください';

  @override
  String get connecting => '接続中…';

  @override
  String get connect => '接続';

  @override
  String get appearance => '表示';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeDark => 'ダーク';

  @override
  String get colorAzureBlue => 'Azure ブルー';

  @override
  String get colorSystem => 'システムカラー';

  @override
  String get language => '言語';

  @override
  String get languageSystem => 'システムの言語';

  @override
  String get privacy => 'プライバシー';

  @override
  String get sendErrorReports => 'エラーレポートを送信';

  @override
  String get sendErrorReportsHint =>
      '不具合を修正するため、クラッシュとエラーの匿名の詳細を送信します。トークンが送信されることはありません。';

  @override
  String get signOut => 'サインアウト';

  @override
  String get selectTicketTitle => 'チケットを選択';

  @override
  String get selectTicketMessage => '左側のチケットを選ぶと詳細が表示されます。';

  @override
  String get chooseProject => 'プロジェクトを選択';

  @override
  String get refresh => '更新';

  @override
  String get searchTicketsHint => 'タイトル、ID、タグ、担当者で検索';

  @override
  String get scopeAssignedToMe => '自分に割り当て';

  @override
  String get scopeCreatedByMe => '自分が作成';

  @override
  String get scopeAll => 'すべて';

  @override
  String get openOnly => '未完了のみ';

  @override
  String get loadTicketsFailed => 'チケットを読み込めませんでした';

  @override
  String get retry => '再試行';

  @override
  String get noProjectTitle => 'プロジェクトが選択されていません';

  @override
  String get noProjectMessage => 'プロジェクトを選択してチケットを表示します。';

  @override
  String get noTicketsTitle => 'チケットはありません';

  @override
  String get noTicketsMessage => 'フィルターに一致するチケットはありません。';

  @override
  String ticketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のチケット',
    );
    return '$_temp0';
  }

  @override
  String get unassigned => '未割り当て';

  @override
  String get chooseAProject => 'プロジェクトを選択';

  @override
  String get searchProjectHint => 'プロジェクトを検索';

  @override
  String get loadProjectsFailed => 'プロジェクトを読み込めませんでした';

  @override
  String get browserOpenFailed => 'ブラウザーを開けませんでした';

  @override
  String get openInDevOps => 'DevOps で開く';

  @override
  String get description => '説明';

  @override
  String get reproSteps => '再現手順';

  @override
  String get acceptanceCriteria => '受け入れ基準';

  @override
  String get assignedTo => '担当者';

  @override
  String get priority => '優先度';

  @override
  String get effort => '工数';

  @override
  String get originalEstimate => '当初の見積もり';

  @override
  String get remainingWork => '残作業';

  @override
  String get completedWork => '完了した作業';

  @override
  String hours(String value) {
    return '$value 時間';
  }

  @override
  String get area => 'エリア';

  @override
  String get iteration => 'イテレーション';

  @override
  String get created => '作成日';

  @override
  String createdOnBy(String date, String name) {
    return '$date（$name）';
  }

  @override
  String get changed => '更新日';

  @override
  String get linkedItems => 'リンクされた項目';

  @override
  String get parent => '親';

  @override
  String get child => '子';

  @override
  String commentsCount(int count) {
    return 'コメント（$count）';
  }

  @override
  String get noComments => 'コメントはまだありません。';

  @override
  String get unknownPerson => '不明';

  @override
  String get justNow => 'たった今';

  @override
  String minutesAgo(int count) {
    return '$count 分前';
  }

  @override
  String hoursAgo(int count) {
    return '$count 時間前';
  }

  @override
  String daysAgo(int count) {
    return '$count 日前';
  }

  @override
  String get errorUnauthorized => '認証されていません。Personal Access Token を確認してください。';

  @override
  String get errorNotFound => '見つかりません。組織またはプロジェクトを確認してください。';

  @override
  String errorHttp(int code) {
    return 'Azure DevOps からのエラー $code';
  }

  @override
  String get errorUnexpectedResponse => '予期しない応答です。組織とトークンを確認してください。';

  @override
  String get widgetSetupRequired => 'アプリを開いて設定してください';
}
