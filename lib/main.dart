import 'dart:async';
import 'dart:developer';

import 'package:core/core.dart' as core;
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/analytics/ecounity_analytics_service.dart';
import 'package:ecounity/src/analytics/ecounity_group_context.dart';
import 'package:ecounity/src/analytics/ecounity_group_enrollment_service.dart';
import 'package:ecounity/src/learning/ecounity_learning_provider.dart';
import 'package:ecounity/src/providers/ecounity_badge_provider.dart';
import 'package:ecounity/src/providers/ecounity_group_context_provider.dart';
import 'package:ecounity/src/providers/ecounity_teacher_report_provider.dart';
import 'package:ecounity/src/providers/locale_provider.dart';
import 'package:ecounity/src/providers/selected_pathway_notifier.dart';
import 'package:ecounity/src/providers/teacher_mode_provider.dart';
import 'package:ecounity/src/screens/dashboard/dashboard.dart';
import 'package:ecounity/src/screens/login/login_form.dart';
import 'package:ecounity/src/util/app_theme.dart';
import 'package:ecounity/src/util/core_compat.dart';
import 'package:ecounity/src/util/ecounity_storage.dart';
import 'package:ecounity/src/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

final navigatorKey = NavigationService.navigatorKey;
const bool _screenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');
const String _screenshotLocaleCode = String.fromEnvironment(
  'SCREENSHOT_LOCALE',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  late core.FileStorage fileStorage;

  try {
    fileStorage = await core.FileStorage.initialize();
    // Only register the additional adapters here
    await EcoUnityStorage(fileStorage).registerAdapters();
  } catch (e) {
    // If there's an error (likely schema mismatch), clear the storage and reinitialize
    if (kDebugMode) {
      log('Error initializing storage: $e. Clearing storage and retrying...');
    }
    try {
      // Close all boxes and delete from disk to clear corrupted data
      await Hive.close();
      await Hive.deleteFromDisk();
    } catch (clearError) {
      if (kDebugMode) {
        log('Error clearing storage: $clearError');
      }
    }
    // Reinitialize after clearing
    fileStorage = await core.FileStorage.initialize();
    await EcoUnityStorage(fileStorage).registerAdapters();
  }

  if (_screenshotLocaleCode.isNotEmpty) {
    await core.Settings().setLanguage(_screenshotLocaleCode);
  }

  runApp(
    // Create providers for the application to enable state management
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final LocaleProvider localeProvider = LocaleProvider();
            if (_screenshotLocaleCode.isNotEmpty) {
              localeProvider.setLocale(Locale(_screenshotLocaleCode));
            }
            return localeProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => core.AuthProvider(),
        ), // AuthProvider
        ChangeNotifierProvider(
          create: (_) => core.UserProvider(),
        ), // UserProvider
        ChangeNotifierProvider(
          create: (_) => core.WebPageProvider(),
        ), // WebPageProvider
        ChangeNotifierProvider(
          create: (_) => EcoUnityBadgeProvider(),
        ), // BadgeProvider
        ChangeNotifierProvider(
          create: (_) => EcoUnityLearningProvider(),
        ), // EcoUnityLearningProvider
        ChangeNotifierProvider(
          create: (_) => EcoUnityGroupContextProvider(),
        ), // EcoUnityGroupContextProvider
        ChangeNotifierProvider(
          create: (_) => EcoUnityTeacherReportProvider(),
        ), // EcoUnityTeacherReportProvider
        ChangeNotifierProvider(
          create: (_) => TeacherModeProvider(),
        ), // TeacherModeProvider
        Provider<EcoUnityAnalyticsService>(
          create: (_) => EcoUnityAnalyticsService(),
        ),
        ChangeNotifierProvider(create: (_) => SelectedPathwayNotifier()),
        ChangeNotifierProvider(create: (_) => fileStorage), // FileStorage
        ChangeNotifierProvider<AppImageProvider>(
          create: (_) => createImageProvider(),
        ),
      ],
      child: const Ecounity(),
    ),
  );
}

class Ecounity extends StatefulWidget {
  const Ecounity({super.key});

  @override
  EcounityState createState() => EcounityState();
}

class EcounityState extends State<Ecounity> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Listen to ApiClient isProcessingNotifier
    core.ApiClient().isProcessingNotifier.addListener(_handleProcessing);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_screenshotMode || !mounted) {
        return;
      }
      unawaited(
        Provider.of<EcoUnityAnalyticsService>(
          context,
          listen: false,
        ).startSession(language: Localizations.localeOf(context).languageCode),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initLocale();
  }

  void initLocale() async {
    if (_screenshotLocaleCode.isNotEmpty) {
      return;
    }

    String? savedLocale = await core.Settings().getLanguage();
    if (savedLocale != null && mounted) {
      Provider.of<LocaleProvider>(
        context,
        listen: false,
      ).setLocale(Locale(savedLocale));
    }
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    core.ApiClient().isProcessingNotifier.removeListener(_handleProcessing);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_screenshotMode || !mounted) {
      return;
    }
    final EcoUnityAnalyticsService analytics =
        Provider.of<EcoUnityAnalyticsService>(context, listen: false);
    final String language = Localizations.localeOf(context).languageCode;
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(analytics.startSession(language: language));
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(analytics.endSession(language: language));
        break;
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    if (_screenshotMode) {
      return;
    }
    if (kDebugMode) {
      log(
        'System language changed: ${locales?.map((locale) => locale.toString()).join(', ')}',
      );
    }
    core.Settings().setLanguage(locales!.first.languageCode);
    // Reload the app data when the system language changes
    loadAppData(context);
  }

  void _handleProcessing() {
    // if the ApiClient is processing, show the loader overlay
    if (core.ApiClient().isProcessingNotifier.value) {
      context.loaderOverlay.show();
    } else {
      // if the ApiClient is not processing, hide the loader overlay
      context.loaderOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    // if settings has language set, get locale based on that

    return MaterialApp(
      title: 'Ecounity',
      debugShowCheckedModeBanner: false, // remove debug banner
      navigatorKey: navigatorKey, // set global navigator key
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: appTheme,
      locale: Provider.of<LocaleProvider>(context).locale,
      home: const AppLocalizationState(),
    );
  }
}

