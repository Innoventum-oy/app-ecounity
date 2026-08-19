import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:core/core.dart' as core;
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

typedef EcoUnityAnalyticsConfigLoader =
    Future<EcoUnityAnalyticsConfig> Function();
typedef EcoUnityAnalyticsIdGenerator = String Function();
typedef EcoUnityAnalyticsClock = DateTime Function();

class EcoUnityAnalyticsConfig {
  const EcoUnityAnalyticsConfig({
    required this.enabled,
    required this.token,
    this.disabledReason,
    this.serverName,
    this.pilotKey,
    this.pilotParticipantCode,
    this.country,
    this.language,
    this.platform,
    this.appVersion,
  });

  final bool enabled;
  final String token;
  final String? disabledReason;
  final String? serverName;
  final String? pilotKey;
  final String? pilotParticipantCode;
  final String? country;
  final String? language;
  final String? platform;
  final String? appVersion;

  static Future<EcoUnityAnalyticsConfig> load() async {
    const String tokenFromEnv = String.fromEnvironment(
      'ECOUNITY_ANALYTICS_TOKEN',
    );
    const String pilotKeyFromEnv = String.fromEnvironment(
      'ECOUNITY_ANALYTICS_PILOT_KEY',
    );
    const String participantCodeFromEnv = String.fromEnvironment(
      'ECOUNITY_ANALYTICS_PARTICIPANT_CODE',
    );
    const String countryFromEnv = String.fromEnvironment(
      'ECOUNITY_ANALYTICS_COUNTRY',
    );

    final core.AppSettings appSettings = core.AppSettings();
    final core.Settings settings = core.Settings();
    final String serverName = await settings.getServerName();
    final Map<String, dynamic> analyticsMap =
        await appSettings.getMap('analytics') ?? const <String, dynamic>{};
    final String token = resolveIngestionToken(
      tokenFromEnvironment: tokenFromEnv,
      analyticsMap: analyticsMap,
      serverName: serverName,
      rootAnalyticsIngestionToken: await appSettings.get(
        'analyticsIngestionToken',
      ),
    );
    final String? language = await settings.getLanguage();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion =
        '${packageInfo.version}+${packageInfo.buildNumber}';

    final bool enabledByConfig = _readEnabledFlag(analyticsMap['enabled']);
    final bool enabled = token.isNotEmpty && enabledByConfig;

    return EcoUnityAnalyticsConfig(
      enabled: enabled,
      token: token,
      disabledReason: _disabledReason(
        token: token,
        enabledByConfig: enabledByConfig,
        serverName: serverName,
      ),
      serverName: serverName,
      pilotKey: _nullableFirstNonEmptyString(<Object?>[
        pilotKeyFromEnv,
        analyticsMap['pilotKey'],
        analyticsMap['pilot_key'],
      ]),
      pilotParticipantCode: _nullableFirstNonEmptyString(<Object?>[
        participantCodeFromEnv,
        analyticsMap['pilotParticipantCode'],
        analyticsMap['pilot_participant_code'],
        analyticsMap['participant_code'],
      ]),
      country: _nullableFirstNonEmptyString(<Object?>[
        countryFromEnv,
        analyticsMap['country'],
      ]),
      language: language,
      platform: _currentPlatform(),
      appVersion: appVersion,
    );
  }

  EcoUnityAnalyticsConfig copyWith({String? language}) {
    return EcoUnityAnalyticsConfig(
      enabled: enabled,
      token: token,
      disabledReason: disabledReason,
      serverName: serverName,
      pilotKey: pilotKey,
      pilotParticipantCode: pilotParticipantCode,
      country: country,
      language: language ?? this.language,
      platform: platform,
      appVersion: appVersion,
    );
  }

