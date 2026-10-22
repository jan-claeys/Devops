// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get settings => 'Настройки';

  @override
  String get connectionSaved => 'Подключение сохранено';

  @override
  String get onboardingIntro => 'Подключитесь к Azure DevOps, чтобы начать.';

  @override
  String get connection => 'Подключение';

  @override
  String get organization => 'Организация';

  @override
  String get organizationHint =>
      'напр. mycompany или https://dev.azure.com/mycompany';

  @override
  String get organizationRequired => 'Введите организацию';

  @override
  String get organizationInsecure =>
      'Используйте адрес https://, чтобы токен не передавался без шифрования';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'Токен уже сохранён. Введите его снова, чтобы изменить.';

  @override
  String get requiredScopes => 'Нужные права';

  @override
  String get tokenRequired => 'Введите токен';

  @override
  String get tokenHelpTitle => 'Как создать токен?';

  @override
  String get tokenHelpStep1 =>
      'В Azure DevOps откройте User settings → Personal access tokens и выберите New Token.';

  @override
  String get tokenHelpStep2 => 'Выберите организацию и срок действия.';

  @override
  String get tokenHelpStep3 =>
      'В разделе Scopes выберите Custom defined и включите только права, перечисленные выше, каждое с уровнем Read.';

  @override
  String get tokenHelpStep4 =>
      'Нажмите Create, скопируйте токен и вставьте его выше. Он показывается только один раз.';

  @override
  String get tokenHelpPermissions =>
      'У токена никогда не бывает больше прав, чем у вашей учётной записи: нужен как минимум доступ Stakeholder и права на чтение нужных проектов.';

  @override
  String get tokenHelpDocs => 'Документация Microsoft';

  @override
  String get connecting => 'Подключение…';

  @override
  String get connect => 'Подключиться';

  @override
  String get appearance => 'Оформление';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get colorAzureBlue => 'Синий Azure';

  @override
  String get colorSystem => 'Системный цвет';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Язык системы';

  @override
  String get privacy => 'Конфиденциальность';

  @override
  String get about => 'О приложении';

  @override
  String appVersion(String version) {
    return 'Версия $version';
  }

  @override
  String madeBy(String name) {
    return 'Автор: $name';
  }

  @override
  String get sendErrorReports => 'Отправлять отчёты об ошибках';

  @override
  String get sendErrorReportsHint =>
      'Отправляет анонимные данные о сбоях и ошибках, чтобы их можно было исправить. Ваш токен никогда не отправляется.';

  @override
  String get signOut => 'Выйти';

  @override
  String get selectTicketTitle => 'Выберите тикет';

  @override
  String get selectTicketMessage =>
      'Выберите тикет слева, чтобы увидеть подробности.';

  @override
  String get chooseProjects => 'Выберите проекты';

  @override
  String get refresh => 'Обновить';

  @override
  String get searchTicketsHint => 'Поиск по названию, ID, тегу или человеку';

  @override
  String get scopeAssignedToMe => 'Мне';

  @override
  String get scopeCreatedByMe => 'Мои';

  @override
  String get scopeAll => 'Все';

  @override
  String get openOnly => 'Только открытые';

  @override
  String get loadTicketsFailed => 'Не удалось загрузить тикеты';

  @override
  String get retry => 'Повторить';

  @override
  String get noProjectsTitle => 'Проекты не выбраны';

  @override
  String get noProjectsMessage =>
      'Выберите один или несколько проектов, чтобы увидеть тикеты.';

  @override
  String get noTicketsTitle => 'Нет тикетов';

  @override
  String get noTicketsMessage => 'Нет тикетов, соответствующих фильтрам.';

  @override
  String ticketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count тикета',
      many: '$count тикетов',
      few: '$count тикета',
      one: '$count тикет',
    );
    return '$_temp0';
  }

  @override
  String get unassigned => 'Не назначен';

  @override
  String get projects => 'Проекты';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count проекта',
      many: '$count проектов',
      few: '$count проекта',
      one: '$count проект',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Применить';

  @override
  String get searchProjectHint => 'Поиск проекта';

  @override
  String get loadProjectsFailed => 'Не удалось загрузить проекты';

  @override
  String get browserOpenFailed => 'Не удалось открыть браузер';

  @override
  String get openInDevOps => 'Открыть в DevOps';

  @override
  String get description => 'Описание';

  @override
  String get reproSteps => 'Шаги воспроизведения';

  @override
  String get acceptanceCriteria => 'Критерии приёмки';

  @override
  String get symptom => 'Симптом';

  @override
  String get systemInfo => 'Сведения о системе';

  @override
  String get proposedFix => 'Исправление';

  @override
  String get emptyField => 'Нет содержимого';

  @override
  String get assignedTo => 'Назначен';

  @override
  String get priority => 'Приоритет';

  @override
  String get effort => 'Трудозатраты';

  @override
  String get originalEstimate => 'Исходная оценка';

  @override
  String get remainingWork => 'Оставшаяся работа';

  @override
  String get completedWork => 'Выполненная работа';

  @override
  String hours(String value) {
    return '$value ч';
  }

  @override
  String get area => 'Область';

  @override
  String get iteration => 'Итерация';

  @override
  String get created => 'Создан';

  @override
  String createdOnBy(String date, String name) {
    return '$date, $name';
  }

  @override
  String get changed => 'Изменён';

  @override
  String get linkedItems => 'Связанные элементы';

  @override
  String get parent => 'Родительский';

  @override
  String get child => 'Дочерний';

  @override
  String commentsCount(int count) {
    return 'Комментарии ($count)';
  }

  @override
  String get noComments => 'Комментариев пока нет.';

  @override
  String attachmentsCount(int count) {
    return 'Вложения ($count)';
  }

  @override
  String get openFile => 'Открыть файл';

  @override
  String get download => 'Скачать';

  @override
  String get downloadLargeTitle => 'Скачать большой файл?';

  @override
  String downloadLargeBody(String name, String size) {
    return '$name занимает $size. Загрузка может занять время и расходовать мобильный трафик.';
  }

  @override
  String get noAppForFile =>
      'На этом устройстве нет приложения, которое может открыть этот файл.';

  @override
  String get unknownPerson => 'Неизвестно';

  @override
  String get justNow => 'только что';

  @override
  String minutesAgo(int count) {
    return '$count мин назад';
  }

  @override
  String hoursAgo(int count) {
    return '$count ч назад';
  }

  @override
  String daysAgo(int count) {
    return '$count дн. назад';
  }

  @override
  String get errorUnauthorized =>
      'Personal Access Token недействителен или истёк. Создайте новый в настройках.';

  @override
  String get errorNotFound => 'Не найдено. Проверьте организацию или проект.';

  @override
  String errorHttp(int code) {
    return 'Ошибка $code от Azure DevOps';
  }

  @override
  String get errorUnexpectedResponse =>
      'Неожиданный ответ. Проверьте организацию и токен.';

  @override
  String get widgetSetupRequired => 'Откройте приложение для настройки';

  @override
  String get tickets => 'Тикеты';

  @override
  String get pipelines => 'Конвейеры';

  @override
  String get searchRunsHint => 'Поиск по конвейеру, ветке или человеку';

  @override
  String get activeOnly => 'Только активные';

  @override
  String get loadRunsFailed => 'Не удалось загрузить запуски';

  @override
  String get noRunsTitle => 'Нет запусков конвейеров';

  @override
  String get noRunsMessage => 'Нет запусков, соответствующих фильтрам.';

  @override
  String runCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count запуска',
      many: '$count запусков',
      few: '$count запуска',
      one: '$count запуск',
    );
    return '$_temp0';
  }

  @override
  String get selectRunTitle => 'Выберите запуск';

  @override
  String get selectRunMessage =>
      'Выберите запуск слева, чтобы следить за ходом выполнения.';

  @override
  String get runPending => 'Ожидание';

  @override
  String get runQueued => 'В очереди';

  @override
  String get runRunning => 'Выполняется';

  @override
  String get runCancelling => 'Отменяется';

  @override
  String get runSucceeded => 'Успешно';

  @override
  String get runPartiallySucceeded => 'Частично успешно';

  @override
  String get runFailed => 'Ошибка';

  @override
  String get runCanceled => 'Отменено';

  @override
  String get runSkipped => 'Пропущено';

  @override
  String get progress => 'Ход выполнения';

  @override
  String tasksProgress(int done, int total) {
    return 'Выполнено задач: $done из $total';
  }

  @override
  String get branch => 'Ветка';

  @override
  String get requestedBy => 'Запросил';

  @override
  String get queued => 'Поставлен в очередь';

  @override
  String get started => 'Начат';

  @override
  String get finished => 'Завершён';

  @override
  String get duration => 'Длительность';

  @override
  String get stages => 'Этапы';

  @override
  String get noStagesYet => 'Этапы появятся после начала запуска.';

  @override
  String get runWaitingForApproval => 'Ожидает утверждения';

  @override
  String get runNotDeployed => 'Не развёрнуто';

  @override
  String get builds => 'Сборки';

  @override
  String get releases => 'Выпуски';

  @override
  String get loadReleasesFailed => 'Не удалось загрузить выпуски';

  @override
  String get releaseScopeHint =>
      'Для выпусков токену нужны права Release (Read).';

  @override
  String get artifact => 'Артефакт';

  @override
  String waitingForApprovalBy(String names) {
    return 'Ожидает утверждения: $names';
  }

  @override
  String get pullRequests => 'Pull request’ы';

  @override
  String get searchPullRequestsHint =>
      'Поиск по названию, ID, ветке или человеку';

  @override
  String get scopeReviewing => 'На проверку';

  @override
  String get loadPullRequestsFailed => 'Не удалось загрузить pull request’ы';

  @override
  String get codeScopeHint =>
      'Для pull request’ов токену нужны права Code (Read).';

  @override
  String get noPullRequestsTitle => 'Нет pull request’ов';

  @override
  String get noPullRequestsMessage =>
      'Нет pull request’ов, соответствующих фильтрам.';

  @override
  String pullRequestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pull request’а',
      many: '$count pull request’ов',
      few: '$count pull request’а',
      one: '$count pull request',
    );
    return '$_temp0';
  }

  @override
  String get selectPullRequestTitle => 'Выберите pull request';

  @override
  String get selectPullRequestMessage =>
      'Выберите pull request слева, чтобы увидеть подробности.';

  @override
  String get prDraft => 'Черновик';

  @override
  String get prActive => 'Активный';

  @override
  String get prCompleted => 'Завершён';

  @override
  String get prAbandoned => 'Отменён';

  @override
  String get mergeConflicts => 'Конфликты слияния';

  @override
  String get repository => 'Репозиторий';

  @override
  String get closed => 'Закрыт';

  @override
  String get reviewers => 'Рецензенты';

  @override
  String get noReviewers => 'Нет рецензентов';

  @override
  String get requiredReviewer => 'Обязательный';

  @override
  String get voteApproved => 'Одобрено';

  @override
  String get voteApprovedWithSuggestions => 'Одобрено с предложениями';

  @override
  String get voteNone => 'Нет голоса';

  @override
  String get voteWaitingForAuthor => 'Ожидает автора';

  @override
  String get voteRejected => 'Отклонено';

  @override
  String get threadResolved => 'Решено';

  @override
  String get runErrors => 'Ошибки';

  @override
  String get viewLog => 'Показать журнал';

  @override
  String showAll(int count) {
    return 'Показать все ($count)';
  }

  @override
  String get copyLog => 'Копировать журнал';

  @override
  String get logCopied => 'Журнал скопирован';

  @override
  String get logEmpty => 'Этот журнал пуст.';

  @override
  String get showMore => 'Показать больше';

  @override
  String get showLess => 'Показать меньше';

  @override
  String get onlyErrorsAndWarnings => 'Только ошибки и предупреждения';

  @override
  String get noLogIssues => 'В этом журнале нет ошибок и предупреждений.';

  @override
  String get previousError => 'Предыдущая ошибка';

  @override
  String get nextError => 'Следующая ошибка';

  @override
  String errorPosition(int current, int total) {
    return 'Ошибка $current из $total';
  }

  @override
  String errorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ошибки',
      many: '$count ошибок',
      few: '$count ошибки',
      one: '1 ошибка',
    );
    return '$_temp0';
  }

  @override
  String get dashboard => 'Обзор';

  @override
  String refreshFailed(String time) {
    return 'Не удалось обновить. Данные: $time.';
  }

  @override
  String get loadDashboardFailed => 'Не удалось загрузить обзор';

  @override
  String get myPullRequests => 'Мои pull request’ы';

  @override
  String get myTickets => 'Мои открытые тикеты';

  @override
  String get waitingForYourReview => 'Ждёт вашего ревью';

  @override
  String get waitingForYou => 'Ждёт вас';

  @override
  String get nothingWaiting => 'Сейчас вас ничего не ждёт.';

  @override
  String get readyToComplete => 'Одобрен, можно завершить';

  @override
  String get yourApproval => 'Ждёт вашего одобрения';

  @override
  String get myRuns => 'Мои запуски';

  @override
  String get noRecentRuns => 'Вы давно не запускали конвейеры.';

  @override
  String failingOnMain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count конвейера падают на основной ветке',
      many: '$count конвейеров падают на основной ветке',
      few: '$count конвейера падают на основной ветке',
      one: '$count конвейер падает на основной ветке',
    );
    return '$_temp0';
  }

  @override
  String noChangesFor(int count) {
    return 'Без изменений $count дн.';
  }
}
