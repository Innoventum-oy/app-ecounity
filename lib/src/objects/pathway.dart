import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/objects/pathway_stage.dart';
import 'package:ecounity/src/objects/pathway_status.dart';
import 'package:ecounity/src/objects/pathway_status_item.dart';
import 'package:ecounity/src/objects/pathway_type.dart';
import 'package:ecounity/src/objects/ecounity_badge.dart';
import 'package:ecounity/src/util/image_from_url.dart';

import '../providers/ecounity_badge_provider.dart';
import '../util/core_compat.dart';
import '../util/ecounity_storage.dart';
import '../util/settings.dart';
import '../widgets/badge_completion_page.dart';
import '../widgets/popupdialog.dart';
import 'badge_status_item.dart';
export 'pathway_status.dart';
export 'pathway_type.dart';

final Map<int, Future<core.ImageObject?>> _coreImageFutureCache = {};

extension Pathway on core.WebPage {
  int get id =>
      (getValue('id') is String) ? int.parse(getValue('id')) : getValue('id');
  String get title {
    String titleEscaped = getValue('title') ?? pagetitle ?? '';
    return core.unescapeHTML(titleEscaped);
  }

  String? get description => getValue('description');
  String? get introductionTextString => getValue('introductiontext');

  Future<core.ImageObject?> get thumbnailImage async {
    if (thumbnail == null) {
      if (kDebugMode) {
        log('No thumbnail available for $title');
      }
      return null;
    }

    return await _coreImageFutureCache.putIfAbsent(
      thumbnail!,
      () => loadCoreImage(thumbnail!),
    );
  }

  Future<String?> get thumbnailImageUrl async {
    core.ImageObject? image = await thumbnailImage;
    return image?.imageUrl;
  }

  Future<core.ImageObject?> get introductionImage async {
    if (getValue('introductionimage') == null) {
      return null;
    }
    Map imageProperties = getValue('introductionimage');
    final imageId = int.parse(imageProperties['objectid']);
    return await _coreImageFutureCache.putIfAbsent(
      imageId,
      () => loadCoreImage(imageId),
    );
  }

  Future<core.ImageObject?> get completionImage async {
    if (getValue('completionimage') == null) {
      return null;
    }
    Map imageProperties = getValue('completionimage');
    final imageId = int.parse(imageProperties['objectid']);
    return await _coreImageFutureCache.putIfAbsent(
      imageId,
      () => loadCoreImage(imageId),
    );
  }

  Future<core.Form?> get form async {
    if (getValue('form') == null) {
      return null;
    }
    Map formProperties = getValue('form');
    // Loads form with elements
    return await core.FormProvider().loadForm(
      int.parse(formProperties['objectid']),
    );
  }

  String? get completionTextString => getValue('completiontext');

  PathwayStage get stage {
    try {
      return getValue('stage') == null
          ? PathwayStage.any
          : PathwayStage.values.byName(getValue('stage'));
    } catch (e) {
      // Default
      if (kDebugMode) {
        print('Error getting stage: $e');
      }
      return PathwayStage.any;
    }
  }

  PathwayType get type {
    try {
      String type = getValue('pagecategory');
      // Special case for 'forms' type -> return quiz
      if (type == 'forms') {
        return PathwayType.quiz;
      }
      return PathwayType.values.byName(type);
    } catch (e) {
      // Default to wiki
      return PathwayType.wiki;
    }
  }

