import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';

void notifyDialog(String? titleText, Widget text, BuildContext context) {
  // get screen height
  double screenHeight = MediaQuery.of(context).size.height;

  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(titleText ?? context.l10n.attention),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 0.8 * screenHeight),
        child: SingleChildScrollView(child: text),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text(context.l10n.ok),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    ),
  );
}
