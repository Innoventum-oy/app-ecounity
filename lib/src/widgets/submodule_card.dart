import 'dart:developer';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/src/objects/pathway.dart';

import '../../l10n/app_localizations_extension.dart';
import '../util/router.dart';

/// Display a card for a module.
Widget subModuleCard(
  BuildContext context,
  WebPage module,
  bool isCompleted,
  int navIndex, {
  WebPageList? modules,
}) {
  ListTileThemeData theme = Theme.of(context).listTileTheme;

  Widget? trailing = isCompleted ? const Icon(Icons.check) : null;
  if (kDebugMode) {
    trailing = IconButton(
      onPressed: () {
        module.toggleCompleted(context);
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
        leading: module.icon,
        title: Text(module.title),
        subtitle: module.description != null ? Text(module.description!) : null,
        trailing: trailing,
        onTap: () async {
          if (kDebugMode) {
            log(
              'module: ${module.type.name}, navIndex: $navIndex, replaceRoute: false, data: ${module.toString()}, pathways: $modules',
            );
          }
          AppRouter.navigate(
            context,
            module.type.name,
            navIndex,
            replaceRoute: false,
            data: module,
            pathways: modules,
          );
        },
      ),
    ),
  );
}
