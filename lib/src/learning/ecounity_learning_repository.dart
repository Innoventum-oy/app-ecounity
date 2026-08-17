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
  EcoUnityLearningRepository({EcoUnityLearningBackend? backend})
    : _backend = backend ?? EcoUnityCoreLearningBackend();

  static const String sdgModuleObjectType = 'ecounitysdgmodule';
  static const String activityObjectType = 'ecounitylearningactivity';
  static const String progressObjectType = 'ecounitylearningprogress';

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

  final EcoUnityLearningBackend _backend;

  Future<List<EcoUnitySdgModule>> loadModules({
    String language = 'en',
    bool publishedOnly = true,
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
    return EcoUnitySdgModule.fromJson(data, language: language);
  }

  Future<List<EcoUnityLearningActivity>> loadActivities({
    String language = 'en',
    int? moduleId,
    int? sdgNumber,
    EcoUnityActivityType? type,
    bool publishedOnly = true,
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

    return _asMapList(rawData)
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
  }) async {
    final dynamic rawData = await _backend.getDetails(
      activityObjectType,
      activityId,
    );
    final Map<String, dynamic>? data = _asMap(rawData);
    if (data == null) {
      return null;
    }
    return EcoUnityLearningActivity.fromJson(data, language: language);
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
    if (data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    return data;
  }
  return null;
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
