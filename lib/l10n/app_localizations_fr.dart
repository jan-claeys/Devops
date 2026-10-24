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
  String get onboardingIntro => 'Connectez-vous à Azure DevOps pour commencer.';

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
  String get organizationInsecure =>
      'Utilisez une adresse https:// pour que votre jeton ne soit pas envoyé en clair';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'Un jeton est déjà enregistré. Saisissez-le à nouveau pour le modifier.';

  @override
  String get requiredScopes => 'Portées requises';

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
      'Sous Scopes, choisissez Custom defined et activez uniquement les portées indiquées ci-dessus, chacune avec l’autorisation affichée à côté.';

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
  String attachmentsCount(int count) {
    return 'Pièces jointes ($count)';
  }

  @override
  String get openFile => 'Ouvrir le fichier';

  @override
  String get download => 'Télécharger';

  @override
  String get downloadLargeTitle => 'Télécharger un fichier volumineux ?';

  @override
  String downloadLargeBody(String name, String size) {
    return '$name fait $size. Le téléchargement peut prendre du temps et consommer des données mobiles.';
  }

  @override
  String get noAppForFile =>
      'Aucune application de cet appareil ne peut ouvrir ce fichier.';

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
      'Votre Personal Access Token est invalide ou a expiré. Créez-en un nouveau dans les paramètres.';

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

  @override
  String get runWaitingForApproval => 'En attente d’approbation';

  @override
  String get runNotDeployed => 'Non déployée';

  @override
  String get builds => 'Builds';

  @override
  String get releases => 'Releases';

  @override
  String get loadReleasesFailed => 'Impossible de charger les releases';

  @override
  String get releaseScopeHint =>
      'Les releases nécessitent la portée Release (Read, write, & execute) sur votre jeton.';

  @override
  String get artifact => 'Artefact';

  @override
  String waitingForApprovalBy(String names) {
    return 'En attente d’approbation de $names';
  }

  @override
  String get approvals => 'Approbations';

  @override
  String approveStage(String stage) {
    return 'Approuver $stage ?';
  }

  @override
  String rejectStage(String stage) {
    return 'Rejeter $stage ?';
  }

  @override
  String get approvalCommentHint => 'Commentaire (facultatif)';

  @override
  String get stageApproved => 'Étape approuvée';

  @override
  String get stageRejected => 'Étape rejetée';

  @override
  String get buildScopeHint =>
      'Agir sur les exécutions de pipeline nécessite la portée Build (Read & execute) sur votre jeton.';

  @override
  String get pullRequests => 'Pull requests';

  @override
  String get searchPullRequestsHint =>
      'Rechercher par titre, ID, branche ou personne';

  @override
  String get scopeReviewing => 'À relire';

  @override
  String get loadPullRequestsFailed =>
      'Impossible de charger les pull requests';

  @override
  String get codeScopeHint =>
      'Les pull requests nécessitent la portée Code (Read & write) sur votre jeton.';

  @override
  String get noPullRequestsTitle => 'Aucune pull request';

  @override
  String get noPullRequestsMessage =>
      'Aucune pull request ne correspond aux filtres.';

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
  String get selectPullRequestTitle => 'Sélectionnez une pull request';

  @override
  String get selectPullRequestMessage =>
      'Choisissez une pull request à gauche pour voir ses détails.';

  @override
  String get prDraft => 'Brouillon';

  @override
  String get prActive => 'Active';

  @override
  String get prCompleted => 'Terminée';

  @override
  String get prAbandoned => 'Abandonnée';

  @override
  String get mergeConflicts => 'Conflits de fusion';

  @override
  String get repository => 'Dépôt';

  @override
  String get closed => 'Fermée';

  @override
  String get reviewers => 'Relecteurs';

  @override
  String get noReviewers => 'Aucun relecteur';

  @override
  String get requiredReviewer => 'Obligatoire';

  @override
  String get voteApproved => 'Approuvé';

  @override
  String get voteApprovedWithSuggestions => 'Approuvé avec suggestions';

  @override
  String get voteNone => 'Pas de vote';

  @override
  String get voteWaitingForAuthor => 'En attente de l’auteur';

  @override
  String get voteRejected => 'Refusé';

  @override
  String get threadResolved => 'Résolu';

  @override
  String get voteApprove => 'Approuver';

  @override
  String get voteApproveWithSuggestions => 'Approuver avec suggestions';

  @override
  String get voteWaitForAuthor => 'Attendre l’auteur';

  @override
  String get voteReject => 'Rejeter';

  @override
  String get voteReset => 'Réinitialiser le vote';

  @override
  String get otherVotes => 'Autres votes';

  @override
  String get rejectConfirmTitle => 'Rejeter cette pull request ?';

  @override
  String get rejectConfirmBody =>
      'La pull request ne peut pas être terminée tant que votre vote est Rejeté.';

  @override
  String get voteSaved => 'Vote enregistré';

  @override
  String get cancel => 'Annuler';

  @override
  String get actionDenied =>
      'Azure DevOps n’a pas autorisé cette action. Vérifiez que votre jeton a la bonne portée et que votre compte a l’autorisation.';

  @override
  String get writeComment => 'Écrire un commentaire…';

  @override
  String get send => 'Envoyer';

  @override
  String get reply => 'Répondre';

  @override
  String get writeReply => 'Écrire une réponse…';

  @override
  String get resolveThread => 'Résoudre';

  @override
  String get reactivateThread => 'Réactiver';

  @override
  String get workItemScopeHint =>
      'Commenter des tickets nécessite la portée Work Items (Read & write) sur votre jeton.';

  @override
  String get runErrors => 'Erreurs';

  @override
  String get viewLog => 'Voir le journal';

  @override
  String showAll(int count) {
    return 'Tout afficher ($count)';
  }

  @override
  String get copyLog => 'Copier le journal';

  @override
  String get logCopied => 'Journal copié';

  @override
  String get logEmpty => 'Ce journal est vide.';

  @override
  String get showMore => 'Afficher plus';

  @override
  String get showLess => 'Afficher moins';

  @override
  String get onlyErrorsAndWarnings => 'Erreurs et avertissements uniquement';

  @override
  String get noLogIssues =>
      'Aucune erreur ni aucun avertissement dans ce journal.';

  @override
  String get previousError => 'Erreur précédente';

  @override
  String get nextError => 'Erreur suivante';

  @override
  String errorPosition(int current, int total) {
    return 'Erreur $current sur $total';
  }

  @override
  String errorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count erreurs',
      one: '1 erreur',
    );
    return '$_temp0';
  }

  @override
  String get dashboard => 'Vue d’ensemble';

  @override
  String refreshFailed(String time) {
    return 'Actualisation impossible. Données : $time.';
  }

  @override
  String get loadDashboardFailed => 'Impossible de charger la vue d’ensemble';

  @override
  String get myPullRequests => 'Mes pull requests';

  @override
  String get myTickets => 'Mes tickets ouverts';

  @override
  String get waitingForYourReview => 'En attente de votre revue';

  @override
  String get waitingForYou => 'En attente de vous';

  @override
  String get nothingWaiting => 'Rien ne vous attend pour le moment.';

  @override
  String get readyToComplete => 'Approuvée, prête à être terminée';

  @override
  String get yourApproval => 'En attente de votre approbation';

  @override
  String get myRuns => 'Mes exécutions';

  @override
  String get noRecentRuns => 'Vous n’avez lancé aucune exécution récemment.';

  @override
  String failingOnMain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pipelines échouent sur la branche principale',
      one: '1 pipeline échoue sur la branche principale',
    );
    return '$_temp0';
  }

  @override
  String noChangesFor(int count) {
    return 'Inchangé depuis $count j';
  }

  @override
  String get linkNotSupported =>
      'Ce lien ne peut pas être ouvert dans l\'application.';

  @override
  String get linkOtherOrganization =>
      'Ce lien appartient à une autre organisation que celle à laquelle vous êtes connecté.';

  @override
  String get notifications => 'Notifications';

  @override
  String get runNotificationsHint =>
      'Affiche la progression des pipelines en cours tant que l\'app est ouverte, et continue de les suivre en arrière-plan jusqu\'à leur fin.';

  @override
  String get runNotificationsOff => 'Désactivées';

  @override
  String get runNotificationsMine => 'Mes exécutions';

  @override
  String get runNotificationsAll => 'Toutes les exécutions';

  @override
  String get runNotificationChannel => 'Progression des pipelines';

  @override
  String get notificationsDenied =>
      'Les notifications sont désactivées pour cette app dans les paramètres Android.';

  @override
  String runNotificationsRunning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pipelines en cours',
      one: '1 pipeline en cours',
    );
    return '$_temp0';
  }
}
