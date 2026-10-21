// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get welcome => 'Bem-vindo';

  @override
  String get settings => 'Configurações';

  @override
  String get connectionSaved => 'Conexão salva';

  @override
  String get onboardingIntro => 'Conecte-se ao Azure DevOps para começar.';

  @override
  String get connection => 'Conexão';

  @override
  String get organization => 'Organização';

  @override
  String get organizationHint =>
      'ex. minhaempresa ou https://dev.azure.com/minhaempresa';

  @override
  String get organizationRequired => 'Informe sua organização';

  @override
  String get personalAccessToken => 'Personal Access Token';

  @override
  String get tokenAlreadyStored =>
      'Já existe um token salvo. Informe-o novamente para alterá-lo.';

  @override
  String get requiredScopes => 'Escopos necessários';

  @override
  String get tokenRequired => 'Informe seu token';

  @override
  String get tokenHelpTitle => 'Como crio um token?';

  @override
  String get tokenHelpStep1 =>
      'No Azure DevOps, abra User settings → Personal access tokens e selecione New Token.';

  @override
  String get tokenHelpStep2 =>
      'Escolha sua organização e uma data de expiração.';

  @override
  String get tokenHelpStep3 =>
      'Em Scopes, escolha Custom defined e ative apenas os escopos indicados acima, cada um com Read.';

  @override
  String get tokenHelpStep4 =>
      'Selecione Create, copie o token e cole-o acima. Ele é exibido apenas uma vez.';

  @override
  String get tokenHelpPermissions =>
      'Um token nunca tem mais permissões que sua conta: você precisa de pelo menos acesso Stakeholder e permissão de leitura nos projetos que deseja ver.';

  @override
  String get tokenHelpDocs => 'Documentação da Microsoft';

  @override
  String get connecting => 'Conectando…';

  @override
  String get connect => 'Conectar';

  @override
  String get appearance => 'Aparência';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeDark => 'Escuro';

  @override
  String get colorAzureBlue => 'Azul Azure';

  @override
  String get colorSystem => 'Cor do sistema';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Idioma do sistema';

  @override
  String get privacy => 'Privacidade';

  @override
  String get about => 'Sobre';

  @override
  String appVersion(String version) {
    return 'Versão $version';
  }

  @override
  String madeBy(String name) {
    return 'Criado por $name';
  }

  @override
  String get sendErrorReports => 'Enviar relatórios de erros';

  @override
  String get sendErrorReportsHint =>
      'Envia dados anônimos sobre falhas e erros para que possam ser corrigidos. Seu token nunca é enviado.';

  @override
  String get signOut => 'Sair';

  @override
  String get selectTicketTitle => 'Selecione um ticket';

  @override
  String get selectTicketMessage =>
      'Escolha um ticket à esquerda para ver os detalhes.';

  @override
  String get chooseProjects => 'Escolher projetos';

  @override
  String get refresh => 'Atualizar';

  @override
  String get searchTicketsHint => 'Pesquisar por título, ID, tag ou pessoa';

  @override
  String get scopeAssignedToMe => 'Atribuídos a mim';

  @override
  String get scopeCreatedByMe => 'Criados por mim';

  @override
  String get scopeAll => 'Todos';

  @override
  String get openOnly => 'Somente abertos';

  @override
  String get loadTicketsFailed => 'Não foi possível carregar os tickets';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get noProjectsTitle => 'Nenhum projeto selecionado';

  @override
  String get noProjectsMessage =>
      'Escolha um ou mais projetos para ver os tickets.';

  @override
  String get noTicketsTitle => 'Nenhum ticket';

  @override
  String get noTicketsMessage => 'Nenhum ticket corresponde aos filtros.';

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
  String get unassigned => 'Não atribuído';

  @override
  String get projects => 'Projetos';

  @override
  String projectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projetos',
      one: '1 projeto',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Aplicar';

  @override
  String get searchProjectHint => 'Pesquisar projeto';

  @override
  String get loadProjectsFailed => 'Não foi possível carregar os projetos';

  @override
  String get browserOpenFailed => 'Não foi possível abrir o navegador';

  @override
  String get openInDevOps => 'Abrir no DevOps';

  @override
  String get description => 'Descrição';

  @override
  String get reproSteps => 'Passos para reproduzir';

  @override
  String get acceptanceCriteria => 'Critérios de aceitação';

  @override
  String get symptom => 'Sintoma';

  @override
  String get systemInfo => 'Informações do sistema';

  @override
  String get proposedFix => 'Correção';

  @override
  String get emptyField => 'Sem conteúdo';

  @override
  String get assignedTo => 'Atribuído a';

  @override
  String get priority => 'Prioridade';

  @override
  String get effort => 'Esforço';

  @override
  String get originalEstimate => 'Estimativa original';

  @override
  String get remainingWork => 'Trabalho restante';

  @override
  String get completedWork => 'Trabalho concluído';

  @override
  String hours(String value) {
    return '$value h';
  }

  @override
  String get area => 'Área';

  @override
  String get iteration => 'Iteração';

  @override
  String get created => 'Criado';

  @override
  String createdOnBy(String date, String name) {
    return '$date por $name';
  }

  @override
  String get changed => 'Alterado';

  @override
  String get linkedItems => 'Itens vinculados';

  @override
  String get parent => 'Pai';

  @override
  String get child => 'Filho';

  @override
  String commentsCount(int count) {
    return 'Comentários ($count)';
  }

  @override
  String get noComments => 'Nenhum comentário ainda.';

  @override
  String get unknownPerson => 'Desconhecido';

  @override
  String get justNow => 'agora mesmo';

  @override
  String minutesAgo(int count) {
    return 'há $count min';
  }

  @override
  String hoursAgo(int count) {
    return 'há $count h';
  }

  @override
  String daysAgo(int count) {
    return 'há $count d';
  }

  @override
  String get errorUnauthorized =>
      'Não autorizado. Verifique seu Personal Access Token.';

  @override
  String get errorNotFound =>
      'Não encontrado. Verifique a organização ou o projeto.';

  @override
  String errorHttp(int code) {
    return 'Erro $code do Azure DevOps';
  }

  @override
  String get errorUnexpectedResponse =>
      'Resposta inesperada. Verifique a organização e seu token.';

  @override
  String get widgetSetupRequired => 'Abra o app para configurar';

  @override
  String get tickets => 'Tickets';

  @override
  String get pipelines => 'Pipelines';

  @override
  String get searchRunsHint => 'Pesquisar por pipeline, branch ou pessoa';

  @override
  String get activeOnly => 'Somente ativas';

  @override
  String get loadRunsFailed => 'Não foi possível carregar as execuções';

  @override
  String get noRunsTitle => 'Nenhuma execução de pipeline';

  @override
  String get noRunsMessage =>
      'Não há execuções de pipeline que correspondam aos filtros.';

  @override
  String runCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count execuções',
      one: '1 execução',
    );
    return '$_temp0';
  }

  @override
  String get selectRunTitle => 'Selecione uma execução';

  @override
  String get selectRunMessage =>
      'Escolha uma execução à esquerda para acompanhar o progresso.';

  @override
  String get runPending => 'Aguardando';

  @override
  String get runQueued => 'Na fila';

  @override
  String get runRunning => 'Em execução';

  @override
  String get runCancelling => 'Cancelando';

  @override
  String get runSucceeded => 'Concluída';

  @override
  String get runPartiallySucceeded => 'Parcialmente concluída';

  @override
  String get runFailed => 'Falhou';

  @override
  String get runCanceled => 'Cancelada';

  @override
  String get runSkipped => 'Ignorada';

  @override
  String get progress => 'Progresso';

  @override
  String tasksProgress(int done, int total) {
    return '$done de $total tarefas concluídas';
  }

  @override
  String get branch => 'Branch';

  @override
  String get requestedBy => 'Solicitada por';

  @override
  String get queued => 'Na fila desde';

  @override
  String get started => 'Iniciada';

  @override
  String get finished => 'Terminada';

  @override
  String get duration => 'Duração';

  @override
  String get stages => 'Estágios';

  @override
  String get noStagesYet => 'Os estágios aparecem quando a execução começar.';

  @override
  String get runWaitingForApproval => 'Aguardando aprovação';

  @override
  String get runNotDeployed => 'Não implantado';

  @override
  String get builds => 'Builds';

  @override
  String get releases => 'Versões';

  @override
  String get loadReleasesFailed => 'Não foi possível carregar as versões';

  @override
  String get releaseScopeHint =>
      'As versões precisam do escopo Release (Read) no seu token.';

  @override
  String get artifact => 'Artefato';

  @override
  String waitingForApprovalBy(String names) {
    return 'Aguardando aprovação de $names';
  }

  @override
  String get pullRequests => 'Pull requests';

  @override
  String get searchPullRequestsHint =>
      'Pesquisar por título, ID, branch ou pessoa';

  @override
  String get scopeReviewing => 'Para revisar';

  @override
  String get loadPullRequestsFailed =>
      'Não foi possível carregar os pull requests';

  @override
  String get codeScopeHint =>
      'Os pull requests precisam do escopo Code (Read) no seu token.';

  @override
  String get noPullRequestsTitle => 'Nenhum pull request';

  @override
  String get noPullRequestsMessage =>
      'Não há pull requests que correspondam aos filtros.';

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
  String get selectPullRequestTitle => 'Selecione um pull request';

  @override
  String get selectPullRequestMessage =>
      'Escolha um pull request à esquerda para ver os detalhes.';

  @override
  String get prDraft => 'Rascunho';

  @override
  String get prActive => 'Ativo';

  @override
  String get prCompleted => 'Concluído';

  @override
  String get prAbandoned => 'Abandonado';

  @override
  String get mergeConflicts => 'Conflitos de merge';

  @override
  String get repository => 'Repositório';

  @override
  String get closed => 'Fechado';

  @override
  String get reviewers => 'Revisores';

  @override
  String get noReviewers => 'Sem revisores';

  @override
  String get requiredReviewer => 'Obrigatório';

  @override
  String get voteApproved => 'Aprovado';

  @override
  String get voteApprovedWithSuggestions => 'Aprovado com sugestões';

  @override
  String get voteNone => 'Sem voto';

  @override
  String get voteWaitingForAuthor => 'Aguardando o autor';

  @override
  String get voteRejected => 'Rejeitado';

  @override
  String get threadResolved => 'Resolvido';
}
