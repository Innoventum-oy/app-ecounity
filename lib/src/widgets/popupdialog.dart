import 'package:flutter/material.dart';

import '../../l10n/app_localizations_extension.dart';

Future<dynamic> popupDialog(
    String? titleText, Widget dialogContent, BuildContext context,
    {List<Widget>? actions}) async {
  return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
            scrollable: true,
            title: Text(titleText ??
                context.l10n.notification),
            content: dialogContent,
            actions: actions ??
                <Widget>[
                  ElevatedButton(
                      child: Text(
                          context.l10n.ok),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      })
                ],
          ));
}
