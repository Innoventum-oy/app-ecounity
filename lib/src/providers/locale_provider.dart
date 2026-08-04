import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;
  void setLocale(Locale loc) {
    if (!AppLocalizations.supportedLocales.contains(loc)) return;
    _locale = loc;
    notifyListeners();
  }

  void clearLocale() {
    _locale = null;
    notifyListeners();
  }
}
