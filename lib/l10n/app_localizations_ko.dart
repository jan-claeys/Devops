// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get welcome => '환영합니다';

  @override
  String get settings => '설정';

  @override
  String get connectionSaved => '연결이 저장되었습니다';

  @override
  String get onboardingIntro => '시작하려면 Azure DevOps에 연결하세요.';

  @override
  String get connection => '연결';

  @override
  String get organization => '조직';

  @override
  String get organizationHint =>
      '예: mycompany 또는 https://dev.azure.com/mycompany';

  @override
  String get organizationRequired => '조직을 입력하세요';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored => '토큰이 이미 저장되어 있습니다. 변경하려면 다시 입력하세요.';

  @override
  String get tokenScopeHint =>
      '필요한 범위: Work Items (Read), Build (Read) 및 Project and Team (Read)';

  @override
  String get tokenRequired => '토큰을 입력하세요';

  @override
  String get tokenHelpTitle => '토큰은 어떻게 만드나요?';

  @override
  String get tokenHelpStep1 =>
      'Azure DevOps에서 User settings → Personal access tokens를 열고 New Token을 선택합니다.';

  @override
  String get tokenHelpStep2 => '조직과 만료 날짜를 선택합니다.';

  @override
  String get tokenHelpStep3 =>
      'Scopes에서 Custom defined를 선택하고 Work Items: Read, Build: Read와 Project and Team: Read만 켭니다.';

  @override
  String get tokenHelpStep4 =>
      'Create를 선택하고 토큰을 복사해 위에 붙여넣습니다. 토큰은 한 번만 표시됩니다.';

  @override
  String get tokenHelpPermissions =>
      '토큰은 계정보다 많은 권한을 가질 수 없습니다. 최소 Stakeholder 액세스와 보려는 프로젝트에 대한 읽기 권한이 필요합니다.';

  @override
  String get tokenHelpDocs => 'Microsoft 문서';

  @override
  String get connecting => '연결 중…';

  @override
  String get connect => '연결';

  @override
  String get appearance => '화면';

  @override
  String get themeLight => '밝게';

  @override
  String get themeSystem => '시스템';

  @override
  String get themeDark => '어둡게';

  @override
  String get colorAzureBlue => 'Azure 블루';

  @override
  String get colorSystem => '시스템 색상';

  @override
  String get language => '언어';

  @override
  String get languageSystem => '시스템 언어';

  @override
  String get privacy => '개인정보';

  @override
  String get about => '정보';

  @override
  String appVersion(String version) {
    return '버전 $version';
  }

  @override
  String madeBy(String name) {
    return '제작: $name';
  }

  @override
  String get sendErrorReports => '오류 보고서 보내기';

  @override
  String get sendErrorReportsHint =>
      '버그를 수정할 수 있도록 충돌 및 오류에 대한 익명 정보를 보냅니다. 토큰은 절대 전송되지 않습니다.';

  @override
  String get signOut => '로그아웃';

  @override
  String get selectTicketTitle => '티켓 선택';

  @override
  String get selectTicketMessage => '왼쪽에서 티켓을 선택하면 세부 정보가 표시됩니다.';

  @override
  String get chooseProjects => '프로젝트 선택';

  @override
  String get refresh => '새로 고침';

  @override
  String get searchTicketsHint => '제목, ID, 태그 또는 사람으로 검색';

  @override
  String get scopeAssignedToMe => '내 할당';

  @override
  String get scopeCreatedByMe => '내가 만든';

  @override
  String get scopeAll => '전체';

  @override
  String get openOnly => '열린 항목만';

  @override
  String get loadTicketsFailed => '티켓을 불러올 수 없습니다';

  @override
  String get retry => '다시 시도';

  @override
  String get noProjectsTitle => '선택된 프로젝트 없음';

  @override
  String get noProjectsMessage => '티켓을 보려면 프로젝트를 하나 이상 선택하세요.';

  @override
  String get noTicketsTitle => '티켓 없음';

  @override
  String get noTicketsMessage => '필터와 일치하는 티켓이 없습니다.';

  @override
  String ticketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '티켓 $count개',
    );
    return '$_temp0';
  }

  @override
  String get unassigned => '할당되지 않음';

  @override
  String get projects => '프로젝트';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '프로젝트 $count개',
    );
    return '$_temp0';
  }

  @override
  String get apply => '적용';

  @override
  String get searchProjectHint => '프로젝트 검색';

  @override
  String get loadProjectsFailed => '프로젝트를 불러올 수 없습니다';

  @override
  String get browserOpenFailed => '브라우저를 열 수 없습니다';

  @override
  String get openInDevOps => 'DevOps에서 열기';

  @override
  String get description => '설명';

  @override
  String get reproSteps => '재현 단계';

  @override
  String get acceptanceCriteria => '수락 기준';

  @override
  String get symptom => '증상';

  @override
  String get systemInfo => '시스템 정보';

  @override
  String get proposedFix => '수정';

  @override
  String get emptyField => '내용 없음';

  @override
  String get assignedTo => '담당자';

  @override
  String get priority => '우선순위';

  @override
  String get effort => '작업량';

  @override
  String get originalEstimate => '초기 예상';

  @override
  String get remainingWork => '남은 작업';

  @override
  String get completedWork => '완료된 작업';

  @override
  String hours(String value) {
    return '$value시간';
  }

  @override
  String get area => '영역';

  @override
  String get iteration => '반복';

  @override
  String get created => '생성됨';

  @override
  String createdOnBy(String date, String name) {
    return '$date, $name';
  }

  @override
  String get changed => '변경됨';

  @override
  String get linkedItems => '연결된 항목';

  @override
  String get parent => '상위';

  @override
  String get child => '하위';

  @override
  String commentsCount(int count) {
    return '댓글 ($count)';
  }

  @override
  String get noComments => '아직 댓글이 없습니다.';

  @override
  String get unknownPerson => '알 수 없음';

  @override
  String get justNow => '방금';

  @override
  String minutesAgo(int count) {
    return '$count분 전';
  }

  @override
  String hoursAgo(int count) {
    return '$count시간 전';
  }

  @override
  String daysAgo(int count) {
    return '$count일 전';
  }

  @override
  String get errorUnauthorized => '권한이 없습니다. Personal Access Token을 확인하세요.';

  @override
  String get errorNotFound => '찾을 수 없습니다. 조직 또는 프로젝트를 확인하세요.';

  @override
  String errorHttp(int code) {
    return 'Azure DevOps 오류 $code';
  }

  @override
  String get errorUnexpectedResponse => '예기치 않은 응답입니다. 조직과 토큰을 확인하세요.';

  @override
  String get widgetSetupRequired => '앱을 열어 설정하세요';

  @override
  String get tickets => '티켓';

  @override
  String get pipelines => '파이프라인';

  @override
  String get searchRunsHint => '파이프라인, 브랜치 또는 사람으로 검색';

  @override
  String get activeOnly => '진행 중인 항목만';

  @override
  String get loadRunsFailed => '파이프라인 실행을 불러오지 못했습니다';

  @override
  String get noRunsTitle => '파이프라인 실행 없음';

  @override
  String get noRunsMessage => '필터와 일치하는 파이프라인 실행이 없습니다.';

  @override
  String runCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '실행 $count개',
    );
    return '$_temp0';
  }

  @override
  String get selectRunTitle => '파이프라인 실행 선택';

  @override
  String get selectRunMessage => '왼쪽에서 실행을 선택하면 진행 상황을 볼 수 있습니다.';

  @override
  String get runPending => '대기 중';

  @override
  String get runQueued => '대기열에 있음';

  @override
  String get runRunning => '실행 중';

  @override
  String get runCancelling => '취소 중';

  @override
  String get runSucceeded => '성공';

  @override
  String get runPartiallySucceeded => '부분 성공';

  @override
  String get runFailed => '실패';

  @override
  String get runCanceled => '취소됨';

  @override
  String get runSkipped => '건너뜀';

  @override
  String get progress => '진행 상황';

  @override
  String tasksProgress(int done, int total) {
    return '작업 $total개 중 $done개 완료';
  }

  @override
  String get branch => '브랜치';

  @override
  String get requestedBy => '요청자';

  @override
  String get queued => '대기열 추가';

  @override
  String get started => '시작';

  @override
  String get finished => '종료';

  @override
  String get duration => '소요 시간';

  @override
  String get stages => '단계';

  @override
  String get noStagesYet => '실행이 시작되면 단계가 표시됩니다.';
}
