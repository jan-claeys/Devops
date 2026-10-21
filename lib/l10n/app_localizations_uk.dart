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
  String get onboardingIntro =>
      'Підключіться до Azure DevOps, щоб бачити свої тікети.';

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
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'Токен уже збережено. Введіть його знову, щоб змінити.';

  @override
  String get tokenScopeHint =>
      'Потрібні права: Work Items (Read) і Project and Team (Read)';

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
      'У розділі Scopes виберіть Custom defined і ввімкніть лише Work Items: Read і Project and Team: Read.';

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
      'Немає доступу. Перевірте Personal Access Token.';

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
}
