import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:ecounity/src/analytics/ecounity_analytics_service.dart';
import 'package:ecounity/src/learning/ecounity_comic_speech_audio_controller.dart';
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_provider.dart';
import 'package:ecounity/src/learning/ecounity_learning_text_utils.dart';
import 'package:ecounity/src/learning/widgets/ecounity_content_review_panel.dart';
import 'package:ecounity/src/learning/widgets/ecounity_learning_copy.dart';
import 'package:ecounity/src/learning/widgets/ecounity_comic_player.dart';
import 'package:ecounity/src/learning/widgets/ecounity_media_image.dart';
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

    final Widget content = switch (activity.type) {
      EcoUnityActivityType.comic => _buildComic(
        activity,
        data.language,
        loadingAdditionalScenes: data.loadingAdditionalScenes,
      ),
      EcoUnityActivityType.quiz => _QuizActivityView(
        activity: activity,
        reviewPanel: _reviewPanel(activity, data.language),
        onQuizSubmitted: (EcoUnityQuizResult result, int attemptNumber) =>
            _trackQuizCompleted(activity, data.language, result, attemptNumber),
        onCompleted: (Map<String, dynamic> payload) {
          return _markCompleted(activity, data.language, payload: payload);
        },
      ),
      EcoUnityActivityType.reflection => _ReflectionActivityView(
        activity: activity,
        reviewPanel: _reviewPanel(activity, data.language),
        submitLabel: 'Submit reflection',
        onCompleted: (Map<String, dynamic> payload) {
          return _markCompleted(activity, data.language, payload: payload);
        },
      ),
      EcoUnityActivityType.challenge => _ReflectionActivityView(
        activity: activity,
        reviewPanel: _reviewPanel(activity, data.language),
        submitLabel: 'Complete challenge',
        onCompleted: (Map<String, dynamic> payload) {
          return _markCompleted(activity, data.language, payload: payload);
        },
      ),
      _ => _ReadableActivityView(
        activity: activity,
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
  }) {
    if (activity.comicScenes.isEmpty) {
      return Column(
        children: <Widget>[
          _reviewPanel(activity, language),
          const Expanded(
            child: Center(child: Text('No comic scenes available')),
          ),
        ],
      );
    }

    return Column(
      children: <Widget>[
        _reviewPanel(activity, language),
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
    return EcoUnityContentReviewPanel(
      status: activity.contentStatus,
      onStatusChanged: (EcoUnityContentStatus status) {
        return _updateActivityContentStatus(activity, status, language);
      },
    );
  }

  Future<void> _updateActivityContentStatus(
    EcoUnityLearningActivity activity,
    EcoUnityContentStatus status,
    String language,
  ) async {
    final int? activityId = activity.id;
    if (activityId == null) {
      throw StateError('Activity id is missing');
    }

    final EcoUnityLearningActivity? updatedActivity =
        await Provider.of<EcoUnityLearningProvider>(
          context,
          listen: false,
        ).updateActivityContentStatus(
          activityId: activityId,
          status: status,
          language: language,
        );

    if (mounted && updatedActivity != null) {
      final _ActivityScreenData data = _ActivityScreenData(
        activity: updatedActivity,
        language: language,
        loadingAdditionalScenes: false,
      );
      setState(() {
        _latestData = data;
        _future = Future<_ActivityScreenData>.value(data);
      });
    }
  }

  Future<_ActivityScreenData> _loadActivityData() async {
    final EcoUnityLearningProvider provider =
        Provider.of<EcoUnityLearningProvider>(context, listen: false);
    final String language = await core.Settings().getLanguage() ?? 'en';
    final int? activityId = widget.activityId ?? widget.activity?.id;

    EcoUnityLearningActivity? activity = widget.activity;
    if (activityId != null) {
      final EcoUnityLearningActivity? cachedFullActivity = provider
          .cachedActivity(activityId, language: language);
      if (cachedFullActivity != null && cachedFullActivity.isComic) {
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
    await _showCompletionDialogIfNeeded(activity, language);
  }

  Future<void> _showCompletionDialogIfNeeded(
    EcoUnityLearningActivity activity,
    String language,
  ) async {
    final String completionText = activity.completionText.trim();
    if (completionText.isEmpty) {
      return;
    }
    final String key = _activityAnalyticsKey(activity, language);
    if (!_shownCompletionDialogKeys.add(key) || !mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Activity completed'),
          content: EcoUnityLearningCopy(text: completionText),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _trackActivityStarted(
    EcoUnityLearningActivity activity,
    String language,
  ) {
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

  Future<void> _trackQuizCompleted(
    EcoUnityLearningActivity activity,
    String language,
    EcoUnityQuizResult result,
    int attemptNumber,
  ) {
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

class _ReadableActivityView extends StatefulWidget {
  const _ReadableActivityView({
    required this.activity,
    required this.reviewPanel,
    required this.onCompleted,
  });

  final EcoUnityLearningActivity activity;
  final Widget reviewPanel;
  final Future<void> Function() onCompleted;

  @override
  State<_ReadableActivityView> createState() => _ReadableActivityViewState();
}

class _ReadableActivityViewState extends State<_ReadableActivityView> {
  bool _completed = false;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _ActivityHeroImage(activity: widget.activity),
        if (widget.activity.heroImage != null) const SizedBox(height: 16),
        _ActivityIntro(activity: widget.activity),
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
        FilledButton.icon(
          onPressed: _completed || _submitting ? null : _complete,
          icon: _submitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(_completed ? Icons.check_circle : Icons.check),
          label: Text(_completed ? 'Completed' : 'Mark complete'),
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
    required this.reviewPanel,
    required this.onQuizSubmitted,
    required this.onCompleted,
  });

  final EcoUnityLearningActivity activity;
  final Widget reviewPanel;
  final Future<void> Function(EcoUnityQuizResult result, int attemptNumber)
  onQuizSubmitted;
  final Future<void> Function(Map<String, dynamic> payload) onCompleted;

  @override
  State<_QuizActivityView> createState() => _QuizActivityViewState();
}

class _QuizActivityViewState extends State<_QuizActivityView> {
  final Map<int, Set<String>> _selectedAnswers = <int, Set<String>>{};
  EcoUnityQuizResult? _result;
  int _attemptNumber = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _ActivityHeroImage(activity: widget.activity),
        if (widget.activity.heroImage != null) const SizedBox(height: 16),
        _ActivityIntro(activity: widget.activity),
        widget.reviewPanel,
        const SizedBox(height: 16),
        for (final EcoUnityQuizQuestion question in widget.activity.questions)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _QuestionCard(
              question: question,
              selectedAnswers:
                  _selectedAnswers[_questionKey(question)] ?? <String>{},
              onChanged: (Set<String> answers) {
                setState(() {
                  _selectedAnswers[_questionKey(question)] = answers;
                  _result = null;
                });
              },
            ),
          ),
        if (_result != null) ...<Widget>[
          _QuizResultPanel(result: _result!),
          const SizedBox(height: 12),
        ],
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check),
          label: const Text('Submit answers'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final EcoUnityQuizResult result = widget.activity.evaluateQuizAnswers(
      _selectedAnswers,
    );
    _attemptNumber += 1;
    setState(() {
      _result = result;
    });

    await widget.onQuizSubmitted(result, _attemptNumber);

    if (result.passed) {
      await widget.onCompleted(<String, dynamic>{
        'score': result.score,
        'possible_score': result.possibleScore,
        'correct_questions': result.correctQuestionCount,
        'question_count': result.questionCount,
        'passed': result.passed,
        'attempt_number': _attemptNumber,
      });
    }
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.selectedAnswers,
    required this.onChanged,
  });

  final EcoUnityQuizQuestion question;
  final Set<String> selectedAnswers;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              question.prompt,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: EcoUnityColors.deepTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            if (question.allowsMultipleAnswers)
              for (final EcoUnityQuizOption option in question.options)
                CheckboxListTile(
                  value: selectedAnswers.contains(option.id),
                  onChanged: (bool? selected) {
                    final Set<String> nextAnswers = <String>{
                      ...selectedAnswers,
                    };
                    if (selected ?? false) {
                      nextAnswers.add(option.id);
                    } else {
                      nextAnswers.remove(option.id);
                    }
                    onChanged(nextAnswers);
                  },
                  title: Text(option.label),
                  controlAffinity: ListTileControlAffinity.leading,
                )
            else
              RadioGroup<String>(
                groupValue: selectedAnswers.isEmpty
                    ? null
                    : selectedAnswers.first,
                onChanged: (String? value) {
                  if (value != null) {
                    onChanged(<String>{value});
                  }
                },
                child: Column(
                  children: <Widget>[
                    for (final EcoUnityQuizOption option in question.options)
                      RadioListTile<String>(
                        value: option.id,
                        title: Text(option.label),
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

class _ReflectionActivityView extends StatefulWidget {
  const _ReflectionActivityView({
    required this.activity,
    required this.reviewPanel,
    required this.submitLabel,
    required this.onCompleted,
  });

  final EcoUnityLearningActivity activity;
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
        _ActivityHeroImage(activity: widget.activity),
        if (widget.activity.heroImage != null) const SizedBox(height: 16),
        _ActivityIntro(activity: widget.activity),
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

class _ActivityHeroImage extends StatelessWidget {
  const _ActivityHeroImage({required this.activity});

  final EcoUnityLearningActivity activity;

  @override
  Widget build(BuildContext context) {
    final EcoUnityMedia? media = activity.heroImage;
    if (media == null) {
      return const SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: EcoUnityMediaImage(
        media: media,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(8),
        fallback: DecoratedBox(
          decoration: const BoxDecoration(
            color: EcoUnityColors.surfaceContainer,
          ),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              color: EcoUnityColors.deepTeal.withValues(alpha: 0.72),
              size: 36,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityIntro extends StatelessWidget {
  const _ActivityIntro({required this.activity});

  final EcoUnityLearningActivity activity;

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
            if (activity.learningObjective.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              EcoUnityLearningCopy(
                text: activity.learningObjective,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: EcoUnityColors.deepTeal,
                  fontWeight: FontWeight.w600,
                ),
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
