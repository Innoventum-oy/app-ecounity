import 'dart:math' as math;

import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/widgets/ecounity_media_image.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:flutter/material.dart';

typedef EcoUnityComicImageBuilder =
    Widget Function(
      BuildContext context,
      EcoUnityMedia? media,
      String altText,
      BoxFit fit,
    );

class EcoUnityComicPlayer extends StatefulWidget {
  const EcoUnityComicPlayer({
    super.key,
    required this.comic,
    this.language = 'en',
    this.onCompleted,
    this.onReadySpeech,
    this.onSpeechCueChanged,
    this.imageBuilder,
    this.loadingAdditionalScenes = false,
  });

  final EcoUnityComic comic;
  final String language;
  final VoidCallback? onCompleted;
  final ValueChanged<EcoUnityComicSpeechItem>? onReadySpeech;
  final ValueChanged<EcoUnityComicSpeechItem?>? onSpeechCueChanged;
  final EcoUnityComicImageBuilder? imageBuilder;
  final bool loadingAdditionalScenes;

  @override
  State<EcoUnityComicPlayer> createState() => _EcoUnityComicPlayerState();
}

class _EcoUnityComicPlayerState extends State<EcoUnityComicPlayer> {
  String? _sceneKey;
  int _timelineIndex = 0;
  String? _lastSpeechCueKey;

  @override
  void initState() {
    super.initState();
    _sceneKey = widget.comic.startScene?.sceneKey;
  }

  @override
  void didUpdateWidget(covariant EcoUnityComicPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) {
      _sceneKey = widget.comic.startScene?.sceneKey;
      _timelineIndex = 0;
      _lastSpeechCueKey = null;
      return;
    }

    if (oldWidget.comic != widget.comic) {
      final EcoUnityComicScene? currentScene = widget.comic.sceneByKey(
        _sceneKey,
      );
      if (currentScene == null) {
        _sceneKey = widget.comic.startScene?.sceneKey;
        _timelineIndex = 0;
        _lastSpeechCueKey = null;
        return;
      }
      final int timelineLength = currentScene
          .dialogueTimeline(widget.language)
          .length;
      if (timelineLength > 0 && _timelineIndex >= timelineLength) {
        _timelineIndex = timelineLength;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final EcoUnityComicScene? scene =
        widget.comic.sceneByKey(_sceneKey) ?? widget.comic.startScene;
    if (scene == null) {
      return const Center(child: Text('No comic scenes available'));
    }

    final List<EcoUnityComicTimelineEntry> timeline = scene.dialogueTimeline(
      widget.language,
    );
    final EcoUnityComicTimelineEntry? currentEntry =
        _timelineIndex < timeline.length ? timeline[_timelineIndex] : null;

    _cueSpeech(currentEntry);

    return Column(
      children: <Widget>[
        Expanded(
          child: _ComicSceneCanvas(
            scene: scene,
            language: widget.language,
            currentEntry: currentEntry,
            imageBuilder: widget.imageBuilder,
          ),
        ),
        _ComicControls(
          scene: scene,
          timeline: timeline,
          timelineIndex: _timelineIndex,
          currentEntry: currentEntry,
          onContinue: () => _continue(scene, timeline),
          onDecisionSelected: _selectDecision,
          canSelectDecision: (EcoUnityComicDecision decision) {
            return widget.comic.sceneForDecision(decision) != null;
          },
          onCompleted: widget.onCompleted,
          loadingAdditionalScenes: widget.loadingAdditionalScenes,
        ),
      ],
    );
  }

  void _cueSpeech(EcoUnityComicTimelineEntry? entry) {
    final EcoUnityComicSpeechItem? speech = entry?.speech;
    final EcoUnityComicSpeechItem? readySpeech =
        speech != null && speech.hasReadyAudio ? speech : null;

    final String cueKey = readySpeech == null
        ? 'silent:${entry?.dialogue.id ?? 'end'}'
        : 'ready:${entry?.dialogue.id ?? ''}:${readySpeech.id ?? ''}:'
              '${readySpeech.audioFile?.url ?? ''}';
    if (cueKey == _lastSpeechCueKey) {
      return;
    }
    _lastSpeechCueKey = cueKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onSpeechCueChanged?.call(readySpeech);
      if (readySpeech != null) {
        widget.onReadySpeech?.call(readySpeech);
      }
    });
  }

  void _continue(
    EcoUnityComicScene scene,
    List<EcoUnityComicTimelineEntry> timeline,
  ) {
    if (_timelineIndex < timeline.length - 1) {
      setState(() {
        _timelineIndex += 1;
      });
      return;
    }

    if (scene.decisions.isNotEmpty) {
      setState(() {
        _timelineIndex = timeline.length;
      });
      return;
    }

    if (scene.decisions.isEmpty) {
      widget.onCompleted?.call();
    }
  }

  void _selectDecision(EcoUnityComicDecision decision) {
    final EcoUnityComicScene? targetScene = widget.comic.sceneForDecision(
      decision,
    );
    if (targetScene == null) {
      return;
    }

    setState(() {
      _sceneKey = targetScene.sceneKey;
      _timelineIndex = 0;
      _lastSpeechCueKey = null;
    });
  }
}