  @visibleForTesting
  static String resolveIngestionToken({
    required String tokenFromEnvironment,
    required Map<String, dynamic> analyticsMap,
    required String serverName,
    Object? rootAnalyticsIngestionToken,
  }) {
    return _firstNonEmptyString(<Object?>[
      tokenFromEnvironment,
      _serverSectionToken(analyticsMap[serverName]),
      _environmentToken(analyticsMap['ingestionToken'], serverName),
      _environmentToken(analyticsMap['analyticsIngestionToken'], serverName),
      _environmentToken(rootAnalyticsIngestionToken, serverName),
    ]);
  }

  static String? _disabledReason({
    required String token,
    required bool enabledByConfig,
    required String serverName,
  }) {
    if (!enabledByConfig) {
      return 'disabled by analytics.enabled=false';
    }
    if (token.isEmpty) {
      if (serverName.isNotEmpty) {
        return 'missing analytics ingestion token for server environment "$serverName"';
      }
      return 'missing analytics ingestion token';
    }
    return null;
  }
}

abstract class EcoUnityAnalyticsStore {
  Future<Object?> getObject(String key);

  Future<void> setObject(String key, Object? value);

  Future<void> deleteObject(String key);
}

class EcoUnityFileAnalyticsStore implements EcoUnityAnalyticsStore {
  EcoUnityFileAnalyticsStore({
    core.FileStorage? fileStorage,
    this.boxName = 'ecounityAnalytics',
  }) : _fileStorage = fileStorage ?? core.FileStorage();

  final core.FileStorage _fileStorage;
  final String boxName;

  @override
  Future<Object?> getObject(String key) {
    return _fileStorage.getObject(key, boxName: boxName);
  }

  @override
  Future<void> setObject(String key, Object? value) {
    return _fileStorage.setObject(key, value, boxName: boxName);
  }

  @override
  Future<void> deleteObject(String key) {
    return _fileStorage.deleteObject(key, boxName: boxName);
  }
}

abstract class EcoUnityAnalyticsTransport {
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> payload,
    String token,
  );
}

class EcoUnityHttpAnalyticsTransport implements EcoUnityAnalyticsTransport {
  EcoUnityHttpAnalyticsTransport({
    http.Client? httpClient,
    core.Settings? settings,
  }) : _httpClient = httpClient ?? http.Client(),
       _settings = settings ?? core.Settings();

  final http.Client _httpClient;
  final core.Settings _settings;

  @override
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> payload,
    String token,
  ) async {
    final Uri uri = _analyticsUri(await _settings.getServer(), path);
    final http.Response response = await _httpClient.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-EcoUnity-Analytics-Token': token,
      },
      body: jsonEncode(payload),
    );
    final Map<String, dynamic> decoded = _decodeResponseBody(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    throw EcoUnityAnalyticsHttpException(response.statusCode, decoded);
  }
}

class EcoUnityAnalyticsHttpException implements Exception {
  const EcoUnityAnalyticsHttpException(this.statusCode, this.payload);

  final int statusCode;
  final Map<String, dynamic> payload;

  @override
  String toString() => 'EcoUnityAnalyticsHttpException($statusCode)';
}

class EcoUnityAnalyticsService {
  EcoUnityAnalyticsService({
    EcoUnityAnalyticsConfigLoader? configLoader,
    EcoUnityAnalyticsTransport? transport,
    EcoUnityAnalyticsStore? store,
    EcoUnityAnalyticsIdGenerator? idGenerator,
    EcoUnityAnalyticsClock? clock,
    this.batchSize = 25,
  }) : _configLoader = configLoader ?? EcoUnityAnalyticsConfig.load,
       _transport = transport ?? EcoUnityHttpAnalyticsTransport(),
       _store = store ?? EcoUnityFileAnalyticsStore(),
       _idGenerator = idGenerator ?? _uuidV4,
       _clock = clock ?? DateTime.now;

  static const String _identityKey = 'analytics_user_id';
  static const String _queueKey = 'event_queue';

  final EcoUnityAnalyticsConfigLoader _configLoader;
  final EcoUnityAnalyticsTransport _transport;
  final EcoUnityAnalyticsStore _store;
  final EcoUnityAnalyticsIdGenerator _idGenerator;
  final EcoUnityAnalyticsClock _clock;
  final int batchSize;

