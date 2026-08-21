import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/core.dart' as core;
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

enum EcoUnityMediaKind { image, audio, other }

class EcoUnityCachedMedia {
  const EcoUnityCachedMedia({
    required this.url,
    required this.playableUrl,
    this.bytes,
    this.localPath,
    this.fromCache = false,
  });

  final String url;
  final String playableUrl;
  final Uint8List? bytes;
  final String? localPath;
  final bool fromCache;
}

class EcoUnityMediaCache {
  factory EcoUnityMediaCache() {
    return _instance;
  }

  EcoUnityMediaCache._();

  static final EcoUnityMediaCache _instance = EcoUnityMediaCache._();
  static const String _boxName = 'ecounityMediaCache';

  final core.FileStorage _fileStorage = core.FileStorage();
  final http.Client _httpClient = http.Client();
  final Map<String, Future<Uint8List>> _byteFutures =
      <String, Future<Uint8List>>{};
  final Map<String, Future<EcoUnityCachedMedia>> _audioFutures =
      <String, Future<EcoUnityCachedMedia>>{};
  Future<Map<String, String>>? _appHeadersFuture;

  Future<Uint8List> loadImageBytes(String url) {
    return loadBytes(url, kind: EcoUnityMediaKind.image);
  }

  Future<void> prepareImageUrls(Iterable<String> urls) async {
    await Future.wait(
      urls
          .map(_normalizeUrl)
          .where((String url) => url.isNotEmpty)
          .toSet()
          .map(loadImageBytes),
    );
  }

  Future<Uint8List> loadBytes(
    String url, {
    EcoUnityMediaKind kind = EcoUnityMediaKind.other,
  }) {
    final String normalizedUrl = _normalizeUrl(url);
    final String key = _bytesStorageKey(normalizedUrl, kind);
    return _byteFutures.putIfAbsent(
      key,
      () => _loadBytes(normalizedUrl, key: key),
    );
  }

  Future<EcoUnityCachedMedia> prepareAudio(String url) {
    final String normalizedUrl = _normalizeUrl(url);
    final String key = _bytesStorageKey(normalizedUrl, EcoUnityMediaKind.audio);
    return _audioFutures.putIfAbsent(key, () => _prepareAudio(normalizedUrl));
  }

  Future<void> prepareAudioUrls(Iterable<String> urls) async {
    await Future.wait(
      urls
          .map(_normalizeUrl)
          .where((String url) => url.isNotEmpty)
          .toSet()
          .map(prepareAudio),
    );
  }

  Future<Uint8List> _loadBytes(String url, {required String key}) async {
    final Object? stored = await _fileStorage.getObject(key, boxName: _boxName);
    if (stored != null) {
      return _asUint8List(stored);
    }

    final http.Response response = await _httpClient.get(
      Uri.parse(url),
      headers: await _requestHeaders(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _byteFutures.remove(key);
      throw Exception('Failed to load media: HTTP ${response.statusCode}');
    }

    final Uint8List bytes = response.bodyBytes;
    await _fileStorage.setObject(key, bytes, boxName: _boxName);
    return bytes;
  }

  Future<EcoUnityCachedMedia> _prepareAudio(String url) async {
    final Uint8List bytes = await loadBytes(url, kind: EcoUnityMediaKind.audio);
    final File file = await _audioCacheFile(url, bytes);
    final bool existed = await file.exists();
    if (!existed || await file.length() != bytes.length) {
      await file.writeAsBytes(bytes, flush: false);
    }

    return EcoUnityCachedMedia(
      url: url,
      playableUrl: file.uri.toString(),
      bytes: bytes,
      localPath: file.path,
      fromCache: existed,
    );
  }

  Future<File> _audioCacheFile(String url, Uint8List bytes) async {
    final Directory baseDirectory = await getApplicationSupportDirectory();
    String serverName = 'default';
    try {
      serverName = await core.Settings().getServerName();
    } catch (_) {
      // Keep a deterministic fallback if settings are unavailable in tests.
    }
    final Directory cacheDirectory = Directory(
      '${baseDirectory.path}/ecounity_media_cache/${_safePathPart(serverName)}',
    );
    if (!await cacheDirectory.exists()) {
      await cacheDirectory.create(recursive: true);
    }
    final String key = cacheKeyForUrl(url);
    final String extension = _extensionForUrl(url, fallback: '.audio');
    return File('${cacheDirectory.path}/$key$extension');
  }

  Future<Map<String, String>> _requestHeaders() async {
    final Map<String, String> appHeaders = await (_appHeadersFuture ??=
        _loadAppHeaders());
    final String? token =
        (await core.UserPreferences.user).token ??
        await core.Settings().getAnonymousApiKey();
    return <String, String>{
      ...appHeaders,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> _loadAppHeaders() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return <String, String>{
      'X-Mobile-App':
          '${packageInfo.appName} / ${packageInfo.version} '
          '${packageInfo.buildNumber}',
    };
  }
}

String cacheKeyForUrl(String url) {
  return sha1.convert(utf8.encode(_normalizeUrl(url))).toString();
}

String _bytesStorageKey(String url, EcoUnityMediaKind kind) {
  return 'bytes:${kind.name}:${cacheKeyForUrl(url)}';
}

String _normalizeUrl(String url) {
  return url.trim();
}

Uint8List _asUint8List(Object value) {
  if (value is Uint8List) {
    return value;
  }
  if (value is List<int>) {
    return Uint8List.fromList(value);
  }
  throw Exception('Stored media data is not bytes');
}

String _extensionForUrl(String url, {required String fallback}) {
  final Uri? uri = Uri.tryParse(url);
  final String path = uri?.path ?? url.split('?').first;
  final int dotIndex = path.lastIndexOf('.');
  if (dotIndex < 0 || dotIndex == path.length - 1) {
    return fallback;
  }
  final String extension = path.substring(dotIndex).toLowerCase();
  final bool safe =
      extension.length >= 3 &&
      extension.length <= 9 &&
      extension.startsWith('.') &&
      extension.codeUnits.skip(1).every(_isLowercaseAsciiLetterOrDigit);
  return safe ? extension : fallback;
}

String _safePathPart(String value) {
  final String normalized = value.trim().toLowerCase();
  final StringBuffer buffer = StringBuffer();
  for (final int codeUnit in normalized.codeUnits) {
    buffer.write(
      _isSafePathCodeUnit(codeUnit) ? String.fromCharCode(codeUnit) : '_',
    );
  }
  return buffer.toString();
}

bool _isSafePathCodeUnit(int codeUnit) {
  return _isLowercaseAsciiLetterOrDigit(codeUnit) ||
      codeUnit == 45 ||
      codeUnit == 46 ||
      codeUnit == 95;
}

bool _isLowercaseAsciiLetterOrDigit(int codeUnit) {
  return (codeUnit >= 97 && codeUnit <= 122) ||
      (codeUnit >= 48 && codeUnit <= 57);
}
