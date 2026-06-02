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
  String get answer_saved => 'Answer saved';

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
    return 'You have completed $completed out of $required learning contents required to earn this badge.';
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
  String get errors_in_form => 'Errors in form';

  @override
  String field_required(String field) {
    return 'Das Feld $field ist erforderlich';
  }

  @override
  String get firstName => 'Vorname';

  @override
  String get funding_disclaimer =>
      'Finanziert von der Europäischen Union. Die geäußerten Ansichten und Meinungen sind jedoch ausschließlich die der Autor(en) und spiegeln nicht unbedingt die der Europäischen Union oder der Europäischen Exekutivagentur für Bildung und Kultur (EACEA) wider. Weder die Europäische Union noch die EACEA können dafür verantwortlich gemacht werden.';

  @override
  String get great => 'Great';

  @override
  String get home => 'Startseite';

  @override
  String get introduction => 'Introduction';

  @override
  String get language => 'Sprache';

  @override
  String get select_language => 'Select language';

  @override
  String locale(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'fi': 'Finnisch',
      'en': 'Englisch',
      'pl': 'Polnisch',
      'de': 'Deutsch',
      'uk': 'Ukrainisch',
      'ro': 'Rumänisch',
      'es': 'Spanisch',
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
      'other': 'Menü:$item',
    });
    return '$_temp0';
  }

  @override
  String get next => 'Next';

  @override
  String get noBadgesFound => 'Keine Abzeichen gefunden';

  @override
  String get noChallengesFound => 'Keine Herausforderungen gefunden';

  @override
  String get noContentFound => 'Kein Inhalt gefunden';

  @override
  String get noPathwaysFound => 'No learning contents were found';

  @override
  String get noTranscriptAvailable => 'Kein Transkript verfügbar';

  @override
  String get noVideosFound => 'Keine Videos gefunden';

  @override
  String get noLessonsFound => 'No lessons were found';

  @override
  String get page_content => 'Seiteninhalt';

  @override
  String get password => 'Passwort';

  @override
  String get pathway => 'Learning content';

  @override
  String get pathway_already_completed => 'Learning content is completed';

  @override
  String get pathway_completed => 'Learning content completed';

  @override
  String get phone => 'Telefon';

  @override
  String get phone_or_email => 'Telefonnummer oder E-Mail-Adresse';

  @override
  String get please_complete_form_properly =>
      'Please complete the form properly';

  @override
  String get please_enter_password => 'Bitte geben Sie ein Passwort ein';

  @override
  String get please_enter_phone_or_email =>
      'Bitte geben Sie eine Telefonnummer oder E-Mail-Adresse ein';

  @override
  String get please_provide_valid_phone_or_email =>
      'Bitte geben Sie eine gültige Telefonnummer oder E-Mail-Adresse an';

  @override
  String get previous => 'Previous';

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
  String get saving_data_failed => 'Saving data failed';

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
  String get screenTitle_videos => 'Videos';

  @override
  String get screenTitle_lessons => 'Unterricht';

  @override
  String get screenTitle_modules => 'Modules';

  @override
  String get screenTitle_resources => 'Resources';

  @override
  String get select => 'Auswählen';

  @override
  String get selected => 'Ausgewählt';

  @override
  String get sendAnswer => 'Antwort senden';

  @override
  String get server => 'Server';

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
      'Welcome to the Ecounity App - your gateway to digital learning, inspiration, and entrepreneurial growth.';

  @override
  String get login_introduction_text =>
      'Explore Flipped Classroom micro-learning resources, videos, and success stories with practical tools that complement the Ecounity Curriculum and strengthen social entrepreneurship skills.';

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
  String get refresh => 'Aktualisieren';

  @override
  String get cache_cleared => 'Cache geleert. Bitte laden Sie die Seite neu.';

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
  String get not_enough_images_to_match => 'Not enough images to match';

  @override
  String get unknown => 'Unknown';

  @override
  String get error_loading_button => 'Error loading button';

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
