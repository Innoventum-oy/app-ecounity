import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/util/utils.dart';

import '../providers/locale_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
  // Create dropdown and get the options from AppLocalizations.supportedLocales
    return DropdownButton(
      hint: Text(context.l10n.select_language),
      onChanged: (Locale? locale) async {
        // Set the locale
         Provider.of<LocaleProvider>(context, listen: false).setLocale(locale!);
         // Language needs to be also saved to settings since the API uses the language
         await Settings().setLanguage(locale.languageCode);
         // Update app contents
        if(context.mounted) {
          loadAppData(context);
          // pop the dialog
          Navigator.of(context).pop();
        }
      },
      items: AppLocalizations.supportedLocales.map((Locale locale) {
        return DropdownMenuItem(
          value: locale,
          child: Text(context.l10n.locale(locale.toString())),
        );
      }).toList(),
    );

  }
}