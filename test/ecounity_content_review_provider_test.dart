import 'package:core/core.dart' as core;
import 'package:ecounity/src/learning/ecounity_content_review_service.dart';
import 'package:ecounity/src/providers/ecounity_content_review_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads SDG review queue into per-object review cache', () async {
    final _FakeReviewTransport transport = _FakeReviewTransport();
    final EcoUnityContentReviewProvider provider =
        EcoUnityContentReviewProvider(
          service: EcoUnityContentReviewService(transport: transport),
        );
    final core.User user = core.User(id: 3, token: 'review-token');

    final List<EcoUnityContentReviewRecord> records = await provider
        .loadSdgReviewQueue(user: user, moduleId: 12, language: 'es');

    expect(records, hasLength(2));
    expect(
      provider
          .recordFor(
            scope: EcoUnityReviewScope.activity,
            objectId: 17,
            language: 'es',
          )
          ?.reviewStatus,
      EcoUnityReviewStatus.approved,
    );
    expect(
      provider
          .recordFor(
            scope: EcoUnityReviewScope.activity,
            objectId: 18,
            language: 'es',
          )
          ?.reviewStatus,
      EcoUnityReviewStatus.needsChanges,
    );
    expect(
      transport.paths,
      containsAll(<String>[
        '/api/accesslevels/modules/ecounitylearning',
        '/api/ecounitylearning/sdg/12/review/es',
      ]),
    );
  });
}

class _FakeReviewTransport implements EcoUnityContentReviewTransport {
  final List<String> paths = <String>[];

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    required core.User user,
    String? language,
  }) async {
    paths.add(path);
    if (path == '/api/accesslevels/modules/ecounitylearning') {
      return <String, dynamic>{'can_modify': true};
    }
    if (path == '/api/ecounitylearning/sdg/12/review/es') {
      return <String, dynamic>{
        'status': 'success',
        'language': 'es',
        'groups': <Map<String, dynamic>>[
          <String, dynamic>{
            'label': 'Activities',
            'items': <Map<String, dynamic>>[
              <String, dynamic>{
                'scopeType': 'activity',
                'scopeId': 17,
                'reviewStatus': 'approved',
                'reviewStatusLabel': 'Approved',
              },
              <String, dynamic>{
                'scope_type': 'activity',
                'object_id': 18,
                'review_status': 'needs_changes',
                'review_status_label': 'Needs changes',
              },
            ],
          },
        ],
      };
    }
    fail('Unexpected GET path: $path');
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> payload, {
    required core.User user,
    String? language,
  }) async {
    fail('Unexpected POST path: $path');
  }
}
