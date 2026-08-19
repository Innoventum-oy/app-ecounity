import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:ecounity/src/analytics/ecounity_analytics_service.dart';
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_provider.dart';
import 'package:ecounity/src/learning/ecounity_learning_text_utils.dart';
import 'package:ecounity/src/learning/widgets/ecounity_content_review_panel.dart';
import 'package:ecounity/src/learning/widgets/ecounity_learning_copy.dart';
import 'package:ecounity/src/learning/widgets/ecounity_media_image.dart';
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
              title: module?.title ?? 'Module',
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
      return Center(child: Text('Unable to load module: ${snapshot.error}'));
    }
    if (module == null) {
      return const Center(child: Text('Module not found'));
    }

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.78,
      child: ListView(
        key: const ValueKey<String>('learning-module-detail-list'),
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _ModuleHeader(module: module),
          EcoUnityContentReviewPanel(
            status: module.contentStatus,
            onStatusChanged: (EcoUnityContentStatus status) {
              return _updateModuleContentStatus(module, status);
            },
          ),
          const SizedBox(height: 16),
          if (module.activities.isEmpty)
            const _EmptyActivitiesMessage()
          else
            for (final EcoUnityLearningActivity activity in module.activities)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ActivityCard(
                  activity: activity,
                  onTap: () {
                    AppRouter.navigate(
                      context,
                      'learningactivity',
                      widget.navIndex,
                      replaceRoute: false,
                      data: activity,
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
    final String language = await core.Settings().getLanguage() ?? 'en';
    final EcoUnitySdgModule? module =
        await provider.loadModule(moduleId, language: language) ??
        widget.module;
    if (module != null) {
      _trackModuleOpened(module, language);
    }
    return module;
  }

  void _trackModuleOpened(EcoUnitySdgModule module, String language) {
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

  Future<void> _updateModuleContentStatus(
    EcoUnitySdgModule module,
    EcoUnityContentStatus status,
  ) async {
    final int? moduleId = module.id;
    if (moduleId == null) {
      throw StateError('Module id is missing');
    }

    final EcoUnityLearningProvider provider =
        Provider.of<EcoUnityLearningProvider>(context, listen: false);
    final String language = await core.Settings().getLanguage() ?? 'en';
    final EcoUnitySdgModule? updatedModule = await provider
        .updateModuleContentStatus(
          moduleId: moduleId,
          status: status,
          language: language,
        );

    if (mounted && updatedModule != null) {
      setState(() {
        _future = Future<EcoUnitySdgModule?>.value(updatedModule);
      });
    }
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
                'Activities will appear here when this module is ready.',
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
  const _ActivityCard({required this.activity, required this.onTap});

  final EcoUnityLearningActivity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        minVerticalPadding: 12,
        leading: CircleAvatar(
          backgroundColor: EcoUnityColors.surfaceContainer,
          foregroundColor: EcoUnityColors.deepTeal,
          child: Icon(_activityIcon(activity.type)),
        ),
        title: Text(
          activity.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _activityLabel(activity),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
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

EcoUnityAnalyticsService? _analyticsOf(BuildContext context) {
  try {
    return Provider.of<EcoUnityAnalyticsService>(context, listen: false);
  } catch (_) {
    return null;
  }
}

String _activityLabel(EcoUnityLearningActivity activity) {
  final String description = ecoUnityPlainText(
    activity.shortDescription,
    maxLength: 90,
  );
  final List<String> parts = <String>[
    switch (activity.type) {
      EcoUnityActivityType.comic => 'Comic',
      EcoUnityActivityType.mlr => 'Micro-learning',
      EcoUnityActivityType.quiz => 'Quiz',
      EcoUnityActivityType.reflection => 'Reflection',
      EcoUnityActivityType.challenge => 'Challenge',
      EcoUnityActivityType.unknown => 'Activity',
    },
    if (activity.estimatedMinutes != null) '${activity.estimatedMinutes} min',
    if (description.isNotEmpty) description,
  ];
  return parts.join(' · ');
}
