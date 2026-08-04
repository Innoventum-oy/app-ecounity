import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/util/router.dart';
import 'package:flutter/material.dart';

import '../../../widgets/screenscaffold.dart';

class SettingsScreen extends StatelessWidget {
  final int navigationIndex;
  const SettingsScreen({required this.navigationIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: context.l10n.settings,
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
              AppRouter.navigate(
                context,
                '/settings/privacy',
                navigationIndex,
                replaceRoute: false,
              );
            },
          ),
          ListTile(
            title: Text(context.l10n.about),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              AppRouter.navigate(
                context,
                '/settings/about',
                navigationIndex,
                replaceRoute: false,
              );
            },
          ),
        ],
      ),
    );
  }
}
