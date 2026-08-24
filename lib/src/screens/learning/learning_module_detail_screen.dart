import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/analytics/ecounity_analytics_service.dart';
import 'package:ecounity/src/analytics/ecounity_teacher_report_models.dart';
import 'package:ecounity/src/learning/ecounity_content_review_service.dart';
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_provider.dart';
import 'package:ecounity/src/learning/ecounity_learning_text_utils.dart';
import 'package:ecounity/src/learning/widgets/ecounity_content_review_panel.dart';
import 'package:ecounity/src/learning/widgets/ecounity_learning_copy.dart';
import 'package:ecounity/src/learning/widgets/ecounity_media_image.dart';
import 'package:ecounity/src/providers/ecounity_content_review_provider.dart';
import 'package:ecounity/src/providers/ecounity_teacher_report_provider.dart';
import 'package:ecounity/src/providers/teacher_mode_provider.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:ecounity/src/util/router.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EcoUnityLearningModuleDetailScreen extends StatefulWidget {
  const EcoUnityLearningModuleDetailScreen({
    super.key,
    required this.navIndex,
    this.module,
    this.moduleId,
  });

  final int navIndex;
  final EcoUnitySdgModule? module;
  final int? moduleId;

  @override
  State<EcoUnityLearningModuleDetailScreen> createState() =>
      _EcoUnityLearningModuleDetailScreenState();
}

