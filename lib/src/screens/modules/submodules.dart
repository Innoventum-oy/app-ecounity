import 'dart:developer';

import 'package:ecounity/src/objects/pathway.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:core/core.dart';
import 'package:provider/provider.dart';
import '../../objects/pathway_status_item.dart';
import '../../util/ecounity_storage.dart';
import '../../util/utils.dart';
import '../../widgets/screenscaffold.dart';
import 'package:ecounity/src/util/settings.dart';
import '../../widgets/submodule_card.dart';

class SubModulesView extends StatefulWidget {
  final int navIndex;
  final WebPage parent;
  const SubModulesView({
    required this.navIndex,
    super.key,
    required this.parent,
  });

  @override
  State<SubModulesView> createState() => SubModulesViewState();
}

class SubModulesViewState extends State<SubModulesView> {
  FileStorage fileStorage = FileStorage();
  List<PathwayStatusItem>? completedPathways;

  @override
  void initState() {
    // add listener to the file storage
    fileStorage.addListener(_fileStorageListener);
    super.initState();
    loadModules();
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

  @override
  void dispose() {
    // remove listener to the file storage
    fileStorage.removeListener(_fileStorageListener);
    super.dispose();
  }

  void loadModules() async {
    // Get all web pages that have a pagecategory set
    WebPageProvider webPageProvider = Provider.of<WebPageProvider>(
      context,
      listen: false,
    );

    webPageProvider.getItems(pathwayLoadParameters).then((value) {
      // TODO use different loading parameters than for pathways?
      if (kDebugMode) {
        log('${webPageProvider.list?.length} modules loaded');
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
    String screenTitle = context.l10n.screenTitle_modules;
    DataLoadingStatus loadingStatus = Provider.of<WebPageProvider>(
      context,
    ).loadingStatus;
    String? error;
    // if data is loaded, display the submodules
    if (loadingStatus == DataLoadingStatus.loaded) {
      List<WebPage>? modules = Provider.of<WebPageProvider>(context).list;
      if (modules != null) {
        List<WebPage> subModules = modules
            .where((element) => (element.parent == widget.parent.id))
            .toList();
        if (subModules.isNotEmpty) {
          // sort the sub modules by name // TODO sort by some other criteria?
          subModules.sort((a, b) {
            if (a.pathwayName == null || b.pathwayName == null) {
              return 0;
            } else {
              return a.pathwayName!.compareTo(b.pathwayName!);
            }
          });

          return ScreenScaffold(
            onRefresh: _refresh,
            title: screenTitle,
            navigationIndex: widget.navIndex,
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.8,
              width: MediaQuery.sizeOf(context).width,
              child: ListView(
                children: subModules.map((e) {
                  return subModuleCard(
                    context,
                    e,
                    isPathwayCompleted(e, completedPathways),
                    widget.navIndex,
                  );
                }).toList(),
              ),
            ),
          );
        } else {
          error = context.l10n.no_contents_found;
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
