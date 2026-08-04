import 'package:core/core.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/widgets/popupdialog.dart';
import 'package:flutter/material.dart';

import '../objects/pathway.dart';
import 'completion_page.dart';

ElevatedButton activeButton(
  BuildContext context,
  WebPage pathway, {
  VoidCallback? onDialogShow,
  VoidCallback? onDialogHide,
}) {
  return ElevatedButton.icon(
    label: Text(context.l10n.markAsCompleted),
    icon: const Icon(Icons.check),
    onPressed: () async {
      await pathway.setStatus(PathwayStatus.completed, context);
      if (context.mounted) {
        // if the pathway has completion text, show completion popup
        onDialogShow?.call();
        try {
          await popupDialog(
            context.l10n.pathway_completed,
            CompletionPage(pathway: pathway),
            context,
          );
        } finally {
          onDialogHide?.call();
        }
      }
    },
  );
}

ElevatedButton inactiveButton(BuildContext context) {
  return ElevatedButton.icon(
    // set style to disabled
    style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.grey)),
    icon: const Icon(Icons.check),

    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pathway_already_completed)),
      );
    },
    label: Text(context.l10n.pathway_already_completed),
  );
}

Future<Widget> completePathwayButton(
  BuildContext context,
  WebPage pathway,
  FileStorage fileStorage, {
  VoidCallback? onDialogShow,
  VoidCallback? onDialogHide,
}) async {
  final String loadingLabel = context.l10n.error_loading_button;
  try {
    final bool completed = await pathway.status == PathwayStatus.completed;
    if (!context.mounted) return const SizedBox();
    return completed
        ? inactiveButton(context)
        : activeButton(
            context,
            pathway,
            onDialogShow: onDialogShow,
            onDialogHide: onDialogHide,
          );
  } catch (e) {
    if (!context.mounted) return const SizedBox();
    return Text(loadingLabel);
  }
}

Future<Widget> openPathwayButton(
  BuildContext context,
  WebPage pathway, {
  Future<void> Function()? onClosed,
}) async {
  String openText = pathway.type == PathwayType.quiz
      ? context.l10n.start
      : context.l10n.button_ok;
  return ElevatedButton.icon(
    label: Text(openText),
    icon: const Icon(Icons.open_in_new),
    onPressed: () async {
      final bool canPopInitially = Navigator.canPop(context);
      // Updates the status of the pathway to opened which causes the pathway to be displayed in the pathway list
      bool completed = await pathway.status == PathwayStatus.completed;
      if (!context.mounted) return;
      final targetStatus = completed
          ? PathwayStatus.completed
          : PathwayStatus
                .opened; // Do not change the status if the pathway is already completed
      await pathway.setStatus(targetStatus, context);
      if (!context.mounted) return;

      if (onClosed != null) {
        await onClosed();
        if (!context.mounted) return;
      } else if (canPopInitially) {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      }
    },
  );
}
