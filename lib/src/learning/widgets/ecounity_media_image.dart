import 'package:core/core.dart' as core;
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/util/core_compat.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:ecounity/src/util/image_from_url.dart';
import 'package:flutter/material.dart';

final Map<int, Future<core.ImageObject?>> _mediaImageFutureCache =
    <int, Future<core.ImageObject?>>{};

class EcoUnityMediaImage extends StatelessWidget {
  const EcoUnityMediaImage({
    super.key,
    required this.media,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.loadedKey,
  });

  final EcoUnityMedia? media;
  final Widget fallback;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Key? loadedKey;

  @override
  Widget build(BuildContext context) {
    final EcoUnityMedia? value = media;
    final String? directUrl = value?.url?.trim();

    return ClipRRect(
      borderRadius: borderRadius,
      child: directUrl != null && directUrl.isNotEmpty
          ? _MediaUrlImage(
              url: directUrl,
              fit: fit,
              fallback: fallback,
              loadedKey: loadedKey,
            )
          : _MediaIdImage(
              id: value?.id,
              fit: fit,
              fallback: fallback,
              loadedKey: loadedKey,
            ),
    );
  }
}

class _MediaIdImage extends StatelessWidget {
  const _MediaIdImage({
    required this.id,
    required this.fit,
    required this.fallback,
    required this.loadedKey,
  });

  final int? id;
  final BoxFit fit;
  final Widget fallback;
  final Key? loadedKey;

  @override
  Widget build(BuildContext context) {
    final int? value = id;
    if (value == null) {
      return fallback;
    }

    return FutureBuilder<core.ImageObject?>(
      future: _loadMediaImage(value),
      builder:
          (BuildContext context, AsyncSnapshot<core.ImageObject?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _ImagePlaceholder();
            }
            final String? url = snapshot.data?.imageUrl?.trim();
            if (url == null || url.isEmpty) {
              return fallback;
            }
            return _MediaUrlImage(
              url: url,
              fit: fit,
              fallback: fallback,
              loadedKey: loadedKey,
            );
          },
    );
  }
}

Future<core.ImageObject?> _loadMediaImage(int id) {
  return _mediaImageFutureCache.putIfAbsent(id, () => loadCoreImage(id));
}

class _MediaUrlImage extends StatelessWidget {
  const _MediaUrlImage({
    required this.url,
    required this.fit,
    required this.fallback,
    required this.loadedKey,
  });

  final String url;
  final BoxFit fit;
  final Widget fallback;
  final Key? loadedKey;

  @override
  Widget build(BuildContext context) {
    return ImageFromUrl.get(
      url,
      fillContainer: fit == BoxFit.cover,
      loadedKey: loadedKey,
      loadingBuilder: (_) => const _ImagePlaceholder(),
      errorBuilder: (context, error) => fallback,
      emptyBuilder: (_) => fallback,
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: EcoUnityColors.surfaceContainer),
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: EcoUnityColors.deepTeal.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