  EcoUnityAnalyticsConfig? _config;
  Future<EcoUnityAnalyticsConfig>? _configFuture;
  String? _analyticsUserId;
  String? _sessionId;
  DateTime? _sessionStartedAt;
  bool _startingSession = false;
  bool _flushing = false;
  bool _queueLocked = false;
  bool _pausedForUnauthorized = false;
  bool _loggedDisabledConfig = false;
  bool _loggedUnauthorized = false;
  bool _loggedTransportFailure = false;
  int _serverStateGeneration = 0;

  Future<bool> get isEnabled async => (await _ensureConfig()).enabled;

  Future<void> handleServerChanged({String? language}) async {
    _clearServerBoundState();
    await _store.deleteObject(_queueKey);
    await startSession(language: language);
  }

  Future<void> startSession({String? language}) async {
    final int generation = _serverStateGeneration;
    final EcoUnityAnalyticsConfig config = (await _ensureConfig()).copyWith(
      language: language,
    );
    if (generation != _serverStateGeneration) {
      await startSession(language: language);
      return;
    }
    if (!config.enabled) {
      _logDisabledConfig(config);
      return;
    }
    if (_startingSession || _sessionId != null) {
      return;
    }

    _startingSession = true;
    try {
      final String analyticsUserId = await _ensureAnalyticsUserId();
      final String sessionId = _idGenerator();
      final DateTime startedAt = _clock().toUtc();
      if (generation != _serverStateGeneration) {
        return;
      }
      _sessionId = sessionId;
      _sessionStartedAt = startedAt;

      await _postLifecycle(
        '/api/ecounitylearning/analytics/identity',
        <String, dynamic>{
          'analytics_user_id': analyticsUserId,
          'seen_at': startedAt.toIso8601String(),
          ..._contextPayload(config),
        },
        config,
      );
      if (generation != _serverStateGeneration) {
        return;
      }
      await _postLifecycle(
        '/api/ecounitylearning/analytics/session/start',
        <String, dynamic>{
          'analytics_user_id': analyticsUserId,
          'session_id': sessionId,
          'started_at': startedAt.toIso8601String(),
          ..._contextPayload(config),
        },
        config,
      );
      if (generation == _serverStateGeneration) {
        await flush();
      }
    } finally {
      if (generation == _serverStateGeneration) {
        _startingSession = false;
      }
    }
  }

  Future<void> endSession({String? language}) async {
    final String? sessionId = _sessionId;
    if (sessionId == null) {
      return;
    }
    final EcoUnityAnalyticsConfig config = (await _ensureConfig()).copyWith(
      language: language,
    );
    if (!config.enabled) {
      _logDisabledConfig(config);
      _sessionId = null;
      _sessionStartedAt = null;
      return;
    }

    final DateTime endedAt = _clock().toUtc();
    final DateTime? startedAt = _sessionStartedAt;
    final int? durationSeconds = startedAt == null
        ? null
        : endedAt.difference(startedAt).inSeconds.clamp(0, 86400).toInt();

    final Map<String, dynamic> payload = <String, dynamic>{
      'analytics_user_id': await _ensureAnalyticsUserId(),
      'session_id': sessionId,
      'ended_at': endedAt.toIso8601String(),
      ..._contextPayload(config),
    };
    if (durationSeconds != null) {
      payload['duration_seconds'] = durationSeconds;
    }

    await _postLifecycle(
      '/api/ecounitylearning/analytics/session/end',
      payload,
      config,
    );
    _sessionId = null;
    _sessionStartedAt = null;
    await flush();
  }

  Future<void> trackModuleOpened(EcoUnitySdgModule module, {String? language}) {
    return trackEvent(
      eventType: 'module_opened',
      language: language,
      sdgNumber: module.sdgNumber,
      moduleId: module.id,
      eventData: <String, Object?>{
        if (module.slug.isNotEmpty) 'module_key': module.slug,
      },
    );
  }

