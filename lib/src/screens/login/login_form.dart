import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:core/core.dart' as core;
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/providers/locale_provider.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:ecounity/src/util/utils.dart';
import '../../util/router.dart';
import '../../util/settings.dart';
import '../../widgets/content_page.dart';

const bool _screenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');

const String _defaultFundingLogoAsset =
    'assets/images/EN_Co-fundedbytheEU_RGB_NEG.png';

const Map<String, String> _fundingLogoAssetsByLanguage = {
  'de': 'assets/images/DE_Co-fundedbytheEU_RGB_NEG.png',
  'en': _defaultFundingLogoAsset,
  'fi': 'assets/images/FI_Co-fundedbytheEU_RGB_NEG.png',
  'it': 'assets/images/IT_Co-fundedbytheEU_RGB_NEG.png',
  'pl': 'assets/images/PL_Co-fundedbytheEU_RGB_NEG.png',
  'pt': 'assets/images/PT_Co-fundedbytheEU_RGB_NEG.png',
  'uk': 'assets/images/UK_Co-fundedbytheEU_RGB_NEG.png',
};

const List<Locale> _welcomeLocales = <Locale>[
  Locale('en'),
  Locale('de'),
  Locale('es'),
  Locale('fi'),
  Locale('pl'),
  Locale('ro'),
  Locale('uk'),
];

/// Login screen mode
enum LoginMode { initial, login, register, reset }

/// Login screen widget
class Login extends StatefulWidget {
  final dynamic user;

  const Login({super.key, this.user});
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false; // loading state
  String? _contact, _password; // form fields
  String serverName = ''; // server name
  String serverUrl = ''; // server url
  String appName = ''; // app name
  String packageName = ''; // package name
  String version = ''; // version
  String buildNumber = ''; // build number

  bool _showPassword = false; // show password state
  late core.AuthProvider auth; // auth provider
  late core.UserProvider userProvider; // user provider
  late final Map? servers; // server list
  bool serversLoaded = false; // server list loaded state
  LoginMode mode = LoginMode.initial; // login mode
  String versionInfo = '';
  String appDataVersion = '';

  String _fundingLogoAssetFor(Locale locale) {
    return _fundingLogoAssetsByLanguage[locale.languageCode] ??
        _defaultFundingLogoAsset;
  }

  LoginState() {
    PackageInfo.fromPlatform()
        .then((PackageInfo packageInfo) {
          if (mounted) {
            setState(() {
              appName = packageInfo.appName; // set app name
              packageName = packageInfo.packageName; // set package name
              version = packageInfo.version; // set version
              buildNumber = packageInfo.buildNumber; // set build number
            });
          }
        })
        .catchError((e) {
          log('Error getting package info: $e');
        });

    core.Settings().getServerName().then(
      (val) => setState(() {
        serverName = val; // set server name
      }),
    );
  }

  @override
  void initState() {
    super.initState();

    userProvider = Provider.of<core.UserProvider>(
      context,
      listen: false,
    ); // get user provider
    getServers(); // get servers
  }

  void getServers() async {
    servers = await core.AppSettings().getMap('servers'); // get servers
    setState(() {
      serversLoaded = true; // set servers loaded state
      if (kDebugMode) {
        log('Defaulting to development server');
        serverName =
            'development'; // set default server to development in debug mode
      }
    });
  }

