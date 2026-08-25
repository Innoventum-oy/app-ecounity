import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/analytics/ecounity_analytics_service.dart';
import 'package:ecounity/src/learning/ecounity_comic_speech_audio_controller.dart';
import 'package:ecounity/src/learning/ecounity_content_review_service.dart';
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_provider.dart';
import 'package:ecounity/src/learning/ecounity_learning_text_utils.dart';
import 'package:ecounity/src/learning/widgets/ecounity_activity_hero_image.dart';
import 'package:ecounity/src/learning/widgets/ecounity_content_review_panel.dart';
import 'package:ecounity/src/learning/widgets/ecounity_learning_copy.dart';
import 'package:ecounity/src/learning/widgets/ecounity_comic_player.dart';
import 'package:ecounity/src/learning/widgets/ecounity_teacher_objective_card.dart';
import 'package:ecounity/src/providers/teacher_mode_provider.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EcoUnityLearningActivityScreen extends StatefulWidget {
  const EcoUnityLearningActivityScreen({
    super.key,
    required this.navIndex,
    this.activity,
    this.activityId,
  });

  final int navIndex;
  final EcoUnityLearningActivity? activity;
  final int? activityId;

  @override
  State<EcoUnityLearningActivityScreen> createState() =>
      _EcoUnityLearningActivityScreenState();
}

