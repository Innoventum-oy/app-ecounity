import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/objects/ecounity_badge.dart';

import '../../widgets/screenscaffold.dart';

class BadgeView extends StatefulWidget {
  final EcoUnityBadge badge;
  final int? navIndex;

  const BadgeView(this.badge, {this.navIndex, super.key});
  @override
  BadgeViewState createState() => BadgeViewState();
}

class BadgeViewState extends State<BadgeView> {
  bool isCompleted = false;
  int requiredPathways = 0;
  int completedPathways = 0;

  void initBadge() async {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    String currentLanguage = Localizations.localeOf(context).languageCode;
    requiredPathways = await widget.badge.getRequiredPathwaysCount(
      currentLanguage,
    );
    completedPathways = await widget.badge.getCompletedPathwaysCount(
      currentLanguage,
    );
    isCompleted = requiredPathways > 0 && completedPathways >= requiredPathways;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    initBadge();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: widget.badge.name ?? context.l10n.unnamed,
      navigationIndex: widget.navIndex,
      child: widgetContent(context),
    );
  }

  Widget widgetContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.badge.badgeimageurl != null
              ? Image.network(
                  widget.badge.badgeimageurl!,
                  fit: BoxFit.contain,
                  height: 200,
                )
              : const Icon(Icons.emoji_events, size: 100),
          const SizedBox(height: 16),
          Text(
            widget.badge.name ?? context.l10n.unnamed,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),
          if (isCompleted)
            Text(
              context.l10n.you_have_this_badge,
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
          if (!isCompleted)
            Text(
              context.l10n.badge_completion_status(
                completedPathways,
                requiredPathways,
              ),
              style: const TextStyle(fontSize: 20, color: Colors.blue),
            ),
          const SizedBox(height: 8),
          Text(
            widget.badge.description ??
                ((widget.badge.pathway != null || widget.badge.name != null)
                    ? context.l10n.badge_description(
                        widget.badge.pathway ?? widget.badge.name!,
                      )
                    : context.l10n.badge),
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
