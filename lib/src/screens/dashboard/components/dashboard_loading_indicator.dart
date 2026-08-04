import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_extension.dart';

class DashboardLoadingIndicator extends StatelessWidget {
  final double size;

  const DashboardLoadingIndicator({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Center(
          child: SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Text(context.l10n.loading),
        ),
      ],
    );
  }
}
