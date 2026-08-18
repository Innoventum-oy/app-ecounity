import 'dart:async';
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
  bool _isTimelinePlaying = false;
  final List<Timer> _timelineTimers = <Timer>[];

  @override
  void initState() {
    super.initState();
    _sceneKey = widget.comic.startScene?.sceneKey;
  }

  @override
  void didUpdateWidget(covariant EcoUnityComicPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) {
      _stopTimelinePlayback(updateState: false, stopAudio: true);
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
        _stopTimelinePlayback(updateState: false, stopAudio: true);
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
  void dispose() {
    _cancelTimelineTimers();
    widget.onSpeechCueChanged?.call(null);
    super.dispose();
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
            isTimelinePlaying: _isTimelinePlaying,
            imageBuilder: widget.imageBuilder,
          ),
        ),
        _ComicControls(
          scene: scene,
          timeline: timeline,
          timelineIndex: _timelineIndex,
          currentEntry: currentEntry,
          onContinue: () => _continue(scene, timeline),
          onPlaybackToggle: () => _toggleTimelinePlayback(scene, timeline),
          onDecisionSelected: _selectDecision,
          canSelectDecision: (EcoUnityComicDecision decision) {
            return widget.comic.sceneForDecision(decision) != null;
          },
          onCompleted: widget.onCompleted,
          loadingAdditionalScenes: widget.loadingAdditionalScenes,
          isTimelinePlaying: _isTimelinePlaying,
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
    _stopTimelinePlayback(updateState: false, stopAudio: true);
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
    _stopTimelinePlayback(updateState: false, stopAudio: true);
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

  void _toggleTimelinePlayback(
    EcoUnityComicScene scene,
    List<EcoUnityComicTimelineEntry> timeline,
  ) {
    if (_isTimelinePlaying) {
      _stopTimelinePlayback(stopAudio: true);
      return;
    }
    _startTimelinePlayback(scene, timeline);
  }

  void _startTimelinePlayback(
    EcoUnityComicScene scene,
    List<EcoUnityComicTimelineEntry> timeline,
  ) {
    if (timeline.isEmpty) {
      return;
    }

    _cancelTimelineTimers();
    final int firstStartMs = math.max(0, timeline.first.startMs);
    final int totalDurationMs = timeline.fold<int>(0, (
      int currentMax,
      EcoUnityComicTimelineEntry entry,
    ) {
      final int startMs = math.max(0, entry.startMs);
      return math.max(currentMax, startMs + _playbackDurationMs(entry));
    });

    setState(() {
      _isTimelinePlaying = true;
      _timelineIndex = 0;
      _lastSpeechCueKey = null;
    });

    for (int index = 1; index < timeline.length; index += 1) {
      final EcoUnityComicTimelineEntry entry = timeline[index];
      final int delayMs = math.max(0, entry.startMs - firstStartMs);
      _timelineTimers.add(
        Timer(Duration(milliseconds: delayMs), () {
          if (!mounted ||
              _sceneKey != scene.sceneKey ||
              widget.comic.sceneByKey(scene.sceneKey) == null) {
            return;
          }
          setState(() {
            _timelineIndex = index;
          });
        }),
      );
    }

    _timelineTimers.add(
      Timer(
        Duration(milliseconds: math.max(0, totalDurationMs - firstStartMs)),
        () {
          if (!mounted ||
              _sceneKey != scene.sceneKey ||
              widget.comic.sceneByKey(scene.sceneKey) == null) {
            return;
          }
          setState(() {
            _isTimelinePlaying = false;
            _timelineIndex = timeline.length;
          });
        },
      ),
    );
  }

  void _stopTimelinePlayback({
    bool updateState = true,
    required bool stopAudio,
  }) {
    _cancelTimelineTimers();
    if (stopAudio) {
      widget.onSpeechCueChanged?.call(null);
    }
    if (!mounted || !updateState) {
      _isTimelinePlaying = false;
      return;
    }
    setState(() {
      _isTimelinePlaying = false;
    });
  }

  void _cancelTimelineTimers() {
    for (final Timer timer in _timelineTimers) {
      timer.cancel();
    }
    _timelineTimers.clear();
  }
}

class _ComicSceneCanvas extends StatelessWidget {
  const _ComicSceneCanvas({
    required this.scene,
    required this.language,
    required this.currentEntry,
    required this.isTimelinePlaying,
    required this.imageBuilder,
  });

  final EcoUnityComicScene scene;
  final String language;
  final EcoUnityComicTimelineEntry? currentEntry;
  final bool isTimelinePlaying;
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
                              _AnimatedDialogueBubble(
                                entry: currentEntry,
                                viewportKind: viewportKind,
                                constraints: constraints,
                                dimmed: isTimelinePlaying,
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
    final double baseWidthFactor = switch (layer.kind) {
      EcoUnityComicLayerKind.character => 0.28,
      EcoUnityComicLayerKind.prop => 0.24,
      EcoUnityComicLayerKind.decision => 0.32,
    };
    final double width = (constraints.maxWidth * baseWidthFactor * layout.scale)
        .clamp(24, constraints.maxWidth * 1.2)
        .toDouble();
    final double left = constraints.maxWidth * layout.x;
    final double top = constraints.maxHeight * layout.y;

    return Positioned(
      left: left,
      top: top,
      width: width,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: SizedBox(
          key: _comicLayerKey(layer),
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
        ),
      ),
    );
  }
}

