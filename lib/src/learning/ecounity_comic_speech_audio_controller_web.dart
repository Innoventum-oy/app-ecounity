import 'dart:async';
import 'dart:js_interop';

import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class EcoUnityComicSpeechAudioController {
  final Map<String, web.HTMLAudioElement> _audioCache =
      <String, web.HTMLAudioElement>{};
  final List<web.HTMLAudioElement> _activeAudio = <web.HTMLAudioElement>[];

  Future<void> prepareCues(List<EcoUnityComicSpeechItem> speechItems) async {
    final List<String> urls = _readyUrls(speechItems);
    if (urls.isEmpty) {
      return;
    }

    await Future.wait(urls.map(_prepareUrl));
  }

  Future<void> playCue(EcoUnityComicSpeechItem? speech) async {
    final String? url = speech?.audioFile?.url?.trim();
    final bool readyStatus =
        speech?.generationStatus == EcoUnitySpeechGenerationStatus.ready ||
        speech?.generationStatus ==
            EcoUnitySpeechGenerationStatus.updateRecommended;
    if (speech == null ||
        !speech.hasReadyAudio ||
        url == null ||
        url.trim().isEmpty) {
      if (kDebugMode && speech != null && readyStatus) {
        debugPrint(
          'Comic speech audio is ready but no playable URL was provided '
          '(speech id: ${speech.id ?? 'unknown'}, language: '
          '${speech.language}).',
        );
      }
      await stop();
      return;
    }

    web.HTMLAudioElement? audio;
    try {
      audio = _audioCache.remove(url) ?? _createAudio(url);
      audio.currentTime = 0;
      _activeAudio.add(audio);

      void cleanup() {
        final web.HTMLAudioElement? currentAudio = audio;
        if (currentAudio == null) {
          return;
        }
        _activeAudio.remove(currentAudio);
        currentAudio.pause();
        currentAudio.removeAttribute('src');
        currentAudio.load();
      }

      audio.addEventListener('ended', ((web.Event _) => cleanup()).toJS);
      audio.addEventListener('error', ((web.Event _) => cleanup()).toJS);

      await audio.play().toDart;
    } catch (exception, stackTrace) {
      if (audio != null) {
        _activeAudio.remove(audio);
      }
      if (kDebugMode) {
        debugPrint('Unable to play comic speech audio: $exception');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  Future<void> stop() async {
    try {
      for (final web.HTMLAudioElement audio in List<web.HTMLAudioElement>.from(
        _activeAudio,
      )) {
        audio.pause();
        audio.currentTime = 0;
        audio.removeAttribute('src');
        audio.load();
      }
      _activeAudio.clear();
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unable to stop comic speech audio: $exception');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  Future<void> dispose() async {
    await stop();
    for (final web.HTMLAudioElement audio in _audioCache.values) {
      audio.pause();
      audio.removeAttribute('src');
      audio.load();
    }
    _audioCache.clear();
  }

  web.HTMLAudioElement _audioForUrl(String url) {
    return _audioCache.putIfAbsent(url, () {
      final web.HTMLAudioElement audio = _createAudio(url);
      audio.addEventListener(
        'ended',
        ((web.Event _) {
          _activeAudio.remove(audio);
        }).toJS,
      );
      audio.addEventListener(
        'error',
        ((web.Event _) {
          _activeAudio.remove(audio);
        }).toJS,
      );
      audio.load();
      return audio;
    });
  }

  web.HTMLAudioElement _createAudio(String url) {
    final web.HTMLAudioElement audio =
        web.document.createElement('audio') as web.HTMLAudioElement;
    audio.preload = 'auto';
    audio.src = url;
    audio.load();
    return audio;
  }

  Future<void> _prepareUrl(String url) async {
    final web.HTMLAudioElement audio = _audioForUrl(url);
    if (audio.readyState >= 3) {
      return;
    }

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
      const Duration(seconds: 3),
      onTimeout: () {},
    );
  }
}

List<String> _readyUrls(List<EcoUnityComicSpeechItem> speechItems) {
  final Set<String> urls = <String>{};
  for (final EcoUnityComicSpeechItem speech in speechItems) {
    final String? url = speech.audioFile?.url?.trim();
    if (speech.hasReadyAudio && url != null && url.isNotEmpty) {
      urls.add(url);
    }
  }
  return urls.toList();
}
