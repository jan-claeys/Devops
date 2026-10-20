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
  String get onboardingIntro => 'Azure DevOps에 연결하여 티켓을 확인하세요.';

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
      '필요한 범위: Work Items (Read) 및 Project and Team (Read)';

  @override
  String get tokenRequired => '토큰을 입력하세요';

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
  String get signOut => '로그아웃';

  @override
  String get selectTicketTitle => '티켓 선택';

  @override
  String get selectTicketMessage => '왼쪽에서 티켓을 선택하면 세부 정보가 표시됩니다.';

  @override
  String get chooseProject => '프로젝트 선택';

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
  String get noProjectTitle => '선택된 프로젝트 없음';

  @override
  String get noProjectMessage => '티켓을 보려면 프로젝트를 선택하세요.';

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
  String get chooseAProject => '프로젝트 선택';

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
}
