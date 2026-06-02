
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:core/core.dart' as core;
import 'package:ecounity/src/widgets/screenscaffold.dart';
import 'package:ecounity/src/widgets/webpage_screen.dart';
import '../../../widgets/mark_pathway_completed.dart';
import 'components/youtube_player_widget.dart';
/// Video widget, containing a video player and Video transcript
class Video extends WebpageScreen {

  const Video({super.key, required super.navIndex, required super.webPage, super.openIntroduction = false,super.pathways});
  @override
  WebpageScreenState createState() => VideoState();
}
class VideoState extends WebpageScreenState<Video> {

  @override
  Widget buildScreen(BuildContext context,{List<Widget> buttons = const []}) {
    core.WebPage video = widget.webPage;
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
              child: Text(context.l10n.no_video_found)
            ),
          ],
        ),
      );
    }
    else if(kDebugMode){
      log('Video url: ${video.videoUrl}',
          name: 'VideoState.buildScreen');
    }
    return ScreenScaffold(
      title: video.title,
      child: SingleChildScrollView(
      child:
      Column(
        children: [
          // Video player
          Padding(
            padding: EdgeInsets.all(4.0),
            child: YoutubePlayerWidget(
              url: video.videoUrl!,
              language: Localizations.localeOf(context).toString(),
              title: video.title,
            )),
          // Video transcript
          video.contents ?? Text(context.l10n.noTranscriptAvailable),
          // Completion button (completePathwayButton in a FutureBuilder)
          Consumer<core.FileStorage>(
            builder: (context, fileStorage, child) {
              return FutureBuilder(
                future: completePathwayButton(context, video,fileStorage),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    } else {
                      return Text(context.l10n.error_loading_button);
                    }
                  }
                  return const CircularProgressIndicator();
                },
                initialData: const CircularProgressIndicator(),
              );
            },
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
            // Previous button
            buttons
            ,
          ),
        ],
      ),
      )
    );
  }
}