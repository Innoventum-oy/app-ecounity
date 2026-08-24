import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart' as core;
import 'package:http/http.dart' as http;

import '../util/ecounity_media_cache.dart';
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

abstract class EcoUnityComicPackageClient {
  Future<Map<String, dynamic>?> loadJson(
    String urlOrPath, {
    String language = 'en',
  });

  Future<String> resolveUrl(String urlOrPath);
}

class EcoUnityHttpComicPackageClient implements EcoUnityComicPackageClient {
  EcoUnityHttpComicPackageClient({
    http.Client? httpClient,
    core.Settings? settings,
  }) : _httpClient = httpClient ?? http.Client(),
       _settings = settings ?? core.Settings();

  final http.Client _httpClient;
  final core.Settings _settings;

  @override
  Future<Map<String, dynamic>?> loadJson(
    String urlOrPath, {
    String language = 'en',
  }) async {
    final String trimmed = urlOrPath.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    try {
      final http.Response response = await _httpClient.get(
        await _uriFor(trimmed),
        headers: <String, String>{
          'Accept': 'application/json',
          if (language.trim().isNotEmpty)
            'Accept-Language': language.trim().toLowerCase(),
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return _asMap(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> resolveUrl(String urlOrPath) async {
    final String trimmed = urlOrPath.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return (await _uriFor(trimmed)).toString();
  }

  Future<Uri> _uriFor(String urlOrPath) async {
    final Uri parsed = Uri.parse(urlOrPath);
    if (parsed.hasScheme) {
      return parsed;
    }

    String baseUrl = (await _settings.getServer()).trim();
    if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {
      baseUrl = 'https://$baseUrl';
    }
    Uri base = Uri.parse(baseUrl);
    if (!base.path.endsWith('/')) {
      base = base.replace(path: '${base.path}/');
    }
    return base.resolveUri(parsed);
  }
}

typedef EcoUnityComicAssetPreparer =
    Future<void> Function({
      required Iterable<String> imageUrls,
      required Iterable<String> audioUrls,
    });

Future<void> _defaultComicAssetPreparer({
  required Iterable<String> imageUrls,
  required Iterable<String> audioUrls,
}) async {
  final EcoUnityMediaCache mediaCache = EcoUnityMediaCache();
  await Future.wait(<Future<void>>[
    mediaCache.prepareImageUrls(imageUrls),
    mediaCache.prepareAudioUrls(audioUrls),
  ]);
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
    EcoUnityComicPackageClient? comicPackageClient,
    EcoUnityComicAssetPreparer? comicAssetPreparer,
    core.FileStorage? fileStorage,
    bool? usePersistentCache,
  }) : _backend = backend ?? EcoUnityCoreLearningBackend(),
       _comicPackageClient =
           comicPackageClient ??
           (backend == null ? EcoUnityHttpComicPackageClient() : null),
       _comicAssetPreparer = comicAssetPreparer ?? _defaultComicAssetPreparer,
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
    'comic_package_base_url',
    'comic_package_manifest_url',
    'comic_package_status',
    'comic_package_version',
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
  final EcoUnityComicPackageClient? _comicPackageClient;
  final EcoUnityComicAssetPreparer _comicAssetPreparer;
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
  final Map<_ProgressCacheKey, EcoUnityProgressEntry> _localProgressCache =
      <_ProgressCacheKey, EcoUnityProgressEntry>{};
  bool _localProgressLoaded = false;

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

  Future<void> warmComicActivityCache(
    Iterable<EcoUnitySdgModule> modules, {
    String language = 'en',
    int concurrency = 1,
  }) async {
    final String normalizedLanguage = _normalizeLanguage(language);
    final List<int> activityIds = await _comicActivityIdsForWarmup(
      modules,
      language: normalizedLanguage,
    );
    if (activityIds.isEmpty) {
      return;
    }

    final int workerCount = concurrency < 1
        ? 1
        : concurrency > activityIds.length
        ? activityIds.length
        : concurrency;
    int nextIndex = 0;
    int failures = 0;

    Future<void> worker() async {
      while (true) {
        final int index = nextIndex;
        if (index >= activityIds.length) {
          return;
        }
        nextIndex += 1;
        final int activityId = activityIds[index];

        await Future<void>.delayed(Duration.zero);
        try {
          await loadActivity(activityId, language: normalizedLanguage);
        } catch (_) {
          failures += 1;
          // Cache warming is opportunistic. Opening the activity can still
          // fetch from the backend if this background request fails.
        }
      }
    }

    await Future.wait(
      List<Future<void>>.generate(workerCount, (_) => worker()),
    );
    if (failures > 0) {
      throw StateError(
        'Failed to warm $failures of ${activityIds.length} comic activities.',
      );
    }
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
    if (_activityDataIsComic(data)) {
      final Map<String, dynamic>? packaged = await _loadPackagedComicActivity(
        data,
        activityId: activityId,
        language: language,
      );
      if (packaged != null) {
        final EcoUnityLearningActivity activity =
            EcoUnityLearningActivity.fromJson(packaged, language: language);
        _activityCache[_ActivityCacheKey(
              activityId,
              language,
              comicSceneLimit,
            )] =
            activity;
        await _writePersistentMap(
          _activityCacheStorageKey(
            _ActivityCacheKey(activityId, language, comicSceneLimit),
          ),
          packaged,
        );
        _activityCache[_ActivityCacheKey(activityId, language, null)] =
            activity;
        await _writePersistentMap(
          _activityCacheStorageKey(
            _ActivityCacheKey(activityId, language, null),
          ),
          packaged,
        );
        return activity;
      }
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

  Future<List<EcoUnityProgressEntry>> loadLocalProgress({
    String? language,
    int? moduleId,
    int? activityId,
  }) async {
    await _ensureLocalProgressLoaded();
    final String? normalizedLanguage = language == null
        ? null
        : _normalizeLanguage(language);

    final List<EcoUnityProgressEntry> entries =
        _localProgressCache.values.where((EcoUnityProgressEntry entry) {
          if (normalizedLanguage != null &&
              _normalizeLanguage(entry.language) != normalizedLanguage) {
            return false;
          }
          if (moduleId != null && entry.moduleId != moduleId) {
            return false;
          }
          if (activityId != null && entry.activityId != activityId) {
            return false;
          }
          return true;
        }).toList()..sort((EcoUnityProgressEntry a, EcoUnityProgressEntry b) {
          final DateTime aTime =
              a.completedAt ??
              a.startedAt ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final DateTime bTime =
              b.completedAt ??
              b.startedAt ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return aTime.compareTo(bTime);
        });
    return entries;
  }

  Future<EcoUnityProgressEntry?> saveLocalProgress({
    required int moduleId,
    required int activityId,
    required EcoUnityProgressStatus status,
    String language = 'en',
    String source = 'app',
    Map<String, dynamic> payload = const <String, dynamic>{},
  }) async {
    await _ensureLocalProgressLoaded();
    final String normalizedLanguage = _normalizeLanguage(language);
    final _ProgressCacheKey key = _ProgressCacheKey(
      activityId,
      normalizedLanguage,
    );
    final EcoUnityProgressEntry? existing = _localProgressCache[key];
    if (existing?.status == EcoUnityProgressStatus.completed &&
        status == EcoUnityProgressStatus.opened) {
      return existing;
    }

    final DateTime now = DateTime.now().toUtc();
    final DateTime? completedAt =
        status == EcoUnityProgressStatus.completed ||
            status == EcoUnityProgressStatus.submitted
        ? now
        : existing?.completedAt;
    final Map<String, dynamic> progressData = <String, dynamic>{
      'id': existing?.id ?? Object.hash(activityId, normalizedLanguage).abs(),
      'module': moduleId,
      'activity': activityId,
      'language': normalizedLanguage,
      'status': _progressStatusToWire(status),
      'source': source,
      'payload_json': jsonEncode(payload),
      'started_at': (existing?.startedAt ?? now).toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt.toIso8601String(),
    };

    final EcoUnityProgressEntry entry = EcoUnityProgressEntry.fromJson(
      progressData,
    );
    _localProgressCache[key] = entry;
    await _writeLocalProgress();
    return entry;
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

  Future<List<int>> _comicActivityIdsForWarmup(
    Iterable<EcoUnitySdgModule> modules, {
    required String language,
  }) async {
    final Set<int> seen = <int>{};
    final List<int> activityIds = <int>[];

    for (final EcoUnitySdgModule module in modules) {
      for (final EcoUnityLearningActivity activity in module.activities) {
        final int? activityId = activity.id;
        if (activityId != null && activity.isComic && seen.add(activityId)) {
          activityIds.add(activityId);
        }
      }
    }

    if (activityIds.isNotEmpty) {
      return activityIds;
    }

    try {
      final List<Map<String, dynamic>> activityMaps = await _loadActivityMaps(
        language: language,
        type: EcoUnityActivityType.comic,
        additionalParams: const <String, dynamic>{
          'fields': 'id,objectid,activity_type,orderno,title,module,sdg_number',
          'limit': 100,
        },
      );
      for (final Map<String, dynamic> activityMap in activityMaps) {
        final int? activityId = _relationId(activityMap);
        if (activityId != null && seen.add(activityId)) {
          activityIds.add(activityId);
        }
      }
    } catch (_) {
      return activityIds;
    }

    return activityIds;
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
        language: language,
      );
    }

    hydrated['activities'] = activityMaps;
    return hydrated;
  }

  Future<Map<String, dynamic>?> _loadPackagedComicActivity(
    Map<String, dynamic> activityData, {
    required int activityId,
    required String language,
  }) async {
    final EcoUnityComicPackageClient? packageClient = _comicPackageClient;
    if (packageClient == null) {
      return null;
    }

    final List<String> manifestCandidates = _comicPackageManifestCandidates(
      activityData,
      activityId,
    );
    final String normalizedLanguage = _normalizeLanguage(language);
    for (final String manifestUrl in manifestCandidates) {
      final Map<String, dynamic>? manifest = await packageClient.loadJson(
        manifestUrl,
        language: normalizedLanguage,
      );
      if (!_isComicPackageManifest(manifest)) {
        continue;
      }

      final _ComicPackageLanguage? packageLanguage =
          _selectComicPackageLanguage(
            manifest!,
            requestedLanguage: normalizedLanguage,
          );
      if (packageLanguage == null) {
        continue;
      }

      final String? packageUrl = _comicPackageUrlFromManifest(
        packageLanguage.url,
        manifestUrl: manifestUrl,
        activityData: activityData,
        language: packageLanguage.language,
      );
      if (packageUrl == null || packageUrl.trim().isEmpty) {
        continue;
      }

      final Map<String, dynamic>? packageData = await packageClient.loadJson(
        packageUrl,
        language: packageLanguage.language,
      );
      final Map<String, dynamic>? hydrated =
          await _activityDataFromComicPackage(
            activityData,
            packageData,
            language: packageLanguage.language,
            manifest: manifest,
            contentHash: packageLanguage.contentHash,
          );
      if (hydrated != null) {
        return hydrated;
      }
    }

    for (final String packageUrl in _comicPackageLanguageCandidates(
      activityData,
      activityId,
      normalizedLanguage,
    )) {
      final Map<String, dynamic>? packageData = await packageClient.loadJson(
        packageUrl,
        language: normalizedLanguage,
      );
      final Map<String, dynamic>? hydrated =
          await _activityDataFromComicPackage(
            activityData,
            packageData,
            language: normalizedLanguage,
          );
      if (hydrated != null) {
        return hydrated;
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> _activityDataFromComicPackage(
    Map<String, dynamic> activityData,
    Map<String, dynamic>? packageData, {
    required String language,
    Map<String, dynamic>? manifest,
    String? contentHash,
  }) async {
    if (!_isComicLanguagePackage(packageData)) {
      return null;
    }

    final Map<String, dynamic> resolvedPackage = await _resolveComicPackageUrls(
      packageData!,
    );
    final List<Map<String, dynamic>> scenes = _asMapList(
      resolvedPackage['scenes'],
    ).map(_normalizePackageComicScene).toList();
    if (scenes.isEmpty) {
      return null;
    }

    final Map<String, dynamic> hydrated = Map<String, dynamic>.from(
      activityData,
    );
    final Map<String, dynamic> packageActivity =
        _asMap(resolvedPackage['activity']) ?? const <String, dynamic>{};

    _copyFirstPresent(hydrated, packageActivity, const ['id'], 'id');
    _copyFirstPresent(hydrated, packageActivity, const ['slug'], 'slug');
    _copyFirstPresent(hydrated, packageActivity, const [
      'sdg_number',
      'sdgNumber',
    ], 'sdg_number');
    _copyFirstPresent(hydrated, packageActivity, const ['title'], 'title');
    _copyFirstPresent(hydrated, packageActivity, const [
      'short_description',
      'shortDescription',
    ], 'short_description');
    _copyFirstPresent(hydrated, packageActivity, const [
      'content_status',
      'contentStatus',
    ], 'content_status');
    _copyFirstPresent(hydrated, packageActivity, const [
      'hero_image_url',
      'heroImageUrl',
    ], 'hero_image_url');
    _copyFirstPresent(hydrated, packageActivity, const [
      'media_image_urls',
      'mediaImageUrls',
    ], 'media_image_urls');

    hydrated['activity_type'] = 'comic';
    hydrated['comic_scenes'] = scenes;
    hydrated['scenes'] = scenes;
    _copyFirstPresent(hydrated, resolvedPackage, const [
      'start_scene_key',
      'startSceneKey',
    ], 'start_scene_key');
    _copyFirstPresent(hydrated, resolvedPackage, const [
      'scene_index',
      'sceneIndex',
    ], 'scene_index');
    _copyFirstPresent(hydrated, resolvedPackage, const [
      'package_version',
      'packageVersion',
    ], 'comic_package_version');
    _copyFirstPresent(hydrated, resolvedPackage, const [
      'content_language',
      'contentLanguage',
    ], 'comic_package_language');
    if (contentHash != null && contentHash.trim().isNotEmpty) {
      hydrated['comic_package_content_hash'] = contentHash.trim();
    }
    if (manifest != null) {
      _copyFirstPresent(hydrated, manifest, const [
        'package_version',
        'packageVersion',
      ], 'comic_package_manifest_version');
    }
    hydrated['comic_package_assets'] = resolvedPackage['assets'];
    hydrated['comic_package_hydration_source'] = 'package';
    hydrated['comic_package_requested_language'] = _normalizeLanguage(language);

    _preparePackagedComicAssets(resolvedPackage);
    return hydrated;
  }

  Future<Map<String, dynamic>> _resolveComicPackageUrls(
    Map<String, dynamic> packageData,
  ) async {
    final dynamic resolved = await _resolveComicPackageValue(
      'package',
      packageData,
    );
    return Map<String, dynamic>.from(resolved as Map);
  }

  Future<dynamic> _resolveComicPackageValue(String key, dynamic value) async {
    final EcoUnityComicPackageClient? packageClient = _comicPackageClient;
    if (packageClient == null) {
      return value;
    }

    if (value is String && _isPackageUrlField(key)) {
      return packageClient.resolveUrl(value);
    }
    if (value is Iterable && _isPackageUrlListField(key)) {
      return Future.wait(
        value.map((dynamic item) async {
          if (item is String) {
            return packageClient.resolveUrl(item);
          }
          return _resolveComicPackageValue(key, item);
        }),
      );
    }
    if (value is Map) {
      final Map<String, dynamic> resolved = <String, dynamic>{};
      for (final MapEntry<dynamic, dynamic> entry in value.entries) {
        final String childKey = entry.key.toString();
        resolved[childKey] = await _resolveComicPackageValue(
          childKey,
          entry.value,
        );
      }
      return resolved;
    }
    if (value is Iterable) {
      return Future.wait(
        value.map((dynamic item) => _resolveComicPackageValue(key, item)),
      );
    }
    return value;
  }

  void _preparePackagedComicAssets(Map<String, dynamic> packageData) {
    final Iterable<String> imageUrls = _comicPackageAssetUrls(
      packageData,
      'images',
    );
    final Iterable<String> audioUrls = _comicPackageAssetUrls(
      packageData,
      'audio',
    );
    if (imageUrls.isEmpty && audioUrls.isEmpty) {
      return;
    }

    unawaited(
      _comicAssetPreparer(
        imageUrls: imageUrls,
        audioUrls: audioUrls,
      ).catchError((_) {}),
    );
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
        language: language,
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
        language: language,
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
          language: language,
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
    required String language,
    required Map<int, String> sceneKeyById,
    bool reload = false,
  }) async {
    final Map<String, dynamic> hydrated = Map<String, dynamic>.from(scene);
    final List<List<Map<String, dynamic>>> hydratedRelations =
        await Future.wait(<Future<List<Map<String, dynamic>>>>[
          _hydrateRelationList(
            hydrated['backgrounds'],
            sceneBackgroundObjectType,
            language: language,
            keepStubsOnFailure: true,
            reload: reload,
          ),
          _hydrateCastLayers(
            hydrated['cast'],
            language: language,
            reload: reload,
          ),
          _hydrateRelationList(
            hydrated['props'],
            scenePropObjectType,
            language: language,
            keepStubsOnFailure: true,
            reload: reload,
          ),
          _hydrateDecisions(
            hydrated['decisions'],
            language: language,
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
    required String language,
    bool reload = false,
  }) async {
    final List<Map<String, dynamic>> castLayers = await _hydrateRelationList(
      rawCast,
      sceneCastObjectType,
      language: language,
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
          language: language,
          reload: reload,
        );
        return hydrated;
      }),
    );
  }

  Future<List<Map<String, dynamic>>> _hydrateDialogueEntries(
    dynamic rawDialogueEntries, {
    required String language,
    bool reload = false,
  }) async {
    final List<Map<String, dynamic>> dialogueEntries =
        await _hydrateRelationList(
          rawDialogueEntries,
          sceneDialogueObjectType,
          language: language,
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
          language: language,
          keepStubsOnFailure: true,
          reload: reload,
        );
        return hydrated;
      }),
    );
  }

  Future<List<Map<String, dynamic>>> _hydrateDecisions(
    dynamic rawDecisions, {
    required String language,
    required Map<int, String> sceneKeyById,
    bool reload = false,
  }) async {
    final List<Map<String, dynamic>> decisions = await _hydrateRelationList(
      rawDecisions,
      comicDecisionObjectType,
      language: language,
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
    required String language,
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
          language: language,
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
    required String language,
    bool reload = false,
  }) async {
    final _DetailCacheKey cacheKey = _DetailCacheKey(
      objectType,
      objectId,
      _normalizeLanguage(language),
    );
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

  Future<void> _ensureLocalProgressLoaded() async {
    if (_localProgressLoaded) {
      return;
    }
    _localProgressLoaded = true;
    final List<Map<String, dynamic>>? stored = await _readPersistentMapList(
      _localProgressStorageKey,
    );
    if (stored == null) {
      return;
    }
    for (final Map<String, dynamic> item in stored) {
      final EcoUnityProgressEntry entry = EcoUnityProgressEntry.fromJson(item);
      final int? activityId = entry.activityId;
      if (activityId == null) {
        continue;
      }
      _localProgressCache[_ProgressCacheKey(
            activityId,
            _normalizeLanguage(entry.language),
          )] =
          entry;
    }
  }

  Future<void> _writeLocalProgress() async {
    if (!_usePersistentCache) {
      return;
    }
    await _writePersistentMapList(
      _localProgressStorageKey,
      _localProgressCache.values.map(_progressEntryToStorageMap).toList(),
    );
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

bool _activityDataIsComic(Map<String, dynamic> activityData) {
  return _readStringValue(
        activityData['activity_type'] ?? activityData['activityType'],
      ).trim().toLowerCase() ==
      'comic';
}

List<String> _comicPackageManifestCandidates(
  Map<String, dynamic> activityData,
  int activityId,
) {
  final List<String> candidates = <String>[];
  _addUniqueString(
    candidates,
    _readStringValue(
      activityData['comic_package_manifest_url'] ??
          activityData['comicPackageManifestUrl'],
    ),
  );
  final String baseUrl = _readStringValue(
    activityData['comic_package_base_url'] ??
        activityData['comicPackageBaseUrl'],
  );
  if (baseUrl.trim().isNotEmpty) {
    _addUniqueString(candidates, _joinPackagePath(baseUrl, 'manifest.json'));
  }
  _addUniqueString(
    candidates,
    '/ecounitylearning/comics/$activityId/manifest.json',
  );
  return candidates;
}

List<String> _comicPackageLanguageCandidates(
  Map<String, dynamic> activityData,
  int activityId,
  String language,
) {
  final String baseUrl = _readStringValue(
    activityData['comic_package_base_url'] ??
        activityData['comicPackageBaseUrl'],
  );
  final List<String> languages = _preferredPackageLanguages(language);
  final List<String> candidates = <String>[];
  for (final String preferredLanguage in languages) {
    if (baseUrl.trim().isNotEmpty) {
      _addUniqueString(
        candidates,
        _joinPackagePath(baseUrl, '$preferredLanguage.json'),
      );
    }
    _addUniqueString(
      candidates,
      '/ecounitylearning/comics/$activityId/$preferredLanguage.json',
    );
  }
  return candidates;
}

bool _isComicPackageManifest(Map<String, dynamic>? manifest) {
  if (manifest == null) {
    return false;
  }
  final String packageType = _readStringValue(
    manifest['packageType'] ?? manifest['package_type'],
  );
  return packageType == 'ecounity_comic_manifest' ||
      _asMapList(manifest['languages']).isNotEmpty;
}

bool _isComicLanguagePackage(Map<String, dynamic>? packageData) {
  if (packageData == null) {
    return false;
  }
  final String packageType = _readStringValue(
    packageData['packageType'] ?? packageData['package_type'],
  );
  return packageType == 'ecounity_comic' ||
      _asMapList(packageData['scenes']).isNotEmpty;
}

_ComicPackageLanguage? _selectComicPackageLanguage(
  Map<String, dynamic> manifest, {
  required String requestedLanguage,
}) {
  final List<Map<String, dynamic>> languages = _asMapList(
    manifest['languages'],
  );
  if (languages.isEmpty) {
    return null;
  }

  for (final String preferredLanguage in _preferredPackageLanguages(
    requestedLanguage,
  )) {
    for (final Map<String, dynamic> item in languages) {
      final String language = _normalizeLanguage(
        _readStringValue(item['language']),
      );
      if (language == preferredLanguage) {
        return _ComicPackageLanguage.fromJson(item, language: language);
      }
    }
  }

  return _ComicPackageLanguage.fromJson(
    languages.first,
    language: _normalizeLanguage(_readStringValue(languages.first['language'])),
  );
}

List<String> _preferredPackageLanguages(String language) {
  final String normalizedLanguage = _normalizeLanguage(language);
  return <String>[normalizedLanguage, if (normalizedLanguage != 'en') 'en'];
}

String? _comicPackageUrlFromManifest(
  String packageUrl, {
  required String manifestUrl,
  required Map<String, dynamic> activityData,
  required String language,
}) {
  final String trimmed = packageUrl.trim();
  if (trimmed.isEmpty) {
    final String baseUrl = _readStringValue(
      activityData['comic_package_base_url'] ??
          activityData['comicPackageBaseUrl'],
    );
    if (baseUrl.trim().isNotEmpty) {
      return _joinPackagePath(baseUrl, '$language.json');
    }
    final String manifestDirectory = _packageDirectoryPath(manifestUrl);
    return manifestDirectory.isEmpty
        ? null
        : _joinPackagePath(manifestDirectory, '$language.json');
  }
  final Uri parsed = Uri.parse(trimmed);
  if (parsed.hasScheme || trimmed.startsWith('/')) {
    return trimmed;
  }

  final String baseUrl = _readStringValue(
    activityData['comic_package_base_url'] ??
        activityData['comicPackageBaseUrl'],
  );
  if (baseUrl.trim().isNotEmpty) {
    return _joinPackagePath(baseUrl, trimmed);
  }
  return _joinPackagePath(_packageDirectoryPath(manifestUrl), trimmed);
}

String _packageDirectoryPath(String urlOrPath) {
  final String trimmed = urlOrPath.trim();
  final int slashIndex = trimmed.lastIndexOf('/');
  if (slashIndex < 0) {
    return '';
  }
  return trimmed.substring(0, slashIndex);
}

String _joinPackagePath(String base, String child) {
  final String trimmedBase = base.trim();
  final String trimmedChild = child.trim();
  if (trimmedBase.isEmpty) {
    return trimmedChild;
  }
  if (trimmedChild.isEmpty) {
    return trimmedBase;
  }
  final String cleanBase = trimmedBase.endsWith('/')
      ? trimmedBase.substring(0, trimmedBase.length - 1)
      : trimmedBase;
  final String cleanChild = trimmedChild.startsWith('/')
      ? trimmedChild.substring(1)
      : trimmedChild;
  return '$cleanBase/$cleanChild';
}

Map<String, dynamic> _normalizePackageComicScene(Map<String, dynamic> scene) {
  final Map<String, dynamic> normalized = Map<String, dynamic>.from(scene);
  _copyFirstPresent(normalized, normalized, const ['sceneKey'], 'scene_key');
  _copyFirstPresent(normalized, normalized, const ['orderNo'], 'orderno');
  _copyFirstPresent(normalized, normalized, const ['altText'], 'alt_text');
  _copyFirstPresent(normalized, normalized, const [
    'contentStatus',
  ], 'content_status');

  final List<Map<String, dynamic>> backgrounds = _asMapList(
    normalized['backgrounds'],
  ).map(_normalizePackageComicBackground).toList();
  if (backgrounds.isNotEmpty) {
    normalized['backgrounds'] = backgrounds;
  } else {
    final Map<String, dynamic>? viewportBackgrounds = _asMap(
      normalized['viewportBackgrounds'] ?? normalized['viewport_backgrounds'],
    );
    if (viewportBackgrounds != null && viewportBackgrounds.isNotEmpty) {
      normalized['backgrounds'] = <Map<String, dynamic>>[
        <String, dynamic>{
          'viewports': viewportBackgrounds.values
              .map(_asMap)
              .whereType<Map<String, dynamic>>()
              .map(_normalizePackageComicViewport)
              .toList(),
        },
      ];
    }
  }

  normalized['cast'] = _asMapList(
    normalized['cast'],
  ).map(_normalizePackageComicCastLayer).toList();
  normalized['props'] = _asMapList(
    normalized['props'],
  ).map(_normalizePackageComicPropLayer).toList();
  normalized['decisions'] = _asMapList(
    normalized['decisions'],
  ).map(_normalizePackageComicDecision).toList();
  return normalized;
}

Map<String, dynamic> _normalizePackageComicBackground(
  Map<String, dynamic> background,
) {
  final Map<String, dynamic> normalized = Map<String, dynamic>.from(background);
  _copyFirstPresent(normalized, normalized, const [
    'altText',
  ], 'background_alt_text');
  _copyFirstPresent(normalized, normalized, const [
    'contentStatus',
  ], 'content_status');
  _copyFirstPresent(normalized, normalized, const [
    'referenceImageUrl',
  ], 'reference_image_url');
  normalized['viewports'] = _asMapList(
    normalized['viewports'],
  ).map(_normalizePackageComicViewport).toList();
  return normalized;
}

Map<String, dynamic> _normalizePackageComicViewport(
  Map<String, dynamic> viewport,
) {
  final Map<String, dynamic> normalized = Map<String, dynamic>.from(viewport);
  _copyFirstPresent(normalized, normalized, const [
    'canvasWidth',
  ], 'canvas_width');
  _copyFirstPresent(normalized, normalized, const [
    'canvasHeight',
  ], 'canvas_height');
  _copyFirstPresent(normalized, normalized, const ['imageUrl'], 'image_url');
  _copyFirstPresent(normalized, normalized, const [
    'generationStatus',
  ], 'generation_status');
  _copyFirstPresent(normalized, normalized, const [
    'contentStatus',
  ], 'content_status');
  return normalized;
}

Map<String, dynamic> _normalizePackageComicCastLayer(
  Map<String, dynamic> layer,
) {
  final Map<String, dynamic> normalized = _normalizePackageComicLayer(layer);
  _copyFirstPresent(normalized, normalized, const ['poseLayer'], 'pose_layer');
  final Map<String, dynamic>? poseLayer = _asMap(normalized['pose_layer']);
  if (poseLayer != null) {
    final Map<String, dynamic> normalizedPoseLayer = Map<String, dynamic>.from(
      poseLayer,
    );
    _copyFirstPresent(normalizedPoseLayer, normalizedPoseLayer, const [
      'imageUrl',
    ], 'image_url');
    _copyFirstPresent(normalizedPoseLayer, normalizedPoseLayer, const [
      'generationStatus',
    ], 'generation_status');
    _copyFirstPresent(normalizedPoseLayer, normalizedPoseLayer, const [
      'altText',
    ], 'alt_text');
    normalized['pose_layer'] = normalizedPoseLayer;
  }

  normalized['dialogue_entries'] = _asMapList(
    normalized['dialogue_entries'] ?? normalized['dialogueEntries'],
  ).map(_normalizePackageComicDialogueEntry).toList();
  return normalized;
}

Map<String, dynamic> _normalizePackageComicPropLayer(
  Map<String, dynamic> layer,
) {
  final Map<String, dynamic> normalized = _normalizePackageComicLayer(layer);
  final Map<String, dynamic>? prop = _asMap(normalized['prop']);
  if (prop != null) {
    final Map<String, dynamic> normalizedProp = Map<String, dynamic>.from(prop);
    _copyFirstPresent(normalizedProp, normalizedProp, const [
      'imageUrl',
    ], 'image_url');
    _copyFirstPresent(normalizedProp, normalizedProp, const [
      'altText',
    ], 'alt_text');
    normalized['prop'] = normalizedProp;
  }
  return normalized;
}

Map<String, dynamic> _normalizePackageComicDecision(
  Map<String, dynamic> decision,
) {
  final Map<String, dynamic> normalized = _normalizePackageComicLayer(decision);
  _copyFirstPresent(normalized, normalized, const [
    'targetSceneKey',
  ], 'target_scene_key');
  _copyFirstPresent(normalized, normalized, const [
    'targetSceneId',
  ], 'target_scene_id');
  _copyFirstPresent(normalized, normalized, const [
    'consequenceSummary',
  ], 'consequence_summary');
  _copyFirstPresent(normalized, normalized, const [
    'choiceImageUrl',
  ], 'choice_image_url');
  return normalized;
}

Map<String, dynamic> _normalizePackageComicLayer(Map<String, dynamic> layer) {
  final Map<String, dynamic> normalized = Map<String, dynamic>.from(layer);
  _copyFirstPresent(normalized, normalized, const ['orderNo'], 'orderno');
  _copyFirstPresent(normalized, normalized, const ['zIndex'], 'z_index');
  _copyFirstPresent(normalized, normalized, const ['altText'], 'alt_text');
  _copyFirstPresent(normalized, normalized, const [
    'contentStatus',
  ], 'content_status');

  final Map<String, dynamic>? layout = _asMap(normalized['layout']);
  if (layout != null) {
    final Map<String, dynamic> sharedLayout = _sharedPackageLayout(layout);
    final Map<String, dynamic> portraitLayout = <String, dynamic>{
      ...sharedLayout,
      ...?_asMap(layout['portrait']),
    };
    final Map<String, dynamic> landscapeLayout = <String, dynamic>{
      ...sharedLayout,
      ...?_asMap(layout['landscape']),
    };
    if (portraitLayout.isNotEmpty &&
        !normalized.containsKey('portraitLayout') &&
        !normalized.containsKey('portrait_layout_json')) {
      normalized['portraitLayout'] = portraitLayout;
    }
    if (landscapeLayout.isNotEmpty &&
        !normalized.containsKey('landscapeLayout') &&
        !normalized.containsKey('landscape_layout_json')) {
      normalized['landscapeLayout'] = landscapeLayout;
    }
    if (!normalized.containsKey('z_index')) {
      final int? sharedZIndex = _readIntValue(
        sharedLayout['z_index'] ?? sharedLayout['zIndex'],
      );
      if (sharedZIndex != null) {
        normalized['z_index'] = sharedZIndex;
      }
    }
  }

  return normalized;
}

Map<String, dynamic> _sharedPackageLayout(Map<String, dynamic> layout) {
  final Map<String, dynamic> shared = <String, dynamic>{};
  for (final MapEntry<String, dynamic> entry in layout.entries) {
    if (entry.key == 'portrait' ||
        entry.key == 'landscape' ||
        entry.key == 'shared' ||
        entry.key == 'default' ||
        entry.key == 'fallback' ||
        entry.key == 'all') {
      continue;
    }
    shared[entry.key] = entry.value;
  }
  final Map<String, dynamic>? sharedLayout =
      _asMap(layout['shared']) ??
      _asMap(layout['default']) ??
      _asMap(layout['fallback']) ??
      _asMap(layout['all']);
  if (sharedLayout != null) {
    shared.addAll(sharedLayout);
  }
  return shared;
}

Map<String, dynamic> _normalizePackageComicDialogueEntry(
  Map<String, dynamic> dialogueEntry,
) {
  final Map<String, dynamic> normalized = Map<String, dynamic>.from(
    dialogueEntry,
  );
  _copyFirstPresent(normalized, normalized, const ['orderNo'], 'orderno');
  _copyFirstPresent(normalized, normalized, const [
    'speechFeeling',
  ], 'speech_feeling');
  normalized['speech_items'] = _asMapList(
    normalized['speech_items'] ?? normalized['speechItems'],
  ).map(_normalizePackageComicSpeechItem).toList();
  return normalized;
}

Map<String, dynamic> _normalizePackageComicSpeechItem(
  Map<String, dynamic> speechItem,
) {
  final Map<String, dynamic> normalized = Map<String, dynamic>.from(speechItem);
  _copyFirstPresent(normalized, normalized, const ['orderNo'], 'orderno');
  _copyFirstPresent(normalized, normalized, const [
    'dialogueEntryId',
  ], 'dialogue_id');
  _copyFirstPresent(normalized, normalized, const ['audioUrl'], 'audio_url');
  _copyFirstPresent(normalized, normalized, const [
    'audioFileUrl',
  ], 'audio_file_url');
  _copyFirstPresent(normalized, normalized, const [
    'generationStatus',
  ], 'generation_status');
  _copyFirstPresent(normalized, normalized, const ['startMs'], 'start_ms');
  _copyFirstPresent(normalized, normalized, const [
    'durationMs',
  ], 'duration_ms');
  _copyFirstPresent(normalized, normalized, const [
    'responseFormat',
  ], 'response_format');
  return normalized;
}

Iterable<String> _comicPackageAssetUrls(
  Map<String, dynamic> packageData,
  String assetGroup,
) {
  final Map<String, dynamic>? assets = _asMap(packageData['assets']);
  if (assets == null) {
    return const <String>[];
  }
  return _asMapList(assets[assetGroup])
      .map((Map<String, dynamic> asset) => _readStringValue(asset['url']))
      .where((String url) => url.trim().isNotEmpty)
      .toSet();
}

bool _isPackageUrlField(String key) {
  final String lowerKey = key.toLowerCase();
  return lowerKey == 'url' ||
      lowerKey.endsWith('url') ||
      lowerKey.endsWith('_url');
}

bool _isPackageUrlListField(String key) {
  final String lowerKey = key.toLowerCase();
  return lowerKey.endsWith('urls') || lowerKey.endsWith('_urls');
}

void _copyFirstPresent(
  Map<String, dynamic> target,
  Map<String, dynamic> source,
  List<String> sourceKeys,
  String targetKey,
) {
  for (final String sourceKey in sourceKeys) {
    if (source.containsKey(sourceKey) && source[sourceKey] != null) {
      target[targetKey] = source[sourceKey];
      return;
    }
  }
}

void _addUniqueString(List<String> values, String value) {
  final String trimmed = value.trim();
  if (trimmed.isNotEmpty && !values.contains(trimmed)) {
    values.add(trimmed);
  }
}

String _normalizeLanguage(String language) {
  final String normalized = language.trim().toLowerCase();
  return normalized.isEmpty ? 'en' : normalized;
}

class _ComicPackageLanguage {
  const _ComicPackageLanguage({
    required this.language,
    required this.url,
    required this.contentHash,
  });

  final String language;
  final String url;
  final String contentHash;

  factory _ComicPackageLanguage.fromJson(
    Map<String, dynamic> data, {
    required String language,
  }) {
    return _ComicPackageLanguage(
      language: language,
      url: _readStringValue(data['url']),
      contentHash: _readStringValue(
        data['contentHash'] ?? data['content_hash'],
      ),
    );
  }
}

List<Map<String, dynamic>> _cloneMapList(List<Map<String, dynamic>> value) {
  return value
      .map((Map<String, dynamic> item) => Map<String, dynamic>.from(item))
      .toList();
}

const String _learningContentCachePrefix = 'learning-content-v2';

String _activityCacheStorageKey(_ActivityCacheKey key) {
  return '$_learningContentCachePrefix:activity:${key.activityId}:${key.language}:'
      '${key.comicSceneLimit ?? 'full'}';
}

String _detailCacheStorageKey(_DetailCacheKey key) {
  return '$_learningContentCachePrefix:detail:${key.objectType}:'
      '${key.objectId}:${key.language}';
}

String _comicSceneListCacheStorageKey(_ComicSceneListCacheKey key) {
  return '$_learningContentCachePrefix:comic-scenes:'
      '${key.activityId}:${key.language}';
}

const String _localProgressStorageKey = 'local-progress';

Map<String, dynamic> _progressEntryToStorageMap(EcoUnityProgressEntry entry) {
  return <String, dynamic>{
    'id': entry.id,
    'module': entry.moduleId,
    'activity': entry.activityId,
    'language': entry.language,
    'status': _progressStatusToWire(entry.status),
    'source': entry.source,
    'payload_json': jsonEncode(entry.payload),
    if (entry.startedAt != null)
      'started_at': entry.startedAt!.toIso8601String(),
    if (entry.completedAt != null)
      'completed_at': entry.completedAt!.toIso8601String(),
  };
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
  const _DetailCacheKey(this.objectType, this.objectId, this.language);

  final String objectType;
  final int objectId;
  final String language;

  @override
  bool operator ==(Object other) {
    return other is _DetailCacheKey &&
        other.objectType == objectType &&
        other.objectId == objectId &&
        other.language == language;
  }

  @override
  int get hashCode => Object.hash(objectType, objectId, language);
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

class _ProgressCacheKey {
  const _ProgressCacheKey(this.activityId, this.language);

  final int activityId;
  final String language;

  @override
  bool operator ==(Object other) {
    return other is _ProgressCacheKey &&
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
