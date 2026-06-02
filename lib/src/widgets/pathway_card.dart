import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:ecounity/src/util/app_theme.dart';

import '../../l10n/app_localizations_extension.dart';
import '../objects/pathway_stage.dart';
import '../util/router.dart';
/// Display a card for a pathway.
Widget pathwayCard(BuildContext context, WebPage pathway,bool isCompleted, int navIndex,{WebPageList? pathways}) {
  // Choose the specific ListTileThemeData based on some condition
  ListTileThemeData theme = Theme.of(context).listTileTheme;
  // Update the theme based on the pathway stage
  switch(pathway.stage){
    case PathwayStage.before:
      theme = Theme.of(context).listTileThemeBefore;
      break;
    case PathwayStage.after:
      theme = Theme.of(context).listTileThemeAfter;
      break;
    case PathwayStage.during:
      theme = Theme.of(context).listTileThemeDuring;
      break;
    case PathwayStage.any:
    // no change
      break;
  }
  Widget? trailing = isCompleted ? const Icon(Icons.check) :null;
  if(kDebugMode){
    trailing = IconButton(onPressed: () {
      pathway.toggleCompleted(context);
    },
      icon: isCompleted ? const Icon(Icons.check) : const Icon(Icons.close),
      tooltip: isCompleted ? context.l10n.mark_as_not_completed : context.l10n.mark_as_completed,
    );
  }
  return Card(
    child: ListTileTheme(
      data: theme,

      child: ListTile(
        // apply style based on the pathway stage: listTileThemeBefore / listTileThemeAfter / listTileThemeDuring

        leading: pathway.icon,
        title: Text(pathway.title),
        subtitle: pathway.description != null ? Text(pathway.description!) : null,
        trailing:  trailing,
        onTap: () async{
          //  await markCompleted(pathway);
          // navigate to view depending on the type
          // TODO set up pathway types for submodules and resources?
          if(pathway.isSubModule) {
            AppRouter.navigate(context, 'submodules', navIndex, replaceRoute: false, data: pathway, pathways: pathways);
          }
          else if(pathway.isMainResource) {
            AppRouter.navigate(context, 'resources', navIndex, replaceRoute: false, data: pathway, pathways: pathways);
          }
          else {
            AppRouter.navigate(context, pathway.type.name, navIndex, replaceRoute: false, data: pathway, pathways: pathways,);
          }

        },
      ),
    ),
  );
}