class _EcoUnityLearningModuleDetailScreenState
    extends State<EcoUnityLearningModuleDetailScreen> {
  Future<EcoUnitySdgModule?>? _future;
  final Set<String> _trackedModuleOpenKeys = <String>{};
  String? _loadedLanguage;
  String? _requestedReviewQueueKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _loadModule();
  }

  @override
  void didUpdateWidget(covariant EcoUnityLearningModuleDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.module != widget.module ||
        oldWidget.moduleId != widget.moduleId) {
      _future = _loadModule();
      _requestedReviewQueueKey = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EcoUnitySdgModule?>(
      future: _future,
      builder:
          (BuildContext context, AsyncSnapshot<EcoUnitySdgModule?> snapshot) {
            final EcoUnitySdgModule? module = snapshot.data ?? widget.module;
            return ScreenScaffold(
              title: module?.title ?? context.l10n.learning_module_title,
              navigationIndex: widget.navIndex,
              child: _buildBody(context, snapshot, module),
            );
          },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<EcoUnitySdgModule?> snapshot,
    EcoUnitySdgModule? module,
  ) {
    if (snapshot.connectionState != ConnectionState.done && module == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(
        child: Text(
          context.l10n.learning_module_load_error('${snapshot.error}'),
        ),
      );
    }
    if (module == null) {
      return Center(child: Text(context.l10n.learning_module_not_found));
    }

    final bool teacherModeEnabled = Provider.of<TeacherModeProvider>(
      context,
    ).isTeacherMode;
    final String reviewLanguage =
        _loadedLanguage ?? Localizations.localeOf(context).languageCode;
    final core.User user = Provider.of<core.UserProvider>(context).user;
    final EcoUnityContentReviewProvider reviewProvider =
        Provider.of<EcoUnityContentReviewProvider>(context);
    _scheduleReviewQueueLoad(context, module, reviewLanguage, user);
    final bool showReviewChips = reviewProvider.canReviewFor(user);
    final bool reviewQueueLoading =
        showReviewChips &&
        module.id != null &&
        reviewProvider.isSdgReviewQueueLoading(
          moduleId: module.id!,
          language: reviewLanguage,
          user: user,
        );
    final EcoUnityTeacherGroupReport? teacherReport = teacherModeEnabled
        ? Provider.of<EcoUnityTeacherReportProvider>(context).activeReport
        : null;
    final Set<int> completedActivityIds = teacherModeEnabled
        ? <int>{}
        : _completedActivityIds(
            context.watch<EcoUnityLearningProvider>().progressEntries,
          );

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.78,
      child: ListView(
        key: const ValueKey<String>('learning-module-detail-list'),
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _ModuleHeader(module: module),
          if (module.id != null)
            EcoUnityContentReviewPanel(
              scope: EcoUnityReviewScope.module,
              objectId: module.id!,
              language: reviewLanguage,
              fallbackStatus: module.contentStatus,
            ),
          const SizedBox(height: 16),
          if (module.activities.isEmpty)
            const _EmptyActivitiesMessage()
          else
            for (final EcoUnityLearningActivity activity in module.activities)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Builder(
                  builder: (BuildContext context) {
                    final EcoUnityContentReviewRecord? reviewRecord =
                        showReviewChips && activity.id != null
                        ? reviewProvider.recordFor(
                            scope: EcoUnityReviewScope.activity,
                            objectId: activity.id!,
                            language: reviewLanguage,
                          )
                        : null;
                    final EcoUnityReviewStatus? reviewStatus = showReviewChips
                        ? reviewRecord?.reviewStatus ??
                              ecoUnityReviewStatusFromContentStatus(
                                activity.contentStatus,
                              )
                        : null;

                    return _ActivityCard(
                      activity: activity,
                      completed:
                          activity.id != null &&
                          completedActivityIds.contains(activity.id),
                      teacherStats: teacherReport?.activityStatsFor(
                        activityId: activity.id,
                        slug: activity.slug,
                      ),
                      groupSize: teacherReport?.enrolledUsers,
                      reviewStatus: reviewStatus,
                      reviewStatusLabel: reviewStatus == null
                          ? null
                          : _reviewStatusLabel(reviewStatus, reviewRecord),
                      reviewLoading:
                          reviewStatus != null &&
                          reviewQueueLoading &&
                          reviewRecord == null,
                      onTap: () {
                        AppRouter.navigate(
                          context,
                          'learningactivity',
                          widget.navIndex,
                          replaceRoute: false,
                          data: activity,
                        );
                      },
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  Future<EcoUnitySdgModule?> _loadModule() async {
    final int? moduleId = widget.moduleId ?? widget.module?.id;
    if (moduleId == null) {
      return widget.module;
    }
    final EcoUnityLearningProvider provider =
        Provider.of<EcoUnityLearningProvider>(context, listen: false);
    final bool teacherModeEnabled = Provider.of<TeacherModeProvider>(
      context,
      listen: false,
    ).isTeacherMode;
    final String language = await core.Settings().getLanguage() ?? 'en';
    _loadedLanguage = language;
    final Future<EcoUnitySdgModule?> moduleFuture = provider.loadModule(
      moduleId,
      language: language,
    );
    final Future<List<EcoUnityProgressEntry>>? progressFuture =
        teacherModeEnabled ? null : provider.loadProgress(language: language);
    final EcoUnitySdgModule? module = await moduleFuture ?? widget.module;
    await progressFuture;
    if (module != null) {
      _trackModuleOpened(module, language);
    }
    return module;
  }

  void _trackModuleOpened(EcoUnitySdgModule module, String language) {
    if (Provider.of<TeacherModeProvider>(
      context,
      listen: false,
    ).isTeacherMode) {
      return;
    }
    final int? moduleId = module.id;
    if (moduleId == null) {
      return;
    }
    final String key = '$moduleId:$language';
    if (!_trackedModuleOpenKeys.add(key)) {
      return;
    }
    final EcoUnityAnalyticsService? analytics = _analyticsOf(context);
    if (analytics == null) {
      return;
    }
    unawaited(analytics.trackModuleOpened(module, language: language));
  }

  void _scheduleReviewQueueLoad(
    BuildContext context,
    EcoUnitySdgModule module,
    String language,
    core.User user,
  ) {
    final int? moduleId = module.id;
    if (moduleId == null || !_hasPotentialReviewUser(user)) {
      return;
    }

    final String key = '$moduleId:$language:${user.id}:${user.token}';
    if (_requestedReviewQueueKey == key) {
      return;
    }
    _requestedReviewQueueKey = key;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final EcoUnityContentReviewProvider reviewProvider =
          Provider.of<EcoUnityContentReviewProvider>(context, listen: false);
      unawaited(
        reviewProvider.loadSdgReviewQueue(
          user: user,
          moduleId: moduleId,
          language: language,
        ),
      );
    });
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({required this.module});

  final EcoUnitySdgModule module;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EcoUnityColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (module.coverImage != null) ...<Widget>[
              AspectRatio(
                aspectRatio: 16 / 9,
                child: EcoUnityMediaImage(
                  media: module.coverImage,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(6),
                  fallback: _ModuleBannerFallback(module: module),
                  loadedKey: ValueKey<String>(
                    'sdg-module-cover-${module.id ?? module.sdgNumber ?? module.slug}',
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: EcoUnityColors.deepTeal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'SDG ${module.sdgNumber ?? '-'}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (module.difficulty.isNotEmpty)
                  Chip(label: Text(module.difficulty)),
              ],
            ),
            if (module.introduction.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              EcoUnityLearningCopy(
                text: module.introduction,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (module.learningObjective.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              EcoUnityLearningCopy(
                text: module.learningObjective,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: EcoUnityColors.deepTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModuleBannerFallback extends StatelessWidget {
  const _ModuleBannerFallback({required this.module});

  final EcoUnitySdgModule module;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.deepTeal,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'SDG ${module.sdgNumber ?? '-'}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyActivitiesMessage extends StatelessWidget {
  const _EmptyActivitiesMessage();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EcoUnityColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.hourglass_empty,
              color: EcoUnityColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.learning_empty_activities,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: EcoUnityColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.activity,
    required this.completed,
    required this.teacherStats,
    required this.groupSize,
    required this.reviewStatus,
    required this.reviewStatusLabel,
    required this.reviewLoading,
    required this.onTap,
  });

  final EcoUnityLearningActivity activity;
  final bool completed;
  final EcoUnityTeacherActivityStats? teacherStats;
  final int? groupSize;
  final EcoUnityReviewStatus? reviewStatus;
  final String? reviewStatusLabel;
  final bool reviewLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color cardColor = completed ? const Color(0xFFEAF8E4) : Colors.white;
    final Color borderColor = completed
        ? EcoUnityColors.success.withValues(alpha: 0.35)
        : EcoUnityColors.outlineVariant;
    final Color leadingBackground = completed
        ? EcoUnityColors.success
        : EcoUnityColors.surfaceContainer;
    final Color leadingForeground = completed
        ? Colors.white
        : EcoUnityColors.deepTeal;

    return Card(
      color: cardColor,
      elevation: completed ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor),
      ),
      child: ListTile(
        onTap: onTap,
        minVerticalPadding: 12,
        leading: CircleAvatar(
          backgroundColor: leadingBackground,
          foregroundColor: leadingForeground,
          child: Icon(
            completed ? Icons.check_rounded : _activityIcon(activity.type),
          ),
        ),
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                activity.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: completed
                    ? Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: EcoUnityColors.deepTeal,
                        fontWeight: FontWeight.w800,
                      )
                    : null,
              ),
            ),
            if (completed) ...<Widget>[
              const SizedBox(width: 8),
              const _CompletedActivityChip(),
            ],
          ],
        ),
        isThreeLine: teacherStats != null || reviewStatus != null,
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _activityLabel(context, activity),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (reviewStatus != null) ...<Widget>[
                const SizedBox(height: 8),
                _ActivityReviewStatusChip(
                  status: reviewStatus!,
                  label: reviewStatusLabel ?? _reviewStatusLabel(reviewStatus!),
                  loading: reviewLoading,
                ),
              ],
              if (teacherStats != null) ...<Widget>[
                const SizedBox(height: 8),
                _TeacherActivityStats(
                  stats: teacherStats!,
                  groupSize: groupSize,
                  isQuiz: activity.isQuiz,
                ),
              ],
            ],
          ),
        ),
        trailing: Icon(
          completed ? Icons.check_circle_rounded : Icons.chevron_right,
          color: completed ? EcoUnityColors.success : null,
        ),
      ),
    );
  }
}

