import 'dart:developer';

import 'package:core/core.dart' as core;
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/src/objects/pathway_status_item.dart';
import '../../l10n/app_localizations.dart';
import '../util/ecounity_storage.dart';
import 'package:hive_ce/hive.dart';
import 'pathway_status.dart';

part 'ecounity_badge.g.dart';

@HiveType(typeId: 1205)
class EcoUnityBadge extends core.Badge {
  @HiveField(251)
  String? pathway;
  @HiveField(252)
  bool isNotified = false;
  // unnamed constructor extending parent
  EcoUnityBadge({
    super.id,
    super.name,
    super.description,
    super.badgeimageurl,
    super.color,
    super.accesslevel,
    super.requiredPathways,
    this.pathway,
    super.data,
  }) : super();

  // Method to check if badge is completed
  Future<bool> isCompleted([String? lang]) async {
    final List<WebPage> filteredPathways = _getFilteredPathways(lang);
    final int requiredCount = filteredPathways.length;
    if (requiredCount == 0) {
      if (kDebugMode) {
        log(
          'Badge ${name ?? id}: isCompleted=false, no required pathways for lang=$lang',
          name: 'EcoUnityBadge',
        );
      }
      return false;
    }

    final int completedCount = await getCompletedPathwaysCount(lang);
    final bool result = completedCount >= requiredCount;

    if (kDebugMode) {
      final List<PathwayStatusItem> completedPathways =
          await EcoUnityStorage(core.FileStorage()).getCompletedPathways() ??
          [];
      final Set<int> requiredIds = filteredPathways
          .map((pathway) => pathway.id)
          .whereType<int>()
          .toSet();
      final List<String> relevantStatuses = completedPathways
          .where((item) => requiredIds.contains(item.id))
          .map((item) => '${item.id}:${item.status.name}')
          .toList();

      log(
        'Badge ${name ?? id}: isCompleted=$result, lang=$lang, '
        'required=$requiredCount, completed=$completedCount, '
        'requiredIds=${requiredIds.toList()}, statuses=$relevantStatuses',
        name: 'EcoUnityBadge',
      );
    }

    return result;
  }

  // Get completion status in percent
  Future<double> getCompletion([String? lang]) async {
    // Get the completed pathways from the storage
    core.FileStorage fileStorage = core.FileStorage();
    List<PathwayStatusItem>? completedPathways = await EcoUnityStorage(
      fileStorage,
    ).getCompletedPathways();
    // If there are no completed pathways, return 0.0
    if (completedPathways == null) {
      return 0.0;
    }

    final List<WebPage> filteredPathways = _getFilteredPathways(lang);

    // If there are completed pathways, calculate the completion percentage
    // Iterate the requiredPathways and check if they are in the completedPathways
    // If all required pathways are completed, return 100.0
    // If not all required pathways are completed, return the percentage of completed pathways
    int totalPathways = filteredPathways.length;
    if (totalPathways == 0) {
      return 0.0;
    }
    int completedPathwaysCount = 0;

    for (var element in filteredPathways) {
      // Count only pathways explicitly marked completed, not merely opened.
      if (completedPathways.any(
        (item) =>
            item.id == element.id && item.status == PathwayStatus.completed,
      )) {
        completedPathwaysCount++;
      }
    }

    // Calculate the percentage
    return ((completedPathwaysCount / totalPathways) * 100).roundToDouble();
  }

  Future<int> getRequiredPathwaysCount([String? lang]) async {
    int totalPathways = _getFilteredPathways(lang).length;
    return totalPathways;
  }

  Future<int> getCompletedPathwaysCount([String? lang]) async {
    // Get the completed pathways from the storage
    core.FileStorage fileStorage = core.FileStorage();
    List<PathwayStatusItem>? completedPathways = await EcoUnityStorage(
      fileStorage,
    ).getCompletedPathways();
    // If there are no completed pathways, return 0.0
    if (completedPathways == null) {
      return 0;
    }

    final List<WebPage> filteredPathways = _getFilteredPathways(lang);

    int completedPathwaysCount = 0;
    for (var element in filteredPathways) {
      if (completedPathways.any(
        (item) =>
            item.id == element.id && item.status == PathwayStatus.completed,
      )) {
        completedPathwaysCount++;
      }
    }
    return completedPathwaysCount;
  }

