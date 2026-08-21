import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:core/core.dart' as core;
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:web/web.dart' as web;

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
  final Map<String, web.HTMLAudioElement> _audioElements =
      <String, web.HTMLAudioElement>{};
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
    final web.HTMLAudioElement audio = _audioElements.putIfAbsent(
      url,
      () => _createAudio(url),
    );
    if (audio.readyState < 3) {
      await _waitForPlayableAudio(audio);
    }
    return EcoUnityCachedMedia(
      url: url,
      playableUrl: url,
      fromCache: audio.readyState >= 3,
    );
  }

  web.HTMLAudioElement _createAudio(String url) {
    final web.HTMLAudioElement audio =
        web.document.createElement('audio') as web.HTMLAudioElement;
    audio.preload = 'auto';
    audio.src = url;
    audio.load();
    return audio;
  }

  Future<void> _waitForPlayableAudio(web.HTMLAudioElement audio) async {
    final Completer<void> completer = Completer<void>();
    void complete() {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    audio.addEventListener(
      'canplaythrough',
      ((web.Event _) => complete()).toJS,
    );
    audio.addEventListener('canplay', ((web.Event _) => complete()).toJS);
    audio.addEventListener('loadeddata', ((web.Event _) => complete()).toJS);
    audio.addEventListener('error', ((web.Event _) => complete()).toJS);
    audio.load();

    await completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {},
    );
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
