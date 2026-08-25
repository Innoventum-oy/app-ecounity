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
      'progress': 'Postęp',
      'teacher': 'Nauczyciel',
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
  String get dashboard_no_modules_available => 'Brak dostępnych modułów';

  @override
  String get dashboard_welcome_back => 'Witaj ponownie';

  @override
  String get dashboard_ready_prompt => 'Czas działać dzisiaj?';

  @override
  String get dashboard_start_learning => 'Rozpocznij naukę';

  @override
  String dashboard_continue_sdg(int sdgNumber) {
    return 'Kontynuuj SDG $sdgNumber';
  }

  @override
  String dashboard_start_sdg(int sdgNumber) {
    return 'Rozpocznij SDG $sdgNumber';
  }

  @override
  String get dashboard_explore_modules => 'Poznaj moduły edukacyjne EcoUnity';

  @override
  String get dashboard_browse_modules => 'Przeglądaj moduły';

  @override
  String get dashboard_resume_module => 'Wznów moduł';

  @override
  String get dashboard_start_module => 'Rozpocznij moduł';

  @override
  String get dashboard_stat_modules => 'Moduły';

  @override
  String get dashboard_stat_activities => 'Aktywności';

  @override
  String get dashboard_stat_badges => 'Odznaki';

  @override
  String get dashboard_module_status_done => 'Gotowe';

  @override
  String get dashboard_module_status_started => 'Rozpoczęto';

  @override
  String get dashboard_module_status_new => 'Nowy';

  @override
  String get dashboard_latest_challenge => 'Najnowsze wyzwanie';

  @override
  String get dashboard_one_minute_left => 'Została 1 min';

  @override
  String dashboard_minutes_left(int minutes) {
    return 'Zostało $minutes min';
  }

  @override
  String get dashboard_one_minute => '1 min';

  @override
  String dashboard_minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get dashboard_one_activity => '1 aktywność';

  @override
  String dashboard_activities(int activities) {
    return '$activities aktywności';
  }

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
  String get teacher_mode => 'Tryb nauczyciela';

  @override
  String get teacher_mode_label => 'Jestem nauczycielem';

  @override
  String get teacher_mode_description =>
      'Tryb nauczyciela dodaje informacje dydaktyczne do treści. Postępy ucznia i odznaki są wyłączone, gdy ten tryb jest aktywny.';

  @override
  String get teacher_mode_enable => 'Włącz tryb nauczyciela';

  @override
  String get teacher_mode_active_title => 'Tryb nauczyciela jest aktywny';

  @override
  String get teacher_mode_active_description =>
      'W aktywnościach są wyświetlane informacje dydaktyczne. Postępy ucznia i odznaki są ukryte, gdy ten tryb jest aktywny.';

  @override
  String get teacher_mode_turn_off => 'Wyłącz tryb nauczyciela';

  @override
  String get button_add => 'Dodaj';

  @override
  String get learning_module_title => 'Moduł';

  @override
  String learning_module_load_error(String error) {
    return 'Nie udało się wczytać modułu: $error';
  }

  @override
  String get learning_module_not_found => 'Nie znaleziono modułu';

  @override
  String get learning_empty_activities =>
      'Aktywności pojawią się tutaj, gdy ten moduł będzie gotowy.';

  @override
  String learning_group_stats_for(String group) {
    return 'Wyświetlanie statystyk grupy $group';
  }

  @override
  String get learning_group_stats_empty =>
      'Dodaj i wybierz grupę nauczyciela w widoku Nauczyciel, aby zobaczyć tutaj statystyki.';

  @override
  String learning_sdg_modules_count(int count) {
    return 'Moduły edukacyjne SDG: $count';
  }

  @override
  String learning_module_filter(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Wszystkie',
      'started': 'Rozpoczęte',
      'done': 'Gotowe',
      'challenges': 'Wyzwania',
      'other': 'Wszystkie',
    });
    return '$_temp0';
  }

  @override
  String learning_no_filtered_modules(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Nie ma jeszcze dostępnych modułów.',
      'started': 'Nie ma jeszcze rozpoczętych modułów.',
      'done': 'Nie ma jeszcze ukończonych modułów.',
      'challenges': 'Nie ma jeszcze modułów z wyzwaniami.',
      'other': 'Nie ma jeszcze modułów.',
    });
    return '$_temp0';
  }

  @override
  String learning_module_status(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'new': 'Nowy',
      'started': 'Rozpoczęto',
      'done': 'Gotowe',
      'other': 'Nowy',
    });
    return '$_temp0';
  }

  @override
  String get learning_badge_earned => 'Zdobyto odznakę';

  @override
  String get learning_in_progress => 'W toku';

  @override
  String get learning_one_minute_left => 'Została 1 min';

  @override
  String learning_minutes_left(int minutes) {
    return 'Zostało $minutes min';
  }

  @override
  String get learning_one_minute => '1 min';

  @override
  String learning_minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get learning_one_activity => '1 aktywność';

  @override
  String learning_activities(int activities) {
    return '$activities aktywności';
  }

  @override
  String learning_activity_type(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'comic': 'Komiks',
      'mlr': 'Mikronauka',
      'quiz': 'Quiz',
      'reflection': 'Refleksja',
      'challenge': 'Wyzwanie',
      'unknown': 'Aktywność',
      'other': 'Aktywność',
    });
    return '$_temp0';
  }

  @override
  String learning_module_difficulty(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      'beginner': 'Początkujący',
      'intermediate': 'Średni',
      'advanced': 'Zaawansowany',
      'easy': 'Łatwy',
      'medium': 'Średni',
      'hard': 'Trudny',
      'classroom_activity': 'Aktywność klasowa',
      'home_activity': 'Aktywność domowa',
      'group_challenge': 'Wyzwanie grupowe',
      'other': '$level',
    });
    return '$_temp0';
  }

  @override
  String learning_activity_load_error(String error) {
    return 'Nie można wczytać aktywności: $error';
  }

  @override
  String get learning_activity_not_found => 'Nie znaleziono aktywności';

  @override
  String get learning_submit_reflection => 'Prześlij refleksję';

  @override
  String get learning_complete_challenge => 'Ukończ wyzwanie';

  @override
  String get learning_write_response_hint => 'Napisz swoją odpowiedź';

  @override
  String get learning_reflection_prompt_title => 'Pomyśl o tym';

  @override
  String get quiz_no_questions_title => 'Brak dostępnych pytań';

  @override
  String get quiz_no_questions_message =>
      'Ten quiz nie zawiera obecnie żadnych pytań.';

  @override
  String quiz_question_progress(int current, int total) {
    return 'Pytanie $current z $total';
  }

  @override
  String get quiz_no_answer_options_title => 'Brak opcji odpowiedzi';

  @override
  String get quiz_no_answer_options_message =>
      'To pytanie nie zawiera obecnie opcji odpowiedzi.';

  @override
  String get quiz_submit_answers => 'Prześlij odpowiedzi';

  @override
  String quiz_result_passed(int score, int total) {
    return 'Zaliczone: $score/$total';
  }

  @override
  String quiz_result_try_again(int score, int total) {
    return 'Spróbuj ponownie: $score/$total';
  }

  @override
  String get progress_load_error_title => 'Nie można wczytać postępów';

  @override
  String get progress_empty_message =>
      'Moduły edukacyjne pojawią się tutaj po wczytaniu.';

  @override
  String get progress_journey_title => 'Moja ścieżka nauki';

  @override
  String progress_overall_complete(int percent) {
    return 'Ukończono $percent%';
  }

  @override
  String progress_summary(
    int completedModules,
    int activeChallenges,
    int earnedBadges,
  ) {
    return 'Ukończone moduły: $completedModules, aktywne wyzwania: $activeChallenges, zdobyte odznaki: $earnedBadges';
  }

  @override
  String progress_segment(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'earned': 'Zdobyte',
      'locked': 'Zablokowane',
      'modules': 'Postęp modułów',
      'other': 'Postęp',
    });
    return '$_temp0';
  }

  @override
  String get progress_no_badges_earned_title => 'Nie zdobyto jeszcze odznak';

  @override
  String get progress_no_badges_earned_message =>
      'Ukończ wymagane aktywności, aby odblokować pierwszą odznakę.';

  @override
  String get progress_all_badges_earned_title => 'Wszystkie odznaki zdobyte';

  @override
  String get progress_all_badges_earned_message =>
      'Odblokowano wszystkie dostępne odznaki.';

  @override
  String progress_badge_status(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'earned': 'Zdobyta',
      'locked': 'Zablokowana',
      'other': 'Odznaka',
    });
    return '$_temp0';
  }

  @override
  String get progress_no_modules_title => 'Nie ma jeszcze modułów edukacyjnych';

  @override
  String get progress_no_modules_message =>
      'Postęp modułów pojawi się tutaj po wczytaniu treści.';

  @override
  String progress_module_activities(int completed, int total) {
    return '$completed / $total aktywności';
  }

  @override
  String get progress_suggested_module => 'Sugerowany następny moduł';

  @override
  String progress_continue_with(String activityTitle) {
    return 'Kontynuuj: $activityTitle';
  }

  @override
  String get progress_final_badge_title => 'Finał EcoUnity';

  @override
  String get progress_final_badge_description =>
      'Ukończ wszystkie moduły edukacyjne, aby odblokować finałową odznakę.';

  @override
  String get learning_module_fallback => 'Moduł edukacyjny';

  @override
  String get learning_module_badge_fallback => 'Odznaka modułu';

  @override
  String get teacher_group_statistics_title => 'Statystyki grupy';

  @override
  String get teacher_refresh_active_group => 'Odśwież aktywną grupę';

  @override
  String get teacher_group_report_description =>
      'Dodaj tokeny nauczyciela, aby zobaczyć zbiorczy postęp grupy. Aplikacja zapisuje tylko raporty podsumowujące, bez tożsamości uczniów.';

  @override
  String get teacher_token_label => 'Token nauczyciela';

  @override
  String get teacher_token_hint => 'ABCDEF';

  @override
  String get teacher_group => 'Grupa';

  @override
  String get teacher_active_group => 'Aktywna grupa';

  @override
  String get teacher_select_group => 'Wybierz grupę';

  @override
  String teacher_token_value(String token) {
    return 'Token $token';
  }

  @override
  String get teacher_metric_enrolled => 'Zapisani';

  @override
  String get teacher_metric_active => 'Aktywni';

  @override
  String get teacher_metric_completed => 'Ukończono';

  @override
  String get teacher_refresh_group => 'Odśwież grupę';

  @override
  String get teacher_remove_group => 'Usuń grupę';

  @override
  String get teacher_empty_groups =>
      'Dodaj token grupy, aby włączyć statystyki w widokach Nauka.';

  @override
  String get teacher_loading_saved_groups => 'Ładowanie zapisanych grup...';

  @override
  String teacher_stats_opened(int opened, String total) {
    return 'Otwarto $opened/$total';
  }

  @override
  String teacher_stats_completed(String percent) {
    return 'Ukończono $percent';
  }

  @override
  String teacher_stats_activity_completion(String percent) {
    return '$percent ukończenia aktywności';
  }

  @override
  String teacher_stats_avg_score(String score) {
    return 'Średni wynik $score';
  }

  @override
  String teacher_stats_avg_score_with_max(String score, String maxScore) {
    return 'Średni wynik $score/$maxScore';
  }

  @override
  String get learning_objective => 'Cel nauki';

  @override
  String get group_code => 'Kod grupy';

  @override
  String get group_code_title => 'Dołącz do grupy uczniów';

  @override
  String get group_code_description =>
      'Wpisz kod grupy od nauczyciela lub wklej link zapisu z kodu QR. Postęp w aplikacji zostanie anonimowo powiązany z tą grupą.';

  @override
  String get group_code_hint => 'Kod grupy lub link zapisu';

  @override
  String get group_code_required => 'Wpisz kod grupy';

  @override
  String get join_group => 'Dołącz do grupy';

  @override
  String get selected_group => 'Wybrana grupa';

  @override
  String get group_connected => 'Grupa połączona';

  @override
  String get group_connected_message =>
      'Aplikacja jest teraz powiązana z wybraną grupą uczniów.';

  @override
  String get clear_group => 'Usuń grupę';

  @override
  String get group_code_error =>
      'Nie znaleziono kodu grupy albo kod nie jest aktywny.';

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
  String get welcome_tagline => 'Razem dla planety!';

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
  String get comic_no_scenes_available => 'Brak dostępnych scen komiksu';

  @override
  String get comic_loading_scene => 'Ładowanie sceny...';

  @override
  String get comic_playing => 'Odtwarzanie...';

  @override
  String get comic_complete_action => 'Ukończ';

  @override
  String get comic_loading_next_scenes => 'Ładowanie kolejnych scen...';

  @override
  String get comic_dialogue_title => 'Dialog';

  @override
  String get comic_character_fallback => 'Postać';

  @override
  String get comic_play_tooltip => 'Odtwórz';

  @override
  String get comic_stop_tooltip => 'Zatrzymaj';

  @override
  String get comic_view_dialogue_tooltip => 'Pokaż dialog';

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
