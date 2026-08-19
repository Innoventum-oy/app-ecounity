import 'dart:async';

import 'package:ecounity/src/analytics/ecounity_analytics_service.dart';
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sends lifecycle requests and whitelisted event data', () async {
    final _MemoryAnalyticsStore store = _MemoryAnalyticsStore();
    final _RecordingAnalyticsTransport transport =
        _RecordingAnalyticsTransport();
    final EcoUnityAnalyticsService service = _analyticsService(
      store: store,
      transport: transport,
    );

    await service.trackActivityCompleted(
      _activity(type: EcoUnityActivityType.reflection),
      language: 'fi',
      eventData: <String, Object?>{
        'duration_seconds': 42,
        'score': 7,
        'max_score': 10,
        'reflection_text': 'Do not send learner text',
        'comment': 'Do not send comments',
      },
    );

    expect(
      transport.requests.map((_AnalyticsRequest request) => request.path),
      containsAllInOrder(<String>[
        '/api/ecounitylearning/analytics/identity',
        '/api/ecounitylearning/analytics/session/start',
        '/api/ecounitylearning/analytics/events/batch',
      ]),
    );

    final _AnalyticsRequest batch = transport.requests.last;
    final List<dynamic> events = batch.payload['events'] as List<dynamic>;
    final Map<String, dynamic> event = Map<String, dynamic>.from(
      events.single as Map,
    );
    final Map<String, dynamic> eventData = Map<String, dynamic>.from(
      event['event_data'] as Map,
    );

    expect(event['event_type'], 'activity_completed');
    expect(event['analytics_user_id'], store.values['analytics_user_id']);
    expect(event['session_id'], isNotNull);
    expect(event['language'], 'fi');
    expect(event['sdg_number'], 5);
    expect(event['module_id'], 42);
    expect(event['activity_id'], 108);
    expect(event['activity_type'], 'reflection');
    expect(eventData['activity_key'], 'sdg-5-reflection');
    expect(eventData['duration_seconds'], 42);
    expect(eventData['score'], 7);
    expect(eventData['max_score'], 10);
    expect(eventData.containsKey('reflection_text'), isFalse);
    expect(eventData.containsKey('comment'), isFalse);
    expect(store.values.containsKey('event_queue'), isFalse);
  });

  test('keeps failed batches queued and retries with same event id', () async {
    final _MemoryAnalyticsStore store = _MemoryAnalyticsStore();
    final _RecordingAnalyticsTransport transport =
        _RecordingAnalyticsTransport()..failNextBatch = true;
    final EcoUnityAnalyticsService service = _analyticsService(
      store: store,
      transport: transport,
    );

    await service.trackModuleOpened(_module(), language: 'en');

    final List<dynamic> queuedAfterFailure =
        store.values['event_queue'] as List<dynamic>;
    expect(queuedAfterFailure, hasLength(1));
    final String eventId = (queuedAfterFailure.single as Map)['event_id']
        .toString();

    await service.flush();

    expect(store.values.containsKey('event_queue'), isFalse);
    final List<_AnalyticsRequest> batchRequests = transport.requests
        .where(
          (_AnalyticsRequest request) =>
              request.path == '/api/ecounitylearning/analytics/events/batch',
        )
        .toList();
    expect(batchRequests, hasLength(2));
    for (final _AnalyticsRequest request in batchRequests) {
      final List<dynamic> events = request.payload['events'] as List<dynamic>;
      expect((events.single as Map)['event_id'], eventId);
    }
  });

  test('does not collect events when analytics is disabled', () async {
    final _MemoryAnalyticsStore store = _MemoryAnalyticsStore();
    final _RecordingAnalyticsTransport transport =
        _RecordingAnalyticsTransport();
    final EcoUnityAnalyticsService service = _analyticsService(
      store: store,
      transport: transport,
      config: const EcoUnityAnalyticsConfig(enabled: false, token: ''),
    );

    await service.trackLanguageChanged(
      previousLanguage: 'en',
      newLanguage: 'fi',
    );

    expect(transport.requests, isEmpty);
    expect(store.values, isEmpty);
  });

  test('resolves ingestion token from active server environment', () {
    final String token = EcoUnityAnalyticsConfig.resolveIngestionToken(
      tokenFromEnvironment: '',
      serverName: 'development',
      analyticsMap: <String, dynamic>{
        'ingestionToken': <String, dynamic>{
          'primary': 'primary-token',
          'development': 'development-token',
        },
      },
    );

    expect(token, 'development-token');
  });

  test('supports server analytics sections and dart define override', () {
    final Map<String, dynamic> analyticsMap = <String, dynamic>{
      'development': <String, dynamic>{
        'ingestionToken': 'development-section-token',
      },
      'ingestionToken': <String, dynamic>{
        'development': 'development-map-token',
      },
    };

    expect(
      EcoUnityAnalyticsConfig.resolveIngestionToken(
        tokenFromEnvironment: '',
        serverName: 'development',
        analyticsMap: analyticsMap,
      ),
      'development-section-token',
    );
    expect(
      EcoUnityAnalyticsConfig.resolveIngestionToken(
        tokenFromEnvironment: 'dart-define-token',
        serverName: 'development',
        analyticsMap: analyticsMap,
      ),
      'dart-define-token',
    );
  });

  test(
    'resends identity and starts a new session after server change',
    () async {
      final _MemoryAnalyticsStore store = _MemoryAnalyticsStore();
      final _RecordingAnalyticsTransport transport =
          _RecordingAnalyticsTransport();
      int configIndex = 0;
      final List<EcoUnityAnalyticsConfig> configs = <EcoUnityAnalyticsConfig>[
        const EcoUnityAnalyticsConfig(
          enabled: true,
          token: 'development-token',
          language: 'en',
          platform: 'web',
          appVersion: '1.0.0+1',
        ),
        const EcoUnityAnalyticsConfig(
          enabled: true,
          token: 'production-token',
          language: 'en',
          platform: 'web',
          appVersion: '1.0.0+1',
        ),
      ];
      int id = 0;
      final EcoUnityAnalyticsService service = EcoUnityAnalyticsService(
        configLoader: () async => configs[configIndex],
        transport: transport,
        store: store,
        idGenerator: () {
          id += 1;
          return '00000000-0000-4000-8000-${id.toString().padLeft(12, '0')}';
        },
        clock: () => DateTime.utc(2026, 8, 18, 12, 0, id),
      );

      await service.startSession(language: 'en');
      store.values['event_queue'] = <Map<String, dynamic>>[
        <String, dynamic>{'event_id': 'old-server-event'},
      ];

      configIndex = 1;
      await service.handleServerChanged(language: 'en');

      final List<_AnalyticsRequest> lifecycleRequests = transport.requests
          .where(
            (_AnalyticsRequest request) =>
                request.path == '/api/ecounitylearning/analytics/identity' ||
                request.path == '/api/ecounitylearning/analytics/session/start',
          )
          .toList();

      expect(
        lifecycleRequests.map((_AnalyticsRequest request) => request.path),
        <String>[
          '/api/ecounitylearning/analytics/identity',
          '/api/ecounitylearning/analytics/session/start',
          '/api/ecounitylearning/analytics/identity',
          '/api/ecounitylearning/analytics/session/start',
        ],
      );
      expect(
        lifecycleRequests.map((_AnalyticsRequest request) => request.token),
        <String>[
          'development-token',
          'development-token',
          'production-token',
          'production-token',
        ],
      );
      expect(store.values.containsKey('event_queue'), isFalse);
      expect(
        transport.requests.where(
          (_AnalyticsRequest request) =>
              request.path == '/api/ecounitylearning/analytics/events/batch',
        ),
        isEmpty,
      );
    },
  );

  test('ignores stale session startup after server change', () async {
    final _MemoryAnalyticsStore store = _MemoryAnalyticsStore();
    final _RecordingAnalyticsTransport transport =
        _RecordingAnalyticsTransport();
    final Completer<EcoUnityAnalyticsConfig> oldConfig =
        Completer<EcoUnityAnalyticsConfig>();
    final Completer<EcoUnityAnalyticsConfig> newConfig =
        Completer<EcoUnityAnalyticsConfig>();
    int loadCall = 0;
    int id = 0;
    final EcoUnityAnalyticsService service = EcoUnityAnalyticsService(
      configLoader: () {
        loadCall += 1;
        return loadCall == 1 ? oldConfig.future : newConfig.future;
      },
      transport: transport,
      store: store,
      idGenerator: () {
        id += 1;
        return '00000000-0000-4000-8000-${id.toString().padLeft(12, '0')}';
      },
      clock: () => DateTime.utc(2026, 8, 18, 12, 0, id),
    );

    final Future<void> staleStart = service.startSession(language: 'en');
    expect(loadCall, 1);

    final Future<void> serverChanged = service.handleServerChanged(
      language: 'en',
    );
    await Future<void>.delayed(Duration.zero);
    expect(loadCall, 2);

    newConfig.complete(
      const EcoUnityAnalyticsConfig(
        enabled: true,
        token: 'production-token',
        language: 'en',
        platform: 'web',
        appVersion: '1.0.0+1',
      ),
    );
    await serverChanged;

    oldConfig.complete(
      const EcoUnityAnalyticsConfig(
        enabled: true,
        token: 'development-token',
        language: 'en',
        platform: 'web',
        appVersion: '1.0.0+1',
      ),
    );
    await staleStart;

    expect(
      transport.requests.map((_AnalyticsRequest request) => request.path),
      <String>[
        '/api/ecounitylearning/analytics/identity',
        '/api/ecounitylearning/analytics/session/start',
      ],
    );
    expect(
      transport.requests.map((_AnalyticsRequest request) => request.token),
      <String>['production-token', 'production-token'],
    );
  });
}

