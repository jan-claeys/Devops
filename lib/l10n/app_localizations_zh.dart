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
  String get onboardingIntro => '连接到 Azure DevOps 以查看你的工单。';

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
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored => '已保存一个令牌。重新输入即可更改。';

  @override
  String get tokenScopeHint =>
      '所需范围：Work Items (Read) 和 Project and Team (Read)';

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
      '在 Scopes 下选择 Custom defined，并只启用 Work Items: Read 和 Project and Team: Read。';

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
  String get errorUnauthorized => '未授权。请检查你的 Personal Access Token。';

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
}
