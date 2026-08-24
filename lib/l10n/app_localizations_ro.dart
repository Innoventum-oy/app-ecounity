// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get about => 'Despre';

  @override
  String get age => 'Vârstă';

  @override
  String get account => 'Cont';

  @override
  String get achievements => 'Realizări';

  @override
  String get answer_saved => 'Răspuns salvat';

  @override
  String get application_name => 'Ecounity';

  @override
  String get attention => 'Atenție';

  @override
  String get authenticating => 'Se autentifică...';

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
  String get button_accept => 'Acceptă';

  @override
  String get button_approve => 'Aprobă';

  @override
  String get badge_awarded => 'Insignă nouă obținută';

  @override
  String badge_awarded_congratulations(String badge) {
    return 'Congratulations! You have been awarded the $badge badge.';
  }

  @override
  String get button_back => 'Înapoi';

  @override
  String get button_cancel => 'Anulează';

  @override
  String get button_close => 'Închide';

  @override
  String get button_confirm => 'Confirmă';

  @override
  String get button_continue => 'Continuă';

  @override
  String get button_continue_as_guest => 'Continuă ca invitat';

  @override
  String get button_create => 'Creează';

  @override
  String get button_create_account => 'Creează cont';

  @override
  String get button_delete => 'Șterge';

  @override
  String get button_edit => 'Editează';

  @override
  String get button_finish => 'Finalizează';

  @override
  String get button_forgot_password => 'Ai uitat parola?';

  @override
  String get button_login => 'Autentificare';

  @override
  String get button_logout => 'Deconectare';

  @override
  String get button_next => 'Următorul';

  @override
  String get button_ok => 'OK';

  @override
  String get button_previous => 'Anteriorul';

  @override
  String get button_register => 'Înregistrare';

  @override
  String get button_reject => 'Respinge';

  @override
  String get button_save => 'Salvează';

  @override
  String get button_send => 'Trimite';

  @override
  String get button_submit => 'Trimite';

  @override
  String get cancel => 'Anulează';

  @override
  String get choose_language => 'Alege limba';

  @override
  String get collected_badges => 'Insigne obținute';

  @override
  String get completed => 'Finalizat';

  @override
  String get confirm_deleting_account => 'Sigur dorești să ștergi contul?';

  @override
  String get contact => 'Contact';

  @override
  String get delete_account => 'Șterge contul';

  @override
  String get email => 'E-mail';

  @override
  String get email_not_valid => 'Adresa de e-mail introdusă nu este validă';

  @override
  String get email_or_phone_number => 'E-mail sau număr de telefon';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get error_default => 'Solicitarea nu a putut fi finalizată';

  @override
  String get error_occurred => 'A apărut o eroare';

  @override
  String errorViewNotFound(String view) {
    return 'View $view not found';
  }

  @override
  String get errors_in_form => 'Erori în formular';

  @override
  String field_required(String field) {
    return 'The field $field is required';
  }

  @override
  String get firstName => 'Prenume';

  @override
  String get funding_disclaimer =>
      'Finanțat de Uniunea Europeană. Punctele de vedere și opiniile exprimate aparțin însă exclusiv autorului/autorilor și nu reflectă neapărat punctele de vedere ale Uniunii Europene sau ale Agenției Executive Europene pentru Educație și Cultură (EACEA). Nici Uniunea Europeană, nici EACEA nu pot fi considerate responsabile pentru acestea.';

  @override
  String get great => 'Foarte bine';

  @override
  String get home => 'Acasă';

  @override
  String get introduction => 'Introducere';

  @override
  String get language => 'Limbă';

  @override
  String get select_language => 'Selectează limba';

  @override
  String locale(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'ro': 'Română',
      'es': 'Spaniolă',
      'en': 'Engleză',
      'fi': 'Finlandeză',
      'pl': 'Poloneză',
      'de': 'Germană',
      'uk': 'Ucraineană',
      'it': 'Italiană',
      'pt': 'Portugheză',
      'other': 'Limbă:$language',
    });
    return '$_temp0';
  }

  @override
  String get lastName => 'Nume';

  @override
  String get loading => 'Se încarcă...';

  @override
  String get login => 'Autentificare';

  @override
  String get login_failed => 'Autentificare eșuată';

  @override
  String get logout => 'Deconectare';

  @override
  String get logout_confirmation => 'Sigur dorești să te deconectezi?';

  @override
  String get markAsCompleted => 'Marchează ca finalizat';

  @override
  String navigation_item(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'home': 'Acasă',
      'pathways': 'Trasee',
      'challenges': 'Provocări',
      'videolist': 'Videouri',
      'selfReflectionHub': 'Auto-reflecție',
      'lessons': 'Lecții',
      'modules': 'Învățare',
      'resources': 'Resurse',
      'progress': 'Progres',
      'teacher': 'Profesor',
      'other': 'Meniu:$item',
    });
    return '$_temp0';
  }

  @override
  String get next => 'Următorul';

  @override
  String get noBadgesFound => 'Nu s-au găsit insigne';

  @override
  String get noChallengesFound => 'Nu s-au găsit provocări';

  @override
  String get noContentFound => 'Nu s-a găsit conținut';

  @override
  String get noPathwaysFound => 'Nu s-au găsit conținuturi de învățare';

  @override
  String get noTranscriptAvailable => 'Nu există transcriere disponibilă';

  @override
  String get noVideosFound => 'Nu s-au găsit videouri';

  @override
  String get noLessonsFound => 'Nu s-au găsit lecții';

  @override
  String get page_content => 'Conținutul paginii';

  @override
  String get password => 'Parolă';

  @override
  String get pathway => 'Conținut de învățare';

  @override
  String get pathway_already_completed =>
      'Conținutul de învățare este finalizat';

  @override
  String get pathway_completed => 'Conținut de învățare finalizat';

  @override
  String get phone => 'Telefon';

  @override
  String get phone_or_email => 'Număr de telefon sau e-mail';

  @override
  String get please_complete_form_properly => 'Completează formularul corect';

  @override
  String get please_enter_password => 'Introdu o parolă';

  @override
  String get please_enter_phone_or_email =>
      'Introdu un număr de telefon sau o adresă de e-mail';

  @override
  String get please_provide_valid_phone_or_email =>
      'Introdu un număr de telefon sau o adresă de e-mail validă';

  @override
  String get previous => 'Anteriorul';

  @override
  String get privacy => 'Confidențialitate';

  @override
  String get privacy_policy => 'Politica de confidențialitate';

  @override
  String get profile => 'Profil';

  @override
  String get register => 'Înregistrare';

  @override
  String get registration_failed => 'Înregistrare eșuată';

  @override
  String get registration_successful => 'Înregistrare reușită';

  @override
  String registration_successful_message(String firstName) {
    return 'Bun venit la Ecounity, $firstName!';
  }

  @override
  String get references => 'Referințe';

  @override
  String get saving_data_failed => 'Salvarea datelor a eșuat';

  @override
  String get quiz_not_passed => 'Quizul nu a fost trecut';

  @override
  String get screenTitle_challenges => 'Provocări';

  @override
  String get screenTitle_home => 'Acasă';

  @override
  String get screenTitle_pathways => 'Trasee';

  @override
  String get screenTitle_selfReflectionHub => 'Auto-reflecție';

  @override
  String get screenTitle_videos => 'Videouri';

  @override
  String get screenTitle_lessons => 'Lecții';

  @override
  String get screenTitle_modules => 'Învățare';

  @override
  String get screenTitle_resources => 'Resurse';

  @override
  String get dashboard_no_modules_available => 'Nu sunt module disponibile';

  @override
  String get dashboard_welcome_back => 'Bine ai revenit';

  @override
  String get dashboard_ready_prompt => 'Ești gata să acționezi astăzi?';

  @override
  String get dashboard_start_learning => 'Începe învățarea';

  @override
  String dashboard_continue_sdg(int sdgNumber) {
    return 'Continuă SDG $sdgNumber';
  }

  @override
  String dashboard_start_sdg(int sdgNumber) {
    return 'Începe SDG $sdgNumber';
  }

  @override
  String get dashboard_explore_modules =>
      'Explorează modulele de învățare EcoUnity';

  @override
  String get dashboard_browse_modules => 'Răsfoiește modulele';

  @override
  String get dashboard_resume_module => 'Reia modulul';

  @override
  String get dashboard_start_module => 'Începe modulul';

  @override
  String get dashboard_stat_modules => 'Module';

  @override
  String get dashboard_stat_activities => 'Activități';

  @override
  String get dashboard_stat_badges => 'Insigne';

  @override
  String get dashboard_module_status_done => 'Finalizat';

  @override
  String get dashboard_module_status_started => 'Început';

  @override
  String get dashboard_module_status_new => 'Nou';

  @override
  String get dashboard_latest_challenge => 'Cea mai recentă provocare';

  @override
  String get dashboard_one_minute_left => '1 min rămas';

  @override
  String dashboard_minutes_left(int minutes) {
    return '$minutes min rămase';
  }

  @override
  String get dashboard_one_minute => '1 min';

  @override
  String dashboard_minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get dashboard_one_activity => '1 activitate';

  @override
  String dashboard_activities(int activities) {
    return '$activities activități';
  }

  @override
  String get select => 'Selectează';

  @override
  String get selected => 'Selectat';

  @override
  String get sendAnswer => 'Salvează răspunsul';

  @override
  String get server => 'Server';

  @override
  String get settings => 'Setări';

  @override
  String get stage => 'Etapă';

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
  String get start => 'Începe';

  @override
  String get teacher_mode => 'Mod profesor';

  @override
  String get teacher_mode_label => 'Sunt profesor';

  @override
  String get teacher_mode_description =>
      'Modul profesor adaugă informații didactice la conținut. Progresul elevilor și insignele sunt dezactivate cât timp acest mod este activ.';

  @override
  String get teacher_mode_enable => 'Activează modul profesor';

  @override
  String get teacher_mode_active_title => 'Modul profesor este activ';

  @override
  String get teacher_mode_active_description =>
      'Activitățile afișează informații didactice. Progresul elevilor și insignele sunt ascunse cât timp acest mod este activ.';

  @override
  String get teacher_mode_turn_off => 'Dezactivează modul profesor';

  @override
  String get button_add => 'Adaugă';

  @override
  String get learning_module_title => 'Modul';

  @override
  String learning_module_load_error(String error) {
    return 'Modulul nu a putut fi încărcat: $error';
  }

  @override
  String get learning_module_not_found => 'Modulul nu a fost găsit';

  @override
  String get learning_empty_activities =>
      'Activitățile vor apărea aici când acest modul este gata.';

  @override
  String learning_group_stats_for(String group) {
    return 'Se afișează statisticile grupului $group';
  }

  @override
  String get learning_group_stats_empty =>
      'Adaugă și selectează un grup de profesor în vizualizarea Profesor pentru a afișa statistici aici.';

  @override
  String learning_sdg_modules_count(int count) {
    return 'Module de învățare SDG: $count';
  }

  @override
  String learning_module_filter(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Toate',
      'started': 'Începute',
      'done': 'Finalizate',
      'challenges': 'Provocări',
      'other': 'Toate',
    });
    return '$_temp0';
  }

  @override
  String learning_no_filtered_modules(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Nu există încă module disponibile.',
      'started': 'Nu există încă module începute.',
      'done': 'Nu există încă module finalizate.',
      'challenges': 'Nu există încă module cu provocări.',
      'other': 'Nu există încă module.',
    });
    return '$_temp0';
  }

  @override
  String learning_module_status(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'new': 'Nou',
      'started': 'Început',
      'done': 'Finalizat',
      'other': 'Nou',
    });
    return '$_temp0';
  }

  @override
  String get learning_badge_earned => 'Insignă obținută';

  @override
  String get learning_in_progress => 'În curs';

  @override
  String get learning_one_minute_left => '1 min rămas';

  @override
  String learning_minutes_left(int minutes) {
    return '$minutes min rămase';
  }

  @override
  String get learning_one_minute => '1 min';

  @override
  String learning_minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get learning_one_activity => '1 activitate';

  @override
  String learning_activities(int activities) {
    return '$activities activități';
  }

  @override
  String learning_activity_type(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'comic': 'Comic',
      'mlr': 'Micro-învățare',
      'quiz': 'Quiz',
      'reflection': 'Reflecție',
      'challenge': 'Provocare',
      'unknown': 'Activitate',
      'other': 'Activitate',
    });
    return '$_temp0';
  }

  @override
  String get teacher_group_statistics_title => 'Statistici de grup';

  @override
  String get teacher_refresh_active_group => 'Reîmprospătează grupul activ';

  @override
  String get teacher_group_report_description =>
      'Adaugă tokenuri de profesor pentru a vedea progresul agregat la nivel de grup. Aplicația stochează doar rapoarte rezumative, nu identități ale elevilor.';

  @override
  String get teacher_token_label => 'Token profesor';

  @override
  String get teacher_token_hint => 'ABCDEF';

  @override
  String get teacher_group => 'Grup';

  @override
  String get teacher_active_group => 'Grup activ';

  @override
  String get teacher_select_group => 'Selectează grupul';

  @override
  String teacher_token_value(String token) {
    return 'Token $token';
  }

  @override
  String get teacher_metric_enrolled => 'Înscriși';

  @override
  String get teacher_metric_active => 'Activi';

  @override
  String get teacher_metric_completed => 'Finalizat';

  @override
  String get teacher_refresh_group => 'Reîmprospătează grupul';

  @override
  String get teacher_remove_group => 'Elimină grupul';

  @override
  String get teacher_empty_groups =>
      'Adaugă un token de grup pentru a activa statisticile în vizualizările de învățare.';

  @override
  String get teacher_loading_saved_groups => 'Se încarcă grupurile salvate...';

  @override
  String teacher_stats_opened(int opened, String total) {
    return 'Deschis $opened/$total';
  }

  @override
  String teacher_stats_completed(String percent) {
    return 'Finalizat $percent';
  }

  @override
  String teacher_stats_activity_completion(String percent) {
    return '$percent finalizare activități';
  }

  @override
  String teacher_stats_avg_score(String score) {
    return 'Scor mediu $score';
  }

  @override
  String teacher_stats_avg_score_with_max(String score, String maxScore) {
    return 'Scor mediu $score/$maxScore';
  }

  @override
  String get learning_objective => 'Obiectiv de învățare';

  @override
  String get group_code => 'Cod de grup';

  @override
  String get group_code_title => 'Alătură-te unui grup de învățare';

  @override
  String get group_code_description =>
      'Introdu codul de grup primit de la profesor sau lipește un link de înscriere QR. Progresul din aplicație va fi asociat anonim cu acel grup.';

  @override
  String get group_code_hint => 'Cod de grup sau link de înscriere';

  @override
  String get group_code_required => 'Introdu un cod de grup';

  @override
  String get join_group => 'Alătură-te grupului';

  @override
  String get selected_group => 'Grup selectat';

  @override
  String get group_connected => 'Grup conectat';

  @override
  String get group_connected_message =>
      'Aplicația este acum asociată cu grupul de învățare selectat.';

  @override
  String get clear_group => 'Elimină grupul';

  @override
  String get group_code_error =>
      'Codul de grup nu a fost găsit sau nu este activ.';

  @override
  String get terms => 'Termeni';

  @override
  String get unnamed => 'Fără nume';

  @override
  String get view_introduction => 'Introducere';

  @override
  String get you_have_this_badge => 'Ai această insignă';

  @override
  String get your_password => 'Parola ta';

  @override
  String get view_brochure => 'Vezi broșura';

  @override
  String get welcome_title =>
      'Bun venit în aplicația EcoUnity - poarta ta către învățare digitală, inspirație și dezvoltare antreprenorială.';

  @override
  String get welcome_tagline => 'Împreună pentru planetă!';

  @override
  String get login_introduction_text =>
      'Începe să explorezi module de învățare SDG, benzi desenate interactive, quizuri și provocări la clasă pentru acțiuni prietenoase cu planeta.';

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
  String get refresh => 'Reîmprospătează';

  @override
  String get cache_cleared => 'Cache-ul a fost golit. Reîncarcă pagina.';

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
  String get comic_no_scenes_available =>
      'Nu există scene de benzi desenate disponibile';

  @override
  String get comic_loading_scene => 'Se încarcă scena...';

  @override
  String get comic_playing => 'Se redă...';

  @override
  String get comic_complete_action => 'Finalizează';

  @override
  String get comic_loading_next_scenes => 'Se încarcă scenele următoare...';

  @override
  String get comic_dialogue_title => 'Dialog';

  @override
  String get comic_character_fallback => 'Personaj';

  @override
  String get comic_play_tooltip => 'Redă';

  @override
  String get comic_stop_tooltip => 'Oprește';

  @override
  String get comic_view_dialogue_tooltip => 'Vezi dialogul';

  @override
  String get not_enough_images_to_match => 'Not enough images to match';

  @override
  String get unknown => 'Unknown';

  @override
  String get error_loading_button => 'Eroare la încărcarea butonului';

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
  String get current_progress => 'Current progress';

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
