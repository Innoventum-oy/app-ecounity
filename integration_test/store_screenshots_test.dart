import 'dart:io';

import 'package:core/core.dart' as core;
import 'package:ecounity/main.dart' as app;
import 'package:ecounity/src/objects/pathway.dart';
import 'package:ecounity/src/providers/selected_pathway_notifier.dart';
import 'package:ecounity/src/screens/challenges/quiz/quiz.dart';
import 'package:ecounity/src/util/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

const String _locale = String.fromEnvironment(
  'SCREENSHOT_LOCALE',
  defaultValue: 'en',
);

const List<PathwayType> _contentTypes = [
  PathwayType.wiki,
  PathwayType.quiz,
  PathwayType.dragdrop,
  PathwayType.video,
  PathwayType.slides,
];

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture store screenshots for $_locale', (tester) async {
    await app.main();
    await _settle(tester);
    await _prepareSurface(binding, tester);
    await _takeScreenshot(binding, '01_welcome');

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('screenshot-language-button')),
    );
    await _settle(tester);
    await _takeScreenshot(binding, '02_languages');

    await _tapVisible(tester, find.byKey(const ValueKey('dialog-ok-button')));
    await _settle(tester);

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('screenshot-continue-button')),
    );
    await _settle(tester);
    await _prepareDashboardSuggestionCover(tester);
    await _takeScreenshot(binding, '03_dashboard');

    await _captureNavigationScreens(binding, tester);
    final int nextScreenshotIndex = await _captureContentTypeScreens(
      binding,
      tester,
    );
    await _captureModuleUnitListScreen(binding, tester, nextScreenshotIndex);
  });
}

Future<void> _prepareDashboardSuggestionCover(WidgetTester tester) async {
  await _waitFor(
    tester,
    find.byKey(const ValueKey('screenshot-next-suggestion-card')),
  );

  final List<core.WebPage> candidates = _dashboardSuggestionCandidates(
    _availablePages(tester),
  ).where((page) => page.hasThumbnail).toList();
  if (candidates.isEmpty) {
    await _waitFor(
      tester,
      find.byKey(const ValueKey('screenshot-next-suggestion-cover-loaded')),
      timeout: const Duration(seconds: 60),
    );
    return;
  }

  final SelectedPathwayNotifier selectedPathwayNotifier =
      Provider.of<SelectedPathwayNotifier>(_appContext(tester), listen: false);
  final List<core.WebPage> orderedCandidates = _currentSelectionFirst(
    candidates,
    selectedPathwayNotifier.value?.id,
  );

  TestFailure? lastFailure;
  for (final core.WebPage page in orderedCandidates) {
    selectedPathwayNotifier.select(page);
    await _settle(tester);

    try {
      await _waitFor(
        tester,
        find.byKey(const ValueKey('screenshot-next-suggestion-cover-loaded')),
        timeout: const Duration(seconds: 60),
      );
      debugPrint('Dashboard screenshot suggestion: ${page.id} ${page.title}');
      return;
    } on TestFailure catch (error) {
      lastFailure = error;
      debugPrint('Skipping dashboard suggestion ${page.id}: ${error.message}');
    }
  }

  throw TestFailure(
    'No dashboard suggestion cover image loaded for $_locale. '
    '${lastFailure?.message ?? ''}',
  );
}

Future<void> _captureNavigationScreens(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
) async {
  await _navigate(tester, 'modules', navIndex: 1);
  await _waitFor(tester, find.byKey(const ValueKey('screenshot-modules-list')));
  await _waitForModuleThumbnails(tester);
  await _takeScreenshot(binding, '04_modules_list');

  await _navigate(tester, 'resources', navIndex: 2);
  await _waitFor(
    tester,
    find.byKey(const ValueKey('screenshot-resources-list')),
  );
  await _takeScreenshot(binding, '05_resources_list');
}

Future<int> _captureContentTypeScreens(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
) async {
  final List<core.WebPage> pages = _availablePages(tester);
  final core.WebPageList pageList = core.WebPageList(webPages: pages);

  int screenshotIndex = 6;
  for (final PathwayType type in _contentTypes) {
    final List<core.WebPage> candidates = _contentCandidates(pages, type);
    if (candidates.isEmpty) {
      debugPrint('Skipping ${type.name}: no candidate for $_locale');
      continue;
    }

    final String screenshotName =
        '${screenshotIndex.toString().padLeft(2, '0')}_content_${type.name}';
    await _captureFirstLoadableContentType(
      binding,
      tester,
      type,
      candidates,
      pageList,
      screenshotName,
    );
    screenshotIndex++;
  }
  return screenshotIndex;
}

