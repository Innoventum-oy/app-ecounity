import 'dart:developer';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../../l10n/app_localizations_extension.dart';

final Map<String, Future<_LoadedImageBytes>> _imageFutureCache = {};

extension ImageFromUrl on Image {
  static Widget get(
    String url, {
    bool fillContainer = false,
    Key? loadedKey,
    WidgetBuilder? loadingBuilder,
    Widget Function(BuildContext context, Object error)? errorBuilder,
    WidgetBuilder? emptyBuilder,
  }) {
    return FutureBuilder<_LoadedImageBytes>(
      future: _loadImage(url, fillContainer: fillContainer),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error!) ??
              Center(child: Text('${context.l10n.error}: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return _FrameAwareImage(
            bytes: snapshot.data!.bytes,
            fillContainer: fillContainer,
            loadedKey: loadedKey,
          );
        } else {
          return emptyBuilder?.call(context) ??
              Center(child: Text(context.l10n.no_image_available));
        }
      },
    );
  }

  static Future<_LoadedImageBytes> _loadImage(
    String url, {
    bool fillContainer = false,
  }) {
    final cacheKey = '$url|$fillContainer';
    return _imageFutureCache.putIfAbsent(
      cacheKey,
      () => _fetchImage(url, cacheKey: cacheKey),
    );
  }

  static Future<_LoadedImageBytes> _fetchImage(
    String url, {
    required String cacheKey,
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
      return _LoadedImageBytes(_asUint8List(imageData));
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
      return _LoadedImageBytes(response.bodyBytes);
    } else {
      _imageFutureCache.remove(cacheKey);
      throw Exception('Failed to load image');
    }
  }

  static Uint8List _asUint8List(dynamic value) {
    if (value is Uint8List) {
      return value;
    }
    if (value is List<int>) {
      return Uint8List.fromList(value);
    }
    throw Exception('Stored image data is not bytes');
  }
}

class _LoadedImageBytes {
  final Uint8List bytes;

  const _LoadedImageBytes(this.bytes);
}

class _FrameAwareImage extends StatelessWidget {
  final Uint8List bytes;
  final bool fillContainer;
  final Key? loadedKey;

  const _FrameAwareImage({
    required this.bytes,
    required this.fillContainer,
    required this.loadedKey,
  });

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      bytes,
      fit: fillContainer ? BoxFit.cover : BoxFit.contain,
      width: fillContainer ? double.infinity : null,
      frameBuilder: loadedKey == null
          ? null
          : (context, child, frame, wasSynchronouslyLoaded) {
              final bool imageIsReady = wasSynchronouslyLoaded || frame != null;
              if (!imageIsReady) {
                return const Center(child: CircularProgressIndicator());
              }
              return KeyedSubtree(key: loadedKey, child: child);
            },
    );
  }
}
