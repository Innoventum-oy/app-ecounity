import 'dart:developer';

import 'package:ecounity/src/objects/pathway.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:core/core.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/util/core_compat.dart';
import '../../providers/selected_pathway_notifier.dart';
import '../../objects/pathway_status_item.dart';
import '../../util/ecounity_storage.dart';
import '../../util/image_from_url.dart';
import '../../util/router.dart';
import '../../widgets/screenscaffold.dart';
import 'package:ecounity/src/util/settings.dart';

class ModulesView extends StatefulWidget {
  final int navIndex;
  const ModulesView({required this.navIndex, super.key});

  @override
  ModulesViewState createState() => ModulesViewState();
}

class ModulesViewState extends State<ModulesView> {
  FileStorage fileStorage = FileStorage();
  List<PathwayStatusItem>? completedPathways;
  Map<int, ImageObject> thumbnails = <int, ImageObject>{};

  @override
  void initState() {
    // add listener to the file storage
    fileStorage.addListener(_fileStorageListener);
    super.initState();
    loadModules();
  }

  void _fileStorageListener() async {
    // get the completed pathways from local storage
    List<PathwayStatusItem>? newCompletedPathways = await EcoUnityStorage(
      fileStorage,
    ).getCompletedPathways();
    if (mounted &&
        !EcoUnityStorage.completedPathwaysEqual(
          newCompletedPathways,
          completedPathways,
        )) {
      completedPathways = newCompletedPathways;
      setState(() {
        // update the state only when data changes
      });
    }
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

      List<WebPage>? modules = webPageProvider.list;

      if (modules != null && modules.isNotEmpty) {
        // Load thumbnail images only once
        for (var i = 0; i < modules.length; i++) {
          int? moduleid = modules[i].id is int ? modules[i].id : null;
          if (moduleid != null) {
            modules[i].thumbnailImage.then((value) {
              if (value != null && mounted) {
                thumbnails[moduleid] = value;
                setState(() {
                  // Update thumbnails
                });
              }
            });
          }
        }
      }
    });
    completedPathways = await EcoUnityStorage(
      fileStorage,
    ).getCompletedPathways();
    // Don't call setState here, let the provider trigger the rebuild
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

  int _compareModuleContent(WebPage a, WebPage b) {
    if (a.pathwayName == null || b.pathwayName == null) {
      return 0;
    }
    return a.pathwayName!.compareTo(b.pathwayName!);
  }

  bool _isPathwayCompleted(
    int? pathwayId,
    List<PathwayStatusItem>? completedPathways,
  ) {
    if (pathwayId == null || completedPathways == null) {
      return false;
    }
    return completedPathways.any(
      (element) =>
          element.id == pathwayId && element.status == PathwayStatus.completed,
    );
  }

  bool _isModuleCompleted(
    WebPage module,
    List<WebPage> modules,
    List<PathwayStatusItem>? completedPathways,
  ) {
    final List<WebPage> moduleContents = modules
        .where((element) => element.parent == module.id)
        .toList();

    if (moduleContents.isEmpty) {
      return _isPathwayCompleted(module.id, completedPathways);
    }

    for (final content in moduleContents) {
      if (!_isPathwayCompleted(content.id, completedPathways)) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      log('ModulesView build');
    }
    String screenTitle = context.l10n.screenTitle_modules;
    // Use Selector to only rebuild when loadingStatus changes
    return Selector<WebPageProvider, DataLoadingStatus>(
      selector: (_, provider) => provider.loadingStatus,
      builder: (context, loadingStatus, child) {
        String? error;
        // if data is loaded, display the pathways
        if (loadingStatus == DataLoadingStatus.loaded) {
          List<WebPage>? modules = Provider.of<WebPageProvider>(
            context,
            listen: false,
          ).list;

          if (modules != null && modules.isNotEmpty) {
            // Filter modules by contentlanguages attribute
            String currentLanguage = Localizations.localeOf(
              context,
            ).languageCode;
            modules = modules.where((item) {
              return item.contentLanguagesList.isEmpty ||
                  item.contentLanguagesList.contains(currentLanguage);
            }).toList();
          }

          if (modules != null) {
            List<WebPage> mainModules = modules
                .where((element) => element.isMainModule)
                .toList();
            if (mainModules.isNotEmpty) {
              // sort the main modules by name
              mainModules.sort((a, b) {
                if (a.pathwayName == null || b.pathwayName == null) {
                  return 0;
                } else {
                  return a.pathwayName!.compareTo(b.pathwayName!);
                }
              });

              List<WebPage> modulelist = <WebPage>[];

              for (var value in mainModules) {
                List<WebPage> subModules = modules
                    .where((element) => element.parent == value.id)
                    .toList();
                // sort the subPathways by sortOrder
                subModules.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                modulelist.addAll(subModules);
              }

              List<Widget> itemlist = <Widget>[];

              if (modulelist.isNotEmpty) {
                for (var value in modulelist) {
                  String? imageurl = thumbnails[value.id]?.imageUrl;
                  final bool moduleCompleted = _isModuleCompleted(
                    value,
                    modules,
                    completedPathways,
                  );

                  itemlist.add(
                    GestureDetector(
                      onTap: () async {
                        final List<WebPage> subModuleContents =
                            modules!
                                .where((element) => element.parent == value.id)
                                .toList()
                              ..sort(_compareModuleContent);

                        Provider.of<SelectedPathwayNotifier>(
                          context,
                          listen: false,
                        ).selectFirstIncomplete(
                          subModuleContents,
                          completedPathways,
                        );

                        AppRouter.navigate(
                          context,
                          'submodules',
                          widget.navIndex,
                          replaceRoute: false,
                          data: value,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 25, bottom: 25),
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Theme.of(context)
                              .colorScheme
                              .tertiaryContainer, // TODO change the colour
                        ),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 200,
                                    child:
                                        imageurl != null && imageurl.isNotEmpty
                                        ? ImageFromUrl.get(
                                            imageurl,
                                            fillContainer: true,
                                            loadedKey: ValueKey(
                                              'screenshot-module-thumbnail-loaded-${value.id}',
                                            ),
                                          )
                                        : Image.asset(
                                            'assets/images/ecounity-logo.png',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 200,
                                          ),
                                  ),
                                ),
                                if (moduleCompleted)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              value.title,
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }

              int axiscount = 2;
              double aspectratio = 1 / 1.1;

              double width = MediaQuery.of(context).size.width;
              // TODO Adjust the aspect ratios
              switch (width) {
                case <= 750 && > 700:
                  aspectratio = 1 / 1.1;
                  break;
                case <= 700 && > 650:
                  aspectratio = 1 / 1.2;
                  break;
                case <= 650 && > 600:
                  aspectratio = 1 / 1.3;
                  break;
                case <= 600 && > 550:
                  aspectratio = 1 / 1.6;
                  break;
                case <= 550:
                  axiscount = 1;

                  break;
              }

              return ScreenScaffold(
                key: const ValueKey('screenshot-modules-list-screen'),
                onRefresh: _refresh,
                title: screenTitle,
                navigationIndex: widget.navIndex,

                child: SingleChildScrollView(
                  key: const ValueKey('screenshot-modules-list'),
                  child: Container(
                    margin: EdgeInsets.only(top: 25, left: 25),
                    child: axiscount > 1
                        ? GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: axiscount,
                            childAspectRatio: aspectratio,
                            children: itemlist.toList(),
                          )
                        : Column(children: itemlist.toList()),
                  ),
                ),
              );
            } else {
              error = context.l10n.no_modules_found;
            }
          }
        }
        return ScreenScaffold(
          onRefresh: _refresh,
          title: screenTitle,
          navigationIndex: widget.navIndex,
          child: Center(
            child: error != null
                ? Text(error)
                : const CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

extension on WebPage {
  List<String> get contentLanguagesList {
    final rawValue = data?['contentlanguages'];
    if (rawValue is String) {
      return rawValue
          .replaceAll(' ', '')
          .split(',')
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (rawValue is List) {
      return rawValue.whereType<String>().toList();
    }
    return [];
  }
}
