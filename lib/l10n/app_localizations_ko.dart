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
  String get organizationInsecure =>
      '토큰이 암호화되지 않은 채 전송되지 않도록 https:// 주소를 사용하세요';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored => '토큰이 이미 저장되어 있습니다. 변경하려면 다시 입력하세요.';

  @override
  String get requiredScopes => '필요한 범위';

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
      'Scopes에서 Custom defined를 선택하고 위에 나열된 범위만 각각 Read로 켭니다.';

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
  String attachmentsCount(int count) {
    return '첨부 파일 ($count)';
  }

  @override
  String get openFile => '파일 열기';

  @override
  String get download => '다운로드';

  @override
  String get downloadLargeTitle => '큰 파일을 다운로드할까요?';

  @override
  String downloadLargeBody(String name, String size) {
    return '$name의 크기는 $size입니다. 다운로드에 시간이 걸리고 모바일 데이터가 사용될 수 있습니다.';
  }

  @override
  String get noAppForFile => '이 기기에 이 파일을 열 수 있는 앱이 없습니다.';

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
  String get errorUnauthorized =>
      'Personal Access Token이 유효하지 않거나 만료되었습니다. 설정에서 새 토큰을 만드세요.';

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

  @override
  String get runWaitingForApproval => '승인 대기 중';

  @override
  String get runNotDeployed => '배포 안 됨';

  @override
  String get builds => '빌드';

  @override
  String get releases => '릴리스';

  @override
  String get loadReleasesFailed => '릴리스를 불러오지 못했습니다';

  @override
  String get releaseScopeHint => '릴리스를 보려면 토큰에 Release (Read) 범위가 필요합니다.';

  @override
  String get artifact => '아티팩트';

  @override
  String waitingForApprovalBy(String names) {
    return '$names의 승인 대기 중';
  }

  @override
  String get pullRequests => '끌어오기 요청';

  @override
  String get searchPullRequestsHint => '제목, ID, 분기 또는 사람으로 검색';

  @override
  String get scopeReviewing => '검토 대상';

  @override
  String get loadPullRequestsFailed => '끌어오기 요청을 불러오지 못했습니다';

  @override
  String get codeScopeHint => '끌어오기 요청을 보려면 토큰에 Code (Read) 범위가 필요합니다.';

  @override
  String get noPullRequestsTitle => '끌어오기 요청 없음';

  @override
  String get noPullRequestsMessage => '필터와 일치하는 끌어오기 요청이 없습니다.';

  @override
  String pullRequestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '끌어오기 요청 $count개',
    );
    return '$_temp0';
  }

  @override
  String get selectPullRequestTitle => '끌어오기 요청 선택';

  @override
  String get selectPullRequestMessage => '왼쪽에서 끌어오기 요청을 선택하면 세부 정보를 볼 수 있습니다.';

  @override
  String get prDraft => '초안';

  @override
  String get prActive => '활성';

  @override
  String get prCompleted => '완료됨';

  @override
  String get prAbandoned => '중단됨';

  @override
  String get mergeConflicts => '병합 충돌';

  @override
  String get repository => '리포지토리';

  @override
  String get closed => '닫힘';

  @override
  String get reviewers => '검토자';

  @override
  String get noReviewers => '검토자 없음';

  @override
  String get requiredReviewer => '필수';

  @override
  String get voteApproved => '승인됨';

  @override
  String get voteApprovedWithSuggestions => '제안과 함께 승인됨';

  @override
  String get voteNone => '투표 없음';

  @override
  String get voteWaitingForAuthor => '작성자 대기 중';

  @override
  String get voteRejected => '거부됨';

  @override
  String get threadResolved => '해결됨';

  @override
  String get runErrors => '오류';

  @override
  String get viewLog => '로그 보기';

  @override
  String showAll(int count) {
    return '모두 보기 ($count)';
  }

  @override
  String get copyLog => '로그 복사';

  @override
  String get logCopied => '로그를 복사했습니다';

  @override
  String get logEmpty => '이 로그는 비어 있습니다.';

  @override
  String get showMore => '더 보기';

  @override
  String get showLess => '간략히 보기';

  @override
  String get onlyErrorsAndWarnings => '오류 및 경고만';

  @override
  String get noLogIssues => '이 로그에는 오류나 경고가 없습니다.';

  @override
  String get previousError => '이전 오류';

  @override
  String get nextError => '다음 오류';

  @override
  String errorPosition(int current, int total) {
    return '오류 $current/$total';
  }

  @override
  String errorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '오류 $count개',
    );
    return '$_temp0';
  }

  @override
  String get dashboard => '개요';

  @override
  String refreshFailed(String time) {
    return '새로 고치지 못했습니다. 데이터: $time';
  }

  @override
  String get loadDashboardFailed => '개요를 불러오지 못했습니다';

  @override
  String get myPullRequests => '내 끌어오기 요청';

  @override
  String get myTickets => '내 열린 티켓';

  @override
  String get waitingForYourReview => '내 검토 대기 중';

  @override
  String get waitingForYou => '나를 기다리는 항목';

  @override
  String get nothingWaiting => '지금은 기다리는 항목이 없습니다.';

  @override
  String get readyToComplete => '승인됨, 완료 가능';

  @override
  String get yourApproval => '내 승인 대기 중';

  @override
  String get myRuns => '내 실행';

  @override
  String get noRecentRuns => '최근에 시작한 실행이 없습니다.';

  @override
  String failingOnMain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '파이프라인 $count개가 기본 분기에서 실패 중',
    );
    return '$_temp0';
  }

  @override
  String noChangesFor(int count) {
    return '$count일 동안 변경 없음';
  }
}
