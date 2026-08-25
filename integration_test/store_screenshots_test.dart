import 'dart:io';

import 'package:ecounity/main.dart' as app;
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_provider.dart';
import 'package:ecounity/src/util/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

const String _locale = String.fromEnvironment(
  'SCREENSHOT_LOCALE',
  defaultValue: 'en',
);

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture EcoUnity store screenshots for $_locale', (
    WidgetTester tester,
  ) async {
    await app.main();
    await _settle(tester);
    await _prepareSurface(binding, tester);

    await _waitFor(
      tester,
      find.byKey(const ValueKey<String>('screenshot-welcome-screen')),
    );
    await _takeScreenshot(binding, '01_welcome');

    await _waitFor(
      tester,
      find.byKey(const ValueKey<String>('screenshot-language-options')),
    );
    await _takeScreenshot(binding, '02_language_options');

    await _tapVisible(
      tester,
      find.byKey(const ValueKey<String>('screenshot-continue-button')),
    );
    await _waitForLearningModules(tester);
    await _waitFor(
      tester,
      find.byKey(const ValueKey<String>('screenshot-dashboard-ready')),
      timeout: const Duration(seconds: 90),
    );
    await _takeScreenshot(binding, '03_dashboard');

    final EcoUnitySdgModule module = await _selectScreenshotModule(tester);

    await _navigate(tester, 'learningmodules', navIndex: 1);
    await _waitFor(
      tester,
      find.byKey(const ValueKey<String>('learning-modules-list')),
    );
    await _waitForModuleIcons(tester);
    await _takeScreenshot(binding, '04_sdg_modules');

    await _captureModuleDetail(binding, tester, module);

    await _captureActivity(
      binding,
      tester,
      module,
      EcoUnityActivityType.mlr,
      '06_mlr_activity',
    );
    await _captureActivity(
      binding,
      tester,
      module,
      EcoUnityActivityType.quiz,
      '07_quiz_activity',
    );
    await _captureActivity(
      binding,
      tester,
      module,
      EcoUnityActivityType.comic,
      '08_comic_story',
    );
    await _captureChallengeOrReflection(binding, tester, module);

    await _seedProgressForScreenshot(tester, module);
    await _navigate(tester, 'progress', navIndex: 2);
    await _waitFor(
      tester,
      find.byKey(const ValueKey<String>('screenshot-progress-loaded')),
      timeout: const Duration(seconds: 90),
    );
    await _takeScreenshot(binding, '10_progress');
  });
}

Future<void> _captureModuleDetail(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  EcoUnitySdgModule module,
) async {
  await _navigate(tester, 'learningmodule', navIndex: 1, data: module);
  await _waitFor(
    tester,
    find.byKey(const ValueKey<String>('learning-module-detail-list')),
    timeout: const Duration(seconds: 90),
  );
  await _takeScreenshot(binding, '05_sdg_detail');
}

Future<void> _captureActivity(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  EcoUnitySdgModule module,
  EcoUnityActivityType type,
  String screenshotName,
) async {
  final EcoUnityLearningActivity? activity = await _loadActivityOfType(
    tester,
    module,
    type,
  );
  if (activity == null) {
    debugPrint('Skipping $screenshotName: no ${type.name} activity found.');
    return;
  }

  await _navigate(tester, 'learningactivity', navIndex: 1, data: activity);
  if (type == EcoUnityActivityType.comic) {
    await _waitFor(
      tester,
      find.byKey(const ValueKey<String>('screenshot-content-comic-cover')),
      timeout: const Duration(seconds: 90),
    );
    await _tapVisible(
      tester,
      find.byKey(const ValueKey<String>('screenshot-comic-cover-start-button')),
    );
  }
  await _waitFor(
    tester,
    find.byKey(ValueKey<String>(_activityLoadedKey(type))),
    timeout: type == EcoUnityActivityType.comic
        ? const Duration(seconds: 150)
        : const Duration(seconds: 90),
  );
  await _prepareActivityScreenshot(tester, type);
  await _takeScreenshot(binding, screenshotName);
}

