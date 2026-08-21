import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fi'),
    Locale('it'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('uk'),
  ];

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @answer_saved.
  ///
  /// In en, this message translates to:
  /// **'Answer saved'**
  String get answer_saved;

  /// No description provided for @application_name.
  ///
  /// In en, this message translates to:
  /// **'Ecounity'**
  String get application_name;

  /// No description provided for @attention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get attention;

  /// No description provided for @authenticating.
  ///
  /// In en, this message translates to:
  /// **'Authenticating...'**
  String get authenticating;

  /// No description provided for @badge.
  ///
  /// In en, this message translates to:
  /// **'Badge'**
  String get badge;

  /// Badge completion status
  ///
  /// In en, this message translates to:
  /// **'You have completed {completed} out of {required} learning contents required to earn this badge.'**
  String badge_completion_status(int completed, int required);

  /// No description provided for @badge_description.
  ///
  /// In en, this message translates to:
  /// **'This badge is awarded for completing all the lessons and challenges in the {pathway} pathway.'**
  String badge_description(Object pathway);

  /// No description provided for @button_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get button_accept;

  /// No description provided for @button_approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get button_approve;

  /// No description provided for @badge_awarded.
  ///
  /// In en, this message translates to:
  /// **'New badge awarded'**
  String get badge_awarded;

  /// Badge awarded congratulation message
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You have been awarded the {badge} badge.'**
  String badge_awarded_congratulations(String badge);

  /// No description provided for @button_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get button_back;

  /// No description provided for @button_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get button_cancel;

  /// No description provided for @button_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get button_close;

  /// No description provided for @button_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get button_confirm;

  /// No description provided for @button_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get button_continue;

  /// No description provided for @button_continue_as_guest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get button_continue_as_guest;

  /// No description provided for @button_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get button_create;

  /// No description provided for @button_create_account.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get button_create_account;

  /// No description provided for @button_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get button_delete;

  /// No description provided for @button_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get button_edit;

  /// No description provided for @button_finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get button_finish;

  /// No description provided for @button_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get button_forgot_password;

  /// No description provided for @button_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get button_login;

  /// No description provided for @button_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get button_logout;

  /// No description provided for @button_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get button_next;

  /// No description provided for @button_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get button_ok;

  /// No description provided for @button_previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get button_previous;

  /// No description provided for @button_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get button_register;

  /// No description provided for @button_reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get button_reject;

  /// No description provided for @button_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get button_save;

  /// No description provided for @button_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get button_send;

  /// No description provided for @button_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get button_submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @choose_language.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get choose_language;

  /// No description provided for @collected_badges.
  ///
  /// In en, this message translates to:
  /// **'Collected badges'**
  String get collected_badges;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @confirm_deleting_account.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get confirm_deleting_account;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get delete_account;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @email_not_valid.
  ///
  /// In en, this message translates to:
  /// **'The given email address is not valid'**
  String get email_not_valid;

  /// No description provided for @email_or_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Email or phone number'**
  String get email_or_phone_number;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// No description provided for @error_default.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete the request'**
  String get error_default;

  /// No description provided for @error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error_occurred;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'View {view} not found'**
  String errorViewNotFound(String view);

  /// No description provided for @errors_in_form.
  ///
  /// In en, this message translates to:
  /// **'Errors in form'**
  String get errors_in_form;

  /// Field required
  ///
  /// In en, this message translates to:
  /// **'The field {field} is required'**
  String field_required(String field);

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @funding_disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Funded by the European Union. Views and opinions expressed are however those of the author(s) only and do not necessarily reflect those of the European Union or the European Education and Culture Executive Agency (EACEA). Neither the European Union nor EACEA can be held responsible for them.'**
  String get funding_disclaimer;

  /// No description provided for @great.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get great;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @introduction.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get introduction;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get select_language;

  /// Locale
  ///
  /// In en, this message translates to:
  /// **'{language,select, en{English} fi{Finnish} it{Italian} pt{Portuguese} pl{Polish} de{German} uk{Ukrainian} ro{Romanian} es{Spanish} other{Language:{language}}}'**
  String locale(String language);

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @login_failed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get login_failed;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logout_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logout_confirmation;

  /// No description provided for @markAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get markAsCompleted;

  /// Menu navigation items map
  ///
  /// In en, this message translates to:
  /// **'{item, select, home{Home} pathways{Pathways} challenges{Challenges} videolist{Videos} selfReflectionHub{Self-reflection Hub} lessons{Lessons} modules{Learn} resources{Resources} progress{Progress} teacher{Teacher} other{Menu:{item}}}'**
  String navigation_item(String item);

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @noBadgesFound.
  ///
  /// In en, this message translates to:
  /// **'No badges found'**
  String get noBadgesFound;

  /// No description provided for @noChallengesFound.
  ///
  /// In en, this message translates to:
  /// **'No challenges were found'**
  String get noChallengesFound;

  /// No description provided for @noContentFound.
  ///
  /// In en, this message translates to:
  /// **'No content found'**
  String get noContentFound;

  /// No description provided for @noPathwaysFound.
  ///
  /// In en, this message translates to:
  /// **'No learning contents were found'**
  String get noPathwaysFound;

  /// No description provided for @noTranscriptAvailable.
  ///
  /// In en, this message translates to:
  /// **'No transcript available'**
  String get noTranscriptAvailable;

  /// No description provided for @noVideosFound.
  ///
  /// In en, this message translates to:
  /// **'No videos were found'**
  String get noVideosFound;

  /// No description provided for @noLessonsFound.
  ///
  /// In en, this message translates to:
  /// **'No lessons were found'**
  String get noLessonsFound;

  /// No description provided for @page_content.
  ///
  /// In en, this message translates to:
  /// **'Page content'**
  String get page_content;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pathway.
  ///
  /// In en, this message translates to:
  /// **'Learning content'**
  String get pathway;

  /// No description provided for @pathway_already_completed.
  ///
  /// In en, this message translates to:
  /// **'Learning content is completed'**
  String get pathway_already_completed;

  /// No description provided for @pathway_completed.
  ///
  /// In en, this message translates to:
  /// **'Learning content completed'**
  String get pathway_completed;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phone_or_email.
  ///
  /// In en, this message translates to:
  /// **'Phone number or email address'**
  String get phone_or_email;

  /// No description provided for @please_complete_form_properly.
  ///
  /// In en, this message translates to:
  /// **'Please complete the form properly'**
  String get please_complete_form_properly;

  /// No description provided for @please_enter_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get please_enter_password;

  /// No description provided for @please_enter_phone_or_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number or email address'**
  String get please_enter_phone_or_email;

  /// No description provided for @please_provide_valid_phone_or_email.
  ///
  /// In en, this message translates to:
  /// **'Please provide a valid phone number or email address'**
  String get please_provide_valid_phone_or_email;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registration_failed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registration_failed;

  /// No description provided for @registration_successful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registration_successful;

  /// Registration successful message
  ///
  /// In en, this message translates to:
  /// **'Welcome to Ecounity {firstName}!'**
  String registration_successful_message(String firstName);

  /// No description provided for @references.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get references;

  /// No description provided for @saving_data_failed.
  ///
  /// In en, this message translates to:
  /// **'Saving data failed'**
  String get saving_data_failed;

  /// No description provided for @quiz_not_passed.
  ///
  /// In en, this message translates to:
  /// **'Quiz not passed'**
  String get quiz_not_passed;

  /// No description provided for @screenTitle_challenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get screenTitle_challenges;

  /// No description provided for @screenTitle_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get screenTitle_home;

  /// No description provided for @screenTitle_pathways.
  ///
  /// In en, this message translates to:
  /// **'Pathways'**
  String get screenTitle_pathways;

  /// No description provided for @screenTitle_selfReflectionHub.
  ///
  /// In en, this message translates to:
  /// **'Self-reflection Hub'**
  String get screenTitle_selfReflectionHub;

  /// No description provided for @screenTitle_videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get screenTitle_videos;

  /// No description provided for @screenTitle_lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get screenTitle_lessons;

  /// No description provided for @screenTitle_modules.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get screenTitle_modules;

  /// No description provided for @screenTitle_resources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get screenTitle_resources;

  /// No description provided for @dashboard_no_modules_available.
  ///
  /// In en, this message translates to:
  /// **'No modules available'**
  String get dashboard_no_modules_available;

  /// No description provided for @dashboard_welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get dashboard_welcome_back;

  /// No description provided for @dashboard_ready_prompt.
  ///
  /// In en, this message translates to:
  /// **'Ready to take action today?'**
  String get dashboard_ready_prompt;

  /// No description provided for @dashboard_start_learning.
  ///
  /// In en, this message translates to:
  /// **'Start learning'**
  String get dashboard_start_learning;

  /// Dashboard title for resuming a Sustainable Development Goal module
  ///
  /// In en, this message translates to:
  /// **'Continue SDG {sdgNumber}'**
  String dashboard_continue_sdg(int sdgNumber);

  /// Dashboard title for starting a Sustainable Development Goal module
  ///
  /// In en, this message translates to:
  /// **'Start SDG {sdgNumber}'**
  String dashboard_start_sdg(int sdgNumber);

  /// No description provided for @dashboard_explore_modules.
  ///
  /// In en, this message translates to:
  /// **'Explore EcoUnity learning modules'**
  String get dashboard_explore_modules;

  /// No description provided for @dashboard_browse_modules.
  ///
  /// In en, this message translates to:
  /// **'Browse modules'**
  String get dashboard_browse_modules;

  /// No description provided for @dashboard_resume_module.
  ///
  /// In en, this message translates to:
  /// **'Resume module'**
  String get dashboard_resume_module;

  /// No description provided for @dashboard_start_module.
  ///
  /// In en, this message translates to:
  /// **'Start module'**
  String get dashboard_start_module;

  /// No description provided for @dashboard_stat_modules.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get dashboard_stat_modules;

  /// No description provided for @dashboard_stat_activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get dashboard_stat_activities;

  /// No description provided for @dashboard_stat_badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get dashboard_stat_badges;

  /// No description provided for @dashboard_module_status_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get dashboard_module_status_done;

  /// No description provided for @dashboard_module_status_started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get dashboard_module_status_started;

  /// No description provided for @dashboard_module_status_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get dashboard_module_status_new;

  /// No description provided for @dashboard_latest_challenge.
  ///
  /// In en, this message translates to:
  /// **'Latest challenge'**
  String get dashboard_latest_challenge;

  /// No description provided for @dashboard_one_minute_left.
  ///
  /// In en, this message translates to:
  /// **'1 min left'**
  String get dashboard_one_minute_left;

  /// Dashboard remaining time label
  ///
  /// In en, this message translates to:
  /// **'{minutes} min left'**
  String dashboard_minutes_left(int minutes);

  /// No description provided for @dashboard_one_minute.
  ///
  /// In en, this message translates to:
  /// **'1 min'**
  String get dashboard_one_minute;

  /// Dashboard estimated time label
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String dashboard_minutes(int minutes);

  /// No description provided for @dashboard_one_activity.
  ///
  /// In en, this message translates to:
  /// **'1 activity'**
  String get dashboard_one_activity;

  /// Dashboard activity count label
  ///
  /// In en, this message translates to:
  /// **'{activities} activities'**
  String dashboard_activities(int activities);

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @sendAnswer.
  ///
  /// In en, this message translates to:
  /// **'Save answer'**
  String get sendAnswer;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @stage.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get stage;

  /// Pathway stage options
  ///
  /// In en, this message translates to:
  /// **'{item,select, before{Before} during{During} after{After} other{{item}}}'**
  String stageValue(String item);

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @teacher_mode.
  ///
  /// In en, this message translates to:
  /// **'Teacher mode'**
  String get teacher_mode;

  /// No description provided for @teacher_mode_label.
  ///
  /// In en, this message translates to:
  /// **'I am a teacher'**
  String get teacher_mode_label;

  /// No description provided for @teacher_mode_description.
  ///
  /// In en, this message translates to:
  /// **'Teacher mode adds instructional information to learning content. Learner progress and badges are disabled while teacher mode is active.'**
  String get teacher_mode_description;

  /// No description provided for @teacher_mode_enable.
  ///
  /// In en, this message translates to:
  /// **'Enable teacher mode'**
  String get teacher_mode_enable;

  /// No description provided for @teacher_mode_active_title.
  ///
  /// In en, this message translates to:
  /// **'Teacher mode is active'**
  String get teacher_mode_active_title;

  /// No description provided for @teacher_mode_active_description.
  ///
  /// In en, this message translates to:
  /// **'Instructional information is shown in learning activities. Learner progress and badges are hidden while this mode is active.'**
  String get teacher_mode_active_description;

  /// No description provided for @teacher_mode_turn_off.
  ///
  /// In en, this message translates to:
  /// **'Turn off teacher mode'**
  String get teacher_mode_turn_off;

  /// No description provided for @button_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get button_add;

  /// No description provided for @learning_module_title.
  ///
  /// In en, this message translates to:
  /// **'Module'**
  String get learning_module_title;

  /// Error shown when an SDG module cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Unable to load module: {error}'**
  String learning_module_load_error(String error);

  /// No description provided for @learning_module_not_found.
  ///
  /// In en, this message translates to:
  /// **'Module not found'**
  String get learning_module_not_found;

  /// No description provided for @learning_empty_activities.
  ///
  /// In en, this message translates to:
  /// **'Activities will appear here when this module is ready.'**
  String get learning_empty_activities;

  /// Teacher-mode banner shown in Learn when a group report is selected
  ///
  /// In en, this message translates to:
  /// **'Showing group statistics for {group}'**
  String learning_group_stats_for(String group);

  /// No description provided for @learning_group_stats_empty.
  ///
  /// In en, this message translates to:
  /// **'Add and select a teacher group in Teacher view to show statistics here.'**
  String get learning_group_stats_empty;

  /// Heading showing the number of SDG learning modules
  ///
  /// In en, this message translates to:
  /// **'SDG learning modules: {count}'**
  String learning_sdg_modules_count(int count);

  /// Filter labels in the Learn module list
  ///
  /// In en, this message translates to:
  /// **'{filter, select, all{All} started{Started} done{Done} challenges{Challenges} other{All}}'**
  String learning_module_filter(String filter);

  /// Empty state for a selected Learn module filter
  ///
  /// In en, this message translates to:
  /// **'{filter, select, all{No modules are available yet.} started{No started modules yet.} done{No completed modules yet.} challenges{No challenge modules yet.} other{No modules yet.}}'**
  String learning_no_filtered_modules(String filter);

  /// Status chip for module progress
  ///
  /// In en, this message translates to:
  /// **'{status, select, new{New} started{Started} done{Done} other{New}}'**
  String learning_module_status(String status);

  /// No description provided for @learning_badge_earned.
  ///
  /// In en, this message translates to:
  /// **'Badge earned'**
  String get learning_badge_earned;

  /// No description provided for @learning_in_progress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get learning_in_progress;

  /// No description provided for @learning_one_minute_left.
  ///
  /// In en, this message translates to:
  /// **'1 min left'**
  String get learning_one_minute_left;

  /// Remaining time label in Learn module cards
  ///
  /// In en, this message translates to:
  /// **'{minutes} min left'**
  String learning_minutes_left(int minutes);

  /// No description provided for @learning_one_minute.
  ///
  /// In en, this message translates to:
  /// **'1 min'**
  String get learning_one_minute;

  /// Estimated time label in Learn module and activity cards
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String learning_minutes(int minutes);

  /// No description provided for @learning_one_activity.
  ///
  /// In en, this message translates to:
  /// **'1 activity'**
  String get learning_one_activity;

  /// Activity count label in Learn module cards
  ///
  /// In en, this message translates to:
  /// **'{activities} activities'**
  String learning_activities(int activities);

  /// Learning activity type label
  ///
  /// In en, this message translates to:
  /// **'{type, select, comic{Comic} mlr{Micro-learning} quiz{Quiz} reflection{Reflection} challenge{Challenge} unknown{Activity} other{Activity}}'**
  String learning_activity_type(String type);

  /// No description provided for @teacher_group_statistics_title.
  ///
  /// In en, this message translates to:
  /// **'Group statistics'**
  String get teacher_group_statistics_title;

  /// No description provided for @teacher_refresh_active_group.
  ///
  /// In en, this message translates to:
  /// **'Refresh active group'**
  String get teacher_refresh_active_group;

  /// No description provided for @teacher_group_report_description.
  ///
  /// In en, this message translates to:
  /// **'Add teacher tokens to view aggregate group-level progress. The app stores only summary reports, not learner identities.'**
  String get teacher_group_report_description;

  /// No description provided for @teacher_token_label.
  ///
  /// In en, this message translates to:
  /// **'Teacher token'**
  String get teacher_token_label;

  /// No description provided for @teacher_token_hint.
  ///
  /// In en, this message translates to:
  /// **'ABCDEF'**
  String get teacher_token_hint;

  /// No description provided for @teacher_group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get teacher_group;

  /// No description provided for @teacher_active_group.
  ///
  /// In en, this message translates to:
  /// **'Active group'**
  String get teacher_active_group;

  /// No description provided for @teacher_select_group.
  ///
  /// In en, this message translates to:
  /// **'Select group'**
  String get teacher_select_group;

  /// Teacher-token label for a saved group report
  ///
  /// In en, this message translates to:
  /// **'Token {token}'**
  String teacher_token_value(String token);

  /// No description provided for @teacher_metric_enrolled.
  ///
  /// In en, this message translates to:
  /// **'Enrolled'**
  String get teacher_metric_enrolled;

  /// No description provided for @teacher_metric_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get teacher_metric_active;

  /// No description provided for @teacher_metric_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get teacher_metric_completed;

  /// No description provided for @teacher_refresh_group.
  ///
  /// In en, this message translates to:
  /// **'Refresh group'**
  String get teacher_refresh_group;

  /// No description provided for @teacher_remove_group.
  ///
  /// In en, this message translates to:
  /// **'Remove group'**
  String get teacher_remove_group;

  /// No description provided for @teacher_empty_groups.
  ///
  /// In en, this message translates to:
  /// **'Add a group token to enable statistics in Learn views.'**
  String get teacher_empty_groups;

  /// No description provided for @teacher_loading_saved_groups.
  ///
  /// In en, this message translates to:
  /// **'Loading saved groups...'**
  String get teacher_loading_saved_groups;

  /// Teacher stats opened-users label
  ///
  /// In en, this message translates to:
  /// **'Opened {opened}/{total}'**
  String teacher_stats_opened(int opened, String total);

  /// Teacher stats completed percentage label
  ///
  /// In en, this message translates to:
  /// **'Completed {percent}'**
  String teacher_stats_completed(String percent);

  /// Teacher stats activity completion percentage label
  ///
  /// In en, this message translates to:
  /// **'{percent} activity completion'**
  String teacher_stats_activity_completion(String percent);

  /// Teacher stats quiz average score label without maximum score
  ///
  /// In en, this message translates to:
  /// **'Avg score {score}'**
  String teacher_stats_avg_score(String score);

  /// Teacher stats quiz average score label with maximum score
  ///
  /// In en, this message translates to:
  /// **'Avg score {score}/{maxScore}'**
  String teacher_stats_avg_score_with_max(String score, String maxScore);

  /// No description provided for @learning_objective.
  ///
  /// In en, this message translates to:
  /// **'Learning objective'**
  String get learning_objective;

  /// No description provided for @group_code.
  ///
  /// In en, this message translates to:
  /// **'Group code'**
  String get group_code;

  /// No description provided for @group_code_title.
  ///
  /// In en, this message translates to:
  /// **'Join a learner group'**
  String get group_code_title;

  /// No description provided for @group_code_description.
  ///
  /// In en, this message translates to:
  /// **'Enter the group code from your teacher or paste a QR enrollment link. Your app progress will be linked to that group anonymously.'**
  String get group_code_description;

  /// No description provided for @group_code_hint.
  ///
  /// In en, this message translates to:
  /// **'Group code or enrollment link'**
  String get group_code_hint;

  /// No description provided for @group_code_required.
  ///
  /// In en, this message translates to:
  /// **'Enter a group code'**
  String get group_code_required;

  /// No description provided for @join_group.
  ///
  /// In en, this message translates to:
  /// **'Join group'**
  String get join_group;

  /// No description provided for @selected_group.
  ///
  /// In en, this message translates to:
  /// **'Selected group'**
  String get selected_group;

  /// No description provided for @group_connected.
  ///
  /// In en, this message translates to:
  /// **'Group connected'**
  String get group_connected;

  /// No description provided for @group_connected_message.
  ///
  /// In en, this message translates to:
  /// **'Your app is now linked to the selected learner group.'**
  String get group_connected_message;

  /// No description provided for @clear_group.
  ///
  /// In en, this message translates to:
  /// **'Clear group'**
  String get clear_group;

  /// No description provided for @group_code_error.
  ///
  /// In en, this message translates to:
  /// **'The group code was not found or is not active.'**
  String get group_code_error;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @unnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get unnamed;

  /// No description provided for @view_introduction.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get view_introduction;

  /// No description provided for @you_have_this_badge.
  ///
  /// In en, this message translates to:
  /// **'You have this badge'**
  String get you_have_this_badge;

  /// No description provided for @your_password.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get your_password;

  /// No description provided for @view_brochure.
  ///
  /// In en, this message translates to:
  /// **'View brochure'**
  String get view_brochure;

  /// No description provided for @welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Ecounity App - your gateway to digital learning, inspiration, and entrepreneurial growth.'**
  String get welcome_title;

  /// No description provided for @welcome_tagline.
  ///
  /// In en, this message translates to:
  /// **'Together for Planet!'**
  String get welcome_tagline;

  /// No description provided for @login_introduction_text.
  ///
  /// In en, this message translates to:
  /// **'Start exploring SDG learning modules, interactive comics, quizzes, and classroom challenges for planet-friendly action.'**
  String get login_introduction_text;

  /// No description provided for @srh_description.
  ///
  /// In en, this message translates to:
  /// **'Use these questions as a food for thought.'**
  String get srh_description;

  /// No description provided for @srh_what_was_most_impactful_for_me.
  ///
  /// In en, this message translates to:
  /// **'What was most impactful for me?'**
  String get srh_what_was_most_impactful_for_me;

  /// No description provided for @srh_what_will_i_put_into_practice.
  ///
  /// In en, this message translates to:
  /// **'What will I put into practice?'**
  String get srh_what_will_i_put_into_practice;

  /// No description provided for @srh_what_are_my_hopes_and_fears_for_the_future.
  ///
  /// In en, this message translates to:
  /// **'What are my hopes and fears for the future?'**
  String get srh_what_are_my_hopes_and_fears_for_the_future;

  /// No description provided for @no_video_found.
  ///
  /// In en, this message translates to:
  /// **'The video was not found.'**
  String get no_video_found;

  /// No description provided for @no_modules_found.
  ///
  /// In en, this message translates to:
  /// **'No modules were found.'**
  String get no_modules_found;

  /// No description provided for @no_contents_found.
  ///
  /// In en, this message translates to:
  /// **'Contents were not found.'**
  String get no_contents_found;

  /// No description provided for @no_resources_found.
  ///
  /// In en, this message translates to:
  /// **'Resources were not found.'**
  String get no_resources_found;

  /// No description provided for @no_images_found.
  ///
  /// In en, this message translates to:
  /// **'Images were not found.'**
  String get no_images_found;

  /// No description provided for @links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get links;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @cache_cleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared. Please reload the page.'**
  String get cache_cleared;

  /// No description provided for @module_completed.
  ///
  /// In en, this message translates to:
  /// **'Module completed'**
  String get module_completed;

  /// No description provided for @mark_as_completed.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get mark_as_completed;

  /// No description provided for @mark_as_not_completed.
  ///
  /// In en, this message translates to:
  /// **'Mark as not completed'**
  String get mark_as_not_completed;

  /// No description provided for @no_image_available.
  ///
  /// In en, this message translates to:
  /// **'No image available'**
  String get no_image_available;

  /// No description provided for @no_title.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get no_title;

  /// No description provided for @items_matched.
  ///
  /// In en, this message translates to:
  /// **'Items matched'**
  String get items_matched;

  /// No description provided for @all_items_matched.
  ///
  /// In en, this message translates to:
  /// **'All items matched!'**
  String get all_items_matched;

  /// No description provided for @play_again.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get play_again;

  /// No description provided for @not_enough_images_to_match.
  ///
  /// In en, this message translates to:
  /// **'Not enough images to match'**
  String get not_enough_images_to_match;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @error_loading_button.
  ///
  /// In en, this message translates to:
  /// **'Error loading button'**
  String get error_loading_button;

  /// No description provided for @seek.
  ///
  /// In en, this message translates to:
  /// **'Seek'**
  String get seek;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// Current module completion progress summary
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} modules completed'**
  String modules_completion_summary(int completed, int total);

  /// Current learning content completion progress summary
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} learning contents completed'**
  String learning_contents_completion_summary(int completed, int total);

  /// No description provided for @current_progress.
  ///
  /// In en, this message translates to:
  /// **'Current progress'**
  String get current_progress;

  /// No description provided for @next_suggestion.
  ///
  /// In en, this message translates to:
  /// **'Next suggestion'**
  String get next_suggestion;

  /// No description provided for @next_up.
  ///
  /// In en, this message translates to:
  /// **'Next up:'**
  String get next_up;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @you_have_completed_all_learning_contents.
  ///
  /// In en, this message translates to:
  /// **'You have completed all learning contents.'**
  String get you_have_completed_all_learning_contents;

  /// No description provided for @writeAnswerHere.
  ///
  /// In en, this message translates to:
  /// **'Type your answer here.'**
  String get writeAnswerHere;

  /// No description provided for @fieldCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'This field cannot be empty.'**
  String get fieldCannotBeEmpty;

  /// No description provided for @clear_answers.
  ///
  /// In en, this message translates to:
  /// **'Clear answers'**
  String get clear_answers;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fi',
    'it',
    'pl',
    'pt',
    'ro',
    'uk',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fi':
      return AppLocalizationsFi();
    case 'it':
      return AppLocalizationsIt();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
