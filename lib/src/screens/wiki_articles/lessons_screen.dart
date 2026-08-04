import 'package:core/core.dart';
import 'package:core/core.dart' as core;
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';

import '../../objects/pathway_status_item.dart';
import '../../util/ecounity_storage.dart' as ecounity_storage;
import '../../util/settings.dart';
import '../../util/utils.dart';
import '../../widgets/info_widget.dart';
import '../../widgets/pathway_card.dart';

class WikiArticlesScreen extends StatefulWidget {
  final int navIndex;
  const WikiArticlesScreen({super.key, required this.navIndex});

  @override
  WikiArticlesScreenState createState() => WikiArticlesScreenState();
}

// Create change listener for completed pathways (local storage changes)

class WikiArticlesScreenState extends State<WikiArticlesScreen> {
  FileStorage fileStorage = FileStorage();
  List<PathwayStatusItem>? completedPathways;

  @override
  void initState() {
    getCompletedPathways(fileStorage);
    // add listener to the file storage
    fileStorage.addListener(() {
      getCompletedPathways(fileStorage);
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
    load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getCompletedPathways(FileStorage storage) async {
    completedPathways = await ecounity_storage.EcoUnityStorage(
      storage,
    ).getCompletedPathways();
    if (mounted) {
      setState(() {});
    }
  }

  List<WebPage> pathways = [];
  void load() async {
    // Get all web pages that have a pagecategory set
    WebPageProvider webPageProvider = Provider.of<WebPageProvider>(
      context,
      listen: false,
    );
    webPageProvider.getItems(pathwayLoadParameters).then((value) {
      webPageProvider.loadingStatus = DataLoadingStatus.loaded;
    });
  }

  void _refresh() {
    // call the provider to refresh the data
    Provider.of<WebPageProvider>(context, listen: false).refresh();
  }

  @override
  Widget build(BuildContext context) {
    String screenTitle = context.l10n.screenTitle_lessons;

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
                  .where(
                    (element) =>
                        element.parent == e.id &&
                        element.type == PathwayType.wiki,
                  )
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
                      ),
                      if (subPathways.isEmpty)
                        InfoWidget(
                          title: context.l10n.noContentFound,
                          content: context.l10n.noLessonsFound,
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
