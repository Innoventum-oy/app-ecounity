import 'dart:async';

import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/util/ecounity_media_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class EcoUnityComicSpeechAudioController {
  final EcoUnityMediaCache _mediaCache = EcoUnityMediaCache();
  final Map<String, AudioPlayer> _preparedPlayers = <String, AudioPlayer>{};
  final List<AudioPlayer> _activePlayers = <AudioPlayer>[];

  Future<void> prepareCues(List<EcoUnityComicSpeechItem> speechItems) async {
    final List<String> urls = _readyUrls(speechItems);
    if (urls.isEmpty) {
      return;
    }

    await Future.wait(urls.map(_prepareUrl));
  }

  Future<void> _prepareUrl(String url) async {
    if (_preparedPlayers.containsKey(url)) {
      return;
    }
    final AudioPlayer audioPlayer = AudioPlayer();
    _preparedPlayers[url] = audioPlayer;
    try {
      await _setPlayerSource(audioPlayer, await _mediaCache.prepareAudio(url));
    } catch (exception, stackTrace) {
      _preparedPlayers.remove(url);
      await audioPlayer.dispose();
      if (kDebugMode) {
        debugPrint('Unable to prepare comic speech audio: $exception');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
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

    try {
      final AudioPlayer audioPlayer =
          _preparedPlayers.remove(url) ?? AudioPlayer();
      _activePlayers.add(audioPlayer);
      if (audioPlayer.audioSource == null) {
        await _setPlayerSource(
          audioPlayer,
          await _mediaCache.prepareAudio(url),
        );
      } else {
        await audioPlayer.seek(Duration.zero);
      }
      unawaited(
        audioPlayer.playerStateStream
            .firstWhere(
              (PlayerState state) =>
                  state.processingState == ProcessingState.completed,
            )
            .then((_) => _disposeActivePlayer(audioPlayer)),
      );
      await audioPlayer.play();
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unable to play comic speech audio: $exception');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  Future<void> stop() async {
    try {
      for (final AudioPlayer audioPlayer in List<AudioPlayer>.from(
        _activePlayers,
      )) {
        await audioPlayer.stop();
        await _disposeActivePlayer(audioPlayer);
      }
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unable to stop comic speech audio: $exception');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  Future<void> dispose() async {
    await stop();
    for (final AudioPlayer audioPlayer in _preparedPlayers.values) {
      await audioPlayer.dispose();
    }
    _preparedPlayers.clear();
  }

  Future<void> _disposeActivePlayer(AudioPlayer audioPlayer) async {
    if (!_activePlayers.remove(audioPlayer)) {
      return;
    }
    await audioPlayer.dispose();
  }

  Future<void> _setPlayerSource(
    AudioPlayer audioPlayer,
    EcoUnityCachedMedia media,
  ) async {
    final String? localPath = media.localPath;
    if (localPath != null && localPath.isNotEmpty) {
      await audioPlayer.setFilePath(localPath);
      return;
    }
    await audioPlayer.setUrl(media.playableUrl);
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
