import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations_extension.dart';
import '../../../objects/pathway.dart';
import '../../../objects/pathway_status_item.dart';
import '../../../providers/selected_pathway_notifier.dart';
import '../../../util/ecounity_storage.dart';
import '../../../util/image_from_url.dart';
import '../../../util/navigation_item.dart';
import '../../../util/router.dart';
import '../../../util/settings.dart';
import 'dashboard_loading_indicator.dart';

class NextPathway extends StatefulWidget {
  const NextPathway({super.key});

  @override
  NextPathwayState createState() => NextPathwayState();
}

class NextPathwayState extends State<NextPathway> {
  List<WebPage> subModules = []; // Module index
  List<WebPage> resources =
      []; // Top-level pages for case studies and video interviews
  List<WebPage> pathwayOptions =
      []; // Content pages that can be displayed in this widget
  List<WebPage> sortedPathwayOptions = []; // Sorted content pages

  FileStorage? fileStorage;
  late SelectedPathwayNotifier selectedPathwayNotifier;
  bool hasResolvedSelection = false;
  bool _isLoadingContent = false;
  bool _hasLoadedCandidates = false;
  String _currentLocaleLanguage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String currentLocaleLanguage = Localizations.localeOf(
      context,
    ).languageCode;
    selectedPathwayNotifier = Provider.of<SelectedPathwayNotifier>(
      context,
      listen: false,
    );

    final FileStorage nextFileStorage = Provider.of<FileStorage>(
      context,
      listen: false,
    );

    if (!identical(fileStorage, nextFileStorage)) {
      fileStorage?.removeListener(_handleStorageUpdated);
      fileStorage = nextFileStorage;
      fileStorage?.addListener(_handleStorageUpdated);
    }

    final bool localeChanged =
        currentLocaleLanguage.isNotEmpty &&
        _currentLocaleLanguage != currentLocaleLanguage;

    if (!_isLoadingContent &&
        (!_hasLoadedCandidates ||
            localeChanged ||
            sortedPathwayOptions.isEmpty)) {
      _currentLocaleLanguage = currentLocaleLanguage;
      load();
      return;
    }

