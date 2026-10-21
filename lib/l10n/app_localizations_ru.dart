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
  String get onboardingIntro =>
      'Подключитесь к Azure DevOps, чтобы видеть свои тикеты.';

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
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'Токен уже сохранён. Введите его снова, чтобы изменить.';

  @override
  String get tokenScopeHint =>
      'Нужные права: Work Items (Read) и Project and Team (Read)';

  @override
  String get tokenRequired => 'Введите токен';

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
  String get chooseProject => 'Выбрать проект';

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
  String get noProjectTitle => 'Проект не выбран';

  @override
  String get noProjectMessage => 'Выберите проект, чтобы увидеть тикеты.';

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
  String get chooseAProject => 'Выберите проект';

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
      'Нет доступа. Проверьте Personal Access Token.';

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
}
