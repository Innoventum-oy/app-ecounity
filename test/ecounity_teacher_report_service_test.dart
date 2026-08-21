import 'package:ecounity/src/analytics/ecounity_teacher_report_models.dart';
import 'package:ecounity/src/analytics/ecounity_teacher_report_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EcoUnityTeacherReportService', () {
    test('normalizes teacher tokens for manual entry', () {
      expect(
        EcoUnityTeacherReportService.normalizeTeacherToken(' abc def '),
        'ABCDEF',
      );
      expect(
        EcoUnityTeacherReportService.normalizeTeacherToken('Qwerty'),
        'QWERTY',
      );
    });

    test('loads and parses aggregate group report data', () async {
      final _RecordingTeacherReportTransport transport =
          _RecordingTeacherReportTransport(_sampleReportResponse());
      final EcoUnityTeacherReportService service = EcoUnityTeacherReportService(
        transport: transport,
      );

      final EcoUnityTeacherGroupReport report = await service.loadReport(
        ' abcdef ',
      );

      expect(
        transport.paths.single,
        '/api/ecounitylearning/groups/ABCDEF/report',
      );
      expect(report.displayName, 'Finland group 1');
      expect(report.enrolledUsers, 24);
      expect(report.summary.activeUsers, 22);
      expect(report.sdgStatsForNumber(5)?.moduleOpenedUsers, 20);
      expect(report.activityStatsFor(activityId: 17)?.completionRate, 77.8);
      expect(report.activityStatsFor(slug: 'sdg-5-quiz')?.averageScore, 7.5);
      expect(report.activityStatsFor(slug: 'sdg-5-quiz')?.maxScore, 10);
    });

    test('throws readable exception when report lookup fails', () async {
      final EcoUnityTeacherReportService service = EcoUnityTeacherReportService(
        transport: _FailingTeacherReportTransport(),
      );

      expect(
        () => service.loadReport('missing'),
        throwsA(isA<EcoUnityTeacherReportException>()),
      );
    });
  });
}

Map<String, dynamic> _sampleReportResponse() {
  return <String, dynamic>{
    'status': 'ok',
    'report': <String, dynamic>{
      'group': <String, dynamic>{
        'id': 1,
        'group_key': 'FI-01',
        'pilot_key': 'FI-01',
        'name': 'Finland group 1',
        'country': 'FI',
        'language': 'fi',
        'status': 'active',
      },
      'summary': <String, dynamic>{
        'enrolled_users': 24,
        'participant_code_rows': 0,
        'active_users': 22,
        'sessions': 68,
        'events': 340,
        'activity_opened_users': 21,
        'activity_completed_users': 17,
        'activity_completion_rate': 81.0,
      },
      'sdgs': <Map<String, dynamic>>[
        <String, dynamic>{
          'sdg_number': 5,
          'module_opened_users': 20,
          'module_completed_users': 14,
          'activity_opened_users': 19,
          'activity_completed_users': 15,
          'activity_completion_rate': 78.9,
          'activities': <Map<String, dynamic>>[
            <String, dynamic>{
              'sdg_number': 5,
              'activity_id': 17,
              'activity_type': 'mlr',
              'title': 'What is Gender Equality?',
              'slug': 'sdg-5-mlr-1',
              'opened_users': 18,
              'completed_users': 14,
              'completion_rate': 77.8,
            },
            <String, dynamic>{
              'sdg_number': 5,
              'activity_id': 18,
              'activity_type': 'quiz',
              'title': 'Quiz',
              'slug': 'sdg-5-quiz',
              'opened_users': 16,
              'completed_users': 12,
              'completion_rate': 75.0,
              'quiz_average_score': 7.5,
              'possible_score': 10,
            },
          ],
        },
      ],
      'schemaReady': true,
      'schemaMissing': false,
      'lastUpdated': '2026-08-20 09:30:00',
    },
  };
}

class _RecordingTeacherReportTransport
    implements EcoUnityTeacherReportTransport {
  _RecordingTeacherReportTransport(this.response);

  final Map<String, dynamic> response;
  final List<String> paths = <String>[];

  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    paths.add(path);
    return response;
  }
}

class _FailingTeacherReportTransport implements EcoUnityTeacherReportTransport {
  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    throw const EcoUnityTeacherReportException(
      404,
      'Group report token was not found.',
    );
  }
}
