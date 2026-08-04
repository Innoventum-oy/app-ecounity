import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/src/objects/pathway.dart';
import '../../l10n/app_localizations_extension.dart';
import '../util/router.dart';

/// Display a card for a pathway.
Widget resourceCard(
  BuildContext context,
  WebPage resource,
  bool isCompleted,
  int navIndex, {
  WebPageList? resources,
}) {
  // Choose the specific ListTileThemeData based on some condition
  ListTileThemeData theme = Theme.of(context).listTileTheme;

  Widget? trailing = isCompleted ? const Icon(Icons.check) : null;
  if (kDebugMode) {
    trailing = IconButton(
      onPressed: () {
        resource.toggleCompleted(context);
      },
      icon: isCompleted ? const Icon(Icons.check) : const Icon(Icons.close),
      tooltip: isCompleted
          ? context.l10n.mark_as_not_completed
          : context.l10n.mark_as_completed,
    );
  }
  return Card(
    child: ListTileTheme(
      data: theme,

      child: ListTile(
        leading: resource.icon,
        title: Text(resource.title),
        subtitle: resource.description != null
            ? Text(resource.description!)
            : null,
        trailing: trailing,
        onTap: () async {
          //  await markCompleted(pathway);
          // navigate to view depending on the type

          AppRouter.navigate(
            context,
            resource.type.name,
            navIndex,
            replaceRoute: false,
            data: resource,
            pathways: resources,
          );
        },
      ),
    ),
  );
}