class _ComicSceneCanvas extends StatelessWidget {
  const _ComicSceneCanvas({
    required this.scene,
    required this.language,
    required this.currentEntry,
    required this.imageBuilder,
  });

  final EcoUnityComicScene scene;
  final String language;
  final EcoUnityComicTimelineEntry? currentEntry;
  final EcoUnityComicImageBuilder? imageBuilder;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        final EcoUnityComicViewportKind viewportKind =
            orientation == Orientation.landscape
            ? EcoUnityComicViewportKind.landscape
            : EcoUnityComicViewportKind.portrait;
        final EcoUnityComicViewport? viewport = scene.viewportFor(viewportKind);
        final double aspectRatio = _canvasAspectRatio(viewport, viewportKind);
        final List<EcoUnityComicDrawableLayer> layers = scene.drawableLayersFor(
          viewportKind,
        );

        return ColoredBox(
          color: EcoUnityColors.surfaceContainer,
          child: Center(
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: EcoUnityColors.outlineVariant),
                  ),
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          return Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              _ComicImage(
                                media: viewport?.backgroundImage,
                                altText: scene.altText.isNotEmpty
                                    ? scene.altText
                                    : scene.title,
                                fit: BoxFit.cover,
                                imageBuilder: imageBuilder,
                              ),
                              for (final EcoUnityComicDrawableLayer layer
                                  in layers)
                                _PositionedComicLayer(
                                  layer: layer,
                                  constraints: constraints,
                                  imageBuilder: imageBuilder,
                                ),
                              if (currentEntry != null)
                                _DialogueBubble(
                                  entry: currentEntry!,
                                  viewportKind: viewportKind,
                                  constraints: constraints,
                                ),
                            ],
                          );
                        },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PositionedComicLayer extends StatelessWidget {
  const _PositionedComicLayer({
    required this.layer,
    required this.constraints,
    required this.imageBuilder,
  });

  final EcoUnityComicDrawableLayer layer;
  final BoxConstraints constraints;
  final EcoUnityComicImageBuilder? imageBuilder;

  @override
  Widget build(BuildContext context) {
    final EcoUnityComicLayout layout = layer.layout;
    final double baseWidthFactor =
        layer.kind == EcoUnityComicLayerKind.character ? 0.34 : 0.22;
    final double width = (constraints.maxWidth * baseWidthFactor * layout.scale)
        .clamp(32, constraints.maxWidth * 0.78)
        .toDouble();
    final double maxLeft = math.max(0, constraints.maxWidth - width);
    final double maxTop = math.max(0, constraints.maxHeight - width * 0.3);
    final double left = (constraints.maxWidth * layout.x - width / 2)
        .clamp(0, maxLeft)
        .toDouble();
    final double top = (constraints.maxHeight * layout.y - width / 2)
        .clamp(0, maxTop)
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      width: width,
      child: Transform.rotate(
        angle: layout.rotation * math.pi / 180,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(
            layout.flipX ? -1.0 : 1.0,
            1.0,
            1.0,
          ),
          child: _ComicImage(
            media:
                layer.media ??
                EcoUnityMedia(
                  id: layer.id,
                  url: layer.imageUrl,
                  title: layer.label,
                  altText: layer.altText,
                  rawData: const <String, dynamic>{},
                ),
            altText: layer.altText,
            fit: BoxFit.contain,
            imageBuilder: imageBuilder,
          ),
        ),
      ),
    );
  }
}

class _DialogueBubble extends StatelessWidget {
  const _DialogueBubble({
    required this.entry,
    required this.viewportKind,
    required this.constraints,
  });

