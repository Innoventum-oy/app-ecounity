import 'dart:developer';

import 'package:core/core.dart' as core;
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/learning/ecounity_learning_dashboard_summary.dart';
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_provider.dart';
import 'package:ecounity/src/learning/ecounity_learning_text_utils.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:ecounity/src/util/router.dart';
import 'package:ecounity/src/widgets/bottom_navigation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashBoard extends StatefulWidget {
  final String viewTitle = 'dashboard';
  final int navIndex;
  final bool refresh;

  const DashBoard({this.navIndex = 0, this.refresh = false, super.key});

  @override
  DashBoardState createState() => DashBoardState();
}

class DashBoardState extends State<DashBoard> {
  bool _loadRequested = false;
  bool _loadingDashboard = false;
  String? _loadError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadRequested) {
      _loadRequested = true;
      _loadDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      log('Building EcoUnity dashboard');
    }

    final core.User user = Provider.of<core.UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset('assets/images/ecounity-logo.png'),
        ),
        title: Text(context.l10n.home),
        actions: <Widget>[
          IconButton(
            tooltip: context.l10n.refresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadDashboardData(reload: true),
          ),
          IconButton(
            tooltip: context.l10n.settings,
            icon: const Icon(Icons.settings),
            onPressed: () {
              AppRouter.navigate(context, '/settings', 0, replaceRoute: false);
            },
          ),
          if (user.id != null)
            IconButton(
              tooltip: context.l10n.logout,
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
        ],
      ),
      body: Consumer<EcoUnityLearningProvider>(
        builder:
            (
              BuildContext context,
              EcoUnityLearningProvider provider,
              Widget? child,
            ) {
              return _DashboardBody(
                provider: provider,
                loading: _loadingDashboard,
                error: _loadError ?? provider.error,
                onRefresh: () => _loadDashboardData(reload: true),
              );
            },
      ),
      bottomNavigationBar: bottomNavigation(
        context,
        currentIndex: widget.navIndex,
      ),
    );
  }

  Future<void> _loadDashboardData({bool reload = false}) async {
    if (_loadingDashboard) {
      return;
    }

    setState(() {
      _loadingDashboard = true;
      _loadError = null;
    });

    final EcoUnityLearningProvider provider =
        Provider.of<EcoUnityLearningProvider>(context, listen: false);
    final String fallbackLanguage = Localizations.localeOf(
      context,
    ).languageCode;
    final String language =
        await core.Settings().getLanguage() ?? fallbackLanguage;

    try {
      await provider.loadModules(language: language, reload: reload);
      try {
        await provider.loadProgress(language: language);
      } catch (exception, stackTrace) {
        if (kDebugMode) {
          debugPrint('Unable to load EcoUnity dashboard progress: $exception');
          debugPrintStack(stackTrace: stackTrace);
        }
      }
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unable to load EcoUnity dashboard modules: $exception');
        debugPrintStack(stackTrace: stackTrace);
      }
      _loadError = exception.toString();
    } finally {
      if (mounted) {
        setState(() {
          _loadingDashboard = false;
        });
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

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.provider,
    required this.loading,
    required this.error,
    required this.onRefresh,
  });

  final EcoUnityLearningProvider provider;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final bool initialLoading = loading && provider.modules.isEmpty;
    if (initialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.modules.isEmpty) {
      return Center(child: Text(error ?? 'No modules available'));
    }

    final EcoUnityLearningDashboardSummary summary =
        EcoUnityLearningDashboardSummary.fromLearningState(
          modules: provider.modules,
          progressEntries: provider.progressEntries,
        );

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: <Widget>[
              if (error != null) ...<Widget>[
                _DashboardErrorBanner(message: error!),
                const SizedBox(height: 12),
              ],
              const _DashboardIntro(),
              const SizedBox(height: 14),
              _ContinueLearningCard(summary: summary),
              const SizedBox(height: 16),
              _DashboardStats(summary: summary),
              const SizedBox(height: 18),
              _FeaturedModulesSection(summary: summary),
              if (summary.latestChallenge != null) ...<Widget>[
                const SizedBox(height: 14),
                _LatestChallengeCard(activity: summary.latestChallenge!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardIntro extends StatelessWidget {
  const _DashboardIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Welcome back',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: EcoUnityColors.turquoise,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ready to take action today?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: EcoUnityColors.deepTeal,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({required this.summary});

  final EcoUnityLearningDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final EcoUnitySdgModule? module = summary.continueModule;
    final double ratio = summary.continueModuleCompletionRatio.clamp(0, 1);
    final String title = module?.sdgNumber == null
        ? 'Start learning'
        : 'Continue SDG ${module!.sdgNumber}';
    final String subtitle =
        module?.title ?? 'Explore EcoUnity learning modules';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.deepTeal,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: Colors.white.withValues(alpha: 0.85),
              valueColor: const AlwaysStoppedAnimation<Color>(
                EcoUnityColors.leafGreen,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: EcoUnityColors.deepTeal,
                ),
                onPressed: () {
                  if (module == null) {
                    AppRouter.navigate(
                      context,
                      'learningmodules',
                      1,
                      replaceRoute: false,
                    );
                    return;
                  }
                  AppRouter.navigate(
                    context,
                    'learningmodule',
                    1,
                    replaceRoute: false,
                    data: module,
                  );
                },
                child: Text(
                  module == null ? 'Browse modules' : 'Resume module',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardStats extends StatelessWidget {
  const _DashboardStats({required this.summary});

  final EcoUnityLearningDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EcoUnityColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _StatTile(value: summary.moduleCount, label: 'Modules'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatTile(
                value: summary.activityCount,
                label: 'Activities',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatTile(
                value: summary.earnedBadgeCount,
                label: 'Badges',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          children: <Widget>[
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: EcoUnityColors.deepTeal,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: EcoUnityColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedModulesSection extends StatelessWidget {
  const _FeaturedModulesSection({required this.summary});

  final EcoUnityLearningDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final List<EcoUnitySdgModule> modules = summary.featuredModules;
    if (modules.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 620 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: columns == 2 ? 0.88 : 1.05,
          ),
          itemBuilder: (BuildContext context, int index) {
            final EcoUnitySdgModule module = modules[index];
            return _ModulePreviewCard(
              module: module,
              ratio: summary.completionRatioFor(module),
            );
          },
        );
      },
    );
  }
}

class _ModulePreviewCard extends StatelessWidget {
  const _ModulePreviewCard({required this.module, required this.ratio});

  final EcoUnitySdgModule module;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final double clampedRatio = ratio.clamp(0, 1);
    final bool started = clampedRatio > 0;
    final bool completed = clampedRatio >= 1;

    return Card(
      color: started && !completed ? const Color(0xFFFFF8F1) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: started && !completed
              ? EcoUnityColors.warmOrange
              : EcoUnityColors.outlineVariant,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          AppRouter.navigate(
            context,
            'learningmodule',
            1,
            replaceRoute: false,
            data: module,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _SdgBadge(value: module.sdgNumber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModuleStatusChip(
                      label: completed
                          ? 'Done'
                          : started
                          ? 'Started'
                          : 'New',
                    ),
                  ),
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
              LinearProgressIndicator(
                value: clampedRatio,
                minHeight: 6,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 6),
              Text(
                _moduleDurationLabel(module),
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

class _LatestChallengeCard extends StatelessWidget {
  const _LatestChallengeCard({required this.activity});

  final EcoUnityLearningActivity activity;

  @override
  Widget build(BuildContext context) {
    final String description = ecoUnityPlainText(
      activity.shortDescription,
      maxLength: 140,
    );

    return Card(
      color: const Color(0xFFFFF8F1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: EcoUnityColors.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          AppRouter.navigate(
            context,
            'learningactivity',
            1,
            replaceRoute: false,
            data: activity,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Latest challenge',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: EcoUnityColors.warning,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                activity.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: EcoUnityColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (description.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: EcoUnityColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SdgBadge extends StatelessWidget {
  const _SdgBadge({required this.value});

  final int? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: EcoUnityColors.deepTeal,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value?.toString() ?? '-',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ModuleStatusChip extends StatelessWidget {
  const _ModuleStatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: EcoUnityColors.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DashboardErrorBanner extends StatelessWidget {
  const _DashboardErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDEA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EcoUnityColors.error),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: EcoUnityColors.error),
        ),
      ),
    );
  }
}

String _moduleDurationLabel(EcoUnitySdgModule module) {
  if (module.estimatedMinutes != null) {
    return '${module.estimatedMinutes} min module';
  }
  final int activityCount = module.activities.length;
  if (activityCount == 1) {
    return '1 activity';
  }
  return '$activityCount activities';
}
