import 'dart:developer';

import 'package:core/core.dart' as core;
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_provider.dart';
import 'package:ecounity/src/learning/widgets/ecounity_media_image.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:ecounity/src/util/router.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _ProgressSegment { earned, locked, sdgProgress }

class AchievementsView extends StatefulWidget {
  final int navIndex;
  final String viewTitle = 'progress';
  const AchievementsView({required this.navIndex, super.key});

  @override
  AchievementsViewState createState() => AchievementsViewState();
}

class AchievementsViewState extends State<AchievementsView> {
  bool _loadRequested = false;
  bool _loading = false;
  String? _error;
  String? _loadedLanguage;
  _ProgressSegment _selectedSegment = _ProgressSegment.earned;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String language = Localizations.localeOf(context).languageCode;
    if (!_loadRequested ||
        (_loadedLanguage != null && _loadedLanguage != language)) {
      _loadRequested = true;
      _loadProgressData(reload: _loadedLanguage != null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      log('building ProgressView');
    }

    return ScreenScaffold(
      title: context.l10n.current_progress,
      navigationIndex: widget.navIndex,
      child: Consumer<EcoUnityLearningProvider>(
        builder:
            (
              BuildContext context,
              EcoUnityLearningProvider provider,
              Widget? child,
            ) {
              return _buildBody(context, provider);
            },
      ),
    );
  }

