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
      BoxFit fit, {
      VoidCallback? onReady,
    });

typedef EcoUnityComicSpeechPreparationCallback =
    Future<void> Function(List<EcoUnityComicSpeechItem> speechItems);
typedef EcoUnityComicDecisionSelectionCallback =
    void Function(EcoUnityComicScene scene, EcoUnityComicDecision decision);

class EcoUnityComicPlayer extends StatefulWidget {
  const EcoUnityComicPlayer({
    super.key,
    required this.comic,
    this.language = 'en',
    this.onCompleted,
    this.onReadySpeech,
    this.onSpeechCueChanged,
    this.onPrepareSpeech,
    this.onSceneViewed,
    this.onDecisionSelected,
    this.imageBuilder,
    this.loadingAdditionalScenes = false,
  });

  final EcoUnityComic comic;
  final String language;
  final VoidCallback? onCompleted;
  final ValueChanged<EcoUnityComicSpeechItem>? onReadySpeech;
  final ValueChanged<EcoUnityComicSpeechItem?>? onSpeechCueChanged;
  final EcoUnityComicSpeechPreparationCallback? onPrepareSpeech;
  final ValueChanged<EcoUnityComicScene>? onSceneViewed;
  final EcoUnityComicDecisionSelectionCallback? onDecisionSelected;
  final EcoUnityComicImageBuilder? imageBuilder;
  final bool loadingAdditionalScenes;

  @override
  State<EcoUnityComicPlayer> createState() => _EcoUnityComicPlayerState();
}

class _EcoUnityComicPlayerState extends State<EcoUnityComicPlayer> {
  static const Duration _sceneRevealFadeDuration = Duration(milliseconds: 460);

  String? _sceneKey;
  int _timelineIndex = -1;
  EcoUnityComicTimelineEntry? _activeTimelineEntry;
  String? _activeTimelineEntryKey;
  String? _lastSpeechCueKey;
  bool _isTimelinePlaying = false;
  bool _sceneIsReady = false;
  bool _sceneRevealQueued = false;
  bool _waitingForAutoplay = false;
  String? _sceneAssetSignature;
  String? _sceneSpeechSignature;
  bool _sceneSpeechIsReady = true;
  bool _sceneSpeechPreparationQueued = false;
  Set<String> _expectedSceneAssetKeys = <String>{};
  final Set<String> _readySceneAssetKeys = <String>{};
  final Set<String> _autoplayedSceneKeys = <String>{};
  final List<Timer> _timelineTimers = <Timer>[];
  Timer? _sceneAutoplayTimer;
  int _timelineRunId = 0;

  @override
  void initState() {
    super.initState();
    _sceneKey = widget.comic.startScene?.sceneKey;
  }

  @override
  void didUpdateWidget(covariant EcoUnityComicPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) {
      _autoplayedSceneKeys.clear();
      _loadScene(widget.comic.startScene?.sceneKey, updateState: false);
      return;
    }

