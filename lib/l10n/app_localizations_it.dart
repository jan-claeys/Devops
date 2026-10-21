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
  String get onboardingIntro =>
      'Connettiti ad Azure DevOps per vedere i tuoi ticket.';

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
  String get tokenScopeHint =>
      'Ambito richiesto: Work Items (Read) e Project and Team (Read)';

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
      'In Scopes scegli Custom defined e attiva solo Work Items: Read e Project and Team: Read.';

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
  String get chooseProject => 'Scegli progetto';

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
  String get noProjectTitle => 'Nessun progetto selezionato';

  @override
  String get noProjectMessage => 'Scegli un progetto per vedere i ticket.';

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
  String get chooseAProject => 'Scegli un progetto';

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
}