  Widget _buildBody(BuildContext context, EcoUnityLearningProvider provider) {
    final _ProgressScreenData data = _ProgressScreenData.fromLearningState(
      modules: provider.modules,
      progressEntries: provider.progressEntries,
    );

    if (_loading && !data.hasLearningData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && !data.hasLearningData) {
      return _ProgressMessage(
        icon: Icons.cloud_off_outlined,
        title: context.l10n.progress_load_error_title,
        message: _error!,
        action: FilledButton.icon(
          onPressed: () => _loadProgressData(reload: true),
          icon: const Icon(Icons.refresh),
          label: Text(context.l10n.refresh),
        ),
      );
    }

    if (!data.hasLearningData) {
      return _ProgressMessage(
        icon: Icons.school_outlined,
        title: context.l10n.noPathwaysFound,
        message: context.l10n.progress_empty_message,
        action: FilledButton.icon(
          onPressed: () => _loadProgressData(reload: true),
          icon: const Icon(Icons.refresh),
          label: Text(context.l10n.refresh),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadProgressData(reload: true),
      child: ListView(
        key: const ValueKey<String>('screenshot-progress-loaded'),
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  context.l10n.progress_journey_title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: EcoUnityColors.deepTeal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (_loading)
                const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _ProgressSummaryCard(data: data),
          const SizedBox(height: 12),
          _ProgressSegmentSelector(
            selectedSegment: _selectedSegment,
            onChanged: (Set<_ProgressSegment> selected) {
              final _ProgressSegment? next = selected.firstOrNull;
              if (next == null) {
                return;
              }
              setState(() {
                _selectedSegment = next;
              });
            },
          ),
          const SizedBox(height: 16),
          _ProgressSegmentBody(
            segment: _selectedSegment,
            data: data,
            onModuleTap: _openModule,
          ),
          const SizedBox(height: 16),
          if (data.suggestedModule != null)
            _SuggestedModuleCard(
              module: data.suggestedModule!,
              nextActivity: data.suggestedActivity,
              completionRatio: data.moduleCompletionRatio(
                data.suggestedModule!,
              ),
              onTap: () => _openModule(data.suggestedModule!),
            ),
        ],
      ),
    );
  }

  Future<void> _loadProgressData({bool reload = false}) async {
    if (_loading) {
      return;
    }

    final EcoUnityLearningProvider provider =
        Provider.of<EcoUnityLearningProvider>(context, listen: false);
    final String fallbackLanguage = Localizations.localeOf(
      context,
    ).languageCode;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final String language =
          await core.Settings().getLanguage() ?? fallbackLanguage;
      await Future.wait(<Future<void>>[
        provider.loadModules(language: language, reload: reload),
        provider.loadProgress(language: language),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _loadedLanguage = language;
      });
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        log(
          'Unable to load EcoUnity progress: $exception',
          name: 'ProgressView',
          stackTrace: stackTrace,
        );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _error = exception.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _openModule(EcoUnitySdgModule module) {
    AppRouter.navigate(
      context,
      'learningmodule',
      widget.navIndex,
      replaceRoute: false,
      data: module,
    );
  }
}

class _ProgressSummaryCard extends StatelessWidget {
  const _ProgressSummaryCard({required this.data});

  final _ProgressScreenData data;

  @override
  Widget build(BuildContext context) {
    final int percent = _percent(data.overallCompletionRatio);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.deepTeal,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x180D404E),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              context.l10n.progress_overall_complete(percent),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              context.l10n.progress_summary(
                data.completedModuleCount,
                data.activeChallengeCount,
                data.earnedBadges.length,
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: data.overallCompletionRatio,
                color: EcoUnityColors.leafGreen,
                backgroundColor: Colors.white.withValues(alpha: 0.78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressSegmentSelector extends StatelessWidget {
  const _ProgressSegmentSelector({
    required this.selectedSegment,
    required this.onChanged,
  });

  final _ProgressSegment selectedSegment;
  final ValueChanged<Set<_ProgressSegment>> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_ProgressSegment>(
      showSelectedIcon: false,
      segments: <ButtonSegment<_ProgressSegment>>[
        ButtonSegment<_ProgressSegment>(
          value: _ProgressSegment.earned,
          label: Text(context.l10n.progress_segment('earned')),
        ),
        ButtonSegment<_ProgressSegment>(
          value: _ProgressSegment.locked,
          label: Text(context.l10n.progress_segment('locked')),
        ),
        ButtonSegment<_ProgressSegment>(
          value: _ProgressSegment.sdgProgress,
          label: Text(context.l10n.progress_segment('modules')),
        ),
      ],
      selected: <_ProgressSegment>{selectedSegment},
      onSelectionChanged: onChanged,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 44)),
        visualDensity: VisualDensity.compact,
        textStyle: WidgetStatePropertyAll<TextStyle?>(
          Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return EcoUnityColors.deepTeal;
          }
          return Colors.white;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return EcoUnityColors.textSecondary;
        }),
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const BorderSide(color: EcoUnityColors.deepTeal);
          }
          return const BorderSide(color: EcoUnityColors.outlineVariant);
        }),
      ),
    );
  }
}

class _ProgressSegmentBody extends StatelessWidget {
  const _ProgressSegmentBody({
    required this.segment,
    required this.data,
    required this.onModuleTap,
  });

  final _ProgressSegment segment;
  final _ProgressScreenData data;
  final ValueChanged<EcoUnitySdgModule> onModuleTap;

  @override
  Widget build(BuildContext context) {
    return switch (segment) {
      _ProgressSegment.earned => _BadgeGrid(
        badges: data.earnedBadges,
        emptyTitle: context.l10n.progress_no_badges_earned_title,
        emptyMessage: context.l10n.progress_no_badges_earned_message,
      ),
      _ProgressSegment.locked => _BadgeGrid(
        badges: data.lockedBadges,
        emptyTitle: context.l10n.progress_all_badges_earned_title,
        emptyMessage: context.l10n.progress_all_badges_earned_message,
      ),
      _ProgressSegment.sdgProgress => _SdgProgressList(
        modules: data.modules,
        data: data,
        onModuleTap: onModuleTap,
      ),
    };
  }
}

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({
    required this.badges,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final List<_ProgressBadge> badges;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return _InlineEmptyState(title: emptyTitle, message: emptyMessage);
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 620 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: badges.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: columns == 2 ? 0.92 : 0.96,
          ),
          itemBuilder: (BuildContext context, int index) {
            return _ProgressBadgeCard(badge: badges[index]);
          },
        );
      },
    );
  }
}

