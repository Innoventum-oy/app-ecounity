import 'dart:math' as math;

import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/widgets/ecounity_media_image.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:flutter/material.dart';

class EcoUnityActivityHeroImage extends StatelessWidget {
  const EcoUnityActivityHeroImage({
    super.key,
    required this.activity,
    this.aspectRatio = 16 / 9,
    this.maxHeight,
  });

  final EcoUnityLearningActivity activity;
  final double aspectRatio;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final EcoUnityMedia? media = activity.heroImage;
    if (media == null) {
      return const SizedBox.shrink();
    }

    final Widget image = EcoUnityMediaImage(
      media: media,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(8),
      fallback: DecoratedBox(
        decoration: const BoxDecoration(color: EcoUnityColors.surfaceContainer),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: EcoUnityColors.deepTeal.withValues(alpha: 0.72),
            size: 36,
          ),
        ),
      ),
    );

    if (maxHeight == null) {
      return AspectRatio(aspectRatio: aspectRatio, child: image);
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return SizedBox(
          height: math.min(width / aspectRatio, maxHeight!),
          width: double.infinity,
          child: image,
        );
      },
    );
  }
}
