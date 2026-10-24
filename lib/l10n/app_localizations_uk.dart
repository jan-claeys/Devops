// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get welcome => 'Ласкаво просимо';

  @override
  String get settings => 'Налаштування';

  @override
  String get connectionSaved => 'Підключення збережено';

  @override
  String get onboardingIntro => 'Підключіться до Azure DevOps, щоб почати.';

  @override
  String get connection => 'Підключення';

  @override
  String get organization => 'Організація';

  @override
  String get organizationHint =>
      'напр. mycompany або https://dev.azure.com/mycompany';

  @override
  String get organizationRequired => 'Введіть організацію';

  @override
  String get organizationInsecure =>
      'Використовуйте адресу https://, щоб токен не надсилався без шифрування';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'Токен уже збережено. Введіть його знову, щоб змінити.';

  @override
  String get requiredScopes => 'Потрібні права';

  @override
  String get tokenRequired => 'Введіть токен';

  @override
  String get tokenHelpTitle => 'Як створити токен?';

  @override
  String get tokenHelpStep1 =>
      'В Azure DevOps відкрийте User settings → Personal access tokens і виберіть New Token.';

  @override
  String get tokenHelpStep2 => 'Виберіть організацію та термін дії.';

  @override
  String get tokenHelpStep3 =>
      'У розділі Scopes виберіть Custom defined і ввімкніть лише права, перелічені вище, кожне з рівнем, указаним поруч.';

  @override
  String get tokenHelpStep4 =>
      'Натисніть Create, скопіюйте токен і вставте його вище. Він показується лише один раз.';

  @override
  String get tokenHelpPermissions =>
      'Токен ніколи не має більше прав, ніж ваш обліковий запис: потрібен щонайменше доступ Stakeholder і право читання потрібних проєктів.';

  @override
  String get tokenHelpDocs => 'Документація Microsoft';

  @override
  String get connecting => 'Підключення…';

  @override
  String get connect => 'Підключитися';

  @override
  String get appearance => 'Вигляд';

  @override
  String get themeLight => 'Світла';

  @override
  String get themeSystem => 'Системна';

  @override
  String get themeDark => 'Темна';

  @override
  String get colorAzureBlue => 'Синій Azure';

  @override
  String get colorSystem => 'Системний колір';

  @override
  String get language => 'Мова';

  @override
  String get languageSystem => 'Мова системи';

  @override
  String get privacy => 'Конфіденційність';

  @override
  String get about => 'Про застосунок';

  @override
  String appVersion(String version) {
    return 'Версія $version';
  }

  @override
  String madeBy(String name) {
    return 'Автор: $name';
  }

  @override
  String get sendErrorReports => 'Надсилати звіти про помилки';

  @override
  String get sendErrorReportsHint =>
      'Надсилає анонімні дані про збої та помилки, щоб їх можна було виправити. Ваш токен ніколи не надсилається.';

  @override
  String get signOut => 'Вийти';

  @override
  String get selectTicketTitle => 'Виберіть тікет';

  @override
  String get selectTicketMessage =>
      'Виберіть тікет ліворуч, щоб побачити подробиці.';

  @override
  String get chooseProjects => 'Виберіть проєкти';

  @override
  String get refresh => 'Оновити';

  @override
  String get searchTicketsHint => 'Пошук за назвою, ID, тегом або особою';

  @override
  String get scopeAssignedToMe => 'Мені';

  @override
  String get scopeCreatedByMe => 'Мої';

  @override
  String get scopeAll => 'Усі';

  @override
  String get openOnly => 'Лише відкриті';

  @override
  String get loadTicketsFailed => 'Не вдалося завантажити тікети';

  @override
  String get retry => 'Повторити';

  @override
  String get noProjectsTitle => 'Проєкти не вибрано';

  @override
  String get noProjectsMessage =>
      'Виберіть один або кілька проєктів, щоб побачити тікети.';

  @override
  String get noTicketsTitle => 'Немає тікетів';

  @override
  String get noTicketsMessage => 'Немає тікетів, що відповідають фільтрам.';

  @override
  String ticketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count тікета',
      many: '$count тікетів',
      few: '$count тікети',
      one: '$count тікет',
    );
    return '$_temp0';
  }

  @override
  String get unassigned => 'Не призначено';

  @override
  String get projects => 'Проєкти';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count проєкту',
      many: '$count проєктів',
      few: '$count проєкти',
      one: '$count проєкт',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Застосувати';

  @override
  String get searchProjectHint => 'Пошук проєкту';

  @override
  String get loadProjectsFailed => 'Не вдалося завантажити проєкти';

  @override
  String get browserOpenFailed => 'Не вдалося відкрити браузер';

  @override
  String get openInDevOps => 'Відкрити в DevOps';

  @override
  String get description => 'Опис';

  @override
  String get reproSteps => 'Кроки для відтворення';

  @override
  String get acceptanceCriteria => 'Критерії приймання';

  @override
  String get symptom => 'Симптом';

  @override
  String get systemInfo => 'Відомості про систему';

  @override
  String get proposedFix => 'Виправлення';

  @override
  String get emptyField => 'Немає вмісту';

  @override
  String get assignedTo => 'Призначено';

  @override
  String get priority => 'Пріоритет';

  @override
  String get effort => 'Трудовитрати';

  @override
  String get originalEstimate => 'Початкова оцінка';

  @override
  String get remainingWork => 'Залишок роботи';

  @override
  String get completedWork => 'Виконана робота';

  @override
  String hours(String value) {
    return '$value год';
  }

  @override
  String get area => 'Область';

  @override
  String get iteration => 'Ітерація';

  @override
  String get created => 'Створено';

  @override
  String createdOnBy(String date, String name) {
    return '$date, $name';
  }

  @override
  String get changed => 'Змінено';

  @override
  String get linkedItems => 'Пов\'язані елементи';

  @override
  String get parent => 'Батьківський';

  @override
  String get child => 'Дочірній';

  @override
  String commentsCount(int count) {
    return 'Коментарі ($count)';
  }

  @override
  String get noComments => 'Коментарів ще немає.';

  @override
  String attachmentsCount(int count) {
    return 'Вкладення ($count)';
  }

  @override
  String get openFile => 'Відкрити файл';

  @override
  String get download => 'Завантажити';

  @override
  String get downloadLargeTitle => 'Завантажити великий файл?';

  @override
  String downloadLargeBody(String name, String size) {
    return '$name має розмір $size. Завантаження може тривати довго й витрачати мобільний трафік.';
  }

  @override
  String get noAppForFile =>
      'На цьому пристрої немає застосунку, який може відкрити цей файл.';

  @override
  String get unknownPerson => 'Невідомо';

  @override
  String get justNow => 'щойно';

  @override
  String minutesAgo(int count) {
    return '$count хв тому';
  }

  @override
  String hoursAgo(int count) {
    return '$count год тому';
  }

  @override
  String daysAgo(int count) {
    return '$count дн. тому';
  }

  @override
  String get errorUnauthorized =>
      'Personal Access Token недійсний або його термін дії минув. Створіть новий у налаштуваннях.';

  @override
  String get errorNotFound => 'Не знайдено. Перевірте організацію або проєкт.';

  @override
  String errorHttp(int code) {
    return 'Помилка $code від Azure DevOps';
  }

  @override
  String get errorUnexpectedResponse =>
      'Неочікувана відповідь. Перевірте організацію та токен.';

  @override
  String get widgetSetupRequired => 'Відкрийте застосунок для налаштування';

  @override
  String get tickets => 'Тікети';

  @override
  String get pipelines => 'Конвеєри';

  @override
  String get searchRunsHint => 'Пошук за конвеєром, гілкою або людиною';

  @override
  String get activeOnly => 'Лише активні';

  @override
  String get loadRunsFailed => 'Не вдалося завантажити запуски';

  @override
  String get noRunsTitle => 'Немає запусків конвеєрів';

  @override
  String get noRunsMessage => 'Немає запусків, що відповідають фільтрам.';

  @override
  String runCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count запуску',
      many: '$count запусків',
      few: '$count запуски',
      one: '$count запуск',
    );
    return '$_temp0';
  }

  @override
  String get selectRunTitle => 'Виберіть запуск';

  @override
  String get selectRunMessage =>
      'Виберіть запуск ліворуч, щоб стежити за перебігом.';

  @override
  String get runPending => 'Очікування';

  @override
  String get runQueued => 'У черзі';

  @override
  String get runRunning => 'Виконується';

  @override
  String get runCancelling => 'Скасовується';

  @override
  String get runSucceeded => 'Успішно';

  @override
  String get runPartiallySucceeded => 'Частково успішно';

  @override
  String get runFailed => 'Помилка';

  @override
  String get runCanceled => 'Скасовано';

  @override
  String get runSkipped => 'Пропущено';

  @override
  String get progress => 'Перебіг';

  @override
  String tasksProgress(int done, int total) {
    return 'Виконано завдань: $done з $total';
  }

  @override
  String get branch => 'Гілка';

  @override
  String get requestedBy => 'Запит від';

  @override
  String get queued => 'Поставлено в чергу';

  @override
  String get started => 'Розпочато';

  @override
  String get finished => 'Завершено';

  @override
  String get duration => 'Тривалість';

  @override
  String get stages => 'Етапи';

  @override
  String get noStagesYet => 'Етапи з’являться після початку запуску.';

  @override
  String get runWaitingForApproval => 'Очікує схвалення';

  @override
  String get runNotDeployed => 'Не розгорнуто';

  @override
  String get builds => 'Збірки';

  @override
  String get releases => 'Випуски';

  @override
  String get loadReleasesFailed => 'Не вдалося завантажити випуски';

  @override
  String get releaseScopeHint =>
      'Для випусків токену потрібні права Release (Read).';

  @override
  String get artifact => 'Артефакт';

  @override
  String waitingForApprovalBy(String names) {
    return 'Очікує схвалення: $names';
  }

  @override
  String get pullRequests => 'Pull request’и';

  @override
  String get searchPullRequestsHint =>
      'Пошук за назвою, ID, гілкою або людиною';

  @override
  String get scopeReviewing => 'На перевірку';

  @override
  String get loadPullRequestsFailed => 'Не вдалося завантажити pull request’и';

  @override
  String get codeScopeHint =>
      'Для pull request’ів токену потрібні права Code (Read & write).';

  @override
  String get noPullRequestsTitle => 'Немає pull request’ів';

  @override
  String get noPullRequestsMessage =>
      'Немає pull request’ів, що відповідають фільтрам.';

  @override
  String pullRequestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pull request’у',
      many: '$count pull request’ів',
      few: '$count pull request’и',
      one: '$count pull request',
    );
    return '$_temp0';
  }

  @override
  String get selectPullRequestTitle => 'Виберіть pull request';

  @override
  String get selectPullRequestMessage =>
      'Виберіть pull request ліворуч, щоб побачити подробиці.';

  @override
  String get prDraft => 'Чернетка';

  @override
  String get prActive => 'Активний';

  @override
  String get prCompleted => 'Завершено';

  @override
  String get prAbandoned => 'Скасовано';

  @override
  String get mergeConflicts => 'Конфлікти злиття';

  @override
  String get repository => 'Репозиторій';

  @override
  String get closed => 'Закрито';

  @override
  String get reviewers => 'Рецензенти';

  @override
  String get noReviewers => 'Немає рецензентів';

  @override
  String get requiredReviewer => 'Обов’язковий';

  @override
  String get voteApproved => 'Схвалено';

  @override
  String get voteApprovedWithSuggestions => 'Схвалено з пропозиціями';

  @override
  String get voteNone => 'Немає голосу';

  @override
  String get voteWaitingForAuthor => 'Очікує автора';

  @override
  String get voteRejected => 'Відхилено';

  @override
  String get threadResolved => 'Вирішено';

  @override
  String get voteApprove => 'Схвалити';

  @override
  String get voteApproveWithSuggestions => 'Схвалити з пропозиціями';

  @override
  String get voteWaitForAuthor => 'Чекати на автора';

  @override
  String get voteReject => 'Відхилити';

  @override
  String get voteReset => 'Скинути голос';

  @override
  String get otherVotes => 'Інші варіанти';

  @override
  String get rejectConfirmTitle => 'Відхилити цей pull request?';

  @override
  String get rejectConfirmBody =>
      'Pull request не можна завершити, доки ваш голос — «Відхилено».';

  @override
  String get voteSaved => 'Голос збережено';

  @override
  String get cancel => 'Скасувати';

  @override
  String get actionDenied =>
      'Azure DevOps не дозволив цю дію. Перевірте, що токен має потрібні права, а обліковий запис — дозвіл.';

  @override
  String get writeComment => 'Напишіть коментар…';

  @override
  String get send => 'Надіслати';

  @override
  String get reply => 'Відповісти';

  @override
  String get writeReply => 'Напишіть відповідь…';

  @override
  String get resolveThread => 'Вирішити';

  @override
  String get reactivateThread => 'Відкрити знову';

  @override
  String get runErrors => 'Помилки';

  @override
  String get viewLog => 'Показати журнал';

  @override
  String showAll(int count) {
    return 'Показати всі ($count)';
  }

  @override
  String get copyLog => 'Копіювати журнал';

  @override
  String get logCopied => 'Журнал скопійовано';

  @override
  String get logEmpty => 'Цей журнал порожній.';

  @override
  String get showMore => 'Показати більше';

  @override
  String get showLess => 'Показати менше';

  @override
  String get onlyErrorsAndWarnings => 'Лише помилки та попередження';

  @override
  String get noLogIssues => 'У цьому журналі немає помилок і попереджень.';

  @override
  String get previousError => 'Попередня помилка';

  @override
  String get nextError => 'Наступна помилка';

  @override
  String errorPosition(int current, int total) {
    return 'Помилка $current з $total';
  }

  @override
  String errorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count помилки',
      many: '$count помилок',
      few: '$count помилки',
      one: '1 помилка',
    );
    return '$_temp0';
  }

  @override
  String get dashboard => 'Огляд';

  @override
  String refreshFailed(String time) {
    return 'Не вдалося оновити. Дані: $time.';
  }

  @override
  String get loadDashboardFailed => 'Не вдалося завантажити огляд';

  @override
  String get myPullRequests => 'Мої pull request’и';

  @override
  String get myTickets => 'Мої відкриті тікети';

  @override
  String get waitingForYourReview => 'Чекає на ваше рев’ю';

  @override
  String get waitingForYou => 'Чекає на вас';

  @override
  String get nothingWaiting => 'Зараз на вас нічого не чекає.';

  @override
  String get readyToComplete => 'Схвалено, можна завершити';

  @override
  String get yourApproval => 'Чекає на ваше схвалення';

  @override
  String get myRuns => 'Мої запуски';

  @override
  String get noRecentRuns => 'Ви давно не запускали конвеєри.';

  @override
  String failingOnMain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count конвеєра падають на основній гілці',
      many: '$count конвеєрів падають на основній гілці',
      few: '$count конвеєри падають на основній гілці',
      one: '$count конвеєр падає на основній гілці',
    );
    return '$_temp0';
  }

  @override
  String noChangesFor(int count) {
    return 'Без змін $count дн.';
  }

  @override
  String get linkNotSupported => 'Це посилання не можна відкрити в застосунку.';

  @override
  String get linkOtherOrganization =>
      'Це посилання належить іншій організації, а не тій, до якої ви підключені.';

  @override
  String get notifications => 'Сповіщення';

  @override
  String get runNotificationsHint =>
      'Показує хід виконання запущених конвеєрів, поки застосунок відкритий, і продовжує стежити за ними у фоні до завершення.';

  @override
  String get runNotificationsOff => 'Вимк.';

  @override
  String get runNotificationsMine => 'Мої запуски';

  @override
  String get runNotificationsAll => 'Усі запуски';

  @override
  String get runNotificationChannel => 'Хід виконання конвеєрів';

  @override
  String get notificationsDenied =>
      'Сповіщення для цього застосунку вимкнено в налаштуваннях Android.';

  @override
  String runNotificationsRunning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count конвеєра виконуються',
      many: '$count конвеєрів виконуються',
      few: '$count конвеєри виконуються',
      one: '$count конвеєр виконується',
    );
    return '$_temp0';
  }
}