class _TeacherActivityStats extends StatelessWidget {
  const _TeacherActivityStats({
    required this.stats,
    required this.groupSize,
    required this.isQuiz,
  });

  final EcoUnityTeacherActivityStats stats;
  final int? groupSize;
  final bool isQuiz;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: <Widget>[
        _TeacherStatChip(
          icon: Icons.visibility_outlined,
          label: context.l10n.teacher_stats_opened(
            stats.openedUsers,
            groupSize?.toString() ?? '-',
          ),
        ),
        _TeacherStatChip(
          icon: Icons.check_circle_outline_rounded,
          label: context.l10n.teacher_stats_completed(
            _percentLabel(stats.completionRate),
          ),
        ),
        if (isQuiz && stats.averageScore != null)
          _TeacherStatChip(
            icon: Icons.speed_rounded,
            label: stats.maxScore == null
                ? context.l10n.teacher_stats_avg_score(
                    _numberLabel(stats.averageScore!),
                  )
                : context.l10n.teacher_stats_avg_score_with_max(
                    _numberLabel(stats.averageScore!),
                    _numberLabel(stats.maxScore!),
                  ),
          ),
      ],
    );
  }
}

class _ActivityReviewStatusChip extends StatelessWidget {
  const _ActivityReviewStatusChip({
    required this.status,
    required this.label,
    required this.loading,
  });