  List<WebPage> _getFilteredPathways([String? lang]) {
    if (requiredPathways == null || requiredPathways!.isEmpty) {
      return <WebPage>[];
    }

    if (lang == null) {
      return List<WebPage>.from(requiredPathways!);
    }

    return requiredPathways!.where((WebPage pathway) {
      return pathway.contentlanguages == null ||
          pathway.contentlanguages!.isEmpty ||
          pathway.contentlanguages!.contains(lang);
    }).toList();
  }

  bool isLanguageSpecific() {
    if (requiredPathways != null && requiredPathways!.isNotEmpty) {
      for (WebPage pathway in requiredPathways!) {
        if (pathway.contentlanguages != null &&
            pathway.contentlanguages!.isNotEmpty) {
          return true;
        }
      }
    }
    return false;
  }

  List<String>? getContentLanguages() {
    List<String> languages = [];
    if (requiredPathways != null && requiredPathways!.isNotEmpty) {
      for (WebPage pathway in requiredPathways!) {
        if (pathway.contentlanguages != null &&
            pathway.contentlanguages!.isNotEmpty) {
          languages = {...languages, ...?pathway.contentlanguages}.toList();
        }
      }
    }
    return languages.isNotEmpty ? languages : null;
  }

  // Return all languages where the badge requires the same pathways as in the given language (includes the given language in the list)
  List<String> getParallelLanguageVersions(String lang) {
    List<String> languageVersions = [];
    List<String> allLanguages = AppLocalizations.supportedLocales
        .map((item) => item.languageCode)
        .toList();

    if (requiredPathways != null && requiredPathways!.isNotEmpty) {
      Map<String, List<int?>> languageMap = {};
      for (String item in allLanguages) {
        languageMap[item] = [];
      }
      List<int?> included =
          []; // Pathways that are required in the given language version
      List<int?> excluded =
          []; // Pathways that are not included in the given language version

      for (WebPage pathway in requiredPathways!) {
        if (pathway.contentlanguages != null &&
            pathway.contentlanguages!.isNotEmpty) {
          // Pathway has defined content languages
          bool exclude = true;

          for (String contentlanguage in pathway.contentlanguages!) {
            if (contentlanguage == lang) {
              included.add(pathway.id);
              exclude = false;
            }
            languageMap[contentlanguage]?.add(pathway.id);
          }

          if (exclude) {
            excluded.add(pathway.id);
          }
        } else {
          // Pathway does not have defined content languages, so the pathway will be included in any language version
          included.add(pathway.id);

          for (String item in allLanguages) {
            languageMap[item]?.add(pathway.id);
          }
        }
      }

      // Find all languages where the pathway lists are the same as in the given language
      for (String language in languageMap.keys) {
        if (language == lang ||
            languageMap[language]!.every((item) {
              return included.contains(item) && !excluded.contains(item);
            })) {
          languageVersions.add(language);
        }
      }
    } else {
      // No required pathways, so using the same criteria for all languages
      languageVersions = allLanguages;
    }

    return languageVersions;
  }

  factory EcoUnityBadge.fromJson(Map<String, dynamic> response) {
    Map<String, dynamic> responseData = response['data'] ?? response;
    int accessLevel = responseData['accesslevel'] is int
        ? responseData['accesslevel']
        : int.parse(responseData['accesslevel']);

    return EcoUnityBadge(
      id: responseData['objectid'] != null
          ? int.parse(responseData['objectid'])
          : null,
      name: responseData['name'],
      description: responseData['description'],
      badgeimageurl: responseData['badgeimageurl'],
      color: responseData['color'] != null && responseData['color'].length > 0
          ? responseData['color']
          : '#000000',
      accesslevel: accessLevel,
      requiredPathways: responseData['requiredpathwaydata'] != null
          ? responseData['requiredpathwaydata'].map<core.WebPage>((item) {
              var itemdata = core.WebPage.fromJson(item);
              if (item['contentlanguages'] is String) {
                itemdata.contentlanguages = item['contentlanguages']
                    .replaceAll(' ', '')
                    .split(',')
                    .toList();
              }
              return itemdata;
            }).toList()
          : [],
      pathway: responseData['pathway'],
      data: responseData,
    );
  }

  Widget badgeImage() {
    return badgeimageurl != null
        ? Image.network(badgeimageurl!, fit: BoxFit.contain, height: 200)
        : const Icon(Icons.emoji_events, size: 100);
  }

  @override
  toString() {
    return 'EcoUnityBadge{id: $id, name: $name, description: $description, badgeimageurl: $badgeimageurl, color: $color, accesslevel: $accesslevel, requiredPathways: $requiredPathways}';
  }
}
