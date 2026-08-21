// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get about => 'Über';

  @override
  String get age => 'Alter';

  @override
  String get account => 'Konto';

  @override
  String get achievements => 'Erfolge';

  @override
  String get answer_saved => 'Antwort gespeichert';

  @override
  String get application_name => 'Ecounity';

  @override
  String get attention => 'Achtung';

  @override
  String get authenticating => 'Authentifizierung...';

  @override
  String get badge => 'Abzeichen';

  @override
  String badge_completion_status(int completed, int required) {
    return 'Du hast $completed von $required Lerninhalten abgeschlossen, die erforderlich sind, um dieses Abzeichen zu erhalten.';
  }

  @override
  String badge_description(Object pathway) {
    return 'Dieses Abzeichen wird für den Abschluss aller Lektionen und Herausforderungen im $pathway Lernpfad verliehen.';
  }

  @override
  String get button_accept => 'Akzeptieren';

  @override
  String get button_approve => 'Genehmigen';

  @override
  String get badge_awarded => 'Neues Abzeichen verliehen';

  @override
  String badge_awarded_congratulations(String badge) {
    return 'Herzlichen Glückwunsch! Sie haben das Abzeichen $badge erhalten!';
  }

  @override
  String get button_back => 'Zurück';

  @override
  String get button_cancel => 'Abbrechen';

  @override
  String get button_close => 'Schließen';

  @override
  String get button_confirm => 'Bestätigen';

  @override
  String get button_continue => 'Fortfahren';

  @override
  String get button_continue_as_guest => 'Als Gast fortfahren';

  @override
  String get button_create => 'Erstellen';

  @override
  String get button_create_account => 'Konto erstellen';

  @override
  String get button_delete => 'Löschen';

  @override
  String get button_edit => 'Bearbeiten';

  @override
  String get button_finish => 'Fertigstellen';

  @override
  String get button_forgot_password => 'Passwort vergessen?';

  @override
  String get button_login => 'Anmelden';

  @override
  String get button_logout => 'Abmelden';

  @override
  String get button_next => 'Weiter';

  @override
  String get button_ok => 'OK';

  @override
  String get button_previous => 'Zurück';

  @override
  String get button_register => 'Registrieren';

  @override
  String get button_reject => 'Ablehnen';

  @override
  String get button_save => 'Speichern';

  @override
  String get button_send => 'Senden';

  @override
  String get button_submit => 'Einreichen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get choose_language => 'Sprache wählen';

  @override
  String get collected_badges => 'Gesammelte Abzeichen';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get confirm_deleting_account =>
      'Sind Sie sicher, dass Sie Ihr Konto löschen möchten?';

  @override
  String get contact => 'Kontakt';

  @override
  String get delete_account => 'Konto löschen';

  @override
  String get email => 'E-Mail';

  @override
  String get email_not_valid => 'Die angegebene E-Mail-Adresse ist ungültig';

  @override
  String get email_or_phone_number => 'E-Mail oder Telefonnummer';

  @override
  String error(String error) {
    return 'Fehler: $error';
  }

  @override
  String get error_default => 'Anfrage konnte nicht abgeschlossen werden';

  @override
  String get error_occurred => 'Ein Fehler ist aufgetreten';

  @override
  String errorViewNotFound(String view) {
    return 'Ansicht $view nicht gefunden';
  }

  @override
  String get errors_in_form => 'Fehler im Formular';

  @override
  String field_required(String field) {
    return 'Das Feld $field ist erforderlich';
  }

  @override
  String get firstName => 'Vorname';

  @override
  String get funding_disclaimer =>
      'Von der Europäischen Union finanziert. Die geäußerten Ansichten und Meinungen entsprechen jedoch ausschließlich denen des Autors bzw. der Autoren und spiegeln nicht zwingend die der Europäischen Union oder der Europäischen Exekutivagentur für Bildung und Kultur (EACEA) wider. Weder die Europäische Union noch die EACEA können dafür verantwortlich gemacht werden.';

  @override
  String get great => 'Großartig';

  @override
  String get home => 'Startseite';

  @override
  String get introduction => 'Einführung';

  @override
  String get language => 'Sprache';

  @override
  String get select_language => 'Sprache auswählen';

  @override
  String locale(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'fi': 'Finnisch',
      'en': 'Englisch',
      'it': 'Italienisch',
      'pt': 'Portugiesisch',
      'pl': 'Polnisch',
      'de': 'Deutsch',
      'uk': 'Ukrainisch',
      'ro': 'Romanian',
      'es': 'Spanish',
      'other': 'Sprache:$language',
    });
    return '$_temp0';
  }

  @override
  String get lastName => 'Nachname';

  @override
  String get loading => 'Laden...';

  @override
  String get login => 'Anmelden';

  @override
  String get login_failed => 'Anmeldung fehlgeschlagen';

  @override
  String get logout => 'Abmelden';

  @override
  String get logout_confirmation =>
      'Sind Sie sicher, dass Sie sich abmelden möchten?';

  @override
  String get markAsCompleted => 'Als abgeschlossen markieren';

  @override
  String navigation_item(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'home': 'Startseite',
      'pathways': 'Lernpfade',
      'challenges': 'Herausforderungen',
      'videolist': 'Videos',
      'selfReflectionHub': 'Selbstreflexionszentrum',
      'lessons': 'Unterrichtseinheiten',
      'modules': 'Lernen',
      'resources': 'Ressourcen',
      'progress': 'Fortschritt',
      'teacher': 'Lehrkraft',
      'other': 'Menü:$item',
    });
    return '$_temp0';
  }

  @override
  String get next => 'Weiter';

  @override
  String get noBadgesFound => 'Keine Abzeichen gefunden';

  @override
  String get noChallengesFound => 'Keine Herausforderungen gefunden';

  @override
  String get noContentFound => 'Kein Inhalt gefunden';

  @override
  String get noPathwaysFound => 'Keine Lerninhalte gefunden';

  @override
  String get noTranscriptAvailable => 'Kein Transkript verfügbar';

  @override
  String get noVideosFound => 'Keine Videos gefunden';

  @override
  String get noLessonsFound => 'Keine Lektionen gefunden';

  @override
  String get page_content => 'Seiteninhalt';

  @override
  String get password => 'Passwort';

  @override
  String get pathway => 'Lerninhalt';

  @override
  String get pathway_already_completed => 'Lerninhalt ist abgeschlossen';

  @override
  String get pathway_completed => 'Lerninhalt abgeschlossen';

  @override
  String get phone => 'Telefon';

  @override
  String get phone_or_email => 'Telefonnummer oder E-Mail-Adresse';

  @override
  String get please_complete_form_properly =>
      'Bitte füllen Sie das Formular korrekt aus.';

  @override
  String get please_enter_password => 'Bitte geben Sie ein Passwort ein';

  @override
  String get please_enter_phone_or_email =>
      'Bitte geben Sie eine Telefonnummer oder E-Mail-Adresse ein';

  @override
  String get please_provide_valid_phone_or_email =>
      'Bitte geben Sie eine gültige Telefonnummer oder E-Mail-Adresse an';

  @override
  String get previous => 'Zurück';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get privacy_policy => 'Datenschutzrichtlinie';

  @override
  String get profile => 'Profil';

  @override
  String get register => 'Registrieren';

  @override
  String get registration_failed => 'Registrierung fehlgeschlagen';

  @override
  String get registration_successful => 'Registrierung erfolgreich';

  @override
  String registration_successful_message(String firstName) {
    return 'Willkommen bei Ecounity $firstName!';
  }

  @override
  String get references => 'Referenzen';

  @override
  String get saving_data_failed => 'Daten konnten nicht gespeichert werden';

  @override
  String get quiz_not_passed => 'Quiz nicht bestanden';

  @override
  String get screenTitle_challenges => 'Herausforderungen';

  @override
  String get screenTitle_home => 'Startseite';

  @override
  String get screenTitle_pathways => 'Lernpfade';

  @override
  String get screenTitle_selfReflectionHub => 'Selbstreflexionszentrum';

  @override
  String get screenTitle_videos => 'Videoübersicht';

  @override
  String get screenTitle_lessons => 'Unterricht';

  @override
  String get screenTitle_modules => 'Lernen';

  @override
  String get screenTitle_resources => 'Ressourcen';

  @override
  String get dashboard_no_modules_available => 'Keine Module verfügbar';

  @override
  String get dashboard_welcome_back => 'Willkommen zurück';

  @override
  String get dashboard_ready_prompt => 'Bereit, heute aktiv zu werden?';

  @override
  String get dashboard_start_learning => 'Lernen starten';

  @override
  String dashboard_continue_sdg(int sdgNumber) {
    return 'SDG $sdgNumber fortsetzen';
  }

  @override
  String dashboard_start_sdg(int sdgNumber) {
    return 'SDG $sdgNumber starten';
  }

  @override
  String get dashboard_explore_modules => 'EcoUnity-Lernmodule erkunden';

  @override
  String get dashboard_browse_modules => 'Module durchsuchen';

  @override
  String get dashboard_resume_module => 'Modul fortsetzen';

  @override
  String get dashboard_start_module => 'Modul starten';

  @override
  String get dashboard_stat_modules => 'Module';

  @override
  String get dashboard_stat_activities => 'Aktivitäten';

  @override
  String get dashboard_stat_badges => 'Abzeichen';

  @override
  String get dashboard_module_status_done => 'Fertig';

  @override
  String get dashboard_module_status_started => 'Begonnen';

  @override
  String get dashboard_module_status_new => 'Neu';

  @override
  String get dashboard_latest_challenge => 'Neueste Herausforderung';

  @override
  String get dashboard_one_minute_left => '1 Min. übrig';

  @override
  String dashboard_minutes_left(int minutes) {
    return '$minutes Min. übrig';
  }

  @override
  String get dashboard_one_minute => '1 Min.';

  @override
  String dashboard_minutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get dashboard_one_activity => '1 Aktivität';

  @override
  String dashboard_activities(int activities) {
    return '$activities Aktivitäten';
  }

  @override
  String get select => 'Auswählen';

  @override
  String get selected => 'Ausgewählt';

  @override
  String get sendAnswer => 'Antwort speichern';

  @override
  String get server => 'Systemserver';

  @override
  String get settings => 'Einstellungen';

  @override
  String get stage => 'Stufe';

  @override
  String stageValue(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'before': 'Bevor',
      'during': 'Während',
      'after': 'Nach',
      'other': 'Stufe:$item',
    });
    return '$_temp0';
  }

  @override
  String get start => 'Starten';

  @override
  String get teacher_mode => 'Lehrkraft-Modus';

  @override
  String get teacher_mode_label => 'Ich bin eine Lehrkraft';

  @override
  String get teacher_mode_description =>
      'Der Lehrkraft-Modus ergänzt Lerninhalte um Hinweise für den Unterricht. Lernfortschritt und Abzeichen sind deaktiviert, solange dieser Modus aktiv ist.';

  @override
  String get teacher_mode_enable => 'Lehrkraft-Modus aktivieren';

  @override
  String get teacher_mode_active_title => 'Lehrkraft-Modus ist aktiv';

  @override
  String get teacher_mode_active_description =>
      'In Lernaktivitäten werden Hinweise für den Unterricht angezeigt. Lernfortschritt und Abzeichen sind ausgeblendet, solange dieser Modus aktiv ist.';

  @override
  String get teacher_mode_turn_off => 'Lehrkraft-Modus ausschalten';

  @override
  String get button_add => 'Hinzufügen';

  @override
  String get learning_module_title => 'Modul';

  @override
  String learning_module_load_error(String error) {
    return 'Modul konnte nicht geladen werden: $error';
  }

  @override
  String get learning_module_not_found => 'Modul nicht gefunden';

  @override
  String get learning_empty_activities =>
      'Aktivitäten erscheinen hier, sobald dieses Modul bereit ist.';

  @override
  String learning_group_stats_for(String group) {
    return 'Gruppenstatistiken für $group werden angezeigt';
  }

  @override
  String get learning_group_stats_empty =>
      'Füge in der Lehrkraftansicht eine Gruppe hinzu und wähle sie aus, um hier Statistiken zu sehen.';

  @override
  String learning_sdg_modules_count(int count) {
    return 'SDG-Lernmodule: $count';
  }

  @override
  String learning_module_filter(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Alle',
      'started': 'Begonnen',
      'done': 'Fertig',
      'challenges': 'Herausforderungen',
      'other': 'Alle',
    });
    return '$_temp0';
  }

  @override
  String learning_no_filtered_modules(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Noch keine Module verfügbar.',
      'started': 'Noch keine begonnenen Module.',
      'done': 'Noch keine abgeschlossenen Module.',
      'challenges': 'Noch keine Herausforderungsmodule.',
      'other': 'Noch keine Module.',
    });
    return '$_temp0';
  }

  @override
  String learning_module_status(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'new': 'Neu',
      'started': 'Begonnen',
      'done': 'Fertig',
      'other': 'Neu',
    });
    return '$_temp0';
  }

  @override
  String get learning_badge_earned => 'Abzeichen erhalten';

  @override
  String get learning_in_progress => 'In Bearbeitung';

  @override
  String get learning_one_minute_left => '1 Min. übrig';

  @override
  String learning_minutes_left(int minutes) {
    return '$minutes Min. übrig';
  }

  @override
  String get learning_one_minute => '1 Min.';

  @override
  String learning_minutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get learning_one_activity => '1 Aktivität';

  @override
  String learning_activities(int activities) {
    return '$activities Aktivitäten';
  }

  @override
  String learning_activity_type(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'comic': 'Comic',
      'mlr': 'Mikrolernen',
      'quiz': 'Quiz',
      'reflection': 'Reflexion',
      'challenge': 'Herausforderung',
      'unknown': 'Aktivität',
      'other': 'Aktivität',
    });
    return '$_temp0';
  }

  @override
  String get teacher_group_statistics_title => 'Gruppenstatistiken';

  @override
  String get teacher_refresh_active_group => 'Aktive Gruppe aktualisieren';

  @override
  String get teacher_group_report_description =>
      'Füge Lehrkraft-Tokens hinzu, um aggregierten Fortschritt auf Gruppenebene zu sehen. Die App speichert nur zusammengefasste Berichte, keine Lernendenidentitäten.';

  @override
  String get teacher_token_label => 'Lehrkraft-Token';

  @override
  String get teacher_token_hint => 'ABCDEF';

  @override
  String get teacher_group => 'Gruppe';

  @override
  String get teacher_active_group => 'Aktive Gruppe';

  @override
  String get teacher_select_group => 'Gruppe auswählen';

  @override
  String teacher_token_value(String token) {
    return 'Token $token';
  }

  @override
  String get teacher_metric_enrolled => 'Eingeschrieben';

  @override
  String get teacher_metric_active => 'Aktiv';

  @override
  String get teacher_metric_completed => 'Abgeschlossen';

  @override
  String get teacher_refresh_group => 'Gruppe aktualisieren';

  @override
  String get teacher_remove_group => 'Gruppe entfernen';

  @override
  String get teacher_empty_groups =>
      'Füge ein Gruppen-Token hinzu, um Statistiken in den Lernansichten zu aktivieren.';

  @override
  String get teacher_loading_saved_groups =>
      'Gespeicherte Gruppen werden geladen...';

  @override
  String teacher_stats_opened(int opened, String total) {
    return 'Geöffnet $opened/$total';
  }

  @override
  String teacher_stats_completed(String percent) {
    return 'Abgeschlossen $percent';
  }

  @override
  String teacher_stats_activity_completion(String percent) {
    return '$percent Aktivitätsabschluss';
  }

  @override
  String teacher_stats_avg_score(String score) {
    return 'Durchschn. Punktzahl $score';
  }

  @override
  String teacher_stats_avg_score_with_max(String score, String maxScore) {
    return 'Durchschn. Punktzahl $score/$maxScore';
  }

  @override
  String get learning_objective => 'Lernziel';

  @override
  String get group_code => 'Gruppencode';

  @override
  String get group_code_title => 'Einer Lerngruppe beitreten';

  @override
  String get group_code_description =>
      'Gib den Gruppencode deiner Lehrkraft ein oder füge einen QR-Einschreibelink ein. Dein App-Fortschritt wird anonym mit dieser Gruppe verknüpft.';

  @override
  String get group_code_hint => 'Gruppencode oder Einschreibelink';

  @override
  String get group_code_required => 'Gib einen Gruppencode ein';

  @override
  String get join_group => 'Gruppe beitreten';

  @override
  String get selected_group => 'Ausgewählte Gruppe';

  @override
  String get group_connected => 'Gruppe verbunden';

  @override
  String get group_connected_message =>
      'Deine App ist nun mit der ausgewählten Lerngruppe verknüpft.';

  @override
  String get clear_group => 'Gruppe entfernen';

  @override
  String get group_code_error =>
      'Der Gruppencode wurde nicht gefunden oder ist nicht aktiv.';

  @override
  String get terms => 'Bedingungen';

  @override
  String get unnamed => 'Unbenannt';

  @override
  String get view_introduction => 'Einführung';

  @override
  String get you_have_this_badge => 'Sie haben dieses Abzeichen';

  @override
  String get your_password => 'Ihr Passwort';

  @override
  String get view_brochure => 'Broschüre anzeigen';

  @override
  String get welcome_title =>
      'Willkommen bei der Ecounity-App - Ihrem Portal für digitales Lernen, Inspiration und unternehmerisches Wachstum.';

  @override
  String get welcome_tagline => 'Gemeinsam für den Planeten!';

  @override
  String get login_introduction_text =>
      'Entdecke SDG-Lernmodule, interaktive Comics, Quizze und Unterrichts-Challenges für umweltfreundliches Handeln.';

  @override
  String get srh_description => 'Nutzen Sie diese Fragen als Denkanstoß.';

  @override
  String get srh_what_was_most_impactful_for_me =>
      'Was war für mich am wirkungsvollsten?';

  @override
  String get srh_what_will_i_put_into_practice =>
      'Was werde ich in die Praxis umsetzen?';

  @override
  String get srh_what_are_my_hopes_and_fears_for_the_future =>
      'Was sind meine Hoffnungen und Ängste für die Zukunft?';

  @override
  String get no_video_found => 'Das Video wurde nicht gefunden.';

  @override
  String get no_modules_found => 'Keine Module gefunden.';

  @override
  String get no_contents_found => 'Inhalte wurden nicht gefunden.';

  @override
  String get no_resources_found => 'Ressourcen wurden nicht gefunden.';

  @override
  String get no_images_found => 'Bilder wurden nicht gefunden.';

  @override
  String get links => 'Verweise';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get cache_cleared => 'Cache geleert. Bitte laden Sie die Seite neu.';

  @override
  String get module_completed => 'Modul abgeschlossen';

  @override
  String get mark_as_completed => 'Als abgeschlossen markieren';

  @override
  String get mark_as_not_completed => 'Als nicht abgeschlossen markieren';

  @override
  String get no_image_available => 'Kein Bild verfügbar';

  @override
  String get no_title => 'Kein Titel';

  @override
  String get items_matched => 'Elemente zugeordnet';

  @override
  String get all_items_matched => 'Alle Elemente wurden zugeordnet!';

  @override
  String get play_again => 'Nochmal spielen';

  @override
  String get not_enough_images_to_match => 'Nicht genug Bilder zum Zuordnen';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get error_loading_button => 'Fehler beim Laden der Schaltfläche';

  @override
  String get seek => 'Suchen';

  @override
  String get ok => 'OK';

  @override
  String get notification => 'Benachrichtigung';

  @override
  String modules_completion_summary(int completed, int total) {
    return '$completed von $total Modulen abgeschlossen';
  }

  @override
  String learning_contents_completion_summary(int completed, int total) {
    return '$completed von $total Lerninhalten abgeschlossen';
  }

  @override
  String get current_progress => 'Aktueller Fortschritt';

  @override
  String get next_suggestion => 'Nächster Vorschlag';

  @override
  String get next_up => 'Nächste Schritte:';

  @override
  String get congratulations => 'Glückwunsch!';

  @override
  String get you_have_completed_all_learning_contents =>
      'Du hast alle Lerninhalte abgeschlossen.';

  @override
  String get writeAnswerHere => 'Geben Sie hier Ihre Antwort ein.';

  @override
  String get fieldCannotBeEmpty => 'Dieses Feld darf nicht leer sein.';

  @override
  String get clear_answers => 'Antworten löschen';
}
