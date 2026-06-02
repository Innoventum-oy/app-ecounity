import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:ecounity/src/util/router.dart';

Widget videoCard(BuildContext context, WebPage pathway, bool isCompleted, int navIndex,{WebPageList? pathways}) {
  // Return a card with the video thumbnail, title and possible description
  // If the pathway has thumbnailUrl, create network image, otherwise use assets/images/video.jpg
  Widget thumbnail = pathway.thumbnail != null
      ? pathway.imageBuilder(pathway.thumbnailImage)//Image.network(pathway.thumbnailUrl ?? '', fit: BoxFit.cover, width: double.infinity, height: double.infinity)
      : Image.asset('assets/images/video.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity);

  return GestureDetector(
    onTap: () {
      // Navigate to the video page
      AppRouter.navigate(context,pathway.type.name, navIndex,replaceRoute:false,data:pathway,pathways:pathways );
    },
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              thumbnail,
              // title and description
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(

                  color: Colors.black.withAlpha(128),

                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pathway.title, style: const TextStyle(color: Colors.white, fontSize: 18)),
                      if (pathway.description != null) Text(pathway.description ?? '', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              // if completed, show a checkmark
              if (isCompleted) const Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.check, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}