import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';

import 'ecounity_learning_models.dart';
import 'ecounity_learning_repository.dart';

class EcoUnityLearningProvider with ChangeNotifier {
  EcoUnityLearningProvider({EcoUnityLearningRepository? repository})
    : _repository = repository ?? EcoUnityLearningRepository();

  final EcoUnityLearningRepository _repository;

  core.DataLoadingStatus loadingStatus = core.DataLoadingStatus.notLoaded;
  String? error;
  String? modulesLanguage;
  List<EcoUnitySdgModule> modules = <EcoUnitySdgModule>[];
  List<EcoUnityProgressEntry> progressEntries = <EcoUnityProgressEntry>[];
  final Set<String> _completedComicWarmupSignatures = <String>{};
  Future<void>? _comicWarmupFuture;
  String? _comicWarmupSignature;
  int _moduleLoadGeneration = 0;

  bool get isLoaded => loadingStatus == core.DataLoadingStatus.loaded;

  EcoUnitySdgModule? moduleBySdgNumber(int sdgNumber) {
    for (final EcoUnitySdgModule module in modules) {
      if (module.sdgNumber == sdgNumber) {
        return module;
      }
    }
    return null;
  }

  EcoUnitySdgModule? moduleById(int moduleId) {
    for (final EcoUnitySdgModule module in modules) {
      if (module.id == moduleId) {
        return module;
      }
    }
    return null;
  }

  void clearLoadedContent() {
    _moduleLoadGeneration += 1;
    modules = <EcoUnitySdgModule>[];
    modulesLanguage = null;
    progressEntries = <EcoUnityProgressEntry>[];
    loadingStatus = core.DataLoadingStatus.notLoaded;
    error = null;
    notifyListeners();
  }

