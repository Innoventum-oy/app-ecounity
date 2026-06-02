

import 'dart:developer';

import 'package:core/core.dart' as core;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../objects/ecounity_badge.dart';

class EcoUnityBadgeProvider extends core.BadgeProvider<EcoUnityBadge> {
  EcoUnityBadgeProvider();

  @override
  Future<List<EcoUnityBadge>> loadItems(params) async {

    String filename = md5.convert(utf8.encode(params.toString())).toString();
    dynamic remoteData =  await apiClient.getDataList('badge', params);

    final List<EcoUnityBadge> badges = (remoteData == null || remoteData.isEmpty) ? [] : remoteData.map<EcoUnityBadge>((data) => EcoUnityBadge.fromJson(data)).toList();

    loadingStatus = core.DataLoadingStatus.loaded;
    if(kDebugMode){
      // log the number of badges loaded
      log('Loaded ${badges.length} badges',name:'EcoUnityBadgeProvider');
    }
    //Set loaded data to storage
    core.FileStorage().setObject(filename,remoteData, boxName:objectType);
    loadingStatus = core.DataLoadingStatus.loaded;
    notifyListeners();
    return badges;

  }

  /// Load list of Badges
  @override
  Future<List<EcoUnityBadge>> loadBadges(Map<String, dynamic> params) async {
    // First check storage

    return apiClient.getDataList('badge', params).then(( data) {
      if (data == null) return [];

      notifyListeners();
      return data.map<EcoUnityBadge>((item) => EcoUnityBadge.fromJson(item as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future saveObject(int? objectId, Map? objectData, {String? objectType}) async {
    String type = objectType ?? this.objectType;
    return apiClient.saveObject(objectId ?? current?.data?['objectid'],type, objectData ?? current!.data!);
  }

}