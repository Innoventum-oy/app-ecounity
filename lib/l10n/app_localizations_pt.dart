// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get about => 'Sobre';

  @override
  String get age => 'Idade';

  @override
  String get account => 'Conta';

  @override
  String get achievements => 'Conquistas';

  @override
  String get answer_saved => 'Resposta guardada';

  @override
  String get application_name => 'Ecounity';

  @override
  String get attention => 'Atenção';

  @override
  String get authenticating => 'A autenticar...';

  @override
  String get badge => 'Emblema';

  @override
  String badge_completion_status(int completed, int required) {
    return 'Concluiu $completed de $required conteúdos de aprendizagem necessários para ganhar esta insígnia.';
  }

  @override
  String badge_description(Object pathway) {
    return 'Este emblema é concedido por ter completado todas as lições e desafios no caminho $pathway.';
  }

  @override
  String get button_accept => 'Aceitar';

  @override
  String get button_approve => 'Aprovar';

  @override
  String get badge_awarded => 'Novo emblema concedido';

  @override
  String badge_awarded_congratulations(String badge) {
    return 'Parabéns! Você ganhou o emblema $badge!';
  }

  @override
  String get button_back => 'Voltar';

  @override
  String get button_cancel => 'Cancelar';

  @override
  String get button_close => 'Fechar';

  @override
  String get button_confirm => 'Confirmar';

  @override
  String get button_continue => 'Continuar';

  @override
  String get button_continue_as_guest => 'Continuar como convidado';

  @override
  String get button_create => 'Criar';

  @override
  String get button_create_account => 'Criar conta';

  @override
  String get button_delete => 'Excluir';

  @override
  String get button_edit => 'Editar';

  @override
  String get button_finish => 'Concluir';

  @override
  String get button_forgot_password => 'Esqueceu-se a sua palavra passe?';

  @override
  String get button_login => 'Entrar';

  @override
  String get button_logout => 'Sair';

  @override
  String get button_next => 'Próximo';

  @override
  String get button_ok => 'OK';

  @override
  String get button_previous => 'Anterior';

  @override
  String get button_register => 'Registrar';

  @override
  String get button_reject => 'Rejeitar';

  @override
  String get button_save => 'Salvar';

  @override
  String get button_send => 'Enviar';

  @override
  String get button_submit => 'Enviar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get choose_language => 'Escolher idioma';

  @override
  String get collected_badges => 'Emblemas obtidos';

  @override
  String get completed => 'Concluído';

  @override
  String get confirm_deleting_account =>
      'Tem a certeza de que deseja apagar a sua conta?';

  @override
  String get contact => 'Contacto';

  @override
  String get delete_account => 'Apagar conta';

  @override
  String get email => 'Endereço de e-mail';

  @override
  String get email_not_valid => 'O endereço de e-mail fornecido não é válido';

  @override
  String get email_or_phone_number =>
      'Endereço de e-mail ou número de telefone';

  @override
  String error(String error) {
    return 'Erro: $error';
  }

  @override
  String get error_default => 'Não foi possível completar a solicitação';

  @override
  String get error_occurred => 'Ocorreu um erro';

  @override
  String errorViewNotFound(String view) {
    return 'Vista $view não encontrada';
  }

  @override
  String get errors_in_form => 'Erros no formulário';

  @override
  String field_required(String field) {
    return 'O campo $field é obrigatório';
  }

  @override
  String get firstName => 'Primeiro nome';

  @override
  String get funding_disclaimer =>
      'Financiado pela União Europeia. Os pontos de vista e as opiniões expressas são as do(s) autor(es) e não refletem necessariamente a posição da União Europeia ou da Agência de Execução Europeia da Educação e da Cultura (EACEA). Nem a União Europeia nem a EACEA podem ser tidos como responsáveis por essas opiniões.';

  @override
  String get great => 'Ótimo';

  @override
  String get home => 'Início';

  @override
  String get introduction => 'Introdução';

  @override
  String get language => 'Idioma';

  @override
  String get select_language => 'Selecionar idioma';

  @override
  String locale(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'pt': 'Português',
      'de': 'Alemão',
      'fi': 'Finlandês',
      'en': 'Inglês',
      'it': 'Italiana',
      'pl': 'Polaca',
      'uk': 'Ucraniana',
      'ro': 'Romanian',
      'es': 'Spanish',
      'other': 'Idioma:$language',
    });
    return '$_temp0';
  }

  @override
  String get lastName => 'Último nome';

  @override
  String get loading => 'A carregar...';

  @override
  String get login => 'Entrar';

  @override
  String get login_failed => 'Falha na autenticação';

  @override
  String get logout => 'Sair';

  @override
  String get logout_confirmation => 'Tem certeza de que deseja sair?';

  @override
  String get markAsCompleted => 'Marcar como concluído';

  @override
  String navigation_item(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'home': 'Início',
      'pathways': 'Percursos',
      'challenges': 'Desafios',
      'videolist': 'Vídeos',
      'selfReflectionHub': 'Centro de Auto-reflexão',
      'lessons': 'Lições',
      'modules': 'Aprender',
      'resources': 'Recursos',
      'progress': 'Progresso',
      'teacher': 'Professor',
      'other': 'Menu:$item',
    });
    return '$_temp0';
  }

  @override
  String get next => 'Próximo';

  @override
  String get noBadgesFound => 'Nenhum emblema encontrado';

  @override
  String get noChallengesFound => 'Nenhum desafio encontrado';

  @override
  String get noContentFound => 'Nenhum conteúdo encontrado';

  @override
  String get noPathwaysFound => 'Nenhum conteúdo de aprendizagem encontrado';

  @override
  String get noTranscriptAvailable => 'Nenhuma transcrição disponível';

  @override
  String get noVideosFound => 'Nenhum vídeo encontrado';

  @override
  String get noLessonsFound => 'Nenhuma lição encontrada';

  @override
  String get page_content => 'Conteúdo da página';

  @override
  String get password => 'palavra Passe';

  @override
  String get pathway => 'Conteúdo de aprendizagem';

  @override
  String get pathway_already_completed =>
      'O conteúdo de aprendizagem está concluído';

  @override
  String get pathway_completed => 'Conteúdo de aprendizagem concluído';

  @override
  String get phone => 'Telefone';

  @override
  String get phone_or_email => 'Número de telefone ou endereço de e-mail';

  @override
  String get please_complete_form_properly =>
      'Por favor, preencha o formulário corretamente';

  @override
  String get please_enter_password => 'Por favor, insira uma palavra passe';

  @override
  String get please_enter_phone_or_email =>
      'Por favor, insira um número de telefone ou endereço de e-mail';

  @override
  String get please_provide_valid_phone_or_email =>
      'Por favor, forneça um número de telefone ou endereço de e-mail válido';

  @override
  String get previous => 'Anterior';

  @override
  String get privacy => 'Privacidade';

  @override
  String get privacy_policy => 'Política de Privacidade';

  @override
  String get profile => 'Perfil';

  @override
  String get register => 'Fazer registo';

  @override
  String get registration_failed => 'Falha no registo';

  @override
  String get registration_successful => 'Registo bem-sucedido';

  @override
  String registration_successful_message(String firstName) {
    return 'Bem-vindo/a ao Ecounity $firstName!';
  }

  @override
  String get references => 'Referências';

  @override
  String get saving_data_failed => 'Falha ao salvar os dados';

  @override
  String get quiz_not_passed => 'Questionário não aprovado';

  @override
  String get screenTitle_challenges => 'Desafios';

  @override
  String get screenTitle_home => 'Início';

  @override
  String get screenTitle_pathways => 'Percursos';

  @override
  String get screenTitle_selfReflectionHub => 'Centro de Auto-reflexão';

  @override
  String get screenTitle_videos => 'Vídeos';

  @override
  String get screenTitle_lessons => 'Lições';

  @override
  String get screenTitle_modules => 'Aprender';

  @override
  String get screenTitle_resources => 'Recursos';

  @override
  String get select => 'Selecionar';

  @override
  String get selected => 'Selecionado';

  @override
  String get sendAnswer => 'Guardar resposta';

  @override
  String get server => 'Servidor';

  @override
  String get settings => 'Configurações';

  @override
  String get stage => 'Estágio';

  @override
  String stageValue(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'before': 'Antes',
      'during': 'Durante',
      'after': 'Depois',
      'other': 'Estágio: $item',
    });
    return '$_temp0';
  }

  @override
  String get start => 'Iniciar';

  @override
  String get teacher_mode => 'Modo professor';

  @override
  String get teacher_mode_label => 'Sou professor';

  @override
  String get teacher_mode_description =>
      'O modo professor acrescenta informação pedagógica aos conteúdos. O progresso dos alunos e os crachás ficam desativados enquanto este modo estiver ativo.';

  @override
  String get teacher_mode_enable => 'Ativar modo professor';

  @override
  String get teacher_mode_active_title => 'O modo professor está ativo';

  @override
  String get teacher_mode_active_description =>
      'As atividades mostram informação pedagógica. O progresso dos alunos e os crachás ficam ocultos enquanto este modo estiver ativo.';

  @override
  String get teacher_mode_turn_off => 'Desativar modo professor';

  @override
  String get learning_objective => 'Objetivo de aprendizagem';

  @override
  String get group_code => 'Código do grupo';

  @override
  String get group_code_title => 'Entrar num grupo de aprendizagem';

  @override
  String get group_code_description =>
      'Insira o código do grupo fornecido pelo professor ou cole uma ligação de inscrição QR. O progresso na app será associado anonimamente a esse grupo.';

  @override
  String get group_code_hint => 'Código do grupo ou ligação de inscrição';

  @override
  String get group_code_required => 'Insira um código do grupo';

  @override
  String get join_group => 'Entrar no grupo';

  @override
  String get selected_group => 'Grupo selecionado';

  @override
  String get group_connected => 'Grupo associado';

  @override
  String get group_connected_message =>
      'A app está agora associada ao grupo de aprendizagem selecionado.';

  @override
  String get clear_group => 'Remover grupo';

  @override
  String get group_code_error =>
      'O código do grupo não foi encontrado ou não está ativo.';

  @override
  String get terms => 'Termos';

  @override
  String get unnamed => 'Sem nome';

  @override
  String get view_introduction => 'Introdução';

  @override
  String get you_have_this_badge => 'Você tem este emblema';

  @override
  String get your_password => 'A sua palavra passe';

  @override
  String get view_brochure => 'Ver brochura';

  @override
  String get welcome_title =>
      'Bem-vindo ao App Ecounity - a sua porta de entrada para a aprendizagem digital, inspiração e crescimento empreendedor.';

  @override
  String get login_introduction_text =>
      'Comece a explorar módulos de aprendizagem sobre os ODS, banda desenhada interativa, questionários e desafios em sala de aula para ações amigas do planeta.';

  @override
  String get srh_description =>
      'Utilize estas questões como matéria para reflexão.';

  @override
  String get srh_what_was_most_impactful_for_me =>
      'O que foi mais impactante para mim?';

  @override
  String get srh_what_will_i_put_into_practice =>
      'O que vou colocar em prática?';

  @override
  String get srh_what_are_my_hopes_and_fears_for_the_future =>
      'Quais são minhas esperanças e medos para o futuro?';

  @override
  String get no_video_found => 'Vídeo não foi encontrado.';

  @override
  String get no_modules_found => 'Nenhum módulo foi encontrado.';

  @override
  String get no_contents_found => 'Conteúdos não foram encontrados.';

  @override
  String get no_resources_found => 'Recursos não foram encontrados.';

  @override
  String get no_images_found => 'Imagens não foram encontradas.';

  @override
  String get links => 'Ligação';

  @override
  String get refresh => 'Atualizar';

  @override
  String get cache_cleared => 'Cache limpo. Por favor, recarregue a página.';

  @override
  String get module_completed => 'Módulo concluído';

  @override
  String get mark_as_completed => 'Marcar como concluído';

  @override
  String get mark_as_not_completed => 'Marcar como não concluído';

  @override
  String get no_image_available => 'Sem imagem disponível';

  @override
  String get no_title => 'Sem título';

  @override
  String get items_matched => 'Itens correspondidos';

  @override
  String get all_items_matched => 'Todos os itens correspondem!';

  @override
  String get play_again => 'Jogar novamente';

  @override
  String get not_enough_images_to_match =>
      'Não há imagens suficientes para combinar';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get error_loading_button => 'Erro ao carregar botão';

  @override
  String get seek => 'Procurar';

  @override
  String get ok => 'OK';

  @override
  String get notification => 'Notificação';

  @override
  String modules_completion_summary(int completed, int total) {
    return '$completed de $total módulos concluídos';
  }

  @override
  String learning_contents_completion_summary(int completed, int total) {
    return '$completed de $total conteúdos de aprendizagem concluídos';
  }

  @override
  String get current_progress => 'Progresso atual';

  @override
  String get next_suggestion => 'Próxima sugestão';

  @override
  String get next_up => 'A seguir:';

  @override
  String get congratulations => 'Parabéns!';

  @override
  String get you_have_completed_all_learning_contents =>
      'Concluiu todos os conteúdos de aprendizagem.';

  @override
  String get writeAnswerHere => 'Digite a sua resposta aqui.';

  @override
  String get fieldCannotBeEmpty => 'Este campo não pode ficar vazio.';

  @override
  String get clear_answers => 'Limpar respostas';
}
