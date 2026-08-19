import 'dart:convert';

import 'package:core/core.dart' as core;

import 'ecounity_learning_models.dart';

abstract class EcoUnityLearningBackend {
  Future<dynamic> getDataList(String objectType, Map<String, dynamic> params);

  Future<dynamic> getDetails(String objectType, int objectId);

  Future<dynamic> saveObject(
    int? objectId,
    String objectType,
    Map<String, dynamic> objectData,
  );
}

class EcoUnityCoreLearningBackend implements EcoUnityLearningBackend {
  EcoUnityCoreLearningBackend({core.ApiClient? apiClient})
    : _apiClient = apiClient ?? core.ApiClient();

  final core.ApiClient _apiClient;

  @override
  Future<dynamic> getDataList(String objectType, Map<String, dynamic> params) {
    return _apiClient.getDataList(objectType, params);
  }

  @override
  Future<dynamic> getDetails(String objectType, int objectId) {
    return _apiClient.getDetails(objectType, objectId);
  }

  @override
  Future<dynamic> saveObject(
    int? objectId,
    String objectType,
    Map<String, dynamic> objectData,
  ) {
    return _apiClient.saveObject(objectId ?? 'new', objectType, objectData);
  }
}

class EcoUnityLearningRepository {
  EcoUnityLearningRepository({
    EcoUnityLearningBackend? backend,
    core.FileStorage? fileStorage,
    bool? usePersistentCache,
  }) : _backend = backend ?? EcoUnityCoreLearningBackend(),
       _fileStorage = fileStorage ?? core.FileStorage(),
       _usePersistentCache = usePersistentCache ?? backend == null;

  static const String sdgModuleObjectType = 'ecounitysdgmodule';
  static const String activityObjectType = 'ecounitylearningactivity';
  static const String questionObjectType = 'ecounityquestion';
  static const String comicSceneObjectType = 'ecounitycomicscene';
  static const String sceneBackgroundObjectType = 'ecounityscenebackground';
  static const String sceneCastObjectType = 'ecounityscenecast';
  static const String scenePropObjectType = 'ecounitysceneprop';
  static const String sceneDialogueObjectType = 'ecounityscenedialogue';
  static const String sceneSpeechObjectType = 'ecounityscenespeech';
  static const String comicDecisionObjectType = 'ecounitycomicdecision';
  static const String progressObjectType = 'ecounitylearningprogress';
  static const String learningCacheBoxName = 'ecounityLearningCache';

  static const List<String> moduleFields = <String>[
    'id',
    'objectid',
    'sdg_number',
    'slug',
    'title',
    'introduction',
    'learning_objective',
    'estimated_minutes',
    'difficulty',
    'content_status',
    'icon_image',
    'cover_image',
    'activities',
    'badges',
    'tags',
  ];

  static const List<String> activityFields = <String>[
    'id',
    'objectid',
    'module',
    'sdg_number',
    'slug',
    'activity_type',
    'flow_stage',
    'orderno',
    'mlr_number',
    'title',
    'short_description',
    'body',
    'key_message',
    'reflection_prompt',
    'completion_text',
    'video_url',
    'estimated_minutes',
    'difficulty',
    'learning_objective',
    'completion_required',
    'passing_logic',
    'minimum_score',
    'content_status',
    'hero_image',
    'media_images',
    'files',
    'questions',
    'comic_scenes',
    'tags',
  ];

  static const List<String> progressFields = <String>[
    'id',
    'objectid',
    'user',
    'module',
    'activity',
    'language',
    'status',
    'source',
    'payload_json',
    'started_at',
    'completed_at',
  ];

  static const List<String> comicSceneFields = <String>[
    'id',
    'objectid',
    'comic_activity',
    'scene_key',
    'orderno',
    'title',
    'narration',
    'alt_text',
    'backgrounds',
    'cast',
    'props',
    'decisions',
    'content_status',
  ];

