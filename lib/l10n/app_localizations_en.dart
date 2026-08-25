// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get language => 'Language';

  @override
  String get select_language => 'Select language';

  @override
  String locale(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'en': 'English',
      'fi': 'Finnish',
      'it': 'Italian',
      'pt': 'Portuguese',
      'pl': 'Polish',
      'de': 'German',
      'uk': 'Ukrainian',
      'ro': 'Romanian',
      'es': 'Spanish',
      'other': 'Language:$language',
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
      'modules': 'Learn',
      'resources': 'Resources',
      'progress': 'Progress',
      'teacher': 'Teacher',
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
  String get screenTitle_modules => 'Learn';

  @override
  String get screenTitle_resources => 'Resources';

  @override
  String get dashboard_no_modules_available => 'No modules available';

  @override
  String get dashboard_welcome_back => 'Welcome back';

  @override
  String get dashboard_ready_prompt => 'Ready to take action today?';

  @override
  String get dashboard_start_learning => 'Start learning';

  @override
  String dashboard_continue_sdg(int sdgNumber) {
    return 'Continue SDG $sdgNumber';
  }

  @override
  String dashboard_start_sdg(int sdgNumber) {
    return 'Start SDG $sdgNumber';
  }

  @override
  String get dashboard_explore_modules => 'Explore EcoUnity learning modules';

  @override
  String get dashboard_browse_modules => 'Browse modules';

  @override
  String get dashboard_resume_module => 'Resume module';

  @override
  String get dashboard_start_module => 'Start module';

  @override
  String get dashboard_stat_modules => 'Modules';

  @override
  String get dashboard_stat_activities => 'Activities';

  @override
  String get dashboard_stat_badges => 'Badges';

  @override
  String get dashboard_module_status_done => 'Done';

  @override
  String get dashboard_module_status_started => 'Started';

  @override
  String get dashboard_module_status_new => 'New';

  @override
  String get dashboard_latest_challenge => 'Latest challenge';

  @override
  String get dashboard_one_minute_left => '1 min left';

  @override
  String dashboard_minutes_left(int minutes) {
    return '$minutes min left';
  }

  @override
  String get dashboard_one_minute => '1 min';

  @override
  String dashboard_minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get dashboard_one_activity => '1 activity';

  @override
  String dashboard_activities(int activities) {
    return '$activities activities';
  }

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
  String get teacher_mode => 'Teacher mode';

  @override
  String get teacher_mode_label => 'I am a teacher';

  @override
  String get teacher_mode_description =>
      'Teacher mode adds instructional information to learning content. Learner progress and badges are disabled while teacher mode is active.';

  @override
  String get teacher_mode_enable => 'Enable teacher mode';

  @override
  String get teacher_mode_active_title => 'Teacher mode is active';

  @override
  String get teacher_mode_active_description =>
      'Instructional information is shown in learning activities. Learner progress and badges are hidden while this mode is active.';

  @override
  String get teacher_mode_turn_off => 'Turn off teacher mode';

  @override
  String get button_add => 'Add';

  @override
  String get learning_module_title => 'Module';

  @override
  String learning_module_load_error(String error) {
    return 'Unable to load module: $error';
  }

  @override
  String get learning_module_not_found => 'Module not found';

  @override
  String get learning_empty_activities =>
      'Activities will appear here when this module is ready.';

  @override
  String learning_group_stats_for(String group) {
    return 'Showing group statistics for $group';
  }

  @override
  String get learning_group_stats_empty =>
      'Add and select a teacher group in Teacher view to show statistics here.';

  @override
  String learning_sdg_modules_count(int count) {
    return 'SDG learning modules: $count';
  }

  @override
  String learning_module_filter(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'All',
      'started': 'Started',
      'done': 'Done',
      'challenges': 'Challenges',
      'other': 'All',
    });
    return '$_temp0';
  }

  @override
  String learning_no_filtered_modules(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'No modules are available yet.',
      'started': 'No started modules yet.',
      'done': 'No completed modules yet.',
      'challenges': 'No challenge modules yet.',
      'other': 'No modules yet.',
    });
    return '$_temp0';
  }

  @override
  String learning_module_status(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'new': 'New',
      'started': 'Started',
      'done': 'Done',
      'other': 'New',
    });
    return '$_temp0';
  }

  @override
  String get learning_badge_earned => 'Badge earned';

  @override
  String get learning_in_progress => 'In progress';

  @override
  String get learning_one_minute_left => '1 min left';

  @override
  String learning_minutes_left(int minutes) {
    return '$minutes min left';
  }

  @override
  String get learning_one_minute => '1 min';

  @override
  String learning_minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get learning_one_activity => '1 activity';

  @override
  String learning_activities(int activities) {
    return '$activities activities';
  }

  @override
  String learning_activity_type(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'comic': 'Comic',
      'mlr': 'Micro-learning',
      'quiz': 'Quiz',
      'reflection': 'Reflection',
      'challenge': 'Challenge',
      'unknown': 'Activity',
      'other': 'Activity',
    });
    return '$_temp0';
  }

  @override
  String learning_module_difficulty(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      'beginner': 'Beginner',
      'intermediate': 'Intermediate',
      'advanced': 'Advanced',
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
      'classroom_activity': 'Classroom activity',
      'home_activity': 'Home activity',
      'group_challenge': 'Group challenge',
      'other': '$level',
    });
    return '$_temp0';
  }

  @override
  String learning_activity_load_error(String error) {
    return 'Unable to load activity: $error';
  }

  @override
  String get learning_activity_not_found => 'Activity not found';

  @override
  String get learning_submit_reflection => 'Submit reflection';

  @override
  String get learning_complete_challenge => 'Complete challenge';

  @override
  String get learning_write_response_hint => 'Write your response';

  @override
  String get learning_reflection_prompt_title => 'Think about it';

  @override
  String get quiz_no_questions_title => 'No questions available';

  @override
  String get quiz_no_questions_message =>
      'This quiz does not currently include any questions.';

  @override
  String quiz_question_progress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get quiz_no_answer_options_title => 'No answer options';

  @override
  String get quiz_no_answer_options_message =>
      'This question does not currently include answer options.';

  @override
  String get quiz_submit_answers => 'Submit answers';

  @override
  String quiz_result_passed(int score, int total) {
    return 'Passed: $score/$total';
  }

  @override
  String quiz_result_try_again(int score, int total) {
    return 'Try again: $score/$total';
  }

  @override
  String get progress_load_error_title => 'Unable to load progress';

  @override
  String get progress_empty_message =>
      'Learning modules will appear here after they are loaded.';

  @override
  String get progress_journey_title => 'My learning journey';

  @override
  String progress_overall_complete(int percent) {
    return '$percent% complete';
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
      other: 'modules',
      one: 'module',
    );
    String _temp1 = intl.Intl.pluralLogic(
      activeChallenges,
      locale: localeName,
      other: 'challenges',
      one: 'challenge',
    );
    String _temp2 = intl.Intl.pluralLogic(
      earnedBadges,
      locale: localeName,
      other: 'badges',
      one: 'badge',
    );
    return '$completedModules $_temp0 complete, $activeChallenges $_temp1 active, $earnedBadges $_temp2 earned';
  }

  @override
  String progress_segment(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'earned': 'Earned',
      'locked': 'Locked',
      'modules': 'Module progress',
      'other': 'Progress',
    });
    return '$_temp0';
  }

  @override
  String get progress_no_badges_earned_title => 'No badges earned yet';

  @override
  String get progress_no_badges_earned_message =>
      'Complete required activities to unlock your first badge.';

  @override
  String get progress_all_badges_earned_title => 'All badges earned';

  @override
  String get progress_all_badges_earned_message =>
      'You have unlocked every available badge.';

  @override
  String progress_badge_status(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'earned': 'Earned',
      'locked': 'Locked',
      'other': 'Badge',
    });
    return '$_temp0';
  }

  @override
  String get progress_no_modules_title => 'No learning modules yet';

  @override
  String get progress_no_modules_message =>
      'Module progress will appear here after content loads.';

  @override
  String progress_module_activities(int completed, int total) {
    return '$completed / $total activities';
  }

  @override
  String get progress_suggested_module => 'Suggested next module';

  @override
  String progress_continue_with(String activityTitle) {
    return 'Continue with $activityTitle';
  }

  @override
  String get progress_final_badge_title => 'EcoUnity Final';

  @override
  String get progress_final_badge_description =>
      'Complete every learning module to unlock the final badge.';

  @override
  String get learning_module_fallback => 'Learning module';

  @override
  String get learning_module_badge_fallback => 'Module badge';

  @override
  String get teacher_group_statistics_title => 'Group statistics';

  @override
  String get teacher_refresh_active_group => 'Refresh active group';

  @override
  String get teacher_group_report_description =>
      'Add teacher tokens to view aggregate group-level progress. The app stores only summary reports, not learner identities.';

  @override
  String get teacher_token_label => 'Teacher token';

  @override
  String get teacher_token_hint => 'ABCDEF';

  @override
  String get teacher_group => 'Group';

  @override
  String get teacher_active_group => 'Active group';

  @override
  String get teacher_select_group => 'Select group';

  @override
  String teacher_token_value(String token) {
    return 'Token $token';
  }

  @override
  String get teacher_metric_enrolled => 'Enrolled';

  @override
  String get teacher_metric_active => 'Active';

  @override
  String get teacher_metric_completed => 'Completed';

  @override
  String get teacher_refresh_group => 'Refresh group';

  @override
  String get teacher_remove_group => 'Remove group';

  @override
  String get teacher_empty_groups =>
      'Add a group token to enable statistics in Learn views.';

  @override
  String get teacher_loading_saved_groups => 'Loading saved groups...';

  @override
  String teacher_stats_opened(int opened, String total) {
    return 'Opened $opened/$total';
  }

  @override
  String teacher_stats_completed(String percent) {
    return 'Completed $percent';
  }

  @override
  String teacher_stats_activity_completion(String percent) {
    return '$percent activity completion';
  }

  @override
  String teacher_stats_avg_score(String score) {
    return 'Avg score $score';
  }

  @override
  String teacher_stats_avg_score_with_max(String score, String maxScore) {
    return 'Avg score $score/$maxScore';
  }

  @override
  String get learning_objective => 'Learning objective';

  @override
  String get group_code => 'Group code';

  @override
  String get group_code_title => 'Join a learner group';

  @override
  String get group_code_description =>
      'Enter the group code from your teacher or paste a QR enrollment link. Your app progress will be linked to that group anonymously.';

  @override
  String get group_code_hint => 'Group code or enrollment link';

  @override
  String get group_code_required => 'Enter a group code';

  @override
  String get join_group => 'Join group';

  @override
  String get selected_group => 'Selected group';

  @override
  String get group_connected => 'Group connected';

  @override
  String get group_connected_message =>
      'Your app is now linked to the selected learner group.';

  @override
  String get clear_group => 'Clear group';

  @override
  String get group_code_error =>
      'The group code was not found or is not active.';

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
  String get welcome_tagline => 'Together for Planet!';

  @override
  String get login_introduction_text =>
      'Start exploring SDG learning modules, interactive comics, quizzes, and classroom challenges for planet-friendly action.';

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
  String get comic_no_scenes_available => 'No comic scenes available';

  @override
  String get comic_loading_scene => 'Loading scene...';

  @override
  String get comic_playing => 'Playing...';

  @override
  String get comic_complete_action => 'Complete';

  @override
  String get comic_loading_next_scenes => 'Loading next scenes...';

  @override
  String get comic_dialogue_title => 'Dialogue';

  @override
  String get comic_character_fallback => 'Character';

  @override
  String get comic_play_tooltip => 'Play';

  @override
  String get comic_stop_tooltip => 'Stop';

  @override
  String get comic_view_dialogue_tooltip => 'View dialogue';

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
