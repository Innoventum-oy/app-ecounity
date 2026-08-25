import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_text_utils.dart';
import 'package:ecounity/src/learning/widgets/ecounity_activity_hero_image.dart';
import 'package:ecounity/src/learning/widgets/ecounity_learning_copy.dart';
import 'package:ecounity/src/learning/widgets/ecounity_teacher_objective_card.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:flutter/material.dart';

class EcoUnityComicActivityCoverSheet extends StatelessWidget {
  const EcoUnityComicActivityCoverSheet({
    super.key,
    required this.activity,
    required this.teacherModeEnabled,
    required this.loadingAdditionalScenes,
    required this.onStart,
    this.reviewPanel,
  });

  final EcoUnityLearningActivity activity;
  final bool teacherModeEnabled;
  final bool loadingAdditionalScenes;
  final VoidCallback onStart;
  final Widget? reviewPanel;

  @override
  Widget build(BuildContext context) {
    final String shortDescription = activity.shortDescription.trim();
    final String body = activity.body.trim();
    final bool showBody = body.isNotEmpty && body != shortDescription;

    return ListView(
      key: const ValueKey<String>('screenshot-content-comic-cover'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: <Widget>[
        EcoUnityActivityHeroImage(activity: activity, maxHeight: 360),
        if (activity.heroImage != null) const SizedBox(height: 16),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: EcoUnityColors.outlineVariant),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x140D404E),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Chip(
                  avatar: const Icon(Icons.forum_rounded, size: 18),
                  label: Text(context.l10n.learning_activity_type('comic')),
                  backgroundColor: const Color(0xFFEAFBFB),
                  side: BorderSide.none,
                ),
                const SizedBox(height: 8),
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: EcoUnityColors.deepTeal,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (shortDescription.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  EcoUnityLearningCopy(
                    text: shortDescription,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: EcoUnityColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
                if (showBody) ...<Widget>[
                  const SizedBox(height: 12),
                  EcoUnityLearningCopy(
                    text: ecoUnityReplaceMediaImageTokens(
                      body,
                      activity.mediaImages,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: EcoUnityColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
                if (activity.keyMessage.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  _ComicCoverMessage(text: activity.keyMessage.trim()),
                ],
              ],
            ),
          ),
        ),
        if (reviewPanel != null) ...<Widget>[
          const SizedBox(height: 12),
          reviewPanel!,
        ],
        if (teacherModeEnabled && activity.learningObjective.isNotEmpty) ...[
          const SizedBox(height: 12),
          EcoUnityTeacherObjectiveCard(
            learningObjective: activity.learningObjective,
          ),
        ],
        if (loadingAdditionalScenes) ...<Widget>[
          const SizedBox(height: 12),
          _ComicCoverLoadingNotice(
            label: context.l10n.comic_loading_next_scenes,
          ),
        ],
        const SizedBox(height: 18),
        FilledButton.icon(
          key: const ValueKey<String>('screenshot-comic-cover-start-button'),
          onPressed: onStart,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(context.l10n.start),
        ),
      ],
    );
  }
}

class _ComicCoverMessage extends StatelessWidget {
  const _ComicCoverMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EcoUnityColors.warmOrange),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: EcoUnityLearningCopy(
          text: text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: EcoUnityColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ComicCoverLoadingNotice extends StatelessWidget {
  const _ComicCoverLoadingNotice({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: <Widget>[
            const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: EcoUnityColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
