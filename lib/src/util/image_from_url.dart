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
    VoidCallback? onReady,
  }) {
    return FutureBuilder<_LoadedImageBytes>(
      future: _loadImage(url, fillContainer: fillContainer),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _withImageReady(
            errorBuilder?.call(context, snapshot.error!) ??
                Center(child: Text('${context.l10n.error}: ${snapshot.error}')),
            onReady,
          );
        } else if (snapshot.hasData) {
          return _FrameAwareImage(
            bytes: snapshot.data!.bytes,
            fillContainer: fillContainer,
            loadedKey: loadedKey,
            onReady: onReady,
          );
        } else {
          return _withImageReady(
            emptyBuilder?.call(context) ??
                Center(child: Text(context.l10n.no_image_available)),
            onReady,
          );
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

class _FrameAwareImage extends StatefulWidget {
  final Uint8List bytes;
  final bool fillContainer;
  final Key? loadedKey;
  final VoidCallback? onReady;

  const _FrameAwareImage({
    required this.bytes,
    required this.fillContainer,
    required this.loadedKey,
    required this.onReady,
  });

  @override
  State<_FrameAwareImage> createState() => _FrameAwareImageState();
}

class _FrameAwareImageState extends State<_FrameAwareImage> {
  bool _readyNotified = false;

  @override
  void didUpdateWidget(covariant _FrameAwareImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.bytes, widget.bytes) ||
        oldWidget.onReady != widget.onReady) {
      _readyNotified = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      widget.bytes,
      fit: widget.fillContainer ? BoxFit.cover : BoxFit.contain,
      width: widget.fillContainer ? double.infinity : null,
      frameBuilder: widget.loadedKey == null && widget.onReady == null
          ? null
          : (context, child, frame, wasSynchronouslyLoaded) {
              final bool imageIsReady = wasSynchronouslyLoaded || frame != null;
              if (!imageIsReady) {
                return const Center(child: CircularProgressIndicator());
              }
              _notifyReady();
              final Key? loadedKey = widget.loadedKey;
              if (loadedKey == null) {
                return child;
              }
              return KeyedSubtree(key: loadedKey, child: child);
            },
    );
  }

  void _notifyReady() {
    if (_readyNotified) {
      return;
    }
    _readyNotified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onReady?.call();
    });
  }
}

Widget _withImageReady(Widget child, VoidCallback? onReady) {
  if (onReady == null) {
    return child;
  }
  return _ImageReadyCallback(onReady: onReady, child: child);
}

class _ImageReadyCallback extends StatefulWidget {
  const _ImageReadyCallback({required this.onReady, required this.child});

  final VoidCallback onReady;
  final Widget child;

  @override
  State<_ImageReadyCallback> createState() => _ImageReadyCallbackState();
}

class _ImageReadyCallbackState extends State<_ImageReadyCallback> {
  bool _readyNotified = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifyReady();
  }

  @override
  void didUpdateWidget(covariant _ImageReadyCallback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onReady != widget.onReady) {
      _readyNotified = false;
      _notifyReady();
    }
  }

  void _notifyReady() {
    if (_readyNotified) {
      return;
    }
    _readyNotified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
