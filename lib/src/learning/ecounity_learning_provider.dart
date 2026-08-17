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
  List<EcoUnitySdgModule> modules = <EcoUnitySdgModule>[];
  List<EcoUnityProgressEntry> progressEntries = <EcoUnityProgressEntry>[];

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

  Future<List<EcoUnitySdgModule>> loadModules({
    String language = 'en',
    bool reload = false,
  }) async {
    if (!reload && modules.isNotEmpty) {
      return modules;
    }

    loadingStatus = core.DataLoadingStatus.loading;
    error = null;
    notifyListeners();

    try {
      modules = await _repository.loadModules(language: language);
      loadingStatus = core.DataLoadingStatus.loaded;
      notifyListeners();
      return modules;
    } catch (exception) {
      loadingStatus = core.DataLoadingStatus.error;
      error = exception.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<EcoUnityLearningActivity?> loadActivity(
    int activityId, {
    String language = 'en',
  }) {
    return _repository.loadActivity(activityId, language: language);
  }

  Future<EcoUnitySdgModule?> loadModule(
    int moduleId, {
    String language = 'en',
  }) async {
    final EcoUnitySdgModule? module = await _repository.loadModule(
      moduleId,
      language: language,
    );
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

  Future<List<EcoUnityProgressEntry>> loadProgress({
    String? language,
    int? moduleId,
    int? activityId,
  }) async {
    progressEntries = await _repository.loadProgress(
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
    final EcoUnityProgressEntry? saved = await _repository.saveProgress(
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
