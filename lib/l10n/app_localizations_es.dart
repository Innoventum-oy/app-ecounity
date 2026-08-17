// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get age => 'Age';

  @override
  String get account => 'Account';

  @override
  String get achievements => 'Achievements';

  @override
  String get answer_saved => 'Answer saved';

  @override
  String get application_name => 'Ecounity';

  @override
  String get attention => 'Attention';

  @override
  String get authenticating => 'Authenticating...';

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
  String get button_accept => 'Accept';

  @override
  String get button_approve => 'Approve';

  @override
  String get badge_awarded => 'New badge awarded';

  @override
  String badge_awarded_congratulations(String badge) {
    return 'Congratulations! You have been awarded the $badge badge.';
  }

  @override
  String get button_back => 'Back';

  @override
  String get button_cancel => 'Cancel';

  @override
  String get button_close => 'Close';

  @override
  String get button_confirm => 'Confirm';

  @override
  String get button_continue => 'Continue';

  @override
  String get button_continue_as_guest => 'Continue as guest';

  @override
  String get button_create => 'Create';

  @override
  String get button_create_account => 'Create account';

  @override
  String get button_delete => 'Delete';

  @override
  String get button_edit => 'Edit';

  @override
  String get button_finish => 'Finish';

  @override
  String get button_forgot_password => 'Forgot password?';

  @override
  String get button_login => 'Login';

  @override
  String get button_logout => 'Logout';

  @override
  String get button_next => 'Next';

  @override
  String get button_ok => 'OK';

  @override
  String get button_previous => 'Previous';

  @override
  String get button_register => 'Register';

  @override
  String get button_reject => 'Reject';

  @override
  String get button_save => 'Save';

  @override
  String get button_send => 'Send';

  @override
  String get button_submit => 'Submit';

  @override
  String get cancel => 'Cancel';

  @override
  String get choose_language => 'Choose language';

  @override
  String get collected_badges => 'Collected badges';

  @override
  String get completed => 'Completed';

  @override
  String get confirm_deleting_account =>
      'Are you sure you want to delete your account?';

  @override
  String get contact => 'Contact';

  @override
  String get delete_account => 'Delete account';

  @override
  String get email => 'Email';

  @override
  String get email_not_valid => 'The given email address is not valid';

  @override
  String get email_or_phone_number => 'Email or phone number';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get error_default => 'Unable to complete the request';

  @override
  String get error_occurred => 'An error occurred';

  @override
  String errorViewNotFound(String view) {
    return 'View $view not found';
  }

  @override
  String get errors_in_form => 'Errors in form';

  @override
  String field_required(String field) {
    return 'The field $field is required';
  }

  @override
  String get firstName => 'First name';

  @override
  String get funding_disclaimer =>
      'Funded by the European Union. Views and opinions expressed are however those of the author(s) only and do not necessarily reflect those of the European Union or the European Education and Culture Executive Agency (EACEA). Neither the European Union nor EACEA can be held responsible for them.';

  @override
  String get great => 'Great';

  @override
  String get home => 'Home';

  @override
  String get introduction => 'Introduction';

  @override
  String get language => 'Idioma';

  @override
  String get select_language => 'Select language';

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
      'it': 'Italian',
      'pt': 'Portuguese',
      'other': 'Idioma:$language',
    });
    return '$_temp0';
  }

  @override
  String get lastName => 'Last name';

  @override
  String get loading => 'Loading...';

  @override
  String get login => 'Login';

  @override
  String get login_failed => 'Login failed';

  @override
  String get logout => 'Logout';

  @override
  String get logout_confirmation => 'Are you sure you want to logout?';

  @override
  String get markAsCompleted => 'Mark as completed';

  @override
  String navigation_item(String item) {
    String _temp0 = intl.Intl.selectLogic(item, {
      'home': 'Home',
      'pathways': 'Pathways',
      'challenges': 'Challenges',
      'videolist': 'Videos',
      'selfReflectionHub': 'Self-reflection Hub',
      'lessons': 'Lessons',
      'modules': 'Modules',
      'resources': 'Resources',
      'other': 'Menu:$item',
    });
    return '$_temp0';
  }

  @override
  String get next => 'Next';

  @override
  String get noBadgesFound => 'No badges found';

  @override
  String get noChallengesFound => 'No challenges were found';

  @override
  String get noContentFound => 'No content found';

  @override
  String get noPathwaysFound => 'No learning contents were found';

  @override
  String get noTranscriptAvailable => 'No transcript available';

  @override
  String get noVideosFound => 'No videos were found';

  @override
  String get noLessonsFound => 'No lessons were found';

  @override
  String get page_content => 'Page content';

  @override
  String get password => 'Password';

  @override
  String get pathway => 'Learning content';

  @override
  String get pathway_already_completed => 'Learning content is completed';

  @override
  String get pathway_completed => 'Learning content completed';

  @override
  String get phone => 'Phone';

  @override
  String get phone_or_email => 'Phone number or email address';

  @override
  String get please_complete_form_properly =>
      'Please complete the form properly';

  @override
  String get please_enter_password => 'Please enter a password';

  @override
  String get please_enter_phone_or_email =>
      'Please enter a phone number or email address';

  @override
  String get please_provide_valid_phone_or_email =>
      'Please provide a valid phone number or email address';

  @override
  String get previous => 'Previous';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacy_policy => 'Privacy Policy';

  @override
  String get profile => 'Profile';

  @override
  String get register => 'Register';

  @override
  String get registration_failed => 'Registration failed';

  @override
  String get registration_successful => 'Registration successful';

  @override
  String registration_successful_message(String firstName) {
    return 'Welcome to Ecounity $firstName!';
  }

  @override
  String get references => 'References';

  @override
  String get saving_data_failed => 'Saving data failed';

  @override
  String get quiz_not_passed => 'Quiz not passed';

  @override
  String get screenTitle_challenges => 'Challenges';

  @override
  String get screenTitle_home => 'Home';

  @override
  String get screenTitle_pathways => 'Pathways';

  @override
  String get screenTitle_selfReflectionHub => 'Self-reflection Hub';

  @override
  String get screenTitle_videos => 'Videos';

  @override
  String get screenTitle_lessons => 'Lessons';

  @override
  String get screenTitle_modules => 'Modules';

  @override
  String get screenTitle_resources => 'Resources';

  @override
  String get select => 'Select';

  @override
  String get selected => 'Selected';

  @override
  String get sendAnswer => 'Save answer';

  @override
  String get server => 'Server';

  @override
  String get settings => 'Settings';

  @override
  String get stage => 'Stage';

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
  String get start => 'Start';

  @override
  String get terms => 'Terms';

  @override
  String get unnamed => 'Unnamed';

  @override
  String get view_introduction => 'Introduction';

  @override
  String get you_have_this_badge => 'You have this badge';

  @override
  String get your_password => 'Your password';

  @override
  String get view_brochure => 'View brochure';

  @override
  String get welcome_title =>
      'Welcome to the Ecounity App - your gateway to digital learning, inspiration, and entrepreneurial growth.';

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
  String get refresh => 'Refresh';

  @override
  String get cache_cleared => 'Cache cleared. Please reload the page.';

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
