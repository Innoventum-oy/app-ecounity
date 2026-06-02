
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';

import '../../../widgets/screenscaffold.dart';
class SettingsScreen extends StatelessWidget {
 final int navigationIndex;
 const SettingsScreen({required this.navigationIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
        title:'Settings',
      navigationIndex: navigationIndex,
      child: ListView(
        children: [
          /*
          ListTile(
            title: Text(context.l10n.language),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              popupDialog(context.l10n.language, LanguageSelector(), context);
            },
          ),
           */

          ListTile(
            title: Text(context.l10n.privacy_policy),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).pushNamed('/settings/privacy');
            },
          ),
          ListTile(
            title: Text(context.l10n.about),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).pushNamed('/settings/about');
            },
          ),
        ],
      ),
    );
  }
}