// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get welcome => 'Bienvenue';

  @override
  String get settings => 'Paramètres';

  @override
  String get connectionSaved => 'Connexion enregistrée';

  @override
  String get onboardingIntro =>
      'Connectez-vous à Azure DevOps pour voir vos tickets.';

  @override
  String get connection => 'Connexion';

  @override
  String get organization => 'Organisation';

  @override
  String get organizationHint =>
      'ex. monentreprise ou https://dev.azure.com/monentreprise';

  @override
  String get organizationRequired => 'Saisissez votre organisation';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'Un jeton est déjà enregistré. Saisissez-le à nouveau pour le modifier.';

  @override
  String get tokenScopeHint =>
      'Portée requise : Work Items (Read), Build (Read) et Project and Team (Read)';

  @override
  String get tokenRequired => 'Saisissez votre jeton';

  @override
  String get tokenHelpTitle => 'Comment créer un token ?';

  @override
  String get tokenHelpStep1 =>
      'Dans Azure DevOps, ouvrez User settings → Personal access tokens et sélectionnez New Token.';

  @override
  String get tokenHelpStep2 =>
      'Choisissez votre organisation et une date d\'expiration.';

  @override
  String get tokenHelpStep3 =>
      'Sous Scopes, choisissez Custom defined et activez uniquement Work Items: Read, Build: Read et Project and Team: Read.';

  @override
  String get tokenHelpStep4 =>
      'Sélectionnez Create, copiez le token et collez-le ci-dessus. Il n\'est affiché qu\'une seule fois.';

  @override
  String get tokenHelpPermissions =>
      'Un token n\'a jamais plus de droits que votre compte : il vous faut au moins un accès Stakeholder et un accès en lecture aux projets à afficher.';

  @override
  String get tokenHelpDocs => 'Documentation Microsoft';

  @override
  String get connecting => 'Connexion…';

  @override
  String get connect => 'Se connecter';

  @override
  String get appearance => 'Apparence';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeDark => 'Sombre';

  @override
  String get colorAzureBlue => 'Bleu Azure';

  @override
  String get colorSystem => 'Couleur système';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get about => 'À propos';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String madeBy(String name) {
    return 'Créé par $name';
  }

  @override
  String get sendErrorReports => 'Envoyer les rapports d\'erreur';

  @override
  String get sendErrorReportsHint =>
      'Envoie des informations anonymes sur les plantages et les erreurs pour corriger les bugs. Votre jeton n\'est jamais envoyé.';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get selectTicketTitle => 'Sélectionnez un ticket';

  @override
  String get selectTicketMessage =>
      'Choisissez un ticket à gauche pour voir ses détails.';

  @override
  String get chooseProjects => 'Choisir des projets';

  @override
  String get refresh => 'Actualiser';

  @override
  String get searchTicketsHint => 'Rechercher par titre, ID, tag ou personne';

  @override
  String get scopeAssignedToMe => 'À moi';

  @override
  String get scopeCreatedByMe => 'Par moi';

  @override
  String get scopeAll => 'Tous';

  @override
  String get openOnly => 'Ouverts uniquement';

  @override
  String get loadTicketsFailed => 'Impossible de charger les tickets';

  @override
  String get retry => 'Réessayer';

  @override
  String get noProjectsTitle => 'Aucun projet sélectionné';

  @override
  String get noProjectsMessage =>
      'Choisissez un ou plusieurs projets pour voir les tickets.';

  @override
  String get noTicketsTitle => 'Aucun ticket';

  @override
  String get noTicketsMessage => 'Aucun ticket ne correspond aux filtres.';

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
  String get unassigned => 'Non attribué';

  @override
  String get projects => 'Projets';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projets',
      one: '1 projet',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Appliquer';

  @override
  String get searchProjectHint => 'Rechercher un projet';

  @override
  String get loadProjectsFailed => 'Impossible de charger les projets';

  @override
  String get browserOpenFailed => 'Impossible d\'ouvrir le navigateur';

  @override
  String get openInDevOps => 'Ouvrir dans DevOps';

  @override
  String get description => 'Description';

  @override
  String get reproSteps => 'Étapes de reproduction';

  @override
  String get acceptanceCriteria => 'Critères d\'acceptation';

  @override
  String get symptom => 'Symptôme';

  @override
  String get systemInfo => 'Infos système';

  @override
  String get proposedFix => 'Correctif';

  @override
  String get emptyField => 'Aucun contenu';

  @override
  String get assignedTo => 'Attribué à';

  @override
  String get priority => 'Priorité';

  @override
  String get effort => 'Effort';

  @override
  String get originalEstimate => 'Estimation initiale';

  @override
  String get remainingWork => 'Travail restant';

  @override
  String get completedWork => 'Travail terminé';

  @override
  String hours(String value) {
    return '$value h';
  }

  @override
  String get area => 'Zone';

  @override
  String get iteration => 'Itération';

  @override
  String get created => 'Créé';

  @override
  String createdOnBy(String date, String name) {
    return '$date par $name';
  }

  @override
  String get changed => 'Modifié';

  @override
  String get linkedItems => 'Éléments liés';

  @override
  String get parent => 'Parent';

  @override
  String get child => 'Enfant';

  @override
  String commentsCount(int count) {
    return 'Commentaires ($count)';
  }

  @override
  String get noComments => 'Aucun commentaire pour l\'instant.';

  @override
  String get unknownPerson => 'Inconnu';

  @override
  String get justNow => 'à l\'instant';

  @override
  String minutesAgo(int count) {
    return 'il y a $count min';
  }

  @override
  String hoursAgo(int count) {
    return 'il y a $count h';
  }

  @override
  String daysAgo(int count) {
    return 'il y a $count j';
  }

  @override
  String get errorUnauthorized =>
      'Non autorisé. Vérifiez votre Personal Access Token.';

  @override
  String get errorNotFound =>
      'Introuvable. Vérifiez l\'organisation ou le projet.';

  @override
  String errorHttp(int code) {
    return 'Erreur $code d\'Azure DevOps';
  }

  @override
  String get errorUnexpectedResponse =>
      'Réponse inattendue. Vérifiez l\'organisation et votre jeton.';

  @override
  String get widgetSetupRequired => 'Ouvrez l\'application pour la configurer';

  @override
  String get tickets => 'Tickets';

  @override
  String get pipelines => 'Pipelines';

  @override
  String get searchRunsHint => 'Rechercher par pipeline, branche ou personne';

  @override
  String get activeOnly => 'Actives uniquement';

  @override
  String get loadRunsFailed => 'Impossible de charger les exécutions';

  @override
  String get noRunsTitle => 'Aucune exécution de pipeline';

  @override
  String get noRunsMessage =>
      'Aucune exécution de pipeline ne correspond aux filtres.';

  @override
  String runCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exécutions',
      one: '1 exécution',
    );
    return '$_temp0';
  }

  @override
  String get selectRunTitle => 'Sélectionnez une exécution';

  @override
  String get selectRunMessage =>
      'Choisissez une exécution à gauche pour suivre sa progression.';

  @override
  String get runPending => 'En attente';

  @override
  String get runQueued => 'En file d’attente';

  @override
  String get runRunning => 'En cours';

  @override
  String get runCancelling => 'Annulation en cours';

  @override
  String get runSucceeded => 'Réussie';

  @override
  String get runPartiallySucceeded => 'Partiellement réussie';

  @override
  String get runFailed => 'Échouée';

  @override
  String get runCanceled => 'Annulée';

  @override
  String get runSkipped => 'Ignorée';

  @override
  String get progress => 'Progression';

  @override
  String tasksProgress(int done, int total) {
    return '$done tâches terminées sur $total';
  }

  @override
  String get branch => 'Branche';

  @override
  String get requestedBy => 'Demandée par';

  @override
  String get queued => 'Mise en file';

  @override
  String get started => 'Démarrée';

  @override
  String get finished => 'Terminée';

  @override
  String get duration => 'Durée';

  @override
  String get stages => 'Étapes';

  @override
  String get noStagesYet =>
      'Les étapes apparaissent dès que l’exécution démarre.';
}
