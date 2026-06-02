import 'package:flutter/material.dart';
import 'package:ecounity/src/objects/ecounity_badge.dart';

import '../../badge_view/badge_view.dart';


Widget badgeIconDisplay(EcoUnityBadge badge, BuildContext context) {
  String badgeUrl = badge.badgeimageurl ?? '';
  bool hasImage = badge.badgeimageurl != null ? true : false;
  //   print('showing badge image: '+badgeUrl);
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BadgeView(badge)),
      );
    },
    child: Column(

      //    mainAxisSize: MainAxisSize.max,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(35.0),
            child:  hasImage
                ? FadeInImage.assetNetwork(
              fit: BoxFit.cover,
              height: 70,
              width:70,
              placeholder: 'assets/images/ecounity-logo.png',
              image: badgeUrl,
            )
                : const Image(image: AssetImage('assets/images/ecounity-logo.png')),
          ),
          Text(
            overflow: TextOverflow.ellipsis,
            badge.name ?? '-',
            maxLines: 2,
            style: const TextStyle(fontSize: 14),


          ),
        ]),
  );
}