class _AnimatedDialogueBubble extends StatelessWidget {
  const _AnimatedDialogueBubble({
    required this.entry,
    required this.viewportKind,
    required this.constraints,
    required this.dimmed,
  });

  final EcoUnityComicTimelineEntry? entry;
  final EcoUnityComicViewportKind viewportKind;
  final BoxConstraints constraints;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: entry == null,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          reverseDuration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
                child: child,
              ),
            );
          },
          child: entry == null
              ? const SizedBox.shrink(key: ValueKey<String>('dialogue-empty'))
              : Stack(
                  key: ValueKey<String>('dialogue-${entry!.dialogue.id}'),
                  fit: StackFit.expand,
                  children: <Widget>[
                    _DialogueBubble(
                      entry: entry!,
                      viewportKind: viewportKind,
                      constraints: constraints,
                      dimmed: dimmed,
                    ),
                  ],
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
    required this.dimmed,
  });

  final EcoUnityComicTimelineEntry entry;
  final EcoUnityComicViewportKind viewportKind;
  final BoxConstraints constraints;
  final bool dimmed;

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
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: dimmed ? 0.96 : 1,
        child: Material(
          color: Colors.white,
          elevation: dimmed ? 6 : 3,
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
    required this.onPlaybackToggle,
    required this.onDecisionSelected,
    required this.canSelectDecision,
    required this.onCompleted,
    required this.loadingAdditionalScenes,
    required this.isTimelinePlaying,
  });

  final EcoUnityComicScene scene;
  final List<EcoUnityComicTimelineEntry> timeline;
  final int timelineIndex;
  final EcoUnityComicTimelineEntry? currentEntry;
  final VoidCallback onContinue;
  final VoidCallback onPlaybackToggle;
  final ValueChanged<EcoUnityComicDecision> onDecisionSelected;
  final bool Function(EcoUnityComicDecision decision) canSelectDecision;
  final VoidCallback? onCompleted;
  final bool loadingAdditionalScenes;
  final bool isTimelinePlaying;

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
            const SizedBox(width: 8),
            _TimelinePlaybackButton(
              enabled: timeline.isNotEmpty,
              isPlaying: isTimelinePlaying,
              onPressed: onPlaybackToggle,
            ),
            _DialogueTranscriptButton(
              enabled: timeline.isNotEmpty,
              onPressed: () => _showDialogueTranscript(context),
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
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _ComicUtilityControls(
            timeline: timeline,
            isTimelinePlaying: isTimelinePlaying,
            onPlaybackToggle: onPlaybackToggle,
            onTranscriptPressed: () => _showDialogueTranscript(context),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCompleted,
              icon: const Icon(Icons.check),
              label: const Text('Complete'),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: _ComicUtilityControls(
            timeline: timeline,
            isTimelinePlaying: isTimelinePlaying,
            onPlaybackToggle: onPlaybackToggle,
            onTranscriptPressed: () => _showDialogueTranscript(context),
          ),
        ),
        const SizedBox(height: 8),
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

  void _showDialogueTranscript(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(scene.title.isNotEmpty ? scene.title : 'Dialogue'),
          content: SizedBox(
            width: math.min(MediaQuery.sizeOf(context).width - 64, 520),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: timeline.length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(height: 20);
              },
              itemBuilder: (BuildContext context, int index) {
                final EcoUnityComicTimelineEntry entry = timeline[index];
                final String speaker =
                    entry.castLayer.character?.name ?? 'Character';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      speaker,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: EcoUnityColors.deepTeal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.dialogue.dialogue,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.35),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _ComicUtilityControls extends StatelessWidget {
  const _ComicUtilityControls({
    required this.timeline,
    required this.isTimelinePlaying,
    required this.onPlaybackToggle,
    required this.onTranscriptPressed,
  });

  final List<EcoUnityComicTimelineEntry> timeline;
  final bool isTimelinePlaying;
  final VoidCallback onPlaybackToggle;
  final VoidCallback onTranscriptPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _TimelinePlaybackButton(
          enabled: timeline.isNotEmpty,
          isPlaying: isTimelinePlaying,
          onPressed: onPlaybackToggle,
        ),
        _DialogueTranscriptButton(
          enabled: timeline.isNotEmpty,
          onPressed: onTranscriptPressed,
        ),
      ],
    );
  }
}

class _TimelinePlaybackButton extends StatelessWidget {
  const _TimelinePlaybackButton({
    required this.enabled,
    required this.isPlaying,
    required this.onPressed,
  });

  final bool enabled;
  final bool isPlaying;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: isPlaying ? 'Stop' : 'Play',
      onPressed: enabled ? onPressed : null,
      icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
    );
  }
}

class _DialogueTranscriptButton extends StatelessWidget {
  const _DialogueTranscriptButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'View dialogue',
      onPressed: enabled ? onPressed : null,
      icon: const Icon(Icons.chat_bubble_outline),
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

Key _comicLayerKey(EcoUnityComicDrawableLayer layer) {
  final String id = layer.id?.toString() ?? layer.label;
  return ValueKey<String>('comic-layer-${layer.kind.name}-$id');
}

int _playbackDurationMs(EcoUnityComicTimelineEntry entry) {
  if (entry.durationMs > 0) {
    return entry.durationMs;
  }
  final int textLength = entry.dialogue.dialogue.trim().length;
  return math.max(1400, math.min(5000, textLength * 55));
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
