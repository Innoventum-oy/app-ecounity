import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:ecounity/src/analytics/ecounity_analytics_service.dart';
import 'package:ecounity/src/learning/ecounity_comic_speech_audio_controller.dart';
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_provider.dart';
import 'package:ecounity/src/learning/widgets/ecounity_comic_player.dart';
import 'package:ecounity/src/learning/widgets/ecounity_teacher_objective_card.dart';
import 'package:ecounity/src/providers/teacher_mode_provider.dart';
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
  _ComicScreenData? _latestData;
  final Set<String> _trackedActivityStartKeys = <String>{};
  final Set<String> _trackedModuleCompletionKeys = <String>{};
  final Map<String, DateTime> _activityStartedAtByKey = <String, DateTime>{};

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
      _latestData = null;
      _future = _loadComicData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ComicScreenData>(
      future: _future,
      initialData: _latestData,
      builder:
          (BuildContext context, AsyncSnapshot<_ComicScreenData> snapshot) {
            final _ComicScreenData? data = snapshot.data ?? _latestData;
            final EcoUnityLearningActivity? activity = data?.activity;
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
    final _ComicScreenData? data = snapshot.data ?? _latestData;
    if (snapshot.connectionState != ConnectionState.done && data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError && data == null) {
      return Center(child: Text('Unable to load comic: ${snapshot.error}'));
    }

    final EcoUnityLearningActivity? activity = data?.activity;
    if (data == null || activity == null || activity.comicScenes.isEmpty) {
      return const Center(child: Text('No comic scenes available'));
    }

    final EcoUnityComic comic = EcoUnityComic(
      activity: activity,
      scenes: activity.comicScenes,
      rawData: activity.rawData,
    );
    final bool teacherModeEnabled = Provider.of<TeacherModeProvider>(
      context,
    ).isTeacherMode;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height * 0.82;
        final Widget player = EcoUnityComicPlayer(
          comic: comic,
          language: data.language,
          loadingAdditionalScenes: data.loadingAdditionalScenes,
          onCompleted: () => _markCompleted(activity, data.language),
          onSceneViewed: (EcoUnityComicScene scene) {
            _trackComicSceneViewed(activity, data.language, scene);
          },
          onDecisionSelected:
              (EcoUnityComicScene scene, EcoUnityComicDecision decision) {
                _trackComicDecisionSelected(
                  activity,
                  data.language,
                  scene,
                  decision,
                );
              },
          onPrepareSpeech: _speechAudioController.prepareCues,
          onSpeechCueChanged: (EcoUnityComicSpeechItem? speech) {
            unawaited(_speechAudioController.playCue(speech));
          },
        );
        return SizedBox(
          width: double.infinity,
          height: height,
          child: teacherModeEnabled && activity.learningObjective.isNotEmpty
              ? Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: EcoUnityTeacherObjectiveCard(
                        learningObjective: activity.learningObjective,
                      ),
                    ),
                    Expanded(child: player),
                  ],
                )
              : player,
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
      final EcoUnityLearningActivity? cachedFullActivity = learningProvider
          .cachedActivity(activityId, language: language);
      if (cachedFullActivity != null && cachedFullActivity.isComic) {
        return _rememberData(
          _ComicScreenData(
            activity: cachedFullActivity,
            language: language,
            loadingAdditionalScenes: false,
          ),
        );
      }

      activity =
          await learningProvider.loadActivity(
            activityId,
            language: language,
            comicSceneLimit: 1,
          ) ??
          widget.activity;
      if (activity != null && activity.isComic) {
        final bool loadingAdditionalScenes = _needsAdditionalComicScenes(
          activity,
        );
        if (loadingAdditionalScenes) {
          _loadRemainingComicScenes(activityId, language, activity);
        }
        return _rememberData(
          _ComicScreenData(
            activity: activity,
            language: language,
            loadingAdditionalScenes: loadingAdditionalScenes,
          ),
        );
      }
    }

    return _rememberData(
      _ComicScreenData(
        activity: activity,
        language: language,
        loadingAdditionalScenes: false,
      ),
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
        final _ComicScreenData data = _ComicScreenData(
          activity: fullActivity,
          language: language,
          loadingAdditionalScenes: false,
        );
        setState(() {
          _latestData = data;
          _future = Future<_ComicScreenData>.value(data);
        });
      } catch (_) {
        if (!mounted) {
          return;
        }
        final _ComicScreenData data = _ComicScreenData(
          activity: initialActivity,
          language: language,
          loadingAdditionalScenes: false,
        );
        setState(() {
          _latestData = data;
          _future = Future<_ComicScreenData>.value(data);
        });
      }
    }());
  }

  _ComicScreenData _rememberData(_ComicScreenData data) {
    _latestData = data;
    final EcoUnityLearningActivity? activity = data.activity;
    if (activity != null) {
      _trackActivityStarted(activity, data.language);
    }
    return data;
  }

  Future<void> _markCompleted(
    EcoUnityLearningActivity activity,
    String language,
  ) async {
    final int? moduleId = activity.moduleId;
    final int? activityId = activity.id;
    if (_teacherModeEnabled()) {
      return;
    }
    if (moduleId == null || activityId == null) {
      return;
    }

    final EcoUnityLearningProvider provider =
        Provider.of<EcoUnityLearningProvider>(context, listen: false);

    await provider.markActivityCompleted(
      moduleId: moduleId,
      activityId: activityId,
      language: language,
      payload: <String, dynamic>{'activity_type': 'comic'},
    );
    if (!mounted) {
      return;
    }
    final EcoUnityAnalyticsService? analytics = _analyticsOf(context);
    if (analytics != null) {
      final int? durationSeconds = _activityDurationSeconds(activity, language);
      unawaited(
        analytics.trackActivityCompleted(
          activity,
          language: language,
          eventData: durationSeconds == null
              ? const <String, Object?>{}
              : <String, Object?>{'duration_seconds': durationSeconds},
        ),
      );
    }
    _trackModuleCompletedIfReady(provider, moduleId, language);
  }

  void _trackActivityStarted(
    EcoUnityLearningActivity activity,
    String language,
  ) {
    if (_teacherModeEnabled()) {
      return;
    }
    final int? activityId = activity.id;
    if (activityId == null) {
      return;
    }
    final String key = _activityAnalyticsKey(activity, language);
    if (!_trackedActivityStartKeys.add(key)) {
      return;
    }
    _activityStartedAtByKey[key] = DateTime.now().toUtc();
    final EcoUnityAnalyticsService? analytics = _analyticsOf(context);
    if (analytics == null) {
      return;
    }
    unawaited(analytics.trackActivityStarted(activity, language: language));
  }

  void _trackComicSceneViewed(
    EcoUnityLearningActivity activity,
    String language,
    EcoUnityComicScene scene,
  ) {
    if (_teacherModeEnabled()) {
      return;
    }
    final EcoUnityAnalyticsService? analytics = _analyticsOf(context);
    if (analytics == null) {
      return;
    }
    unawaited(
      analytics.trackComicSceneViewed(activity, scene, language: language),
    );
  }

  void _trackComicDecisionSelected(
    EcoUnityLearningActivity activity,
    String language,
    EcoUnityComicScene scene,
    EcoUnityComicDecision decision,
  ) {
    if (_teacherModeEnabled()) {
      return;
    }
    final EcoUnityAnalyticsService? analytics = _analyticsOf(context);
    if (analytics == null) {
      return;
    }
    unawaited(
      analytics.trackComicDecisionSelected(
        activity,
        scene,
        decision,
        language: language,
      ),
    );
  }

  void _trackModuleCompletedIfReady(
    EcoUnityLearningProvider provider,
    int moduleId,
    String language,
  ) {
    if (_teacherModeEnabled()) {
      return;
    }
    final EcoUnitySdgModule? module = provider.moduleById(moduleId);
    if (module == null ||
        module.completionRatio(provider.progressEntries) < 1) {
      return;
    }
    final String key = '$moduleId:$language';
    if (!_trackedModuleCompletionKeys.add(key)) {
      return;
    }
    final EcoUnityAnalyticsService? analytics = _analyticsOf(context);
    if (analytics == null) {
      return;
    }
    unawaited(analytics.trackModuleCompleted(module, language: language));
  }

  int? _activityDurationSeconds(
    EcoUnityLearningActivity activity,
    String language,
  ) {
    final DateTime? startedAt =
        _activityStartedAtByKey[_activityAnalyticsKey(activity, language)];
    if (startedAt == null) {
      return null;
    }
    return DateTime.now()
        .toUtc()
        .difference(startedAt)
        .inSeconds
        .clamp(0, 86400)
        .toInt();
  }

  bool _teacherModeEnabled() {
    try {
      return Provider.of<TeacherModeProvider>(
        context,
        listen: false,
      ).isTeacherMode;
    } catch (_) {
      return false;
    }
  }
}

EcoUnityAnalyticsService? _analyticsOf(BuildContext context) {
  try {
    return Provider.of<EcoUnityAnalyticsService>(context, listen: false);
  } catch (_) {
    return null;
  }
}

String _activityAnalyticsKey(
  EcoUnityLearningActivity activity,
  String language,
) {
  return '${activity.id ?? activity.slug}:$language';
}

bool _needsAdditionalComicScenes(EcoUnityLearningActivity activity) {
  final EcoUnityComic comic = EcoUnityComic(
    activity: activity,
    scenes: activity.comicScenes,
    rawData: activity.rawData,
  );
  for (final EcoUnityComicScene scene in activity.comicScenes) {
    for (final EcoUnityComicDecision decision in scene.decisions) {
      if (comic.sceneForDecision(decision) == null) {
        return true;
      }
    }
  }
  return false;
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