Future<void> _captureModuleUnitListScreen(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  int screenshotIndex,
) async {
  await _navigate(tester, 'modules', navIndex: 1);
  await _waitFor(tester, find.byKey(const ValueKey('screenshot-modules-list')));
  await _waitForModuleThumbnails(tester);

  final List<core.WebPage> pages = _availablePages(tester);
  final core.WebPage? module = _firstModuleWithUnits(pages);
  if (module == null) {
    throw TestFailure('No module with MLR unit list found for $_locale.');
  }

  await _navigate(tester, 'submodules', navIndex: 1, data: module);
  await _waitFor(
    tester,
    find.byKey(const ValueKey('screenshot-module-units-list')),
  );
  await _takeScreenshot(
    binding,
    '${screenshotIndex.toString().padLeft(2, '0')}_module_units_list',
  );
}

Future<void> _captureFirstLoadableContentType(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  PathwayType type,
  List<core.WebPage> candidates,
  core.WebPageList pageList,
  String screenshotName,
) async {
  TestFailure? lastFailure;
  for (final core.WebPage page in candidates) {
    await _navigate(
      tester,
      type.name,
      navIndex: _navigationIndexFor(page, pageList.webPages),
      data: page,
      pathways: pageList,
      skipAutoOpenIntroduction: true,
    );

    try {
      await _waitFor(tester, find.byKey(ValueKey(_contentLoadedKey(type))));
      await _prepareContentScreenshot(tester, type);
      await _takeScreenshot(binding, screenshotName);
      return;
    } on TestFailure catch (error) {
      lastFailure = error;
      debugPrint(
        'Skipping ${type.name} candidate ${page.id}: ${error.message}',
      );
    }
  }

  throw TestFailure(
    'No ${type.name} candidate loaded for $_locale. '
    '${lastFailure?.message ?? ''}',
  );
}

Future<void> _prepareContentScreenshot(
  WidgetTester tester,
  PathwayType type,
) async {
  if (type == PathwayType.quiz) {
    _assertQuizCandidateIsLocalized(tester);

    final Finder nextIcon = find.descendant(
      of: find.byKey(const ValueKey('screenshot-content-quiz-loaded')),
      matching: find.byIcon(Icons.arrow_forward),
    );
    if (tester.any(nextIcon)) {
      await tester.tap(nextIcon.first);
      await _settle(tester);
    }
  }

  if (type == PathwayType.dragdrop) {
    await tester.pump(const Duration(seconds: 1));
  }
}

void _assertQuizCandidateIsLocalized(WidgetTester tester) {
  if (_normalizeLanguageCode(_locale) == 'en') {
    return;
  }

  final QuizState quizState = tester.state<QuizState>(find.byType(Quiz));
  final List<String> textValues = _quizTextValues(quizState.form).toList();
  if (!_containsEnglishFallbackQuizText(textValues)) {
    return;
  }

  throw TestFailure(
    'Quiz candidate loaded English fallback form text for $_locale.',
  );
}

Iterable<String> _quizTextValues(core.Form? form) sync* {
  for (final core.FormElement element in form?.elements ?? []) {
    yield element.title ?? '';
    yield element.description ?? '';
    yield element.htmldescription ?? '';
    yield element.help ?? '';

    for (final core.FormElementData option in element.elements ?? []) {
      yield option.value ?? '';
    }
  }
}

bool _containsEnglishFallbackQuizText(List<String> textValues) {
  final Set<String> normalizedValues = textValues
      .map((value) => value.trim().toLowerCase())
      .where((value) => value.isNotEmpty)
      .toSet();
  if (normalizedValues.isEmpty) {
    return false;
  }

  final String joined = normalizedValues.join(' ');
  const List<String> fallbackPhrases = [
    'terms and conditions help define',
    'social enterprise in poland can remove',
    'customers, beneficiaries or users',
    'copying terms and conditions',
    'true or false - terms and conditions',
    'true or false – terms and conditions',
  ];

  if (fallbackPhrases.any(joined.contains)) {
    return true;
  }

  return normalizedValues.contains('true') &&
      normalizedValues.contains('false') &&
      joined.contains('terms and conditions');
}

