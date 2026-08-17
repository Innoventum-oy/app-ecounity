import 'package:ecounity/src/learning/ecounity_learning_models.dart';

class EcoUnityLearningDashboardSummary {
  const EcoUnityLearningDashboardSummary({
    required this.moduleCount,
    required this.activityCount,
    required this.completedActivityCount,
    required this.earnedBadgeCount,
    required this.continueModule,
    required this.nextActivity,
    required this.latestChallenge,
    required this.featuredModules,
    required List<EcoUnityProgressEntry> progressEntries,
  }) : _progressEntries = progressEntries;

  final int moduleCount;
  final int activityCount;
  final int completedActivityCount;
  final int earnedBadgeCount;
  final EcoUnitySdgModule? continueModule;
  final EcoUnityLearningActivity? nextActivity;
  final EcoUnityLearningActivity? latestChallenge;
  final List<EcoUnitySdgModule> featuredModules;

  double get activityCompletionRatio {
    if (activityCount == 0) {
      return 0;
    }
    return completedActivityCount / activityCount;
  }

  double get continueModuleCompletionRatio {
    final EcoUnitySdgModule? module = continueModule;
    if (module == null) {
      return 0;
    }
    return completionRatioFor(module);
  }

  bool get hasLearningData => moduleCount > 0;

  double completionRatioFor(EcoUnitySdgModule module) {
    return module.completionRatio(_progressEntries);
  }

  static EcoUnityLearningDashboardSummary fromLearningState({
    required List<EcoUnitySdgModule> modules,
    required List<EcoUnityProgressEntry> progressEntries,
  }) {
    final Set<int> completedActivityIds = progressEntries
        .where((entry) => entry.status == EcoUnityProgressStatus.completed)
        .map((entry) => entry.activityId)
        .whereType<int>()
        .toSet();

    final List<EcoUnityLearningActivity> activities = modules
        .expand((module) => module.activities)
        .toList();
    final List<EcoUnityLearningActivity> countedActivities = activities
        .where((activity) => activity.id != null)
        .toList();

    final EcoUnitySdgModule? continueModule = _findContinueModule(
      modules,
      progressEntries,
    );

    return EcoUnityLearningDashboardSummary(
      moduleCount: modules.length,
      activityCount: activities.length,
      completedActivityCount: countedActivities
          .where((activity) => completedActivityIds.contains(activity.id))
          .length,
      earnedBadgeCount: _earnedBadgeCount(modules, completedActivityIds),
      continueModule: continueModule,
      nextActivity: _findNextActivity(continueModule, completedActivityIds),
      latestChallenge: _findLatestChallenge(modules),
      featuredModules: _featuredModules(modules),
      progressEntries: progressEntries,
    );
  }

  final List<EcoUnityProgressEntry> _progressEntries;
}

EcoUnitySdgModule? _findContinueModule(
  List<EcoUnitySdgModule> modules,
  List<EcoUnityProgressEntry> progressEntries,
) {
  for (final EcoUnitySdgModule module in modules) {
    final double ratio = module.completionRatio(progressEntries);
    if (ratio > 0 && ratio < 1) {
      return module;
    }
  }
  for (final EcoUnitySdgModule module in modules) {
    if (module.activities.isNotEmpty) {
      return module;
    }
  }
  return modules.isEmpty ? null : modules.first;
}

EcoUnityLearningActivity? _findNextActivity(
  EcoUnitySdgModule? module,
  Set<int> completedActivityIds,
) {
  if (module == null || module.activities.isEmpty) {
    return null;
  }

  for (final EcoUnityLearningActivity activity in module.activities) {
    if (activity.id != null && !completedActivityIds.contains(activity.id)) {
      return activity;
    }
  }
  return module.activities.first;
}

EcoUnityLearningActivity? _findLatestChallenge(
  List<EcoUnitySdgModule> modules,
) {
  for (final EcoUnitySdgModule module in modules) {
    for (final EcoUnityLearningActivity activity in module.activities) {
      if (activity.type == EcoUnityActivityType.challenge) {
        return activity;
      }
    }
  }
  return null;
}

List<EcoUnitySdgModule> _featuredModules(List<EcoUnitySdgModule> modules) {
  final List<EcoUnitySdgModule> withActivities = modules
      .where((module) => module.activities.isNotEmpty)
      .toList();
  final List<EcoUnitySdgModule> source = withActivities.isNotEmpty
      ? withActivities
      : modules;
  return source.take(2).toList();
}

int _earnedBadgeCount(
  List<EcoUnitySdgModule> modules,
  Set<int> completedActivityIds,
) {
  final Set<int> earnedBadgeIds = <int>{};
  int anonymousEarnedBadges = 0;

  for (final EcoUnityBadgeSummary badge in modules.expand(
    (module) => module.badges,
  )) {
    if (badge.requiredActivityIds.isEmpty ||
        !badge.requiredActivityIds.every(completedActivityIds.contains)) {
      continue;
    }
    if (badge.id != null) {
      earnedBadgeIds.add(badge.id!);
    } else {
      anonymousEarnedBadges += 1;
    }
  }

  return earnedBadgeIds.length + anonymousEarnedBadges;
}
