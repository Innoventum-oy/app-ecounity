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
import '../../widgets/pathway_card.dart';
import '../video_list/video/components/video_card.dart';

class PathwaysScreen extends StatefulWidget {
  final int navIndex;
  const PathwaysScreen({super.key, required this.navIndex});

  @override
  PathwaysScreenState createState() => PathwaysScreenState();
}

// Create change listener for completed pathways (local storage changes)

class PathwaysScreenState extends State<PathwaysScreen> {
  FileStorage fileStorage = FileStorage();
  List<PathwayStatusItem>? completedPathways;

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
    });
    completedPathways = await EcoUnityStorage(
      fileStorage,
    ).getCompletedPathways();
    setState(() {});
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
      log('PathwaysScreen build');
    }
    String screenTitle = context.l10n.screenTitle_pathways;
    DataLoadingStatus loadingStatus = Provider.of<WebPageProvider>(
      context,
    ).loadingStatus;
    String? error;
    // if data is loaded, display the pathways
    if (loadingStatus == DataLoadingStatus.loaded) {
      List<WebPage>? pathways = Provider.of<WebPageProvider>(context).list;
      if (pathways != null) {
        List<WebPage> mainPathways = pathways
            .where((element) => element.isMainPathway)
            .toList();
        if (mainPathways.isNotEmpty) {
          // sort the main pathways by name
          mainPathways.sort((a, b) => a.pathwayName!.compareTo(b.pathwayName!));
          TabBar tabBar = TabBar(
            tabs: mainPathways.map((e) => Tab(text: e.title)).toList(),
          );
          TabBarView tabBarView = TabBarView(
            children: mainPathways.map((e) {
              List<WebPage> subPathways = pathways
                  .where((element) => element.parent == e.id)
                  .toList();
              // sort the subPathways by sortOrder
              subPathways.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
              core.WebPageList pageList = core.WebPageList(
                webPages: subPathways,
              );
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: subPathways.length,
                        itemBuilder: (context, index) {
                          // if the pathway is a video, show videoCard
                          if (subPathways[index].type == PathwayType.video) {
                            return videoCard(
                              context,
                              subPathways[index],
                              isPathwayCompleted(
                                subPathways[index],
                                completedPathways,
                              ),
                              widget.navIndex,
                              pathways: pageList,
                            );
                          }

                          return pathwayCard(
                            context,
                            subPathways[index],
                            isPathwayCompleted(
                              subPathways[index],
                              completedPathways,
                            ),
                            widget.navIndex,
                            pathways: pageList,
                          );
                        },
                        // If the list is empty, display a message
                      ),
                      if (subPathways.isEmpty)
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
          return DefaultTabController(
            length: mainPathways.length,
            child: ScreenScaffold(
              onRefresh: _refresh,
              title: screenTitle,
              navigationIndex: widget.navIndex,
              child: Column(
                children: [
                  tabBar,
                  Expanded(child: tabBarView),
                ],
              ),
            ),
          );
        } else {
          error = 'No pathways found';
        }
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
