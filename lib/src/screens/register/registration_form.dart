import 'package:core/core.dart' as core;
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import '../../util/router.dart';
import '../../util/settings.dart';

enum ContactMethod { phone, email }

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  RegistrationFormState createState() => RegistrationFormState();
}

class RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final core.Auth apiClient = core.Auth();

  late core.User user;
  String? errorMessage;
  late bool loading = false;
  ContactMethod contactMethod = ContactMethod.phone;
  bool _obscureText = true;
  Map<String, TextEditingController> controllers = {
    'firstname': TextEditingController(),
    'lastname': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'password': TextEditingController(),
  };

  PhoneNumber phoneNumber = PhoneNumber(isoCode: 'FI'); // Default to Finland
  String initialCountry = 'FI';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      user = Provider.of<core.UserProvider>(context, listen: false).user;
      setInitialCountry();
    });
  }

  void setInitialCountry() {
    String languageCode = Localizations.localeOf(context).languageCode;
    switch (languageCode) {
      case 'fi':
        initialCountry = 'FI';
        break;
      case 'es':
        initialCountry = 'ES';
        break;
      case 'ro':
        initialCountry = 'RO';
        break;
      case 'de':
        initialCountry = 'DE';
        break;
      case 'pl':
        initialCountry = 'PL';
        break;
      case 'uk':
        initialCountry = 'UA';
        break;
      default:
        initialCountry =
            'FI'; // Default to Finland if language is English or unknown
    }
    phoneNumber = PhoneNumber(isoCode: initialCountry);
  }

  @override
  Widget build(BuildContext context) {
    String firstNameLabel = context.l10n.firstName;
    String lastNameLabel = context.l10n.lastName;
    String emailLabel = context.l10n.email;
    String phoneLabel = context.l10n.phone;
    String passwordLabel = context.l10n.password;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.register)),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(40.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                children: <Widget>[
                  Center(child: Image.asset('assets/images/ecounity-logo.png')),
                  Form(
                    key: _formKey,
                    onChanged: () {
                      setState(() {
                        errorMessage = null;
                      });
                    },
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controllers['firstname'],
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.person),
                                  labelText: firstNameLabel,
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return context.l10n.field_required(
                                      firstNameLabel,
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: controllers['lastname'],
                                decoration: InputDecoration(
                                  labelText: lastNameLabel,
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return context.l10n.field_required(
                                      lastNameLabel,
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controllers['email'],
                          decoration: InputDecoration(
                            labelText: emailLabel,
                            prefixIcon: const Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return context.l10n.field_required(emailLabel);
                            }
                            if (!EmailValidator.validate(value)) {
                              return context.l10n.email_not_valid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            //    controllers['phone']?.text = number.phoneNumber ?? '';
                            if (kDebugMode) {
                              print(number.phoneNumber);
                            }
                            phoneNumber = number;
                          },
                          locale: Localizations.localeOf(context).languageCode,

                          initialValue: phoneNumber,
                          selectorConfig: const SelectorConfig(
                            selectorType: PhoneInputSelectorType.DROPDOWN,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          // selectorTextStyle: const TextStyle(color: Colors.black),
                          textFieldController: controllers['phone'],
                          formatInput: false,

                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          inputDecoration: InputDecoration(
                            labelText: phoneLabel,
                            prefixIcon: const Icon(Icons.phone),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return context.l10n.field_required(phoneLabel);
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controllers['password'],
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            labelText: passwordLabel,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return context.l10n.field_required(passwordLabel);
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (loading) return;
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      loading = true;
                                    });
                                    apiClient
                                        .register(
                                          firstname:
                                              controllers['firstname']?.text ??
                                              '',
                                          lastname:
                                              controllers['lastname']?.text ??
                                              '',
                                          email: controllers['email']?.text,
                                          phone: phoneNumber.phoneNumber,
                                          password:
                                              controllers['password']?.text ??
                                              '',
                                        )
                                        .then((core.ApiResponse response) {
                                          setState(() {
                                            if (kDebugMode) {
                                              print(response);
                                            }
                                            loading = false;
                                            if (response.status ==
                                                    core.ResponseStatus.error ||
                                                response.statusCode != 200) {
                                              errorMessage =
                                                  response.message ??
                                                  context.l10n.error_occurred;
                                            } else {
                                              core.User user =
                                                  core.User.fromJson(
                                                    response.getData(
                                                      key: 'user',
                                                    ),
                                                  );
                                              Provider.of<core.UserProvider>(
                                                context,
                                                listen: false,
                                              ).setUser(user);
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      context
                                                          .l10n
                                                          .registration_successful,
                                                    ),
                                                    content: Text(
                                                      context.l10n
                                                          .registration_successful_message(
                                                            user.firstname ??
                                                                '',
                                                          ),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                          AppRouter.navigate(
                                                            context,
                                                            AppRoutes.dashboard,
                                                            0,
                                                          );
                                                        },
                                                        child: Text(
                                                          context
                                                              .l10n
                                                              .button_ok,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          });
                                        });
                                  }
                                },
                                style: loading
                                    ? ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                              Colors.grey,
                                            ),
                                      )
                                    : null,
                                child: Text(context.l10n.register),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () {
                                  AppRouter.navigate(
                                    context,
                                    AppRoutes.login,
                                    0,
                                  );
                                },
                                style: loading
                                    ? ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                              Colors.grey,
                                            ),
                                      )
                                    : null,
                                child: Text(context.l10n.button_back),
                              ),
                            ),
                          ],
                        ),
                        if (loading) const CupertinoActivityIndicator(),
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Card(
                              color: Colors.red,
                              child: ListTile(
                                leading: const Icon(Icons.error),
                                title: Text(context.l10n.error('')),
                                subtitle: Text(errorMessage!),
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
      ),
    );
  }
}
