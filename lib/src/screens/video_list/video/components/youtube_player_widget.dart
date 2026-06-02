
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../../l10n/app_localizations_extension.dart';

class YoutubePlayerWidget extends StatefulWidget {

  final String url;
  final String language;
  final String title;
  const YoutubePlayerWidget({super.key, required this.url, required this.language, required this.title});

  @override
  YoutubePlayerWidgetState createState() => YoutubePlayerWidgetState ();
}

class YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: YoutubePlayerParams(
        captionLanguage: widget.language,
        interfaceLanguage:  widget.language,
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );

    _controller.setFullScreenListener(
          (isFullScreen) {
            if(kDebugMode){
              log('${isFullScreen ? 'Entered' : 'Exited'} Fullscreen.');
            }
      }
    );

      _controller.loadVideo(widget.url).catchError((error){
        if(kDebugMode){
          log('Error loading video: $error');
        }
      }).then((value) {
        if(kDebugMode){
          log('Video loaded successfully');
        }
      }).catchError((error) {
        if(kDebugMode){
          log('Error loading video: $error');
        }
      });

    // test with id
//    _controller.loadVideoById(videoId: '3kdn2yk6nss');

  }
  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    if(kDebugMode){
      log('Building YoutubePlayerWidget, attempting to play ${widget.url}');
    }
      return YoutubePlayer(
        controller: _controller,

      );
    }
  }



///
class VideoPositionIndicator extends StatelessWidget {
  ///
  const VideoPositionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.ytController;

    return StreamBuilder<YoutubeVideoState>(
      stream: controller.videoStateStream,
      initialData: const YoutubeVideoState(),
      builder: (context, snapshot) {
        final position = snapshot.data?.position.inMilliseconds ?? 0;
        final duration = controller.metadata.duration.inMilliseconds;

        return LinearProgressIndicator(
          value: duration == 0 ? 0 : position / duration,
          minHeight: 1,
        );
      },
    );
  }
}

///
class VideoPositionSeeker extends StatelessWidget {
  ///
  const VideoPositionSeeker({super.key});

  @override
  Widget build(BuildContext context) {
    var value = 0.0;

    return Row(
      children: [
        Text(
          context.l10n.seek,
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: StreamBuilder<YoutubeVideoState>(
            stream: context.ytController.videoStateStream,
            initialData: const YoutubeVideoState(),
            builder: (context, snapshot) {
              final position = snapshot.data?.position.inSeconds ?? 0;
              final duration = context.ytController.metadata.duration.inSeconds;

              value = position == 0 || duration == 0 ? 0 : position / duration;

              return StatefulBuilder(
                builder: (context, setState) {
                  return Slider(
                    value: value,
                    onChanged: (positionFraction) {
                      value = positionFraction;
                      setState(() {});

                      context.ytController.seekTo(
                        seconds: (value * duration).toDouble(),
                        allowSeekAhead: true,
                      );
                    },
                    min: 0,
                    max: 1,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}