  final EcoUnityLearningBackend _backend;
  final core.FileStorage _fileStorage;
  final bool _usePersistentCache;
  final Map<_ActivityCacheKey, EcoUnityLearningActivity> _activityCache =
      <_ActivityCacheKey, EcoUnityLearningActivity>{};
  final Map<_ActivityCacheKey, Future<EcoUnityLearningActivity?>>
  _activityLoadFutures =
      <_ActivityCacheKey, Future<EcoUnityLearningActivity?>>{};
  final Map<_DetailCacheKey, Map<String, dynamic>> _detailCache =
      <_DetailCacheKey, Map<String, dynamic>>{};
  final Map<_DetailCacheKey, Future<Map<String, dynamic>?>> _detailLoadFutures =
      <_DetailCacheKey, Future<Map<String, dynamic>?>>{};
  final Map<_ComicSceneListCacheKey, List<Map<String, dynamic>>>
  _comicSceneListCache =
      <_ComicSceneListCacheKey, List<Map<String, dynamic>>>{};
  final Map<_ComicSceneListCacheKey, Future<List<Map<String, dynamic>>>>
  _comicSceneListLoadFutures =
      <_ComicSceneListCacheKey, Future<List<Map<String, dynamic>>>>{};

  EcoUnityLearningActivity? cachedActivity(
    int activityId, {
    String language = 'en',
    int? comicSceneLimit,
  }) {
    final String normalizedLanguage = _normalizeLanguage(language);
    final EcoUnityLearningActivity? fullActivity =
        _activityCache[_ActivityCacheKey(activityId, normalizedLanguage, null)];
    if (fullActivity != null) {
      return fullActivity;
    }
    return _activityCache[_ActivityCacheKey(
      activityId,
      normalizedLanguage,
      comicSceneLimit,
    )];
  }

  void clearActivityCache(int activityId, {String? language}) {
    final String? normalizedLanguage = language == null
        ? null
        : _normalizeLanguage(language);
    _activityCache.removeWhere((key, _) {
      return key.activityId == activityId &&
          (normalizedLanguage == null || key.language == normalizedLanguage);
    });
    _activityLoadFutures.removeWhere((key, _) {
      return key.activityId == activityId &&
          (normalizedLanguage == null || key.language == normalizedLanguage);
    });
    _comicSceneListCache.removeWhere((key, _) {
      return key.activityId == activityId &&
          (normalizedLanguage == null || key.language == normalizedLanguage);
    });
    _comicSceneListLoadFutures.removeWhere((key, _) {
      return key.activityId == activityId &&
          (normalizedLanguage == null || key.language == normalizedLanguage);
    });
  }

  void clearCache() {
    _activityCache.clear();
    _activityLoadFutures.clear();
    _detailCache.clear();
    _detailLoadFutures.clear();
    _comicSceneListCache.clear();
    _comicSceneListLoadFutures.clear();
  }

