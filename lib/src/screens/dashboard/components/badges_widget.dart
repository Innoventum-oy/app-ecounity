import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/objects/ecounity_badge.dart';
import '../../../util/router.dart';
import 'badge_displays.dart';
import 'package:core/core.dart' as core;

Widget dashboardBadgesWidget(core.User user, List<EcoUnityBadge> badges, BuildContext context) {
  return  ListTile(
    visualDensity: const VisualDensity(vertical: VisualDensity.maximumDensity),
    onTap: () {
      AppRouter.navigate(context, '/achievements', 0, replaceRoute: false);
    },
    title: Text(
      context.l10n.achievements,
      style: const TextStyle(fontSize: 20),
    ),
    trailing: badges.isNotEmpty
        ? SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: badgeDisplays(
          badges,
          user.getValue('activitycount') ?? 0,
          context,
        ),
      ),
    )
        : const Icon(Icons.shield),
  );


}