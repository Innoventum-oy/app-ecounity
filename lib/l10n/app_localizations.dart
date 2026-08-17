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
  /// **'{item, select, home{Home} pathways{Pathways} challenges{Challenges} videolist{Videos} selfReflectionHub{Self-reflection Hub} lessons{Lessons} modules{Modules} resources{Resources} other{Menu:{item}}}'**
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
  /// **'Modules'**
  String get screenTitle_modules;

  /// No description provided for @screenTitle_resources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get screenTitle_resources;

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
