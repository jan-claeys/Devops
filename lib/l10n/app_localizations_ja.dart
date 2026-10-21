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
  String get onboardingIntro => 'Azure DevOps に接続して始めましょう。';

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
  String get requiredScopes => '必要なスコープ';

  @override
  String get tokenRequired => 'トークンを入力してください';

  @override
  String get tokenHelpTitle => 'トークンの作成方法';

  @override
  String get tokenHelpStep1 =>
      'Azure DevOps で User settings → Personal access tokens を開き、New Token を選択します。';

  @override
  String get tokenHelpStep2 => '組織と有効期限を選択します。';

  @override
  String get tokenHelpStep3 =>
      'Scopes で Custom defined を選び、上記のスコープのみをそれぞれ Read で有効にします。';

  @override
  String get tokenHelpStep4 =>
      'Create を選択してトークンをコピーし、上に貼り付けます。トークンは一度だけ表示されます。';

  @override
  String get tokenHelpPermissions =>
      'トークンがアカウント以上の権限を持つことはありません。少なくとも Stakeholder アクセスと、表示したいプロジェクトの読み取り権限が必要です。';

  @override
  String get tokenHelpDocs => 'Microsoft のドキュメント';

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
  String get about => 'このアプリについて';

  @override
  String appVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String madeBy(String name) {
    return '作成者: $name';
  }

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
  String get chooseProjects => 'プロジェクトを選択';

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
  String get noProjectsTitle => 'プロジェクトが選択されていません';

  @override
  String get noProjectsMessage => 'チケットを表示するには、1 つ以上のプロジェクトを選択してください。';

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
  String get projects => 'プロジェクト';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のプロジェクト',
    );
    return '$_temp0';
  }

  @override
  String get apply => '適用';

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
  String get symptom => '症状';

  @override
  String get systemInfo => 'システム情報';

  @override
  String get proposedFix => '修正';

  @override
  String get emptyField => '内容なし';

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

  @override
  String get tickets => 'チケット';

  @override
  String get pipelines => 'パイプライン';

  @override
  String get searchRunsHint => 'パイプライン、ブランチ、ユーザーで検索';

  @override
  String get activeOnly => '実行中のみ';

  @override
  String get loadRunsFailed => 'パイプラインの実行を読み込めませんでした';

  @override
  String get noRunsTitle => 'パイプラインの実行はありません';

  @override
  String get noRunsMessage => 'フィルターに一致するパイプラインの実行はありません。';

  @override
  String runCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件の実行',
    );
    return '$_temp0';
  }

  @override
  String get selectRunTitle => 'パイプラインの実行を選択';

  @override
  String get selectRunMessage => '左側で実行を選ぶと進行状況を確認できます。';

  @override
  String get runPending => '待機中';

  @override
  String get runQueued => 'キュー登録済み';

  @override
  String get runRunning => '実行中';

  @override
  String get runCancelling => 'キャンセル中';

  @override
  String get runSucceeded => '成功';

  @override
  String get runPartiallySucceeded => '一部成功';

  @override
  String get runFailed => '失敗';

  @override
  String get runCanceled => 'キャンセル済み';

  @override
  String get runSkipped => 'スキップ';

  @override
  String get progress => '進行状況';

  @override
  String tasksProgress(int done, int total) {
    return '$total 件中 $done 件のタスクが完了';
  }

  @override
  String get branch => 'ブランチ';

  @override
  String get requestedBy => '要求者';

  @override
  String get queued => 'キュー登録';

  @override
  String get started => '開始';

  @override
  String get finished => '終了';

  @override
  String get duration => '所要時間';

  @override
  String get stages => 'ステージ';

  @override
  String get noStagesYet => '実行が始まるとステージが表示されます。';

  @override
  String get runWaitingForApproval => '承認待ち';

  @override
  String get runNotDeployed => '未デプロイ';

  @override
  String get builds => 'ビルド';

  @override
  String get releases => 'リリース';

  @override
  String get loadReleasesFailed => 'リリースを読み込めませんでした';

  @override
  String get releaseScopeHint => 'リリースにはトークンの Release (Read) スコープが必要です。';

  @override
  String get artifact => '成果物';

  @override
  String waitingForApprovalBy(String names) {
    return '$names の承認待ち';
  }

  @override
  String get pullRequests => 'プル リクエスト';

  @override
  String get searchPullRequestsHint => 'タイトル、ID、ブランチ、ユーザーで検索';

  @override
  String get scopeReviewing => 'レビュー担当';

  @override
  String get loadPullRequestsFailed => 'プル リクエストを読み込めませんでした';

  @override
  String get codeScopeHint => 'プル リクエストにはトークンの Code (Read) スコープが必要です。';

  @override
  String get noPullRequestsTitle => 'プル リクエストはありません';

  @override
  String get noPullRequestsMessage => 'フィルターに一致するプル リクエストはありません。';

  @override
  String pullRequestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のプル リクエスト',
    );
    return '$_temp0';
  }

  @override
  String get selectPullRequestTitle => 'プル リクエストを選択';

  @override
  String get selectPullRequestMessage => '左側でプル リクエストを選ぶと詳細が表示されます。';

  @override
  String get prDraft => '下書き';

  @override
  String get prActive => 'アクティブ';

  @override
  String get prCompleted => '完了';

  @override
  String get prAbandoned => '破棄';

  @override
  String get mergeConflicts => 'マージの競合';

  @override
  String get repository => 'リポジトリ';

  @override
  String get closed => 'クローズ';

  @override
  String get reviewers => 'レビュー担当者';

  @override
  String get noReviewers => 'レビュー担当者はいません';

  @override
  String get requiredReviewer => '必須';

  @override
  String get voteApproved => '承認済み';

  @override
  String get voteApprovedWithSuggestions => '提案付きで承認';

  @override
  String get voteNone => '投票なし';

  @override
  String get voteWaitingForAuthor => '作成者を待機中';

  @override
  String get voteRejected => '却下';

  @override
  String get threadResolved => '解決済み';
}
