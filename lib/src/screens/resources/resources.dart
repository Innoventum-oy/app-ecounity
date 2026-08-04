import 'dart:developer';
import 'package:core/core.dart';
import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:ecounity/src/util/ecounity_storage.dart';
import 'package:ecounity/src/widgets/info_widget.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';

import '../../objects/pathway_status_item.dart';
import '../../util/settings.dart';
import '../../util/utils.dart';
import '../../widgets/resource_card.dart';
import '../video_list/video/components/video_card.dart';

class ResourcesView extends StatefulWidget {
  final int navIndex;
  final WebPage? webPage;
  const ResourcesView({super.key, required this.navIndex, this.webPage});

  @override
  ResourcesViewState createState() => ResourcesViewState();
}

// Create change listener for completed pathways (local storage changes)

class ResourcesViewState extends State<ResourcesView>
    with TickerProviderStateMixin {
  FileStorage fileStorage = FileStorage();
  List<PathwayStatusItem>? completedPathways;
  late TabController controller;
  List<WebPage> resources = <WebPage>[];
  List<WebPage> mainResources = <WebPage>[];
  bool isLoaded = false;

  @override
  void initState() {
    // add listener to the file storage
    fileStorage.addListener(_fileStorageListener);
    super.initState();
    load();
  }

  @override
  void dispose() {
    // remove listener to the file storage
    fileStorage.removeListener(_fileStorageListener);
    controller.dispose();
    super.dispose();
  }

  void _fileStorageListener() async {
    // get the completed pathways from local storage
    final newCompletedPathways = await EcoUnityStorage(
      fileStorage,
    ).getCompletedPathways();
    if (!mounted ||
        EcoUnityStorage.completedPathwaysEqual(
          newCompletedPathways,
          completedPathways,
        )) {
      return;
    }
    completedPathways = newCompletedPathways;
    setState(() {
      // update the state
    });
  }

  List<WebPage> pathways = [];
  void load() async {
    // Get all web pages that have a pagecategory set
    WebPageProvider webPageProvider = Provider.of<WebPageProvider>(
      context,
      listen: false,
    );

    webPageProvider.getItems(pathwayLoadParameters).then((value) {
      if (kDebugMode) {
        log('${webPageProvider.list?.length} pages loaded');
      }
      webPageProvider.loadingStatus = DataLoadingStatus.loaded;

      setResources(webPageProvider.list);
      initTabBar();
    });
    completedPathways = await EcoUnityStorage(
      fileStorage,
    ).getCompletedPathways();
    setState(() {});
  }

  void setResources(List<WebPage>? resourceList) {
    if (resourceList!.isNotEmpty) {
      // Store all resources
      resources = resourceList;

      // Find the main resources
      mainResources = resourceList
          .where((element) => element.isMainResource)
          .toList();

      for (var i = 0; i < resourceList.length; i++) {
        var resource = resourceList[i];
        log('Pathway name: ${resource.pathwayName}');
      }

      if (mainResources.isNotEmpty) {
        // sort the main resources by name
        mainResources.sort((a, b) {
          if (a.pathwayName == null || b.pathwayName == null) {
            return 0;
          } else {
            return a.pathwayName!.compareTo(b.pathwayName!);
          }
        });
      }
    }
  }

  List<WebPage> getSubResources(WebPage mainResource) {
    List<WebPage> subResources = resources
        .where((element) => element.parent == mainResource.id)
        .toList();
    if (subResources.isNotEmpty) {
      // sort the subResources by sortOrder
      subResources.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }
    return subResources;
  }

  void initTabBar() {
    // Set the initial index (tab)
    int initialIndex = 0;
    if (widget.webPage != null) {
      int tabIndex = mainResources.indexWhere(
        (el) => el.id == widget.webPage?.id,
      );
      if (tabIndex >= 0) {
        initialIndex = tabIndex;
      }
    }

    // Initialize the controller only once
    controller = TabController(
      length: mainResources.length,
      initialIndex: initialIndex,
      vsync: this,
    );

    // Ready to display resources
    setState(() {
      isLoaded = true;
    });
  }

  Widget pageGrid(List<WebPage> pages) {
    return GridView.builder(
      itemCount: pages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(pages[index].title),
          subtitle: Text(pages[index].getValue('textcontents')!),
        );
      },
    );
  }

  void _refresh() {
    // call the provider to refresh the data
    Provider.of<WebPageProvider>(context, listen: false).refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      log('ResourcesScreen build');
    }
    String screenTitle = context.l10n.screenTitle_resources;
    String? error;
    // if data is loaded, display the resources
    if (isLoaded) {
      if (mainResources.isNotEmpty) {
        TabBar tabBar = TabBar(
          tabs: mainResources.map((e) => Tab(text: e.title)).toList(),
          controller: controller,
        );

        TabBarView tabBarView = TabBarView(
          controller: controller,
          children: mainResources.map((e) {
            List<WebPage> subResources = getSubResources(e);
            // sort the subResources by sortOrder
            subResources.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
            core.WebPageList pageList = core.WebPageList(
              webPages: subResources,
            );
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: subResources.length,
                      itemBuilder: (context, index) {
                        // if the pathway is a video, show videoCard
                        if (subResources[index].type == PathwayType.video) {
                          return videoCard(
                            context,
                            subResources[index],
                            isPathwayCompleted(
                              subResources[index],
                              completedPathways,
                            ),
                            widget.navIndex,
                            pathways: pageList,
                          );
                        }

                        return resourceCard(
                          context,
                          subResources[index],
                          isPathwayCompleted(
                            subResources[index],
                            completedPathways,
                          ),
                          widget.navIndex,
                          resources: pageList,
                        );
                      },

                      // If the list is empty, display a message
                    ),
                    if (subResources.isEmpty)
                      InfoWidget(
                        title: context.l10n.error(''),
                        content: context.l10n.noContentFound,
                        style: InfoWidgetStyle.warning,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        );

        return ScreenScaffold(
          key: const ValueKey('screenshot-resources-list-screen'),
          onRefresh: _refresh,
          title: screenTitle,
          navigationIndex: widget.navIndex,
          child: Column(
            children: [
              tabBar,
              Expanded(
                child: KeyedSubtree(
                  key: const ValueKey('screenshot-resources-list'),
                  child: tabBarView,
                ),
              ),
            ],
          ),
        );
      } else {
        error = context.l10n.no_resources_found;
      }
    }
    return ScreenScaffold(
      onRefresh: _refresh,
      title: screenTitle,
      navigationIndex: widget.navIndex,
      child: Center(
        child: error != null ? Text(error) : const CircularProgressIndicator(),
      ),
    );
  }
}