  Future<void> trackModuleCompleted(
    EcoUnitySdgModule module, {
    String? language,
  }) {
    return trackEvent(
      eventType: 'module_completed',
      language: language,
      sdgNumber: module.sdgNumber,
      moduleId: module.id,
    );
  }

  Future<void> trackActivityStarted(
    EcoUnityLearningActivity activity, {
    String? language,
  }) async {
    await trackEvent(
      eventType: 'activity_started',
      language: language,
      sdgNumber: activity.sdgNumber,
      moduleId: activity.moduleId,
      activityId: activity.id,
      activityType: _activityTypeToWire(activity.type),
      eventData: <String, Object?>{
        if (activity.slug.isNotEmpty) 'activity_key': activity.slug,
      },
    );

    if (activity.isComic) {
      await trackComicStarted(activity, language: language);
    }
  }

  Future<void> trackActivityCompleted(
    EcoUnityLearningActivity activity, {
    String? language,
    Map<String, Object?> eventData = const <String, Object?>{},
  }) async {
    await trackEvent(
      eventType: 'activity_completed',
      language: language,
      sdgNumber: activity.sdgNumber,
      moduleId: activity.moduleId,
      activityId: activity.id,
      activityType: _activityTypeToWire(activity.type),
      eventData: <String, Object?>{
        if (activity.slug.isNotEmpty) 'activity_key': activity.slug,
        ...eventData,
      },
    );

    if (activity.isComic) {
      await trackComicCompleted(
        activity,
        language: language,
        eventData: eventData,
      );
    }
  }

  Future<void> trackQuizCompleted(
    EcoUnityLearningActivity activity,
    EcoUnityQuizResult result, {
    required int attemptNumber,
    String? language,
  }) {
    return trackEvent(
      eventType: 'quiz_completed',
      language: language,
      sdgNumber: activity.sdgNumber,
      moduleId: activity.moduleId,
      activityId: activity.id,
      activityType: 'quiz',
      eventData: <String, Object?>{
        'score': result.score,
        'max_score': result.possibleScore,
        'correct_count': result.correctQuestionCount,
        'question_count': result.questionCount,
        'passed': result.passed,
        'attempt_number': attemptNumber,
      },
    );
  }

  Future<void> trackComicStarted(
    EcoUnityLearningActivity activity, {
    String? language,
  }) {
    return trackEvent(
      eventType: 'comic_started',
      language: language,
      sdgNumber: activity.sdgNumber,
      moduleId: activity.moduleId,
      activityId: activity.id,
      comicId: activity.id,
      activityType: 'comic',
      eventData: <String, Object?>{
        if (activity.slug.isNotEmpty) 'activity_key': activity.slug,
      },
    );
  }

  Future<void> trackComicSceneViewed(
    EcoUnityLearningActivity activity,
    EcoUnityComicScene scene, {
    String? language,
  }) {
    return trackEvent(
      eventType: 'comic_scene_viewed',
      language: language,
      sdgNumber: activity.sdgNumber,
      moduleId: activity.moduleId,
      activityId: activity.id,
      comicId: activity.id,
      sceneId: scene.id,
      activityType: 'comic',
      eventData: <String, Object?>{
        if (scene.sceneKey.isNotEmpty) 'scene_key': scene.sceneKey,
      },
    );
  }

  Future<void> trackComicDecisionSelected(
    EcoUnityLearningActivity activity,
    EcoUnityComicScene scene,
    EcoUnityComicDecision decision, {
    String? language,
  }) {
    return trackEvent(
      eventType: 'comic_decision_selected',
      language: language,
      sdgNumber: activity.sdgNumber,
      moduleId: activity.moduleId,
      activityId: activity.id,
      comicId: activity.id,
      sceneId: scene.id,
      decisionId: decision.id,
      activityType: 'comic',
      eventData: <String, Object?>{
        if (decision.targetSceneKey.isNotEmpty)
          'branch_key': decision.targetSceneKey,
        if (decision.label.isNotEmpty) 'decision_label': decision.label,
      },
    );
  }

