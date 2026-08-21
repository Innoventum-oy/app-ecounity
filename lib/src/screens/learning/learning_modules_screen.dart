import 'package:core/core.dart' as core;
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/analytics/ecounity_teacher_report_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_provider.dart';
import 'package:ecounity/src/learning/widgets/ecounity_media_image.dart';
import 'package:ecounity/src/providers/ecounity_teacher_report_provider.dart';
import 'package:ecounity/src/providers/teacher_mode_provider.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:ecounity/src/util/router.dart';
import 'package:ecounity/src/widgets/bottom_navigation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _ModuleFilter { all, started, done, challenges }

class EcoUnityLearningModulesScreen extends StatefulWidget {
  const EcoUnityLearningModulesScreen({super.key, required this.navIndex});

  final int navIndex;

  @override
  State<EcoUnityLearningModulesScreen> createState() =>
      _EcoUnityLearningModulesScreenState();
}

class _EcoUnityLearningModulesScreenState
    extends State<EcoUnityLearningModulesScreen> {
  bool _loadRequested = false;
  _ModuleFilter _selectedFilter = _ModuleFilter.all;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadRequested) {
      _loadRequested = true;
      _loadModules();
    }
  }

  @override
  Widget build(BuildContext context) {
    final core.User user = Provider.of<core.UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        centerTitle: false,
        leadingWidth: 58,
        titleSpacing: 0,
        leading: const _LearningModulesAppBarLeading(),
        title: Text(
          context.l10n.screenTitle_modules,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: EcoUnityColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: <Widget>[
          _LearningModulesAppBarAction(
            tooltip: context.l10n.refresh,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadModules,
          ),
          const SizedBox(width: 4),
          _LearningModulesAppBarAction(
            tooltip: context.l10n.settings,
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              AppRouter.navigate(context, '/settings', 0, replaceRoute: false);
            },
          ),
          if (user.id != null) ...<Widget>[
            const SizedBox(width: 4),
            _LearningModulesAppBarAction(
              tooltip: context.l10n.logout,
              icon: const Icon(Icons.logout_rounded),
              onPressed: _logout,
            ),
          ],
          const SizedBox(width: 12),
        ],
      ),
      body: Consumer<EcoUnityLearningProvider>(
        builder:
            (
              BuildContext context,
              EcoUnityLearningProvider provider,
              Widget? child,
            ) {
              final bool teacherModeEnabled = Provider.of<TeacherModeProvider>(
                context,
              ).isTeacherMode;
              final EcoUnityTeacherGroupReport? teacherReport =
                  teacherModeEnabled
                  ? Provider.of<EcoUnityTeacherReportProvider>(
                      context,
                    ).activeReport
                  : null;
              if (provider.loadingStatus == core.DataLoadingStatus.loading &&
                  provider.modules.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.modules.isEmpty) {
                return Center(
                  child: Text(provider.error ?? context.l10n.no_modules_found),
                );
              }

              return _LearningModulesBody(
                modules: provider.modules,
                progressEntries: teacherModeEnabled
                    ? const <EcoUnityProgressEntry>[]
                    : provider.progressEntries,
                teacherModeEnabled: teacherModeEnabled,
                teacherReport: teacherReport,
                loading:
                    provider.loadingStatus == core.DataLoadingStatus.loading,
                selectedFilter: _selectedFilter,
                onFilterChanged: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                onRefresh: _loadModules,
                onModuleTap: (EcoUnitySdgModule module) {
                  AppRouter.navigate(
                    context,
                    'learningmodule',
                    widget.navIndex,
                    replaceRoute: false,
                    data: module,
                  );
                },
              );
            },
      ),
      bottomNavigationBar: bottomNavigation(
        context,
        currentIndex: widget.navIndex,
      ),
    );
  }

  Future<void> _loadModules() async {
    final EcoUnityLearningProvider provider =
        Provider.of<EcoUnityLearningProvider>(context, listen: false);
    final bool teacherModeEnabled = Provider.of<TeacherModeProvider>(
      context,
      listen: false,
    ).isTeacherMode;
    final String language = await core.Settings().getLanguage() ?? 'en';
    try {
      await provider.loadModules(language: language, reload: true);
      if (!teacherModeEnabled) {
        await provider.loadProgress(language: language);
      }
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unable to load EcoUnity learning modules: $exception');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  Future<void> _logout() async {
    final core.UserProvider userProvider = Provider.of<core.UserProvider>(
      context,
      listen: false,
    );
    final core.User loggedInUser = userProvider.user;
    if (!loggedInUser.isGuestUser) {
      await Provider.of<core.AuthProvider>(
        context,
        listen: false,
      ).logout(loggedInUser);
    }
    userProvider.clearCurrentUser();
    if (mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }
  }
}

