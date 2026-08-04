import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:core/core.dart' as core;
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/objects/ecounity_badge.dart';
import 'package:ecounity/src/objects/pathway_stage.dart';
import 'package:ecounity/src/objects/pathway_status.dart';
import 'package:ecounity/src/objects/pathway_status_item.dart';
import 'package:ecounity/src/objects/pathway_type.dart';
import 'package:ecounity/src/util/image_from_url.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

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
final Map<String, Future<List<core.ImageObject>>> _imageObjectsCache = {};
final Map<String, Future<Widget?>> _contentsCache = {};
Future<void> _pathwayStatusMutationQueue = Future.value();

Future<T> _runWithPathwayStatusQueue<T>(Future<T> Function() task) {
  final Future<T> queued = _pathwayStatusMutationQueue.then((_) => task());
  _pathwayStatusMutationQueue = queued.then((_) {}, onError: (_) {});
  return queued;
}

int? _coerceInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

@visibleForTesting
String replaceImageTokens(String content, List<core.ImageObject> images) {
  String contentWithImages = content;

  for (int i = 0; i < images.length; i++) {
    final String token = '%image.${i + 1}%';
    final String? imageUrl = images[i].imageUrl;
    if (imageUrl == null) {
      contentWithImages = contentWithImages.replaceAll(token, '');
      continue;
    }

    contentWithImages = contentWithImages.replaceAll(
      token,
      '<img src="$imageUrl" style="max-width: 100%; height: auto; width: auto;" />',
    );
  }

  // Remove any remaining placeholders to keep HTML clean.
  contentWithImages = contentWithImages.replaceAll(RegExp(r'%image\.\d+%'), '');

  return contentWithImages;
}

String _contentsCacheKey(core.WebPage page) {
  return "${page.getValue('id')}|${const DeepCollectionEquality().hash(page.getValue('images'))}|${const DeepCollectionEquality().hash(page.getValue('textcontents'))}";
}

String _imageObjectsCacheKey(core.WebPage page) {
  return "${page.getValue('id')}|${const DeepCollectionEquality().hash(page.getValue('images'))}";
}

extension Pathway on core.WebPage {
  int get id =>
      (getValue('id') is String) ? int.parse(getValue('id')) : getValue('id');
  String get title {
    String titleEscaped = getValue('title') ?? pagetitle ?? '';
    return core.unescapeHTML(titleEscaped);
  }

  String? get description => getValue('description');
  String? get introductionTextString => getValue('introductiontext');
  String? get references => getValue('references');

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

  Future<List<core.ImageObject>> get imageObjects async {
    final cacheKey = _imageObjectsCacheKey(this);
    if (_imageObjectsCache.containsKey(cacheKey)) {
      return _imageObjectsCache[cacheKey]!;
    }

    final dynamic images = getValue('images');
    final future = () async {
      if (images == null || images is! List<dynamic>) {
        return <core.ImageObject>[];
      }

      final List<Future<core.ImageObject?>> imageFutures = [];
      for (final imageData in images) {
        if (imageData is! Map) {
          continue;
        }

        final String? objectType = imageData['objecttype']?.toString();
        if (objectType != null && objectType != 'image') {
          continue;
        }

        final dynamic objectId = imageData['objectid'];
        final int? id = int.tryParse(objectId.toString());
        if (id == null) {
          continue;
        }

        imageFutures.add(loadCoreImage(id));
      }

      final List<core.ImageObject?> imagesLoaded = await Future.wait(
        imageFutures,
      );
      return imagesLoaded.whereType<core.ImageObject>().toList();
    }();

    _imageObjectsCache[cacheKey] = future;
    return future;
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

  Future<Widget?> get contents async {
    final String cacheKey = _contentsCacheKey(this);
    if (_contentsCache.containsKey(cacheKey)) {
      return _contentsCache[cacheKey]!;
    }

    final future = () async {
      if (textcontents == null) {
        return null;
      }

      final List<core.ImageObject> images = await imageObjects;

      final List<Widget> widgets = [];
      for (String content in textcontents!) {
        final String contentWithImages = replaceImageTokens(content, images);
        widgets.add(
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: HtmlWidget(contentWithImages),
            ),
          ),
        );
      }

      return Column(children: widgets);
    }();

