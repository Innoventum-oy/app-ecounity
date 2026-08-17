import 'package:core/core.dart' as core;
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_provider.dart';
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
          const SizedBox(height: 16),
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
    return await provider.loadModule(moduleId, language: language) ??
        widget.module;
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
              Text(module.introduction),
            ],
            if (module.learningObjective.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                module.learningObjective,
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

String _activityLabel(EcoUnityLearningActivity activity) {
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
    if (activity.shortDescription.isNotEmpty) activity.shortDescription,
  ];
  return parts.join(' · ');
}
