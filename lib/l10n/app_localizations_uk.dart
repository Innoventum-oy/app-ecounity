// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get about => 'Про';

  @override
  String get age => 'Вік';

  @override
  String get account => 'Акаунт';

  @override
  String get achievements => 'Досягнення';

  @override
  String get answer_saved => 'Відповідь збережено';

  @override
  String get application_name => 'Ecounity';

  @override
  String get attention => 'Увага';

  @override
  String get authenticating => 'Авторизація...';

  @override
  String get badge => 'Відзнака';

  @override
  String badge_completion_status(int completed, int required) {
    return 'Ви завершили $completed з $required навчальних матеріалів, необхідних для отримання цієї відзнаки.';
  }

  @override
  String badge_description(Object pathway) {
    return 'Цю відзнаку надають за проходження всіх уроків і викликів у програмі $pathway.';
  }

  @override
  String get button_accept => 'Прийняти';

  @override
  String get button_approve => 'Схвалити';

  @override
  String get badge_awarded => 'Нараховано нову відзнаку';

  @override
  String badge_awarded_congratulations(String badge) {
    return 'Вітаємо! Вам надано відзнаку $badge.';
  }

  @override
  String get button_back => 'Назад';

  @override
  String get button_cancel => 'Скасувати';

  @override
  String get button_close => 'Закрити';

  @override
  String get button_confirm => 'Підтвердити';

  @override
  String get button_continue => 'Продовжити';

  @override
  String get button_continue_as_guest => 'Продовжити як гість';

  @override
  String get button_create => 'Створити';

  @override
  String get button_create_account => 'Створити обліковий запис';

  @override
  String get button_delete => 'Видалити';

  @override
  String get button_edit => 'Редагувати';

  @override
  String get button_finish => 'Завершити';

  @override
  String get button_forgot_password => 'Забули пароль?';

  @override
  String get button_login => 'Увійти';

  @override
  String get button_logout => 'Вийти';

  @override
  String get button_next => 'Далі';

  @override
  String get button_ok => 'OK';

  @override
  String get button_previous => 'Попередній';

  @override
  String get button_register => 'Зареєструватися';

  @override
  String get button_reject => 'Відхилити';

  @override
  String get button_save => 'Зберегти';

  @override
  String get button_send => 'Надіслати';

  @override
  String get button_submit => 'Надіслати';

  @override
  String get cancel => 'Скасувати';

  @override
  String get choose_language => 'Вибрати мову';

  @override
  String get collected_badges => 'Зібрані відзнаки';

  @override
  String get completed => 'Завершено';

  @override
  String get confirm_deleting_account =>
      'Ви впевнені, що хочете видалити свій обліковий запис?';

  @override
  String get contact => 'Контакт';

  @override
  String get delete_account => 'Видалити обліковий запис';

  @override
  String get email => 'Електронна пошта';

  @override
  String get email_not_valid => 'Надана адреса email недійсна';

  @override
  String get email_or_phone_number => 'Email або номер телефону';

  @override
  String error(String error) {
    return 'Помилка: $error';
  }

  @override
  String get error_default => 'Не вдалося виконати запит';

  @override
  String get error_occurred => 'Сталася помилка';

  @override
  String errorViewNotFound(String view) {
    return 'Сторінку $view не знайдено';
  }

  @override
  String get errors_in_form => 'Помилки у формі';

  @override
  String field_required(String field) {
    return 'Поле $field є обов\'язковим';
  }

  @override
  String get firstName => 'Ім\'я';

  @override
  String get funding_disclaimer =>
      'Фінансується Європейським Союзом. Погляди та думки, що тут висловлені, належать лише автору(ам) і не обов\'язково відображають позицію Європейського Союзу або Європейського виконавчого агентства з освіти й культури (EACEA). Ані Європейський Союз, ані EACEA не несуть відповідальності.';

  @override
  String get great => 'Чудово';

  @override
  String get home => 'Головна';

  @override
  String get introduction => 'Вступ';

  @override
  String get language => 'Мова';

  @override
  String get select_language => 'Оберіть мову';

  @override
  String locale(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'uk': 'Українська',
      'en': 'Англійська',
      'fi': 'Фінська',
      'it': 'Італійська',
      'de': 'Німецька',
      'pl': 'Польська',
      'pt': 'Португальська',
      'ro': 'Romanian',
      'es': 'Spanish',
      'other': 'Мова:$language',
    });
    return '$_temp0';
  }

  @override
  String get lastName => 'Прізвище';

  @override
  String get loading => 'Завантаження...';

  @override
  String get login => 'Увійти';

  @override
  String get login_failed => 'Не вдалося увійти';

  @override
  String get logout => 'Вийти';

  @override
  String get logout_confirmation => 'Ви впевнені, що хочете вийти?';

  @override
  String get markAsCompleted => 'Позначити як завершене';

  @override
  String navigation_item(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'home': 'Головна',
      'pathways': 'Шляхи',
      'challenges': 'Виклики',
      'videolist': 'Відео',
      'selfReflectionHub': 'Центр саморефлексії',
      'lessons': 'Уроки',
      'modules': 'Навчання',
      'resources': 'Ресурси',
      'progress': 'Прогрес',
      'teacher': 'Учитель',
      'other': 'Меню:$item',
    });
    return '$_temp0';
  }

  @override
  String get next => 'Далі';

  @override
  String get noBadgesFound => 'Відзнак не знайдено';

  @override
  String get noChallengesFound => 'Викликів не знайдено';

  @override
  String get noContentFound => 'Контент не знайдено';

  @override
  String get noPathwaysFound => 'Не знайдено навчальних матеріалів';

  @override
  String get noTranscriptAvailable => 'Транскрипт недоступний';

  @override
  String get noVideosFound => 'Відео не знайдено';

  @override
  String get noLessonsFound => 'Уроків не знайдено';

  @override
  String get page_content => 'Вміст сторінки';

  @override
  String get password => 'Пароль';

  @override
  String get pathway => 'Навчальний матеріал';

  @override
  String get pathway_already_completed => 'Навчальний матеріал завершено';

  @override
  String get pathway_completed => 'Навчальний матеріал завершено';

  @override
  String get phone => 'Телефон';

  @override
  String get phone_or_email => 'Номер телефону або email';

  @override
  String get please_complete_form_properly =>
      'Будь ласка, заповніть форму правильно';

  @override
  String get please_enter_password => 'Введіть пароль';

  @override
  String get please_enter_phone_or_email => 'Введіть номер телефону або email';

  @override
  String get please_provide_valid_phone_or_email =>
      'Введіть дійсний номер телефону або email';

  @override
  String get previous => 'Назад';

  @override
  String get privacy => 'Конфіденційність';

  @override
  String get privacy_policy => 'Політика конфіденційності';

  @override
  String get profile => 'Профіль';

  @override
  String get register => 'Зареєструватися';

  @override
  String get registration_failed => 'Реєстрація не вдалася';

  @override
  String get registration_successful => 'Реєстрація успішна';

  @override
  String registration_successful_message(String firstName) {
    return 'Ласкаво просимо до Ecounity $firstName!';
  }

  @override
  String get references => 'Джерела';

  @override
  String get saving_data_failed => 'Не вдалося зберегти дані';

  @override
  String get quiz_not_passed => 'Тест не пройдено';

  @override
  String get screenTitle_challenges => 'Виклики';

  @override
  String get screenTitle_home => 'Головна';

  @override
  String get screenTitle_pathways => 'Шляхи';

  @override
  String get screenTitle_selfReflectionHub => 'Центр саморефлексії';

  @override
  String get screenTitle_videos => 'Відео';

  @override
  String get screenTitle_lessons => 'Уроки';

  @override
  String get screenTitle_modules => 'Навчання';

  @override
  String get screenTitle_resources => 'Ресурси';

  @override
  String get dashboard_no_modules_available => 'Немає доступних модулів';

  @override
  String get dashboard_welcome_back => 'З поверненням';

  @override
  String get dashboard_ready_prompt => 'Готові діяти сьогодні?';

  @override
  String get dashboard_start_learning => 'Почати навчання';

  @override
  String dashboard_continue_sdg(int sdgNumber) {
    return 'Продовжити ЦСР $sdgNumber';
  }

  @override
  String dashboard_start_sdg(int sdgNumber) {
    return 'Почати ЦСР $sdgNumber';
  }

  @override
  String get dashboard_explore_modules =>
      'Досліджуйте навчальні модулі EcoUnity';

  @override
  String get dashboard_browse_modules => 'Переглянути модулі';

  @override
  String get dashboard_resume_module => 'Продовжити модуль';

  @override
  String get dashboard_start_module => 'Почати модуль';

  @override
  String get dashboard_stat_modules => 'Модулі';

  @override
  String get dashboard_stat_activities => 'Активності';

  @override
  String get dashboard_stat_badges => 'Бейджі';

  @override
  String get dashboard_module_status_done => 'Готово';

  @override
  String get dashboard_module_status_started => 'Розпочато';

  @override
  String get dashboard_module_status_new => 'Новий';

  @override
  String get dashboard_latest_challenge => 'Останній виклик';

  @override
  String get dashboard_one_minute_left => 'Залишилась 1 хв';

  @override
  String dashboard_minutes_left(int minutes) {
    return 'Залишилось $minutes хв';
  }

  @override
  String get dashboard_one_minute => '1 хв';

  @override
  String dashboard_minutes(int minutes) {
    return '$minutes хв';
  }

  @override
  String get dashboard_one_activity => '1 активність';

  @override
  String dashboard_activities(int activities) {
    return '$activities активностей';
  }

  @override
  String get select => 'Вибрати';

  @override
  String get selected => 'Обрано';

  @override
  String get sendAnswer => 'Зберегти відповідь';

  @override
  String get server => 'Сервер';

  @override
  String get settings => 'Налаштування';

  @override
  String get stage => 'Етап';

  @override
  String stageValue(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'before': 'Перед',
      'during': 'Під час',
      'after': 'Після',
      'other': '$item',
    });
    return '$_temp0';
  }

  @override
  String get start => 'Почати';

  @override
  String get teacher_mode => 'Режим учителя';

  @override
  String get teacher_mode_label => 'Я вчитель';

  @override
  String get teacher_mode_description =>
      'Режим учителя додає методичну інформацію до навчального контенту. Прогрес учня та відзнаки вимкнені, поки цей режим активний.';

  @override
  String get teacher_mode_enable => 'Увімкнути режим учителя';

  @override
  String get teacher_mode_active_title => 'Режим учителя активний';

  @override
  String get teacher_mode_active_description =>
      'У навчальних активностях показується методична інформація. Прогрес учня та відзнаки приховані, поки цей режим активний.';

  @override
  String get teacher_mode_turn_off => 'Вимкнути режим учителя';

  @override
  String get button_add => 'Додати';

  @override
  String get learning_module_title => 'Модуль';

  @override
  String learning_module_load_error(String error) {
    return 'Не вдалося завантажити модуль: $error';
  }

  @override
  String get learning_module_not_found => 'Модуль не знайдено';

  @override
  String get learning_empty_activities =>
      'Активності з\'являться тут, коли цей модуль буде готовий.';

  @override
  String learning_group_stats_for(String group) {
    return 'Показано статистику групи $group';
  }

  @override
  String get learning_group_stats_empty =>
      'Додайте та виберіть групу в режимі вчителя, щоб показати статистику тут.';

  @override
  String learning_sdg_modules_count(int count) {
    return 'Навчальні модулі ЦСР: $count';
  }

  @override
  String learning_module_filter(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Усі',
      'started': 'Розпочаті',
      'done': 'Готові',
      'challenges': 'Виклики',
      'other': 'Усі',
    });
    return '$_temp0';
  }

  @override
  String learning_no_filtered_modules(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Поки немає доступних модулів.',
      'started': 'Поки немає розпочатих модулів.',
      'done': 'Поки немає завершених модулів.',
      'challenges': 'Поки немає модулів із викликами.',
      'other': 'Поки немає модулів.',
    });
    return '$_temp0';
  }

  @override
  String learning_module_status(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'new': 'Новий',
      'started': 'Розпочато',
      'done': 'Готово',
      'other': 'Новий',
    });
    return '$_temp0';
  }

  @override
  String get learning_badge_earned => 'Бейдж отримано';

  @override
  String get learning_in_progress => 'У процесі';

  @override
  String get learning_one_minute_left => 'Залишилась 1 хв';

  @override
  String learning_minutes_left(int minutes) {
    return 'Залишилось $minutes хв';
  }

  @override
  String get learning_one_minute => '1 хв';

  @override
  String learning_minutes(int minutes) {
    return '$minutes хв';
  }

  @override
  String get learning_one_activity => '1 активність';

  @override
  String learning_activities(int activities) {
    return '$activities активностей';
  }

  @override
  String learning_activity_type(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'comic': 'Комікс',
      'mlr': 'Мікронавчання',
      'quiz': 'Вікторина',
      'reflection': 'Рефлексія',
      'challenge': 'Виклик',
      'unknown': 'Активність',
      'other': 'Активність',
    });
    return '$_temp0';
  }

  @override
  String learning_module_difficulty(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      'beginner': 'Початковий',
      'intermediate': 'Середній',
      'advanced': 'Просунутий',
      'easy': 'Легкий',
      'medium': 'Середній',
      'hard': 'Складний',
      'classroom_activity': 'Класна активність',
      'home_activity': 'Домашня активність',
      'group_challenge': 'Груповий виклик',
      'other': '$level',
    });
    return '$_temp0';
  }

  @override
  String learning_activity_load_error(String error) {
    return 'Не вдалося завантажити активність: $error';
  }

  @override
  String get learning_activity_not_found => 'Активність не знайдено';

  @override
  String get learning_submit_reflection => 'Надіслати рефлексію';

  @override
  String get learning_complete_challenge => 'Завершити виклик';

  @override
  String get learning_write_response_hint => 'Напиши свою відповідь';

  @override
  String get learning_reflection_prompt_title => 'Подумай про це';

  @override
  String get quiz_no_questions_title => 'Немає доступних запитань';

  @override
  String get quiz_no_questions_message =>
      'Ця вікторина наразі не містить запитань.';

  @override
  String quiz_question_progress(int current, int total) {
    return 'Запитання $current з $total';
  }

  @override
  String get quiz_no_answer_options_title => 'Немає варіантів відповіді';

  @override
  String get quiz_no_answer_options_message =>
      'Це запитання наразі не містить варіантів відповіді.';

  @override
  String get quiz_submit_answers => 'Надіслати відповіді';

  @override
  String quiz_result_passed(int score, int total) {
    return 'Пройдено: $score/$total';
  }

  @override
  String quiz_result_try_again(int score, int total) {
    return 'Спробуй ще раз: $score/$total';
  }

  @override
  String get progress_load_error_title => 'Не вдалося завантажити прогрес';

  @override
  String get progress_empty_message =>
      'Навчальні модулі з\'являться тут після завантаження.';

  @override
  String get progress_journey_title => 'Мій навчальний шлях';

  @override
  String progress_overall_complete(int percent) {
    return '$percent% завершено';
  }

  @override
  String progress_summary(
    int completedModules,
    int activeChallenges,
    int earnedBadges,
  ) {
    return 'Завершено модулів: $completedModules, активних викликів: $activeChallenges, здобутих значків: $earnedBadges';
  }

  @override
  String progress_segment(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'earned': 'Здобуті',
      'locked': 'Заблоковані',
      'modules': 'Прогрес модулів',
      'other': 'Прогрес',
    });
    return '$_temp0';
  }

  @override
  String get progress_no_badges_earned_title => 'Значків ще не здобуто';

  @override
  String get progress_no_badges_earned_message =>
      'Завершуй потрібні активності, щоб відкрити перший значок.';

  @override
  String get progress_all_badges_earned_title => 'Усі значки здобуто';

  @override
  String get progress_all_badges_earned_message =>
      'Ти відкрив усі доступні значки.';

  @override
  String progress_badge_status(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'earned': 'Здобуто',
      'locked': 'Заблоковано',
      'other': 'Значок',
    });
    return '$_temp0';
  }

  @override
  String get progress_no_modules_title => 'Навчальних модулів ще немає';

  @override
  String get progress_no_modules_message =>
      'Прогрес модулів з\'явиться тут після завантаження контенту.';

  @override
  String progress_module_activities(int completed, int total) {
    return '$completed / $total активностей';
  }

  @override
  String get progress_suggested_module => 'Наступний рекомендований модуль';

  @override
  String progress_continue_with(String activityTitle) {
    return 'Продовжити: $activityTitle';
  }

  @override
  String get progress_final_badge_title => 'Фінал EcoUnity';

  @override
  String get progress_final_badge_description =>
      'Заверши всі навчальні модулі, щоб відкрити фінальний значок.';

  @override
  String get learning_module_fallback => 'Навчальний модуль';

  @override
  String get learning_module_badge_fallback => 'Значок модуля';

  @override
  String get teacher_group_statistics_title => 'Статистика групи';

  @override
  String get teacher_refresh_active_group => 'Оновити активну групу';

  @override
  String get teacher_group_report_description =>
      'Додайте токени вчителя, щоб бачити агрегований прогрес групи. Застосунок зберігає лише підсумкові звіти, а не ідентичності учнів.';

  @override
  String get teacher_token_label => 'Токен учителя';

  @override
  String get teacher_token_hint => 'ABCDEF';

  @override
  String get teacher_group => 'Група';

  @override
  String get teacher_active_group => 'Активна група';

  @override
  String get teacher_select_group => 'Вибрати групу';

  @override
  String teacher_token_value(String token) {
    return 'Токен $token';
  }

  @override
  String get teacher_metric_enrolled => 'Зараховано';

  @override
  String get teacher_metric_active => 'Активні';

  @override
  String get teacher_metric_completed => 'Завершено';

  @override
  String get teacher_refresh_group => 'Оновити групу';

  @override
  String get teacher_remove_group => 'Видалити групу';

  @override
  String get teacher_empty_groups =>
      'Додайте токен групи, щоб увімкнути статистику в навчальних екранах.';

  @override
  String get teacher_loading_saved_groups => 'Завантаження збережених груп...';

  @override
  String teacher_stats_opened(int opened, String total) {
    return 'Відкрито $opened/$total';
  }

  @override
  String teacher_stats_completed(String percent) {
    return 'Завершено $percent';
  }

  @override
  String teacher_stats_activity_completion(String percent) {
    return '$percent завершення активностей';
  }

  @override
  String teacher_stats_avg_score(String score) {
    return 'Середній бал $score';
  }

  @override
  String teacher_stats_avg_score_with_max(String score, String maxScore) {
    return 'Середній бал $score/$maxScore';
  }

  @override
  String get learning_objective => 'Навчальна мета';

  @override
  String get group_code => 'Код групи';

  @override
  String get group_code_title => 'Приєднатися до навчальної групи';

  @override
  String get group_code_description =>
      'Введіть код групи від учителя або вставте QR-посилання для реєстрації. Прогрес у застосунку буде анонімно пов\'язаний із цією групою.';

  @override
  String get group_code_hint => 'Код групи або посилання для реєстрації';

  @override
  String get group_code_required => 'Введіть код групи';

  @override
  String get join_group => 'Приєднатися до групи';

  @override
  String get selected_group => 'Вибрана група';

  @override
  String get group_connected => 'Групу підключено';

  @override
  String get group_connected_message =>
      'Застосунок тепер пов\'язаний із вибраною навчальною групою.';

  @override
  String get clear_group => 'Очистити групу';

  @override
  String get group_code_error => 'Код групи не знайдено або він не активний.';

  @override
  String get terms => 'Умови';

  @override
  String get unnamed => 'Без назви';

  @override
  String get view_introduction => 'Вступ';

  @override
  String get you_have_this_badge => 'У вас є ця відзнака';

  @override
  String get your_password => 'Ваш пароль';

  @override
  String get view_brochure => 'Переглянути брошуру';

  @override
  String get welcome_title =>
      'Ласкаво просимо до додатка Ecounity — вашого доступу до цифрового навчання, натхнення та підприємницького зростання.';

  @override
  String get welcome_tagline => 'Разом заради планети!';

  @override
  String get login_introduction_text =>
      'Почніть вивчати навчальні модулі ЦСР, інтерактивні комікси, вікторини та завдання для уроків, що надихають на дії, дружні до планети.';

  @override
  String get srh_description =>
      'Використовуйте ці запитання як привід для роздумів.';

  @override
  String get srh_what_was_most_impactful_for_me =>
      'Що було для мене найбільш вражаючим?';

  @override
  String get srh_what_will_i_put_into_practice => 'Що я застосую на практиці?';

  @override
  String get srh_what_are_my_hopes_and_fears_for_the_future =>
      'Які мої надії та страхи на майбутнє?';

  @override
  String get no_video_found => 'Відео не знайдено.';

  @override
  String get no_modules_found => 'Модулів не знайдено.';

  @override
  String get no_contents_found => 'Матеріали не знайдені.';

  @override
  String get no_resources_found => 'Ресурси не знайдені.';

  @override
  String get no_images_found => 'Зображення не знайдені.';

  @override
  String get links => 'Посилання';

  @override
  String get refresh => 'Оновити';

  @override
  String get cache_cleared =>
      'Кеш очищено. Будь ласка, перезавантажте сторінку.';

  @override
  String get module_completed => 'Модуль завершено';

  @override
  String get mark_as_completed => 'Позначити як завершене';

  @override
  String get mark_as_not_completed => 'Позначити як незавершене';

  @override
  String get no_image_available => 'Зображення недоступне';

  @override
  String get no_title => 'Без назви';

  @override
  String get items_matched => 'Елементи зіставлено';

  @override
  String get all_items_matched => 'Усі елементи зіставлені!';

  @override
  String get play_again => 'Спробувати знову';

  @override
  String get comic_no_scenes_available => 'Немає доступних сцен коміксу';

  @override
  String get comic_loading_scene => 'Завантаження сцени...';

  @override
  String get comic_playing => 'Відтворення...';

  @override
  String get comic_complete_action => 'Завершити';

  @override
  String get comic_loading_next_scenes => 'Завантаження наступних сцен...';

  @override
  String get comic_dialogue_title => 'Діалог';

  @override
  String get comic_character_fallback => 'Персонаж';

  @override
  String get comic_play_tooltip => 'Відтворити';

  @override
  String get comic_stop_tooltip => 'Зупинити';

  @override
  String get comic_view_dialogue_tooltip => 'Переглянути діалог';

  @override
  String get not_enough_images_to_match =>
      'Недостатньо зображень для зіставлення';

  @override
  String get unknown => 'Невідомо';

  @override
  String get error_loading_button => 'Помилка завантаження кнопки';

  @override
  String get seek => 'Шукати';

  @override
  String get ok => 'OK';

  @override
  String get notification => 'Сповіщення';

  @override
  String modules_completion_summary(int completed, int total) {
    return '$completed з $total модулів завершено';
  }

  @override
  String learning_contents_completion_summary(int completed, int total) {
    return '$completed з $total навчальних матеріалів завершено';
  }

  @override
  String get current_progress => 'Поточний прогрес';

  @override
  String get next_suggestion => 'Наступна порада';

  @override
  String get next_up => 'Далі:';

  @override
  String get congratulations => 'Вітаємо!';

  @override
  String get you_have_completed_all_learning_contents =>
      'Ви завершили всі навчальні матеріали.';

  @override
  String get writeAnswerHere => 'Введіть відповідь тут.';

  @override
  String get fieldCannotBeEmpty => 'Це поле не може бути порожнім.';

  @override
  String get clear_answers => 'Очистити відповіді';
}
