import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/learning/widgets/ecounity_learning_copy.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:flutter/material.dart';

class EcoUnityTeacherObjectiveCard extends StatelessWidget {
  const EcoUnityTeacherObjectiveCard({
    super.key,
    required this.learningObjective,
  });

  final String learningObjective;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.teacherSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EcoUnityColors.teacherBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.school_outlined,
                  color: EcoUnityColors.warmOrange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.teacher_mode,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: EcoUnityColors.warning,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.learning_objective,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: EcoUnityColors.deepTeal,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            EcoUnityLearningCopy(
              text: learningObjective,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: EcoUnityColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
