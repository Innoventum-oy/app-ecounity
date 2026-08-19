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
    this.onReady,
  });

  final EcoUnityMedia? media;
  final Widget fallback;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Key? loadedKey;
  final VoidCallback? onReady;

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
              onReady: onReady,
            )
          : _MediaIdImage(
              id: value?.id,
              fit: fit,
              fallback: fallback,
              loadedKey: loadedKey,
              onReady: onReady,
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
    required this.onReady,
  });

  final int? id;
  final BoxFit fit;
  final Widget fallback;
  final Key? loadedKey;
  final VoidCallback? onReady;

  @override
  Widget build(BuildContext context) {
    final int? value = id;
    if (value == null) {
      return _withMediaImageReady(fallback, onReady);
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
              return _withMediaImageReady(fallback, onReady);
            }
            return _MediaUrlImage(
              url: url,
              fit: fit,
              fallback: fallback,
              loadedKey: loadedKey,
              onReady: onReady,
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
    required this.onReady,
  });

  final String url;
  final BoxFit fit;
  final Widget fallback;
  final Key? loadedKey;
  final VoidCallback? onReady;

  @override
  Widget build(BuildContext context) {
    return ImageFromUrl.get(
      url,
      fillContainer: fit == BoxFit.cover,
      loadedKey: loadedKey,
      loadingBuilder: (_) => const _ImagePlaceholder(),
      errorBuilder: (context, error) => fallback,
      emptyBuilder: (_) => fallback,
      onReady: onReady,
    );
  }
}

Widget _withMediaImageReady(Widget child, VoidCallback? onReady) {
  if (onReady == null) {
    return child;
  }
  return _MediaImageReadyCallback(onReady: onReady, child: child);
}

class _MediaImageReadyCallback extends StatefulWidget {
  const _MediaImageReadyCallback({required this.onReady, required this.child});

  final VoidCallback onReady;
  final Widget child;

  @override
  State<_MediaImageReadyCallback> createState() =>
      _MediaImageReadyCallbackState();
}

class _MediaImageReadyCallbackState extends State<_MediaImageReadyCallback> {
  bool _readyNotified = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifyReady();
  }

  @override
  void didUpdateWidget(covariant _MediaImageReadyCallback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onReady != widget.onReady) {
      _readyNotified = false;
      _notifyReady();
    }
  }

  void _notifyReady() {
    if (_readyNotified) {
      return;
    }
    _readyNotified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
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
