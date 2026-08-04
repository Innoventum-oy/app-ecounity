import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubePlayerWidget extends StatefulWidget {
  final String url;
  final String language;
  final String title;

  const YoutubePlayerWidget({
    super.key,
    required this.url,
    required this.language,
    required this.title,
  });

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );

    _controller.setFullScreenListener((isFullScreen) {
      if (kDebugMode) {
        log('${isFullScreen ? 'Entered' : 'Exited'} Fullscreen.');
      }
    });

    _controller
        .loadVideo(widget.url)
        .catchError((error) {
          if (kDebugMode) {
            log('Error loading video: $error');
          }
        })
        .then((_) {
          if (kDebugMode) {
            log('Video loaded successfully');
          }
        })
        .catchError((error) {
          if (kDebugMode) {
            log('Error loading video: $error');
          }
        });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      log(
        'Building YoutubePlayerWidget (web iframe), attempting to play ${widget.url}',
      );
    }
    return YoutubePlayer(controller: _controller);
  }
}
