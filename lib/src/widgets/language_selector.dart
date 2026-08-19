import 'dart:async';

import 'package:core/core.dart';
import 'package:ecounity/src/analytics/ecounity_analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/util/utils.dart';

import '../providers/locale_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: AppLocalizations.supportedLocales.map((Locale locale) {
        final Locale currentLocale =
            Provider.of<LocaleProvider>(context).locale ??
            Localizations.localeOf(context);
        final bool isCurrent =
            currentLocale.languageCode == locale.languageCode;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final String previousLanguage = currentLocale.languageCode;
                final EcoUnityAnalyticsService? analytics = _analyticsOf(
                  context,
                );
                Provider.of<LocaleProvider>(
                  context,
                  listen: false,
                ).setLocale(locale);
                await Settings().setLanguage(locale.languageCode);
                if (analytics != null) {
                  unawaited(
                    analytics.trackLanguageChanged(
                      previousLanguage: previousLanguage,
                      newLanguage: locale.languageCode,
                    ),
                  );
                }
                if (context.mounted) {
                  loadAppData(context);
                  Navigator.of(context).pop();
                }
              },
              icon: Text(_localeFlag(locale.languageCode)),
              label: Text(context.l10n.locale(locale.toString())),
              style: OutlinedButton.styleFrom(
                backgroundColor: isCurrent
                    ? Colors.blue.withValues(alpha: 0.1)
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _localeFlag(String languageCode) {
    switch (languageCode) {
      case 'de':
        return '🇦🇹';
      case 'en':
        return '🇬🇧';
      case 'fi':
        return '🇫🇮';
      case 'it':
        return '🇮🇹';
      case 'pl':
        return '🇵🇱';
      case 'pt':
        return '🇵🇹';
      case 'uk':
        return '🇺🇦';
      default:
        return '🌐';
    }
  }
}

EcoUnityAnalyticsService? _analyticsOf(BuildContext context) {
  try {
    return Provider.of<EcoUnityAnalyticsService>(context, listen: false);
  } catch (_) {
    return null;
  }
}
