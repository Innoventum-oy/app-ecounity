import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';
import 'package:ecounity/src/widgets/webpage_screen.dart';
import '../../../widgets/screen_footer.dart';
import 'components/youtube_player_widget.dart';

/// Video widget, containing a video player and Video transcript
class Video extends WebpageScreen {
  const Video({
    super.key,
    required super.navIndex,
    required super.webPage,
    super.openIntroduction = false,
    super.skipAutoIntroduction = false,
    super.pathways,
  });
  @override
  WebpageScreenState createState() => VideoState();
}

class VideoState extends WebpageScreenState<Video> {
  bool _blockYoutubeInteraction = false;

  @override
  Widget buildScreen(BuildContext context) {
    final bool isContentCompleted = status == PathwayStatus.completed;
    var video = widget.webPage;
    // Prepare video player; The video.video contains Youtube url.
    // Use the youtube_player_iframe class
    if (video.videoUrl == null) {
      //return const Text('No video found');
      return ScreenScaffold(
        title: video.title,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(context.l10n.no_video_found),
            ),
          ],
        ),
      );
    } else if (kDebugMode) {
      log('Video url: ${video.videoUrl}', name: 'VideoState.buildScreen');
    }
    return ScreenScaffold(
      key: const ValueKey('screenshot-content-video-screen'),
      title: video.title,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Video player
            Padding(
              padding: EdgeInsets.all(4.0),
              child: IgnorePointer(
                ignoring: _blockYoutubeInteraction,
                child: YoutubePlayerWidget(
                  url: video.videoUrl!,
                  language: Localizations.localeOf(context).toString(),
                  title: video.title,
                ),
              ),
            ),
            // Video transcript
            FutureBuilder<Widget?>(
              future: video.contents,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error == null
                          ? context.l10n.noTranscriptAvailable
                          : '${context.l10n.error}: ${snapshot.error}',
                    ),
                  );
                }
                return KeyedSubtree(
                  key: const ValueKey('screenshot-content-video-loaded'),
                  child:
                      snapshot.data ?? Text(context.l10n.noTranscriptAvailable),
                );
              },
            ),
            ScreenFooter(
              webPage: widget.webPage,
              navIndex: widget.navIndex,
              pathways: widget.pathways,
              isCompleted: isContentCompleted,
              showOpenIntroduction: true,
              showMarkCompleted: true,
              onCompletionDialogShow: () {
                if (!mounted) {
                  return;
                }
                setState(() {
                  _blockYoutubeInteraction = true;
                });
              },
              onCompletionDialogHide: () {
                if (!mounted) {
                  return;
                }
                setState(() {
                  _blockYoutubeInteraction = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
