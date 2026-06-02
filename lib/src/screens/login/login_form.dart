import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:core/core.dart' as core;
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/util/utils.dart';
import '../../util/app_theme.dart';
import '../../util/router.dart';
import '../../util/settings.dart';
import '../../widgets/content_page.dart';
import '../../widgets/language_selector.dart';
import '../../widgets/popupdialog.dart';

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
    updateAppVersionDate(context, forceRefresh: true);
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
    return Expanded(
      flex: 2,
      child: Wrap(
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
        ]
      )
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
      if (value!.isEmpty) return context.l10n.please_enter_phone_or_email;

      //test for phone number pattern
      String pattern = r'(^(?:[+0])?[0-9]{10,12}$)';
      RegExp regExp = RegExp(pattern);
      if (regExp.hasMatch(value)) {
        return null;
      }
      //test for email pattern
      RegExp regex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
      );
      if (!regex.hasMatch(value)) {
        msg = context.l10n.please_provide_valid_phone_or_email;
      }
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
      style: const TextStyle(color: Colors.white),
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

    List<Widget> rowChildren = [];
    List<Widget> contents = [];
    //if(kDebugMode)
    contents.add(const SizedBox(height: 15));
    if (serversLoaded && kDebugMode) rowChildren.add(serverSelect());
    // add language select to columnChildren
    rowChildren.add(
      IconButton(
        tooltip: context.l10n.choose_language,
        icon: const Icon(Icons.language),
        onPressed: () {
          // open language chooser
          popupDialog(context.l10n.language, LanguageSelector(), context);
        },
      ),
    );
    contents.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: rowChildren
            )
          )
        ],
      ),
    );
    switch (mode) {
      case LoginMode.initial:
        // Show buttons to Login / Create Account / Continue as Guest
        contents.insert(
          0,
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10.0, // spacing between children

              children: [
                Text(
                  context.l10n.welcome_title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  context.l10n.login_introduction_text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
        contents.addAll([
          /* SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  mode = LoginMode.login;
                });
              },
              child: Text(AppLocalizations.of(context)!.button_login),
            ),
          ),
          const SizedBox(height: 15.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                auth.setRegisteredStatus(core.Status.notRegistered);
                AppRouter.navigate(context,AppRoutes.register, 0);
              },
              child: Text(AppLocalizations.of(context)!.button_create_account),
            ),
          ),*/
          const SizedBox(height: 15.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                auth.setRegisteredStatus(core.Status.notRegistered);
                auth.loginGuest();

                AppRouter.navigate(context, AppRoutes.dashboard, 0);
              },
              child: Text(context.l10n.button_continue),
            ),
          ),
        ]);
        break;
      case LoginMode.login:
        // Show login form
        contents.addAll([
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

    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(40.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                children: <Widget>[
                  Center(
                    child: appTheme.brightness == Brightness.dark
                        ? Image.asset('assets/images/ecounity-logo.png')
                        : Image.asset('assets/images/ecounity-logo.png'),
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...contents,

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  policyLink(),
                                  //  Text(serverName),
                                  versionWidget()
                                ]
                              )
                            ),
                          ],
                        ),
                        // Erasmus logo and Sepie logo
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                Image.asset(
                                  'assets/images/erasmusplus.png',
                                  width: 100,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            context.l10n.funding_disclaimer,
                            style: const TextStyle(fontSize: 11),
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