    if (oldWidget.comic != widget.comic) {
      final EcoUnityComicScene? currentScene = widget.comic.sceneByKey(
        _sceneKey,
      );
      if (currentScene == null) {
        _loadScene(widget.comic.startScene?.sceneKey, updateState: false);
        return;
      }
      final int timelineLength = currentScene
          .dialogueTimeline(widget.language)
          .length;
      if (_timelineIndex >= 0 &&
          timelineLength > 0 &&
          _timelineIndex >= timelineLength) {
        _timelineIndex = timelineLength;
      }
    }
  }

  @override
  void dispose() {
    _cancelSceneTimers();
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
    final EcoUnityComicTimelineEntry? currentEntry = _sceneIsReady
        ? _activeTimelineEntry
        : null;
    final bool sceneControlsLoading =
        !_sceneIsReady || (_waitingForAutoplay && timeline.isNotEmpty);
    final bool showDecisionControls =
        !sceneControlsLoading &&
        !_isTimelinePlaying &&
        scene.decisions.isNotEmpty &&
        (timeline.isEmpty || _timelineIndex >= timeline.length - 1);
    final EcoUnityComicViewportKind viewportKind = _viewportKindFor(context);
    _syncSceneSpeech(scene.sceneKey, timeline);
    _syncSceneAssets(
      scene.sceneKey,
      _expectedComicSceneAssetKeys(scene, viewportKind),
    );

    _cueSpeech(currentEntry);

    return Column(
      children: <Widget>[
        Expanded(
          child: _ComicSceneCanvas(
            scene: scene,
            language: widget.language,
            currentEntry: currentEntry,
            currentEntryKey: _activeTimelineEntryKey,
            isTimelinePlaying: _isTimelinePlaying,
            isSceneReady: _sceneIsReady,
            showDecisionControls: showDecisionControls,
            loadingAdditionalScenes: widget.loadingAdditionalScenes,
            viewportKind: viewportKind,
            imageBuilder: widget.imageBuilder,
            onAssetReady: (String assetKey) {
              _markSceneAssetReady(scene.sceneKey, assetKey);
            },
            onDecisionSelected: _selectDecision,
            canSelectDecision: (EcoUnityComicDecision decision) {
              return widget.comic.sceneForDecision(decision) != null;
            },
          ),
        ),
        _ComicNarrationCard(scene: scene),
        _ComicControls(
          scene: scene,
          timeline: timeline,
          timelineIndex: _timelineIndex,
          currentEntry: currentEntry,
          onContinue: () => _continue(scene, timeline),
          onPlaybackToggle: () => _toggleTimelinePlayback(scene, timeline),
          onCompleted: widget.onCompleted,
          loadingAdditionalScenes: widget.loadingAdditionalScenes,
          isTimelinePlaying: _isTimelinePlaying,
          isSceneLoading: sceneControlsLoading,
        ),
      ],
    );
  }

  void _cueSpeech(
    EcoUnityComicTimelineEntry? entry, {
    bool immediately = false,
  }) {
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
    if (readySpeech == null) {
      return;
    }

    void notifySpeechCue() {
      if (!mounted) {
        return;
      }
      widget.onSpeechCueChanged?.call(readySpeech);
      widget.onReadySpeech?.call(readySpeech);
    }

    if (immediately) {
      notifySpeechCue();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifySpeechCue();
    });
  }

  void _continue(
    EcoUnityComicScene scene,
    List<EcoUnityComicTimelineEntry> timeline,
  ) {
    if (!_sceneIsReady || _waitingForAutoplay) {
      return;
    }
    _stopTimelinePlayback(updateState: false, stopAudio: true);
    if (_timelineIndex < timeline.length - 1) {
      setState(() {
        _timelineIndex += 1;
        _activeTimelineEntry = timeline[_timelineIndex];
        _activeTimelineEntryKey = _timelineEntryKey(
          scene.sceneKey,
          _timelineIndex,
          _activeTimelineEntry!,
        );
      });
      return;
    }

    if (scene.decisions.isNotEmpty) {
      setState(() {
        _timelineIndex = timeline.length;
        _activeTimelineEntry = null;
        _activeTimelineEntryKey = null;
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

    final EcoUnityComicScene? currentScene = widget.comic.sceneByKey(_sceneKey);
    if (currentScene != null) {
      widget.onDecisionSelected?.call(currentScene, decision);
    }
    _loadScene(targetScene.sceneKey);
  }

  void _toggleTimelinePlayback(
    EcoUnityComicScene scene,
    List<EcoUnityComicTimelineEntry> timeline,
  ) {
    if (!_sceneIsReady || _waitingForAutoplay) {
      return;
    }
    if (_isTimelinePlaying) {
      _stopTimelinePlayback(stopAudio: true);
      return;
    }
    unawaited(_prepareTimelineSpeech(scene.sceneKey, timeline));
    _startTimelinePlayback(scene, timeline);
  }

  void _startTimelinePlayback(
    EcoUnityComicScene scene,
    List<EcoUnityComicTimelineEntry> timeline,
  ) {
    if (!_sceneIsReady || timeline.isEmpty) {
      return;
    }

    _cancelTimelineTimers();
    final int runId = ++_timelineRunId;
    final List<_TimelineCue> cues = _timelineCuesFor(scene.sceneKey, timeline);
    final int totalDurationMs = cues.fold<int>(
      0,
      (int currentMax, _TimelineCue cue) => math.max(currentMax, cue.endMs),
    );

    setState(() {
      _isTimelinePlaying = true;
      _waitingForAutoplay = false;
      _timelineIndex = -1;
      _activeTimelineEntry = null;
      _activeTimelineEntryKey = null;
      _lastSpeechCueKey = null;
    });

    for (final _TimelineCue cue in cues) {
      if (cue.startMs <= 0) {
        _activateTimelineCue(scene.sceneKey, cue, runId);
      } else {
        _timelineTimers.add(
          Timer(Duration(milliseconds: cue.startMs), () {
            _activateTimelineCue(scene.sceneKey, cue, runId);
          }),
        );
      }
      _timelineTimers.add(
        Timer(Duration(milliseconds: cue.endMs), () {
          _clearTimelineCue(scene.sceneKey, cue, runId);
        }),
      );
    }

    _timelineTimers.add(
      Timer(Duration(milliseconds: math.max(0, totalDurationMs)), () {
        if (!_timelineTimerIsCurrent(scene.sceneKey, runId)) {
          return;
        }
        setState(() {
          _isTimelinePlaying = false;
          _timelineIndex = timeline.length;
          _activeTimelineEntry = null;
          _activeTimelineEntryKey = null;
        });
        widget.onSpeechCueChanged?.call(null);
      }),
    );
  }

  void _activateTimelineCue(String sceneKey, _TimelineCue cue, int runId) {
    if (!_timelineTimerIsCurrent(sceneKey, runId)) {
      return;
    }
    setState(() {
      _timelineIndex = cue.index;
      _activeTimelineEntry = cue.entry;
      _activeTimelineEntryKey = cue.key;
    });
    _cueSpeech(cue.entry, immediately: true);
  }

  void _clearTimelineCue(String sceneKey, _TimelineCue cue, int runId) {
    if (!_timelineTimerIsCurrent(sceneKey, runId)) {
      return;
    }
    if (_activeTimelineEntryKey != cue.key) {
      return;
    }
    setState(() {
      _activeTimelineEntry = null;
      _activeTimelineEntryKey = null;
    });
  }

  bool _timelineTimerIsCurrent(String sceneKey, int runId) {
    return mounted &&
        _timelineRunId == runId &&
        _sceneKey == sceneKey &&
        widget.comic.sceneByKey(sceneKey) != null;
  }

  void _stopTimelinePlayback({
    bool updateState = true,
    required bool stopAudio,
  }) {
    _cancelTimelineTimers();
    _timelineRunId += 1;
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

  void _loadScene(String? sceneKey, {bool updateState = true}) {
    _cancelSceneTimers();
    _cancelTimelineTimers();
    widget.onSpeechCueChanged?.call(null);

    void assignState() {
      _sceneKey = sceneKey;
      _timelineIndex = -1;
      _activeTimelineEntry = null;
      _activeTimelineEntryKey = null;
      _lastSpeechCueKey = null;
      _isTimelinePlaying = false;
      _sceneIsReady = false;
      _sceneRevealQueued = false;
      _waitingForAutoplay = false;
      _sceneAssetSignature = null;
      _sceneSpeechSignature = null;
      _sceneSpeechIsReady = true;
      _sceneSpeechPreparationQueued = false;
      _expectedSceneAssetKeys = <String>{};
      _readySceneAssetKeys.clear();
    }

    if (mounted && updateState) {
      setState(assignState);
    } else {
      assignState();
    }
  }

  void _syncSceneSpeech(
    String? sceneKey,
    List<EcoUnityComicTimelineEntry> timeline,
  ) {
    final List<EcoUnityComicSpeechItem> speechItems = _readySpeechItems(
      timeline,
    );
    final String signature = _sceneSpeechSignatureFor(sceneKey, speechItems);
    if (_sceneSpeechSignature != signature) {
      _sceneSpeechSignature = signature;
      _sceneSpeechIsReady =
          speechItems.isEmpty || widget.onPrepareSpeech == null;
      _sceneSpeechPreparationQueued = _sceneSpeechIsReady;
      _sceneRevealQueued = false;
    }

    if (!_sceneSpeechIsReady && !_sceneSpeechPreparationQueued) {
      _sceneSpeechPreparationQueued = true;
      unawaited(_prepareSceneSpeech(sceneKey, signature, speechItems));
    }

    _tryRevealScene(sceneKey, allowImmediate: false);
  }

  void _syncSceneAssets(String? sceneKey, Set<String> expectedAssetKeys) {
    final String signature = _sceneAssetSignatureFor(
      sceneKey,
      expectedAssetKeys,
    );
    if (_sceneAssetSignature != signature) {
      _sceneAssetSignature = signature;
      _expectedSceneAssetKeys = expectedAssetKeys;
      _readySceneAssetKeys.removeWhere(
        (String assetKey) => !expectedAssetKeys.contains(assetKey),
      );
      _sceneRevealQueued = false;
    }
    _tryRevealScene(sceneKey, allowImmediate: false);
  }

  void _markSceneAssetReady(String? sceneKey, String assetKey) {
    if (!mounted ||
        _sceneKey != sceneKey ||
        !_expectedSceneAssetKeys.contains(assetKey)) {
      return;
    }
    if (_readySceneAssetKeys.add(assetKey)) {
      _tryRevealScene(sceneKey, allowImmediate: true);
    }
  }

  void _tryRevealScene(String? sceneKey, {required bool allowImmediate}) {
    if (!mounted ||
        _sceneIsReady ||
        sceneKey == null ||
        sceneKey.trim().isEmpty ||
        _sceneKey != sceneKey ||
        !_allSceneAssetsReady ||
        !_sceneSpeechIsReady) {
      return;
    }

    if (allowImmediate) {
      _revealScene(sceneKey);
      return;
    }

    if (_sceneRevealQueued) {
      return;
    }
    _sceneRevealQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _sceneRevealQueued = false;
      _tryRevealScene(sceneKey, allowImmediate: true);
    });
  }

  bool get _allSceneAssetsReady {
    for (final String assetKey in _expectedSceneAssetKeys) {
      if (!_readySceneAssetKeys.contains(assetKey)) {
        return false;
      }
    }
    return true;
  }

  void _revealScene(String sceneKey) {
    if (!mounted || _sceneKey != sceneKey || _sceneIsReady) {
      return;
    }

    final EcoUnityComicScene? scene = widget.comic.sceneByKey(sceneKey);
    if (scene == null) {
      return;
    }
    final List<EcoUnityComicTimelineEntry> timeline = scene.dialogueTimeline(
      widget.language,
    );
    final bool shouldAutoplay =
        timeline.isNotEmpty && !_autoplayedSceneKeys.contains(sceneKey);

    setState(() {
      _sceneIsReady = true;
      _waitingForAutoplay = shouldAutoplay;
    });
    widget.onSceneViewed?.call(scene);

    if (!shouldAutoplay) {
      return;
    }

    _sceneAutoplayTimer?.cancel();
    _sceneAutoplayTimer = Timer(_sceneRevealFadeDuration, () {
      _startAutoplay(sceneKey);
    });
  }

  void _startAutoplay(String sceneKey) {
    if (!mounted || _sceneKey != sceneKey) {
      return;
    }
    final EcoUnityComicScene? scene = widget.comic.sceneByKey(sceneKey);
    if (scene == null) {
      return;
    }

    _autoplayedSceneKeys.add(sceneKey);
    _startTimelinePlayback(scene, scene.dialogueTimeline(widget.language));
  }

  Future<void> _prepareTimelineSpeech(
    String sceneKey,
    List<EcoUnityComicTimelineEntry> timeline,
  ) async {
    final List<EcoUnityComicSpeechItem> speechItems = _readySpeechItems(
      timeline,
    );
    await _prepareSpeechItems(sceneKey, speechItems);
  }

  Future<void> _prepareSceneSpeech(
    String? sceneKey,
    String signature,
    List<EcoUnityComicSpeechItem> speechItems,
  ) async {
    await _prepareSpeechItems(sceneKey, speechItems);
    if (!mounted ||
        _sceneKey != sceneKey ||
        _sceneSpeechSignature != signature ||
        _sceneSpeechIsReady) {
      return;
    }

    setState(() {
      _sceneSpeechIsReady = true;
    });
    _tryRevealScene(sceneKey, allowImmediate: true);
  }

  Future<void> _prepareSpeechItems(
    String? sceneKey,
    List<EcoUnityComicSpeechItem> speechItems,
  ) async {
    final EcoUnityComicSpeechPreparationCallback? prepareSpeech =
        widget.onPrepareSpeech;
    if (prepareSpeech == null) {
      return;
    }
    if (speechItems.isEmpty) {
      return;
    }

    try {
      await prepareSpeech(
        speechItems,
      ).timeout(const Duration(seconds: 4), onTimeout: () {});
    } catch (_) {
      // Audio preparation is an optimization; text playback must continue.
    }
    if (!mounted || _sceneKey != sceneKey) {
      return;
    }
  }

  void _cancelTimelineTimers() {
    for (final Timer timer in _timelineTimers) {
      timer.cancel();
    }
    _timelineTimers.clear();
    _timelineRunId += 1;
  }

  void _cancelSceneTimers() {
    _sceneAutoplayTimer?.cancel();
    _sceneAutoplayTimer = null;
    _sceneRevealQueued = false;
  }
}

class _ComicSceneCanvas extends StatelessWidget {
  const _ComicSceneCanvas({
    required this.scene,
    required this.language,
    required this.currentEntry,
    required this.currentEntryKey,
    required this.isTimelinePlaying,
    required this.isSceneReady,
    required this.showDecisionControls,
    required this.loadingAdditionalScenes,
    required this.viewportKind,
    required this.imageBuilder,
    required this.onAssetReady,
    required this.onDecisionSelected,
    required this.canSelectDecision,
  });

  final EcoUnityComicScene scene;
  final String language;
  final EcoUnityComicTimelineEntry? currentEntry;
  final String? currentEntryKey;
  final bool isTimelinePlaying;
  final bool isSceneReady;
  final bool showDecisionControls;
  final bool loadingAdditionalScenes;
  final EcoUnityComicViewportKind viewportKind;
  final EcoUnityComicImageBuilder? imageBuilder;
  final ValueChanged<String> onAssetReady;
  final ValueChanged<EcoUnityComicDecision> onDecisionSelected;
  final bool Function(EcoUnityComicDecision decision) canSelectDecision;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints _) {
        final EcoUnityComicViewport? viewport = scene.viewportFor(viewportKind);
        final double aspectRatio = _canvasAspectRatio(viewport, viewportKind);
        final List<EcoUnityComicDrawableLayer> layers = scene.drawableLayersFor(
          viewportKind,
        );
        final List<_DecisionLayerData> decisionLayers = showDecisionControls
            ? _decisionLayerDataFor(scene, viewportKind)
            : const <_DecisionLayerData>[];
        final String? backgroundAssetKey = _comicBackgroundAssetKey(
          scene,
          viewport,
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
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          _ComicImage(
                            key: backgroundAssetKey == null
                                ? null
                                : ValueKey<String>(
                                    'comic-background-image-$backgroundAssetKey',
                                  ),
                            media: viewport?.backgroundImage,
                            altText: scene.altText.isNotEmpty
                                ? scene.altText
                                : scene.title,
                            fit: BoxFit.cover,
                            imageBuilder: imageBuilder,
                            onReady: backgroundAssetKey == null
                                ? null
                                : () => onAssetReady(backgroundAssetKey),
                          ),
                          for (final EcoUnityComicDrawableLayer layer in layers)
                            _PositionedComicLayer(
                              sceneKey: scene.sceneKey,
                              layer: layer,
                              constraints: constraints,
                              imageBuilder: imageBuilder,
                              onAssetReady: onAssetReady,
                            ),
                          _AnimatedDialogueBubble(
                            entry: currentEntry,
                            entryKey: currentEntryKey,
                            viewportKind: viewportKind,
                            constraints: constraints,
                            dimmed: isTimelinePlaying,
                          ),
                          for (final _DecisionLayerData decisionLayer
                              in decisionLayers)
                            _PositionedDecisionLayer(
                              sceneKey: scene.sceneKey,
                              decisionLayer: decisionLayer,
                              constraints: constraints,
                              imageBuilder: imageBuilder,
                              enabled: canSelectDecision(
                                decisionLayer.decision,
                              ),
                              loading:
                                  loadingAdditionalScenes &&
                                  !canSelectDecision(decisionLayer.decision),
                              onSelected: () =>
                                  onDecisionSelected(decisionLayer.decision),
                            ),
                          _SceneLoadingOverlay(isSceneReady: isSceneReady),
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
    required this.sceneKey,
    required this.layer,
    required this.constraints,
    required this.imageBuilder,
    required this.onAssetReady,
  });

  final String sceneKey;
  final EcoUnityComicDrawableLayer layer;
  final BoxConstraints constraints;
  final EcoUnityComicImageBuilder? imageBuilder;
  final ValueChanged<String> onAssetReady;

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
    final String? assetKey = _comicLayerAssetKey(sceneKey, layer);

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
                key: assetKey == null
                    ? null
                    : ValueKey<String>('comic-layer-image-$assetKey'),
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
                onReady: assetKey == null ? null : () => onAssetReady(assetKey),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PositionedDecisionLayer extends StatelessWidget {
  const _PositionedDecisionLayer({
    required this.sceneKey,
    required this.decisionLayer,
    required this.constraints,
    required this.imageBuilder,
    required this.enabled,
    required this.loading,
    required this.onSelected,
  });

  final String sceneKey;
  final _DecisionLayerData decisionLayer;
  final BoxConstraints constraints;
  final EcoUnityComicImageBuilder? imageBuilder;
  final bool enabled;
  final bool loading;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final EcoUnityComicDrawableLayer layer = decisionLayer.layer;
    final EcoUnityComicLayout layout = layer.layout;
    final double width = (constraints.maxWidth * 0.32 * layout.scale)
        .clamp(96, constraints.maxWidth * 0.72)
        .toDouble();
    final double left = constraints.maxWidth * layout.x;
    final double top = constraints.maxHeight * layout.y;
    final bool hasImage =
        layer.media != null || (layer.imageUrl?.trim().isNotEmpty ?? false);

    return Positioned(
      left: left,
      top: top,
      width: width,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Semantics(
          button: true,
          enabled: enabled,
          label: decisionLayer.decision.label,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: _comicLayerKey(layer),
              borderRadius: BorderRadius.circular(8),
              onTap: enabled ? onSelected : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: enabled ? 1 : 0.72,
                child: hasImage
                    ? _DecisionImageHotspot(
                        sceneKey: sceneKey,
                        layer: layer,
                        label: decisionLayer.decision.label,
                        loading: loading,
                        imageBuilder: imageBuilder,
                      )
                    : _DecisionLabelHotspot(
                        label: decisionLayer.decision.label,
                        loading: loading,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DecisionImageHotspot extends StatelessWidget {
  const _DecisionImageHotspot({
    required this.sceneKey,
    required this.layer,
    required this.label,
    required this.loading,
    required this.imageBuilder,
  });

  final String sceneKey;
  final EcoUnityComicDrawableLayer layer;
  final String label;
  final bool loading;
  final EcoUnityComicImageBuilder? imageBuilder;

  @override
  Widget build(BuildContext context) {
    final String? assetKey = _comicLayerAssetKey(sceneKey, layer);
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: AspectRatio(
            aspectRatio: 1,
            child: Transform.rotate(
              angle: layer.layout.rotation * math.pi / 180,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(
                  layer.layout.flipX ? -1.0 : 1.0,
                  1.0,
                  1.0,
                ),
                child: _ComicImage(
                  key: assetKey == null
                      ? null
                      : ValueKey<String>('comic-decision-image-$assetKey'),
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
                  onReady: null,
                ),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          start: 0,
          end: 0,
          bottom: 0,
          child: Center(
            child: _DecisionLabelChip(label: label, loading: loading),
          ),
        ),
      ],
    );
  }
}

class _DecisionLabelHotspot extends StatelessWidget {
  const _DecisionLabelHotspot({required this.label, required this.loading});

  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _DecisionLabelChip(label: label, loading: loading),
    );
  }
}

class _DecisionLabelChip extends StatelessWidget {
  const _DecisionLabelChip({required this.label, required this.loading});

  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.deepTeal.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x440D404E),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (loading) ...<Widget>[
              const SizedBox(width: 8),
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ] else ...<Widget>[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _SceneLoadingOverlay extends StatelessWidget {
  const _SceneLoadingOverlay({required this.isSceneReady});

  final bool isSceneReady;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: isSceneReady,
        child: AnimatedOpacity(
          duration: _EcoUnityComicPlayerState._sceneRevealFadeDuration,
          curve: Curves.easeOutCubic,
          opacity: isSceneReady ? 0 : 1,
          child: ColoredBox(
            color: Colors.black,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isSceneReady
                    ? const SizedBox.shrink()
                    : Column(
                        key: const ValueKey<String>('scene-loading'),
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const SizedBox.square(
                            dimension: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.6,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Loading scene...',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
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
    required this.entryKey,
    required this.viewportKind,
    required this.constraints,
    required this.dimmed,
  });

  final EcoUnityComicTimelineEntry? entry;
  final String? entryKey;
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
                  key: ValueKey<String>(
                    entryKey ?? 'dialogue-${entry!.dialogue.id}',
                  ),
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
    final double rawTop = constraints.maxHeight * layout.bubbleY;
    final double speakerCenterY = constraints.maxHeight * layout.y;
    final bool bubbleIsAboveSpeaker = rawTop < speakerCenterY;
    final double top = (rawTop - (bubbleIsAboveSpeaker ? 24 : 0))
        .clamp(16, maxTop)
        .toDouble();
    final double speakerCenterX = constraints.maxWidth * layout.x;
    final double tailFraction = ((speakerCenterX - left) / maxWidth)
        .clamp(0.18, 0.82)
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      width: maxWidth,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: dimmed ? 0.96 : 1,
        child: CustomPaint(
          painter: _SpeechBubblePainter(
            tailFraction: tailFraction,
            dimmed: dimmed,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if ((entry.castLayer.character?.name ?? '').isNotEmpty) ...[
                  Text(
                    entry.castLayer.character!.name,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: EcoUnityColors.deepTeal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  entry.dialogue.dialogue,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: EcoUnityColors.textPrimary,
                    height: 1.28,
                    fontWeight: FontWeight.w600,
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

class _SpeechBubblePainter extends CustomPainter {
  const _SpeechBubblePainter({
    required this.tailFraction,
    required this.dimmed,
  });

  final double tailFraction;
  final bool dimmed;

  @override
  void paint(Canvas canvas, Size size) {
    const double radius = 16;
    const double tailHeight = 16;
    const double tailWidth = 28;
    final double bodyBottom = math.max(0, size.height - tailHeight);
    final double tailCenter = (size.width * tailFraction)
        .clamp(radius + tailWidth / 2, size.width - radius - tailWidth / 2)
        .toDouble();
    final double tailLeft = tailCenter - tailWidth / 2;
    final double tailRight = tailCenter + tailWidth / 2;
    final Path bubblePath = Path()
      ..moveTo(radius, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, bodyBottom - radius)
      ..quadraticBezierTo(
        size.width,
        bodyBottom,
        size.width - radius,
        bodyBottom,
      )
      ..lineTo(tailRight, bodyBottom)
      ..quadraticBezierTo(
        tailCenter + 8,
        bodyBottom + tailHeight * 0.34,
        tailCenter,
        bodyBottom + tailHeight,
      )
      ..quadraticBezierTo(
        tailCenter - 7,
        bodyBottom + tailHeight * 0.36,
        tailLeft,
        bodyBottom,
      )
      ..lineTo(radius, bodyBottom)
      ..quadraticBezierTo(0, bodyBottom, 0, bodyBottom - radius)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..close();

    canvas.drawShadow(
      bubblePath,
      const Color(0x550D404E),
      dimmed ? 8 : 5,
      false,
    );
    canvas.drawPath(
      bubblePath,
      Paint()..color = Colors.white.withValues(alpha: dimmed ? 0.98 : 1),
    );
    canvas.drawPath(
      bubblePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = EcoUnityColors.deepTeal.withValues(alpha: 0.82),
    );
  }

  @override
  bool shouldRepaint(covariant _SpeechBubblePainter oldDelegate) {
    return oldDelegate.tailFraction != tailFraction ||
        oldDelegate.dimmed != dimmed;
  }
}

class _ComicNarrationCard extends StatelessWidget {
  const _ComicNarrationCard({required this.scene});

  final EcoUnityComicScene scene;

  @override
  Widget build(BuildContext context) {
    final String narration = scene.narration.trim();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: narration.isEmpty
          ? SizedBox.shrink(
              key: ValueKey<String>('narration-empty-${scene.sceneKey}'),
            )
          : Padding(
              key: ValueKey<String>('narration-${scene.sceneKey}'),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: EcoUnityColors.outlineVariant),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x160D404E),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 132),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(
                          Icons.auto_stories_outlined,
                          size: 20,
                          color: EcoUnityColors.deepTeal,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            narration,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: EcoUnityColors.textSecondary,
                                  height: 1.35,
                                ),
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
    required this.onCompleted,
    required this.loadingAdditionalScenes,
    required this.isTimelinePlaying,
    required this.isSceneLoading,
  });

  final EcoUnityComicScene scene;
  final List<EcoUnityComicTimelineEntry> timeline;
  final int timelineIndex;
  final EcoUnityComicTimelineEntry? currentEntry;
  final VoidCallback onContinue;
  final VoidCallback onPlaybackToggle;
  final VoidCallback? onCompleted;
  final bool loadingAdditionalScenes;
  final bool isTimelinePlaying;
  final bool isSceneLoading;

  @override
  Widget build(BuildContext context) {
    final bool showDecisionControls =
        !isTimelinePlaying &&
        scene.decisions.isNotEmpty &&
        timeline.isNotEmpty &&
        timelineIndex >= timeline.length - 1;

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: EcoUnityColors.outlineVariant)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 88),
            child: Align(
              alignment: Alignment.center,
              child: isSceneLoading
                  ? const _ComicLoadingControls()
                  : isTimelinePlaying
                  ? _buildTimelinePlayingControls(context)
                  : showDecisionControls
                  ? _buildSceneEndControls(context)
                  : currentEntry != null
                  ? _buildDialogueControls(context)
                  : _buildSceneEndControls(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelinePlayingControls(BuildContext context) {
    final int totalSteps = math.max(timeline.length, 1);
    final int currentStep =
        timelineIndex >= 0 && timelineIndex < timeline.length
        ? timelineIndex + 1
        : 0;
    return Row(
      children: <Widget>[
        Expanded(
          child: currentStep > 0
              ? LinearProgressIndicator(
                  value: currentStep / totalSteps,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(999),
                )
              : Text(
                  'Playing...',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: EcoUnityColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        if (currentStep > 0) ...<Widget>[
          const SizedBox(width: 12),
          Text(
            '$currentStep / $totalSteps',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: EcoUnityColors.textSecondary,
            ),
          ),
        ],
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
    );
  }

  Widget _buildDialogueControls(BuildContext context) {
    final int currentStep = timelineIndex + 1;
    final int totalSteps = math.max(timeline.length, 1);
    final bool isLastDialogue = currentStep >= totalSteps;
    final bool showPrimaryAction =
        !(isTimelinePlaying && isLastDialogue && scene.decisions.isNotEmpty);
    final String buttonLabel = isLastDialogue
        ? (scene.decisions.isEmpty ? 'Complete' : 'Continue')
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
        if (showPrimaryAction) ...<Widget>[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinue,
              child: Text(buttonLabel),
            ),
          ),
        ],
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

class _ComicLoadingControls extends StatelessWidget {
  const _ComicLoadingControls();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: EcoUnityColors.deepTeal.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Loading scene...',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: EcoUnityColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
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
    super.key,
    required this.media,
    required this.altText,
    required this.fit,
    required this.imageBuilder,
    required this.onReady,
  });

  final EcoUnityMedia? media;
  final String altText;
  final BoxFit fit;
  final EcoUnityComicImageBuilder? imageBuilder;
  final VoidCallback? onReady;

  @override
  Widget build(BuildContext context) {
    if (imageBuilder != null) {
      return imageBuilder!(context, media, altText, fit, onReady: onReady);
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
        onReady: onReady,
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

Set<String> _expectedComicSceneAssetKeys(
  EcoUnityComicScene scene,
  EcoUnityComicViewportKind viewportKind,
) {
  final Set<String> assetKeys = <String>{};
  final EcoUnityComicViewport? viewport = scene.viewportFor(viewportKind);
  final String? backgroundAssetKey = _comicBackgroundAssetKey(
    scene,
    viewport,
    viewportKind,
  );
  if (backgroundAssetKey != null) {
    assetKeys.add(backgroundAssetKey);
  }
  for (final EcoUnityComicDrawableLayer layer in scene.drawableLayersFor(
    viewportKind,
  )) {
    final String? assetKey = _comicLayerAssetKey(scene.sceneKey, layer);
    if (assetKey != null) {
      assetKeys.add(assetKey);
    }
  }
  return assetKeys;
}

List<_DecisionLayerData> _decisionLayerDataFor(
  EcoUnityComicScene scene,
  EcoUnityComicViewportKind viewportKind,
) {
  final List<_DecisionLayerData> decisionLayers = scene.decisions
      .map(
        (EcoUnityComicDecision decision) => _DecisionLayerData(
          decision: decision,
          layer: decision.toDrawableLayer(viewportKind),
        ),
      )
      .toList();
  decisionLayers.sort(
    (_DecisionLayerData a, _DecisionLayerData b) =>
        _compareCanvasLayers(a.layer, b.layer),
  );
  return decisionLayers;
}

int _compareCanvasLayers(
  EcoUnityComicDrawableLayer a,
  EcoUnityComicDrawableLayer b,
) {
  final int byZIndex = a.effectiveZIndex.compareTo(b.effectiveZIndex);
  if (byZIndex != 0) {
    return byZIndex;
  }
  return a.orderNo.compareTo(b.orderNo);
}

class _DecisionLayerData {
  const _DecisionLayerData({required this.decision, required this.layer});

  final EcoUnityComicDecision decision;
  final EcoUnityComicDrawableLayer layer;
}

String _sceneAssetSignatureFor(String? sceneKey, Set<String> assetKeys) {
  final List<String> sortedAssetKeys = assetKeys.toList()..sort();
  return '${sceneKey ?? ''}|${sortedAssetKeys.join('|')}';
}

String _sceneSpeechSignatureFor(
  String? sceneKey,
  List<EcoUnityComicSpeechItem> speechItems,
) {
  final List<String> speechKeys =
      speechItems
          .map(
            (EcoUnityComicSpeechItem speech) =>
                '${speech.id ?? ''}:${speech.language}:'
                '${speech.generationStatus.name}:${speech.audioFile?.url ?? ''}',
          )
          .toList()
        ..sort();
  return '${sceneKey ?? ''}|${speechKeys.join('|')}';
}

String? _comicBackgroundAssetKey(
  EcoUnityComicScene scene,
  EcoUnityComicViewport? viewport,
  EcoUnityComicViewportKind viewportKind,
) {
  return _comicMediaAssetKey(
    'background:${scene.sceneKey}:${viewportKind.name}',
    viewport?.backgroundImage,
  );
}

String? _comicLayerAssetKey(String sceneKey, EcoUnityComicDrawableLayer layer) {
  final String layerId = layer.id?.toString() ?? layer.label;
  final String? url = _nonEmpty(layer.media?.url) ?? _nonEmpty(layer.imageUrl);
  final int? id = layer.media?.id;
  if (url == null && id == null) {
    return null;
  }
  return 'layer:$sceneKey:${layer.kind.name}:$layerId:${url ?? 'id:$id'}';
}

String? _comicMediaAssetKey(String prefix, EcoUnityMedia? media) {
  final String? url = _nonEmpty(media?.url);
  final int? id = media?.id;
  if (url == null && id == null) {
    return null;
  }
  return '$prefix:${url ?? 'id:$id'}';
}

String? _nonEmpty(String? value) {
  final String? trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

EcoUnityComicViewportKind _viewportKindFor(BuildContext context) {
  final Size? mediaSize = MediaQuery.maybeOf(context)?.size;
  if (mediaSize != null && mediaSize.width > 0 && mediaSize.height > 0) {
    return mediaSize.height >= mediaSize.width
        ? EcoUnityComicViewportKind.portrait
        : EcoUnityComicViewportKind.landscape;
  }
  return EcoUnityComicViewportKind.portrait;
}

class _TimelineCue {
  const _TimelineCue({
    required this.index,
    required this.entry,
    required this.key,
    required this.startMs,
    required this.endMs,
  });

  final int index;
  final EcoUnityComicTimelineEntry entry;
  final String key;
  final int startMs;
  final int endMs;
}

List<_TimelineCue> _timelineCuesFor(
  String sceneKey,
  List<EcoUnityComicTimelineEntry> timeline,
) {
  final List<_TimelineCue> cues = <_TimelineCue>[];
  int previousStartMs = -1;
  int cursorMs = 0;

  for (int index = 0; index < timeline.length; index += 1) {
    final EcoUnityComicTimelineEntry entry = timeline[index];
    int startMs = math.max(0, entry.startMs);
    if (index > 0 && startMs <= previousStartMs) {
      startMs = cursorMs;
    }
    final int durationMs = _playbackDurationMs(entry);
    final int endMs = math.max(startMs + 500, startMs + durationMs);
    cues.add(
      _TimelineCue(
        index: index,
        entry: entry,
        key: _timelineEntryKey(sceneKey, index, entry),
        startMs: startMs,
        endMs: endMs,
      ),
    );
    previousStartMs = startMs;
    cursorMs = math.max(cursorMs, endMs + 120);
  }

  return cues;
}

String _timelineEntryKey(
  String sceneKey,
  int index,
  EcoUnityComicTimelineEntry entry,
) {
  return 'dialogue-$sceneKey-$index-${entry.dialogue.id ?? 'no-id'}-'
      '${entry.speech?.id ?? 'no-speech'}-${entry.startMs}';
}

int _playbackDurationMs(EcoUnityComicTimelineEntry entry) {
  if (entry.durationMs > 0) {
    return entry.durationMs;
  }
  final int textLength = entry.dialogue.dialogue.trim().length;
  return math.max(1400, math.min(5000, textLength * 55));
}

List<EcoUnityComicSpeechItem> _readySpeechItems(
  List<EcoUnityComicTimelineEntry> timeline,
) {
  final Map<String, EcoUnityComicSpeechItem> speechByUrl =
      <String, EcoUnityComicSpeechItem>{};
  for (final EcoUnityComicTimelineEntry entry in timeline) {
    final EcoUnityComicSpeechItem? speech = entry.speech;
    final String? url = speech?.audioFile?.url?.trim();
    if (speech == null || !speech.hasReadyAudio || url == null || url.isEmpty) {
      continue;
    }
    speechByUrl.putIfAbsent(url, () => speech);
  }
  return speechByUrl.values.toList();
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
