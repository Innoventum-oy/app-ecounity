import 'package:core/core.dart' as core;
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_provider.dart';
import 'package:ecounity/src/learning/widgets/ecounity_comic_player.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
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
  Future<_ActivityScreenData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _loadActivityData();
  }

  @override
  void didUpdateWidget(covariant EcoUnityLearningActivityScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activity != widget.activity ||
        oldWidget.activityId != widget.activityId) {
      _future = _loadActivityData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ActivityScreenData>(
      future: _future,
      builder:
          (BuildContext context, AsyncSnapshot<_ActivityScreenData> snapshot) {
            final EcoUnityLearningActivity? activity = snapshot.data?.activity;
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
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Unable to load activity: ${snapshot.error}'));
    }

    final _ActivityScreenData? data = snapshot.data;
    final EcoUnityLearningActivity? activity = data?.activity;
    if (data == null || activity == null) {
      return const Center(child: Text('Activity not found'));
    }

    final Widget content = switch (activity.type) {
      EcoUnityActivityType.comic => _buildComic(activity, data.language),
      EcoUnityActivityType.quiz => _QuizActivityView(
        activity: activity,
        onCompleted: (Map<String, dynamic> payload) {
          return _markCompleted(activity, data.language, payload: payload);
        },
      ),
      EcoUnityActivityType.reflection => _ReflectionActivityView(
        activity: activity,
        submitLabel: 'Submit reflection',
        onCompleted: (Map<String, dynamic> payload) {
          return _markCompleted(activity, data.language, payload: payload);
        },
      ),
      EcoUnityActivityType.challenge => _ReflectionActivityView(
        activity: activity,
        submitLabel: 'Complete challenge',
        onCompleted: (Map<String, dynamic> payload) {
          return _markCompleted(activity, data.language, payload: payload);
        },
      ),
      _ => _ReadableActivityView(
        activity: activity,
        onCompleted: () {
          return _markCompleted(activity, data.language);
        },
      ),
    };

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.78,
      child: content,
    );
  }

  Widget _buildComic(EcoUnityLearningActivity activity, String language) {
    if (activity.comicScenes.isEmpty) {
      return const Center(child: Text('No comic scenes available'));
    }

    return EcoUnityComicPlayer(
      comic: EcoUnityComic(
        activity: activity,
        scenes: activity.comicScenes,
        rawData: activity.rawData,
      ),
      language: language,
      onCompleted: () => _markCompleted(
        activity,
        language,
        payload: const <String, dynamic>{'activity_type': 'comic'},
      ),
      onReadySpeech: (EcoUnityComicSpeechItem speech) {
        if (kDebugMode) {
          debugPrint('Ready comic speech audio: ${speech.audioFile?.url}');
        }
      },
    );
  }

  Future<_ActivityScreenData> _loadActivityData() async {
    final EcoUnityLearningProvider provider =
        Provider.of<EcoUnityLearningProvider>(context, listen: false);
    final String language = await core.Settings().getLanguage() ?? 'en';
    EcoUnityLearningActivity? activity = widget.activity;
    final int? activityId = widget.activityId;

    if (activity == null && activityId != null) {
      activity = await provider.loadActivity(activityId, language: language);
    }

    return _ActivityScreenData(activity: activity, language: language);
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

    await Provider.of<EcoUnityLearningProvider>(
      context,
      listen: false,
    ).markActivityCompleted(
      moduleId: moduleId,
      activityId: activityId,
      language: language,
      payload: <String, dynamic>{
        'activity_type': _activityTypeLabel(activity.type).toLowerCase(),
        ...payload,
      },
    );
  }
}

class _ReadableActivityView extends StatelessWidget {
  const _ReadableActivityView({
    required this.activity,
    required this.onCompleted,
  });

  final EcoUnityLearningActivity activity;
  final Future<void> Function() onCompleted;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _ActivityIntro(activity: activity),
        if (activity.body.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          HtmlWidget(activity.body),
        ],
        if (activity.keyMessage.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          _MessagePanel(text: activity.keyMessage),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onCompleted,
          icon: const Icon(Icons.check),
          label: const Text('Mark complete'),
        ),
      ],
    );
  }
}

class _QuizActivityView extends StatefulWidget {
  const _QuizActivityView({required this.activity, required this.onCompleted});

  final EcoUnityLearningActivity activity;
  final Future<void> Function(Map<String, dynamic> payload) onCompleted;

  @override
  State<_QuizActivityView> createState() => _QuizActivityViewState();
}

class _QuizActivityViewState extends State<_QuizActivityView> {
  final Map<int, Set<String>> _selectedAnswers = <int, Set<String>>{};
  EcoUnityQuizResult? _result;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _ActivityIntro(activity: widget.activity),
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
    setState(() {
      _result = result;
    });

    if (result.passed) {
      await widget.onCompleted(<String, dynamic>{
        'score': result.score,
        'possible_score': result.possibleScore,
        'correct_questions': result.correctQuestionCount,
        'question_count': result.questionCount,
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
    required this.submitLabel,
    required this.onCompleted,
  });

  final EcoUnityLearningActivity activity;
  final String submitLabel;
  final Future<void> Function(Map<String, dynamic> payload) onCompleted;

  @override
  State<_ReflectionActivityView> createState() =>
      _ReflectionActivityViewState();
}

class _ReflectionActivityViewState extends State<_ReflectionActivityView> {
  final TextEditingController _controller = TextEditingController();
  bool _submitted = false;

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
        _ActivityIntro(activity: widget.activity),
        if (widget.activity.body.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          HtmlWidget(widget.activity.body),
        ],
        if (widget.activity.reflectionPrompt.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          Text(
            widget.activity.reflectionPrompt,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: EcoUnityColors.deepTeal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
            ),
          ),
        ],
        if (_submitted &&
            widget.activity.completionText.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          _MessagePanel(text: widget.activity.completionText),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _submitted ? null : _submit,
          icon: Icon(_submitted ? Icons.check_circle : Icons.check),
          label: Text(_submitted ? 'Completed' : widget.submitLabel),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    await widget.onCompleted(<String, dynamic>{
      'reflection': _controller.text.trim(),
    });
    setState(() {
      _submitted = true;
    });
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
              Text(activity.shortDescription),
            ],
            if (activity.learningObjective.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                activity.learningObjective,
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
        child: Text(
          text,
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
  const _ActivityScreenData({required this.activity, required this.language});

  final EcoUnityLearningActivity? activity;
  final String language;
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
