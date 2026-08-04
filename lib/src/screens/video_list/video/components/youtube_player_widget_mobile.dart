import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  late final String _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = _extractVideoId(widget.url);
    if (_videoId.isEmpty && kDebugMode) {
      log('Could not parse video id from url ${widget.url}');
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: _videoId,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        enableCaption: false,
        loop: false,
        playsInline: true,
      ),
      autoPlay: false,
    );
  }

  String _extractVideoId(String url) {
    final String extractedId =
        YoutubePlayerController.convertUrlToId(url) ?? '';
    if (extractedId.isNotEmpty) {
      return extractedId;
    }

    final RegExp urlPattern = RegExp(
      r'(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?|shorts)\/|.*[?&]v=)|youtu\.be\/)([A-Za-z0-9_-]{6,})',
      caseSensitive: false,
    );
    final RegExpMatch? match = urlPattern.firstMatch(url);
    return match == null ? '' : match.group(1) ?? '';
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Unable to load this video.'),
        ),
      );
    }

    if (kDebugMode) {
      log(
        'Building YoutubePlayerWidget (native), attempting to play ${widget.url}',
      );
    }
    return YoutubePlayer(
      controller: _controller,
      autoFullScreen: false,
      enableFullScreenOnVerticalDrag: false,
    );
  }
}
