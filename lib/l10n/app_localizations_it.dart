// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get welcome => 'Benvenuto';

  @override
  String get settings => 'Impostazioni';

  @override
  String get connectionSaved => 'Connessione salvata';

  @override
  String get onboardingIntro => 'Connettiti ad Azure DevOps per iniziare.';

  @override
  String get connection => 'Connessione';

  @override
  String get organization => 'Organizzazione';

  @override
  String get organizationHint =>
      'es. miaazienda o https://dev.azure.com/miaazienda';

  @override
  String get organizationRequired => 'Inserisci la tua organizzazione';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'È già salvato un token. Inseriscilo di nuovo per modificarlo.';

  @override
  String get requiredScopes => 'Ambiti richiesti';

  @override
  String get tokenRequired => 'Inserisci il tuo token';

  @override
  String get tokenHelpTitle => 'Come creo un token?';

  @override
  String get tokenHelpStep1 =>
      'In Azure DevOps apri User settings → Personal access tokens e seleziona New Token.';

  @override
  String get tokenHelpStep2 =>
      'Scegli la tua organizzazione e una data di scadenza.';

  @override
  String get tokenHelpStep3 =>
      'In Scopes scegli Custom defined e attiva solo gli ambiti indicati sopra, ciascuno con Read.';

  @override
  String get tokenHelpStep4 =>
      'Seleziona Create, copia il token e incollalo qui sopra. Viene mostrato una sola volta.';

  @override
  String get tokenHelpPermissions =>
      'Un token non ha mai più diritti del tuo account: ti serve almeno l\'accesso Stakeholder e l\'accesso in lettura ai progetti che vuoi vedere.';

  @override
  String get tokenHelpDocs => 'Documentazione Microsoft';

  @override
  String get connecting => 'Connessione…';

  @override
  String get connect => 'Connetti';

  @override
  String get appearance => 'Aspetto';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeDark => 'Scuro';

  @override
  String get colorAzureBlue => 'Blu Azure';

  @override
  String get colorSystem => 'Colore di sistema';

  @override
  String get language => 'Lingua';

  @override
  String get languageSystem => 'Lingua di sistema';

  @override
  String get privacy => 'Privacy';

  @override
  String get about => 'Informazioni';

  @override
  String appVersion(String version) {
    return 'Versione $version';
  }

  @override
  String madeBy(String name) {
    return 'Creato da $name';
  }

  @override
  String get sendErrorReports => 'Invia segnalazioni di errore';

  @override
  String get sendErrorReportsHint =>
      'Invia dati anonimi su arresti anomali ed errori per poterli correggere. Il tuo token non viene mai inviato.';

  @override
  String get signOut => 'Esci';

  @override
  String get selectTicketTitle => 'Seleziona un ticket';

  @override
  String get selectTicketMessage =>
      'Scegli un ticket a sinistra per vederne i dettagli.';

  @override
  String get chooseProjects => 'Scegli progetti';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get searchTicketsHint => 'Cerca per titolo, ID, tag o persona';

  @override
  String get scopeAssignedToMe => 'Assegnati a me';

  @override
  String get scopeCreatedByMe => 'Creati da me';

  @override
  String get scopeAll => 'Tutti';

  @override
  String get openOnly => 'Solo aperti';

  @override
  String get loadTicketsFailed => 'Impossibile caricare i ticket';

  @override
  String get retry => 'Riprova';

  @override
  String get noProjectsTitle => 'Nessun progetto selezionato';

  @override
  String get noProjectsMessage =>
      'Scegli uno o più progetti per vedere i ticket.';

  @override
  String get noTicketsTitle => 'Nessun ticket';

  @override
  String get noTicketsMessage => 'Nessun ticket corrisponde ai filtri.';

  @override
  String ticketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ticket',
      one: '1 ticket',
    );
    return '$_temp0';
  }

  @override
  String get unassigned => 'Non assegnato';

  @override
  String get projects => 'Progetti';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count progetti',
      one: '1 progetto',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Applica';

  @override
  String get searchProjectHint => 'Cerca progetto';

  @override
  String get loadProjectsFailed => 'Impossibile caricare i progetti';

  @override
  String get browserOpenFailed => 'Impossibile aprire il browser';

  @override
  String get openInDevOps => 'Apri in DevOps';

  @override
  String get description => 'Descrizione';

  @override
  String get reproSteps => 'Passaggi per riprodurre';

  @override
  String get acceptanceCriteria => 'Criteri di accettazione';

  @override
  String get symptom => 'Sintomo';

  @override
  String get systemInfo => 'Informazioni di sistema';

  @override
  String get proposedFix => 'Correzione';

  @override
  String get emptyField => 'Nessun contenuto';

  @override
  String get assignedTo => 'Assegnato a';

  @override
  String get priority => 'Priorità';

  @override
  String get effort => 'Impegno';

  @override
  String get originalEstimate => 'Stima originale';

  @override
  String get remainingWork => 'Lavoro rimanente';

  @override
  String get completedWork => 'Lavoro completato';

  @override
  String hours(String value) {
    return '$value h';
  }

  @override
  String get area => 'Area';

  @override
  String get iteration => 'Iterazione';

  @override
  String get created => 'Creato';

  @override
  String createdOnBy(String date, String name) {
    return '$date da $name';
  }

  @override
  String get changed => 'Modificato';

  @override
  String get linkedItems => 'Elementi collegati';

  @override
  String get parent => 'Padre';

  @override
  String get child => 'Figlio';

  @override
  String commentsCount(int count) {
    return 'Commenti ($count)';
  }

  @override
  String get noComments => 'Ancora nessun commento.';

  @override
  String get unknownPerson => 'Sconosciuto';

  @override
  String get justNow => 'adesso';

  @override
  String minutesAgo(int count) {
    return '$count min fa';
  }

  @override
  String hoursAgo(int count) {
    return '$count h fa';
  }

  @override
  String daysAgo(int count) {
    return '$count g fa';
  }

  @override
  String get errorUnauthorized =>
      'Non autorizzato. Controlla il tuo Personal Access Token.';

  @override
  String get errorNotFound =>
      'Non trovato. Controlla l\'organizzazione o il progetto.';

  @override
  String errorHttp(int code) {
    return 'Errore $code da Azure DevOps';
  }

  @override
  String get errorUnexpectedResponse =>
      'Risposta inattesa. Controlla l\'organizzazione e il tuo token.';

  @override
  String get widgetSetupRequired => 'Apri l\'app per configurarla';

  @override
  String get tickets => 'Ticket';

  @override
  String get pipelines => 'Pipeline';

  @override
  String get searchRunsHint => 'Cerca per pipeline, branch o persona';

  @override
  String get activeOnly => 'Solo attive';

  @override
  String get loadRunsFailed => 'Impossibile caricare le esecuzioni';

  @override
  String get noRunsTitle => 'Nessuna esecuzione di pipeline';

  @override
  String get noRunsMessage =>
      'Nessuna esecuzione di pipeline corrisponde ai filtri.';

  @override
  String runCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count esecuzioni',
      one: '1 esecuzione',
    );
    return '$_temp0';
  }

  @override
  String get selectRunTitle => 'Seleziona un’esecuzione';

  @override
  String get selectRunMessage =>
      'Scegli un’esecuzione a sinistra per seguirne l’avanzamento.';

  @override
  String get runPending => 'In attesa';

  @override
  String get runQueued => 'In coda';

  @override
  String get runRunning => 'In corso';

  @override
  String get runCancelling => 'Annullamento';

  @override
  String get runSucceeded => 'Riuscita';

  @override
  String get runPartiallySucceeded => 'Parzialmente riuscita';

  @override
  String get runFailed => 'Non riuscita';

  @override
  String get runCanceled => 'Annullata';

  @override
  String get runSkipped => 'Saltata';

  @override
  String get progress => 'Avanzamento';

  @override
  String tasksProgress(int done, int total) {
    return '$done di $total attività completate';
  }

  @override
  String get branch => 'Branch';

  @override
  String get requestedBy => 'Richiesta da';

  @override
  String get queued => 'In coda dal';

  @override
  String get started => 'Avviata';

  @override
  String get finished => 'Terminata';

  @override
  String get duration => 'Durata';

  @override
  String get stages => 'Fasi';

  @override
  String get noStagesYet => 'Le fasi compaiono quando l’esecuzione inizia.';

  @override
  String get runWaitingForApproval => 'In attesa di approvazione';

  @override
  String get runNotDeployed => 'Non distribuita';

  @override
  String get builds => 'Build';

  @override
  String get releases => 'Release';

  @override
  String get loadReleasesFailed => 'Impossibile caricare le release';

  @override
  String get releaseScopeHint =>
      'Le release richiedono l’ambito Release (Read) nel token.';

  @override
  String get artifact => 'Artefatto';

  @override
  String waitingForApprovalBy(String names) {
    return 'In attesa dell’approvazione di $names';
  }

  @override
  String get pullRequests => 'Pull request';

  @override
  String get searchPullRequestsHint => 'Cerca per titolo, ID, branch o persona';

  @override
  String get scopeReviewing => 'Da revisionare';

  @override
  String get scopeMine => 'Mie';

  @override
  String get loadPullRequestsFailed => 'Impossibile caricare le pull request';

  @override
  String get codeScopeHint =>
      'Le pull request richiedono l’ambito Code (Read) nel token.';

  @override
  String get noPullRequestsTitle => 'Nessuna pull request';

  @override
  String get noPullRequestsMessage =>
      'Nessuna pull request corrisponde ai filtri.';

  @override
  String pullRequestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pull request',
      one: '1 pull request',
    );
    return '$_temp0';
  }

  @override
  String get selectPullRequestTitle => 'Seleziona una pull request';

  @override
  String get selectPullRequestMessage =>
      'Scegli una pull request a sinistra per vederne i dettagli.';

  @override
  String get prDraft => 'Bozza';

  @override
  String get prActive => 'Attiva';

  @override
  String get prCompleted => 'Completata';

  @override
  String get prAbandoned => 'Abbandonata';

  @override
  String get mergeConflicts => 'Conflitti di merge';

  @override
  String get repository => 'Repository';

  @override
  String get closed => 'Chiusa';

  @override
  String get reviewers => 'Revisori';

  @override
  String get noReviewers => 'Nessun revisore';

  @override
  String get requiredReviewer => 'Obbligatorio';

  @override
  String get voteApproved => 'Approvato';

  @override
  String get voteApprovedWithSuggestions => 'Approvato con suggerimenti';

  @override
  String get voteNone => 'Nessun voto';

  @override
  String get voteWaitingForAuthor => 'In attesa dell’autore';

  @override
  String get voteRejected => 'Rifiutato';

  @override
  String get threadResolved => 'Risolto';

  @override
  String get runErrors => 'Errori';

  @override
  String get viewLog => 'Visualizza log';

  @override
  String showAll(int count) {
    return 'Mostra tutti ($count)';
  }

  @override
  String get copyLog => 'Copia log';

  @override
  String get logCopied => 'Log copiato';

  @override
  String get logEmpty => 'Questo log è vuoto.';

  @override
  String get showMore => 'Mostra di più';

  @override
  String get showLess => 'Mostra meno';

  @override
  String get onlyErrorsAndWarnings => 'Solo errori e avvisi';

  @override
  String get noLogIssues => 'Nessun errore o avviso in questo log.';

  @override
  String get previousError => 'Errore precedente';

  @override
  String get nextError => 'Errore successivo';

  @override
  String errorPosition(int current, int total) {
    return 'Errore $current di $total';
  }

  @override
  String errorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count errori',
      one: '1 errore',
    );
    return '$_temp0';
  }

  @override
  String get dashboard => 'Panoramica';

  @override
  String refreshFailed(String time) {
    return 'Impossibile aggiornare. Dati di $time.';
  }

  @override
  String get loadDashboardFailed => 'Impossibile caricare la panoramica';

  @override
  String get myPullRequests => 'Le mie pull request';

  @override
  String get myTickets => 'I miei ticket aperti';

  @override
  String get waitingForYourReview => 'In attesa della tua revisione';

  @override
  String get waitingForYou => 'In attesa di te';

  @override
  String get nothingWaiting => 'Al momento non c’è niente che ti aspetta.';

  @override
  String get readyToComplete => 'Approvata, pronta per il completamento';

  @override
  String get yourApproval => 'In attesa della tua approvazione';

  @override
  String get myRuns => 'Le mie esecuzioni';

  @override
  String get noRecentRuns => 'Non hai avviato esecuzioni di recente.';

  @override
  String failingOnMain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pipeline non riescono sul branch principale',
      one: '1 pipeline non riesce sul branch principale',
    );
    return '$_temp0';
  }

  @override
  String noChangesFor(int count) {
    return 'Nessuna modifica da $count g';
  }
}
