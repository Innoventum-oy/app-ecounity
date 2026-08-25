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

  test('sends review comment when marking content as needs changes', () async {
    final _FakeReviewTransport transport = _FakeReviewTransport();
    final EcoUnityContentReviewProvider provider =
        EcoUnityContentReviewProvider(
          service: EcoUnityContentReviewService(transport: transport),
        );
    final core.User user = core.User(id: 3, token: 'review-token');

    final EcoUnityContentReviewRecord record = await provider.updateReview(
      user: user,
      scope: EcoUnityReviewScope.activity,
      objectId: 17,
      language: 'es',
      reviewStatus: EcoUnityReviewStatus.needsChanges,
      comment: '  Adapt the examples for Spanish classrooms.  ',
    );

    expect(record.reviewStatus, EcoUnityReviewStatus.needsChanges);
    expect(
      record.rawData['comment'],
      'Adapt the examples for Spanish classrooms.',
    );
    expect(transport.posts, hasLength(1));
    expect(
      transport.posts.single.path,
      '/api/ecounitylearning/review/activity/17/es/update',
    );
    expect(transport.posts.single.payload, <String, dynamic>{
      'review_status': 'needs_changes',
      'comment': 'Adapt the examples for Spanish classrooms.',
    });
  });
}

class _FakeReviewTransport implements EcoUnityContentReviewTransport {
  final List<String> paths = <String>[];
  final List<_FakePostRequest> posts = <_FakePostRequest>[];

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
    posts.add(_FakePostRequest(path, Map<String, dynamic>.from(payload)));
    if (path == '/api/ecounitylearning/review/activity/17/es/update') {
      return <String, dynamic>{
        'status': 'success',
        'marker': <String, dynamic>{
          'scopeType': 'activity',
          'scopeId': 17,
          'language': 'es',
          'reviewStatus': payload['review_status'],
          'comment': payload['comment'],
          'hasComment': payload['comment'] != null,
        },
      };
    }
    fail('Unexpected POST path: $path');
  }
}

class _FakePostRequest {
  const _FakePostRequest(this.path, this.payload);

  final String path;
  final Map<String, dynamic> payload;
}
