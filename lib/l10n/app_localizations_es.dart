// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get about => 'Acerca de';

  @override
  String get age => 'Edad';

  @override
  String get account => 'Cuenta';

  @override
  String get achievements => 'Logros';

  @override
  String get answer_saved => 'Respuesta guardada';

  @override
  String get application_name => 'Ecounity';

  @override
  String get attention => 'Atención';

  @override
  String get authenticating => 'Autenticando...';

  @override
  String get badge => 'Badge';

  @override
  String badge_completion_status(int completed, int required) {
    return 'You have completed $completed out of $required learning contents required to earn this badge.';
  }

  @override
  String badge_description(Object pathway) {
    return 'This badge is awarded for completing all the lessons and challenges in the $pathway pathway.';
  }

  @override
  String get button_accept => 'Aceptar';

  @override
  String get button_approve => 'Aprobar';

  @override
  String get badge_awarded => 'Nueva insignia obtenida';

  @override
  String badge_awarded_congratulations(String badge) {
    return 'Congratulations! You have been awarded the $badge badge.';
  }

  @override
  String get button_back => 'Atrás';

  @override
  String get button_cancel => 'Cancelar';

  @override
  String get button_close => 'Cerrar';

  @override
  String get button_confirm => 'Confirmar';

  @override
  String get button_continue => 'Continuar';

  @override
  String get button_continue_as_guest => 'Continuar como invitado';

  @override
  String get button_create => 'Crear';

  @override
  String get button_create_account => 'Crear cuenta';

  @override
  String get button_delete => 'Eliminar';

  @override
  String get button_edit => 'Editar';

  @override
  String get button_finish => 'Finalizar';

  @override
  String get button_forgot_password => '¿Olvidaste tu contraseña?';

  @override
  String get button_login => 'Iniciar sesión';

  @override
  String get button_logout => 'Cerrar sesión';

  @override
  String get button_next => 'Siguiente';

  @override
  String get button_ok => 'OK';

  @override
  String get button_previous => 'Anterior';

  @override
  String get button_register => 'Registrarse';

  @override
  String get button_reject => 'Rechazar';

  @override
  String get button_save => 'Guardar';

  @override
  String get button_send => 'Enviar';

  @override
  String get button_submit => 'Enviar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get choose_language => 'Elige un idioma';

  @override
  String get collected_badges => 'Insignias obtenidas';

  @override
  String get completed => 'Completado';

  @override
  String get confirm_deleting_account =>
      '¿Seguro que quieres eliminar tu cuenta?';

  @override
  String get contact => 'Contacto';

  @override
  String get delete_account => 'Eliminar cuenta';

  @override
  String get email => 'Correo electrónico';

  @override
  String get email_not_valid =>
      'La dirección de correo electrónico no es válida';

  @override
  String get email_or_phone_number => 'Correo electrónico o número de teléfono';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get error_default => 'No se pudo completar la solicitud';

  @override
  String get error_occurred => 'Se produjo un error';

  @override
  String errorViewNotFound(String view) {
    return 'View $view not found';
  }

  @override
  String get errors_in_form => 'Errores en el formulario';

  @override
  String field_required(String field) {
    return 'The field $field is required';
  }

  @override
  String get firstName => 'Nombre';

  @override
  String get funding_disclaimer =>
      'Financiado por la Unión Europea. Las opiniones y puntos de vista expresados son, sin embargo, responsabilidad exclusiva de su(s) autor(es) y no reflejan necesariamente los de la Unión Europea ni los de la Agencia Ejecutiva Europea de Educación y Cultura (EACEA). Ni la Unión Europea ni la EACEA pueden ser consideradas responsables de ellos.';

  @override
  String get great => 'Genial';

  @override
  String get home => 'Inicio';

  @override
  String get introduction => 'Introducción';

  @override
  String get language => 'Idioma';

  @override
  String get select_language => 'Seleccionar idioma';

  @override
  String locale(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'es': 'Español',
      'ro': 'Rumano',
      'en': 'Inglés',
      'fi': 'Finés',
      'pl': 'Polaco',
      'de': 'Alemán',
      'uk': 'Ucraniano',
      'it': 'Italiano',
      'pt': 'Portugués',
      'other': 'Idioma:$language',
    });
    return '$_temp0';
  }

  @override
  String get lastName => 'Apellidos';

  @override
  String get loading => 'Cargando...';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get login_failed => 'Error al iniciar sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logout_confirmation => '¿Seguro que quieres cerrar sesión?';

  @override
  String get markAsCompleted => 'Marcar como completado';

  @override
  String navigation_item(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'home': 'Inicio',
      'pathways': 'Rutas',
      'challenges': 'Retos',
      'videolist': 'Vídeos',
      'selfReflectionHub': 'Auto-reflexión',
      'lessons': 'Lecciones',
      'modules': 'Aprender',
      'resources': 'Recursos',
      'progress': 'Progreso',
      'teacher': 'Docente',
      'other': 'Menú:$item',
    });
    return '$_temp0';
  }

  @override
  String get next => 'Siguiente';

  @override
  String get noBadgesFound => 'No se encontraron insignias';

  @override
  String get noChallengesFound => 'No se encontraron retos';

  @override
  String get noContentFound => 'No se encontró contenido';

  @override
  String get noPathwaysFound => 'No se encontraron contenidos de aprendizaje';

  @override
  String get noTranscriptAvailable => 'No hay transcripción disponible';

  @override
  String get noVideosFound => 'No se encontraron vídeos';

  @override
  String get noLessonsFound => 'No se encontraron lecciones';

  @override
  String get page_content => 'Contenido de la página';

  @override
  String get password => 'Contraseña';

  @override
  String get pathway => 'Contenido de aprendizaje';

  @override
  String get pathway_already_completed =>
      'El contenido de aprendizaje está completado';

  @override
  String get pathway_completed => 'Contenido de aprendizaje completado';

  @override
  String get phone => 'Teléfono';

  @override
  String get phone_or_email => 'Número de teléfono o correo electrónico';

  @override
  String get please_complete_form_properly =>
      'Completa el formulario correctamente';

  @override
  String get please_enter_password => 'Introduce una contraseña';

  @override
  String get please_enter_phone_or_email =>
      'Introduce un número de teléfono o correo electrónico';

  @override
  String get please_provide_valid_phone_or_email =>
      'Introduce un número de teléfono o correo electrónico válido';

  @override
  String get previous => 'Anterior';

  @override
  String get privacy => 'Privacidad';

  @override
  String get privacy_policy => 'Política de privacidad';

  @override
  String get profile => 'Perfil';

  @override
  String get register => 'Registrarse';

  @override
  String get registration_failed => 'Registro fallido';

  @override
  String get registration_successful => 'Registro completado';

  @override
  String registration_successful_message(String firstName) {
    return '¡Te damos la bienvenida a Ecounity, $firstName!';
  }

  @override
  String get references => 'Referencias';

  @override
  String get saving_data_failed => 'No se pudieron guardar los datos';

  @override
  String get quiz_not_passed => 'Cuestionario no superado';

  @override
  String get screenTitle_challenges => 'Retos';

  @override
  String get screenTitle_home => 'Inicio';

  @override
  String get screenTitle_pathways => 'Rutas';

  @override
  String get screenTitle_selfReflectionHub => 'Auto-reflexión';

  @override
  String get screenTitle_videos => 'Vídeos';

  @override
  String get screenTitle_lessons => 'Lecciones';

  @override
  String get screenTitle_modules => 'Aprender';

  @override
  String get screenTitle_resources => 'Recursos';

  @override
  String get dashboard_no_modules_available => 'No hay módulos disponibles';

  @override
  String get dashboard_welcome_back => 'Te damos la bienvenida de nuevo';

  @override
  String get dashboard_ready_prompt => '¿Listo para actuar hoy?';

  @override
  String get dashboard_start_learning => 'Empieza a aprender';

  @override
  String dashboard_continue_sdg(int sdgNumber) {
    return 'Continuar ODS $sdgNumber';
  }

  @override
  String dashboard_start_sdg(int sdgNumber) {
    return 'Empezar ODS $sdgNumber';
  }

  @override
  String get dashboard_explore_modules =>
      'Explora los módulos de aprendizaje de EcoUnity';

  @override
  String get dashboard_browse_modules => 'Ver módulos';

  @override
  String get dashboard_resume_module => 'Continuar módulo';

  @override
  String get dashboard_start_module => 'Empezar módulo';

  @override
  String get dashboard_stat_modules => 'Módulos';

  @override
  String get dashboard_stat_activities => 'Actividades';

  @override
  String get dashboard_stat_badges => 'Insignias';

  @override
  String get dashboard_module_status_done => 'Hecho';

  @override
  String get dashboard_module_status_started => 'Iniciado';

  @override
  String get dashboard_module_status_new => 'Nuevo';

  @override
  String get dashboard_latest_challenge => 'Último reto';

  @override
  String get dashboard_one_minute_left => 'Queda 1 min';

  @override
  String dashboard_minutes_left(int minutes) {
    return 'Quedan $minutes min';
  }

  @override
  String get dashboard_one_minute => '1 min';

  @override
  String dashboard_minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get dashboard_one_activity => '1 actividad';

  @override
  String dashboard_activities(int activities) {
    return '$activities actividades';
  }

  @override
  String get select => 'Seleccionar';

  @override
  String get selected => 'Seleccionado';

  @override
  String get sendAnswer => 'Guardar respuesta';

  @override
  String get server => 'Servidor';

  @override
  String get settings => 'Configuración';

  @override
  String get stage => 'Etapa';

  @override
  String stageValue(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'before': 'Before',
      'during': 'During',
      'after': 'After',
      'other': '$item',
    });
    return '$_temp0';
  }

  @override
  String get start => 'Comenzar';

  @override
  String get teacher_mode => 'Modo docente';

  @override
  String get teacher_mode_label => 'Soy docente';

  @override
  String get teacher_mode_description =>
      'El modo docente añade información didáctica a los contenidos. El progreso del alumnado y las insignias se desactivan mientras este modo está activo.';

  @override
  String get teacher_mode_enable => 'Activar modo docente';

  @override
  String get teacher_mode_active_title => 'El modo docente está activo';

  @override
  String get teacher_mode_active_description =>
      'Las actividades muestran información didáctica. El progreso del alumnado y las insignias permanecen ocultos mientras este modo está activo.';

  @override
  String get teacher_mode_turn_off => 'Desactivar modo docente';

  @override
  String get button_add => 'Añadir';

  @override
  String get learning_module_title => 'Módulo';

  @override
  String learning_module_load_error(String error) {
    return 'No se pudo cargar el módulo: $error';
  }

  @override
  String get learning_module_not_found => 'Módulo no encontrado';

  @override
  String get learning_empty_activities =>
      'Las actividades aparecerán aquí cuando este módulo esté listo.';

  @override
  String learning_group_stats_for(String group) {
    return 'Mostrando estadísticas del grupo $group';
  }

  @override
  String get learning_group_stats_empty =>
      'Añade y selecciona un grupo docente en la vista Docente para mostrar estadísticas aquí.';

  @override
  String learning_sdg_modules_count(int count) {
    return 'Módulos de aprendizaje ODS: $count';
  }

  @override
  String learning_module_filter(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Todos',
      'started': 'Iniciados',
      'done': 'Hechos',
      'challenges': 'Retos',
      'other': 'Todos',
    });
    return '$_temp0';
  }

  @override
  String learning_no_filtered_modules(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Todavía no hay módulos disponibles.',
      'started': 'Todavía no hay módulos iniciados.',
      'done': 'Todavía no hay módulos completados.',
      'challenges': 'Todavía no hay módulos de retos.',
      'other': 'Todavía no hay módulos.',
    });
    return '$_temp0';
  }

  @override
  String learning_module_status(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'new': 'Nuevo',
      'started': 'Iniciado',
      'done': 'Hecho',
      'other': 'Nuevo',
    });
    return '$_temp0';
  }

  @override
  String get learning_badge_earned => 'Insignia obtenida';

  @override
  String get learning_in_progress => 'En curso';

  @override
  String get learning_one_minute_left => 'Queda 1 min';

  @override
  String learning_minutes_left(int minutes) {
    return 'Quedan $minutes min';
  }

  @override
  String get learning_one_minute => '1 min';

  @override
  String learning_minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get learning_one_activity => '1 actividad';

  @override
  String learning_activities(int activities) {
    return '$activities actividades';
  }

  @override
  String learning_activity_type(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'comic': 'Cómic',
      'mlr': 'Microaprendizaje',
      'quiz': 'Cuestionario',
      'reflection': 'Reflexión',
      'challenge': 'Reto',
      'unknown': 'Actividad',
      'other': 'Actividad',
    });
    return '$_temp0';
  }

  @override
  String learning_module_difficulty(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      'beginner': 'Principiante',
      'intermediate': 'Intermedio',
      'advanced': 'Avanzado',
      'easy': 'Fácil',
      'medium': 'Medio',
      'hard': 'Difícil',
      'classroom_activity': 'Actividad de aula',
      'home_activity': 'Actividad en casa',
      'group_challenge': 'Reto en grupo',
      'other': '$level',
    });
    return '$_temp0';
  }

  @override
  String learning_activity_load_error(String error) {
    return 'No se pudo cargar la actividad: $error';
  }

  @override
  String get learning_activity_not_found => 'Actividad no encontrada';

  @override
  String get learning_submit_reflection => 'Enviar reflexión';

  @override
  String get learning_complete_challenge => 'Completar reto';

  @override
  String get learning_write_response_hint => 'Escribe tu respuesta';

  @override
  String get learning_reflection_prompt_title => 'Piénsalo';

  @override
  String get quiz_no_questions_title => 'No hay preguntas disponibles';

  @override
  String get quiz_no_questions_message =>
      'Este cuestionario no incluye preguntas por ahora.';

  @override
  String quiz_question_progress(int current, int total) {
    return 'Pregunta $current de $total';
  }

  @override
  String get quiz_no_answer_options_title => 'No hay opciones de respuesta';

  @override
  String get quiz_no_answer_options_message =>
      'Esta pregunta no incluye opciones de respuesta por ahora.';

  @override
  String get quiz_submit_answers => 'Enviar respuestas';

  @override
  String quiz_result_passed(int score, int total) {
    return 'Aprobado: $score/$total';
  }

  @override
  String quiz_result_try_again(int score, int total) {
    return 'Inténtalo de nuevo: $score/$total';
  }

  @override
  String get progress_load_error_title => 'No se pudo cargar el progreso';

  @override
  String get progress_empty_message =>
      'Los módulos de aprendizaje aparecerán aquí después de cargarse.';

  @override
  String get progress_journey_title => 'Mi recorrido de aprendizaje';

  @override
  String progress_overall_complete(int percent) {
    return '$percent% completado';
  }

  @override
  String progress_summary(
    int completedModules,
    int activeChallenges,
    int earnedBadges,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      completedModules,
      locale: localeName,
      other: 'módulos',
      one: 'módulo',
    );
    String _temp1 = intl.Intl.pluralLogic(
      activeChallenges,
      locale: localeName,
      other: 'retos',
      one: 'reto',
    );
    String _temp2 = intl.Intl.pluralLogic(
      earnedBadges,
      locale: localeName,
      other: 'insignias',
      one: 'insignia',
    );
    return '$completedModules $_temp0 completados, $activeChallenges $_temp1 activos, $earnedBadges $_temp2 obtenidas';
  }

  @override
  String progress_segment(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'earned': 'Obtenidas',
      'locked': 'Bloqueadas',
      'modules': 'Progreso de módulos',
      'other': 'Progreso',
    });
    return '$_temp0';
  }

  @override
  String get progress_no_badges_earned_title => 'Aún no has obtenido insignias';

  @override
  String get progress_no_badges_earned_message =>
      'Completa las actividades requeridas para desbloquear tu primera insignia.';

  @override
  String get progress_all_badges_earned_title =>
      'Todas las insignias obtenidas';

  @override
  String get progress_all_badges_earned_message =>
      'Has desbloqueado todas las insignias disponibles.';

  @override
  String progress_badge_status(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'earned': 'Obtenida',
      'locked': 'Bloqueada',
      'other': 'Insignia',
    });
    return '$_temp0';
  }

  @override
  String get progress_no_modules_title => 'Aún no hay módulos de aprendizaje';

  @override
  String get progress_no_modules_message =>
      'El progreso de los módulos aparecerá aquí después de cargar el contenido.';

  @override
  String progress_module_activities(int completed, int total) {
    return '$completed / $total actividades';
  }

  @override
  String get progress_suggested_module => 'Siguiente módulo sugerido';

  @override
  String progress_continue_with(String activityTitle) {
    return 'Continuar con $activityTitle';
  }

  @override
  String get progress_final_badge_title => 'Final de EcoUnity';

  @override
  String get progress_final_badge_description =>
      'Completa todos los módulos de aprendizaje para desbloquear la insignia final.';

  @override
  String get learning_module_fallback => 'Módulo de aprendizaje';

  @override
  String get learning_module_badge_fallback => 'Insignia de módulo';

  @override
  String get teacher_group_statistics_title => 'Estadísticas de grupo';

  @override
  String get teacher_refresh_active_group => 'Actualizar grupo activo';

  @override
  String get teacher_group_report_description =>
      'Añade tokens docentes para ver el progreso agregado por grupo. La app solo guarda informes resumidos, no identidades del alumnado.';

  @override
  String get teacher_token_label => 'Token docente';

  @override
  String get teacher_token_hint => 'ABCDEF';

  @override
  String get teacher_group => 'Grupo';

  @override
  String get teacher_active_group => 'Grupo activo';

  @override
  String get teacher_select_group => 'Seleccionar grupo';

  @override
  String teacher_token_value(String token) {
    return 'Token $token';
  }

  @override
  String get teacher_metric_enrolled => 'Inscritos';

  @override
  String get teacher_metric_active => 'Activos';

  @override
  String get teacher_metric_completed => 'Completado';

  @override
  String get teacher_refresh_group => 'Actualizar grupo';

  @override
  String get teacher_remove_group => 'Eliminar grupo';

  @override
  String get teacher_empty_groups =>
      'Añade un token de grupo para activar estadísticas en las vistas de aprendizaje.';

  @override
  String get teacher_loading_saved_groups => 'Cargando grupos guardados...';

  @override
  String teacher_stats_opened(int opened, String total) {
    return 'Abierto $opened/$total';
  }

  @override
  String teacher_stats_completed(String percent) {
    return 'Completado $percent';
  }

  @override
  String teacher_stats_activity_completion(String percent) {
    return '$percent de actividades completadas';
  }

  @override
  String teacher_stats_avg_score(String score) {
    return 'Puntuación media $score';
  }

  @override
  String teacher_stats_avg_score_with_max(String score, String maxScore) {
    return 'Puntuación media $score/$maxScore';
  }

  @override
  String get learning_objective => 'Objetivo de aprendizaje';

  @override
  String get group_code => 'Código de grupo';

  @override
  String get group_code_title => 'Unirse a un grupo de aprendizaje';

  @override
  String get group_code_description =>
      'Introduce el código de grupo de tu docente o pega un enlace de inscripción QR. Tu progreso en la app se vinculará anónimamente a ese grupo.';

  @override
  String get group_code_hint => 'Código de grupo o enlace de inscripción';

  @override
  String get group_code_required => 'Introduce un código de grupo';

  @override
  String get join_group => 'Unirse al grupo';

  @override
  String get selected_group => 'Grupo seleccionado';

  @override
  String get group_connected => 'Grupo conectado';

  @override
  String get group_connected_message =>
      'La app está ahora vinculada al grupo de aprendizaje seleccionado.';

  @override
  String get clear_group => 'Quitar grupo';

  @override
  String get group_code_error =>
      'El código de grupo no se encontró o no está activo.';

  @override
  String get terms => 'Términos';

  @override
  String get unnamed => 'Sin nombre';

  @override
  String get view_introduction => 'Introducción';

  @override
  String get you_have_this_badge => 'Tienes esta insignia';

  @override
  String get your_password => 'Tu contraseña';

  @override
  String get view_brochure => 'Ver folleto';

  @override
  String get welcome_title =>
      'Bienvenido a la app EcoUnity: tu puerta de entrada al aprendizaje digital, la inspiración y el crecimiento emprendedor.';

  @override
  String get welcome_tagline => '¡Juntos por el planeta!';

  @override
  String get login_introduction_text =>
      'Empieza a explorar módulos de aprendizaje sobre los ODS, cómics interactivos, cuestionarios y retos de clase para actuar a favor del planeta.';

  @override
  String get srh_description => 'Use these questions as a food for thought.';

  @override
  String get srh_what_was_most_impactful_for_me =>
      'What was most impactful for me?';

  @override
  String get srh_what_will_i_put_into_practice =>
      'What will I put into practice?';

  @override
  String get srh_what_are_my_hopes_and_fears_for_the_future =>
      'What are my hopes and fears for the future?';

  @override
  String get no_video_found => 'The video was not found.';

  @override
  String get no_modules_found => 'No modules were found.';

  @override
  String get no_contents_found => 'Contents were not found.';

  @override
  String get no_resources_found => 'Resources were not found.';

  @override
  String get no_images_found => 'Images were not found.';

  @override
  String get links => 'Links';

  @override
  String get refresh => 'Actualizar';

  @override
  String get cache_cleared => 'Caché borrada. Vuelve a cargar la página.';

  @override
  String get module_completed => 'Module completed';

  @override
  String get mark_as_completed => 'Mark as completed';

  @override
  String get mark_as_not_completed => 'Mark as not completed';

  @override
  String get no_image_available => 'No image available';

  @override
  String get no_title => 'No title';

  @override
  String get items_matched => 'Items matched';

  @override
  String get all_items_matched => 'All items matched!';

  @override
  String get play_again => 'Play again';

  @override
  String get comic_no_scenes_available => 'No hay escenas de cómic disponibles';

  @override
  String get comic_loading_scene => 'Cargando escena...';

  @override
  String get comic_playing => 'Reproduciendo...';

  @override
  String get comic_complete_action => 'Completar';

  @override
  String get comic_loading_next_scenes => 'Cargando las siguientes escenas...';

  @override
  String get comic_dialogue_title => 'Diálogo';

  @override
  String get comic_character_fallback => 'Personaje';

  @override
  String get comic_play_tooltip => 'Reproducir';

  @override
  String get comic_stop_tooltip => 'Detener';

  @override
  String get comic_view_dialogue_tooltip => 'Ver diálogo';

  @override
  String get not_enough_images_to_match => 'Not enough images to match';

  @override
  String get unknown => 'Unknown';

  @override
  String get error_loading_button => 'Error al cargar el botón';

  @override
  String get seek => 'Seek';

  @override
  String get ok => 'OK';

  @override
  String get notification => 'Notification';

  @override
  String modules_completion_summary(int completed, int total) {
    return '$completed of $total modules completed';
  }

  @override
  String learning_contents_completion_summary(int completed, int total) {
    return '$completed of $total learning contents completed';
  }

  @override
  String get current_progress => 'Progreso actual';

  @override
  String get next_suggestion => 'Next suggestion';

  @override
  String get next_up => 'Next up:';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get you_have_completed_all_learning_contents =>
      'You have completed all learning contents.';

  @override
  String get writeAnswerHere => 'Type your answer here.';

  @override
  String get fieldCannotBeEmpty => 'This field cannot be empty.';

  @override
  String get clear_answers => 'Clear answers';
}
