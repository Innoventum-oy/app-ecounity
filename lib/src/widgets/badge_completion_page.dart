
// Completion for a Page (Pathway)
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/src/objects/ecounity_badge.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
class BadgeCompletionPage extends StatelessWidget {
  final EcoUnityBadge badge;

  const BadgeCompletionPage({super.key, required this.badge});


  @override
  Widget build(BuildContext context) {
    if(kDebugMode){
      // log the badge
      log("Badge: $badge");
    }
    double maxWidth = MediaQuery.of(context).size.width*0.9;
    return SingleChildScrollView(child:Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Icon(Icons.shield, size: 40),
                Expanded(
                  child:Text(context.l10n.badge_awarded,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(Icons.shield, size: 40),
              ]
            ),
            // Article Thumbnail in Card if available
            
             Center(child: Card(
                child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: 400 ),
                    child:badge.badgeImage()
                ),
              ),
             ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(context.l10n.badge_awarded_congratulations(badge.name ?? context.l10n.unnamed)
                ),
              ),


          ],
        ),
        );
  }
}