class _LearningModulesAppBarLeading extends StatelessWidget {
  const _LearningModulesAppBarLeading();

  @override
  Widget build(BuildContext context) {
    final bool canPop =
        Navigator.canPop(context) && (ModalRoute.of(context)?.canPop ?? false);
    if (!canPop) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Image.asset('assets/images/ecounity-logo.png'),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 6, 10),
      child: Material(
        color: EcoUnityColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).maybePop(),
          child: const Center(
            child: Icon(
              Icons.arrow_back_rounded,
              color: EcoUnityColors.deepTeal,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _LearningModulesAppBarAction extends StatelessWidget {
  const _LearningModulesAppBarAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onPressed,
            child: SizedBox.square(
              dimension: 44,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: EcoUnityColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SizedBox.square(
                    dimension: 38,
                    child: IconTheme(
                      data: const IconThemeData(
                        color: EcoUnityColors.deepTeal,
                        size: 19,
                      ),
                      child: Center(child: icon),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LearningModulesBody extends StatelessWidget {
  const _LearningModulesBody({
    required this.modules,
    required this.progressEntries,
    required this.teacherModeEnabled,
    required this.teacherReport,
    required this.loading,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onRefresh,
    required this.onModuleTap,
  });

  final List<EcoUnitySdgModule> modules;
  final List<EcoUnityProgressEntry> progressEntries;
  final bool teacherModeEnabled;
  final EcoUnityTeacherGroupReport? teacherReport;
  final bool loading;
  final _ModuleFilter selectedFilter;
  final ValueChanged<_ModuleFilter> onFilterChanged;
  final Future<void> Function() onRefresh;
  final ValueChanged<EcoUnitySdgModule> onModuleTap;

  @override
  Widget build(BuildContext context) {
    final _ModuleFilter effectiveFilter = teacherModeEnabled
        ? _ModuleFilter.all
        : selectedFilter;
    final List<_ModuleCardData> cardData = modules
        .map(
          (EcoUnitySdgModule module) => _ModuleCardData(
            module: module,
            completionRatio: module.completionRatio(progressEntries),
          ),
        )
        .where((data) => effectiveFilter.matches(data))
        .toList();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int columns = constraints.maxWidth >= 620 ? 3 : 2;
              return ListView(
                key: const ValueKey<String>('learning-modules-list'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                children: <Widget>[
                  if (loading) ...<Widget>[
                    const LinearProgressIndicator(minHeight: 3),
                    const SizedBox(height: 16),
                  ],
                  _ModuleListHeader(moduleCount: modules.length),
                  const SizedBox(height: 12),
                  if (!teacherModeEnabled) ...<Widget>[
                    _ModuleFilterBar(
                      selectedFilter: selectedFilter,
                      onFilterChanged: onFilterChanged,
                    ),
                    const SizedBox(height: 18),
                  ] else ...<Widget>[
                    _TeacherGroupStatsBanner(report: teacherReport),
                    const SizedBox(height: 18),
                  ],
                  if (cardData.isEmpty)
                    _FilteredEmptyState(filter: effectiveFilter)
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cardData.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: teacherModeEnabled
                            ? (columns == 2 ? 0.95 : 1.08)
                            : (columns == 2 ? 1.17 : 1.28),
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final _ModuleCardData data = cardData[index];
                        return _ModuleCard(
                          data: data,
                          showProgress: !teacherModeEnabled,
                          teacherStats: teacherReport?.sdgStatsForNumber(
                            data.module.sdgNumber,
                          ),
                          groupSize: teacherReport?.enrolledUsers,
                          onTap: () => onModuleTap(data.module),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TeacherGroupStatsBanner extends StatelessWidget {
  const _TeacherGroupStatsBanner({required this.report});

  final EcoUnityTeacherGroupReport? report;

  @override
  Widget build(BuildContext context) {
    final bool hasReport = report != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.teacherSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EcoUnityColors.teacherBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            const Icon(Icons.insights_rounded, color: EcoUnityColors.deepTeal),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasReport
                    ? context.l10n.learning_group_stats_for(report!.displayName)
                    : context.l10n.learning_group_stats_empty,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: EcoUnityColors.deepTeal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleListHeader extends StatelessWidget {
  const _ModuleListHeader({required this.moduleCount});

  final int moduleCount;

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.learning_sdg_modules_count(moduleCount),
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: EcoUnityColors.deepTeal,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ModuleFilterBar extends StatelessWidget {
  const _ModuleFilterBar({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final _ModuleFilter selectedFilter;
  final ValueChanged<_ModuleFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _ModuleFilter.values.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (BuildContext context, int index) {
          final _ModuleFilter filter = _ModuleFilter.values[index];
          return _ModuleFilterPill(
            filter: filter,
            selected: filter == selectedFilter,
            onTap: () => onFilterChanged(filter),
          );
        },
      ),
    );
  }
}

class _ModuleFilterPill extends StatelessWidget {
  const _ModuleFilterPill({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  final _ModuleFilter filter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor = selected
        ? Colors.white
        : EcoUnityColors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: filter.label(context),
      child: Material(
        color: selected ? EcoUnityColors.deepTeal : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minWidth: 96, minHeight: 36),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? EcoUnityColors.deepTeal : Colors.transparent,
              ),
            ),
            child: Text(
              filter.label(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.data,
    required this.showProgress,
    required this.teacherStats,
    required this.groupSize,
    required this.onTap,
  });

  final _ModuleCardData data;
  final bool showProgress;
  final EcoUnityTeacherSdgStats? teacherStats;
  final int? groupSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final EcoUnitySdgModule module = data.module;
    final _ModuleCardStatus status = data.status;
    final bool started = showProgress && status == _ModuleCardStatus.started;
    final bool hasTeacherStats = !showProgress && teacherStats != null;

    return Card(
      margin: EdgeInsets.zero,
      color: hasTeacherStats
          ? const Color(0xFFFFFCF8)
          : started
          ? const Color(0xFFFFF8F1)
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: hasTeacherStats
              ? EcoUnityColors.teacherBorder
              : started
              ? EcoUnityColors.warmOrange
              : EcoUnityColors.outlineVariant,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _SdgModuleIcon(module: module, highlighted: started),
                  if (showProgress) ...<Widget>[
                    const SizedBox(width: 8),
                    Expanded(child: _ModuleStatusChip(status: status)),
                  ] else if (hasTeacherStats) ...<Widget>[
                    const SizedBox(width: 8),
                    const _TeacherCardChip(),
                  ] else
                    const Spacer(),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                module.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: EcoUnityColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (showProgress) ...<Widget>[
                LinearProgressIndicator(
                  value: data.visibleProgressRatio,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(999),
                  backgroundColor: EcoUnityColors.outlineVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    EcoUnityColors.leafGreen,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              if (hasTeacherStats)
                _TeacherModuleStats(stats: teacherStats!, groupSize: groupSize)
              else
                Text(
                  data.progressLabel(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: EcoUnityColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherCardChip extends StatelessWidget {
  const _TeacherCardChip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.teacherSurfaceHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Text(
          context.l10n.teacher_group,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: EcoUnityColors.deepTeal,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _TeacherModuleStats extends StatelessWidget {
  const _TeacherModuleStats({required this.stats, required this.groupSize});

  final EcoUnityTeacherSdgStats stats;
  final int? groupSize;

  @override
  Widget build(BuildContext context) {
    final double? completionRate = stats.activityCompletionRate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.l10n.teacher_stats_opened(
            stats.moduleOpenedUsers,
            groupSize?.toString() ?? '-',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: EcoUnityColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: completionRate == null
              ? 0
              : (completionRate / 100).clamp(0, 1).toDouble(),
          minHeight: 6,
          borderRadius: BorderRadius.circular(999),
          backgroundColor: EcoUnityColors.outlineVariant,
          valueColor: const AlwaysStoppedAnimation<Color>(
            EcoUnityColors.turquoise,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          context.l10n.teacher_stats_activity_completion(
            _percentLabel(completionRate),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: EcoUnityColors.textSecondary),
        ),
      ],
    );
  }
}

class _ModuleStatusChip extends StatelessWidget {
  const _ModuleStatusChip({required this.status});

  final _ModuleCardStatus status;

  @override
  Widget build(BuildContext context) {
    final bool started = status == _ModuleCardStatus.started;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: started ? Colors.white : EcoUnityColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Text(
          status.label(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: started
                ? EcoUnityColors.warning
                : EcoUnityColors.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SdgModuleIcon extends StatelessWidget {
  const _SdgModuleIcon({required this.module, required this.highlighted});

  final EcoUnitySdgModule module;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = highlighted
        ? EcoUnityColors.warmOrange
        : EcoUnityColors.deepTeal;
    final Widget fallback = _SdgNumberBadge(
      sdgNumber: module.sdgNumber,
      color: accentColor,
    );

    if (module.iconImage == null) {
      return fallback;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlighted
              ? EcoUnityColors.warmOrange
              : EcoUnityColors.outlineVariant,
        ),
      ),
      child: SizedBox.square(
        dimension: 42,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: EcoUnityMediaImage(
            media: module.iconImage,
            fit: BoxFit.contain,
            borderRadius: BorderRadius.circular(5),
            fallback: fallback,
            loadedKey: ValueKey<String>(
              'sdg-module-icon-${module.id ?? module.sdgNumber ?? module.slug}',
            ),
          ),
        ),
      ),
    );
  }
}

class _SdgNumberBadge extends StatelessWidget {
  const _SdgNumberBadge({required this.sdgNumber, required this.color});

  final int? sdgNumber;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        sdgNumber?.toString() ?? '-',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState({required this.filter});

  final _ModuleFilter filter;

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
        child: Text(
          context.l10n.learning_no_filtered_modules(filter.key),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: EcoUnityColors.textSecondary),
        ),
      ),
    );
  }
}

class _ModuleCardData {
  const _ModuleCardData({required this.module, required this.completionRatio});

  final EcoUnitySdgModule module;
  final double completionRatio;

  _ModuleCardStatus get status {
    if (completionRatio >= 1) {
      return _ModuleCardStatus.done;
    }
    if (completionRatio > 0) {
      return _ModuleCardStatus.started;
    }
    return _ModuleCardStatus.newModule;
  }

  bool get hasChallenge {
    return module.activities.any(
      (activity) => activity.type == EcoUnityActivityType.challenge,
    );
  }

  double get visibleProgressRatio {
    if (completionRatio >= 1) {
      return 1;
    }
    if (completionRatio > 0) {
      return completionRatio.clamp(0.04, 0.99);
    }
    return 0.04;
  }

  String progressLabel(BuildContext context) {
    if (status == _ModuleCardStatus.done) {
      return module.badges.isEmpty
          ? context.l10n.completed
          : context.l10n.learning_badge_earned;
    }

    final int? estimatedMinutes = _estimatedMinutes(module);
    if (status == _ModuleCardStatus.started) {
      if (estimatedMinutes == null) {
        return context.l10n.learning_in_progress;
      }
      final int remainingMinutes = (estimatedMinutes * (1 - completionRatio))
          .ceil();
      return remainingMinutes == 1
          ? context.l10n.learning_one_minute_left
          : context.l10n.learning_minutes_left(remainingMinutes);
    }

    if (estimatedMinutes != null) {
      return estimatedMinutes == 1
          ? context.l10n.learning_one_minute
          : context.l10n.learning_minutes(estimatedMinutes);
    }

    final int activityCount = module.activities.length;
    if (activityCount == 1) {
      return context.l10n.learning_one_activity;
    }
    return context.l10n.learning_activities(activityCount);
  }
}

enum _ModuleCardStatus { newModule, started, done }

extension on _ModuleCardStatus {
  String get key {
    return switch (this) {
      _ModuleCardStatus.newModule => 'new',
      _ModuleCardStatus.started => 'started',
      _ModuleCardStatus.done => 'done',
    };
  }

  String label(BuildContext context) =>
      context.l10n.learning_module_status(key);
}

extension on _ModuleFilter {
  String get key {
    return switch (this) {
      _ModuleFilter.all => 'all',
      _ModuleFilter.started => 'started',
      _ModuleFilter.done => 'done',
      _ModuleFilter.challenges => 'challenges',
    };
  }

  String label(BuildContext context) =>
      context.l10n.learning_module_filter(key);

  bool matches(_ModuleCardData data) {
    return switch (this) {
      _ModuleFilter.all => true,
      _ModuleFilter.started => data.status == _ModuleCardStatus.started,
      _ModuleFilter.done => data.status == _ModuleCardStatus.done,
      _ModuleFilter.challenges => data.hasChallenge,
    };
  }
}

int? _estimatedMinutes(EcoUnitySdgModule module) {
  if (module.estimatedMinutes != null) {
    return module.estimatedMinutes;
  }
  final int activityMinutes = module.activities.fold<int>(
    0,
    (sum, activity) => sum + (activity.estimatedMinutes ?? 0),
  );
  return activityMinutes > 0 ? activityMinutes : null;
}

String _percentLabel(double? value) {
  if (value == null) {
    return '-';
  }
  final bool wholeNumber = value == value.roundToDouble();
  return '${value.toStringAsFixed(wholeNumber ? 0 : 1)}%';
}