    if (localeChanged) {
      _currentLocaleLanguage = currentLocaleLanguage;
    }
  }

  @override
  void dispose() {
    fileStorage?.removeListener(_handleStorageUpdated);
    super.dispose();
  }

  void _handleStorageUpdated() {
    if (!_hasLoadedCandidates || _isLoadingContent) {
      return;
    }
    refreshSelectedItem();
  }

  Future<void> load() async {
    _isLoadingContent = true;
    _hasLoadedCandidates = false;
    if (mounted) {
      setState(() {
        hasResolvedSelection = false;
      });
    }
    await loadContentPages();
    _hasLoadedCandidates = true;
    await refreshSelectedItem();
    _isLoadingContent = false;
  }

  // Sort module pages in an alphabetical order (as in the module content page)
  int compareModules(WebPage a, WebPage b) {
    if (a.pathwayName == null || b.pathwayName == null) {
      return 0;
    } else {
      return a.pathwayName!.compareTo(b.pathwayName!);
    }
  }

  // Sort resource pages by orderno (as in the resources page)
  int compareResources(WebPage a, WebPage b) {
    return a.sortOrder.compareTo(b.sortOrder);
  }

  // Load content pages only once
  Future<void> loadContentPages() async {
    subModules = [];
    resources = [];
    pathwayOptions = [];
    sortedPathwayOptions = [];

    WebPageProvider webPageProvider = Provider.of<WebPageProvider>(
      context,
      listen: false,
    );
    await webPageProvider.getItems(pathwayLoadParameters);
    webPageProvider.loadingStatus = DataLoadingStatus.loaded;

    List<WebPage>? allPages = webPageProvider.list;
    if (allPages != null && allPages.isNotEmpty) {
      String? currentLanguage = mounted
          ? Localizations.localeOf(context).languageCode
          : null;

      if (currentLanguage != null) {
        for (WebPage page in allPages) {
          if (!_isAvailableInLanguage(page, currentLanguage)) {
            continue;
          }

          // Exclude pages that are not available in the selected language
          // Place pages in their respective categories
          if (page.isSubModule) {
            subModules.add(page);
          } else if (page.isMainResource) {
            resources.add(page);
          } else if (!page.isMainPathway) {
            pathwayOptions.add(page);
          }
        }
      }

      // Add all modules
      if (subModules.isNotEmpty) {
        subModules.sort(compareModules);

        for (WebPage module in subModules) {
          List<WebPage> modulePages = pathwayOptions
              .where((item) => item.parent == module.id)
              .toList();

          if (modulePages.isNotEmpty) {
            modulePages.sort(compareModules);
            sortedPathwayOptions.addAll(modulePages);
          }
        }
      }

      // Add all resources
      if (resources.isNotEmpty) {
        resources.sort(compareResources);

        for (WebPage resourceCategory in resources) {
          List<WebPage> resourcePages = pathwayOptions
              .where((item) => item.parent == resourceCategory.id)
              .toList();

          if (resourcePages.isNotEmpty) {
            resourcePages.sort(compareResources);
            sortedPathwayOptions.addAll(resourcePages);
          }
        }
      }
    }
  }

  bool _isAvailableInLanguage(WebPage page, String currentLanguage) {
    final String normalizedLanguage = _normalizeLanguageCode(currentLanguage);
    if (normalizedLanguage.isEmpty) {
      return true;
    }

    final List<String> availableLanguages = _normalizeLanguageList(
      page.getValue('contentlanguages'),
    );
    if (availableLanguages.isNotEmpty) {
      return availableLanguages.contains(normalizedLanguage);
    }

    final String legacyLanguage = _extractLanguageCode(
      page.getValue('language'),
    );
    if (legacyLanguage.isNotEmpty) {
      return legacyLanguage == normalizedLanguage;
    }

    return true;
  }

  List<String> _normalizeLanguageList(dynamic raw) {
    if (raw is String) {
      return raw
          .replaceAll(' ', '')
          .split(',')
          .map(_normalizeLanguageCode)
          .where((lang) => lang.isNotEmpty)
          .toList();
    }
    if (raw is List) {
      return raw
          .whereType<dynamic>()
          .map((item) => '$item')
          .map(_normalizeLanguageCode)
          .where((lang) => lang.isNotEmpty)
          .toList();
    }
    return [];
  }

  String _extractLanguageCode(dynamic value) {
    if (value == null) {
      return '';
    }

    return _normalizeLanguageCode(value.toString());
  }

  String _normalizeLanguageCode(String value) {
    return value.split(RegExp(r'[_-]')).first.toLowerCase().trim();
  }

  Future<void> refreshSelectedItem() async {
    if (fileStorage == null || !_hasLoadedCandidates) {
      return;
    }

    if (sortedPathwayOptions.isEmpty) {
      selectedPathwayNotifier.select(null);
      if (mounted && !hasResolvedSelection) {
        setState(() {
          hasResolvedSelection = true;
        });
      }
      return;
    }

    final List<PathwayStatusItem>? statusItems = await loadStatusItems();
    selectedPathwayNotifier.reconcileSelection(
      sortedPathwayOptions,
      statusItems,
    );

    if (mounted && !hasResolvedSelection) {
      setState(() {
        hasResolvedSelection = true;
      });
    }
  }

  Future<List<PathwayStatusItem>?> loadStatusItems() async {
    return fileStorage != null
        ? EcoUnityStorage(fileStorage!).getCompletedPathways()
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: hasResolvedSelection
          ? ValueListenableBuilder<WebPage?>(
              valueListenable: selectedPathwayNotifier,
              builder: (context, selectedItem, child) {
                if (selectedItem != null) {
                  NavigationItem? navItem =
                      subModules.any((item) => selectedItem.parent == item.id)
                      ? navItems.firstWhereOrNull(
                          (item) => item.view == 'modules',
                        )
                      : navItems.firstWhereOrNull(
                              (item) => item.view == 'resources',
                            ) ??
                            navItems.firstWhereOrNull(
                              (item) => item.view == 'modules',
                            );

                  return InkWell(
                    key: const ValueKey('screenshot-next-suggestion-card'),
                    onTap: () {
                      AppRouter.navigate(
                        context,
                        selectedItem.type.name,
                        navItem?.navigationIndex ?? 1,
                        replaceRoute: false,
                        data: selectedItem,
                      );
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 220),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: FutureBuilder<String?>(
                              future: selectedItem.thumbnailImageUrl,
                              builder: (context, snapshot) {
                                final String? imageUrl = snapshot.data;

                                if (imageUrl != null && imageUrl.isNotEmpty) {
                                  return ImageFromUrl.get(
                                    imageUrl,
                                    fillContainer: true,
                                    loadedKey: const ValueKey(
                                      'screenshot-next-suggestion-cover-loaded',
                                    ),
                                  );
                                }

                                return Container(
                                  width: double.infinity,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                  child: Center(
                                    child: Icon(
                                      Icons.auto_stories_rounded,
                                      size: 46,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.next_suggestion,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  selectedItem.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(18),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 220),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.celebration_outlined,
                          size: 42,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          context.l10n.next_suggestion,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.congratulations,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.you_have_completed_all_learning_contents,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(child: DashboardLoadingIndicator()),
    );
  }
}