  final EcoUnityComicTimelineEntry entry;
  final EcoUnityComicViewportKind viewportKind;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final EcoUnityComicLayout layout = entry.castLayer.layoutFor(viewportKind);
    final double maxWidth = math.min(constraints.maxWidth - 32, 280);
    final double maxLeft = math.max(16, constraints.maxWidth - maxWidth - 16);
    final double maxTop = math.max(16, constraints.maxHeight - 160);
    final double left = (constraints.maxWidth * layout.bubbleX - maxWidth / 2)
        .clamp(16, maxLeft)
        .toDouble();
    final double top = (constraints.maxHeight * layout.bubbleY)
        .clamp(16, maxTop)
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      width: maxWidth,
      child: Material(
        color: Colors.white,
        elevation: 3,
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: EcoUnityColors.deepTeal),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if ((entry.castLayer.character?.name ?? '').isNotEmpty)
                  Text(
                    entry.castLayer.character!.name,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: EcoUnityColors.deepTeal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                Text(
                  entry.dialogue.dialogue,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: EcoUnityColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                if (entry.hasReadyAudio)
                  const Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Icon(
                      Icons.volume_up,
                      color: EcoUnityColors.turquoise,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComicControls extends StatelessWidget {
  const _ComicControls({
    required this.scene,
    required this.timeline,
    required this.timelineIndex,
    required this.currentEntry,
    required this.onContinue,
    required this.onDecisionSelected,
    required this.canSelectDecision,
    required this.onCompleted,
    required this.loadingAdditionalScenes,
  });

  final EcoUnityComicScene scene;
  final List<EcoUnityComicTimelineEntry> timeline;
  final int timelineIndex;
  final EcoUnityComicTimelineEntry? currentEntry;
  final VoidCallback onContinue;
  final ValueChanged<EcoUnityComicDecision> onDecisionSelected;
  final bool Function(EcoUnityComicDecision decision) canSelectDecision;
  final VoidCallback? onCompleted;
  final bool loadingAdditionalScenes;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: EcoUnityColors.outlineVariant)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: currentEntry != null
              ? _buildDialogueControls(context)
              : _buildSceneEndControls(context),
        ),
      ),
    );
  }

  Widget _buildDialogueControls(BuildContext context) {
    final int currentStep = timelineIndex + 1;
    final int totalSteps = math.max(timeline.length, 1);
    final bool isLastDialogue = currentStep >= totalSteps;
    final String buttonLabel = isLastDialogue
        ? (scene.decisions.isEmpty ? 'Complete' : 'Choices')
        : 'Continue';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: LinearProgressIndicator(
                value: currentStep / totalSteps,
                minHeight: 6,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$currentStep / $totalSteps',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: EcoUnityColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: onContinue, child: Text(buttonLabel)),
        ),
      ],
    );
  }

  Widget _buildSceneEndControls(BuildContext context) {
    if (scene.decisions.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onCompleted,
          icon: const Icon(Icons.check),
          label: const Text('Complete'),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final EcoUnityComicDecision decision in scene.decisions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ElevatedButton.icon(
              onPressed: canSelectDecision(decision)
                  ? () => onDecisionSelected(decision)
                  : null,
              icon: loadingAdditionalScenes && !canSelectDecision(decision)
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.alt_route),
              label: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  decision.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        if (loadingAdditionalScenes) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            'Loading next scenes...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: EcoUnityColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _ComicImage extends StatelessWidget {
  const _ComicImage({
    required this.media,
    required this.altText,
    required this.fit,
    required this.imageBuilder,
  });

  final EcoUnityMedia? media;
  final String altText;
  final BoxFit fit;
  final EcoUnityComicImageBuilder? imageBuilder;

  @override
  Widget build(BuildContext context) {
    if (imageBuilder != null) {
      return imageBuilder!(context, media, altText, fit);
    }

    final EcoUnityMedia? value = media;
    if (value == null ||
        ((value.url ?? '').trim().isEmpty && value.id == null)) {
      return _ComicImagePlaceholder(altText: altText);
    }

    return Semantics(
      image: true,
      label: altText.isEmpty ? null : altText,
      child: EcoUnityMediaImage(
        media: value,
        fit: fit,
        fallback: _ComicImagePlaceholder(altText: altText),
      ),
    );
  }
}

class _ComicImagePlaceholder extends StatelessWidget {
  const _ComicImagePlaceholder({required this.altText});

  final String altText;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: altText.isEmpty ? null : altText,
      child: ColoredBox(
        color: EcoUnityColors.surfaceContainerHigh,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: EcoUnityColors.textSecondary.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

double _canvasAspectRatio(
  EcoUnityComicViewport? viewport,
  EcoUnityComicViewportKind viewportKind,
) {
  if (viewport != null && viewport.canvasHeight > 0) {
    return viewport.canvasWidth / viewport.canvasHeight;
  }
  return viewportKind == EcoUnityComicViewportKind.landscape ? 16 / 9 : 3 / 4;
}
