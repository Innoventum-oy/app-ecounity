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
      'modules': 'Moduli',
      'resources': 'Risorse',
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
  String get screenTitle_modules => 'Moduli';

  @override
  String get screenTitle_resources => 'Risorse';

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
  String get login_introduction_text =>
      'Esplora le risorse di micro-learning, i video e le storie di successo del Flipped Classroom con strumenti pratici che completano il curriculum Ecounity e rafforzano le competenze di imprenditorialità sociale.';

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
