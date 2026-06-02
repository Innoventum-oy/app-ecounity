// Extension to provide non-nullable access to AppLocalizations
// This file should NOT be auto-generated - keep it separate from generated files

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ecounity/l10n/app_localizations.dart' as generated;

// Re-export the generated AppLocalizations
export 'package:ecounity/l10n/app_localizations.dart';

/// Returns the list of localization delegates
List<LocalizationsDelegate<dynamic>> get appLocalizationsDelegates {
  return [
    generated.AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

extension AppLocalizationsExtension on BuildContext {
  /// Returns the AppLocalizations instance for this context.
  /// Throws if AppLocalizations is not found in the widget tree.
  generated.AppLocalizations get l10n {
    final localizations = generated.AppLocalizations.of(this);
    return localizations;
  }
}