  Future<void> trackComicCompleted(
    EcoUnityLearningActivity activity, {
    String? language,
    Map<String, Object?> eventData = const <String, Object?>{},
  }) {
    return trackEvent(
      eventType: 'comic_completed',
      language: language,
      sdgNumber: activity.sdgNumber,
      moduleId: activity.moduleId,
      activityId: activity.id,
      comicId: activity.id,
      activityType: 'comic',
      eventData: eventData,
    );
  }

  Future<void> trackLanguageChanged({
    required String previousLanguage,
    required String newLanguage,
  }) {
    if (previousLanguage == newLanguage) {
      return Future<void>.value();
    }
    return trackEvent(
      eventType: 'language_changed',
      language: newLanguage,
      eventData: <String, Object?>{
        'previous_language': previousLanguage,
        'new_language': newLanguage,
      },
    );
  }

  Future<void> trackEvent({
    required String eventType,
    String? language,
    int? sdgNumber,
    int? moduleId,
    int? activityId,
    int? questionId,
    int? comicId,
    int? sceneId,
    int? decisionId,
    int? badgeId,
    String? activityType,
    Map<String, Object?> eventData = const <String, Object?>{},
  }) async {
    final EcoUnityAnalyticsConfig config = (await _ensureConfig()).copyWith(
      language: language,
    );
    if (!config.enabled) {
      _logDisabledConfig(config);
      return;
    }

    await startSession(language: config.language);
    if (_pausedForUnauthorized) {
      return;
    }
    final String? sessionId = _sessionId;
    final Map<String, dynamic> payload = <String, dynamic>{
      'event_id': _idGenerator(),
      'analytics_user_id': await _ensureAnalyticsUserId(),
      'event_type': eventType,
      'event_time': _clock().toUtc().toIso8601String(),
      ..._contextPayload(config),
    };
    if (sessionId != null) {
      payload['session_id'] = sessionId;
    }
    if (sdgNumber != null) {
      payload['sdg_number'] = sdgNumber;
    }
    if (moduleId != null) {
      payload['module_id'] = moduleId;
    }
    if (activityId != null) {
      payload['activity_id'] = activityId;
    }
    if (questionId != null) {
      payload['question_id'] = questionId;
    }
    if (comicId != null) {
      payload['comic_id'] = comicId;
    }
    if (sceneId != null) {
      payload['scene_id'] = sceneId;
    }
    if (decisionId != null) {
      payload['decision_id'] = decisionId;
    }
    if (badgeId != null) {
      payload['badge_id'] = badgeId;
    }
    if (activityType != null && activityType.isNotEmpty) {
      payload['activity_type'] = activityType;
    }
    final Map<String, dynamic> safeEventData = _safeEventData(eventData);
    if (safeEventData.isNotEmpty) {
      payload['event_data'] = safeEventData;
    }

    await _appendToQueue(payload);
    await flush();
  }

  Future<void> flush() async {
    if (_flushing || _pausedForUnauthorized) {
      return;
    }
    final EcoUnityAnalyticsConfig config = await _ensureConfig();
    if (!config.enabled) {
      _logDisabledConfig(config);
      return;
    }

    _flushing = true;
    try {
      final List<Map<String, dynamic>> queue = await _readQueue();
      if (queue.isEmpty) {
        return;
      }
      final List<Map<String, dynamic>> batch = queue.take(batchSize).toList();
      try {
        final Map<String, dynamic> response = await _transport.postJson(
          '/api/ecounitylearning/analytics/events/batch',
          <String, dynamic>{..._contextPayload(config), 'events': batch},
          config.token,
        );
        await _removeCompletedBatchEvents(batch, response);
      } on EcoUnityAnalyticsHttpException catch (exception) {
        await _handleBatchHttpFailure(batch, exception);
      } catch (error) {
        _logTransportFailure('events/batch', error);
        // Network or platform failures keep queued events for a later retry.
      }
    } finally {
      _flushing = false;
    }
  }

