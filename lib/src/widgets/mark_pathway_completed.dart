import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/widgets/popupdialog.dart';
import '../objects/pathway.dart';
import 'completion_page.dart';


ElevatedButton activeButton(BuildContext context, WebPage pathway) {
  return ElevatedButton.icon(
    label: Text(context.l10n.markAsCompleted),
    icon: const Icon(Icons.check),
    onPressed: () async {
      await pathway.setStatus(PathwayStatus.completed, context);
      if(context.mounted) {

        // if the pathway has completion text, show completion popup

          popupDialog(context.l10n.pathway_completed, CompletionPage(pathway:pathway), context,actions: [
            ElevatedButton(
                child:
                Text(context.l10n.ok),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                })
          ]);



      }
    },
  );
}

ElevatedButton inactiveButton(BuildContext context) {
  return ElevatedButton.icon(
    // set style to disabled
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.grey),
    ),
    icon: const Icon(Icons.check),

    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.pathway_already_completed),
        ),
      );
    }, label:Text(context.l10n.pathway_already_completed),
  );
}

Future<Widget> completePathwayButton(BuildContext context, WebPage pathway, FileStorage fileStorage) async {

  try {
    bool completed = await pathway.status == PathwayStatus.completed;
    return context.mounted ? (completed ? inactiveButton(context)  : activeButton(context, pathway)) : const SizedBox();
  } catch (e) {

    return Text(context.mounted ? context.l10n.error_loading_button : '');
  }
}

Future<Widget> openPathwayButton(BuildContext context, WebPage pathway) async {
  return ElevatedButton.icon(
    label: Text(context.l10n.button_ok),
    icon: const Icon(Icons.open_in_new),
    onPressed: () async {
      // Updates the status of the pathway to opened which causes the pathway to be displayed in the pathway list
      bool completed = await pathway.status == PathwayStatus.completed;
      if(context.mounted) {
        await pathway.setStatus(
            completed ? PathwayStatus.completed : PathwayStatus.opened, // Do not change the status if the pathway is already completed
            context);
      }
    },
  );
}
