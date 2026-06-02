import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/objects/ecounity_badge.dart';
import 'package:ecounity/src/providers/ecounity_badge_provider.dart';
import 'package:ecounity/src/util/settings.dart';

import '../../util/router.dart';
import '../../widgets/screenscaffold.dart';

class AchievementsView extends StatefulWidget {
  final int navIndex;
  final String viewTitle = 'achievements';
  const AchievementsView({required this.navIndex, super.key});

  @override
  AchievementsViewState createState() => AchievementsViewState();
}

class AchievementsViewState extends State<AchievementsView> {
  List<EcoUnityBadge> badges = [];
  Map<int?, _BadgeProgressData> _badgeProgress = {};
  int limit = 50;
  String? errorMessage;
  bool isLoadingProgress = false;
  String? loadedLanguage;

  @override
  void initState() {
    // Set badges from provider
    if (kDebugMode) {
      log('AchievementsView initState');
    }
    getBadges();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLanguage = Localizations.localeOf(context).languageCode;
    if (badges.isNotEmpty &&
        !isLoadingProgress &&
        (loadedLanguage != currentLanguage ||
            _badgeProgress.length != badges.length)) {
      _loadBadgeProgress(currentLanguage);
    }
  }

  void getBadges() async {
    if (kDebugMode) {
      log('Loading badges');
    }
    final loadedBadges = await Provider.of<EcoUnityBadgeProvider>(
      context,
      listen: false,
    ).getItems(badgeParams);

    if (!mounted) {
      return;
    }

    setState(() {
      badges = loadedBadges;
      errorMessage = loadedBadges.isEmpty ? context.l10n.noBadgesFound : null;
    });

    if (loadedBadges.isNotEmpty) {
      _loadBadgeProgress(Localizations.localeOf(context).languageCode);
    }
  }

  Future<void> _loadBadgeProgress(String currentLanguage) async {
    setState(() {
      isLoadingProgress = true;
    });

    final progressEntries = await Future.wait(
      badges.map((badge) async {
        final requiredCount = await badge.getRequiredPathwaysCount(
          currentLanguage,
        );
        final completedCount = await badge.getCompletedPathwaysCount(
          currentLanguage,
        );
        final completion = requiredCount == 0
            ? 0.0
            : ((completedCount / requiredCount) * 100).roundToDouble();

        return MapEntry(
          badge.id,
          _BadgeProgressData(
            completion: completion,
            isCompleted: requiredCount > 0 && completedCount >= requiredCount,
            completedCount: completedCount,
            requiredCount: requiredCount,
          ),
        );
      }),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _badgeProgress = Map<int?, _BadgeProgressData>.fromEntries(progressEntries);
      loadedLanguage = currentLanguage;
      isLoadingProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      log('building AchievementsView');
    }

    return ScreenScaffold(
      title: context.l10n.achievements,
      navigationIndex: widget.navIndex,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: allBadges(),
      ),
    );
  }

  /* Widget list creator for collected badges */
  Widget allBadges() {
    if (badges.isEmpty) {
      String emptytext = context.l10n.noBadgesFound;
      return Center(
        child: Text(emptytext),
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    int columns = 3;
    if (screenWidth < 400) {
      columns = 1;
    } else if (screenWidth < 600) {
      columns = 2;
    } else {
      columns = 3;
    }

    if (isLoadingProgress && _badgeProgress.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      itemCount: badges.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns, // Adjust based on screen width if needed
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        childAspectRatio: 0.57,
      ),
      itemBuilder: (context, index) {
        final badge = badges[index];
        final progress =
            _badgeProgress[badge.id] ?? const _BadgeProgressData.empty();
        return _badgeIconDisplay(
          badge,
          context,
          progress: progress,
        );
      },
    );
  }

  Widget _badgeIconDisplay(
    EcoUnityBadge badge,
    BuildContext context, {
    required _BadgeProgressData progress,
  }) {
    String completed = context.l10n.completed;
    TextStyle? bodySmall = TextTheme.of(context).bodySmall;
    TextStyle? bodyLarge = TextTheme.of(context).bodyLarge;
    return GestureDetector(
      onTap: () {
        if (kDebugMode) {
          log('Opening badge ${badge.name}');
        }
        AppRouter.navigate(context, '/badge', 0, replaceRoute: false, data: badge);
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: AspectRatio(
              aspectRatio: 0.85,
              child: badge.badgeimageurl != null
                  ? FadeInImage.assetNetwork(
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: 'assets/images/ecounity-logo.png',
                      image: badge.badgeimageurl!,
                    )
                  : const Icon(Icons.emoji_events, size: 60.0),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            badge.name ?? '-',
            style: bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          progress.isCompleted
              ? Text(
                  completed,
                  style: bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )
              : Text("${progress.completion}%"),
          const SizedBox(height: 5),
          Text(
            badge.description ?? '',
            style: bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BadgeProgressData {
  final double completion;
  final bool isCompleted;
  final int completedCount;
  final int requiredCount;

  const _BadgeProgressData({
    required this.completion,
    required this.isCompleted,
    required this.completedCount,
    required this.requiredCount,
  });

  const _BadgeProgressData.empty()
      : completion = 0,
        isCompleted = false,
        completedCount = 0,
        requiredCount = 0;
}