  @override
  void didChangeDependencies() {
    auth = Provider.of<core.AuthProvider>(context); // get auth provider
    userProvider = Provider.of<core.UserProvider>(
      context,
      listen: false,
    ); // get user provider
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void load() {
    core.Settings()
        .getValue('appVersionDate')
        .then(
          (val) => setState(() {
            appDataVersion = val;
          }),
        );
  }

  Widget serverSelect() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        DropdownMenu<String>(
          label: Text(context.l10n.server),
          initialSelection: serverName,
          onSelected: (String? newValue) async {
            serverName = newValue!;
            await core.ApiClient().setServer(serverName);
            if (mounted) {
              appDataVersion = await updateAppVersionDate(context) ?? '';
            }
            setState(() {});
          },
          dropdownMenuEntries: servers!.keys.map<DropdownMenuEntry<String>>((
            dynamic value,
          ) {
            return DropdownMenuEntry<String>(
              value: value as String,
              label: value,
            );
          }).toList(),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: context.l10n.refresh,
          onPressed: () async {
            try {
              // First try to empty the file storage normally
              await core.FileStorage().empty();
            } catch (e) {
              // If that fails (due to corrupted data), force clear everything
              if (kDebugMode) {
                log('Error emptying storage: $e. Force clearing...');
              }
              try {
                await Hive.close();
                await Hive.deleteFromDisk();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.cache_cleared),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } catch (clearError) {
                if (kDebugMode) {
                  log('Error force clearing storage: $clearError');
                }
              }
            }
            if (mounted) {
              await updateAppVersionDate(context, forceRefresh: true);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<core.UserProvider>(context); // get user provider
    auth = Provider.of<core.AuthProvider>(context); // get auth provider
    core.User? user = widget.user; // get user
    String? contact = _contact; // get contact
    if (user != null && contact == null) {
      contact = user.phone != null
          ? user.phone!
          : user.email != null
          ? user.email!
          : '';
    }

    Widget showTextIconButton() {
      return IconButton(
        icon: Icon(
          // Based on passwordVisible state choose the icon
          _showPassword ? Icons.visibility : Icons.visibility_off,
          //  color:  Theme.of(context).colorScheme.primary,
        ),
        onPressed: () {
          // Update the state i.e. toogle the state of passwordVisible variable
          setState(() {
            _showPassword = !_showPassword;
          });
        },
      );
    }

    String? validateContact(String? value) {
      String? msg;
      final String normalizedValue = value?.trim() ?? '';
      if (normalizedValue.isEmpty) {
        return context.l10n.please_enter_phone_or_email;
      }

      if (_isPhoneNumberInput(normalizedValue) ||
          EmailValidator.validate(normalizedValue)) {
        return null;
      }

      msg = context.l10n.please_provide_valid_phone_or_email;
      return msg;
    }

    final contactField = TextFormField(
      autofocus: false,
      validator: validateContact,
      onSaved: (value) => _contact = value,
      decoration: InputDecoration(
        hintText: context.l10n.phone_or_email,
        prefixIcon: const Icon(Icons.email),
      ),
      initialValue: contact,
    );

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: !_showPassword,
      initialValue: _password,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      validator: (value) =>
          value!.isEmpty ? context.l10n.please_enter_password : null,
      onSaved: (value) => _password = value,
      decoration: InputDecoration(
        hintText: context.l10n.password,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: showTextIconButton(),
      ),
    );

    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const CircularProgressIndicator(),
        Text(context.l10n.authenticating),
      ],
    );

    final forgotLabel = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: ElevatedButton(
            child: Text(
              context.l10n.button_forgot_password,
              style: const TextStyle(fontWeight: FontWeight.w300),
            ),
            onPressed: () {
              AppRouter.navigate(context, '/reset-password', 0);
            },
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              AppRouter.navigate(context, AppRoutes.login, 0);
            },

