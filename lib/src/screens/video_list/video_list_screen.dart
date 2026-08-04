import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:ecounity/src/screens/video_list/video/components/video_card.dart';
import 'package:ecounity/src/widgets/info_widget.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';
import '../../objects/pathway_status_item.dart';
import '../../util/ecounity_storage.dart';
import '../../util/settings.dart';
import '../../util/utils.dart';

class VideoListScreen extends StatefulWidget {
  final int navIndex;
  const VideoListScreen({super.key, required this.navIndex});

  @override
  VideoListScreenState createState() => VideoListScreenState();
}

// Create change listener for completed pathways (local storage changes)

class VideoListScreenState extends State<VideoListScreen> {
  FileStorage fileStorage = FileStorage();
  List<PathwayStatusItem>? completedPathways;

  @override
  void initState() {
    // add listener to the file storage
    fileStorage.addListener(() async {
      if (kDebugMode || kProfileMode) {
        debugPrint('Storage updated, refreshing pathwayscreen');
      }
      completedPathways = await EcoUnityStorage(
        fileStorage,
      ).getCompletedPathways();
    });
    super.initState();
    load();
  }

  @override
  void dispose() {
    // remove the listener
    fileStorage.removeListener(() {
      EcoUnityStorage(fileStorage).getCompletedPathways();
    });
    super.dispose();
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
    completedPathways = await EcoUnityStorage(
      fileStorage,
    ).getCompletedPathways();
  }

  void _refresh() {
    // call the provider to refresh the data
    Provider.of<WebPageProvider>(context, listen: false).refresh();
  }
  // Mark a pathway as completed, stored in local storage

  @override
  Widget build(BuildContext context) {
    String screenTitle = context.l10n.screenTitle_videos;
    DataLoadingStatus loadingStatus = Provider.of<WebPageProvider>(
      context,
    ).loadingStatus;
    String? error;
    // if data is loaded, display the pathways
    if (loadingStatus == DataLoadingStatus.loaded) {
      List<WebPage>? pathways = Provider.of<WebPageProvider>(context).list;
      if (pathways != null) {
        List<WebPage> subPathways = pathways
            .where((element) => element.type == PathwayType.video)
            .toList();
        // sort the subPathways by sortOrder
        subPathways.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        WebPageList pageList = WebPageList(webPages: subPathways);
        Widget content = SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subPathways.length,
                  itemBuilder: (context, index) {
                    return videoCard(
                      context,
                      subPathways[index],
                      isPathwayCompleted(subPathways[index], completedPathways),
                      widget.navIndex,
                      pathways: pageList,
                    );
                  },
                ),
                // if no subpathways, display a message
                if (subPathways.isEmpty)
                  InfoWidget(
                    title: context.l10n.noContentFound,
                    content: context.l10n.noVideosFound,
                    style: InfoWidgetStyle.warning,
                  ),
              ],
            ),
          ),
        );

        return ScreenScaffold(
          onRefresh: _refresh,
          title: screenTitle,
          navigationIndex: widget.navIndex,
          child: content,
        );
      } else {
        error = 'No pathways found';
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