Future<void> _captureChallengeOrReflection(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  EcoUnitySdgModule module,
) async {
  final EcoUnityLearningActivity? challenge = await _loadActivityOfType(
    tester,
    module,
    EcoUnityActivityType.challenge,
  );
  if (challenge != null) {
    await _navigate(tester, 'learningactivity', navIndex: 1, data: challenge);
    await _waitFor(
      tester,
      find.byKey(
        ValueKey<String>(_activityLoadedKey(EcoUnityActivityType.challenge)),
      ),
      timeout: const Duration(seconds: 90),
    );
    await _takeScreenshot(binding, '09_challenge_activity');
    return;
  }

  final EcoUnityLearningActivity? reflection = await _loadActivityOfType(
    tester,
    module,
    EcoUnityActivityType.reflection,
  );
  if (reflection == null) {
    debugPrint('Skipping challenge/reflection screenshot: no activity found.');
    return;
  }

  await _navigate(tester, 'learningactivity', navIndex: 1, data: reflection);
  await _waitFor(
    tester,
    find.byKey(
      ValueKey<String>(_activityLoadedKey(EcoUnityActivityType.reflection)),
    ),
    timeout: const Duration(seconds: 90),
  );
  await _takeScreenshot(binding, '09_reflection_activity');
}

Future<EcoUnitySdgModule> _selectScreenshotModule(WidgetTester tester) async {
  final EcoUnityLearningProvider provider = _learningProvider(tester);
  final List<EcoUnitySdgModule> sourceModules = provider.modules
      .where((EcoUnitySdgModule module) => module.id != null)
      .toList();
  if (sourceModules.isEmpty) {
    throw TestFailure('No EcoUnity SDG modules loaded for $_locale.');
  }

  EcoUnitySdgModule? bestModule;
  int bestScore = -1;
  for (final EcoUnitySdgModule module in sourceModules) {
    final EcoUnitySdgModule hydrated =
        await provider.loadModule(module.id!, language: _normalizedLocale) ??
        module;
    final int score = _moduleScreenshotScore(hydrated);
    if (score > bestScore) {
      bestScore = score;
      bestModule = hydrated;
    }
  }

  if (bestModule == null) {
    throw TestFailure(
      'No screenshot-ready EcoUnity module found for $_locale.',
    );
  }

  return bestModule;
}

Future<EcoUnityLearningActivity?> _loadActivityOfType(
  WidgetTester tester,
  EcoUnitySdgModule module,
  EcoUnityActivityType type,
) async {
  final EcoUnityLearningActivity? summaryActivity = _activityOfType(
    module,
    type,
  );
  final int? activityId = summaryActivity?.id;
  if (activityId == null) {
    return summaryActivity;
  }

  return await _learningProvider(
        tester,
      ).loadActivity(activityId, language: _normalizedLocale) ??
      summaryActivity;
}

EcoUnityLearningActivity? _activityOfType(
  EcoUnitySdgModule module,
  EcoUnityActivityType type,
) {
  for (final EcoUnityLearningActivity activity in module.activities) {
    if (activity.type == type) {
      return activity;
    }
  }
  return null;
}

int _moduleScreenshotScore(EcoUnitySdgModule module) {
  int score = 0;
  if (module.coverImage != null) {
    score += 2;
  }
  if (module.iconImage != null) {
    score += 1;
  }
  if (_activityOfType(module, EcoUnityActivityType.comic) != null) {
    score += 5;
  }
  if (_activityOfType(module, EcoUnityActivityType.mlr) != null) {
    score += 4;
  }
  if (_activityOfType(module, EcoUnityActivityType.quiz) != null) {
    score += 4;
  }
  if (_activityOfType(module, EcoUnityActivityType.challenge) != null) {
    score += 3;
  }
  if (_activityOfType(module, EcoUnityActivityType.reflection) != null) {
    score += 2;
  }
  if (module.sdgNumber == 5 || module.sdgNumber == 12) {
    score += 1;
  }
  return score;
}