            child: Text(context.l10n.button_back),
          ),
        ),
      ],
    );
    final cancelButton = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TextButton(
          child: Text(
            context.l10n.button_cancel,
            style: const TextStyle(fontWeight: FontWeight.w300),
          ),
          onPressed: () async {
            //auth.logout(user);
            auth.cancelLogin();
          },
        ),
      ],
    );

    doLogin() {
      final form = formKey.currentState;

      if (form!.validate()) {
        form.save();
        setState(() {
          isLoading = true;
        });

        final Future<core.ApiResponse> successfulMessage = auth.login(
          _contact!,
          _password!,
        );

        successfulMessage.then((core.ApiResponse response) {
          if (kDebugMode) {
            print('$response');
          }
          if (response.status == core.ResponseStatus.success) {
            core.User user = response.getData(key: 'user') as core.User;
            userProvider.setUser(user);
          } else {
            // userProvider.clearUser();
            if (context.mounted) {
              Flushbar(
                title: context.l10n.login_failed,
                message: response.message ?? context.l10n.error_occurred,
                duration: const Duration(seconds: 3),
              ).show(context);
            }
          }
          setState(() {
            isLoading = false;
          });
        });
      }
    }

    final List<Widget> debugControls = [];
    final List<Widget> contents = [];
    if (serversLoaded && kDebugMode && !_screenshotMode) {
      debugControls.add(serverSelect());
    }

    switch (mode) {
      case LoginMode.initial:
        contents.addAll(<Widget>[
          const _WelcomeHeader(),
          const SizedBox(height: 18),
          Text(
            context.l10n.choose_language,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: EcoUnityColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          const _WelcomeLanguageSelector(),
          if (debugControls.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: debugControls),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const ValueKey('screenshot-continue-button'),
              onPressed: () {
                auth.setRegisteredStatus(core.Status.notRegistered);
                auth.loginGuest();

                AppRouter.navigate(context, AppRoutes.dashboard, 0);
              },
              child: Text(context.l10n.start),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  mode = LoginMode.login;
                });
              },
              child: Text(context.l10n.button_login),
            ),
          ),
        ]);
        break;
      case LoginMode.login:
        // Show login form
        contents.addAll([
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    mode = LoginMode.initial;
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  context.l10n.button_login,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: EcoUnityColors.deepTeal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (debugControls.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: debugControls),
          ],
          const SizedBox(height: 18),
          Text(context.l10n.email_or_phone_number),
          const SizedBox(height: 5.0),
          contactField,
          const SizedBox(height: 20.0),
          Text(context.l10n.your_password),
          const SizedBox(height: 5.0),
          passwordField,
          const SizedBox(height: 20.0),
          isLoading || auth.loggedInStatus == core.Status.authenticating
              ? loading
              : ElevatedButton(
                  onPressed: doLogin,
                  child: Text(context.l10n.button_login),
                ),
          const SizedBox(height: 15.0),
          forgotLabel,
          const SizedBox(height: 15.0),
          auth.loggedInStatus == core.Status.authenticating
              ? cancelButton
              : Container(),
        ]);
        break;
      case LoginMode.register:
        // TODO: Handle this case.
        break;
      case LoginMode.reset:
        // TODO: Handle this case.
        break;
    }

    return Scaffold(
      backgroundColor: EcoUnityColors.surface,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
              children: <Widget>[
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...contents,

                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            policyLink(),
                            //  Text(serverName),
                            versionWidget(),
                          ],
                        ),
                      ),
                      // EU co-funded logo.
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          Center(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: EcoUnityColors.deepTeal,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Image.asset(
                                  _fundingLogoAssetFor(
                                    Localizations.localeOf(context),
                                  ),
                                  width: 220,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          context.l10n.funding_disclaimer,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: EcoUnityColors.textSecondary,
                                fontSize: 11,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget trailingWidget(String currentname) {
    return (serverName == currentname)
        ? const Icon(Icons.check, color: Colors.blue)
        : const Icon(null);
  }

  Widget versionWidget() {
    return Text(
      '$appName v.$version($buildNumber) $appDataVersion',
      textAlign: TextAlign.center,
      // style: TextStyle(color: Color(0xFFffe8d7))
    );
  }

  Widget policyLink() {
    return TextButton(
      onPressed: () {
        //View policy page
        setState(() {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ContentPage('privacy-policy')),
          );
        });
      },
      child: Text(
        context.l10n.privacy_policy,
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          //color: Color(0xFFffe8d7)
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Image.asset(
          'assets/images/ecounity-logo.png',
          height: 96,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.application_name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: EcoUnityColors.deepTeal,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Together for Planet!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: EcoUnityColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          context.l10n.login_introduction_text,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: EcoUnityColors.textSecondary),
        ),
      ],
    );
  }
}

class _WelcomeLanguageSelector extends StatelessWidget {
  const _WelcomeLanguageSelector();

  @override
  Widget build(BuildContext context) {
    final Locale currentLocale =
        Provider.of<LocaleProvider>(context).locale ??
        Localizations.localeOf(context);

    return Column(
      children: <Widget>[
        for (final Locale locale in _welcomeLocales)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _WelcomeLanguageOption(
              locale: locale,
              selected: currentLocale.languageCode == locale.languageCode,
            ),
          ),
      ],
    );
  }
}

class _WelcomeLanguageOption extends StatelessWidget {
  const _WelcomeLanguageOption({required this.locale, required this.selected});

  final Locale locale;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final String languageCode = locale.languageCode.toUpperCase();
    final Color borderColor = selected
        ? EcoUnityColors.turquoise
        : EcoUnityColors.outlineVariant;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _selectLocale(context, locale),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE6F8F7) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? EcoUnityColors.turquoise
                      : EcoUnityColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  languageCode,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected ? Colors.white : EcoUnityColors.deepTeal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.locale(locale.languageCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: EcoUnityColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                selected ? 'Selected' : 'Choose',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: EcoUnityColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectLocale(BuildContext context, Locale locale) async {
    Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);
    await core.Settings().setLanguage(locale.languageCode);
    if (context.mounted) {
      await loadAppData(context);
    }
  }
}

bool _isPhoneNumberInput(String value) {
  int startIndex = 0;
  if (value.startsWith('+')) {
    startIndex = 1;
  }

  final int digitCount = value.length - startIndex;
  final int maxDigits = value.startsWith('0') ? 13 : 12;
  if (digitCount < 10 || digitCount > maxDigits) {
    return false;
  }

  for (int index = startIndex; index < value.length; index += 1) {
    final int codeUnit = value.codeUnitAt(index);
    if (codeUnit < 0x30 || codeUnit > 0x39) {
      return false;
    }
  }
  return true;
}