List<core.WebPage> _availablePages(WidgetTester tester) {
  final core.WebPageProvider provider = Provider.of<core.WebPageProvider>(
    _appContext(tester),
    listen: false,
  );
  return (provider.list ?? const <core.WebPage>[])
      .where(_isAvailableInLocale)
      .toList();
}

List<core.WebPage> _dashboardSuggestionCandidates(List<core.WebPage> pages) {
  final List<core.WebPage> subModules = [];
  final List<core.WebPage> resources = [];
  final List<core.WebPage> pathwayOptions = [];
  final List<core.WebPage> sortedPathwayOptions = [];

  for (final core.WebPage page in pages) {
    if (page.isSubModule) {
      subModules.add(page);
    } else if (page.isMainResource) {
      resources.add(page);
    } else if (!page.isMainPathway) {
      pathwayOptions.add(page);
    }
  }

  subModules.sort(_compareDashboardModules);
  for (final core.WebPage module in subModules) {
    final List<core.WebPage> modulePages =
        pathwayOptions.where((item) => item.parent == module.id).toList()
          ..sort(_compareDashboardModules);
    sortedPathwayOptions.addAll(modulePages);
  }

  resources.sort(_compareDashboardResources);
  for (final core.WebPage resourceCategory in resources) {
    final List<core.WebPage> resourcePages =
        pathwayOptions
            .where((item) => item.parent == resourceCategory.id)
            .toList()
          ..sort(_compareDashboardResources);
    sortedPathwayOptions.addAll(resourcePages);
  }

  return sortedPathwayOptions;
}

Future<void> _waitForModuleThumbnails(WidgetTester tester) async {
  final int expectedThumbnailCount = _moduleListPages(
    _availablePages(tester),
  ).where((page) => page.hasThumbnail).length;

  if (expectedThumbnailCount == 0) {
    return;
  }

  await _waitForCondition(
    tester,
    () => _loadedModuleThumbnailCount(tester) >= expectedThumbnailCount,
    '$expectedThumbnailCount module thumbnail frames',
    timeout: const Duration(seconds: 60),
  );
}

int _loadedModuleThumbnailCount(WidgetTester tester) {
  return tester.widgetList(_moduleThumbnailLoadedFinder()).length;
}

Finder _moduleThumbnailLoadedFinder() {
  return find.byWidgetPredicate((Widget widget) {
    final Key? key = widget.key;
    return key is ValueKey<String> &&
        key.value.startsWith('screenshot-module-thumbnail-loaded-');
  });
}

core.WebPage? _firstModuleWithUnits(List<core.WebPage> pages) {
  for (final core.WebPage module in _moduleListPages(pages)) {
    final bool hasUnits = pages.any((page) => page.parent == module.id);
    if (hasUnits) {
      return module;
    }
  }
  return null;
}

List<core.WebPage> _moduleListPages(List<core.WebPage> pages) {
  final List<core.WebPage> mainModules =
      pages.where((page) => page.isMainModule).toList()
        ..sort(_compareDashboardModules);
  final List<core.WebPage> moduleList = [];

  for (final core.WebPage mainModule in mainModules) {
    final List<core.WebPage> subModules =
        pages.where((page) => page.parent == mainModule.id).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    moduleList.addAll(subModules);
  }

  return moduleList;
}

int _compareDashboardModules(core.WebPage a, core.WebPage b) {
  if (a.pathwayName == null || b.pathwayName == null) {
    return 0;
  }
  return a.pathwayName!.compareTo(b.pathwayName!);
}

int _compareDashboardResources(core.WebPage a, core.WebPage b) {
  return a.sortOrder.compareTo(b.sortOrder);
}

List<core.WebPage> _currentSelectionFirst(
  List<core.WebPage> candidates,
  int? selectedId,
) {
  if (selectedId == null) {
    return candidates;
  }

  final int index = candidates.indexWhere((page) => page.id == selectedId);
  if (index <= 0) {
    return candidates;
  }

  return <core.WebPage>[
    candidates[index],
    ...candidates.take(index),
    ...candidates.skip(index + 1),
  ];
}

List<core.WebPage> _contentCandidates(
  List<core.WebPage> pages,
  PathwayType type,
) {
  final List<core.WebPage> candidates =
      pages.where((page) => _isContentCandidate(page, type)).toList()
        ..sort(_compareContentPages);
  return candidates;
}