class _ProgressBadgeCard extends StatelessWidget {
  const _ProgressBadgeCard({required this.badge});

  final _ProgressBadge badge;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = badge.earned
        ? EcoUnityColors.leafGreen
        : EcoUnityColors.outlineVariant;
    final Color backgroundColor = badge.earned
        ? const Color(0xFFF0FCEB)
        : Colors.white;
    final Color statusColor = badge.earned
        ? EcoUnityColors.success
        : EcoUnityColors.textSecondary;
    final String badgeLabel = badge.id == null
        ? context.l10n.progress_final_badge_title
        : badge.label;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: _BadgeSymbol(badge: badge),
            ),
            const SizedBox(height: 12),
            Text(
              badgeLabel.isEmpty
                  ? context.l10n.learning_module_badge_fallback
                  : badgeLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: EcoUnityColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              context.l10n.progress_badge_status(
                badge.earned ? 'earned' : 'locked',
              ),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (!badge.earned) ...<Widget>[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 5,
                  value: badge.completionRatio,
                  color: EcoUnityColors.turquoise,
                  backgroundColor: EcoUnityColors.surfaceContainerHigh,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BadgeSymbol extends StatelessWidget {
  const _BadgeSymbol({required this.badge});

  final _ProgressBadge badge;

  @override
  Widget build(BuildContext context) {
    final EcoUnityMedia? image = badge.image;
    final Color color = badge.earned
        ? EcoUnityColors.leafGreen
        : EcoUnityColors.outline;

    return SizedBox.square(
      dimension: 56,
      child: image == null
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  badge.symbol,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            )
          : EcoUnityMediaImage(
              media: image,
              fit: BoxFit.contain,
              borderRadius: BorderRadius.circular(14),
              fallback: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    badge.symbol,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _SdgProgressList extends StatelessWidget {
  const _SdgProgressList({
    required this.modules,
    required this.data,
    required this.onModuleTap,
  });

  final List<EcoUnitySdgModule> modules;
  final _ProgressScreenData data;
  final ValueChanged<EcoUnitySdgModule> onModuleTap;

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) {
      return _InlineEmptyState(
        title: context.l10n.progress_no_modules_title,
        message: context.l10n.progress_no_modules_message,
      );
    }

    return Column(
      children: <Widget>[
        for (final EcoUnitySdgModule module in modules) ...<Widget>[
          _SdgProgressTile(
            module: module,
            completionRatio: data.moduleCompletionRatio(module),
            completedActivities: data.completedRequiredActivityCount(module),
            requiredActivities: data.requiredActivityCount(module),
            onTap: () => onModuleTap(module),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SdgProgressTile extends StatelessWidget {
  const _SdgProgressTile({
    required this.module,
    required this.completionRatio,
    required this.completedActivities,
    required this.requiredActivities,
    required this.onTap,
  });

  final EcoUnitySdgModule module;
  final double completionRatio;
  final int completedActivities;
  final int requiredActivities;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final int percent = _percent(completionRatio);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: EcoUnityColors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                _ModuleSymbol(module: module),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _moduleTitle(context, module),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: EcoUnityColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: completionRatio,
                          color: completionRatio >= 1
                              ? EcoUnityColors.leafGreen
                              : EcoUnityColors.turquoise,
                          backgroundColor: EcoUnityColors.surfaceContainerHigh,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.progress_module_activities(
                          completedActivities,
                          requiredActivities,
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: EcoUnityColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$percent%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: EcoUnityColors.deepTeal,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModuleSymbol extends StatelessWidget {
  const _ModuleSymbol({required this.module});

  final EcoUnitySdgModule module;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 50,
      child: module.iconImage == null
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: EcoUnityColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${module.sdgNumber ?? ''}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: EcoUnityColors.deepTeal,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            )
          : EcoUnityMediaImage(
              media: module.iconImage,
              fit: BoxFit.contain,
              borderRadius: BorderRadius.circular(12),
              fallback: DecoratedBox(
                decoration: BoxDecoration(
                  color: EcoUnityColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text('${module.sdgNumber ?? ''}')),
              ),
            ),
    );
  }
}

class _SuggestedModuleCard extends StatelessWidget {
  const _SuggestedModuleCard({
    required this.module,
    required this.nextActivity,
    required this.completionRatio,
    required this.onTap,
  });

  final EcoUnitySdgModule module;
  final EcoUnityLearningActivity? nextActivity;
  final double completionRatio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: EcoUnityColors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.progress_suggested_module,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: EcoUnityColors.turquoise,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _moduleTitle(context, module),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: EcoUnityColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (nextActivity != null &&
                    nextActivity!.title.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.progress_continue_with(nextActivity!.title),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: EcoUnityColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: completionRatio,
                    color: EcoUnityColors.leafGreen,
                    backgroundColor: EcoUnityColors.surfaceContainerHigh,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressMessage extends StatelessWidget {
  const _ProgressMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 42, color: EcoUnityColors.deepTeal),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: EcoUnityColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: EcoUnityColors.textSecondary,
              ),
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({required this.title, required this.message});

  final String title;
  final String message;

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
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: EcoUnityColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: EcoUnityColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressScreenData {
  const _ProgressScreenData({
    required this.modules,
    required this.progressEntries,
    required this.badges,
    required this.earnedBadges,
    required this.lockedBadges,
    required this.completedModuleCount,
    required this.activeChallengeCount,
    required this.overallCompletionRatio,
    required this.suggestedModule,
    required this.suggestedActivity,
  });

  final List<EcoUnitySdgModule> modules;
  final List<EcoUnityProgressEntry> progressEntries;
  final List<_ProgressBadge> badges;
  final List<_ProgressBadge> earnedBadges;
  final List<_ProgressBadge> lockedBadges;
  final int completedModuleCount;
  final int activeChallengeCount;
  final double overallCompletionRatio;
  final EcoUnitySdgModule? suggestedModule;
  final EcoUnityLearningActivity? suggestedActivity;

  bool get hasLearningData => modules.isNotEmpty;

  static _ProgressScreenData fromLearningState({
    required List<EcoUnitySdgModule> modules,
    required List<EcoUnityProgressEntry> progressEntries,
  }) {
    final List<EcoUnitySdgModule> orderedModules =
        <EcoUnitySdgModule>[...modules]
          ..sort((EcoUnitySdgModule a, EcoUnitySdgModule b) {
            return (a.sdgNumber ?? 0).compareTo(b.sdgNumber ?? 0);
          });
    final Set<int> completedActivityIds = _completedActivityIds(
      progressEntries,
    );
    final List<_ProgressBadge> badges = _progressBadges(
      orderedModules,
      completedActivityIds,
    );
    final EcoUnitySdgModule? suggestedModule = _suggestedModule(
      orderedModules,
      progressEntries,
    );

    return _ProgressScreenData(
      modules: orderedModules,
      progressEntries: progressEntries,
      badges: badges,
      earnedBadges: badges
          .where((_ProgressBadge badge) => badge.earned)
          .toList(),
      lockedBadges: badges
          .where((_ProgressBadge badge) => !badge.earned)
          .toList(),
      completedModuleCount: orderedModules.where((EcoUnitySdgModule module) {
        return module.completionRatio(progressEntries) >= 1;
      }).length,
      activeChallengeCount: _activeChallengeCount(
        orderedModules,
        progressEntries,
      ),
      overallCompletionRatio: _overallCompletionRatio(
        orderedModules,
        completedActivityIds,
      ),
      suggestedModule: suggestedModule,
      suggestedActivity: _suggestedActivity(
        suggestedModule,
        completedActivityIds,
      ),
    );
  }

  double moduleCompletionRatio(EcoUnitySdgModule module) {
    return module.completionRatio(progressEntries);
  }

  int requiredActivityCount(EcoUnitySdgModule module) {
    return _requiredActivities(module).length;
  }

  int completedRequiredActivityCount(EcoUnitySdgModule module) {
    final Set<int> completedIds = _completedActivityIds(progressEntries);
    return _requiredActivities(module).where((
      EcoUnityLearningActivity activity,
    ) {
      return activity.id != null && completedIds.contains(activity.id);
    }).length;
  }
}

class _ProgressBadge {
  const _ProgressBadge({
    required this.id,
    required this.label,
    required this.description,
    required this.image,
    required this.symbol,
    required this.completionRatio,
    required this.earned,
  });

  final int? id;
  final String label;
  final String description;
  final EcoUnityMedia? image;
  final String symbol;
  final double completionRatio;
  final bool earned;
}

List<_ProgressBadge> _progressBadges(
  List<EcoUnitySdgModule> modules,
  Set<int> completedActivityIds,
) {
  final Map<String, _ProgressBadge> byKey = <String, _ProgressBadge>{};

  for (final EcoUnitySdgModule module in modules) {
    for (final EcoUnityBadgeSummary badge in module.badges) {
      final List<int> requiredActivityIds = badge.requiredActivityIds.isNotEmpty
          ? badge.requiredActivityIds
          : _requiredActivities(module)
                .map((EcoUnityLearningActivity activity) => activity.id)
                .whereType<int>()
                .toList();
      final _BadgeCompletion completion = _badgeCompletion(
        requiredActivityIds,
        completedActivityIds,
      );
      final _ProgressBadge progressBadge = _ProgressBadge(
        id: badge.id,
        label: badge.name.isNotEmpty ? badge.name : _moduleBadgeLabel(module),
        description: badge.description,
        image: badge.image,
        symbol: module.sdgNumber?.toString() ?? _initials(badge.name),
        completionRatio: completion.ratio,
        earned: completion.earned,
      );
      byKey[_badgeKey(progressBadge, module)] = progressBadge;
    }
  }

  final _ProgressBadge finalBadge = _finalBadge(modules, completedActivityIds);
  byKey['final'] = finalBadge;

  final List<_ProgressBadge> badges = byKey.values.toList()
    ..sort((_ProgressBadge a, _ProgressBadge b) {
      if (a.earned != b.earned) {
        return a.earned ? -1 : 1;
      }
      return a.label.compareTo(b.label);
    });
  return badges;
}

String _badgeKey(_ProgressBadge badge, EcoUnitySdgModule module) {
  final int? badgeId = badge.id;
  if (badgeId != null) {
    return 'badge:$badgeId';
  }
  return 'module:${module.id ?? module.sdgNumber}:${badge.label}';
}

_ProgressBadge _finalBadge(
  List<EcoUnitySdgModule> modules,
  Set<int> completedActivityIds,
) {
  final List<int> requiredActivityIds = modules
      .expand(_requiredActivities)
      .map((EcoUnityLearningActivity activity) => activity.id)
      .whereType<int>()
      .toList();
  final _BadgeCompletion completion = _badgeCompletion(
    requiredActivityIds,
    completedActivityIds,
  );
  return _ProgressBadge(
    id: null,
    label: 'EcoUnity Final',
    description: 'Complete every SDG module to unlock the final badge.',
    image: null,
    symbol: 'E',
    completionRatio: completion.ratio,
    earned: completion.earned,
  );
}

_BadgeCompletion _badgeCompletion(
  List<int> requiredActivityIds,
  Set<int> completedActivityIds,
) {
  if (requiredActivityIds.isEmpty) {
    return const _BadgeCompletion(ratio: 0, earned: false);
  }
  final int completed = requiredActivityIds
      .where(completedActivityIds.contains)
      .length;
  final double ratio = completed / requiredActivityIds.length;
  return _BadgeCompletion(
    ratio: ratio,
    earned: completed >= requiredActivityIds.length,
  );
}

class _BadgeCompletion {
  const _BadgeCompletion({required this.ratio, required this.earned});

  final double ratio;
  final bool earned;
}

Set<int> _completedActivityIds(List<EcoUnityProgressEntry> progressEntries) {
  return progressEntries
      .where(
        (EcoUnityProgressEntry entry) =>
            entry.status == EcoUnityProgressStatus.completed,
      )
      .map((EcoUnityProgressEntry entry) => entry.activityId)
      .whereType<int>()
      .toSet();
}

List<EcoUnityLearningActivity> _requiredActivities(EcoUnitySdgModule module) {
  return module.activities
      .where((EcoUnityLearningActivity activity) => activity.completionRequired)
      .toList();
}

int _activeChallengeCount(
  List<EcoUnitySdgModule> modules,
  List<EcoUnityProgressEntry> progressEntries,
) {
  final Set<int> challengeActivityIds = modules
      .expand((EcoUnitySdgModule module) => module.activities)
      .where(
        (EcoUnityLearningActivity activity) =>
            activity.type == EcoUnityActivityType.challenge,
      )
      .map((EcoUnityLearningActivity activity) => activity.id)
      .whereType<int>()
      .toSet();

  return progressEntries
      .where((EcoUnityProgressEntry entry) {
        return entry.activityId != null &&
            challengeActivityIds.contains(entry.activityId) &&
            entry.status != EcoUnityProgressStatus.completed &&
            entry.status != EcoUnityProgressStatus.reset;
      })
      .map((EcoUnityProgressEntry entry) => entry.activityId)
      .whereType<int>()
      .toSet()
      .length;
}

double _overallCompletionRatio(
  List<EcoUnitySdgModule> modules,
  Set<int> completedActivityIds,
) {
  final List<int> requiredIds = modules
      .expand(_requiredActivities)
      .map((EcoUnityLearningActivity activity) => activity.id)
      .whereType<int>()
      .toList();
  if (requiredIds.isEmpty) {
    return 0;
  }
  final int completed = requiredIds.where(completedActivityIds.contains).length;
  return completed / requiredIds.length;
}

EcoUnitySdgModule? _suggestedModule(
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
    if (module.completionRatio(progressEntries) < 1 &&
        module.activities.isNotEmpty) {
      return module;
    }
  }
  return modules.isEmpty ? null : modules.first;
}

EcoUnityLearningActivity? _suggestedActivity(
  EcoUnitySdgModule? module,
  Set<int> completedActivityIds,
) {
  if (module == null) {
    return null;
  }
  for (final EcoUnityLearningActivity activity in module.activities) {
    if (activity.id != null && !completedActivityIds.contains(activity.id)) {
      return activity;
    }
  }
  return module.activities.isEmpty ? null : module.activities.first;
}

String _moduleTitle(BuildContext context, EcoUnitySdgModule module) {
  final String prefix = module.sdgNumber == null
      ? ''
      : 'SDG ${module.sdgNumber}';
  if (module.title.isEmpty) {
    return prefix.isEmpty ? context.l10n.learning_module_fallback : prefix;
  }
  return prefix.isEmpty ? module.title : '$prefix - ${module.title}';
}

String _moduleBadgeLabel(EcoUnitySdgModule module) {
  if (module.title.isEmpty) {
    return module.sdgNumber == null ? 'SDG Badge' : 'SDG ${module.sdgNumber}';
  }
  return module.title;
}

String _initials(String value) {
  final List<String> words = value
      .trim()
      .split(' ')
      .where((String word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) {
    return 'B';
  }
  if (words.length == 1) {
    return words.first.characters.first.toUpperCase();
  }
  return '${words.first.characters.first}${words.last.characters.first}'
      .toUpperCase();
}

int _percent(double ratio) {
  return (ratio.clamp(0, 1) * 100).round();
}