  Future<List<EcoUnitySdgModule>> loadModules({
    String language = 'en',
    bool publishedOnly = false,
    Map<String, dynamic>? additionalParams,
  }) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'fields': moduleFields.join(','),
      'sort': 'sdg_number',
      'language': language,
      if (publishedOnly) 'content_status': 'published',
      ...?additionalParams,
    };

    final dynamic rawData = await _backend.getDataList(
      sdgModuleObjectType,
      params,
    );

    return _asMapList(rawData)
        .map(
          (Map<String, dynamic> item) =>
              EcoUnitySdgModule.fromJson(item, language: language),
        )
        .toList()
      ..sort((EcoUnitySdgModule a, EcoUnitySdgModule b) {
        return (a.sdgNumber ?? 0).compareTo(b.sdgNumber ?? 0);
      });
  }

  Future<EcoUnitySdgModule?> loadModule(
    int moduleId, {
    String language = 'en',
  }) async {
    final dynamic rawData = await _backend.getDetails(
      sdgModuleObjectType,
      moduleId,
    );
    final Map<String, dynamic>? data = _asMap(rawData);
    if (data == null) {
      return null;
    }
    final Map<String, dynamic> hydrated = await _hydrateModuleActivities(
      data,
      language: language,
    );
    return EcoUnitySdgModule.fromJson(hydrated, language: language);
  }

  Future<List<EcoUnityLearningActivity>> loadActivities({
    String language = 'en',
    int? moduleId,
    int? sdgNumber,
    EcoUnityActivityType? type,
    bool publishedOnly = false,
    Map<String, dynamic>? additionalParams,
  }) async {
    final List<Map<String, dynamic>> activityMaps = await _loadActivityMaps(
      language: language,
      moduleId: moduleId,
      sdgNumber: sdgNumber,
      type: type,
      publishedOnly: publishedOnly,
      additionalParams: additionalParams,
    );

    return activityMaps
        .map(
          (Map<String, dynamic> item) =>
              EcoUnityLearningActivity.fromJson(item, language: language),
        )
        .toList()
      ..sort((EcoUnityLearningActivity a, EcoUnityLearningActivity b) {
        return a.orderNo.compareTo(b.orderNo);
      });
  }

  Future<EcoUnityLearningActivity?> loadActivity(
    int activityId, {
    String language = 'en',
    int? comicSceneLimit,
    bool reload = false,
  }) async {
    final String normalizedLanguage = _normalizeLanguage(language);
    if (reload) {
      clearActivityCache(activityId, language: normalizedLanguage);
    } else {
      final EcoUnityLearningActivity? cached = cachedActivity(
        activityId,
        language: normalizedLanguage,
        comicSceneLimit: comicSceneLimit,
      );
      if (cached != null) {
        return cached;
      }
      final EcoUnityLearningActivity? persisted =
          await _cachedActivityFromStorage(
            activityId,
            language: normalizedLanguage,
            comicSceneLimit: comicSceneLimit,
          );
      if (persisted != null) {
        return persisted;
      }
    }

    final _ActivityCacheKey cacheKey = _ActivityCacheKey(
      activityId,
      normalizedLanguage,
      comicSceneLimit,
    );
    if (!reload) {
      final Future<EcoUnityLearningActivity?>? pending =
          _activityLoadFutures[cacheKey];
      if (pending != null) {
        return pending;
      }
    }

    final Future<EcoUnityLearningActivity?> future =
        _loadActivityFromBackend(
          activityId,
          language: normalizedLanguage,
          comicSceneLimit: comicSceneLimit,
          reload: reload,
        ).whenComplete(() {
          _activityLoadFutures.remove(cacheKey);
        });
    _activityLoadFutures[cacheKey] = future;
    return future;
  }

  Future<EcoUnityLearningActivity?> _loadActivityFromBackend(
    int activityId, {
    required String language,
    int? comicSceneLimit,
    required bool reload,
  }) async {
    final dynamic rawData = await _backend.getDetails(
      activityObjectType,
      activityId,
    );
    final Map<String, dynamic>? data = _asMap(rawData);
    if (data == null) {
      return null;
    }
    final Map<String, dynamic> hydrated = await _hydrateActivityDetails(
      data,
      language: language,
      comicSceneLimit: comicSceneLimit,
      reload: reload,
    );
    final EcoUnityLearningActivity activity = EcoUnityLearningActivity.fromJson(
      hydrated,
      language: language,
    );
    _activityCache[_ActivityCacheKey(activityId, language, comicSceneLimit)] =
        activity;
    await _writePersistentMap(
      _activityCacheStorageKey(
        _ActivityCacheKey(activityId, language, comicSceneLimit),
      ),
      hydrated,
    );
    if (comicSceneLimit == null) {
      _activityCache[_ActivityCacheKey(activityId, language, null)] = activity;
      await _writePersistentMap(
        _activityCacheStorageKey(_ActivityCacheKey(activityId, language, null)),
        hydrated,
      );
    }
    return activity;
  }

  Future<List<EcoUnityProgressEntry>> loadProgress({
    String? language,
    int? moduleId,
    int? activityId,
    Map<String, dynamic>? additionalParams,
  }) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'fields': progressFields.join(','),
      'sort': 'started_at',
      'language': ?language,
      'module': ?moduleId,
      'activity': ?activityId,
      ...?additionalParams,
    };

    final dynamic rawData = await _backend.getDataList(
      progressObjectType,
      params,
    );

    return _asMapList(rawData).map(EcoUnityProgressEntry.fromJson).toList();
  }

  Future<EcoUnityProgressEntry?> saveProgress({
    int? progressId,
    required int moduleId,
    required int activityId,
    required EcoUnityProgressStatus status,
    String language = 'en',
    String source = 'app',
    Map<String, dynamic> payload = const <String, dynamic>{},
  }) async {
    final Map<String, dynamic> objectData = <String, dynamic>{
      'module': moduleId,
      'activity': activityId,
      'language': language,
      'status': _progressStatusToWire(status),
      'source': source,
      'payload_json': jsonEncode(payload),
      if (status == EcoUnityProgressStatus.completed ||
          status == EcoUnityProgressStatus.submitted)
        'completed_at': DateTime.now().toUtc().toIso8601String(),
    };

    final dynamic rawData = await _backend.saveObject(
      progressId,
      progressObjectType,
      objectData,
    );
    final Map<String, dynamic>? data = _asMap(rawData);
    if (data == null) {
      return null;
    }
    return EcoUnityProgressEntry.fromJson(data);
  }

  Future<EcoUnitySdgModule?> updateModuleContentStatus(
    int moduleId,
    EcoUnityContentStatus status, {
    String language = 'en',
  }) async {
    await _backend.saveObject(moduleId, sdgModuleObjectType, <String, dynamic>{
      'content_status': _contentStatusToWire(status),
    });
    return loadModule(moduleId, language: language);
  }

  Future<EcoUnityLearningActivity?> updateActivityContentStatus(
    int activityId,
    EcoUnityContentStatus status, {
    String language = 'en',
  }) async {
    await _backend.saveObject(activityId, activityObjectType, <String, dynamic>{
      'content_status': _contentStatusToWire(status),
    });
    return loadActivity(activityId, language: language, reload: true);
  }

  Future<List<Map<String, dynamic>>> _loadActivityMaps({
    required String language,
    int? moduleId,
    int? sdgNumber,
    EcoUnityActivityType? type,
    bool publishedOnly = false,
    Map<String, dynamic>? additionalParams,
  }) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'fields': activityFields.join(','),
      'sort': 'orderno',
      'language': language,
      'module': ?moduleId,
      'sdg_number': ?sdgNumber,
      'activity_type': ?_activityTypeToWire(type),
      if (publishedOnly) 'content_status': 'published',
      ...?additionalParams,
    };

    final dynamic rawData = await _backend.getDataList(
      activityObjectType,
      params,
    );

    return _asMapList(rawData);
  }

  Future<Map<String, dynamic>> _hydrateModuleActivities(
    Map<String, dynamic> moduleData, {
    required String language,
  }) async {
    final Map<String, dynamic> hydrated = Map<String, dynamic>.from(moduleData);
    final List<int> relationIds = _relationIds(hydrated['activities']);
    if (relationIds.isEmpty) {
      return hydrated;
    }

    List<Map<String, dynamic>> activityMaps = <Map<String, dynamic>>[];
    final int? sdgNumber = _readIntValue(hydrated['sdg_number']);
    if (sdgNumber != null) {
      activityMaps = await _loadActivityMaps(
        language: language,
        sdgNumber: sdgNumber,
      );
      activityMaps = activityMaps.where((Map<String, dynamic> activity) {
        final int? activityId = _relationId(activity);
        return activityId != null && relationIds.contains(activityId);
      }).toList();
    }

    if (activityMaps.isEmpty) {
      activityMaps = await _hydrateRelationList(
        hydrated['activities'],
        activityObjectType,
      );
    }

    hydrated['activities'] = activityMaps;
    return hydrated;
  }

  Future<Map<String, dynamic>> _hydrateActivityDetails(
    Map<String, dynamic> activityData, {
    required String language,
    int? comicSceneLimit,
    bool reload = false,
  }) async {
    final Map<String, dynamic> hydrated = Map<String, dynamic>.from(
      activityData,
    );

    final List<int> questionIds = _relationIds(hydrated['questions']);
    if (questionIds.isNotEmpty) {
      hydrated['questions'] = await _hydrateRelationList(
        hydrated['questions'],
        questionObjectType,
        reload: reload,
      );
    }

    if (_readStringValue(hydrated['activity_type']) == 'comic') {
      hydrated['comic_scenes'] = await _hydrateComicScenes(
        hydrated,
        language: language,
        limit: comicSceneLimit,
        reload: reload,
      );
    }

    return hydrated;
  }

  Future<List<Map<String, dynamic>>> _hydrateComicScenes(
    Map<String, dynamic> activityData, {
    required String language,
    int? limit,
    bool reload = false,
  }) async {
    final int? activityId = _relationId(activityData);
    final List<int> relationIds = _relationIds(activityData['comic_scenes']);
    List<Map<String, dynamic>> sceneMaps = <Map<String, dynamic>>[];

    if (activityId != null) {
      sceneMaps = await _loadComicSceneList(
        activityId,
        language: language,
        reload: reload,
      );
    }

    if (sceneMaps.isEmpty && relationIds.isNotEmpty) {
      sceneMaps = await _hydrateRelationList(
        activityData['comic_scenes'],
        comicSceneObjectType,
        reload: reload,
      );
    }

    sceneMaps.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
      return (_readIntValue(a['orderno']) ?? 0).compareTo(
        _readIntValue(b['orderno']) ?? 0,
      );
    });

    final Map<int, String> sceneKeyById = <int, String>{
      for (final Map<String, dynamic> scene in sceneMaps)
        if (_relationId(scene) != null)
          _relationId(scene)!: _readStringValue(scene['scene_key']),
    };

    final Iterable<Map<String, dynamic>> scenesToHydrate = limit == null
        ? sceneMaps
        : sceneMaps.take(limit);

    return Future.wait(
      scenesToHydrate.map((Map<String, dynamic> scene) {
        return _hydrateComicScene(
          scene,
          sceneKeyById: sceneKeyById,
          reload: reload,
        );
      }),
    );
  }

  Future<List<Map<String, dynamic>>> _loadComicSceneList(
    int activityId, {
    required String language,
    bool reload = false,
  }) async {
    final _ComicSceneListCacheKey cacheKey = _ComicSceneListCacheKey(
      activityId,
      _normalizeLanguage(language),
    );
    if (!reload) {
      final List<Map<String, dynamic>>? cached = _comicSceneListCache[cacheKey];
      if (cached != null) {
        return _cloneMapList(cached);
      }
      final List<Map<String, dynamic>>? persisted =
          await _readPersistentMapList(
            _comicSceneListCacheStorageKey(cacheKey),
          );
      if (persisted != null) {
        _comicSceneListCache[cacheKey] = _cloneMapList(persisted);
        return _cloneMapList(persisted);
      }
      final Future<List<Map<String, dynamic>>>? pending =
          _comicSceneListLoadFutures[cacheKey];
      if (pending != null) {
        return pending.then(_cloneMapList);
      }
    }

    final Future<List<Map<String, dynamic>>> future =
        _loadComicSceneListFromBackend(
          activityId,
          language: language,
          cacheKey: cacheKey,
        ).whenComplete(() {
          _comicSceneListLoadFutures.remove(cacheKey);
        });
    _comicSceneListLoadFutures[cacheKey] = future;
    return future;
  }

  Future<List<Map<String, dynamic>>> _loadComicSceneListFromBackend(
    int activityId, {
    required String language,
    required _ComicSceneListCacheKey cacheKey,
  }) async {
    final dynamic rawScenes = await _backend
        .getDataList(comicSceneObjectType, <String, dynamic>{
          'fields': comicSceneFields.join(','),
          'activity': activityId,
          'sort': 'orderno',
          'language': language,
          'limit': 100,
        });
    final List<Map<String, dynamic>> sceneMaps = _asMapList(rawScenes);
    _comicSceneListCache[cacheKey] = _cloneMapList(sceneMaps);
    await _writePersistentMapList(
      _comicSceneListCacheStorageKey(cacheKey),
      sceneMaps,
    );
    return _cloneMapList(sceneMaps);
  }

  Future<Map<String, dynamic>> _hydrateComicScene(
    Map<String, dynamic> scene, {
    required Map<int, String> sceneKeyById,
    bool reload = false,
  }) async {
    final Map<String, dynamic> hydrated = Map<String, dynamic>.from(scene);
    final List<List<Map<String, dynamic>>> hydratedRelations =
        await Future.wait(<Future<List<Map<String, dynamic>>>>[
          _hydrateRelationList(
            hydrated['backgrounds'],
            sceneBackgroundObjectType,
            keepStubsOnFailure: true,
            reload: reload,
          ),
          _hydrateCastLayers(hydrated['cast'], reload: reload),
          _hydrateRelationList(
            hydrated['props'],
            scenePropObjectType,
            keepStubsOnFailure: true,
            reload: reload,
          ),
          _hydrateDecisions(
            hydrated['decisions'],
            sceneKeyById: sceneKeyById,
            reload: reload,
          ),
        ]);

    hydrated['backgrounds'] = hydratedRelations[0];
    hydrated['cast'] = hydratedRelations[1];
    hydrated['props'] = hydratedRelations[2];
    hydrated['decisions'] = hydratedRelations[3];
    return hydrated;
  }

  Future<List<Map<String, dynamic>>> _hydrateCastLayers(
    dynamic rawCast, {
    bool reload = false,
  }) async {
    final List<Map<String, dynamic>> castLayers = await _hydrateRelationList(
      rawCast,
      sceneCastObjectType,
      keepStubsOnFailure: true,
      reload: reload,
    );

    return Future.wait(
      castLayers.map((Map<String, dynamic> castLayer) async {
        final Map<String, dynamic> hydrated = Map<String, dynamic>.from(
          castLayer,
        );
        hydrated['dialogue_entries'] = await _hydrateDialogueEntries(
          hydrated['dialogue_entries'],
          reload: reload,
        );
        return hydrated;
      }),
    );
  }

  Future<List<Map<String, dynamic>>> _hydrateDialogueEntries(
    dynamic rawDialogueEntries, {
    bool reload = false,
  }) async {
    final List<Map<String, dynamic>> dialogueEntries =
        await _hydrateRelationList(
          rawDialogueEntries,
          sceneDialogueObjectType,
          keepStubsOnFailure: true,
          reload: reload,
        );

    return Future.wait(
      dialogueEntries.map((Map<String, dynamic> dialogueEntry) async {
        final Map<String, dynamic> hydrated = Map<String, dynamic>.from(
          dialogueEntry,
        );
        hydrated['speech_items'] = await _hydrateRelationList(
          hydrated['speech_items'],
          sceneSpeechObjectType,
          keepStubsOnFailure: true,
          reload: reload,
        );
        return hydrated;
      }),
    );
  }

  Future<List<Map<String, dynamic>>> _hydrateDecisions(
    dynamic rawDecisions, {
    required Map<int, String> sceneKeyById,
    bool reload = false,
  }) async {
    final List<Map<String, dynamic>> decisions = await _hydrateRelationList(
      rawDecisions,
      comicDecisionObjectType,
      keepStubsOnFailure: true,
      reload: reload,
    );

    return decisions.map((Map<String, dynamic> decision) {
      final Map<String, dynamic> hydrated = Map<String, dynamic>.from(decision);
      if (_readStringValue(hydrated['target_scene_key']).isEmpty) {
        final int? targetSceneId = _relationId(hydrated['target_scene']);
        final String? targetSceneKey = sceneKeyById[targetSceneId];
        if (targetSceneKey != null && targetSceneKey.isNotEmpty) {
          hydrated['target_scene_key'] = targetSceneKey;
        }
      }
      return hydrated;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _hydrateRelationList(
    dynamic rawRelations,
    String objectType, {
    bool keepStubsOnFailure = false,
    bool reload = false,
  }) async {
    final List<Map<String, dynamic>> stubs = _asMapList(rawRelations);
    final List<Map<String, dynamic>?> items = await Future.wait(
      stubs.map((Map<String, dynamic> stub) async {
        final int? objectId = _relationId(stub);
        if (objectId == null) {
          return stub;
        }
        final Map<String, dynamic>? detail = await _loadDetailMap(
          objectType,
          objectId,
          reload: reload,
        );
        if (detail != null) {
          return detail;
        }
        return keepStubsOnFailure ? stub : null;
      }),
    );
    return items.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>?> _loadDetailMap(
    String objectType,
    int objectId, {
    bool reload = false,
  }) async {
    final _DetailCacheKey cacheKey = _DetailCacheKey(objectType, objectId);
    if (!reload) {
      final Map<String, dynamic>? cached = _detailCache[cacheKey];
      if (cached != null) {
        return Map<String, dynamic>.from(cached);
      }
      final Map<String, dynamic>? persisted = await _readPersistentMap(
        _detailCacheStorageKey(cacheKey),
      );
      if (persisted != null) {
        _detailCache[cacheKey] = Map<String, dynamic>.from(persisted);
        return Map<String, dynamic>.from(persisted);
      }
      final Future<Map<String, dynamic>?>? pending =
          _detailLoadFutures[cacheKey];
      if (pending != null) {
        return pending.then(
          (Map<String, dynamic>? data) =>
              data == null ? null : Map<String, dynamic>.from(data),
        );
      }
    }

    final Future<Map<String, dynamic>?> future =
        _loadDetailMapFromBackend(objectType, objectId, cacheKey).whenComplete(
          () {
            _detailLoadFutures.remove(cacheKey);
          },
        );
    _detailLoadFutures[cacheKey] = future;
    return future;
  }

  Future<Map<String, dynamic>?> _loadDetailMapFromBackend(
    String objectType,
    int objectId,
    _DetailCacheKey cacheKey,
  ) async {
    try {
      final Map<String, dynamic>? data = _asMap(
        await _backend.getDetails(objectType, objectId),
      );
      if (data != null) {
        _detailCache[cacheKey] = Map<String, dynamic>.from(data);
        await _writePersistentMap(_detailCacheStorageKey(cacheKey), data);
      }
      return data == null ? null : Map<String, dynamic>.from(data);
    } catch (_) {
      return null;
    }
  }

  Future<EcoUnityLearningActivity?> _cachedActivityFromStorage(
    int activityId, {
    required String language,
    int? comicSceneLimit,
  }) async {
    final List<_ActivityCacheKey> cacheKeys = <_ActivityCacheKey>[
      _ActivityCacheKey(activityId, language, null),
      if (comicSceneLimit != null)
        _ActivityCacheKey(activityId, language, comicSceneLimit),
    ];

    for (final _ActivityCacheKey cacheKey in cacheKeys) {
      final Map<String, dynamic>? data = await _readPersistentMap(
        _activityCacheStorageKey(cacheKey),
      );
      if (data == null) {
        continue;
      }
      final EcoUnityLearningActivity activity =
          EcoUnityLearningActivity.fromJson(data, language: language);
      _activityCache[cacheKey] = activity;
      return activity;
    }

    return null;
  }

  Future<Map<String, dynamic>?> _readPersistentMap(String key) async {
    if (!_usePersistentCache) {
      return null;
    }
    try {
      return _asMap(
        await _fileStorage.getObject(key, boxName: learningCacheBoxName),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> _readPersistentMapList(String key) async {
    if (!_usePersistentCache) {
      return null;
    }
    try {
      final dynamic stored = await _fileStorage.getObject(
        key,
        boxName: learningCacheBoxName,
      );
      if (stored == null) {
        return null;
      }
      return _asMapList(stored);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writePersistentMap(
    String key,
    Map<String, dynamic> data,
  ) async {
    if (!_usePersistentCache) {
      return;
    }
    try {
      await _fileStorage.setObject(
        key,
        Map<String, dynamic>.from(data),
        boxName: learningCacheBoxName,
      );
    } catch (_) {
      // Cache writes are opportunistic; backend data remains the source of truth.
    }
  }

  Future<void> _writePersistentMapList(
    String key,
    List<Map<String, dynamic>> data,
  ) async {
    if (!_usePersistentCache) {
      return;
    }
    try {
      await _fileStorage.setObject(
        key,
        _cloneMapList(data),
        boxName: learningCacheBoxName,
      );
    } catch (_) {
      // Cache writes are opportunistic; backend data remains the source of truth.
    }
  }
}

List<Map<String, dynamic>> _asMapList(dynamic rawData) {
  if (rawData == null) {
    return <Map<String, dynamic>>[];
  }
  if (rawData is core.ApiResponse) {
    return _asMapList(rawData.data ?? rawData.rawData);
  }
  if (rawData is Map && rawData['data'] is Iterable) {
    return _asMapList(rawData['data']);
  }
  if (rawData is Iterable) {
    return rawData.map(_asMap).whereType<Map<String, dynamic>>().toList();
  }
  final Map<String, dynamic>? single = _asMap(rawData);
  return single == null
      ? <Map<String, dynamic>>[]
      : <Map<String, dynamic>>[single];
}

Map<String, dynamic>? _asMap(dynamic rawData) {
  if (rawData == null) {
    return null;
  }
  if (rawData is core.ApiResponse) {
    return _asMap(rawData.data ?? rawData.rawData);
  }
  if (rawData is Map) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);
    final String status = _readStringValue(data['status']);
    if (status == 'error') {
      return null;
    }
    if (status == 'fail' && data['data'] == null) {
      return null;
    }
    if (data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    return data;
  }
  return null;
}

List<int> _relationIds(dynamic rawData) {
  return _asMapList(rawData).map(_relationId).whereType<int>().toList();
}

int? _relationId(dynamic rawData) {
  if (rawData is core.ApiResponse) {
    return _relationId(rawData.data ?? rawData.rawData);
  }
  if (rawData is Iterable) {
    for (final dynamic item in rawData) {
      final int? id = _relationId(item);
      if (id != null) {
        return id;
      }
    }
    return null;
  }
  if (rawData is Map) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);
    if (data['data'] is Map) {
      return _relationId(data['data']);
    }
    return _readIntValue(
      data['id'] ?? data['objectid'] ?? data['value'] ?? data['objectId'],
    );
  }
  return _readIntValue(rawData);
}

int? _readIntValue(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}

String _readStringValue(dynamic value) {
  if (value == null) {
    return '';
  }
  if (value is String) {
    return value;
  }
  if (value is num || value is bool) {
    return value.toString();
  }
  if (value is Map) {
    return _readStringValue(
      value['value'] ?? value['name'] ?? value['title'] ?? value['text'],
    );
  }
  return '';
}

String _normalizeLanguage(String language) {
  final String normalized = language.trim().toLowerCase();
  return normalized.isEmpty ? 'en' : normalized;
}

List<Map<String, dynamic>> _cloneMapList(List<Map<String, dynamic>> value) {
  return value
      .map((Map<String, dynamic> item) => Map<String, dynamic>.from(item))
      .toList();
}

String _activityCacheStorageKey(_ActivityCacheKey key) {
  return 'activity:${key.activityId}:${key.language}:'
      '${key.comicSceneLimit ?? 'full'}';
}

String _detailCacheStorageKey(_DetailCacheKey key) {
  return 'detail:${key.objectType}:${key.objectId}';
}

String _comicSceneListCacheStorageKey(_ComicSceneListCacheKey key) {
  return 'comic-scenes:${key.activityId}:${key.language}';
}

class _ActivityCacheKey {
  const _ActivityCacheKey(this.activityId, this.language, this.comicSceneLimit);

  final int activityId;
  final String language;
  final int? comicSceneLimit;

  @override
  bool operator ==(Object other) {
    return other is _ActivityCacheKey &&
        other.activityId == activityId &&
        other.language == language &&
        other.comicSceneLimit == comicSceneLimit;
  }

  @override
  int get hashCode => Object.hash(activityId, language, comicSceneLimit);
}

class _DetailCacheKey {
  const _DetailCacheKey(this.objectType, this.objectId);

  final String objectType;
  final int objectId;

  @override
  bool operator ==(Object other) {
    return other is _DetailCacheKey &&
        other.objectType == objectType &&
        other.objectId == objectId;
  }

  @override
  int get hashCode => Object.hash(objectType, objectId);
}

class _ComicSceneListCacheKey {
  const _ComicSceneListCacheKey(this.activityId, this.language);

  final int activityId;
  final String language;

  @override
  bool operator ==(Object other) {
    return other is _ComicSceneListCacheKey &&
        other.activityId == activityId &&
        other.language == language;
  }

  @override
  int get hashCode => Object.hash(activityId, language);
}

String? _activityTypeToWire(EcoUnityActivityType? type) {
  return switch (type) {
    null => null,
    EcoUnityActivityType.comic => 'comic',
    EcoUnityActivityType.mlr => 'mlr',
    EcoUnityActivityType.quiz => 'quiz',
    EcoUnityActivityType.reflection => 'reflection',
    EcoUnityActivityType.challenge => 'challenge',
    EcoUnityActivityType.unknown => null,
  };
}

String _progressStatusToWire(EcoUnityProgressStatus status) {
  return switch (status) {
    EcoUnityProgressStatus.opened => 'opened',
    EcoUnityProgressStatus.completed => 'completed',
    EcoUnityProgressStatus.submitted => 'submitted',
    EcoUnityProgressStatus.reset => 'reset',
  };
}

String _contentStatusToWire(EcoUnityContentStatus status) {
  return switch (status) {
    EcoUnityContentStatus.draft => 'draft',
    EcoUnityContentStatus.review => 'review',
    EcoUnityContentStatus.approved => 'approved',
    EcoUnityContentStatus.published => 'published',
    EcoUnityContentStatus.archived => 'archived',
    EcoUnityContentStatus.unknown => 'review',
  };
}
