// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get about => 'Informazioni';

  @override
  String get age => 'Età';

  @override
  String get account => 'Profilo';

  @override
  String get achievements => 'Risultati';

  @override
  String get answer_saved => 'Risposta salvata';

  @override
  String get application_name => 'Ecounity';

  @override
  String get attention => 'Attenzione';

  @override
  String get authenticating => 'Autenticazione in corso...';

  @override
  String get badge => 'Distintivo';

  @override
  String badge_completion_status(int completed, int required) {
    return 'Hai completato $completed di $required contenuti formativi necessari per ottenere questo badge.';
  }

  @override
  String badge_description(Object pathway) {
    return 'Questo badge viene assegnato al completamento di tutte le lezioni e delle sfide nel percorso $pathway.';
  }

  @override
  String get button_accept => 'Accetta';

  @override
  String get button_approve => 'Approva';

  @override
  String get badge_awarded => 'Nuovo badge assegnato';

  @override
  String badge_awarded_congratulations(String badge) {
    return 'Congratulazioni! Hai ricevuto il badge $badge.';
  }

  @override
  String get button_back => 'Indietro';

  @override
  String get button_cancel => 'Annulla';

  @override
  String get button_close => 'Chiudi';

  @override
  String get button_confirm => 'Conferma';

  @override
  String get button_continue => 'Continua';

  @override
  String get button_continue_as_guest => 'Continua come ospite';

  @override
  String get button_create => 'Crea';

  @override
  String get button_create_account => 'Crea account';

  @override
  String get button_delete => 'Elimina';

  @override
  String get button_edit => 'Modifica';

  @override
  String get button_finish => 'Fine';

  @override
  String get button_forgot_password => 'Password dimenticata?';

  @override
  String get button_login => 'Accedi';

  @override
  String get button_logout => 'Esci';

  @override
  String get button_next => 'Avanti';

  @override
  String get button_ok => 'OK';

  @override
  String get button_previous => 'Precedente';

  @override
  String get button_register => 'Registrati';

  @override
  String get button_reject => 'Rifiuta';

  @override
  String get button_save => 'Salva';

  @override
  String get button_send => 'Invia';

  @override
  String get button_submit => 'Invia';

  @override
  String get cancel => 'Annulla';

  @override
  String get choose_language => 'Scegli lingua';

  @override
  String get collected_badges => 'Badge raccolti';

  @override
  String get completed => 'Completato';

  @override
  String get confirm_deleting_account =>
      'Sei sicuro di voler eliminare il tuo account?';

  @override
  String get contact => 'Contatto';

  @override
  String get delete_account => 'Elimina account';

  @override
  String get email => 'Indirizzo email';

  @override
  String get email_not_valid => 'L\'indirizzo email inserito non è valido';

  @override
  String get email_or_phone_number => 'Email o numero di telefono';

  @override
  String error(String error) {
    return 'Errore: $error';
  }

  @override
  String get error_default => 'Impossibile completare la richiesta';

  @override
  String get error_occurred => 'Si è verificato un errore';

  @override
  String errorViewNotFound(String view) {
    return 'Vista $view non trovata';
  }

  @override
  String get errors_in_form => 'Errori nel modulo';

  @override
  String field_required(String field) {
    return 'Il campo $field è obbligatorio';
  }

  @override
  String get firstName => 'Nome';

  @override
  String get funding_disclaimer =>
      'Finanziato dall\'Unione europea. Le opinioni espresse appartengono, tuttavia, al solo o ai soli autori e non riflettono necessariamente le opinioni dell\'Unione europea o dell’Agenzia esecutiva europea per l’istruzione e la cultura (EACEA). Né l\'Unione europea né l\'EACEA possono esserne ritenute responsabili.';

  @override
  String get great => 'Ottimo';

  @override
  String get home => 'Inizio';

  @override
  String get introduction => 'Introduzione';

  @override
  String get language => 'Lingua';

  @override
  String get select_language => 'Seleziona lingua';

  @override
  String locale(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'it': 'Italiano',
      'fi': 'Finlandese',
      'en': 'Inglese',
      'pl': 'Polacca',
      'pt': 'Portoghese',
      'de': 'Tedesca',
      'uk': 'Ucraina',
      'ro': 'Romanian',
      'es': 'Spanish',
      'other': 'Lingua:$language',
    });
    return '$_temp0';
  }

  @override
  String get lastName => 'Cognome';

  @override
  String get loading => 'Caricamento...';

  @override
  String get login => 'Accedi';

  @override
  String get login_failed => 'Accesso non riuscito';

  @override
  String get logout => 'Esci';

  @override
  String get logout_confirmation => 'Sei sicuro di voler uscire?';

  @override
  String get markAsCompleted => 'Segna come completato';

  @override
  String navigation_item(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'home': 'Home',
      'pathways': 'Percorsi',
      'challenges': 'Sfide',
      'videolist': 'Video',
      'selfReflectionHub': 'Centro auto-riflessione',
      'lessons': 'Lezioni',
      'modules': 'Impara',
      'resources': 'Risorse',
      'progress': 'Progresso',
      'teacher': 'Docente',
      'other': 'Menu:$item',
    });
    return '$_temp0';
  }

  @override
  String get next => 'Avanti';

  @override
  String get noBadgesFound => 'Nessun badge trovato';

  @override
  String get noChallengesFound => 'Nessuna sfida trovata';

  @override
  String get noContentFound => 'Nessun contenuto trovato';

  @override
  String get noPathwaysFound => 'Nessun contenuto formativo trovato';

  @override
  String get noTranscriptAvailable => 'Nessuna trascrizione disponibile';

  @override
  String get noVideosFound => 'Nessun video trovato';

  @override
  String get noLessonsFound => 'Nessuna lezione trovata';

  @override
  String get page_content => 'Contenuto della pagina';

  @override
  String get password => 'Parola d\'accesso';

  @override
  String get pathway => 'Contenuto formativo';

  @override
  String get pathway_already_completed =>
      'Il contenuto formativo è stato completato';

  @override
  String get pathway_completed => 'Contenuto formativo completato';

  @override
  String get phone => 'Telefono';

  @override
  String get phone_or_email => 'Numero di telefono o indirizzo email';

  @override
  String get please_complete_form_properly => 'Compila correttamente il modulo';

  @override
  String get please_enter_password => 'Inserisci una password';

  @override
  String get please_enter_phone_or_email =>
      'Inserisci un numero di telefono o un indirizzo email';

  @override
  String get please_provide_valid_phone_or_email =>
      'Inserisci un numero di telefono o un indirizzo email valido';

  @override
  String get previous => 'Precedente';

  @override
  String get privacy => 'Riservatezza';

  @override
  String get privacy_policy => 'Politica sulla privacy';

  @override
  String get profile => 'Profilo';

  @override
  String get register => 'Registrati';

  @override
  String get registration_failed => 'Registrazione fallita';

  @override
  String get registration_successful => 'Registrazione completata con successo';

  @override
  String registration_successful_message(String firstName) {
    return 'Benvenuto in Ecounity $firstName!';
  }

  @override
  String get references => 'Riferimenti';

  @override
  String get saving_data_failed => 'Errore durante il salvataggio dei dati';

  @override
  String get quiz_not_passed => 'Quiz non superato';

  @override
  String get screenTitle_challenges => 'Sfide';

  @override
  String get screenTitle_home => 'Inizio';

  @override
  String get screenTitle_pathways => 'Percorsi';

  @override
  String get screenTitle_selfReflectionHub => 'Centro di auto-riflessione';

  @override
  String get screenTitle_videos => 'Video';

  @override
  String get screenTitle_lessons => 'Lezioni';

  @override
  String get screenTitle_modules => 'Impara';

  @override
  String get screenTitle_resources => 'Risorse';

  @override
  String get dashboard_no_modules_available => 'Nessun modulo disponibile';

  @override
  String get dashboard_welcome_back => 'Bentornato';

  @override
  String get dashboard_ready_prompt => 'Pronto ad agire oggi?';

  @override
  String get dashboard_start_learning => 'Inizia a imparare';

  @override
  String dashboard_continue_sdg(int sdgNumber) {
    return 'Continua SDG $sdgNumber';
  }

  @override
  String dashboard_start_sdg(int sdgNumber) {
    return 'Inizia SDG $sdgNumber';
  }

  @override
  String get dashboard_explore_modules =>
      'Esplora i moduli di apprendimento EcoUnity';

  @override
  String get dashboard_browse_modules => 'Sfoglia i moduli';

  @override
  String get dashboard_resume_module => 'Riprendi modulo';

  @override
  String get dashboard_start_module => 'Inizia modulo';

  @override
  String get dashboard_stat_modules => 'Moduli';

  @override
  String get dashboard_stat_activities => 'Attività';

  @override
  String get dashboard_stat_badges => 'Badge';

  @override
  String get dashboard_module_status_done => 'Completato';

  @override
  String get dashboard_module_status_started => 'Iniziato';

  @override
  String get dashboard_module_status_new => 'Nuovo';

  @override
  String get dashboard_latest_challenge => 'Ultima sfida';

  @override
  String get dashboard_one_minute_left => '1 min rimasto';

  @override
  String dashboard_minutes_left(int minutes) {
    return '$minutes min rimasti';
  }

  @override
  String get dashboard_one_minute => '1 min';

  @override
  String dashboard_minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get dashboard_one_activity => '1 attività';

  @override
  String dashboard_activities(int activities) {
    return '$activities attività';
  }

  @override
  String get select => 'Seleziona';

  @override
  String get selected => 'Selezionato';

  @override
  String get sendAnswer => 'Salva risposta';

  @override
  String get server => 'Server applicativo';

  @override
  String get settings => 'Impostazioni';

  @override
  String get stage => 'Fase';

  @override
  String stageValue(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'before': 'Prima',
      'during': 'Durante',
      'after': 'Dopo',
      'other': '$item',
    });
    return '$_temp0';
  }

  @override
  String get start => 'Inizia';

  @override
  String get teacher_mode => 'Modalità docente';

  @override
  String get teacher_mode_label => 'Sono un docente';

  @override
  String get teacher_mode_description =>
      'La modalità docente aggiunge informazioni didattiche ai contenuti. I progressi degli studenti e i badge sono disattivati mentre questa modalità è attiva.';

  @override
  String get teacher_mode_enable => 'Attiva modalità docente';

  @override
  String get teacher_mode_active_title => 'La modalità docente è attiva';

  @override
  String get teacher_mode_active_description =>
      'Le attività mostrano informazioni didattiche. I progressi degli studenti e i badge restano nascosti mentre questa modalità è attiva.';

  @override
  String get teacher_mode_turn_off => 'Disattiva modalità docente';

  @override
  String get button_add => 'Aggiungi';

  @override
  String get learning_module_title => 'Modulo';

  @override
  String learning_module_load_error(String error) {
    return 'Impossibile caricare il modulo: $error';
  }

  @override
  String get learning_module_not_found => 'Modulo non trovato';

  @override
  String get learning_empty_activities =>
      'Le attività appariranno qui quando questo modulo sarà pronto.';

  @override
  String learning_group_stats_for(String group) {
    return 'Statistiche del gruppo $group visualizzate';
  }

  @override
  String get learning_group_stats_empty =>
      'Aggiungi e seleziona un gruppo docente nella vista Docente per mostrare qui le statistiche.';

  @override
  String learning_sdg_modules_count(int count) {
    return 'Moduli di apprendimento SDG: $count';
  }

  @override
  String learning_module_filter(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Tutti',
      'started': 'Iniziati',
      'done': 'Completati',
      'challenges': 'Sfide',
      'other': 'Tutti',
    });
    return '$_temp0';
  }

  @override
  String learning_no_filtered_modules(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Non ci sono ancora moduli disponibili.',
      'started': 'Non ci sono ancora moduli iniziati.',
      'done': 'Non ci sono ancora moduli completati.',
      'challenges': 'Non ci sono ancora moduli di sfida.',
      'other': 'Non ci sono ancora moduli.',
    });
    return '$_temp0';
  }

  @override
  String learning_module_status(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'new': 'Nuovo',
      'started': 'Iniziato',
      'done': 'Completato',
      'other': 'Nuovo',
    });
    return '$_temp0';
  }

  @override
  String get learning_badge_earned => 'Badge ottenuto';

  @override
  String get learning_in_progress => 'In corso';

  @override
  String get learning_one_minute_left => '1 min rimasto';

  @override
  String learning_minutes_left(int minutes) {
    return '$minutes min rimasti';
  }

  @override
  String get learning_one_minute => '1 min';

  @override
  String learning_minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get learning_one_activity => '1 attività';

  @override
  String learning_activities(int activities) {
    return '$activities attività';
  }

  @override
  String learning_activity_type(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'comic': 'Fumetto',
      'mlr': 'Micro-apprendimento',
      'quiz': 'Quiz',
      'reflection': 'Riflessione',
      'challenge': 'Sfida',
      'unknown': 'Attività',
      'other': 'Attività',
    });
    return '$_temp0';
  }

  @override
  String learning_module_difficulty(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      'beginner': 'Principiante',
      'intermediate': 'Intermedio',
      'advanced': 'Avanzato',
      'easy': 'Facile',
      'medium': 'Medio',
      'hard': 'Difficile',
      'classroom_activity': 'Attività in classe',
      'home_activity': 'Attività a casa',
      'group_challenge': 'Sfida di gruppo',
      'other': '$level',
    });
    return '$_temp0';
  }

  @override
  String learning_activity_load_error(String error) {
    return 'Impossibile caricare l\'attività: $error';
  }

  @override
  String get learning_activity_not_found => 'Attività non trovata';

  @override
  String get learning_submit_reflection => 'Invia riflessione';

  @override
  String get learning_complete_challenge => 'Completa la sfida';

  @override
  String get learning_write_response_hint => 'Scrivi la tua risposta';

  @override
  String get learning_reflection_prompt_title => 'Pensaci';

  @override
  String get quiz_no_questions_title => 'Nessuna domanda disponibile';

  @override
  String get quiz_no_questions_message =>
      'Questo quiz al momento non include domande.';

  @override
  String quiz_question_progress(int current, int total) {
    return 'Domanda $current di $total';
  }

  @override
  String get quiz_no_answer_options_title => 'Nessuna opzione di risposta';

  @override
  String get quiz_no_answer_options_message =>
      'Questa domanda al momento non include opzioni di risposta.';

  @override
  String get quiz_submit_answers => 'Invia risposte';

  @override
  String quiz_result_passed(int score, int total) {
    return 'Superato: $score/$total';
  }

  @override
  String quiz_result_try_again(int score, int total) {
    return 'Riprova: $score/$total';
  }

  @override
  String get progress_load_error_title => 'Impossibile caricare i progressi';

  @override
  String get progress_empty_message =>
      'I moduli di apprendimento appariranno qui dopo il caricamento.';

  @override
  String get progress_journey_title => 'Il mio percorso di apprendimento';

  @override
  String progress_overall_complete(int percent) {
    return '$percent% completato';
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
      other: 'moduli',
      one: 'modulo',
    );
    String _temp1 = intl.Intl.pluralLogic(
      activeChallenges,
      locale: localeName,
      other: 'sfide',
      one: 'sfida',
    );
    String _temp2 = intl.Intl.pluralLogic(
      earnedBadges,
      locale: localeName,
      other: 'badge',
      one: 'badge',
    );
    return '$completedModules $_temp0 completati, $activeChallenges $_temp1 attive, $earnedBadges $_temp2 ottenuti';
  }

  @override
  String progress_segment(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'earned': 'Ottenuti',
      'locked': 'Bloccati',
      'modules': 'Progresso moduli',
      'other': 'Progresso',
    });
    return '$_temp0';
  }

  @override
  String get progress_no_badges_earned_title => 'Nessun badge ancora ottenuto';

  @override
  String get progress_no_badges_earned_message =>
      'Completa le attività richieste per sbloccare il tuo primo badge.';

  @override
  String get progress_all_badges_earned_title => 'Tutti i badge ottenuti';

  @override
  String get progress_all_badges_earned_message =>
      'Hai sbloccato tutti i badge disponibili.';

  @override
  String progress_badge_status(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'earned': 'Ottenuto',
      'locked': 'Bloccato',
      'other': 'Badge',
    });
    return '$_temp0';
  }

  @override
  String get progress_no_modules_title =>
      'Ancora nessun modulo di apprendimento';

  @override
  String get progress_no_modules_message =>
      'Il progresso dei moduli apparirà qui dopo il caricamento dei contenuti.';

  @override
  String progress_module_activities(int completed, int total) {
    return '$completed / $total attività';
  }

  @override
  String get progress_suggested_module => 'Prossimo modulo suggerito';

  @override
  String progress_continue_with(String activityTitle) {
    return 'Continua con $activityTitle';
  }

  @override
  String get progress_final_badge_title => 'Finale EcoUnity';

  @override
  String get progress_final_badge_description =>
      'Completa tutti i moduli di apprendimento per sbloccare il badge finale.';

  @override
  String get learning_module_fallback => 'Modulo di apprendimento';

  @override
  String get learning_module_badge_fallback => 'Badge del modulo';

  @override
  String get teacher_group_statistics_title => 'Statistiche gruppo';

  @override
  String get teacher_refresh_active_group => 'Aggiorna gruppo attivo';

  @override
  String get teacher_group_report_description =>
      'Aggiungi token docente per vedere il progresso aggregato del gruppo. L\'app salva solo report di sintesi, non identità degli studenti.';

  @override
  String get teacher_token_label => 'Token docente';

  @override
  String get teacher_token_hint => 'ABCDEF';

  @override
  String get teacher_group => 'Gruppo';

  @override
  String get teacher_active_group => 'Gruppo attivo';

  @override
  String get teacher_select_group => 'Seleziona gruppo';

  @override
  String teacher_token_value(String token) {
    return 'Token $token';
  }

  @override
  String get teacher_metric_enrolled => 'Iscritti';

  @override
  String get teacher_metric_active => 'Attivi';

  @override
  String get teacher_metric_completed => 'Completato';

  @override
  String get teacher_refresh_group => 'Aggiorna gruppo';

  @override
  String get teacher_remove_group => 'Rimuovi gruppo';

  @override
  String get teacher_empty_groups =>
      'Aggiungi un token gruppo per abilitare le statistiche nelle viste di apprendimento.';

  @override
  String get teacher_loading_saved_groups => 'Caricamento gruppi salvati...';

  @override
  String teacher_stats_opened(int opened, String total) {
    return 'Aperto $opened/$total';
  }

  @override
  String teacher_stats_completed(String percent) {
    return 'Completato $percent';
  }

  @override
  String teacher_stats_activity_completion(String percent) {
    return '$percent completamento attività';
  }

  @override
  String teacher_stats_avg_score(String score) {
    return 'Punteggio medio $score';
  }

  @override
  String teacher_stats_avg_score_with_max(String score, String maxScore) {
    return 'Punteggio medio $score/$maxScore';
  }

  @override
  String get learning_objective => 'Obiettivo di apprendimento';

  @override
  String get group_code => 'Codice gruppo';

  @override
  String get group_code_title => 'Unisciti a un gruppo di apprendimento';

  @override
  String get group_code_description =>
      'Inserisci il codice gruppo del docente o incolla un link di iscrizione QR. I progressi nell\'app saranno collegati al gruppo in modo anonimo.';

  @override
  String get group_code_hint => 'Codice gruppo o link di iscrizione';

  @override
  String get group_code_required => 'Inserisci un codice gruppo';

  @override
  String get join_group => 'Unisciti al gruppo';

  @override
  String get selected_group => 'Gruppo selezionato';

  @override
  String get group_connected => 'Gruppo collegato';

  @override
  String get group_connected_message =>
      'L\'app è ora collegata al gruppo di apprendimento selezionato.';

  @override
  String get clear_group => 'Rimuovi gruppo';

  @override
  String get group_code_error =>
      'Il codice gruppo non è stato trovato o non è attivo.';

  @override
  String get terms => 'Termini';

  @override
  String get unnamed => 'Senza nome';

  @override
  String get view_introduction => 'Introduzione';

  @override
  String get you_have_this_badge => 'Hai questo badge';

  @override
  String get your_password => 'La tua password';

  @override
  String get view_brochure => 'Visualizza brochure';

  @override
  String get welcome_title =>
      'Benvenuto nell\'app Ecounity - la tua porta d\'accesso a apprendimento digitale, ispirazione e crescita imprenditoriale.';

  @override
  String get welcome_tagline => 'Insieme per il pianeta!';

  @override
  String get login_introduction_text =>
      'Inizia a esplorare moduli di apprendimento sugli SDG, fumetti interattivi, quiz e sfide in classe per azioni rispettose del pianeta.';

  @override
  String get srh_description => 'Usa queste domande come spunto.';

  @override
  String get srh_what_was_most_impactful_for_me =>
      'Cosa è stato più significativo per me?';

  @override
  String get srh_what_will_i_put_into_practice => 'Cosa metterò in pratica?';

  @override
  String get srh_what_are_my_hopes_and_fears_for_the_future =>
      'Quali sono le mie speranze e paure per il futuro?';

  @override
  String get no_video_found => 'Il video non è stato trovato.';

  @override
  String get no_modules_found => 'Nessun modulo trovato.';

  @override
  String get no_contents_found => 'I contenuti non sono stati trovati.';

  @override
  String get no_resources_found => 'Le risorse non sono state trovate.';

  @override
  String get no_images_found => 'Nessuna immagine trovata.';

  @override
  String get links => 'Link';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get cache_cleared => 'Cache cancellata. Ricarica la pagina.';

  @override
  String get module_completed => 'Modulo completato';

  @override
  String get mark_as_completed => 'Segna come completato';

  @override
  String get mark_as_not_completed => 'Segna come non completato';

  @override
  String get no_image_available => 'Nessuna immagine disponibile';

  @override
  String get no_title => 'Nessun titolo';

  @override
  String get items_matched => 'Elementi abbinati';

  @override
  String get all_items_matched => 'Tutti gli elementi sono stati abbinati!';

  @override
  String get play_again => 'Rigioca';

  @override
  String get comic_no_scenes_available =>
      'Non ci sono scene del fumetto disponibili';

  @override
  String get comic_loading_scene => 'Caricamento scena...';

  @override
  String get comic_playing => 'Riproduzione...';

  @override
  String get comic_complete_action => 'Completa';

  @override
  String get comic_loading_next_scenes => 'Caricamento scene successive...';

  @override
  String get comic_dialogue_title => 'Dialogo';

  @override
  String get comic_character_fallback => 'Personaggio';

  @override
  String get comic_play_tooltip => 'Riproduci';

  @override
  String get comic_stop_tooltip => 'Interrompi';

  @override
  String get comic_view_dialogue_tooltip => 'Visualizza dialogo';

  @override
  String get not_enough_images_to_match =>
      'Non ci sono abbastanza immagini da abbinare';

  @override
  String get unknown => 'Sconosciuto';

  @override
  String get error_loading_button =>
      'Errore durante il caricamento del pulsante';

  @override
  String get seek => 'Cerca';

  @override
  String get ok => 'OK';

  @override
  String get notification => 'Notifica';

  @override
  String modules_completion_summary(int completed, int total) {
    return '$completed di $total moduli completati';
  }

  @override
  String learning_contents_completion_summary(int completed, int total) {
    return '$completed di $total contenuti formativi completati';
  }

  @override
  String get current_progress => 'Progresso attuale';

  @override
  String get next_suggestion => 'Prossimo suggerimento';

  @override
  String get next_up => 'Prossimo:';

  @override
  String get congratulations => 'Congratulazioni!';

  @override
  String get you_have_completed_all_learning_contents =>
      'Hai completato tutti i contenuti formativi.';

  @override
  String get writeAnswerHere => 'Scrivi qui la tua risposta.';

  @override
  String get fieldCannotBeEmpty => 'Questo campo non può essere vuoto.';

  @override
  String get clear_answers => 'Cancella risposte';
}
