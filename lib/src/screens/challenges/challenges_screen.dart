import 'package:core/core.dart' as core;

import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:ecounity/src/widgets/info_widget.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';

import '../../objects/pathway_status_item.dart';
import '../../util/ecounity_storage.dart';
import '../../util/settings.dart';
import '../../util/utils.dart';
import '../../widgets/pathway_card.dart';

class ChallengesScreen extends StatefulWidget {
  final int navIndex;
  const ChallengesScreen({super.key, required this.navIndex});

  @override
  ChallengesScreenState createState() => ChallengesScreenState();
}

// Create change listener for completed pathways (local storage changes)

class ChallengesScreenState extends State<ChallengesScreen> {
  core.FileStorage fileStorage = core.FileStorage();
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

  List<core.WebPage> pathways = [];
  void load() async {
    // Get all web pages that have a pagecategory set
    core.WebPageProvider webPageProvider = Provider.of<core.WebPageProvider>(
      context,
      listen: false,
    );

    webPageProvider.getItems(pathwayLoadParameters).then((value) {
      webPageProvider.loadingStatus = core.DataLoadingStatus.loaded;
    });
    completedPathways = await EcoUnityStorage(
      fileStorage,
    ).getCompletedPathways();
  }

  void _refresh() {
    // call the provider to refresh the data
    Provider.of<core.WebPageProvider>(context, listen: false).refresh();
  }
  // Mark a pathway as completed, stored in local storage

  @override
  Widget build(BuildContext context) {
    String screenTitle = context.l10n.screenTitle_challenges;

    core.DataLoadingStatus loadingStatus = Provider.of<core.WebPageProvider>(
      context,
    ).loadingStatus;
    String? error;
    // if data is loaded, display the pathways
    if (loadingStatus == core.DataLoadingStatus.loaded) {
      List<core.WebPage>? pathways = Provider.of<core.WebPageProvider>(
        context,
      ).list;
      if (pathways != null) {
        List<core.WebPage> mainPathways = pathways
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
              List<core.WebPage> subPathways = pathways
                  .where(
                    (element) =>
                        element.parent == e.id &&
                        (element.type == PathwayType.quiz ||
                            element.type == PathwayType.dragdrop),
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
                      // if no subpathways, display a message
                      if (subPathways.isEmpty)
                        InfoWidget(
                          title: context.l10n.noContentFound,
                          content: context.l10n.noChallengesFound,
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
