import 'package:core/core.dart' as core;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/widgets/screen_footer.dart';

core.WebPage _makePage({
  required int id,
  required String category,
  int? parent,
  String title = '',
}) {
  return core.WebPage(
    id: id,
    data: {
      'id': id.toString(),
      'title': title,
      'textcontents': <String>[],
      'pagecategory': category,
      if (parent != null) 'pageid': parent.toString(),
    },
  );
}

Widget _wrapWithLocalization(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets(
    'ScreenFooter excludes main modules and keeps next within same module',
    (WidgetTester tester) async {
      final core.WebPage mainModuleA = _makePage(
        id: 1,
        category: 'modules',
        title: 'Module A',
      );
      final core.WebPage moduleAUnit1 = _makePage(
        id: 2,
        category: 'wiki',
        parent: 1,
        title: 'Unit 1',
      );
      final core.WebPage moduleAUnit2 = _makePage(
        id: 3,
        category: 'wiki',
        parent: 1,
        title: 'Unit 2',
      );

      final core.WebPageList pathways = core.WebPageList(
        webPages: [mainModuleA, moduleAUnit1, moduleAUnit2],
      );

      await tester.pumpWidget(
        _wrapWithLocalization(
          ScreenFooter(
            webPage: moduleAUnit1,
            navIndex: 1,
            pathways: pathways,
            isCompleted: true,
            showOpenIntroduction: false,
            showMarkCompleted: false,
            showNextWhenCompleted: false,
            showRestart: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    },
  );

  testWidgets(
    'ScreenFooter skips main modules when moving across module boundaries',
    (WidgetTester tester) async {
      final core.WebPage mainModuleA = _makePage(
        id: 1,
        category: 'modules',
        title: 'Module A',
      );
      final core.WebPage moduleAUnit1 = _makePage(
        id: 2,
        category: 'wiki',
        parent: 1,
        title: 'Unit 1',
      );
      final core.WebPage mainModuleB = _makePage(
        id: 10,
        category: 'modules',
        title: 'Module B',
      );
      final core.WebPage moduleBUnit1 = _makePage(
        id: 11,
        category: 'wiki',
        parent: 10,
        title: 'Unit 2',
      );

      final core.WebPageList pathways = core.WebPageList(
        webPages: [mainModuleA, moduleAUnit1, mainModuleB, moduleBUnit1],
      );

      await tester.pumpWidget(
        _wrapWithLocalization(
          ScreenFooter(
            webPage: moduleBUnit1,
            navIndex: 1,
            pathways: pathways,
            isCompleted: true,
            showOpenIntroduction: false,
            showMarkCompleted: false,
            showNextWhenCompleted: false,
            showRestart: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsNothing);
    },
  );

  test(
    'ScreenFooter skips module containers and targets first page of next module',
    () {
      final core.WebPage rootModule = _makePage(
        id: 1,
        category: 'modules',
        title: 'Modules',
      );
      final core.WebPage module5 = _makePage(
        id: 50,
        category: 'submodule',
        parent: 1,
        title: 'Module 5',
      );
      final core.WebPage module5Page1 = _makePage(
        id: 51,
        category: 'wiki',
        parent: 50,
        title: 'Module 5 page 1',
      );
      final core.WebPage module5Page2 = _makePage(
        id: 52,
        category: 'quiz',
        parent: 50,
        title: 'Module 5 page 2',
      );
      final core.WebPage module6 = _makePage(
        id: 60,
        category: 'submodule',
        parent: 1,
        title: 'Module 6',
      );
      final core.WebPage module6Page1 = _makePage(
        id: 61,
        category: 'wiki',
        parent: 60,
        title: 'Module 6 page 1',
      );

      final core.WebPageList pathways = core.WebPageList(
        webPages: [
          rootModule,
          module5,
          module5Page1,
          module5Page2,
          module6,
          module6Page1,
        ],
      );

      final ScreenFooter footer = ScreenFooter(
        webPage: module5Page2,
        navIndex: 1,
        pathways: pathways,
        isCompleted: true,
        showOpenIntroduction: false,
        showMarkCompleted: false,
        showNextWhenCompleted: false,
        showRestart: false,
      );

      final core.WebPage? next = footer.getNextTargetForTesting(pathways);

      expect(next?.id, module6Page1.id);
    },
  );
}
