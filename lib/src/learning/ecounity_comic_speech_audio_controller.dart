import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class EcoUnityComicSpeechAudioController {
  EcoUnityComicSpeechAudioController({AudioPlayer? audioPlayer})
    : _audioPlayer = audioPlayer ?? AudioPlayer();

  final AudioPlayer _audioPlayer;
  String? _currentUrl;

  Future<void> playCue(EcoUnityComicSpeechItem? speech) async {
    final String? url = speech?.audioFile?.url;
    if (speech == null ||
        !speech.hasReadyAudio ||
        url == null ||
        url.trim().isEmpty) {
      await stop();
      return;
    }

    try {
      if (_currentUrl != url) {
        await _audioPlayer.stop();
        await _audioPlayer.setUrl(url);
        _currentUrl = url;
      } else {
        await _audioPlayer.seek(Duration.zero);
      }
      await _audioPlayer.play();
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unable to play comic speech audio: $exception');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (exception, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unable to stop comic speech audio: $exception');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