Future<void> _seedProgressForScreenshot(
  WidgetTester tester,
  EcoUnitySdgModule module,
) async {
  final EcoUnityLearningProvider provider = _learningProvider(tester);
  final List<EcoUnityLearningActivity> sampleActivities = module.activities
      .where(
        (EcoUnityLearningActivity activity) =>
            activity.moduleId != null &&
            activity.id != null &&
            activity.completionRequired,
      )
      .take(2)
      .toList();

  for (final EcoUnityLearningActivity activity in sampleActivities) {
    await provider.markActivityCompleted(
      moduleId: activity.moduleId!,
      activityId: activity.id!,
      language: _normalizedLocale,
      payload: <String, dynamic>{
        'activity_type': activity.type.name,
        'source': 'store_screenshot',
      },
    );
  }

  await provider.loadProgress(language: _normalizedLocale);
}

Future<void> _prepareActivityScreenshot(
  WidgetTester tester,
  EcoUnityActivityType type,
) async {
  if (type == EcoUnityActivityType.quiz) {
    final Finder firstOption = _quizOptionFinder();
    if (tester.any(firstOption)) {
      await tester.tap(firstOption.first);
      await _settle(tester);
    }
  }

  if (type == EcoUnityActivityType.comic) {
    await tester.pump(const Duration(milliseconds: 800));
  }
}

Finder _quizOptionFinder() {
  return find.byWidgetPredicate((Widget widget) {
    final Key? key = widget.key;
    return key is ValueKey<String> && key.value.startsWith('quiz-option-');
  });
}

Future<void> _waitForLearningModules(WidgetTester tester) async {
  await _waitForCondition(
    tester,
    () {
      final EcoUnityLearningProvider provider = _learningProvider(tester);
      return provider.hasCompletedModuleLoad && provider.modules.isNotEmpty;
    },
    'EcoUnity learning modules for $_locale',
    timeout: const Duration(seconds: 120),
  );
}

Future<void> _waitForModuleIcons(WidgetTester tester) async {
  final int expected = _learningProvider(tester).modules
      .where((EcoUnitySdgModule module) => module.iconImage != null)
      .length;
  if (expected == 0) {
    return;
  }

  await _waitForCondition(
    tester,
    () => tester.widgetList(_moduleIconLoadedFinder()).isNotEmpty,
    'at least one SDG module icon',
    timeout: const Duration(seconds: 60),
  );
}

Finder _moduleIconLoadedFinder() {
  return find.byWidgetPredicate((Widget widget) {
    final Key? key = widget.key;
    return key is ValueKey<String> && key.value.startsWith('sdg-module-icon-');
  });
}

String _activityLoadedKey(EcoUnityActivityType type) {
  return switch (type) {
    EcoUnityActivityType.comic => 'screenshot-content-comic-loaded',
    EcoUnityActivityType.mlr => 'screenshot-content-mlr-loaded',
    EcoUnityActivityType.quiz => 'screenshot-content-quiz-loaded',
    EcoUnityActivityType.reflection => 'screenshot-content-reflection-loaded',
    EcoUnityActivityType.challenge => 'screenshot-content-challenge-loaded',
    EcoUnityActivityType.unknown => 'screenshot-content-activity-loaded',
  };
}

EcoUnityLearningProvider _learningProvider(WidgetTester tester) {
  return Provider.of<EcoUnityLearningProvider>(
    _appContext(tester),
    listen: false,
  );
}

Future<void> _navigate(
  WidgetTester tester,
  String view, {
  required int navIndex,
  dynamic data,
}) async {
  AppRouter.navigate(
    _appContext(tester),
    view,
    navIndex,
    data: data,
    replaceRoute: true,
  );
  await tester.pump();
  await _settle(tester);
}

BuildContext _appContext(WidgetTester tester) {
  return app.navigatorKey.currentContext ??
      tester.element(find.byType(MaterialApp));
}

String get _normalizedLocale {
  return _locale.split('_').first.split('-').first.toLowerCase().trim();
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
  await _settle(tester);
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