EcoUnityAnalyticsService _analyticsService({
  required _MemoryAnalyticsStore store,
  required _RecordingAnalyticsTransport transport,
  EcoUnityAnalyticsConfig config = const EcoUnityAnalyticsConfig(
    enabled: true,
    token: 'test-token',
    pilotKey: 'FI-01',
    country: 'FI',
    language: 'en',
    platform: 'web',
    appVersion: '1.0.0+1',
  ),
}) {
  int id = 0;
  return EcoUnityAnalyticsService(
    configLoader: () async => config,
    transport: transport,
    store: store,
    idGenerator: () {
      id += 1;
      return '00000000-0000-4000-8000-${id.toString().padLeft(12, '0')}';
    },
    clock: () => DateTime.utc(2026, 8, 18, 12, 0, id),
  );
}

EcoUnitySdgModule _module() {
  return const EcoUnitySdgModule(
    id: 42,
    sdgNumber: 5,
    slug: 'sdg-5',
    title: 'SDG 5',
    introduction: '',
    learningObjective: '',
    estimatedMinutes: null,
    difficulty: '',
    contentStatus: EcoUnityContentStatus.published,
    iconImage: null,
    coverImage: null,
    activities: <EcoUnityLearningActivity>[],
    badges: <EcoUnityBadgeSummary>[],
    tags: <EcoUnityTag>[],
    rawData: <String, dynamic>{},
  );
}

