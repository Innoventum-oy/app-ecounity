import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const pdfLocaleCodes = <String>['de', 'en', 'es', 'fi', 'pl', 'ro', 'uk'];

  test('supported locales match the PDF language baseline', () {
    final supportedLocaleCodes = AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .toList();

    expect(supportedLocaleCodes, pdfLocaleCodes);
    expect(supportedLocaleCodes, isNot(contains('it')));
    expect(supportedLocaleCodes, isNot(contains('pt')));
  });

  testWidgets('localization delegate loads the app shell', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: appLocalizationsDelegates,
        home: Builder(
          builder: (context) {
            return Scaffold(body: Text(context.l10n.application_name));
          },
        ),
      ),
    );

    expect(find.text('Ecounity'), findsOneWidget);
  });
}
