import 'dart:developer';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../../l10n/app_localizations_extension.dart';

final Map<String, Future<Image>> _imageFutureCache = {};

extension ImageFromUrl on Image {
  static Widget get(String url, {bool fillContainer = false}) {
    return FutureBuilder<Image>(
      future: _loadImage(url, fillContainer: fillContainer),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('${context.l10n.error}: ${snapshot.error}'),
          );
        } else if (snapshot.hasData) {
          return snapshot.data!;
        } else {
          return Center(child: Text(context.l10n.no_image_available));
        }
      },
    );
  }

  static Future<Image> _loadImage(String url, {bool fillContainer = false}) {
    final cacheKey = '$url|$fillContainer';
    return _imageFutureCache.putIfAbsent(
      cacheKey,
      () => _fetchImage(url, cacheKey: cacheKey, fillContainer: fillContainer),
    );
  }

  static Future<Image> _fetchImage(
    String url, {
    required String cacheKey,
    bool fillContainer = false,
  }) async {
    FileStorage fileStorage = FileStorage();
    String? imageName = url.split('/').last;
    if (imageName.contains('?')) {
      imageName = imageName.split('?')[0];
    }
    var imageData = await fileStorage.getObject(imageName, boxName: 'images');
    if (imageData != null) {
      if (kDebugMode) {
        log('Image found in local storage for $imageName');
      }
      return Image.memory(
        imageData,
        fit: fillContainer ? BoxFit.cover : BoxFit.contain,
      );
    }
    String? token =
        (await UserPreferences.user).token ??
        await Settings().getAnonymousApiKey();
    Map softwareInfo = {
      'appName': '',
      'packageName': '',
      'version': '',
      'buildNumber': '',
    };
    await PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      softwareInfo['appName'] = packageInfo.appName;
      softwareInfo['packageName'] = packageInfo.packageName;
      softwareInfo['version'] = packageInfo.version;
      softwareInfo['buildNumber'] = packageInfo.buildNumber;
    });
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-Mobile-App':
            '${softwareInfo['appName']} / ${softwareInfo['version']} ${softwareInfo['buildNumber']}',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        log('Saving image to local storage: $imageName');
      }
      await fileStorage.setObject(
        imageName,
        response.bodyBytes,
        boxName: 'images',
      );
      return fillContainer
          ? Image.memory(
              response.bodyBytes,
              fit: BoxFit.contain,
              width: double.infinity,
            )
          : Image.memory(response.bodyBytes, fit: BoxFit.contain);
    } else {
      _imageFutureCache.remove(cacheKey);
      throw Exception('Failed to load image');
    }
  }
}
