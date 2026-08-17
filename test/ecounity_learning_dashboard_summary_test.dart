import 'package:ecounity/src/learning/ecounity_learning_dashboard_summary.dart';
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('summarizes modules, progress, badges, and next activity', () {
    final List<EcoUnitySdgModule> modules = <EcoUnitySdgModule>[
      _module(
        id: 12,
        sdgNumber: 12,
        activities: <Map<String, dynamic>>[
          _activity(id: 101, orderNo: 10, type: 'comic'),
          _activity(id: 102, orderNo: 20, type: 'mlr'),
          _activity(id: 103, orderNo: 30, type: 'challenge'),
        ],
        badges: <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 900,
            'name': 'Waste watcher',
            'requiredactivities': <Map<String, dynamic>>[
              <String, dynamic>{'objectid': 101},
            ],
          },
        ],
      ),
      _module(id: 13, sdgNumber: 13, activities: <Map<String, dynamic>>[]),
    ];
    final List<EcoUnityProgressEntry> progressEntries = <EcoUnityProgressEntry>[
      EcoUnityProgressEntry.fromJson(<String, dynamic>{
        'activity': 101,
        'module': 12,
        'status': 'completed',
      }),
    ];

    final EcoUnityLearningDashboardSummary summary =
        EcoUnityLearningDashboardSummary.fromLearningState(
          modules: modules,
          progressEntries: progressEntries,
        );

    expect(summary.moduleCount, 2);
    expect(summary.activityCount, 3);
    expect(summary.completedActivityCount, 1);
    expect(summary.earnedBadgeCount, 1);
    expect(summary.continueModule?.sdgNumber, 12);
    expect(summary.nextActivity?.id, 102);
    expect(summary.latestChallenge?.id, 103);
    expect(summary.continueModuleCompletionRatio, closeTo(1 / 3, 0.001));
    expect(summary.featuredModules.map((module) => module.sdgNumber), <int?>[
      12,
    ]);
  });

  test('limits featured modules to two dashboard cards', () {
    final List<EcoUnitySdgModule> modules = <EcoUnitySdgModule>[
      _module(
        id: 12,
        sdgNumber: 12,
        activities: <Map<String, dynamic>>[
          _activity(id: 101, orderNo: 10, type: 'mlr'),
        ],
      ),
      _module(
        id: 13,
        sdgNumber: 13,
        activities: <Map<String, dynamic>>[
          _activity(id: 201, orderNo: 10, type: 'mlr', moduleId: 13),
        ],
      ),
      _module(
        id: 14,
        sdgNumber: 14,
        activities: <Map<String, dynamic>>[
          _activity(id: 301, orderNo: 10, type: 'mlr', moduleId: 14),
        ],
      ),
    ];

    final EcoUnityLearningDashboardSummary summary =
        EcoUnityLearningDashboardSummary.fromLearningState(
          modules: modules,
          progressEntries: const <EcoUnityProgressEntry>[],
        );

    expect(summary.featuredModules.map((module) => module.sdgNumber), <int?>[
      12,
      13,
    ]);
  });
}

EcoUnitySdgModule _module({
  required int id,
  required int sdgNumber,
  required List<Map<String, dynamic>> activities,
  List<Map<String, dynamic>> badges = const <Map<String, dynamic>>[],
}) {
  return EcoUnitySdgModule.fromJson(<String, dynamic>{
    'id': id,
    'sdg_number': sdgNumber,
    'slug': 'sdg-$sdgNumber',
    'title': 'SDG $sdgNumber',
    'activities': activities,
    'badges': badges,
  });
}

Map<String, dynamic> _activity({
  required int id,
  required int orderNo,
  required String type,
  int moduleId = 12,
}) {
  return <String, dynamic>{
    'id': id,
    'module': moduleId,
    'sdg_number': moduleId,
    'slug': 'activity-$id',
    'activity_type': type,
    'orderno': orderNo,
    'title': 'Activity $id',
  };
}
