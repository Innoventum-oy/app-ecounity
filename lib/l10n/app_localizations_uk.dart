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
      'modules': 'Модулі',
      'resources': 'Ресурси',
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
  String get screenTitle_modules => 'Модулі';

  @override
  String get screenTitle_resources => 'Ресурси';

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
