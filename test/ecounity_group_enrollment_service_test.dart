import 'package:ecounity/src/analytics/ecounity_group_context.dart';
import 'package:ecounity/src/analytics/ecounity_group_enrollment_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EcoUnityGroupEnrollmentService', () {
    test('extracts enrollment tokens from supported QR link paths', () {
      expect(
        EcoUnityGroupEnrollmentService.normalizeJoinCode(
          'https://ecounity.devsite.fi/ecounitylearning/group/f4k9x7p2q8mn?x=1',
        ),
        'f4k9x7p2q8mn',
      );
      expect(
        EcoUnityGroupEnrollmentService.normalizeJoinCode(
          'https://ecounity.devsite.fi/ecounitylearning/pilot/legacy-token',
        ),
        'legacy-token',
      );
      expect(
        EcoUnityGroupEnrollmentService.normalizeJoinCode('  ABC123  '),
        'ABC123',
      );
    });

    test('resolves and returns persisted group context shape', () async {
      final _RecordingGroupEnrollmentTransport transport =
          _RecordingGroupEnrollmentTransport(<String, dynamic>{
            'status': 'ok',
            'group': <String, dynamic>{
              'id': 1,
              'group_key': 'FI-01',
              'pilot_key': 'FI-01',
              'name': 'Finland group 1',
              'country': 'FI',
              'language': 'fi',
              'status': 'active',
              'join_token': 'f4k9x7p2q8mn',
            },
          });
      final EcoUnityGroupEnrollmentService service =
          EcoUnityGroupEnrollmentService(
            transport: transport,
            persistContext: false,
          );

      final EcoUnityAnalyticsGroupContext group = await service.enrollWithCode(
        'https://ecounity.devsite.fi/ecounitylearning/group/f4k9x7p2q8mn',
      );

      expect(
        transport.paths.single,
        '/api/ecounitylearning/group/f4k9x7p2q8mn',
      );
      expect(group.effectivePilotKey, 'FI-01');
      expect(group.displayName, 'Finland group 1');
      expect(group.country, 'FI');
      expect(group.language, 'fi');
    });

    test('throws a readable exception when enrollment fails', () async {
      final EcoUnityGroupEnrollmentService service =
          EcoUnityGroupEnrollmentService(
            transport: _FailingGroupEnrollmentTransport(),
            persistContext: false,
          );

      expect(
        () => service.enrollWithCode('missing-token'),
        throwsA(isA<EcoUnityGroupEnrollmentException>()),
      );
    });
  });
}

class _RecordingGroupEnrollmentTransport
    implements EcoUnityGroupEnrollmentTransport {
  _RecordingGroupEnrollmentTransport(this.response);

  final Map<String, dynamic> response;
  final List<String> paths = <String>[];

  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    paths.add(path);
    return response;
  }
}

class _FailingGroupEnrollmentTransport
    implements EcoUnityGroupEnrollmentTransport {
  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    throw const EcoUnityGroupEnrollmentException(
      404,
      'Group enrollment link was not found or is not active.',
    );
  }
}
