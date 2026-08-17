import 'package:core/core.dart' as core;
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_provider.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:ecounity/src/util/router.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return ScreenScaffold(
      title: 'Modules',
      navigationIndex: widget.navIndex,
      onRefresh: _loadModules,
      child: Consumer<EcoUnityLearningProvider>(
        builder:
            (
              BuildContext context,
              EcoUnityLearningProvider provider,
              Widget? child,
            ) {
              if (provider.loadingStatus == core.DataLoadingStatus.loading &&
                  provider.modules.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.modules.isEmpty) {
                return Center(
                  child: Text(provider.error ?? 'No modules available'),
                );
              }

              return SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.78,
                child: ListView.separated(
                  key: const ValueKey<String>('learning-modules-list'),
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.modules.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 12);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    final EcoUnitySdgModule module = provider.modules[index];
                    return _ModuleCard(
                      module: module,
                      completionRatio: module.completionRatio(
                        provider.progressEntries,
                      ),
                      onTap: () {
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
              );
            },
      ),
    );
  }

  Future<void> _loadModules() async {
    final EcoUnityLearningProvider provider =
        Provider.of<EcoUnityLearningProvider>(context, listen: false);
    final String language = await core.Settings().getLanguage() ?? 'en';
    try {
      await provider.loadModules(language: language, reload: true);
      await provider.loadProgress(language: language);
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unable to load EcoUnity learning modules: $exception');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.completionRatio,
    required this.onTap,
  });

  final EcoUnitySdgModule module;
  final double completionRatio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final int activityCount = module.activities.length;
    final String activityLabel = activityCount == 1 ? 'activity' : 'activities';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _SdgNumberBadge(sdgNumber: module.sdgNumber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          module.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: EcoUnityColors.deepTeal,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$activityCount $activityLabel',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: EcoUnityColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              if (module.introduction.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  module.introduction,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: completionRatio.clamp(0, 1),
                minHeight: 6,
                borderRadius: BorderRadius.circular(999),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SdgNumberBadge extends StatelessWidget {
  const _SdgNumberBadge({required this.sdgNumber});

  final int? sdgNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: EcoUnityColors.deepTeal,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        sdgNumber?.toString() ?? '-',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
