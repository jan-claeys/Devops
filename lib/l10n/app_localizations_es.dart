// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get welcome => 'Bienvenido';

  @override
  String get settings => 'Ajustes';

  @override
  String get connectionSaved => 'Conexión guardada';

  @override
  String get onboardingIntro => 'Conéctate a Azure DevOps para empezar.';

  @override
  String get connection => 'Conexión';

  @override
  String get organization => 'Organización';

  @override
  String get organizationHint =>
      'p. ej. miempresa o https://dev.azure.com/miempresa';

  @override
  String get organizationRequired => 'Introduce tu organización';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'Ya hay un token guardado. Introdúcelo de nuevo para cambiarlo.';

  @override
  String get requiredScopes => 'Ámbitos necesarios';

  @override
  String get tokenRequired => 'Introduce tu token';

  @override
  String get tokenHelpTitle => '¿Cómo creo un token?';

  @override
  String get tokenHelpStep1 =>
      'En Azure DevOps, abre User settings → Personal access tokens y selecciona New Token.';

  @override
  String get tokenHelpStep2 =>
      'Elige tu organización y una fecha de caducidad.';

  @override
  String get tokenHelpStep3 =>
      'En Scopes, elige Custom defined y activa solo los ámbitos indicados arriba, cada uno con Read.';

  @override
  String get tokenHelpStep4 =>
      'Selecciona Create, copia el token y pégalo arriba. Solo se muestra una vez.';

  @override
  String get tokenHelpPermissions =>
      'Un token nunca tiene más permisos que tu cuenta: necesitas al menos acceso Stakeholder y permiso de lectura en los proyectos que quieras ver.';

  @override
  String get tokenHelpDocs => 'Documentación de Microsoft';

  @override
  String get connecting => 'Conectando…';

  @override
  String get connect => 'Conectar';

  @override
  String get appearance => 'Apariencia';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get colorAzureBlue => 'Azul Azure';

  @override
  String get colorSystem => 'Color del sistema';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Idioma del sistema';

  @override
  String get privacy => 'Privacidad';

  @override
  String get about => 'Acerca de';

  @override
  String appVersion(String version) {
    return 'Versión $version';
  }

  @override
  String madeBy(String name) {
    return 'Creado por $name';
  }

  @override
  String get sendErrorReports => 'Enviar informes de errores';

  @override
  String get sendErrorReportsHint =>
      'Envía datos anónimos sobre cierres inesperados y errores para poder corregirlos. Tu token nunca se envía.';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get selectTicketTitle => 'Selecciona un ticket';

  @override
  String get selectTicketMessage =>
      'Elige un ticket a la izquierda para ver sus detalles.';

  @override
  String get chooseProjects => 'Elegir proyectos';

  @override
  String get refresh => 'Actualizar';

  @override
  String get searchTicketsHint => 'Buscar por título, ID, etiqueta o persona';

  @override
  String get scopeAssignedToMe => 'Asignados a mí';

  @override
  String get scopeCreatedByMe => 'Creados por mí';

  @override
  String get scopeAll => 'Todos';

  @override
  String get openOnly => 'Solo abiertos';

  @override
  String get loadTicketsFailed => 'No se pudieron cargar los tickets';

  @override
  String get retry => 'Reintentar';

  @override
  String get noProjectsTitle => 'Ningún proyecto seleccionado';

  @override
  String get noProjectsMessage =>
      'Elige uno o más proyectos para ver los tickets.';

  @override
  String get noTicketsTitle => 'No hay tickets';

  @override
  String get noTicketsMessage =>
      'No hay tickets que coincidan con los filtros.';

  @override
  String ticketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tickets',
      one: '1 ticket',
    );
    return '$_temp0';
  }

  @override
  String get unassigned => 'Sin asignar';

  @override
  String get projects => 'Proyectos';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count proyectos',
      one: '1 proyecto',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Aplicar';

  @override
  String get searchProjectHint => 'Buscar proyecto';

  @override
  String get loadProjectsFailed => 'No se pudieron cargar los proyectos';

  @override
  String get browserOpenFailed => 'No se pudo abrir el navegador';

  @override
  String get openInDevOps => 'Abrir en DevOps';

  @override
  String get description => 'Descripción';

  @override
  String get reproSteps => 'Pasos para reproducir';

  @override
  String get acceptanceCriteria => 'Criterios de aceptación';

  @override
  String get symptom => 'Síntoma';

  @override
  String get systemInfo => 'Información del sistema';

  @override
  String get proposedFix => 'Corrección';

  @override
  String get emptyField => 'Sin contenido';

  @override
  String get assignedTo => 'Asignado a';

  @override
  String get priority => 'Prioridad';

  @override
  String get effort => 'Esfuerzo';

  @override
  String get originalEstimate => 'Estimación original';

  @override
  String get remainingWork => 'Trabajo restante';

  @override
  String get completedWork => 'Trabajo completado';

  @override
  String hours(String value) {
    return '$value h';
  }

  @override
  String get area => 'Área';

  @override
  String get iteration => 'Iteración';

  @override
  String get created => 'Creado';

  @override
  String createdOnBy(String date, String name) {
    return '$date por $name';
  }

  @override
  String get changed => 'Modificado';

  @override
  String get linkedItems => 'Elementos vinculados';

  @override
  String get parent => 'Primario';

  @override
  String get child => 'Secundario';

  @override
  String commentsCount(int count) {
    return 'Comentarios ($count)';
  }

  @override
  String get noComments => 'Aún no hay comentarios.';

  @override
  String get unknownPerson => 'Desconocido';

  @override
  String get justNow => 'ahora mismo';

  @override
  String minutesAgo(int count) {
    return 'hace $count min';
  }

  @override
  String hoursAgo(int count) {
    return 'hace $count h';
  }

  @override
  String daysAgo(int count) {
    return 'hace $count d';
  }

  @override
  String get errorUnauthorized =>
      'No autorizado. Comprueba tu Personal Access Token.';

  @override
  String get errorNotFound =>
      'No encontrado. Comprueba la organización o el proyecto.';

  @override
  String errorHttp(int code) {
    return 'Error $code de Azure DevOps';
  }

  @override
  String get errorUnexpectedResponse =>
      'Respuesta inesperada. Comprueba la organización y tu token.';

  @override
  String get widgetSetupRequired => 'Abre la app para configurarla';

  @override
  String get tickets => 'Tickets';

  @override
  String get pipelines => 'Pipelines';

  @override
  String get searchRunsHint => 'Buscar por pipeline, rama o persona';

  @override
  String get activeOnly => 'Solo activas';

  @override
  String get loadRunsFailed => 'No se pudieron cargar las ejecuciones';

  @override
  String get noRunsTitle => 'No hay ejecuciones de pipeline';

  @override
  String get noRunsMessage =>
      'No hay ejecuciones de pipeline que coincidan con los filtros.';

  @override
  String runCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ejecuciones',
      one: '1 ejecución',
    );
    return '$_temp0';
  }

  @override
  String get selectRunTitle => 'Selecciona una ejecución';

  @override
  String get selectRunMessage =>
      'Elige una ejecución a la izquierda para seguir su progreso.';

  @override
  String get runPending => 'En espera';

  @override
  String get runQueued => 'En cola';

  @override
  String get runRunning => 'En curso';

  @override
  String get runCancelling => 'Cancelando';

  @override
  String get runSucceeded => 'Correcta';

  @override
  String get runPartiallySucceeded => 'Parcialmente correcta';

  @override
  String get runFailed => 'Con errores';

  @override
  String get runCanceled => 'Cancelada';

  @override
  String get runSkipped => 'Omitida';

  @override
  String get progress => 'Progreso';

  @override
  String tasksProgress(int done, int total) {
    return '$done de $total tareas completadas';
  }

  @override
  String get branch => 'Rama';

  @override
  String get requestedBy => 'Solicitada por';

  @override
  String get queued => 'En cola desde';

  @override
  String get started => 'Iniciada';

  @override
  String get finished => 'Finalizada';

  @override
  String get duration => 'Duración';

  @override
  String get stages => 'Fases';

  @override
  String get noStagesYet => 'Las fases aparecen cuando empieza la ejecución.';

  @override
  String get runWaitingForApproval => 'Esperando aprobación';

  @override
  String get runNotDeployed => 'No implementada';

  @override
  String get builds => 'Compilaciones';

  @override
  String get releases => 'Versiones';

  @override
  String get loadReleasesFailed => 'No se pudieron cargar las versiones';

  @override
  String get releaseScopeHint =>
      'Las versiones necesitan el ámbito Release (Read) en tu token.';

  @override
  String get artifact => 'Artefacto';

  @override
  String waitingForApprovalBy(String names) {
    return 'Esperando la aprobación de $names';
  }

  @override
  String get pullRequests => 'Pull requests';

  @override
  String get searchPullRequestsHint => 'Buscar por título, ID, rama o persona';

  @override
  String get scopeReviewing => 'Para revisar';

  @override
  String get loadPullRequestsFailed =>
      'No se pudieron cargar las pull requests';

  @override
  String get codeScopeHint =>
      'Las pull requests necesitan el ámbito Code (Read) en tu token.';

  @override
  String get noPullRequestsTitle => 'No hay pull requests';

  @override
  String get noPullRequestsMessage =>
      'No hay pull requests que coincidan con los filtros.';

  @override
  String pullRequestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pull requests',
      one: '1 pull request',
    );
    return '$_temp0';
  }

  @override
  String get selectPullRequestTitle => 'Selecciona una pull request';

  @override
  String get selectPullRequestMessage =>
      'Elige una pull request a la izquierda para ver sus detalles.';

  @override
  String get prDraft => 'Borrador';

  @override
  String get prActive => 'Activa';

  @override
  String get prCompleted => 'Completada';

  @override
  String get prAbandoned => 'Abandonada';

  @override
  String get mergeConflicts => 'Conflictos de fusión';

  @override
  String get repository => 'Repositorio';

  @override
  String get closed => 'Cerrada';

  @override
  String get reviewers => 'Revisores';

  @override
  String get noReviewers => 'Sin revisores';

  @override
  String get requiredReviewer => 'Obligatorio';

  @override
  String get voteApproved => 'Aprobado';

  @override
  String get voteApprovedWithSuggestions => 'Aprobado con sugerencias';

  @override
  String get voteNone => 'Sin voto';

  @override
  String get voteWaitingForAuthor => 'Esperando al autor';

  @override
  String get voteRejected => 'Rechazado';

  @override
  String get threadResolved => 'Resuelto';

  @override
  String get runErrors => 'Errores';

  @override
  String get viewLog => 'Ver registro';

  @override
  String showAll(int count) {
    return 'Mostrar todo ($count)';
  }

  @override
  String get copyLog => 'Copiar registro';

  @override
  String get logCopied => 'Registro copiado';

  @override
  String get logEmpty => 'Este registro está vacío.';

  @override
  String get showMore => 'Mostrar más';

  @override
  String get showLess => 'Mostrar menos';

  @override
  String get onlyErrorsAndWarnings => 'Solo errores y advertencias';

  @override
  String get noLogIssues => 'No hay errores ni advertencias en este registro.';

  @override
  String get previousError => 'Error anterior';

  @override
  String get nextError => 'Error siguiente';

  @override
  String errorPosition(int current, int total) {
    return 'Error $current de $total';
  }

  @override
  String errorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count errores',
      one: '1 error',
    );
    return '$_temp0';
  }
}