class _EcoUnityLearningActivityScreenState
    extends State<EcoUnityLearningActivityScreen> {
  late final EcoUnityComicSpeechAudioController _speechAudioController;
  Future<_ActivityScreenData>? _future;
  _ActivityScreenData? _latestData;
  final Set<String> _trackedActivityStartKeys = <String>{};
  final Set<String> _trackedModuleCompletionKeys = <String>{};
  final Set<String> _shownCompletionDialogKeys = <String>{};
  final Map<String, DateTime> _activityStartedAtByKey = <String, DateTime>{};

  @override
  void initState() {
    super.initState();
    _speechAudioController = EcoUnityComicSpeechAudioController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _loadActivityData();
  }

  @override
  void dispose() {
    unawaited(_speechAudioController.dispose());
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EcoUnityLearningActivityScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activity != widget.activity ||
        oldWidget.activityId != widget.activityId) {
      _latestData = null;
      _future = _loadActivityData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ActivityScreenData>(
      future: _future,
      initialData: _latestData,
      builder:
          (BuildContext context, AsyncSnapshot<_ActivityScreenData> snapshot) {
            final _ActivityScreenData? data = snapshot.data ?? _latestData;
            final EcoUnityLearningActivity? activity = data?.activity;
            return ScreenScaffold(
              title: activity?.title ?? 'Activity',
              navigationIndex: widget.navIndex,
              fullWidth: activity?.isComic ?? false,
              child: _buildBody(context, snapshot),
            );
          },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<_ActivityScreenData> snapshot,
  ) {
    final _ActivityScreenData? data = snapshot.data ?? _latestData;
    if (snapshot.connectionState != ConnectionState.done && data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError && data == null) {
      return Center(child: Text('Unable to load activity: ${snapshot.error}'));
    }

    final EcoUnityLearningActivity? activity = data?.activity;
    if (data == null || activity == null) {
      return const Center(child: Text('Activity not found'));
    }
    final bool teacherModeEnabled = Provider.of<TeacherModeProvider>(
      context,
    ).isTeacherMode;
    final bool alreadyCompleted =
        !teacherModeEnabled &&
        _isActivityCompleted(
          context.watch<EcoUnityLearningProvider>().progressEntries,
          activity,
          data.language,
        );

    final Widget content = switch (activity.type) {
      EcoUnityActivityType.comic => _buildComic(
        activity,
        data.language,
        loadingAdditionalScenes: data.loadingAdditionalScenes,
        teacherModeEnabled: teacherModeEnabled,
      ),
      EcoUnityActivityType.quiz => _QuizActivityView(
        activity: activity,
        teacherModeEnabled: teacherModeEnabled,
        reviewPanel: _reviewPanel(activity, data.language),
        onQuizSubmitted: (EcoUnityQuizResult result, int attemptNumber) =>
            _trackQuizCompleted(activity, data.language, result, attemptNumber),
        onCompleted: (Map<String, dynamic> payload) {
          return _markCompleted(activity, data.language, payload: payload);
        },
      ),
      EcoUnityActivityType.reflection => _ReflectionActivityView(
        activity: activity,
        teacherModeEnabled: teacherModeEnabled,
        reviewPanel: _reviewPanel(activity, data.language),
        submitLabel: 'Submit reflection',
        onCompleted: (Map<String, dynamic> payload) {
          return _markCompleted(activity, data.language, payload: payload);
        },
      ),
      EcoUnityActivityType.challenge => _ReflectionActivityView(
        activity: activity,
        teacherModeEnabled: teacherModeEnabled,
        reviewPanel: _reviewPanel(activity, data.language),
        submitLabel: 'Complete challenge',
        onCompleted: (Map<String, dynamic> payload) {
          return _markCompleted(activity, data.language, payload: payload);
        },
      ),
      _ => _ReadableActivityView(
        activity: activity,
        alreadyCompleted: alreadyCompleted,
        teacherModeEnabled: teacherModeEnabled,
        reviewPanel: _reviewPanel(activity, data.language),
        onCompleted: () {
          return _markCompleted(activity, data.language);
        },
      ),
    };

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double height = activity.isComic && constraints.hasBoundedHeight
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height * 0.78;
        return SizedBox(width: double.infinity, height: height, child: content);
      },
    );
  }

  Widget _buildComic(
    EcoUnityLearningActivity activity,
    String language, {
    required bool loadingAdditionalScenes,
    required bool teacherModeEnabled,
  }) {
    if (activity.comicScenes.isEmpty) {
      return Column(
        children: <Widget>[
          if (activity.heroImage != null) ...<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: EcoUnityActivityHeroImage(
                activity: activity,
                maxHeight: 220,
              ),
            ),
            const SizedBox(height: 12),
          ],
          _reviewPanel(activity, language),
          if (teacherModeEnabled && activity.learningObjective.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: EcoUnityTeacherObjectiveCard(
                learningObjective: activity.learningObjective,
              ),
            ),
          const Expanded(
            child: Center(child: Text('No comic scenes available')),
          ),
        ],
      );
    }

    return Column(
      children: <Widget>[
        if (activity.heroImage != null) ...<Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: EcoUnityActivityHeroImage(
              activity: activity,
              maxHeight: 220,
            ),
          ),
          const SizedBox(height: 12),
        ],
        _reviewPanel(activity, language),
        if (teacherModeEnabled && activity.learningObjective.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: EcoUnityTeacherObjectiveCard(
              learningObjective: activity.learningObjective,
            ),
          ),
        Expanded(
          child: EcoUnityComicPlayer(
            comic: EcoUnityComic(
              activity: activity,
              scenes: activity.comicScenes,
              rawData: activity.rawData,
            ),
            language: language,
            loadingAdditionalScenes: loadingAdditionalScenes,
            onCompleted: () => _markCompleted(
              activity,
              language,
              payload: const <String, dynamic>{'activity_type': 'comic'},
            ),
            onSceneViewed: (EcoUnityComicScene scene) {
              _trackComicSceneViewed(activity, language, scene);
            },
            onDecisionSelected:
                (EcoUnityComicScene scene, EcoUnityComicDecision decision) {
                  _trackComicDecisionSelected(
                    activity,
                    language,
                    scene,
                    decision,
                  );
                },
            onPrepareSpeech: _speechAudioController.prepareCues,
            onSpeechCueChanged: (EcoUnityComicSpeechItem? speech) {
              unawaited(_speechAudioController.playCue(speech));
            },
          ),
        ),
      ],
    );
  }

  Widget _reviewPanel(EcoUnityLearningActivity activity, String language) {
    final int? activityId = activity.id;
    if (activityId == null) {
      return const SizedBox.shrink();
    }
    return EcoUnityContentReviewPanel(
      scope: EcoUnityReviewScope.activity,
      objectId: activityId,
      language: language,
      fallbackStatus: activity.contentStatus,
    );
  }

  Future<_ActivityScreenData> _loadActivityData() async {
    final EcoUnityLearningProvider provider =
        Provider.of<EcoUnityLearningProvider>(context, listen: false);
    final bool teacherModeEnabled = Provider.of<TeacherModeProvider>(
      context,
      listen: false,
    ).isTeacherMode;
    final String language = await core.Settings().getLanguage() ?? 'en';
    final int? activityId = widget.activityId ?? widget.activity?.id;

    EcoUnityLearningActivity? activity = widget.activity;
    if (activityId != null) {
      final EcoUnityLearningActivity? cachedFullActivity = provider
          .cachedActivity(activityId, language: language);
      if (cachedFullActivity != null && cachedFullActivity.isComic) {
        if (!teacherModeEnabled) {
          await provider.loadProgress(language: language);
        }
        return _rememberData(
          _ActivityScreenData(
            activity: cachedFullActivity,
            language: language,
            loadingAdditionalScenes: false,
          ),
        );
      }

      activity =
          await provider.loadActivity(
            activityId,
            language: language,
            comicSceneLimit: 1,
          ) ??
          widget.activity;
      if (activity != null && activity.isComic) {
        if (!teacherModeEnabled) {
          await provider.loadProgress(language: language);
        }
        final bool loadingAdditionalScenes = _needsAdditionalComicScenes(
          activity,
        );
        if (loadingAdditionalScenes) {
          _loadRemainingComicScenes(activityId, language, activity);
        }
        return _rememberData(
          _ActivityScreenData(
            activity: activity,
            language: language,
            loadingAdditionalScenes: loadingAdditionalScenes,
          ),
        );
      }
    }

    if (activity != null && !teacherModeEnabled) {
      await provider.loadProgress(language: language);
    }

    return _rememberData(
      _ActivityScreenData(
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
        final _ActivityScreenData data = _ActivityScreenData(
          activity: fullActivity,
          language: language,
          loadingAdditionalScenes: false,
        );
        setState(() {
          _latestData = data;
          _future = Future<_ActivityScreenData>.value(data);
        });
      } catch (_) {
        if (!mounted) {
          return;
        }
        final _ActivityScreenData data = _ActivityScreenData(
          activity: initialActivity,
          language: language,
          loadingAdditionalScenes: false,
        );
        setState(() {
          _latestData = data;
          _future = Future<_ActivityScreenData>.value(data);
        });
      }
    }());
  }

  _ActivityScreenData _rememberData(_ActivityScreenData data) {
    _latestData = data;
    final EcoUnityLearningActivity? activity = data.activity;
    if (activity != null) {
      _trackActivityStarted(activity, data.language);
    }
    return data;
  }

  Future<void> _markCompleted(
    EcoUnityLearningActivity activity,
    String language, {
    Map<String, dynamic> payload = const <String, dynamic>{},
  }) async {
    final int? moduleId = activity.moduleId;
    final int? activityId = activity.id;
    final bool teacherModeEnabled = Provider.of<TeacherModeProvider>(
      context,
      listen: false,
    ).isTeacherMode;

    if (!teacherModeEnabled) {
      if (moduleId == null || activityId == null) {
        return;
      }

      final EcoUnityLearningProvider provider =
          Provider.of<EcoUnityLearningProvider>(context, listen: false);

      await provider.markActivityCompleted(
        moduleId: moduleId,
        activityId: activityId,
        language: language,
        payload: <String, dynamic>{
          'activity_type': _activityTypeLabel(activity.type).toLowerCase(),
          ...payload,
        },
      );

      if (!mounted) {
        return;
      }
      final EcoUnityAnalyticsService? analytics = _analyticsOf(context);
      if (analytics != null) {
        unawaited(
          analytics.trackActivityCompleted(
            activity,
            language: language,
            eventData: _completionAnalyticsData(
              activity,
              language,
              payload: payload,
            ),
          ),
        );
      }
      _trackModuleCompletedIfReady(provider, moduleId, language);
    }

    final bool showedCompletionDialog = await _showCompletionDialogIfNeeded(
      activity,
      language,
    );
    if (!mounted) {
      return;
    }
    if (showedCompletionDialog || activity.completionText.trim().isEmpty) {
      await Navigator.of(context).maybePop();
    }
  }

  Future<bool> _showCompletionDialogIfNeeded(
    EcoUnityLearningActivity activity,
    String language,
  ) async {
    final String completionText = activity.completionText.trim();
    if (completionText.isEmpty) {
      return false;
    }
    final String key = _activityAnalyticsKey(activity, language);
    if (!_shownCompletionDialogKeys.add(key) || !mounted) {
      return false;
    }

    final bool? shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.pathway_completed),
          content: EcoUnityLearningCopy(text: completionText),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10n.button_continue),
            ),
          ],
        );
      },
    );
    return shouldContinue ?? false;
  }

  void _trackActivityStarted(
    EcoUnityLearningActivity activity,
    String language,
  ) {
    final int? activityId = activity.id;
    if (_teacherModeEnabled()) {
      return;
    }
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

  Future<void> _trackQuizCompleted(
    EcoUnityLearningActivity activity,
    String language,
    EcoUnityQuizResult result,
    int attemptNumber,
  ) {
    if (_teacherModeEnabled()) {
      return Future<void>.value();
    }
    final EcoUnityAnalyticsService? analytics = _analyticsOf(context);
    if (analytics == null) {
      return Future<void>.value();
    }
    return analytics.trackQuizCompleted(
      activity,
      result,
      attemptNumber: attemptNumber,
      language: language,
    );
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

  Map<String, Object?> _completionAnalyticsData(
    EcoUnityLearningActivity activity,
    String language, {
    required Map<String, dynamic> payload,
  }) {
    final Map<String, Object?> eventData = <String, Object?>{};
    final int? durationSeconds = _activityDurationSeconds(activity, language);
    if (durationSeconds != null) {
      eventData['duration_seconds'] = durationSeconds;
    }

    if (payload['score'] != null) {
      eventData['score'] = payload['score'];
    }
    if (payload['max_score'] != null) {
      eventData['max_score'] = payload['max_score'];
    } else if (payload['possible_score'] != null) {
      eventData['max_score'] = payload['possible_score'];
    }
    if (payload['correct_count'] != null) {
      eventData['correct_count'] = payload['correct_count'];
    } else if (payload['correct_questions'] != null) {
      eventData['correct_count'] = payload['correct_questions'];
    }
    if (payload['question_count'] != null) {
      eventData['question_count'] = payload['question_count'];
    }
    if (payload['passed'] != null) {
      eventData['passed'] = payload['passed'];
    }
    if (payload['attempt_number'] != null) {
      eventData['attempt_number'] = payload['attempt_number'];
    }

    return eventData;
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

bool _isActivityCompleted(
  List<EcoUnityProgressEntry> progressEntries,
  EcoUnityLearningActivity activity,
  String language,
) {
  final int? activityId = activity.id;
  if (activityId == null) {
    return false;
  }
  final String normalizedLanguage = _normalizeLanguage(language);
  return progressEntries.any((EcoUnityProgressEntry entry) {
    return entry.activityId == activityId &&
        _normalizeLanguage(entry.language) == normalizedLanguage &&
        entry.status == EcoUnityProgressStatus.completed;
  });
}

String _normalizeLanguage(String language) {
  final String normalized = language.trim().toLowerCase();
  return normalized.isEmpty ? 'en' : normalized;
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

class _ReadableActivityView extends StatefulWidget {
  const _ReadableActivityView({
    required this.activity,
    required this.alreadyCompleted,
    required this.teacherModeEnabled,
    required this.reviewPanel,
    required this.onCompleted,
  });

  final EcoUnityLearningActivity activity;
  final bool alreadyCompleted;
  final bool teacherModeEnabled;
  final Widget reviewPanel;
  final Future<void> Function() onCompleted;

  @override
  State<_ReadableActivityView> createState() => _ReadableActivityViewState();
}

class _ReadableActivityViewState extends State<_ReadableActivityView> {
  bool _completed = false;
  bool _submitting = false;

  @override
  void didUpdateWidget(covariant _ReadableActivityView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activity.id != widget.activity.id) {
      _completed = false;
      _submitting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool completed = widget.alreadyCompleted || _completed;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        EcoUnityActivityHeroImage(activity: widget.activity),
        if (widget.activity.heroImage != null) const SizedBox(height: 16),
        _ActivityIntro(
          activity: widget.activity,
          teacherModeEnabled: widget.teacherModeEnabled,
        ),
        widget.reviewPanel,
        if (widget.activity.body.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          EcoUnityLearningCopy(
            text: ecoUnityReplaceMediaImageTokens(
              widget.activity.body,
              widget.activity.mediaImages,
            ),
          ),
        ],
        if (widget.activity.keyMessage.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          _MessagePanel(text: widget.activity.keyMessage),
        ],
        if (widget.activity.reflectionPrompt.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          _ReflectionPromptPanel(prompt: widget.activity.reflectionPrompt),
        ],
        const SizedBox(height: 20),
        if (completed)
          _ActivityCompletionPanel(activity: widget.activity)
        else
          FilledButton.icon(
            onPressed: _submitting ? null : _complete,
            icon: _submitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(context.l10n.markAsCompleted),
          ),
      ],
    );
  }

  Future<void> _complete() async {
    setState(() {
      _submitting = true;
    });
    try {
      await widget.onCompleted();
      if (!mounted) {
        return;
      }
      setState(() {
        _completed = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

class _QuizActivityView extends StatefulWidget {
  const _QuizActivityView({
    required this.activity,
    required this.teacherModeEnabled,
    required this.reviewPanel,
    required this.onQuizSubmitted,
    required this.onCompleted,
  });

  final EcoUnityLearningActivity activity;
  final bool teacherModeEnabled;
  final Widget reviewPanel;
  final Future<void> Function(EcoUnityQuizResult result, int attemptNumber)
  onQuizSubmitted;
  final Future<void> Function(Map<String, dynamic> payload) onCompleted;

  @override
  State<_QuizActivityView> createState() => _QuizActivityViewState();
}

class _QuizActivityViewState extends State<_QuizActivityView> {
  final Map<int, Set<String>> _selectedAnswers = <int, Set<String>>{};
  late PageController _pageController;
  EcoUnityQuizResult? _result;
  bool _completed = false;
  bool _submitting = false;
  int _currentQuestionIndex = 0;
  int _attemptNumber = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant _QuizActivityView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activity.id != widget.activity.id ||
        oldWidget.activity.questions.length !=
            widget.activity.questions.length) {
      _selectedAnswers.clear();
      _result = null;
      _completed = false;
      _submitting = false;
      _currentQuestionIndex = 0;
      _attemptNumber = 0;
      _pageController.dispose();
      _pageController = PageController();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<EcoUnityQuizQuestion> questions = widget.activity.questions;
    if (questions.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          EcoUnityActivityHeroImage(activity: widget.activity),
          if (widget.activity.heroImage != null) const SizedBox(height: 16),
          _QuizActivityHeader(
            activity: widget.activity,
            teacherModeEnabled: widget.teacherModeEnabled,
          ),
          widget.reviewPanel,
          const SizedBox(height: 16),
          const _InlineActivityMessage(
            icon: Icons.quiz_outlined,
            title: 'No questions available',
            message: 'This quiz does not currently include any questions.',
          ),
        ],
      );
    }

    final int safeQuestionIndex = _currentQuestionIndex
        .clamp(0, questions.length - 1)
        .toInt();
    final EcoUnityQuizQuestion currentQuestion = questions[safeQuestionIndex];
    final bool isLastQuestion = _currentQuestionIndex >= questions.length - 1;
    final double answeredRatio = questions.isEmpty
        ? 0
        : (_currentQuestionIndex + 1) / questions.length;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height * 0.78;
        final double questionHeight = (availableHeight - 190)
            .clamp(390.0, 640.0)
            .toDouble();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            EcoUnityActivityHeroImage(activity: widget.activity),
            if (widget.activity.heroImage != null) const SizedBox(height: 16),
            _QuizActivityHeader(
              activity: widget.activity,
              teacherModeEnabled: widget.teacherModeEnabled,
            ),
            widget.reviewPanel,
            const SizedBox(height: 12),
            _QuizProgressHeader(
              currentIndex: _currentQuestionIndex,
              questionCount: questions.length,
              progressValue: answeredRatio,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: questionHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: questions.length,
                onPageChanged: (int index) {
                  setState(() {
                    _currentQuestionIndex = index;
                    _result = null;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  final EcoUnityQuizQuestion question = questions[index];
                  return _QuizQuestionPage(
                    question: question,
                    selectedAnswers:
                        _selectedAnswers[_questionKey(question)] ?? <String>{},
                    onChanged: (Set<String> answers) {
                      _updateAnswer(question, answers);
                    },
                    onSingleChoiceSelected: (String optionId) {
                      _selectSingleChoice(question, optionId);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            if (_result != null) ...<Widget>[
              _QuizResultPanel(result: _result!),
              const SizedBox(height: 12),
            ],
            _QuizPageControls(
              canGoPrevious: _currentQuestionIndex > 0,
              canGoNext: !isLastQuestion,
              isLastQuestion: isLastQuestion,
              submitting: _submitting,
              completed: _completed,
              currentQuestionRequiresAnswer: currentQuestion.required,
              currentQuestionAnswered: _hasAnswer(currentQuestion),
              onPrevious: _previousQuestion,
              onNext: _nextQuestion,
              onSubmit: _submit,
            ),
          ],
        );
      },
    );
  }

  void _updateAnswer(EcoUnityQuizQuestion question, Set<String> answers) {
    setState(() {
      _selectedAnswers[_questionKey(question)] = answers;
      _result = null;
    });
  }

  void _selectSingleChoice(EcoUnityQuizQuestion question, String optionId) {
    final bool wasUnanswered = !_hasAnswer(question);
    _updateAnswer(question, <String>{optionId});
    if (wasUnanswered &&
        _currentQuestionIndex < widget.activity.questions.length - 1) {
      _advanceAfterSingleChoice(question);
    }
  }

  Future<void> _advanceAfterSingleChoice(
    EcoUnityQuizQuestion selectedQuestion,
  ) async {
    final int selectedQuestionIndex = _currentQuestionIndex;
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted ||
        selectedQuestionIndex != _currentQuestionIndex ||
        !_pageController.hasClients ||
        !_hasAnswer(selectedQuestion)) {
      return;
    }
    _nextQuestion();
  }

  bool _hasAnswer(EcoUnityQuizQuestion question) {
    return (_selectedAnswers[_questionKey(question)] ?? <String>{}).isNotEmpty;
  }

  void _previousQuestion() {
    if (_currentQuestionIndex <= 0 || !_pageController.hasClients) {
      return;
    }
    _pageController.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _nextQuestion() {
    if (_currentQuestionIndex >= widget.activity.questions.length - 1 ||
        !_pageController.hasClients) {
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _submit() async {
    if (_submitting || _completed) {
      return;
    }
    setState(() {
      _submitting = true;
    });

    final EcoUnityQuizResult result = widget.activity.evaluateQuizAnswers(
      _selectedAnswers,
    );
    _attemptNumber += 1;
    setState(() {
      _result = result;
    });

    try {
      if (!widget.teacherModeEnabled) {
        await widget.onQuizSubmitted(result, _attemptNumber);
      }

      if (result.passed) {
        await widget.onCompleted(<String, dynamic>{
          'score': result.score,
          'possible_score': result.possibleScore,
          'correct_questions': result.correctQuestionCount,
          'question_count': result.questionCount,
          'passed': result.passed,
          'attempt_number': _attemptNumber,
        });
        if (!mounted) {
          return;
        }
        setState(() {
          _completed = true;
        });
      } else {
        _moveToFirstRequiredUnansweredQuestion();
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _moveToFirstRequiredUnansweredQuestion() {
    final List<EcoUnityQuizQuestion> questions = widget.activity.questions;
    for (int index = 0; index < questions.length; index += 1) {
      final EcoUnityQuizQuestion question = questions[index];
      if (question.required && !_hasAnswer(question)) {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          );
        }
        return;
      }
    }
  }
}

class _QuizActivityHeader extends StatelessWidget {
  const _QuizActivityHeader({
    required this.activity,
    required this.teacherModeEnabled,
  });

  final EcoUnityLearningActivity activity;
  final bool teacherModeEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: EcoUnityColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: EcoUnityColors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAFBFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.quiz_outlined,
                    color: EcoUnityColors.deepTeal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        activity.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: EcoUnityColors.deepTeal,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      if (activity.shortDescription
                          .trim()
                          .isNotEmpty) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(
                          activity.shortDescription.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: EcoUnityColors.textSecondary,
                                height: 1.25,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (teacherModeEnabled && activity.learningObjective.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: EcoUnityTeacherObjectiveCard(
              learningObjective: activity.learningObjective,
            ),
          ),
      ],
    );
  }
}

class _QuizProgressHeader extends StatelessWidget {
  const _QuizProgressHeader({
    required this.currentIndex,
    required this.questionCount,
    required this.progressValue,
  });

  final int currentIndex;
  final int questionCount;
  final double progressValue;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Question ${currentIndex + 1} of $questionCount',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: EcoUnityColors.deepTeal,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: progressValue.clamp(0, 1).toDouble(),
                color: EcoUnityColors.turquoise,
                backgroundColor: EcoUnityColors.surfaceContainerHigh,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizQuestionPage extends StatelessWidget {
  const _QuizQuestionPage({
    required this.question,
    required this.selectedAnswers,
    required this.onChanged,
    required this.onSingleChoiceSelected,
  });

  final EcoUnityQuizQuestion question;
  final Set<String> selectedAnswers;
  final ValueChanged<Set<String>> onChanged;
  final ValueChanged<String> onSingleChoiceSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: EcoUnityColors.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                question.prompt,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: EcoUnityColors.deepTeal,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              if (question.options.isEmpty)
                const _InlineActivityMessage(
                  icon: Icons.rule_outlined,
                  title: 'No answer options',
                  message:
                      'This question does not currently include answer options.',
                )
              else
                for (final EcoUnityQuizOption option
                    in question.options) ...<Widget>[
                  _QuizOptionCard(
                    option: option,
                    multipleChoice: question.allowsMultipleAnswers,
                    selected: selectedAnswers.contains(option.id),
                    onTap: () {
                      if (question.allowsMultipleAnswers) {
                        final Set<String> nextAnswers = <String>{
                          ...selectedAnswers,
                        };
                        if (nextAnswers.contains(option.id)) {
                          nextAnswers.remove(option.id);
                        } else {
                          nextAnswers.add(option.id);
                        }
                        onChanged(nextAnswers);
                      } else {
                        onSingleChoiceSelected(option.id);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizOptionCard extends StatelessWidget {
  const _QuizOptionCard({
    required this.option,
    required this.multipleChoice,
    required this.selected,
    required this.onTap,
  });

  final EcoUnityQuizOption option;
  final bool multipleChoice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected
        ? EcoUnityColors.turquoise
        : EcoUnityColors.outlineVariant;
    final Color backgroundColor = selected
        ? const Color(0xFFEAFBFB)
        : EcoUnityColors.surface;
    final IconData icon = multipleChoice
        ? selected
              ? Icons.check_box_rounded
              : Icons.check_box_outline_blank_rounded
        : selected
        ? Icons.radio_button_checked_rounded
        : Icons.radio_button_unchecked_rounded;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: <Widget>[
                Icon(
                  icon,
                  color: selected
                      ? EcoUnityColors.deepTeal
                      : EcoUnityColors.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option.label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: EcoUnityColors.textPrimary,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
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

class _QuizPageControls extends StatelessWidget {
  const _QuizPageControls({
    required this.canGoPrevious,
    required this.canGoNext,
    required this.isLastQuestion,
    required this.submitting,
    required this.completed,
    required this.currentQuestionRequiresAnswer,
    required this.currentQuestionAnswered,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  final bool canGoPrevious;
  final bool canGoNext;
  final bool isLastQuestion;
  final bool submitting;
  final bool completed;
  final bool currentQuestionRequiresAnswer;
  final bool currentQuestionAnswered;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final bool canLeaveCurrentQuestion =
        !currentQuestionRequiresAnswer || currentQuestionAnswered;

    return Row(
      children: <Widget>[
        IconButton.filledTonal(
          onPressed: canGoPrevious ? onPrevious : null,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Previous',
        ),
        const SizedBox(width: 12),
        Expanded(
          child: isLastQuestion
              ? FilledButton.icon(
                  onPressed: completed || submitting ? null : onSubmit,
                  icon: submitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          completed
                              ? Icons.check_circle_rounded
                              : Icons.check_rounded,
                        ),
                  label: Text(completed ? 'Completed' : 'Submit answers'),
                )
              : FilledButton.icon(
                  onPressed: canGoNext && canLeaveCurrentQuestion
                      ? onNext
                      : null,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Next'),
                ),
        ),
      ],
    );
  }
}

class _ReflectionActivityView extends StatefulWidget {
  const _ReflectionActivityView({
    required this.activity,
    required this.teacherModeEnabled,
    required this.reviewPanel,
    required this.submitLabel,
    required this.onCompleted,
  });

  final EcoUnityLearningActivity activity;
  final bool teacherModeEnabled;
  final Widget reviewPanel;
  final String submitLabel;
  final Future<void> Function(Map<String, dynamic> payload) onCompleted;

  @override
  State<_ReflectionActivityView> createState() =>
      _ReflectionActivityViewState();
}

class _ReflectionActivityViewState extends State<_ReflectionActivityView> {
  final TextEditingController _controller = TextEditingController();
  bool _submitted = false;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        EcoUnityActivityHeroImage(activity: widget.activity),
        if (widget.activity.heroImage != null) const SizedBox(height: 16),
        _ActivityIntro(
          activity: widget.activity,
          teacherModeEnabled: widget.teacherModeEnabled,
        ),
        widget.reviewPanel,
        if (widget.activity.body.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          EcoUnityLearningCopy(
            text: ecoUnityReplaceMediaImageTokens(
              widget.activity.body,
              widget.activity.mediaImages,
            ),
          ),
        ],
        if (widget.activity.reflectionPrompt.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          _ReflectionPromptPanel(
            prompt: widget.activity.reflectionPrompt,
            input: TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                hintText: 'Write your response',
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _submitted || _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(_submitted ? Icons.check_circle : Icons.check),
          label: Text(_submitted ? 'Completed' : widget.submitLabel),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
    });
    try {
      await widget.onCompleted(<String, dynamic>{
        'reflection': _controller.text.trim(),
      });
      if (!mounted) {
        return;
      }
      setState(() {
        _submitted = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

class _InlineActivityMessage extends StatelessWidget {
  const _InlineActivityMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EcoUnityColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: EcoUnityColors.deepTeal, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: EcoUnityColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: EcoUnityColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCompletionPanel extends StatelessWidget {
  const _ActivityCompletionPanel({required this.activity});

  final EcoUnityLearningActivity activity;

  @override
  Widget build(BuildContext context) {
    final String completionText = activity.completionText.trim();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE7F8DF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: EcoUnityColors.success.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: EcoUnityColors.success,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.completed,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: EcoUnityColors.success,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (completionText.isEmpty)
              Text(
                context.l10n.pathway_already_completed,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: EcoUnityColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              EcoUnityLearningCopy(
                text: completionText,
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

class _ActivityIntro extends StatelessWidget {
  const _ActivityIntro({
    required this.activity,
    required this.teacherModeEnabled,
  });

  final EcoUnityLearningActivity activity;
  final bool teacherModeEnabled;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EcoUnityColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EcoUnityColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Chip(label: Text(_activityTypeLabel(activity.type))),
            if (activity.shortDescription.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              EcoUnityLearningCopy(
                text: activity.shortDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (teacherModeEnabled &&
                activity.learningObjective.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              EcoUnityTeacherObjectiveCard(
                learningObjective: activity.learningObjective,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReflectionPromptPanel extends StatelessWidget {
  const _ReflectionPromptPanel({required this.prompt, this.input});

  final String prompt;
  final Widget? input;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEAFBFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EcoUnityColors.turquoise),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.lightbulb_outline,
                  color: EcoUnityColors.deepTeal,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Think about it',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: EcoUnityColors.deepTeal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            EcoUnityLearningCopy(
              text: prompt,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: EcoUnityColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (input != null) ...<Widget>[const SizedBox(height: 12), input!],
          ],
        ),
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({required this.text});

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
        padding: const EdgeInsets.all(14),
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

class _QuizResultPanel extends StatelessWidget {
  const _QuizResultPanel({required this.result});

  final EcoUnityQuizResult result;

  @override
  Widget build(BuildContext context) {
    final Color color = result.passed
        ? EcoUnityColors.success
        : EcoUnityColors.error;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: result.passed
            ? const Color(0xFFE7F8DF)
            : const Color(0xFFFFEDEA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          result.passed
              ? 'Passed: ${result.score}/${result.possibleScore}'
              : 'Try again: ${result.score}/${result.possibleScore}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ActivityScreenData {
  const _ActivityScreenData({
    required this.activity,
    required this.language,
    required this.loadingAdditionalScenes,
  });

  final EcoUnityLearningActivity? activity;
  final String language;
  final bool loadingAdditionalScenes;
}

int _questionKey(EcoUnityQuizQuestion question) {
  return question.id ?? question.orderNo;
}

String _activityTypeLabel(EcoUnityActivityType type) {
  return switch (type) {
    EcoUnityActivityType.comic => 'Comic',
    EcoUnityActivityType.mlr => 'Micro-learning',
    EcoUnityActivityType.quiz => 'Quiz',
    EcoUnityActivityType.reflection => 'Reflection',
    EcoUnityActivityType.challenge => 'Challenge',
    EcoUnityActivityType.unknown => 'Activity',
  };
}