  Widget? getContentsReplaced(List<String> keys, List<String> values) {
    if (textcontents == null) {
      return null;
    }
    // Iterate through the text contents and return a widget. The text contents are in HTML format. The widget should contain a list of Card widget, each containing the HTML content.
    List<Widget> widgets = [];
    for (String content in textcontents!) {
      for (int i = 0; i < keys.length; i++) {
        content = content.replaceAllMapped(
          RegExp(keys[i], caseSensitive: false),
          (match) => values[i],
        );
      }
      widgets.add(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: HtmlWidget(content),
          ),
        ),
      );
    }
    return Column(children: widgets);
  }

  Widget? get contents {
    if (textcontents == null) {
      return null;
    }
    // Iterate through the text contents and return a widget. The text contents are in HTML format. The widget should contain a list of Card widget, each containing the HTML content.
    List<Widget> widgets = [];
    for (String content in textcontents!) {
      if(kDebugMode ) print(content);

      widgets.add(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: HtmlWidget(content),
          ),
        ),
      );
    }
    return Column(children: widgets);
  }

  Widget? getIntroductionTextReplaced(List<String> keys, List<String> values) {
    if (introductionTextString == null) {
      return null;
    }
    String content = introductionTextString!;
    for (int i = 0; i < keys.length; i++) {
      content = content.replaceAllMapped(
        RegExp(keys[i], caseSensitive: false),
        (match) => values[i],
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: HtmlWidget(content),
      ),
    );
  }

  Widget? get introductionText {
    if (introductionTextString == null) {
      return null;
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: HtmlWidget(introductionTextString!),
      ),
    );
  }

  bool hasIntroductionImage() {
    return getValue('introductionimage') != null;
  }

  bool hasCompletionImage() {
    return getValue('completionimage') != null;
  }

  bool hasIntroduction() {
    return introductionTextString != null;
  }

  bool hasCompletion() {
    return completionTextString != null || hasCompletionImage();
  }

  Widget? getCompletionTextReplaced(List<String> keys, List<String> values) {
    if (completionTextString == null) {
      return null;
    }
    String content = completionTextString!;
    for (int i = 0; i < keys.length; i++) {
      content = content.replaceAllMapped(
        RegExp(keys[i], caseSensitive: false),
        (match) => values[i],
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: HtmlWidget(content),
      ),
    );
  }

  Widget getCompletionText(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: HtmlWidget(
          completionTextString ?? context.l10n.pathway_completed,
        ),
      ),
    );
  }

  String? get pathwayName => getValue('maincategory');
  String? get categoryName => getValue('pagecategory');
  int? get thumbnail {
    var value = getValue('thumbnailid');
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  String? get videoUrl => getValue('video');
  int get sortOrder =>
      getValue('orderno') != null ? int.parse(getValue('orderno')) : 0;
  bool get hasThumbnail => thumbnail != null;
  int? get parent =>
      getValue('pageid') != null ? int.parse(getValue('pageid')) : null;
  bool get isMainPathway => pathwayName != null && pathwayName != '';
  bool get isMainModule => categoryName == 'modules';
  bool get isSubModule => categoryName == 'submodule';
  bool get isMainResource => categoryName == 'resources';
  bool get isModuleRoot => categoryName == 'modules'; // Alias for isMainModule
  bool get isResourceRoot => categoryName == 'resourcemenu';
  Widget get icon {
    Widget icon = Icon(Icons.question_mark);
    switch (type) {
      case PathwayType.quiz:
        icon = const Icon(Icons.quiz);
        break;
      case PathwayType.dragdrop:
        icon = const Icon(IconData(0xe629, fontFamily: 'MaterialIcons'));
        break;
      case PathwayType.video:
        icon = const Icon(Icons.video_collection);
        break;
      case PathwayType.wiki:
        icon = const Icon(Icons.book);
        break;
      case PathwayType.slides:
        icon = const Icon(Icons.slideshow);
    }
    return CircleAvatar(backgroundColor: Colors.black, child: icon);
  }

  Future<void> toggleCompleted(BuildContext context) async {
    if (await isCompleted() && context.mounted) {
      setStatus(PathwayStatus.opened, context);
    } else {
      setStatus(PathwayStatus.completed, context);
    }
  }

  Future<void> setStatus(PathwayStatus status, BuildContext context) async {
    if (kDebugMode) {
      log('Setting pathway status for $title ($id) to $status');
    }

    core.FileStorage fileStorage = Provider.of<core.FileStorage>(
      context,
      listen: false,
    );
    await EcoUnityStorage(fileStorage).registerAdapters();

    List<PathwayStatusItem>? statusItems = await EcoUnityStorage(
      fileStorage,
    ).getCompletedPathways();
    // If the pathway is already in the list, update the status
    if (statusItems != null) {
      PathwayStatusItem? item = statusItems.firstWhereOrNull(
        (element) => element.id == id,
      );
      if (item != null) {
        item.status = status;
      } else {
        statusItems.add(PathwayStatusItem(id: id, status: status));
      }
    } else {
      statusItems = [PathwayStatusItem(id: id, status: status)];
    }

    // Update the status of the parent page
    if (parent != null && context.mounted) {
      core.WebPageProvider webPageProvider = Provider.of<core.WebPageProvider>(
        context,
        listen: false,
      );
      List<core.WebPage> pages = await webPageProvider.getItems(
        pathwayLoadParameters,
      );

      if (pages.isNotEmpty) {
        core.WebPage? parentpage = pages.firstWhere(
          (val) => val.id == parent,
          orElse: () => core.WebPage(),
        );

        if (parentpage.id != null) {
          if (status == PathwayStatus.completed) {
            // Check if the parent page should be marked as completed

            List<core.WebPage> siblingpages = pages
                .where((val) => val.parent == parent)
                .toList();

            if (siblingpages.isNotEmpty) {
              bool incomplete = false;
              for (int i = 0; i < siblingpages.length; i++) {
                if (siblingpages[i].id == id) {
                  // Ignore current page
                  continue;
                }
                if (await siblingpages[i].status != PathwayStatus.completed) {
                  incomplete = true;
                  break;
                }
              }

              if (!incomplete &&
                  await parentpage.status != PathwayStatus.completed &&
                  context.mounted) {
                // Mark parent page as completed
                parentpage.setStatus(PathwayStatus.completed, context);
              }
            }
          } else if (await parentpage.status == PathwayStatus.completed &&
              context.mounted) {
            // Mark parent page as incomplete
            parentpage.setStatus(PathwayStatus.opened, context);
          }
        }
      }
    }

    // Put the bunny back in the box
    await fileStorage.setObject(
      'completedPathways',
      statusItems,
      boxName: 'userData',
    );
    // Check if the change caused a badge to be completed
    if (status == PathwayStatus.completed) {
      if (context.mounted) {
        awardBadges(context);
      }

      // Increase the counter for the times when the page has been completed
      await core.ApiClient().addCompletion(id);
    }
  }

  void awardBadges(BuildContext context) async {
    // Check completed badges
    List<EcoUnityBadge>? badges = (await EcoUnityBadgeProvider().getItems(
      badgeParams,
    ));
    if (badges.isNotEmpty) {
      if (kDebugMode) {
        log('Badges found for $title, checking if completed');
      }
      // Reverse the order so that the completion popups are displayed in a logical order (the last one to be added gets shown on top)
      badges = badges.reversed.toList();

      String currentLanguage = context.mounted
          ? Localizations.localeOf(context).languageCode
          : 'en';

      List<BadgeStatusItem> statusItems = await getBadgeStatusItems() ?? [];
      bool updateStatusItems = false;

      for (EcoUnityBadge badge in badges) {
        if (kDebugMode) {
          log(
            'Badge ${badge.name}: isCompleted: ${await badge.isCompleted(currentLanguage)}, isNotified: ${badge.isNotified}',
          );
        }
        if (await badge.isCompleted(currentLanguage) && context.mounted) {
          List<String> parallelLanguages = badge.getParallelLanguageVersions(
            currentLanguage,
          );
          bool isNotified = statusItems.any((item) {
            return (item.badgeId == badge.id &&
                item.isNotified &&
                parallelLanguages.contains(item.language));
          });

          if (!isNotified) {
            if (kDebugMode) {
              log('Badge ${badge.name} is completed, notifying user');
            }
            // Notify the user and mark the badge as notified
            popupDialog(
              context.l10n.module_completed,
              BadgeCompletionPage(badge: badge),
              context,
              actions: [
                ElevatedButton(
                  child: Text(context.l10n.ok),
                  onPressed: () {
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  },
                ),
              ],
            );
            badge.isNotified = true;
            // Save the badge as notified

            for (String language in parallelLanguages) {
              int relevantIndex = statusItems.indexWhere((item) {
                return (item.badgeId == badge.id && item.language == language);
              });

              BadgeStatusItem relevantItem = (relevantIndex >= 0)
                  ? statusItems.elementAt(relevantIndex)
                  : BadgeStatusItem(badgeId: badge.id, language: language);
              relevantItem.isNotified = true;
              if (relevantIndex >= 0) {
                statusItems[relevantIndex] = relevantItem;
              } else {
                statusItems.add(relevantItem);
              }
            }

            updateStatusItems = true;
          }
        }
      }

      if (updateStatusItems) {
        setBadgeStatusItems(statusItems);
      }
    }
  }

  // Get list of badge status items from local storage
  Future<List<BadgeStatusItem>?> getBadgeStatusItems() async {
    core.FileStorage fileStorage = core.FileStorage();
    return (await fileStorage.getObject('badgeStatusItems', boxName: 'userData')
            as List<dynamic>?)
        ?.map((item) => item as BadgeStatusItem)
        .toList();
  }

  // Store list of badge status items to local storage
  void setBadgeStatusItems(List<BadgeStatusItem>? statusItems) async {
    core.FileStorage fileStorage = core.FileStorage();
    await fileStorage.setObject(
      'badgeStatusItems',
      statusItems,
      boxName: 'userData',
    );
  }

  /// Check if a pathway is completed
  Future<bool> isCompleted() async {
    PathwayStatus? status = await this.status;
    if (status != null) {
      return status == PathwayStatus.completed;
    }
    return false;
  }

  /// Check if a pathway is opened
  Future<bool> isOpened() async {
    PathwayStatus? status = await this.status;
    if (status != null) {
      return status == PathwayStatus.opened;
    }
    return false;
  }

  Future<PathwayStatus?> get status async {
    List<PathwayStatusItem>? completedPathways = await getCompletedPathways();
    return (completedPathways
        ?.firstWhereOrNull((element) => element.id == id)
        ?.status);
  }

  // Get list of completed pathways from local storage
  Future<List<PathwayStatusItem>?> getCompletedPathways() async {
    return EcoUnityStorage(core.FileStorage()).getCompletedPathways();
  }

  Widget imageBuilder(Future<core.ImageObject?> future) {
    if (kDebugMode) {
      log('Image builder called for $title');
    }
    return FutureBuilder<core.ImageObject?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          debugPrint('Error: ${snapshot.error}');
          debugPrint('Stack trace: ${snapshot.stackTrace}');
          return Center(
            child: Text('${context.l10n.error}: ${snapshot.error}'),
          );
        } else if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.imageUrl != null) {
          return Card(
            // child: ImageFromUrl.get('/api/dispatcher/openimage/${snapshot.data!.id!}'), // optional approach but this needs tweaking
            child: SizedBox(
              width: double.infinity,
              child: ImageFromUrl.get(snapshot.data!.imageUrl!),
            ),
          );
        } else {
          return Center(child: Text(context.l10n.no_image_available));
        }
      },
    );
  }
}

extension on core.ApiClient {
  /// Increase the counter for times the page has been completed.
  ///
  /// Parameters:
  /// - pageId: page ID
  ///
  /// Returns:
  /// - True on success, or false on failure
  Future<bool> addCompletion(int pageId) async {
    // Build the dispatcher URL for the pagelist module
    String apiPath = await buildApiPath('dispatcher/pagelist/');
    Map<String, dynamic> params = {
      'objectid': pageId,
      'action': 'addcompletion',
      'method': 'json'
    };
    var url = Uri.https(await baseUrl, apiPath, params.map((key, value) => MapEntry(key, value.toString())));

    return getJson(url).then((core.ApiResponse response) {
      Map<String, dynamic>? responseData = response.rawData as Map<String, dynamic>?;
      return responseData?['status'] == 'success';
    });
  }
}