  final EcoUnityReviewStatus status;
  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final Color color = _reviewStatusColor(status);
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.42)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (loading) ...<Widget>[
                SizedBox.square(
                  dimension: 12,
                  child: CircularProgressIndicator(
                    color: color,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 6),
              ] else ...<Widget>[
                Icon(_reviewStatusIcon(status), size: 14, color: color),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherStatChip extends StatelessWidget {
  const _TeacherStatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.teacherSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: EcoUnityColors.teacherBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 14, color: EcoUnityColors.deepTeal),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: EcoUnityColors.deepTeal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedActivityChip extends StatelessWidget {
  const _CompletedActivityChip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: EcoUnityColors.success.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          context.l10n.completed,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: EcoUnityColors.success,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

IconData _activityIcon(EcoUnityActivityType type) {
  return switch (type) {
    EcoUnityActivityType.comic => Icons.forum,
    EcoUnityActivityType.mlr => Icons.menu_book,
    EcoUnityActivityType.quiz => Icons.quiz,
    EcoUnityActivityType.reflection => Icons.psychology_alt,
    EcoUnityActivityType.challenge => Icons.flag,
    EcoUnityActivityType.unknown => Icons.help_outline,
  };
}

IconData _reviewStatusIcon(EcoUnityReviewStatus status) {
  return switch (status) {
    EcoUnityReviewStatus.approved => Icons.check_circle_outline_rounded,
    EcoUnityReviewStatus.published => Icons.verified_rounded,
    EcoUnityReviewStatus.needsReview => Icons.rate_review_outlined,
    EcoUnityReviewStatus.needsChanges => Icons.edit_note_rounded,
    EcoUnityReviewStatus.notReady => Icons.hourglass_empty_rounded,
    EcoUnityReviewStatus.unknown => Icons.help_outline_rounded,
  };
}

Color _reviewStatusColor(EcoUnityReviewStatus status) {
  return switch (status) {
    EcoUnityReviewStatus.approved => EcoUnityColors.success,
    EcoUnityReviewStatus.published => EcoUnityColors.success,
    EcoUnityReviewStatus.needsReview => EcoUnityColors.warning,
    EcoUnityReviewStatus.needsChanges => EcoUnityColors.warmOrange,
    EcoUnityReviewStatus.notReady => EcoUnityColors.textSecondary,
    EcoUnityReviewStatus.unknown => EcoUnityColors.textSecondary,
  };
}

String _reviewStatusLabel([
  EcoUnityReviewStatus? status,
  EcoUnityContentReviewRecord? record,
]) {
  final String backendLabel = _firstNonEmptyString(<Object?>[
    record?.rawData['reviewStatusLabel'],
    record?.rawData['review_status_label'],
    record?.rawData['status_label'],
    record?.rawData['statusLabel'],
  ]);
  if (backendLabel.isNotEmpty) {
    return backendLabel;
  }

  return switch (status ?? EcoUnityReviewStatus.unknown) {
    EcoUnityReviewStatus.notReady => 'Not ready',
    EcoUnityReviewStatus.needsReview => 'Needs review',
    EcoUnityReviewStatus.needsChanges => 'Needs changes',
    EcoUnityReviewStatus.approved => 'Approved',
    EcoUnityReviewStatus.published => 'Published',
    EcoUnityReviewStatus.unknown => 'Unknown',
  };
}

bool _hasPotentialReviewUser(core.User user) {
  return user.id != null &&
      !user.isGuestUser &&
      (user.token?.trim().isNotEmpty ?? false);
}

Set<int> _completedActivityIds(List<EcoUnityProgressEntry> progressEntries) {
  return progressEntries
      .where((EcoUnityProgressEntry entry) {
        return entry.status == EcoUnityProgressStatus.completed;
      })
      .map((EcoUnityProgressEntry entry) => entry.activityId)
      .whereType<int>()
      .toSet();
}

EcoUnityAnalyticsService? _analyticsOf(BuildContext context) {
  try {
    return Provider.of<EcoUnityAnalyticsService>(context, listen: false);
  } catch (_) {
    return null;
  }
}

String _activityLabel(BuildContext context, EcoUnityLearningActivity activity) {
  final String description = ecoUnityPlainText(
    activity.shortDescription,
    maxLength: 90,
  );
  final List<String> parts = <String>[
    switch (activity.type) {
      EcoUnityActivityType.comic => context.l10n.learning_activity_type(
        'comic',
      ),
      EcoUnityActivityType.mlr => context.l10n.learning_activity_type('mlr'),
      EcoUnityActivityType.quiz => context.l10n.learning_activity_type('quiz'),
      EcoUnityActivityType.reflection => context.l10n.learning_activity_type(
        'reflection',
      ),
      EcoUnityActivityType.challenge => context.l10n.learning_activity_type(
        'challenge',
      ),
      EcoUnityActivityType.unknown => context.l10n.learning_activity_type(
        'unknown',
      ),
    },
    if (activity.estimatedMinutes != null)
      activity.estimatedMinutes == 1
          ? context.l10n.learning_one_minute
          : context.l10n.learning_minutes(activity.estimatedMinutes!),
    if (description.isNotEmpty) description,
  ];
  return parts.join(' · ');
}

String _firstNonEmptyString(Iterable<Object?> values) {
  for (final Object? value in values) {
    final String text = value?.toString().trim() ?? '';
    if (text.isNotEmpty && text != 'null') {
      return text;
    }
  }
  return '';
}

String _percentLabel(double? value) {
  if (value == null) {
    return '-';
  }
  final bool wholeNumber = value == value.roundToDouble();
  return '${value.toStringAsFixed(wholeNumber ? 0 : 1)}%';
}

String _numberLabel(double value) {
  final bool wholeNumber = value == value.roundToDouble();
  return value.toStringAsFixed(wholeNumber ? 0 : 1);
}
