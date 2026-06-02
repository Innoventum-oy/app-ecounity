
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:ecounity/src/objects/ecounity_badge.dart';
import 'badge_display.dart';
List<Widget> badgeDisplays(List<EcoUnityBadge> badges, int activityCount,BuildContext context) {

  List<Widget> data = [];
  bool firstVisibleBadgeSet = false;
  if (badges.isEmpty) {
    if(kDebugMode) {
      log("No badges passed to badgeDisplays widget");
    }
    return data;
  }
    for (var badge in badges) {

      Key badgeKey = Key('badge-${badge.id}');
      data.add(badgeDisplay(badge, activityCount, badgeKey,context));
      if (!firstVisibleBadgeSet) {
        double percentage = badge.getValue('requiredactivities') != null
            ? activityCount / int.parse(badge.getValue('requiredactivities'))
            : 1;
        if (percentage < 1) {
          //ensure this badge is visible
          // print('ensuring badge '+badge.name+' should be visible, percentage is '+percentage.toString());
          firstVisibleBadgeSet = true;
          if (context.mounted) {
            Scrollable.ensureVisible(context);
          }
        }
      }
    }
    return data;
  }
