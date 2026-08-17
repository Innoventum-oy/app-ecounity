// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get about => 'O aplikacji';

  @override
  String get age => 'Wiek';

  @override
  String get account => 'Konto';

  @override
  String get achievements => 'Osiągnięcia';

  @override
  String get answer_saved => 'Odpowiedź zapisana';

  @override
  String get application_name => 'Ecounity';

  @override
  String get attention => 'Uwaga';

  @override
  String get authenticating => 'Uwierzytelnianie...';

  @override
  String get badge => 'Odznaka';

  @override
  String badge_completion_status(int completed, int required) {
    return 'Ukończyłeś $completed z $required treści, aby zdobyć tę odznakę.';
  }

  @override
  String badge_description(Object pathway) {
    return 'Ta odznaka jest przyznawana po ukończeniu wszystkich lekcji i wyzwań w ścieżce $pathway.';
  }

  @override
  String get button_accept => 'Zaakceptuj';

  @override
  String get button_approve => 'Zatwierdź';

  @override
  String get badge_awarded => 'Przyznano nową odznakę';

  @override
  String badge_awarded_congratulations(String badge) {
    return 'Gratulacje! Otrzymałeś odznakę $badge.';
  }

  @override
  String get button_back => 'Wstecz';

  @override
  String get button_cancel => 'Anuluj';

  @override
  String get button_close => 'Zamknij';

  @override
  String get button_confirm => 'Potwierdź';

  @override
  String get button_continue => 'Kontynuuj';

  @override
  String get button_continue_as_guest => 'Kontynuuj jako gość';

  @override
  String get button_create => 'Utwórz';

  @override
  String get button_create_account => 'Utwórz konto';

  @override
  String get button_delete => 'Usuń';

  @override
  String get button_edit => 'Edytuj';

  @override
  String get button_finish => 'Zakończ';

  @override
  String get button_forgot_password => 'Zapomniałeś hasła?';

  @override
  String get button_login => 'Zaloguj się';

  @override
  String get button_logout => 'Wyloguj się';

  @override
  String get button_next => 'Dalej';

  @override
  String get button_ok => 'OK';

  @override
  String get button_previous => 'Poprzedni';

  @override
  String get button_register => 'Zarejestruj';

  @override
  String get button_reject => 'Odrzuć';

  @override
  String get button_save => 'Zapisz';

  @override
  String get button_send => 'Wyślij';

  @override
  String get button_submit => 'Prześlij';

  @override
  String get cancel => 'Anuluj';

  @override
  String get choose_language => 'Wybierz język';

  @override
  String get collected_badges => 'Zebrane odznaki';

  @override
  String get completed => 'Ukończone';

  @override
  String get confirm_deleting_account =>
      'Czy na pewno chcesz usunąć swoje konto?';

  @override
  String get contact => 'Kontakt';

  @override
  String get delete_account => 'Usuń konto';

  @override
  String get email => 'E-mail';

  @override
  String get email_not_valid => 'Podany adres e-mail nie jest poprawny';

  @override
  String get email_or_phone_number => 'Adres e-mail lub numer telefonu';

  @override
  String error(String error) {
    return 'Błąd: $error';
  }

  @override
  String get error_default => 'Nie udało się wykonać żądania';

  @override
  String get error_occurred => 'Wystąpił błąd';

  @override
  String errorViewNotFound(String view) {
    return 'Widok $view nie został znaleziony';
  }

  @override
  String get errors_in_form => 'Błędy w formularzu';

  @override
  String field_required(String field) {
    return 'Pole $field jest wymagane';
  }

  @override
  String get firstName => 'Imię';

  @override
  String get funding_disclaimer =>
      'Sfinansowane ze środków UE. Wyrażone poglądy i opinie są jedynie opiniami autora lub autorów i niekoniecznie odzwierciedlają poglądy i opinie Unii Europejskiej lub Europejskiej Agencji Wykonawczej ds. Edukacji i Kultury (EACEA). Unia Europejska ani EACEA nie ponoszą za nie odpowiedzialności.';

  @override
  String get great => 'Świetnie';

  @override
  String get home => 'Strona główna';

  @override
  String get introduction => 'Wstęp';

  @override
  String get language => 'Język';

  @override
  String get select_language => 'Wybierz język';

  @override
  String locale(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'pl': 'Polski',
      'en': 'Angielski',
      'fi': 'Fiński',
      'de': 'Niemiecki',
      'pt': 'Portugalski',
      'uk': 'Ukraiński',
      'it': 'Włoski',
      'ro': 'Romanian',
      'es': 'Spanish',
      'other': 'Język:$language',
    });
    return '$_temp0';
  }

  @override
  String get lastName => 'Nazwisko';

  @override
  String get loading => 'Ładowanie...';

  @override
  String get login => 'Zaloguj się';

  @override
  String get login_failed => 'Logowanie nie powiodło się';

  @override
  String get logout => 'Wyloguj się';

  @override
  String get logout_confirmation => 'Czy na pewno chcesz się wylogować?';

  @override
  String get markAsCompleted => 'Oznacz jako ukończone';

  @override
  String navigation_item(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'home': 'Strona główna',
      'pathways': 'Ścieżki',
      'challenges': 'Wyzwania',
      'videolist': 'Filmy',
      'selfReflectionHub': 'Centrum auto-refleksji',
      'lessons': 'Lekcje',
      'modules': 'Nauka',
      'resources': 'Zasoby',
      'other': 'Menu:$item',
    });
    return '$_temp0';
  }

  @override
  String get next => 'Dalej';

  @override
  String get noBadgesFound => 'Nie znaleziono odznak';

  @override
  String get noChallengesFound => 'Nie znaleziono wyzwań';

  @override
  String get noContentFound => 'Nie znaleziono treści';

  @override
  String get noPathwaysFound => 'Nie znaleziono treści szkoleniowych';

  @override
  String get noTranscriptAvailable => 'Brak dostępnego transkryptu';

  @override
  String get noVideosFound => 'Nie znaleziono filmów';

  @override
  String get noLessonsFound => 'Nie znaleziono lekcji';

  @override
  String get page_content => 'Treść strony';

  @override
  String get password => 'Hasło';

  @override
  String get pathway => 'Treść szkoleniowa';

  @override
  String get pathway_already_completed => 'Treść szkoleniowa została ukończona';

  @override
  String get pathway_completed => 'Treść szkoleniowa ukończona';

  @override
  String get phone => 'Telefon';

  @override
  String get phone_or_email => 'Numer telefonu lub adres e-mail';

  @override
  String get please_complete_form_properly =>
      'Proszę poprawnie wypełnić formularz';

  @override
  String get please_enter_password => 'Wprowadź hasło';

  @override
  String get please_enter_phone_or_email =>
      'Wprowadź numer telefonu lub adres e-mail';

  @override
  String get please_provide_valid_phone_or_email =>
      'Wprowadź poprawny numer telefonu lub adres e-mail';

  @override
  String get previous => 'Wstecz';

  @override
  String get privacy => 'Prywatność';

  @override
  String get privacy_policy => 'Polityka prywatności';

  @override
  String get profile => 'Profil';

  @override
  String get register => 'Zarejestruj się';

  @override
  String get registration_failed => 'Rejestracja nie powiodła się';

  @override
  String get registration_successful => 'Rejestracja zakończona pomyślnie';

  @override
  String registration_successful_message(String firstName) {
    return 'Witaj w Ecounity $firstName!';
  }

  @override
  String get references => 'Odnośniki';

  @override
  String get saving_data_failed => 'Nie udało się zapisać danych';

  @override
  String get quiz_not_passed => 'Quiz niezaliczony';

  @override
  String get screenTitle_challenges => 'Wyzwania';

  @override
  String get screenTitle_home => 'Strona główna';

  @override
  String get screenTitle_pathways => 'Ścieżki';

  @override
  String get screenTitle_selfReflectionHub => 'Centrum auto-refleksji';

  @override
  String get screenTitle_videos => 'Filmy';

  @override
  String get screenTitle_lessons => 'Lekcje';

  @override
  String get screenTitle_modules => 'Nauka';

  @override
  String get screenTitle_resources => 'Zasoby';

  @override
  String get select => 'Wybierz';

  @override
  String get selected => 'Wybrano';

  @override
  String get sendAnswer => 'Zapisz odpowiedź';

  @override
  String get server => 'Serwer';

  @override
  String get settings => 'Ustawienia';

  @override
  String get stage => 'Etap';

  @override
  String stageValue(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'before': 'Przed',
      'during': 'W trakcie',
      'after': 'Po',
      'other': '$item',
    });
    return '$_temp0';
  }

  @override
  String get start => 'Rozpocznij';

  @override
  String get terms => 'Regulamin';

  @override
  String get unnamed => 'Bez nazwy';

  @override
  String get view_introduction => 'Wstęp';

  @override
  String get you_have_this_badge => 'Masz tę odznakę';

  @override
  String get your_password => 'Twoje hasło';

  @override
  String get view_brochure => 'Zobacz broszurę';

  @override
  String get welcome_title =>
      'Witaj w aplikacji Ecounity – Twoich bramie do cyfrowej nauki, inspiracji i rozwoju przedsiębiorczego.';

  @override
  String get login_introduction_text =>
      'Zacznij odkrywać moduły edukacyjne SDG, interaktywne komiksy, quizy i wyzwania klasowe, które zachęcają do działań przyjaznych planecie.';

  @override
  String get srh_description => 'Użyj tych pytań jako punktu do refleksji.';

  @override
  String get srh_what_was_most_impactful_for_me =>
      'Co było dla mnie najbardziej przemawiające?';

  @override
  String get srh_what_will_i_put_into_practice =>
      'Co zamierzam wdrożyć w praktyce?';

  @override
  String get srh_what_are_my_hopes_and_fears_for_the_future =>
      'Jakie są moje nadzieje i obawy na przyszłość?';

  @override
  String get no_video_found => 'Nie znaleziono filmu.';

  @override
  String get no_modules_found => 'Nie znaleziono modułów.';

  @override
  String get no_contents_found => 'Nie znaleziono treści.';

  @override
  String get no_resources_found => 'Nie znaleziono zasobów.';

  @override
  String get no_images_found => 'Nie znaleziono obrazów.';

  @override
  String get links => 'Linki';

  @override
  String get refresh => 'Odśwież';

  @override
  String get cache_cleared => 'Pamięć podręczna wyczyszczona. Odśwież stronę.';

  @override
  String get module_completed => 'Moduł ukończony';

  @override
  String get mark_as_completed => 'Oznacz jako ukończone';

  @override
  String get mark_as_not_completed => 'Oznacz jako nieukończone';

  @override
  String get no_image_available => 'Brak obrazka';

  @override
  String get no_title => 'Brak tytułu';

  @override
  String get items_matched => 'Połączone elementy';

  @override
  String get all_items_matched => 'Wszystkie elementy połączone!';

  @override
  String get play_again => 'Zagraj ponownie';

  @override
  String get not_enough_images_to_match => 'Za mało obrazów do dopasowania';

  @override
  String get unknown => 'Nieznane';

  @override
  String get error_loading_button => 'Błąd podczas ładowania przycisku';

  @override
  String get seek => 'Szukaj';

  @override
  String get ok => 'OK';

  @override
  String get notification => 'Powiadomienie';

  @override
  String modules_completion_summary(int completed, int total) {
    return 'Ukończono $completed z $total modułów';
  }

  @override
  String learning_contents_completion_summary(int completed, int total) {
    return 'Ukończono $completed z $total treści szkoleniowych';
  }

  @override
  String get current_progress => 'Aktualny postęp';

  @override
  String get next_suggestion => 'Następna sugestia';

  @override
  String get next_up => 'Następny krok:';

  @override
  String get congratulations => 'Gratulacje!';

  @override
  String get you_have_completed_all_learning_contents =>
      'Ukończyłeś wszystkie treści szkoleniowe.';

  @override
  String get writeAnswerHere => 'Wpisz tutaj swoją odpowiedź.';

  @override
  String get fieldCannotBeEmpty => 'To pole nie może być puste.';

  @override
  String get clear_answers => 'Wyczyść odpowiedzi';
}