  Future<List<EcoUnitySdgModule>> loadModules({
    String language = 'en',
    bool reload = false,
  }) async {
    final String normalizedLanguage = _normalizeLanguage(language);
    if (!reload &&
        modules.isNotEmpty &&
        modulesLanguage == normalizedLanguage) {
      return modules;
    }

    final int loadGeneration = ++_moduleLoadGeneration;
    if (modulesLanguage != null && modulesLanguage != normalizedLanguage) {
      modules = <EcoUnitySdgModule>[];
    }
    loadingStatus = core.DataLoadingStatus.loading;
    error = null;
    notifyListeners();

    try {
      final List<EcoUnitySdgModule> loadedModules = await _repository
          .loadModules(language: normalizedLanguage);
      if (loadGeneration != _moduleLoadGeneration) {
        return loadedModules;
      }
      modules = loadedModules;
      modulesLanguage = normalizedLanguage;
      loadingStatus = core.DataLoadingStatus.loaded;
      notifyListeners();
      return modules;
    } catch (exception) {
      if (loadGeneration == _moduleLoadGeneration) {
        loadingStatus = core.DataLoadingStatus.error;
        error = exception.toString();
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<EcoUnityLearningActivity?> loadActivity(
    int activityId, {
    String language = 'en',
    int? comicSceneLimit,
    bool reload = false,
  }) {
    return _repository.loadActivity(
      activityId,
      language: language,
      comicSceneLimit: comicSceneLimit,
      reload: reload,
    );
  }

  EcoUnityLearningActivity? cachedActivity(
    int activityId, {
    String language = 'en',
    int? comicSceneLimit,
  }) {
    return _repository.cachedActivity(
      activityId,
      language: language,
      comicSceneLimit: comicSceneLimit,
    );
  }

  Future<EcoUnitySdgModule?> loadModule(
    int moduleId, {
    String language = 'en',
  }) async {
    final String normalizedLanguage = _normalizeLanguage(language);
    final EcoUnitySdgModule? module = await _repository.loadModule(
      moduleId,
      language: normalizedLanguage,
    );
    if (module != null &&
        (modules.isEmpty || modulesLanguage == normalizedLanguage)) {
      modulesLanguage = normalizedLanguage;
      modules =
          <EcoUnitySdgModule>[
            ...modules.where((EcoUnitySdgModule item) => item.id != module.id),
            module,
          ]..sort((EcoUnitySdgModule a, EcoUnitySdgModule b) {
            return (a.sdgNumber ?? 0).compareTo(b.sdgNumber ?? 0);
          });
      notifyListeners();
    }
    return module;
  }

  Future<void> warmComicActivityCache({
    String language = 'en',
    Iterable<EcoUnitySdgModule>? modules,
    int concurrency = 1,
    bool force = false,
  }) {
    final String normalizedLanguage = _normalizeLanguage(language);
    final List<EcoUnitySdgModule> sourceModules =
        modules?.toList(growable: false) ?? this.modules;
    final List<int> moduleIds =
        sourceModules
            .map((EcoUnitySdgModule module) => module.id)
            .whereType<int>()
            .toList()
          ..sort();
    final String signature =
        '$normalizedLanguage:${moduleIds.join(',')}:$concurrency';

    if (sourceModules.isEmpty) {
      return Future<void>.value();
    }
    if (!force && _completedComicWarmupSignatures.contains(signature)) {
      return Future<void>.value();
    }
    final Future<void>? currentWarmup = _comicWarmupFuture;
    if (!force && currentWarmup != null && _comicWarmupSignature == signature) {
      return currentWarmup;
    }

    final Future<void> future = _repository
        .warmComicActivityCache(
          sourceModules,
          language: normalizedLanguage,
          concurrency: concurrency,
        )
        .then((_) {
          _completedComicWarmupSignatures.add(signature);
        })
        .catchError((Object exception, StackTrace stackTrace) {
          if (kDebugMode) {
            debugPrint(
              'Unable to warm EcoUnity comic activity cache: $exception',
            );
            debugPrintStack(stackTrace: stackTrace);
          }
        });

    late final Future<void> trackedFuture;
    trackedFuture = future.whenComplete(() {
      if (_comicWarmupFuture == trackedFuture) {
        _comicWarmupFuture = null;
      }
    });
    _comicWarmupSignature = signature;
    _comicWarmupFuture = trackedFuture;
    return _comicWarmupFuture!;
  }

  String _normalizeLanguage(String language) {
    final String normalized = language.trim().toLowerCase();
    return normalized.isEmpty ? 'en' : normalized;
  }

  Future<List<EcoUnityProgressEntry>> loadProgress({
    String? language,
    int? moduleId,
    int? activityId,
  }) async {
    progressEntries = await _repository.loadLocalProgress(
      language: language,
      moduleId: moduleId,
      activityId: activityId,
    );
    notifyListeners();
    return progressEntries;
  }

  Future<EcoUnityProgressEntry?> markActivityOpened({
    required int moduleId,
    required int activityId,
    String language = 'en',
    Map<String, dynamic> payload = const <String, dynamic>{},
  }) {
    return saveActivityProgress(
      moduleId: moduleId,
      activityId: activityId,
      status: EcoUnityProgressStatus.opened,
      language: language,
      payload: payload,
    );
  }

  Future<EcoUnityProgressEntry?> markActivityCompleted({
    required int moduleId,
    required int activityId,
    String language = 'en',
    Map<String, dynamic> payload = const <String, dynamic>{},
  }) {
    return saveActivityProgress(
      moduleId: moduleId,
      activityId: activityId,
      status: EcoUnityProgressStatus.completed,
      language: language,
      payload: payload,
    );
  }

  Future<EcoUnityProgressEntry?> saveActivityProgress({
    required int moduleId,
    required int activityId,
    required EcoUnityProgressStatus status,
    String language = 'en',
    Map<String, dynamic> payload = const <String, dynamic>{},
  }) async {
    final EcoUnityProgressEntry? saved = await _repository.saveLocalProgress(
      moduleId: moduleId,
      activityId: activityId,
      status: status,
      language: language,
      payload: payload,
    );

    if (saved != null) {
      progressEntries = <EcoUnityProgressEntry>[
        ...progressEntries.where(
          (EcoUnityProgressEntry entry) =>
              entry.activityId != saved.activityId ||
              entry.language != saved.language,
        ),
        saved,
      ];
      notifyListeners();
    }

    return saved;
  }

  Future<EcoUnitySdgModule?> updateModuleContentStatus({
    required int moduleId,
    required EcoUnityContentStatus status,
    String language = 'en',
  }) async {
    final EcoUnitySdgModule? module = await _repository
        .updateModuleContentStatus(moduleId, status, language: language);
    if (module != null) {
      modules =
          <EcoUnitySdgModule>[
            ...modules.where((EcoUnitySdgModule item) => item.id != module.id),
            module,
          ]..sort((EcoUnitySdgModule a, EcoUnitySdgModule b) {
            return (a.sdgNumber ?? 0).compareTo(b.sdgNumber ?? 0);
          });
      notifyListeners();
    }
    return module;
  }

  Future<EcoUnityLearningActivity?> updateActivityContentStatus({
    required int activityId,
    required EcoUnityContentStatus status,
    String language = 'en',
  }) async {
    final EcoUnityLearningActivity? activity = await _repository
        .updateActivityContentStatus(activityId, status, language: language);
    if (activity != null) {
      notifyListeners();
    }
    return activity;
  }
}
