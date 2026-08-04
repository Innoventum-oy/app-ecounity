import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations_extension.dart';
import '../../../objects/pathway.dart';
import '../../../objects/pathway_status_item.dart';
import '../../../util/ecounity_storage.dart';
import '../../../util/router.dart';
import '../../../util/settings.dart';
import '../../../util/utils.dart';
import 'dashboard_loading_indicator.dart';

class DashboardProgressCard extends StatefulWidget {
  const DashboardProgressCard({super.key});

  @override
  State<DashboardProgressCard> createState() => _DashboardProgressCardState();
}

class _DashboardProgressCardState extends State<DashboardProgressCard> {
  FileStorage? fileStorage;
  int completedModules = 0;
  int totalModules = 0;
  int completedPages = 0;
  int totalPages = 0;
  bool isLoaded = false;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final FileStorage nextFileStorage = Provider.of<FileStorage>(
      context,
      listen: false,
    );

    if (!identical(fileStorage, nextFileStorage)) {
      fileStorage?.removeListener(_handleStorageUpdated);
      fileStorage = nextFileStorage;
      fileStorage?.addListener(_handleStorageUpdated);
    }

    if (!isLoading && !isLoaded) {
      loadProgress();
    }
  }

  @override
  void dispose() {
    fileStorage?.removeListener(_handleStorageUpdated);
    super.dispose();
  }

  Future<void> _handleStorageUpdated() async {
    await loadProgress();
  }

  Future<void> loadProgress() async {
    if (isLoading || fileStorage == null) {
      return;
    }

    isLoading = true;

    final String currentLanguage = Localizations.localeOf(context).languageCode;
    final WebPageProvider webPageProvider = Provider.of<WebPageProvider>(
      context,
      listen: false,
    );
    await webPageProvider.getItems(pathwayLoadParameters);

    List<WebPage> modules = webPageProvider.list ?? [];
    modules = modules.where((item) {
      return item.contentlanguages == null ||
          item.contentlanguages!.isEmpty ||
          item.contentlanguages!.contains(currentLanguage);
    }).toList();

    final List<WebPage> mainModules = modules
        .where((element) => element.isMainModule)
        .toList();
    final List<WebPage> moduleCards = [];
    final List<WebPage> modulePages = [];

    for (final WebPage mainModule in mainModules) {
      final List<WebPage> subModules = modules
          .where((element) => element.parent == mainModule.id)
          .toList();
      moduleCards.addAll(subModules);

      for (final WebPage subModule in subModules) {
        modulePages.addAll(
          modules.where((element) => element.parent == subModule.id),
        );
      }
    }

    final List<PathwayStatusItem>? completedPathways = await EcoUnityStorage(
      fileStorage!,
    ).getCompletedPathways();

    final int completedCount = moduleCards
        .where((item) => isPathwayCompleted(item, completedPathways))
        .length;
    final int completedPageCount = modulePages
        .where((item) => isPathwayCompleted(item, completedPathways))
        .length;

    if (!mounted) {
      isLoading = false;
      return;
    }

    setState(() {
      completedModules = completedCount;
      totalModules = moduleCards.length;
      completedPages = completedPageCount;
      totalPages = modulePages.length;
      isLoaded = true;
    });

    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final double progress = totalPages == 0 ? 0 : completedPages / totalPages;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: () {
          AppRouter.navigate(context, 'modules', 1, replaceRoute: false);
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 220),
            child: isLoaded
                ? Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 18,
                          runSpacing: 18,
                          children: [
                            CircularPercentIndicator(
                              radius: 48,
                              lineWidth: 10,
                              percent: progress.clamp(0, 1),
                              circularStrokeCap: CircularStrokeCap.round,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              progressColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              center: Text(
                                '${(progress * 100).round()}%',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  context.l10n.current_progress,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.l10n.modules_completion_summary(
                                    completedModules,
                                    totalModules,
                                  ),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  context.l10n
                                      .learning_contents_completion_summary(
                                        completedPages,
                                        totalPages,
                                      ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const Center(child: DashboardLoadingIndicator()),
          ),
        ),
      ),
    );
  }
}