  Future<EcoUnityAnalyticsConfig> _ensureConfig() async {
    final EcoUnityAnalyticsConfig? config = _config;
    if (config != null) {
      final String? loadedServerName = config.serverName;
      if (!_hasText(loadedServerName)) {
        return config;
      }
      final String serverName = await core.Settings().getServerName();
      if (serverName == loadedServerName) {
        return config;
      }
      _clearServerBoundState();
      await _store.deleteObject(_queueKey);
      return _loadConfig();
    }
    return _loadConfig();
  }

  void _clearServerBoundState() {
    _serverStateGeneration += 1;
    _sessionId = null;
    _sessionStartedAt = null;
    _startingSession = false;
    _pausedForUnauthorized = false;
    _loggedDisabledConfig = false;
    _loggedUnauthorized = false;
    _loggedTransportFailure = false;
    _config = null;
    _configFuture = null;
  }

  Future<EcoUnityAnalyticsConfig> _loadConfig() {
    final Future<EcoUnityAnalyticsConfig>? current = _configFuture;
    if (current != null) {
      return current;
    }

    final int generation = _serverStateGeneration;
    late final Future<EcoUnityAnalyticsConfig> future;
    future = _configLoader()
        .then((EcoUnityAnalyticsConfig loaded) {
          if (generation == _serverStateGeneration) {
            _config = loaded;
          }
          return loaded;
        })
        .whenComplete(() {
          if (identical(_configFuture, future)) {
            _configFuture = null;
          }
        });
    _configFuture = future;
    return future;
  }

  Future<String> _ensureAnalyticsUserId() async {
    final String? cached = _analyticsUserId;
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    final Object? stored = await _store.getObject(_identityKey);
    final String? storedId = stored?.toString().trim();
    if (storedId != null && storedId.isNotEmpty && storedId != 'null') {
      _analyticsUserId = storedId;
      return storedId;
    }
    final String generated = _idGenerator();
    _analyticsUserId = generated;
    await _store.setObject(_identityKey, generated);
    return generated;
  }

  Future<void> _postLifecycle(
    String path,
    Map<String, dynamic> payload,
    EcoUnityAnalyticsConfig config,
  ) async {
    if (_pausedForUnauthorized) {
      return;
    }
    try {
      await _transport.postJson(path, payload, config.token);
    } on EcoUnityAnalyticsHttpException catch (exception) {
      if (exception.statusCode == 401) {
        _pausedForUnauthorized = true;
        _logUnauthorized(path);
      } else {
        _logTransportFailure(path, exception);
      }
    } catch (error) {
      _logTransportFailure(path, error);
      // Lifecycle calls are best effort. User events are retained in the queue.
    }
  }

  Future<void> _appendToQueue(Map<String, dynamic> event) async {
    await _withQueueLock(() async {
      final List<Map<String, dynamic>> queue = await _readQueueUnlocked();
      queue.add(event);
      await _writeQueueUnlocked(queue);
    });
  }

  Future<List<Map<String, dynamic>>> _readQueue() {
    return _withQueueLock(_readQueueUnlocked);
  }