EcoUnityLearningActivity _activity({
  EcoUnityActivityType type = EcoUnityActivityType.mlr,
}) {
  return EcoUnityLearningActivity(
    id: 108,
    moduleId: 42,
    sdgNumber: 5,
    slug: type == EcoUnityActivityType.reflection
        ? 'sdg-5-reflection'
        : 'sdg-5-mlr-1',
    type: type,
    flowStage: EcoUnityFlowStage.reflect,
    orderNo: 1,
    mlrNumber: null,
    title: 'Activity',
    shortDescription: '',
    body: '',
    keyMessage: '',
    reflectionPrompt: '',
    completionText: '',
    videoUrl: '',
    estimatedMinutes: null,
    difficulty: '',
    learningObjective: '',
    completionRequired: true,
    passingLogic: EcoUnityQuizPassingLogic.completionOnly,
    minimumScore: null,
    contentStatus: EcoUnityContentStatus.published,
    heroImage: null,
    mediaImages: const <EcoUnityMedia>[],
    files: const <EcoUnityMedia>[],
    questions: const <EcoUnityQuizQuestion>[],
    comicScenes: const <EcoUnityComicScene>[],
    tags: const <EcoUnityTag>[],
    rawData: const <String, dynamic>{},
  );
}

class _MemoryAnalyticsStore implements EcoUnityAnalyticsStore {
  final Map<String, Object?> values = <String, Object?>{};

  @override
  Future<Object?> getObject(String key) async => values[key];

  @override
  Future<void> setObject(String key, Object? value) async {
    values[key] = value;
  }

  @override
  Future<void> deleteObject(String key) async {
    values.remove(key);
  }
}

class _RecordingAnalyticsTransport implements EcoUnityAnalyticsTransport {
  final List<_AnalyticsRequest> requests = <_AnalyticsRequest>[];
  bool failNextBatch = false;

  @override
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> payload,
    String token,
  ) async {
    requests.add(_AnalyticsRequest(path, payload, token));
    if (path == '/api/ecounitylearning/analytics/events/batch') {
      if (failNextBatch) {
        failNextBatch = false;
        throw const EcoUnityAnalyticsHttpException(503, <String, dynamic>{
          'status': 'error',
        });
      }
      final List<dynamic> events = payload['events'] as List<dynamic>;
      return <String, dynamic>{
        'status': 'ok',
        'accepted': events.length,
        'duplicates': 0,
        'rejected': 0,
        'results': <Map<String, dynamic>>[
          for (int index = 0; index < events.length; index += 1)
            <String, dynamic>{
              'index': index,
              'status': 'accepted',
              'event_id': (events[index] as Map)['event_id'],
            },
        ],
      };
    }
    return <String, dynamic>{'status': 'ok'};
  }
}

class _AnalyticsRequest {
  const _AnalyticsRequest(this.path, this.payload, this.token);

  final String path;
  final Map<String, dynamic> payload;
  final String token;
}
