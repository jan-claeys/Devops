// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get welcome => '欢迎';

  @override
  String get settings => '设置';

  @override
  String get connectionSaved => '连接已保存';

  @override
  String get onboardingIntro => '连接到 Azure DevOps 以开始使用。';

  @override
  String get connection => '连接';

  @override
  String get organization => '组织';

  @override
  String get organizationHint =>
      '例如 mycompany 或 https://dev.azure.com/mycompany';

  @override
  String get organizationRequired => '请输入你的组织';

  @override
  String get organizationInsecure => '请使用 https:// 地址，以免令牌以未加密方式发送';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored => '已保存一个令牌。重新输入即可更改。';

  @override
  String get requiredScopes => '所需范围';

  @override
  String get tokenRequired => '请输入你的令牌';

  @override
  String get tokenHelpTitle => '如何创建令牌？';

  @override
  String get tokenHelpStep1 =>
      '在 Azure DevOps 中打开 User settings → Personal access tokens，然后选择 New Token。';

  @override
  String get tokenHelpStep2 => '选择你的组织和过期日期。';

  @override
  String get tokenHelpStep3 =>
      '在 Scopes 下选择 Custom defined，并只启用上面列出的范围，每个范围使用旁边显示的权限。';

  @override
  String get tokenHelpStep4 => '选择 Create，复制令牌并粘贴到上方。令牌只显示一次。';

  @override
  String get tokenHelpPermissions =>
      '令牌的权限永远不会超过你的账户：你至少需要 Stakeholder 访问级别，以及要查看的项目的读取权限。';

  @override
  String get tokenHelpDocs => 'Microsoft 文档';

  @override
  String get connecting => '正在连接…';

  @override
  String get connect => '连接';

  @override
  String get appearance => '外观';

  @override
  String get themeLight => '浅色';

  @override
  String get themeSystem => '系统';

  @override
  String get themeDark => '深色';

  @override
  String get colorAzureBlue => 'Azure 蓝';

  @override
  String get colorSystem => '系统颜色';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '系统语言';

  @override
  String get privacy => '隐私';

  @override
  String get about => '关于';

  @override
  String appVersion(String version) {
    return '版本 $version';
  }

  @override
  String madeBy(String name) {
    return '由 $name 开发';
  }

  @override
  String get sendErrorReports => '发送错误报告';

  @override
  String get sendErrorReportsHint => '发送匿名的崩溃和错误详情，以便修复问题。绝不会发送你的令牌。';

  @override
  String get signOut => '退出登录';

  @override
  String get selectTicketTitle => '选择一个工单';

  @override
  String get selectTicketMessage => '在左侧选择一个工单以查看详情。';

  @override
  String get chooseProjects => '选择项目';

  @override
  String get refresh => '刷新';

  @override
  String get searchTicketsHint => '按标题、ID、标签或人员搜索';

  @override
  String get scopeAssignedToMe => '分配给我';

  @override
  String get scopeCreatedByMe => '我创建的';

  @override
  String get scopeAll => '全部';

  @override
  String get openOnly => '仅未关闭';

  @override
  String get loadTicketsFailed => '无法加载工单';

  @override
  String get retry => '重试';

  @override
  String get noProjectsTitle => '未选择项目';

  @override
  String get noProjectsMessage => '选择一个或多个项目以查看工单。';

  @override
  String get noTicketsTitle => '没有工单';

  @override
  String get noTicketsMessage => '没有符合筛选条件的工单。';

  @override
  String ticketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个工单',
    );
    return '$_temp0';
  }

  @override
  String get unassigned => '未分配';

  @override
  String get projects => '项目';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个项目',
    );
    return '$_temp0';
  }

  @override
  String get apply => '应用';

  @override
  String get searchProjectHint => '搜索项目';

  @override
  String get loadProjectsFailed => '无法加载项目';

  @override
  String get browserOpenFailed => '无法打开浏览器';

  @override
  String get openInDevOps => '在 DevOps 中打开';

  @override
  String get description => '描述';

  @override
  String get reproSteps => '重现步骤';

  @override
  String get acceptanceCriteria => '验收标准';

  @override
  String get symptom => '症状';

  @override
  String get systemInfo => '系统信息';

  @override
  String get proposedFix => '修复';

  @override
  String get emptyField => '无内容';

  @override
  String get assignedTo => '分配给';

  @override
  String get priority => '优先级';

  @override
  String get effort => '工作量';

  @override
  String get originalEstimate => '原始估计';

  @override
  String get remainingWork => '剩余工作';

  @override
  String get completedWork => '已完成工作';

  @override
  String hours(String value) {
    return '$value 小时';
  }

  @override
  String get area => '区域';

  @override
  String get iteration => '迭代';

  @override
  String get created => '创建时间';

  @override
  String createdOnBy(String date, String name) {
    return '$date，由 $name';
  }

  @override
  String get changed => '修改时间';

  @override
  String get linkedItems => '关联项';

  @override
  String get parent => '父项';

  @override
  String get child => '子项';

  @override
  String commentsCount(int count) {
    return '评论（$count）';
  }

  @override
  String get noComments => '暂无评论。';

  @override
  String attachmentsCount(int count) {
    return '附件 ($count)';
  }

  @override
  String get openFile => '打开文件';

  @override
  String get download => '下载';

  @override
  String get downloadLargeTitle => '下载大文件？';

  @override
  String downloadLargeBody(String name, String size) {
    return '$name 大小为 $size。下载可能需要一些时间并消耗移动数据。';
  }

  @override
  String get noAppForFile => '此设备上没有可以打开此文件的应用。';

  @override
  String get unknownPerson => '未知';

  @override
  String get justNow => '刚刚';

  @override
  String minutesAgo(int count) {
    return '$count 分钟前';
  }

  @override
  String hoursAgo(int count) {
    return '$count 小时前';
  }

  @override
  String daysAgo(int count) {
    return '$count 天前';
  }

  @override
  String get errorUnauthorized =>
      '你的 Personal Access Token 无效或已过期。请在设置中创建一个新的。';

  @override
  String get errorNotFound => '未找到。请检查组织或项目。';

  @override
  String errorHttp(int code) {
    return 'Azure DevOps 返回错误 $code';
  }

  @override
  String get errorUnexpectedResponse => '意外的响应。请检查组织和令牌。';

  @override
  String get widgetSetupRequired => '打开应用进行设置';

  @override
  String get tickets => '工单';

  @override
  String get pipelines => '管道';

  @override
  String get searchRunsHint => '按管道、分支或人员搜索';

  @override
  String get activeOnly => '仅进行中';

  @override
  String get loadRunsFailed => '无法加载管道运行';

  @override
  String get noRunsTitle => '没有管道运行';

  @override
  String get noRunsMessage => '没有符合筛选条件的管道运行。';

  @override
  String runCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次运行',
    );
    return '$_temp0';
  }

  @override
  String get selectRunTitle => '选择一次管道运行';

  @override
  String get selectRunMessage => '在左侧选择一次运行以跟踪其进度。';

  @override
  String get runPending => '等待中';

  @override
  String get runQueued => '排队中';

  @override
  String get runRunning => '运行中';

  @override
  String get runCancelling => '正在取消';

  @override
  String get runSucceeded => '成功';

  @override
  String get runPartiallySucceeded => '部分成功';

  @override
  String get runFailed => '失败';

  @override
  String get runCanceled => '已取消';

  @override
  String get runSkipped => '已跳过';

  @override
  String get progress => '进度';

  @override
  String tasksProgress(int done, int total) {
    return '已完成 $done/$total 个任务';
  }

  @override
  String get branch => '分支';

  @override
  String get requestedBy => '请求者';

  @override
  String get queued => '排队时间';

  @override
  String get started => '开始时间';

  @override
  String get finished => '结束时间';

  @override
  String get duration => '持续时间';

  @override
  String get stages => '阶段';

  @override
  String get noStagesYet => '运行开始后将显示阶段。';

  @override
  String get runWaitingForApproval => '等待审批';

  @override
  String get runNotDeployed => '未部署';

  @override
  String get builds => '生成';

  @override
  String get releases => '发布';

  @override
  String get loadReleasesFailed => '无法加载发布';

  @override
  String get releaseScopeHint =>
      '发布需要令牌具有 Release (Read, write, & execute) 范围。';

  @override
  String get artifact => '项目';

  @override
  String waitingForApprovalBy(String names) {
    return '等待 $names 审批';
  }

  @override
  String get approvals => '审批';

  @override
  String approveStage(String stage) {
    return '批准 $stage？';
  }

  @override
  String rejectStage(String stage) {
    return '拒绝 $stage？';
  }

  @override
  String get approvalCommentHint => '评论（可选）';

  @override
  String get stageApproved => '阶段已批准';

  @override
  String get stageRejected => '阶段已拒绝';

  @override
  String get buildScopeHint => '操作管道运行需要令牌具有 Build (Read & execute) 范围。';

  @override
  String get cancelRun => '取消运行';

  @override
  String get cancelRunTitle => '取消此运行？';

  @override
  String get cancelRunBody => '正在运行的作业将停止，尚未开始的作业将被跳过。';

  @override
  String get keepRunning => '继续运行';

  @override
  String get runAgain => '再次运行';

  @override
  String get rerunFailedJobs => '重新运行失败的作业';

  @override
  String get runStarted => '运行已开始';

  @override
  String get open => '打开';

  @override
  String get pullRequests => '拉取请求';

  @override
  String get searchPullRequestsHint => '按标题、ID、分支或人员搜索';

  @override
  String get scopeReviewing => '待我审阅';

  @override
  String get loadPullRequestsFailed => '无法加载拉取请求';

  @override
  String get codeScopeHint => '拉取请求需要令牌具有 Code (Read & write) 范围。';

  @override
  String get noPullRequestsTitle => '没有拉取请求';

  @override
  String get noPullRequestsMessage => '没有符合筛选条件的拉取请求。';

  @override
  String pullRequestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个拉取请求',
    );
    return '$_temp0';
  }

  @override
  String get selectPullRequestTitle => '选择一个拉取请求';

  @override
  String get selectPullRequestMessage => '在左侧选择一个拉取请求以查看详细信息。';

  @override
  String get prDraft => '草稿';

  @override
  String get prActive => '活动';

  @override
  String get prCompleted => '已完成';

  @override
  String get prAbandoned => '已放弃';

  @override
  String get mergeConflicts => '合并冲突';

  @override
  String get repository => '存储库';

  @override
  String get closed => '已关闭';

  @override
  String get reviewers => '审阅者';

  @override
  String get noReviewers => '没有审阅者';

  @override
  String get requiredReviewer => '必需';

  @override
  String get voteApproved => '已批准';

  @override
  String get voteApprovedWithSuggestions => '已批准但有建议';

  @override
  String get voteNone => '未投票';

  @override
  String get voteWaitingForAuthor => '等待作者';

  @override
  String get voteRejected => '已拒绝';

  @override
  String get threadResolved => '已解决';

  @override
  String get overviewTab => '概览';

  @override
  String get filesTab => '文件';

  @override
  String filesChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已更改 $count 个文件',
    );
    return '$_temp0';
  }

  @override
  String get noFileChanges => '此拉取请求未更改任何文件。';

  @override
  String get loadFilesFailed => '无法加载已更改的文件';

  @override
  String get loadFileFailed => '无法加载此文件';

  @override
  String get binaryFile => '二进制文件';

  @override
  String get fileTooLarge => '文件太大，无法在此比较';

  @override
  String get noContentChanges => '内容无更改';

  @override
  String renamedFrom(String path) {
    return '从 $path 重命名';
  }

  @override
  String get voteApprove => '批准';

  @override
  String get voteApproveWithSuggestions => '批准并提出建议';

  @override
  String get voteWaitForAuthor => '等待作者';

  @override
  String get voteReject => '拒绝';

  @override
  String get voteReset => '重置投票';

  @override
  String get otherVotes => '其他投票';

  @override
  String get rejectConfirmTitle => '拒绝此拉取请求？';

  @override
  String get rejectConfirmBody => '只要你的投票为“已拒绝”，此拉取请求就无法完成。';

  @override
  String get waitForAuthorConfirmTitle => '等待作者？';

  @override
  String get voteReasonHint => '原因（可选）';

  @override
  String get voteReasonHelper => '将作为评论发布到此拉取请求。';

  @override
  String get voteSaved => '投票已保存';

  @override
  String get cancel => '取消';

  @override
  String get actionDenied => 'Azure DevOps 不允许此操作。请检查令牌是否具有正确的范围，以及你的帐户是否有权限。';

  @override
  String get writeComment => '写评论…';

  @override
  String get send => '发送';

  @override
  String get reply => '回复';

  @override
  String get writeReply => '写回复…';

  @override
  String get resolveThread => '解决';

  @override
  String get reactivateThread => '重新激活';

  @override
  String get workItemScopeHint => '评论工单需要令牌具有 Work Items (Read & write) 范围。';

  @override
  String get changeAssignee => '更改负责人';

  @override
  String get searchPeopleHint => '搜索人员';

  @override
  String get assignToMe => '分配给我';

  @override
  String assignedToName(String name) {
    return '已分配给 $name';
  }

  @override
  String get ticketUnassigned => '已取消分配工单';

  @override
  String get assignScopeHint => '分配工单需要令牌具有 Work Items (Read & write) 范围。';

  @override
  String get membersLoadFailed =>
      '无法加载团队成员。这需要令牌具有 Project and Team (Read) 范围。';

  @override
  String get noPeopleFound => '未找到任何人';

  @override
  String get copyLink => '复制链接';

  @override
  String get shareTicket => '分享';

  @override
  String get linkCopied => '链接已复制';

  @override
  String get undo => '撤消';

  @override
  String get runErrors => '错误';

  @override
  String get viewLog => '查看日志';

  @override
  String showAll(int count) {
    return '全部显示 ($count)';
  }

  @override
  String get copyLog => '复制日志';

  @override
  String get logCopied => '已复制日志';

  @override
  String get logEmpty => '此日志为空。';

  @override
  String get showMore => '显示更多';

  @override
  String get showLess => '收起';

  @override
  String get onlyErrorsAndWarnings => '仅错误和警告';

  @override
  String get noLogIssues => '此日志中没有错误或警告。';

  @override
  String get previousError => '上一个错误';

  @override
  String get nextError => '下一个错误';

  @override
  String errorPosition(int current, int total) {
    return '第 $current 个错误，共 $total 个';
  }

  @override
  String errorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个错误',
    );
    return '$_temp0';
  }

  @override
  String get dashboard => '概览';

  @override
  String refreshFailed(String time) {
    return '无法刷新。数据更新于$time。';
  }

  @override
  String get loadDashboardFailed => '无法加载概览';

  @override
  String get myPullRequests => '我的拉取请求';

  @override
  String get myTickets => '我的未关闭工单';

  @override
  String get waitingForYourReview => '等待你审阅';

  @override
  String get waitingForYou => '等你处理';

  @override
  String get nothingWaiting => '目前没有等你处理的内容。';

  @override
  String get readyToComplete => '已批准，可以完成';

  @override
  String get yourApproval => '等待你的批准';

  @override
  String get myRuns => '我的运行';

  @override
  String get noRecentRuns => '你最近没有启动任何运行。';

  @override
  String failingOnMain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个管道在主分支上失败',
    );
    return '$_temp0';
  }

  @override
  String noChangesFor(int count) {
    return '$count 天未更改';
  }

  @override
  String get linkNotSupported => '无法在应用中打开此链接。';

  @override
  String get linkOtherOrganization => '此链接属于其他组织，而不是你当前连接的组织。';

  @override
  String get notifications => '通知';

  @override
  String get runNotificationsHint => '在应用打开时显示正在运行的管道进度，并在后台持续跟踪直到完成。';

  @override
  String get runNotificationsOff => '关闭';

  @override
  String get runNotificationsMine => '我的运行';

  @override
  String get runNotificationsAll => '所有运行';

  @override
  String get runNotificationChannel => '管道进度';

  @override
  String get notificationsDenied => '已在 Android 设置中关闭此应用的通知。';

  @override
  String runNotificationsRunning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个管道正在运行',
    );
    return '$_temp0';
  }
}