    _contentsCache[cacheKey] = future;
    return future;
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
      await setStatus(PathwayStatus.opened, context);
    } else {
      await setStatus(PathwayStatus.completed, context);
    }
  }

  Future<void> setStatus(PathwayStatus status, BuildContext context) async {
    if (kDebugMode) {
      log('Setting pathway status for $title (${id.toString()}) to $status');
    }

    final int? pathwayId = _coerceInt(id);
    if (pathwayId == null) {
      if (kDebugMode) {
        log('Skipping pathway status update because id could not be resolved');
      }
      return;
    }

    final bool shouldAwardBadges = status == PathwayStatus.completed;
    final List<int> completedPathwayIds = List<int>.empty(growable: true);

    core.FileStorage fileStorage = Provider.of<core.FileStorage>(
      context,
      listen: false,
    );
    core.WebPageProvider webPageProvider = Provider.of<core.WebPageProvider>(
      context,
      listen: false,
    );
    await EcoUnityStorage(fileStorage).registerAdapters();

    await _runWithPathwayStatusQueue(() async {
      List<PathwayStatusItem> statusItems =
          (await EcoUnityStorage(
            fileStorage,
          ).getCompletedPathways())?.toList() ??
          [];

      final Map<int, PathwayStatusItem> statusById = {
        for (final PathwayStatusItem item in statusItems) item.id: item,
      };

      final List<core.WebPage> pages = await webPageProvider.getItems(
        pathwayLoadParameters,
      );
      final Map<int, core.WebPage> pagesById = {};
      for (final core.WebPage page in pages) {
        final int? pageId = page.id;
        if (pageId != null) {
          pagesById[pageId] = page;
        }
      }

      if (!pagesById.containsKey(pathwayId)) {
        pagesById[pathwayId] = this;
      }

      final Set<int> pendingStatuses = <int>{pathwayId};
      final Set<int> processed = <int>{};
      final Map<int, PathwayStatus> plannedStatuses = {pathwayId: status};
      final List<int> newlyCompletedIds = [];

      while (pendingStatuses.isNotEmpty) {
        final int currentId = pendingStatuses.first;
        pendingStatuses.remove(currentId);
        if (processed.contains(currentId)) {
          continue;
        }
        processed.add(currentId);

        final PathwayStatus? targetStatus = plannedStatuses[currentId];
        if (targetStatus == null) {
          continue;
        }

        final PathwayStatus? currentStatus = statusById[currentId]?.status;
        final bool wasCompleted = currentStatus == PathwayStatus.completed;
        if (currentStatus != targetStatus) {
          statusById[currentId] = PathwayStatusItem(
            id: currentId,
            status: targetStatus,
          );
          if (!wasCompleted && targetStatus == PathwayStatus.completed) {
            newlyCompletedIds.add(currentId);
          }
        }

        final core.WebPage currentPage =
            pagesById[currentId] ?? core.WebPage(id: currentId);
        final int? parentId = _coerceInt(currentPage.getValue('pageid'));
        if (parentId == null) {
          continue;
        }

        final PathwayStatus? siblingStatusTarget =
            targetStatus == PathwayStatus.completed
            ? PathwayStatus.completed
            : null;

        if (siblingStatusTarget != null) {
          bool siblingBlocked = false;
          for (final core.WebPage sibling in pages) {
            final int? siblingParent = _coerceInt(sibling.getValue('pageid'));
            if (siblingParent != parentId) {
              continue;
            }

            final int? siblingId = sibling.id;
            if (siblingId == null || siblingId == currentId) {
              continue;
            }

            if (statusById[siblingId]?.status != PathwayStatus.completed) {
              siblingBlocked = true;
              break;
            }
          }

          if (!siblingBlocked &&
              statusById[parentId]?.status != PathwayStatus.completed) {
            plannedStatuses[parentId] = PathwayStatus.completed;
            pendingStatuses.add(parentId);
          }
        } else if (statusById[parentId]?.status == PathwayStatus.completed) {
          plannedStatuses[parentId] = PathwayStatus.opened;
          pendingStatuses.add(parentId);
        }
      }

      // Put the bunny back in the box.
      await fileStorage.setObject(
        'completedPathways',
        statusById.values.toList(),
        boxName: 'userData',
      );

      completedPathwayIds.addAll(newlyCompletedIds);
    });

    if (!context.mounted || completedPathwayIds.isEmpty) {
      return;
    }

    if (shouldAwardBadges) {
      awardBadges(context);
    }

    for (final int completedPageId in completedPathwayIds) {
      try {
        await core.ApiClient().addCompletion(completedPageId);
      } catch (error) {
        log('Failed to sync completion for page $completedPageId: $error');
      }
      if (kDebugMode) {
        log('Completion sync completed for page $completedPageId');
      }
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
    try {
      return (await fileStorage.getObject(
                'badgeStatusItems',
                boxName: 'userData',
              )
              as List<dynamic>?)
          ?.map((item) => item as BadgeStatusItem)
          .toList();
    } catch (error) {
      log('Resetting unreadable badgeStatusItems Hive entry: $error');
      await fileStorage.setObject(
        'badgeStatusItems',
        <BadgeStatusItem>[],
        boxName: 'userData',
      );
      return <BadgeStatusItem>[];
    }
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
      'method': 'json',
    };
    var url = Uri.https(
      await baseUrl,
      apiPath,
      params.map((key, value) => MapEntry(key, value.toString())),
    );

    return getJson(url).then((core.ApiResponse response) {
      Map<String, dynamic>? responseData =
          response.rawData as Map<String, dynamic>?;
      return responseData?['status'] == 'success';
    });
  }
}