class AppLocalizationState extends StatefulWidget {
  const AppLocalizationState({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AppLocalizationState();
  }
}

class _AppLocalizationState extends State<AppLocalizationState>
    with WidgetsBindingObserver {
  bool _openedDataRefreshStarted = false;

  Future<core.User> getUserData() async {
    return await Provider.of<core.AuthProvider>(context).user;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSavedLocaleAndRefreshCachedData();
    });
  }

  Future<void> _initSavedLocaleAndRefreshCachedData() async {
    if (_openedDataRefreshStarted) {
      return;
    }
    _openedDataRefreshStarted = true;

    if (_screenshotMode) {
      return;
    }

    String? savedLocale = await core.Settings().getLanguage();
    if (savedLocale == null && mounted) {
      // set the current locale to settings
      String language = Localizations.localeOf(context).languageCode;
      await core.Settings().setLanguage(language);
      if (!mounted) {
        return;
      }
      setState(() {});
    }

    if (!mounted) {
      return;
    }

    await _handleInitialGroupEnrollmentLink();
    if (!mounted) {
      return;
    }

    try {
      await updateAppVersionDate(context, forceRefresh: true);
    } catch (e, stackTrace) {
      if (kDebugMode || kProfileMode) {
        log(
          'Could not refresh cached app data on startup: $e',
          stackTrace: stackTrace,
        );
      }
    }
  }

  Future<void> _handleInitialGroupEnrollmentLink() async {
    final String? joinToken = EcoUnityGroupEnrollmentService.joinTokenFromUri(
      Uri.base,
    );
    if (joinToken == null || joinToken.isEmpty) {
      return;
    }

    try {
      final EcoUnityAnalyticsGroupContext group =
          await Provider.of<EcoUnityGroupContextProvider>(
            context,
            listen: false,
          ).enrollWithCode(joinToken);
      final String language = await _applyGroupLanguage(group.language);
      if (!mounted) {
        return;
      }
      await Provider.of<EcoUnityAnalyticsService>(
        context,
        listen: false,
      ).handleGroupContextChanged(language: language);
    } catch (e, stackTrace) {
      if (kDebugMode || kProfileMode) {
        log(
          'Could not resolve group enrollment link: $e',
          stackTrace: stackTrace,
        );
      }
    }
  }

  Future<String> _applyGroupLanguage(String? languageCode) async {
    final String fallbackLanguage = Localizations.localeOf(
      context,
    ).languageCode;
    final String? normalized = languageCode?.trim().toLowerCase();
    if (normalized == null ||
        !AppLocalizations.supportedLocales.any(
          (Locale locale) => locale.languageCode == normalized,
        )) {
      return await core.Settings().getLanguage() ?? fallbackLanguage;
    }

    await core.Settings().setLanguage(normalized);
    if (mounted) {
      Provider.of<LocaleProvider>(
        context,
        listen: false,
      ).setLocale(Locale(normalized));
    }
    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    core.AuthProvider auth = Provider.of<core.AuthProvider>(context);
    return LoaderOverlay(
      child: FutureBuilder(
        initialData: auth.user,
        future: getUserData(),
        builder: (context, snapshot) {
          if (kDebugMode) {
            log(
              "main.dart: snapshot connectionState: ${snapshot.connectionState.toString()}",
            );
            log(
              'Locales in use: ${AppLocalizations.supportedLocales}; Current locale: ${Localizations.localeOf(context)}, intl locale: ${Intl.getCurrentLocale()}',
            );
          }

          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              // Show a loading spinner while waiting for the user data
              return const Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(),
                ),
              );
            default:
              if (snapshot.hasError) {
                // Show an error message if the future fails
                return Container(
                  color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 50,
                      left: 20,
                      right: 20,
                    ),
                    child: Text(
                      'Error occurred: ${snapshot.error} :: ${snapshot.stackTrace}\n Sorry! x(',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                );
              } else if (snapshot.hasData) {
                // User data is available: check if the user is logged in
                core.User userdata = snapshot.data as core.User;
                if (userdata.token != null || userdata.isGuest) {
                  Provider.of<core.UserProvider>(
                    context,
                    listen: false,
                  ).setUserSilent(userdata);
                  // User is logged in or guest, show the dashboard
                  return const DashBoard();
                }
                if (kDebugMode || kProfileMode) {
                  log('User not logged in, showing login screen');
                }
                return const Login();
              } else {
                // Remove the user data if the future fails
                core.UserPreferences.removeUser();
              }
              //
              return const Login(); //Welcome(user: snapshot.data as User);
          }
        },
      ),
    );
  }
}
