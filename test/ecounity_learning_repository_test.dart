import 'dart:convert';

import 'package:core/core.dart' as core;
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EcoUnityLearningRepository', () {
    test(
      'loads SDG modules through the revised object type and field list',
      () async {
        final _FakeLearningBackend backend = _FakeLearningBackend()
          ..listResponses[EcoUnityLearningRepository.sdgModuleObjectType] =
              <dynamic>[
                _moduleResponse(sdgNumber: 12),
                _moduleResponse(sdgNumber: 5),
              ];

        final EcoUnityLearningRepository repository =
            EcoUnityLearningRepository(backend: backend);

        final List<EcoUnitySdgModule> modules = await repository.loadModules(
          language: 'uk',
        );

        expect(
          backend.listRequests.single.objectType,
          EcoUnityLearningRepository.sdgModuleObjectType,
        );
        expect(backend.listRequests.single.params['language'], 'uk');
        expect(
          backend.listRequests.single.params['content_status'],
          'published',
        );
        expect(
          backend.listRequests.single.params['fields'],
          contains('activities'),
        );
        expect(
          modules.map((EcoUnitySdgModule module) => module.sdgNumber),
          <int?>[5, 12],
        );
      },
    );

    test(
      'loads filtered activities and keeps repository-level sort order',
      () async {
        final _FakeLearningBackend backend = _FakeLearningBackend()
          ..listResponses[EcoUnityLearningRepository.activityObjectType] =
              <dynamic>[
                _activityResponse(id: 202, orderNo: 20, type: 'mlr'),
                _activityResponse(id: 201, orderNo: 10, type: 'comic'),
              ];

        final EcoUnityLearningRepository repository =
            EcoUnityLearningRepository(backend: backend);

        final List<EcoUnityLearningActivity> activities = await repository
            .loadActivities(
              language: 'en',
              moduleId: 12,
              sdgNumber: 12,
              type: EcoUnityActivityType.comic,
              publishedOnly: false,
              additionalParams: <String, dynamic>{'limit': 20},
            );

        final _ListRequest request = backend.listRequests.single;
        expect(
          request.objectType,
          EcoUnityLearningRepository.activityObjectType,
        );
        expect(request.params['module'], 12);
        expect(request.params['sdg_number'], 12);
        expect(request.params['activity_type'], 'comic');
        expect(request.params.containsKey('content_status'), isFalse);
        expect(request.params['limit'], 20);
        expect(
          activities.map((EcoUnityLearningActivity activity) => activity.id),
          <int?>[201, 202],
        );
      },
    );

    test('loads detail responses wrapped in ApiResponse', () async {
      final _FakeLearningBackend backend = _FakeLearningBackend()
        ..detailResponses['${EcoUnityLearningRepository.activityObjectType}:201'] =
            core.ApiResponse(
              status: core.ResponseStatus.success,
              data: _activityResponse(id: 201, orderNo: 10, type: 'comic'),
            );

      final EcoUnityLearningRepository repository = EcoUnityLearningRepository(
        backend: backend,
      );

      final EcoUnityLearningActivity? activity = await repository.loadActivity(
        201,
      );

      expect(activity?.id, 201);
      expect(activity?.type, EcoUnityActivityType.comic);
    });

    test('saves progress with backend field names and JSON payload', () async {
      final _FakeLearningBackend backend = _FakeLearningBackend();
      final EcoUnityLearningRepository repository = EcoUnityLearningRepository(
        backend: backend,
      );

      final EcoUnityProgressEntry? saved = await repository.saveProgress(
        moduleId: 12,
        activityId: 201,
        status: EcoUnityProgressStatus.completed,
        language: 'fi',
        payload: <String, dynamic>{'score': 3},
      );

      expect(
        backend.savedObjectType,
        EcoUnityLearningRepository.progressObjectType,
      );
      expect(backend.savedObjectId, isNull);
      expect(backend.savedObjectData?['module'], 12);
      expect(backend.savedObjectData?['activity'], 201);
      expect(backend.savedObjectData?['status'], 'completed');
      expect(backend.savedObjectData?['language'], 'fi');
      expect(
        jsonDecode(backend.savedObjectData?['payload_json'] as String),
        <String, dynamic>{'score': 3},
      );
      expect(backend.savedObjectData?['completed_at'], isNotNull);
      expect(saved?.status, EcoUnityProgressStatus.completed);
      expect(saved?.payload, <String, dynamic>{'score': 3});
    });
  });
}

Map<String, dynamic> _moduleResponse({required int sdgNumber}) {
  return <String, dynamic>{
    'id': sdgNumber,
    'sdg_number': sdgNumber,
    'slug': 'sdg-$sdgNumber',
    'title': <String, dynamic>{'en': 'SDG $sdgNumber'},
    'content_status': 'published',
    'activities': <Map<String, dynamic>>[],
  };
}

Map<String, dynamic> _activityResponse({
  required int id,
  required int orderNo,
  required String type,
}) {
  return <String, dynamic>{
    'id': id,
    'module': <String, dynamic>{'id': 12},
    'sdg_number': 12,
    'slug': '$type-$id',
    'activity_type': type,
    'flow_stage': type == 'comic' ? 'discover' : 'learn',
    'orderno': orderNo,
    'title': <String, dynamic>{'en': 'Activity $id'},
    'content_status': 'published',
  };
}

class _FakeLearningBackend implements EcoUnityLearningBackend {
  final Map<String, dynamic> listResponses = <String, dynamic>{};
  final Map<String, dynamic> detailResponses = <String, dynamic>{};
  final List<_ListRequest> listRequests = <_ListRequest>[];

  int? savedObjectId;
  String? savedObjectType;
  Map<String, dynamic>? savedObjectData;

  @override
  Future<dynamic> getDataList(
    String objectType,
    Map<String, dynamic> params,
  ) async {
    listRequests.add(
      _ListRequest(objectType, Map<String, dynamic>.from(params)),
    );
    return listResponses[objectType] ?? <dynamic>[];
  }

  @override
  Future<dynamic> getDetails(String objectType, int objectId) async {
    return detailResponses['$objectType:$objectId'];
  }

  @override
  Future<dynamic> saveObject(
    int? objectId,
    String objectType,
    Map<String, dynamic> objectData,
  ) async {
    savedObjectId = objectId;
    savedObjectType = objectType;
    savedObjectData = Map<String, dynamic>.from(objectData);

    return <String, dynamic>{
      'data': <String, dynamic>{
        'id': 77,
        'module': objectData['module'],
        'activity': objectData['activity'],
        'language': objectData['language'],
        'status': objectData['status'],
        'source': objectData['source'],
        'payload_json': objectData['payload_json'],
        'completed_at': objectData['completed_at'],
      },
    };
  }
}

class _ListRequest {
  const _ListRequest(this.objectType, this.params);

  final String objectType;
  final Map<String, dynamic> params;
}