bool _isContentCandidate(core.WebPage page, PathwayType type) {
  if (page.type != type ||
      page.isMainModule ||
      page.isSubModule ||
      page.isMainResource ||
      page.isMainPathway) {
    return false;
  }
  return switch (type) {
    PathwayType.quiz => page.getValue('form') != null,
    PathwayType.dragdrop ||
    PathwayType.slides => page.getValue('imagefolders') != null,
    PathwayType.video => (page.videoUrl ?? '').trim().isNotEmpty,
    PathwayType.wiki => true,
  };
}

int _compareContentPages(core.WebPage a, core.WebPage b) {
  final int parentCompare = (a.parent ?? 0).compareTo(b.parent ?? 0);
  if (parentCompare != 0) {
    return parentCompare;
  }
  final int sortCompare = a.sortOrder.compareTo(b.sortOrder);
  if (sortCompare != 0) {
    return sortCompare;
  }
  return a.title.compareTo(b.title);
}

int _navigationIndexFor(core.WebPage page, List<core.WebPage> pages) {
  final core.WebPage? parent = _pageById(pages, page.parent);
  if (parent == null) {
    return 1;
  }
  if (parent.isMainResource) {
    return 2;
  }
  final core.WebPage? grandparent = _pageById(pages, parent.parent);
  return grandparent != null && grandparent.isMainResource ? 2 : 1;
}

core.WebPage? _pageById(List<core.WebPage> pages, int? id) {
  if (id == null) {
    return null;
  }
  for (final core.WebPage page in pages) {
    if (page.id == id) {
      return page;
    }
  }
  return null;
}

String _contentLoadedKey(PathwayType type) {
  return 'screenshot-content-${type.name}-loaded';
}

Future<void> _navigate(
  WidgetTester tester,
  String view, {
  required int navIndex,
  dynamic data,
  core.WebPageList? pathways,
  bool skipAutoOpenIntroduction = false,
}) async {
  AppRouter.navigate(
    _appContext(tester),
    view,
    navIndex,
    data: data,
    pathways: pathways,
    skipAutoOpenIntroduction: skipAutoOpenIntroduction,
  );
  await tester.pump();
  await _settle(tester);
}

BuildContext _appContext(WidgetTester tester) {
  return app.navigatorKey.currentContext ??
      tester.element(find.byType(MaterialApp));
}

bool _isAvailableInLocale(core.WebPage page) {
  final String normalizedLocale = _normalizeLanguageCode(_locale);
  final List<String> contentLanguages = _normalizeLanguageList(
    page.getValue('contentlanguages'),
  );
  if (contentLanguages.isNotEmpty) {
    return contentLanguages.contains(normalizedLocale);
  }

  final String legacyLanguage = _normalizeLanguageCode(
    page.getValue('language')?.toString() ?? '',
  );
  return legacyLanguage.isEmpty || legacyLanguage == normalizedLocale;
}

List<String> _normalizeLanguageList(dynamic rawValue) {
  if (rawValue is String) {
    return rawValue
        .replaceAll(' ', '')
        .split(',')
        .map(_normalizeLanguageCode)
        .where((item) => item.isNotEmpty)
        .toList();
  }
  if (rawValue is List) {
    return rawValue
        .map((item) => item.toString())
        .map(_normalizeLanguageCode)
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return const <String>[];
}

String _normalizeLanguageCode(String value) {
  return value.split('_').first.split('-').first.toLowerCase().trim();
}

Future<void> _prepareSurface(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
) async {
  if (Platform.isAndroid) {
    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
  }
}

Future<void> _takeScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  await binding.takeScreenshot(name);
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await _settle(tester);
  await tester.tap(finder);
}

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final DateTime deadline = DateTime.now().add(timeout);
  while (!tester.any(finder)) {
    if (DateTime.now().isAfter(deadline)) {
      throw TestFailure('Timed out waiting for $finder');
    }
    await tester.pump(const Duration(milliseconds: 250));
  }
  await _settle(tester);
}

Future<void> _waitForCondition(
  WidgetTester tester,
  bool Function() condition,
  String description, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final DateTime deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TestFailure('Timed out waiting for $description');
    }
    await tester.pump(const Duration(milliseconds: 250));
  }
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 250),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 20),
    );
  } on FlutterError {
    await tester.pump(const Duration(seconds: 1));
  }
}
