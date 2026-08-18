import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:ecounity/src/learning/ecounity_comic_speech_audio_controller.dart';
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_provider.dart';
import 'package:ecounity/src/learning/widgets/ecounity_comic_player.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EcoUnityComicScreen extends StatefulWidget {
  const EcoUnityComicScreen({
    super.key,
    required this.navIndex,
    this.activity,
    this.activityId,
  });

  final int navIndex;
  final EcoUnityLearningActivity? activity;
  final int? activityId;

  @override
  State<EcoUnityComicScreen> createState() => _EcoUnityComicScreenState();
}

class _EcoUnityComicScreenState extends State<EcoUnityComicScreen> {
  late final EcoUnityComicSpeechAudioController _speechAudioController;
  Future<_ComicScreenData>? _future;

  @override
  void initState() {
    super.initState();
    _speechAudioController = EcoUnityComicSpeechAudioController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _loadComicData();
  }

  @override
  void dispose() {
    unawaited(_speechAudioController.dispose());
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EcoUnityComicScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activity != widget.activity ||
        oldWidget.activityId != widget.activityId) {
      _future = _loadComicData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ComicScreenData>(
      future: _future,
      builder:
          (BuildContext context, AsyncSnapshot<_ComicScreenData> snapshot) {
            final EcoUnityLearningActivity? activity = snapshot.data?.activity;
            final String title = activity?.title ?? 'Comic';

            return ScreenScaffold(
              title: title,
              navigationIndex: widget.navIndex,
              fullWidth: true,
              child: _buildBody(context, snapshot),
            );
          },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<_ComicScreenData> snapshot,
  ) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Unable to load comic: ${snapshot.error}'));
    }

    final _ComicScreenData? data = snapshot.data;
    final EcoUnityLearningActivity? activity = data?.activity;
    if (data == null || activity == null || activity.comicScenes.isEmpty) {
      return const Center(child: Text('No comic scenes available'));
    }

    final EcoUnityComic comic = EcoUnityComic(
      activity: activity,
      scenes: activity.comicScenes,
      rawData: activity.rawData,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height * 0.82;
        return SizedBox(
          width: double.infinity,
          height: height,
          child: EcoUnityComicPlayer(
            comic: comic,
            language: data.language,
            loadingAdditionalScenes: data.loadingAdditionalScenes,
            onCompleted: () => _markCompleted(activity, data.language),
            onSpeechCueChanged: (EcoUnityComicSpeechItem? speech) {
              unawaited(_speechAudioController.playCue(speech));
            },
          ),
        );
      },
    );
  }

  Future<_ComicScreenData> _loadComicData() async {
    final EcoUnityLearningProvider learningProvider =
        Provider.of<EcoUnityLearningProvider>(context, listen: false);
    final String language = await core.Settings().getLanguage() ?? 'en';
    EcoUnityLearningActivity? activity = widget.activity;
    final int? activityId = widget.activityId ?? widget.activity?.id;

    if (activityId != null) {
      activity =
          await learningProvider.loadActivity(
            activityId,
            language: language,
            comicSceneLimit: 1,
          ) ??
          widget.activity;
      if (activity != null && activity.isComic) {
        _loadRemainingComicScenes(activityId, language, activity);
        return _ComicScreenData(
          activity: activity,
          language: language,
          loadingAdditionalScenes: true,
        );
      }
    }

    return _ComicScreenData(
      activity: activity,
      language: language,
      loadingAdditionalScenes: false,
    );
  }

  void _loadRemainingComicScenes(
    int activityId,
    String language,
    EcoUnityLearningActivity initialActivity,
  ) {
    unawaited(() async {
      try {
        final EcoUnityLearningActivity? fullActivity =
            await Provider.of<EcoUnityLearningProvider>(
              context,
              listen: false,
            ).loadActivity(activityId, language: language);
        if (!mounted || fullActivity == null) {
          return;
        }
        setState(() {
          _future = Future<_ComicScreenData>.value(
            _ComicScreenData(
              activity: fullActivity,
              language: language,
              loadingAdditionalScenes: false,
            ),
          );
        });
      } catch (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _future = Future<_ComicScreenData>.value(
            _ComicScreenData(
              activity: initialActivity,
              language: language,
              loadingAdditionalScenes: false,
            ),
          );
        });
      }
    }());
  }

  Future<void> _markCompleted(
    EcoUnityLearningActivity activity,
    String language,
  ) async {
    final int? moduleId = activity.moduleId;
    final int? activityId = activity.id;
    if (moduleId == null || activityId == null) {
      return;
    }

    await Provider.of<EcoUnityLearningProvider>(
      context,
      listen: false,
    ).markActivityCompleted(
      moduleId: moduleId,
      activityId: activityId,
      language: language,
      payload: <String, dynamic>{'activity_type': 'comic'},
    );
  }
}

class _ComicScreenData {
  const _ComicScreenData({
    required this.activity,
    required this.language,
    required this.loadingAdditionalScenes,
  });

  final EcoUnityLearningActivity? activity;
  final String language;
  final bool loadingAdditionalScenes;
}
