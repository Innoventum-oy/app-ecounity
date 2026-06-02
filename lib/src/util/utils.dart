import 'dart:developer';
import 'package:collection/collection.dart';
import 'package:core/core.dart' as core;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/util/settings.dart';
import 'package:ecounity/src/util/core_compat.dart';
import 'package:ecounity/src/objects/pathway.dart';
import '../objects/pathway_status_item.dart';
import '../providers/ecounity_badge_provider.dart';

/// Check if a pathway is completed
bool isPathwayCompleted(
    core.WebPage pathway, List<PathwayStatusItem>? completedPathways) {
  if (completedPathways == null) {
    return false;
  }
  PathwayStatus? status = completedPathways
      .firstWhereOrNull((element) => element.id == pathway.id)
      ?.status;
  if (status != null) {
    return status == PathwayStatus.completed;
  }

  return false;
}

/// Check if a pathway is opened
bool isPathwayOpened(
    core.WebPage pathway, List<PathwayStatusItem>? completedPathways) {
  PathwayStatus? status = completedPathways
      ?.firstWhereOrNull((element) => element.id == pathway.id)
      ?.status;
  if (status != null) {
    return status == PathwayStatus.opened;
  }
  return false;
}

/// enable querying color from hex values
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

Future<String?> updateAppVersionDate(BuildContext context,
    {bool forceRefresh = false}) async {
  // Get the versiondate from the backend by calling 'version.php'

  core.ApiResponse versionData = await core.ApiClient().request('version.php');
  if (versionData.rawData == null) {
    if (kDebugMode || kProfileMode) {
      log('Could not get version data from server.');
    }
    return null;
  }
  String versionDate =
      versionData.rawData != null ? versionData.rawData['versiondate'] : '';
  String server = await core.Settings().getServer();
  String currentVersionDate = await core.Settings().getValue('appVersionDate');
  // If the version date has changed, update the app version date and trigger a data refresh
  if (versionDate != currentVersionDate || forceRefresh) {
    await core.Settings().setValue('appVersionDate', versionDate);

    if (kDebugMode || kProfileMode) {
      if (forceRefresh) {
        log('Forcing refresh of app version date');
      } else {
        log('App version date updated from $currentVersionDate to $versionDate (server: $server) - loading data');
      }
    }

    if (context.mounted) loadAppData(context);

    if ((kDebugMode || kProfileMode) && versionDate != currentVersionDate) {
      log('App version date updated from $currentVersionDate to $versionDate (server: $server) ');
    }
  } else {
    if (kDebugMode || kProfileMode) {
      log('App version date is up to date: $versionDate (server: $server)');
    }
  }

  return versionDate;
}

Future<String> getAppVersionDate() async {
  return await core.Settings().getValue('appVersionDate');
}

Future<void> loadAppData(BuildContext context) async {
  core.WebPageProvider webPageProvider =
      Provider.of<core.WebPageProvider>(context, listen: false);
  // Set current language to pathwayLoadParameters
  // Load all badges

  Provider.of<EcoUnityBadgeProvider>(context, listen: false)
      .getItems(badgeParams, reload: true);

  //  pathwayLoadParameters['language'] = Provider.of<LocaleProvider>(context, listen: false).locale?.languageCode ?? 'en';
  await webPageProvider.getItems(pathwayLoadParameters, reload: true);
  // With the items, iterate all quizz pages and load the questions
  AppImageProvider imageProvider = createImageProvider();
  List<core.WebPage> dragdropPages = webPageProvider.list!
      .where((element) => element.type == PathwayType.dragdrop)
      .toList();
  if (kDebugMode) {
    log('Loading images for ${dragdropPages.length} dragdrop pages: ');
  }

  // Iterate all dragdrop pages and pre-load the draggables (imagelists) through imageProvider
  for (core.WebPage page in dragdropPages) {
    List<dynamic>? folders = page.getValue('imagefolders');
    if (folders != null) {
      for (Map<String, dynamic> folder in folders) {
        if (kDebugMode) {
          log('Loading images for dragdrop page ${page.id} folder ${folder['objectid']}');
        }
        imageProvider.getItems({
          'category': folder['objectid'],
          'fields': 'id,title,text,imageurl'
        }, reload: true);
      }
    }

  }
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