  Future<List<Map<String, dynamic>>> _readQueueUnlocked() async {
    final Object? stored = await _store.getObject(_queueKey);
    if (stored is Iterable) {
      return stored
          .whereType<Map>()
          .map((Map item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  Future<void> _writeQueueUnlocked(List<Map<String, dynamic>> queue) {
    if (queue.isEmpty) {
      return _store.deleteObject(_queueKey);
    }
    return _store.setObject(_queueKey, queue);
  }

  Future<void> _removeCompletedBatchEvents(
    List<Map<String, dynamic>> batch,
    Map<String, dynamic> response,
  ) async {
    final Set<String> completedEventIds = <String>{};
    final Object? results = response['results'];
    if (results is Iterable) {
      for (final Object? result in results) {
        if (result is! Map) {
          continue;
        }
        final String status = '${result['status'] ?? ''}'.toLowerCase();
        if (status == 'accepted' ||
            status == 'duplicate' ||
            status == 'rejected') {
          final String eventId = '${result['event_id'] ?? ''}';
          if (eventId.isNotEmpty) {
            completedEventIds.add(eventId);
          }
        }
      }
    }

    if (completedEventIds.isEmpty) {
      final int accepted = _readInt(response['accepted']) ?? 0;
      final int duplicates = _readInt(response['duplicates']) ?? 0;
      final int rejected = _readInt(response['rejected']) ?? 0;
      if (accepted + duplicates + rejected >= batch.length) {
        completedEventIds.addAll(
          batch.map((Map<String, dynamic> event) => '${event['event_id']}'),
        );
      }
    }

    if (completedEventIds.isEmpty) {
      return;
    }

    await _withQueueLock(() async {
      final List<Map<String, dynamic>> queue = await _readQueueUnlocked();
      queue.removeWhere(
        (Map<String, dynamic> event) =>
            completedEventIds.contains('${event['event_id']}'),
      );
      await _writeQueueUnlocked(queue);
    });
  }

  Future<void> _handleBatchHttpFailure(
    List<Map<String, dynamic>> batch,
    EcoUnityAnalyticsHttpException exception,
  ) async {
    if (exception.statusCode == 401) {
      _pausedForUnauthorized = true;
      _logUnauthorized('events/batch');
      return;
    }
    _logTransportFailure('events/batch', exception);
    if (exception.statusCode == 400) {
      final Set<String> failedEventIds = batch
          .map((Map<String, dynamic> event) => '${event['event_id']}')
          .toSet();
      await _withQueueLock(() async {
        final List<Map<String, dynamic>> queue = await _readQueueUnlocked();
        queue.removeWhere(
          (Map<String, dynamic> event) =>
              failedEventIds.contains('${event['event_id']}'),
        );
        await _writeQueueUnlocked(queue);
      });
    }
  }

  void _logDisabledConfig(EcoUnityAnalyticsConfig config) {
    if (_loggedDisabledConfig || kReleaseMode) {
      return;
    }
    _loggedDisabledConfig = true;
    debugPrint(
      'EcoUnity analytics disabled: '
      '${config.disabledReason ?? 'configuration disabled analytics'}. '
      'For local preview, provide --dart-define=ECOUNITY_ANALYTICS_TOKEN=... '
      'or assets/config/keys.yaml analytics.ingestionToken.',
    );
  }

  void _logUnauthorized(String path) {
    if (_loggedUnauthorized || kReleaseMode) {
      return;
    }
    _loggedUnauthorized = true;
    debugPrint(
      'EcoUnity analytics paused: backend returned 401 for $path. '
      'Check the configured analytics ingestion token.',
    );
  }

  void _logTransportFailure(String path, Object error) {
    if (_loggedTransportFailure || kReleaseMode) {
      return;
    }
    _loggedTransportFailure = true;
    debugPrint('EcoUnity analytics request failed for $path: $error');
  }

  Future<T> _withQueueLock<T>(Future<T> Function() action) async {
    while (_queueLocked) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    _queueLocked = true;
    try {
      return await action();
    } finally {
      _queueLocked = false;
    }
  }
}

Map<String, dynamic> _contextPayload(EcoUnityAnalyticsConfig config) {
  return <String, dynamic>{
    if (_hasText(config.pilotKey)) 'pilot_key': config.pilotKey,
    if (_hasText(config.pilotParticipantCode))
      'pilot_participant_code': config.pilotParticipantCode,
    if (_hasText(config.country)) 'country': config.country,
    if (_hasText(config.language)) 'language': config.language,
    if (_hasText(config.platform)) 'platform': config.platform,
    if (_hasText(config.appVersion)) 'app_version': config.appVersion,
  };
}

Map<String, dynamic> _safeEventData(Map<String, Object?> eventData) {
  final Map<String, dynamic> safe = <String, dynamic>{};
  for (final MapEntry<String, Object?> entry in eventData.entries) {
    if (!_allowedEventDataKeys.contains(entry.key)) {
      continue;
    }
    final Object? value = entry.value;
    if (value == null) {
      continue;
    }
    if (value is num || value is bool) {
      safe[entry.key] = value;
      continue;
    }
    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        safe[entry.key] = trimmed.length > 256
            ? trimmed.substring(0, 256)
            : trimmed;
      }
    }
  }
  return safe;
}

const Set<String> _allowedEventDataKeys = <String>{
  'score',
  'max_score',
  'maximum_score',
  'correct_count',
  'question_count',
  'passed',
  'badge_type',
  'badge_slug',
  'branch_key',
  'decision_label',
  'activity_key',
  'module_key',
  'scene_key',
  'duration_seconds',
  'attempt_number',
  'error_code',
  'screen',
  'previous_language',
  'new_language',
};

String? _activityTypeToWire(EcoUnityActivityType type) {
  return switch (type) {
    EcoUnityActivityType.comic => 'comic',
    EcoUnityActivityType.mlr => 'mlr',
    EcoUnityActivityType.quiz => 'quiz',
    EcoUnityActivityType.reflection => 'reflection',
    EcoUnityActivityType.challenge => 'challenge',
    EcoUnityActivityType.unknown => null,
  };
}

Uri _analyticsUri(String rawBase, String path) {
  final String trimmedBase = rawBase.trim();
  final Uri base = trimmedBase.contains('://')
      ? Uri.parse(trimmedBase)
      : Uri(scheme: 'https', host: trimmedBase);
  final String cleanPath = path.startsWith('/') ? path.substring(1) : path;
  final String basePath = base.path.endsWith('/')
      ? base.path.substring(0, base.path.length - 1)
      : base.path;
  return base.replace(
    path: basePath.isEmpty ? cleanPath : '$basePath/$cleanPath',
  );
}

Map<String, dynamic> _decodeResponseBody(String body) {
  if (body.trim().isEmpty) {
    return <String, dynamic>{};
  }
  final Object? decoded = jsonDecode(body);
  if (decoded is Map) {
    return Map<String, dynamic>.from(decoded);
  }
  return <String, dynamic>{'data': decoded};
}

bool _readEnabledFlag(Object? value) {
  if (value == null) {
    return true;
  }
  if (value is bool) {
    return value;
  }
  final String text = value.toString().trim().toLowerCase();
  return text != 'false' && text != '0' && text != 'no' && text != 'off';
}

String _firstNonEmptyString(Iterable<Object?> values) {
  return _nullableFirstNonEmptyString(values) ?? '';
}

String? _serverSectionToken(Object? value) {
  if (value is! Map) {
    return null;
  }
  return _nullableFirstNonEmptyString(<Object?>[
    value['ingestionToken'],
    value['analyticsIngestionToken'],
  ]);
}

String? _environmentToken(Object? value, String serverName) {
  if (value is Map) {
    return _nullableFirstNonEmptyString(<Object?>[
      _serverSectionToken(value[serverName]),
      value[serverName],
      _serverSectionToken(value['default']),
      value['default'],
    ]);
  }
  return _nullableFirstNonEmptyString(<Object?>[value]);
}

String? _nullableFirstNonEmptyString(Iterable<Object?> values) {
  for (final Object? value in values) {
    final String text = value?.toString().trim() ?? '';
    if (text.isNotEmpty && text != 'null') {
      return text;
    }
  }
  return null;
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

String _currentPlatform() {
  if (kIsWeb) {
    return 'web';
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    _ => 'unknown',
  };
}

String _uuidV4() {
  final math.Random random = math.Random.secure();
  final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final String hex = bytes
      .map((int byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-'
      '${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}
