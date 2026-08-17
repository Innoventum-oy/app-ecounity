import 'dart:convert';

enum EcoUnityContentStatus {
  draft,
  review,
  approved,
  published,
  archived,
  unknown,
}

enum EcoUnityActivityType { comic, mlr, quiz, reflection, challenge, unknown }

enum EcoUnityFlowStage {
  discover,
  explore,
  learn,
  reflect,
  act,
  progress,
  unknown,
}

enum EcoUnityQuizPassingLogic { minimumScore, passFail, completionOnly }

enum EcoUnityProgressStatus { opened, completed, submitted, reset }

enum EcoUnityComicViewportKind { portrait, landscape }

enum EcoUnitySpeechGenerationStatus {
  needsGeneration,
  queued,
  running,
  ready,
  updateRecommended,
  failed,
  unknown,
}

enum EcoUnityComicLayerKind { character, prop, decision }

class EcoUnitySdgModule {
  const EcoUnitySdgModule({
    required this.id,
    required this.sdgNumber,
    required this.slug,
    required this.title,
    required this.introduction,
    required this.learningObjective,
    required this.estimatedMinutes,
    required this.difficulty,
    required this.contentStatus,
    required this.iconImage,
    required this.coverImage,
    required this.activities,
    required this.badges,
    required this.tags,
    required this.rawData,
  });

  final int? id;
  final int? sdgNumber;
  final String slug;
  final String title;
  final String introduction;
  final String learningObjective;
  final int? estimatedMinutes;
  final String difficulty;
  final EcoUnityContentStatus contentStatus;
  final EcoUnityMedia? iconImage;
  final EcoUnityMedia? coverImage;
  final List<EcoUnityLearningActivity> activities;
  final List<EcoUnityBadgeSummary> badges;
  final List<EcoUnityTag> tags;
  final Map<String, dynamic> rawData;

  factory EcoUnitySdgModule.fromJson(
    Map<String, dynamic> response, {
    String language = 'en',
  }) {
    final Map<String, dynamic> data = _unwrapData(response);
    final List<EcoUnityLearningActivity> activities =
        _readMapList(data['activities'] ?? data['learning_activities'])
            .map(
              (item) =>
                  EcoUnityLearningActivity.fromJson(item, language: language),
            )
            .toList()
          ..sort((a, b) => a.orderNo.compareTo(b.orderNo));

    return EcoUnitySdgModule(
      id: _readAnyInt(data, const ['id', 'objectid']),
      sdgNumber: _readInt(data['sdg_number']),
      slug: _readString(data['slug']),
      title: _readLocalizedString(data, 'title', language),
      introduction: _readLocalizedString(data, 'introduction', language),
      learningObjective: _readLocalizedString(
        data,
        'learning_objective',
        language,
      ),
      estimatedMinutes: _readInt(data['estimated_minutes']),
      difficulty: _readString(data['difficulty']),
      contentStatus: _contentStatusFromWire(
        _readString(data['content_status']),
      ),
      iconImage: EcoUnityMedia.fromJson(data['icon_image'], language: language),
      coverImage: EcoUnityMedia.fromJson(
        data['cover_image'],
        language: language,
      ),
      activities: activities,
      badges: _readMapList(data['badges'])
          .map(
            (item) => EcoUnityBadgeSummary.fromJson(item, language: language),
          )
          .toList(),
      tags: _readMapList(
        data['tags'],
      ).map((item) => EcoUnityTag.fromJson(item, language: language)).toList(),
      rawData: data,
    );
  }

  double completionRatio(Iterable<EcoUnityProgressEntry> progressEntries) {
    final List<EcoUnityLearningActivity> requiredActivities = activities
        .where((activity) => activity.completionRequired)
        .toList();
    if (requiredActivities.isEmpty) {
      return 0;
    }

    final Set<int> completedActivityIds = progressEntries
        .where((entry) => entry.status == EcoUnityProgressStatus.completed)
        .map((entry) => entry.activityId)
        .whereType<int>()
        .toSet();

    final int completed = requiredActivities
        .where(
          (activity) =>
              activity.id != null && completedActivityIds.contains(activity.id),
        )
        .length;
    return completed / requiredActivities.length;
  }
}

class EcoUnityLearningActivity {
  const EcoUnityLearningActivity({
    required this.id,
    required this.moduleId,
    required this.sdgNumber,
    required this.slug,
    required this.type,
    required this.flowStage,
    required this.orderNo,
    required this.mlrNumber,
    required this.title,
    required this.shortDescription,
    required this.body,
    required this.keyMessage,
    required this.reflectionPrompt,
    required this.completionText,
    required this.videoUrl,
    required this.estimatedMinutes,
    required this.difficulty,
    required this.learningObjective,
    required this.completionRequired,
    required this.passingLogic,
    required this.minimumScore,
    required this.contentStatus,
    required this.heroImage,
    required this.mediaImages,
    required this.files,
    required this.questions,
    required this.comicScenes,
    required this.tags,
    required this.rawData,
  });

  final int? id;
  final int? moduleId;
  final int? sdgNumber;
  final String slug;
  final EcoUnityActivityType type;
  final EcoUnityFlowStage flowStage;
  final int orderNo;
  final int? mlrNumber;
  final String title;
  final String shortDescription;
  final String body;
  final String keyMessage;
  final String reflectionPrompt;
  final String completionText;
  final String videoUrl;
  final int? estimatedMinutes;
  final String difficulty;
  final String learningObjective;
  final bool completionRequired;
  final EcoUnityQuizPassingLogic passingLogic;
  final int? minimumScore;
  final EcoUnityContentStatus contentStatus;
  final EcoUnityMedia? heroImage;
  final List<EcoUnityMedia> mediaImages;
  final List<EcoUnityMedia> files;
  final List<EcoUnityQuizQuestion> questions;
  final List<EcoUnityComicScene> comicScenes;
  final List<EcoUnityTag> tags;
  final Map<String, dynamic> rawData;

  bool get isComic => type == EcoUnityActivityType.comic;
  bool get isQuiz => type == EcoUnityActivityType.quiz;
  bool get isChallenge => type == EcoUnityActivityType.challenge;

  factory EcoUnityLearningActivity.fromJson(
    Map<String, dynamic> response, {
    String language = 'en',
  }) {
    final Map<String, dynamic> data = _unwrapData(response);
    final List<EcoUnityQuizQuestion> questions =
        _readMapList(data['questions'])
            .map(
              (item) => EcoUnityQuizQuestion.fromJson(item, language: language),
            )
            .toList()
          ..sort((a, b) => a.orderNo.compareTo(b.orderNo));

    final List<EcoUnityComicScene> scenes =
        _readMapList(data['comic_scenes'] ?? data['scenes'])
            .map(
              (item) => EcoUnityComicScene.fromJson(item, language: language),
            )
            .toList()
          ..sort((a, b) => a.orderNo.compareTo(b.orderNo));

    return EcoUnityLearningActivity(
      id: _readAnyInt(data, const ['id', 'objectid']),
      moduleId: _readRelationId(data['module']),
      sdgNumber: _readInt(data['sdg_number']),
      slug: _readString(data['slug']),
      type: _activityTypeFromWire(_readString(data['activity_type'])),
      flowStage: _flowStageFromWire(_readString(data['flow_stage'])),
      orderNo: _readInt(data['orderno']) ?? 0,
      mlrNumber: _readInt(data['mlr_number']),
      title: _readLocalizedString(data, 'title', language),
      shortDescription: _readLocalizedString(
        data,
        'short_description',
        language,
      ),
      body: _readLocalizedString(data, 'body', language),
      keyMessage: _readLocalizedString(data, 'key_message', language),
      reflectionPrompt: _readLocalizedString(
        data,
        'reflection_prompt',
        language,
      ),
      completionText: _readLocalizedString(data, 'completion_text', language),
      videoUrl: _readLocalizedString(data, 'video_url', language),
      estimatedMinutes: _readInt(data['estimated_minutes']),
      difficulty: _readString(data['difficulty']),
      learningObjective: _readLocalizedString(
        data,
        'learning_objective',
        language,
      ),
      completionRequired: _readBool(
        data['completion_required'],
        fallback: true,
      ),
      passingLogic: _passingLogicFromWire(_readString(data['passing_logic'])),
      minimumScore: _readInt(data['minimum_score']),
      contentStatus: _contentStatusFromWire(
        _readString(data['content_status']),
      ),
      heroImage: EcoUnityMedia.fromJson(data['hero_image'], language: language),
      mediaImages: _readMapList(data['media_images'])
          .map((item) => EcoUnityMedia.fromJson(item, language: language))
          .whereType<EcoUnityMedia>()
          .toList(),
      files: _readMapList(data['files'])
          .map((item) => EcoUnityMedia.fromJson(item, language: language))
          .whereType<EcoUnityMedia>()
          .toList(),
      questions: questions,
      comicScenes: scenes,
      tags: _readMapList(
        data['tags'],
      ).map((item) => EcoUnityTag.fromJson(item, language: language)).toList(),
      rawData: data,
    );
  }

  EcoUnityQuizResult evaluateQuizAnswers(
    Map<int, Set<String>> selectedOptionIdsByQuestion,
  ) {
    if (questions.isEmpty) {
      return const EcoUnityQuizResult(
        questionCount: 0,
        answeredQuestionCount: 0,
        correctQuestionCount: 0,
        score: 0,
        possibleScore: 0,
        passed: false,
      );
    }

    int answeredQuestionCount = 0;
    int correctQuestionCount = 0;
    int score = 0;
    int possibleScore = 0;

    for (final EcoUnityQuizQuestion question in questions) {
      final int questionKey = question.id ?? question.orderNo;
      final Set<String> selected =
          selectedOptionIdsByQuestion[questionKey] ??
          selectedOptionIdsByQuestion[question.orderNo] ??
          <String>{};
      final int questionPoints = question.pointValue;
      possibleScore += questionPoints;
      if (selected.isNotEmpty) {
        answeredQuestionCount++;
      }
      if (_setEquals(selected, question.correctAnswerIds.toSet())) {
        correctQuestionCount++;
        score += questionPoints;
      }
    }

    final bool allRequiredAnswered = questions
        .where((question) => question.required)
        .every((question) {
          final int questionKey = question.id ?? question.orderNo;
          return (selectedOptionIdsByQuestion[questionKey] ??
                  selectedOptionIdsByQuestion[question.orderNo] ??
                  <String>{})
              .isNotEmpty;
        });

    final bool passed = switch (passingLogic) {
      EcoUnityQuizPassingLogic.completionOnly => allRequiredAnswered,
      EcoUnityQuizPassingLogic.minimumScore =>
        allRequiredAnswered && score >= (minimumScore ?? possibleScore),
      EcoUnityQuizPassingLogic.passFail =>
        allRequiredAnswered && correctQuestionCount == questions.length,
    };

    return EcoUnityQuizResult(
      questionCount: questions.length,
      answeredQuestionCount: answeredQuestionCount,
      correctQuestionCount: correctQuestionCount,
      score: score,
      possibleScore: possibleScore,
      passed: passed,
    );
  }
}

class EcoUnityQuizQuestion {
  const EcoUnityQuizQuestion({
    required this.id,
    required this.activityId,
    required this.orderNo,
    required this.questionType,
    required this.prompt,
    required this.options,
    required this.correctAnswerIds,
    required this.feedbackCorrect,
    required this.feedbackIncorrect,
    required this.points,
    required this.required,
    required this.contentStatus,
    required this.rawData,
  });

  final int? id;
  final int? activityId;
  final int orderNo;
  final String questionType;
  final String prompt;
  final List<EcoUnityQuizOption> options;
  final List<String> correctAnswerIds;
  final String feedbackCorrect;
  final String feedbackIncorrect;
  final int points;
  final bool required;
  final EcoUnityContentStatus contentStatus;
  final Map<String, dynamic> rawData;

  bool get allowsMultipleAnswers => correctAnswerIds.length > 1;
  int get pointValue => points > 0 ? points : 1;

  factory EcoUnityQuizQuestion.fromJson(
    Map<String, dynamic> response, {
    String language = 'en',
  }) {
    final Map<String, dynamic> data = _unwrapData(response);
    final dynamic optionsSource =
        _readLanguageValue(data['options_json'], language) ?? data['options'];

    return EcoUnityQuizQuestion(
      id: _readAnyInt(data, const ['id', 'objectid']),
      activityId: _readRelationId(data['activity']),
      orderNo: _readInt(data['orderno']) ?? 0,
      questionType: _readString(
        data['question_type'],
        fallback: 'multiple_choice',
      ),
      prompt: _readLocalizedString(data, 'prompt', language),
      options: _parseQuizOptions(optionsSource, language: language),
      correctAnswerIds: _readStringListFromJson(data['correct_answers_json']),
      feedbackCorrect: _readLocalizedString(data, 'feedback_correct', language),
      feedbackIncorrect: _readLocalizedString(
        data,
        'feedback_incorrect',
        language,
      ),
      points: _readInt(data['points']) ?? 0,
      required: _readBool(data['required'], fallback: true),
      contentStatus: _contentStatusFromWire(
        _readString(data['content_status']),
      ),
      rawData: data,
    );
  }
}

class EcoUnityQuizOption {
  const EcoUnityQuizOption({required this.id, required this.label});

  final String id;
  final String label;

  factory EcoUnityQuizOption.fromJson(
    Map<String, dynamic> response, {
    String language = 'en',
  }) {
    return EcoUnityQuizOption(
      id: _readString(response['id'] ?? response['key'] ?? response['value']),
      label:
          _stringFromValue(response['label'], language) ??
          _stringFromValue(response['text'], language) ??
          _readString(response['title']),
    );
  }
}

class EcoUnityQuizResult {
  const EcoUnityQuizResult({
    required this.questionCount,
    required this.answeredQuestionCount,
    required this.correctQuestionCount,
    required this.score,
    required this.possibleScore,
    required this.passed,
  });

  final int questionCount;
  final int answeredQuestionCount;
  final int correctQuestionCount;
  final int score;
  final int possibleScore;
  final bool passed;
}

class EcoUnityComic {
  const EcoUnityComic({
    required this.activity,
    required this.scenes,
    required this.rawData,
  });

  final EcoUnityLearningActivity activity;
  final List<EcoUnityComicScene> scenes;
  final Map<String, dynamic> rawData;

  EcoUnityComicScene? get startScene {
    if (scenes.isEmpty) {
      return null;
    }
    final List<EcoUnityComicScene> ordered = [...scenes]
      ..sort((a, b) => a.orderNo.compareTo(b.orderNo));
    return ordered.first;
  }

  factory EcoUnityComic.fromJson(
    Map<String, dynamic> response, {
    String language = 'en',
  }) {
    final Map<String, dynamic> data = _unwrapData(response);
    final Map<String, dynamic> activityData = data['activity'] is Map
        ? _unwrapData(Map<String, dynamic>.from(data['activity'] as Map))
        : data;
    final EcoUnityLearningActivity activity = EcoUnityLearningActivity.fromJson(
      activityData,
      language: language,
    );

    final List<EcoUnityComicScene> scenes =
        (activity.comicScenes.isNotEmpty
                ? activity.comicScenes
                : _readMapList(data['comic_scenes'] ?? data['scenes'])
                      .map(
                        (item) => EcoUnityComicScene.fromJson(
                          item,
                          language: language,
                        ),
                      )
                      .toList())
            .toList()
          ..sort((a, b) => a.orderNo.compareTo(b.orderNo));

    return EcoUnityComic(activity: activity, scenes: scenes, rawData: data);
  }

  EcoUnityComicScene? sceneByKey(String? sceneKey) {
    if (sceneKey == null || sceneKey.trim().isEmpty) {
      return null;
    }
    for (final EcoUnityComicScene scene in scenes) {
      if (scene.sceneKey == sceneKey) {
        return scene;
      }
    }
    return null;
  }

  EcoUnityComicScene? sceneForDecision(EcoUnityComicDecision decision) {
    return sceneByKey(decision.targetSceneKey);
  }
}

class EcoUnityComicScene {
  const EcoUnityComicScene({
    required this.id,
    required this.sceneKey,
    required this.orderNo,
    required this.title,
    required this.narration,
    required this.altText,
    required this.contentStatus,
    required this.backgrounds,
    required this.cast,
    required this.props,
    required this.decisions,
    required this.rawData,
  });

  final int? id;
  final String sceneKey;
  final int orderNo;
  final String title;
  final String narration;
  final String altText;
  final EcoUnityContentStatus contentStatus;
  final List<EcoUnityComicBackground> backgrounds;
  final List<EcoUnityComicCastLayer> cast;
  final List<EcoUnityComicPropLayer> props;
  final List<EcoUnityComicDecision> decisions;
  final Map<String, dynamic> rawData;

  factory EcoUnityComicScene.fromJson(
    Map<String, dynamic> response, {
    String language = 'en',
  }) {
    final Map<String, dynamic> data = _unwrapData(response);
    return EcoUnityComicScene(
      id: _readAnyInt(data, const ['id', 'objectid']),
      sceneKey: _readString(data['scene_key']),
      orderNo: _readInt(data['orderno']) ?? 0,
      title: _readLocalizedString(data, 'title', language),
      narration: _readLocalizedString(data, 'narration', language),
      altText: _readLocalizedString(data, 'alt_text', language),
      contentStatus: _contentStatusFromWire(
        _readString(data['content_status']),
      ),
      backgrounds: _readMapList(data['backgrounds'])
          .map(
            (item) =>
                EcoUnityComicBackground.fromJson(item, language: language),
          )
          .toList(),
      cast:
          _readMapList(data['cast'])
              .map(
                (item) =>
                    EcoUnityComicCastLayer.fromJson(item, language: language),
              )
              .toList()
            ..sort((a, b) => a.orderNo.compareTo(b.orderNo)),
      props:
          _readMapList(data['props'])
              .map(
                (item) =>
                    EcoUnityComicPropLayer.fromJson(item, language: language),
              )
              .toList()
            ..sort((a, b) => a.orderNo.compareTo(b.orderNo)),
      decisions:
          _readMapList(data['decisions'])
              .map(
                (item) =>
                    EcoUnityComicDecision.fromJson(item, language: language),
              )
              .toList()
            ..sort((a, b) => a.orderNo.compareTo(b.orderNo)),
      rawData: data,
    );
  }

  EcoUnityComicViewport? viewportFor(EcoUnityComicViewportKind kind) {
    for (final EcoUnityComicBackground background in backgrounds) {
      final EcoUnityComicViewport? viewport = background.viewportFor(kind);
      if (viewport != null) {
        return viewport;
      }
    }
    for (final EcoUnityComicBackground background in backgrounds) {
      if (background.viewports.isNotEmpty) {
        return background.viewports.first;
      }
    }
    return null;
  }

  List<EcoUnityComicDrawableLayer> drawableLayersFor(
    EcoUnityComicViewportKind kind,
  ) {
    final List<EcoUnityComicDrawableLayer> layers = [
      ...props.map((prop) => prop.toDrawableLayer(kind)),
      ...cast.map((castLayer) => castLayer.toDrawableLayer(kind)),
    ];
    layers.removeWhere(
      (layer) =>
          layer.media == null &&
          (layer.imageUrl == null || layer.imageUrl!.isEmpty),
    );
    layers.sort(_compareDrawableLayers);
    return layers;
  }

  List<EcoUnityComicDrawableLayer> decisionLayersFor(
    EcoUnityComicViewportKind kind,
  ) {
    final List<EcoUnityComicDrawableLayer> layers = decisions
        .map((decision) => decision.toDrawableLayer(kind))
        .toList();
    layers.sort(_compareDrawableLayers);
    return layers;
  }

  List<EcoUnityComicTimelineEntry> dialogueTimeline(String language) {
    final List<EcoUnityComicTimelineEntry> entries = [];
    for (final EcoUnityComicCastLayer castLayer in cast) {
      for (final EcoUnityComicDialogueEntry dialogue
          in castLayer.dialogueEntries) {
        final EcoUnityComicSpeechItem? speech = dialogue.speechForLanguage(
          language,
        );
        entries.add(
          EcoUnityComicTimelineEntry(
            castLayer: castLayer,
            dialogue: dialogue,
            speech: speech,
            startMs: speech?.startMs ?? dialogue.orderNo * 1000,
            durationMs: speech?.durationMs ?? 0,
          ),
        );
      }
    }
    entries.sort((a, b) {
      final int byStart = a.startMs.compareTo(b.startMs);
      if (byStart != 0) {
        return byStart;
      }
      return a.dialogue.orderNo.compareTo(b.dialogue.orderNo);
    });
    return entries;
  }
}

class EcoUnityComicBackground {
  const EcoUnityComicBackground({
    required this.id,
    required this.category,
    required this.title,
    required this.backgroundAltText,
    required this.contentStatus,
    required this.viewports,
    required this.rawData,
  });

  final int? id;
  final String category;
  final String title;
  final String backgroundAltText;
  final EcoUnityContentStatus contentStatus;
  final List<EcoUnityComicViewport> viewports;
  final Map<String, dynamic> rawData;

  factory EcoUnityComicBackground.fromJson(
    Map<String, dynamic> response, {
    String language = 'en',
  }) {
    final Map<String, dynamic> data = _unwrapData(response);
    final List<EcoUnityComicViewport> viewports =
        _readMapList(data['viewports'])
            .map(
              (item) =>
                  EcoUnityComicViewport.fromJson(item, language: language),
            )
            .toList();
    return EcoUnityComicBackground(
      id: _readAnyInt(data, const ['id', 'objectid']),
      category: _readString(data['category'], fallback: 'general'),
      title: _readString(data['title']),
      backgroundAltText: _readLocalizedString(
        data,
        'background_alt_text',
        language,
      ),
      contentStatus: _contentStatusFromWire(
        _readString(data['content_status']),
      ),
      viewports: _backgroundViewportsWithFallbackMedia(
        data,
        viewports,
        language: language,
      ),
      rawData: data,
    );
  }

  EcoUnityComicViewport? viewportFor(EcoUnityComicViewportKind kind) {
    for (final EcoUnityComicViewport viewport in viewports) {
      if (viewport.kind == kind) {
        return viewport;
      }
    }
    return null;
  }
}

class EcoUnityComicViewport {
  const EcoUnityComicViewport({
    required this.id,
    required this.kind,
    required this.title,
    required this.backgroundImage,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.generationStatus,
    required this.contentStatus,
    required this.rawData,
  });

  final int? id;
  final EcoUnityComicViewportKind kind;
  final String title;
  final EcoUnityMedia? backgroundImage;
  final int canvasWidth;
  final int canvasHeight;
  final EcoUnitySpeechGenerationStatus generationStatus;
  final EcoUnityContentStatus contentStatus;
  final Map<String, dynamic> rawData;

  factory EcoUnityComicViewport.fromJson(
    Map<String, dynamic> response, {
    String language = 'en',
  }) {
    final Map<String, dynamic> data = _unwrapData(response);
    return EcoUnityComicViewport(
      id: _readAnyInt(data, const ['id', 'objectid']),
      kind: _viewportKindFromWire(
        _readString(data['viewport'] ?? data['kind'] ?? data['name']),
      ),
      title: _readString(data['title'] ?? data['name']),
      backgroundImage: _readMediaFromFields(
        data,
        objectKeys: const ['background_image', 'image'],
        urlKeys: const ['background_image_url', 'image_url', 'imageurl', 'url'],
        idKeys: const ['background_image_id', 'image_id', 'imageid', 'fileid'],
        language: language,
      ),
      canvasWidth: _readInt(data['canvas_width'] ?? data['width']) ?? 1024,
      canvasHeight: _readInt(data['canvas_height'] ?? data['height']) ?? 1365,
      generationStatus: _speechGenerationStatusFromWire(
        _readString(data['generation_status']),
      ),
      contentStatus: _contentStatusFromWire(
        _readString(data['content_status']),
      ),
      rawData: data,
    );
  }
}

class EcoUnityComicCastLayer {
  const EcoUnityComicCastLayer({
    required this.id,
    required this.character,
    required this.poseLayer,
    required this.orderNo,
    required this.zIndex,
    required this.portraitLayout,
    required this.landscapeLayout,
    required this.altText,
    required this.contentStatus,
    required this.dialogueEntries,
    required this.rawData,
  });

  final int? id;
  final EcoUnityComicCharacter? character;
  final EcoUnityComicPoseLayer? poseLayer;
  final int orderNo;
  final int zIndex;
  final EcoUnityComicLayout portraitLayout;
  final EcoUnityComicLayout landscapeLayout;
  final String altText;
  final EcoUnityContentStatus contentStatus;
  final List<EcoUnityComicDialogueEntry> dialogueEntries;
  final Map<String, dynamic> rawData;

  factory EcoUnityComicCastLayer.fromJson(
    Map<String, dynamic> response, {
    String language = 'en',
  }) {
    final Map<String, dynamic> data = _unwrapData(response);
    return EcoUnityComicCastLayer(
      id: _readAnyInt(data, const ['id', 'objectid']),
      character: EcoUnityComicCharacter.fromJson(
        data['character'],
        language: language,
      ),
      poseLayer: EcoUnityComicPoseLayer.fromJson(
        data['pose_layer'],
        language: language,
      ),
      orderNo: _readInt(data['orderno']) ?? 0,
      zIndex: _readInt(data['z_index']) ?? 10,
      portraitLayout: EcoUnityComicLayout.fromJson(
        data['portrait_layout_json'],
      ),
      landscapeLayout: EcoUnityComicLayout.fromJson(
        data['landscape_layout_json'],
      ),
      altText: _readLocalizedString(data, 'alt_text', language),
      contentStatus: _contentStatusFromWire(
        _readString(data['content_status']),
      ),
      dialogueEntries:
          _readMapList(data['dialogue_entries'])
              .map(
                (item) => EcoUnityComicDialogueEntry.fromJson(
                  item,
                  language: language,
                ),
              )
              .toList()
            ..sort((a, b) => a.orderNo.compareTo(b.orderNo)),
      rawData: data,
    );
  }

  EcoUnityComicLayout layoutFor(EcoUnityComicViewportKind kind) {
    return kind == EcoUnityComicViewportKind.landscape
        ? landscapeLayout
        : portraitLayout;
  }

  EcoUnityComicDrawableLayer toDrawableLayer(EcoUnityComicViewportKind kind) {
    final EcoUnityComicLayout layout = layoutFor(kind);
    return EcoUnityComicDrawableLayer(
      kind: EcoUnityComicLayerKind.character,
      id: id,
      label: character?.name ?? poseLayer?.slug ?? '',
      media: poseLayer?.generatedImage,
      imageUrl: poseLayer?.generatedImage?.url,
      altText: altText.isNotEmpty ? altText : poseLayer?.altText ?? '',
      layout: layout,
      orderNo: orderNo,
      effectiveZIndex: layout.zIndex ?? zIndex,
    );
  }
}

class EcoUnityComicPropLayer {
  const EcoUnityComicPropLayer({
    required this.id,
    required this.prop,
    required this.orderNo,
    required this.zIndex,
    required this.portraitLayout,
    required this.landscapeLayout,
    required this.altText,
    required this.rawData,
  });

  final int? id;
  final EcoUnityComicProp? prop;
  final int orderNo;
  final int zIndex;
  final EcoUnityComicLayout portraitLayout;
  final EcoUnityComicLayout landscapeLayout;
  final String altText;
  final Map<String, dynamic> rawData;

  factory EcoUnityComicPropLayer.fromJson(
    Map<String, dynamic> response, {
    String language = 'en',
  }) {
    final Map<String, dynamic> data = _unwrapData(response);
    return EcoUnityComicPropLayer(
      id: _readAnyInt(data, const ['id', 'objectid']),
      prop: EcoUnityComicProp.fromJson(data['prop'], language: language),
      orderNo: _readInt(data['orderno']) ?? 0,
      zIndex: _readInt(data['z_index']) ?? 20,
      portraitLayout: EcoUnityComicLayout.fromJson(
        data['portrait_layout_json'],
      ),
      landscapeLayout: EcoUnityComicLayout.fromJson(
        data['landscape_layout_json'],
      ),
      altText: _readLocalizedString(data, 'alt_text', language),
      rawData: data,
    );
  }

  EcoUnityComicLayout layoutFor(EcoUnityComicViewportKind kind) {
    return kind == EcoUnityComicViewportKind.landscape
        ? landscapeLayout
        : portraitLayout;
  }

  EcoUnityComicDrawableLayer toDrawableLayer(EcoUnityComicViewportKind kind) {
    final EcoUnityComicLayout layout = layoutFor(kind);
    return EcoUnityComicDrawableLayer(
      kind: EcoUnityComicLayerKind.prop,
      id: id,
      label: prop?.name ?? prop?.slug ?? '',
      media: prop?.image,
      imageUrl: prop?.image?.url,
      altText: altText.isNotEmpty ? altText : prop?.altText ?? '',
      layout: layout,
      orderNo: orderNo,
      effectiveZIndex: layout.zIndex ?? zIndex,
    );
  }
}

class EcoUnityComicDecision {
  const EcoUnityComicDecision({
    required this.id,
    required this.orderNo,
    required this.label,
    required this.targetSceneKey,
    required this.consequenceSummary,
    required this.choiceImage,
    required this.portraitLayout,
    required this.landscapeLayout,
    required this.zIndex,
    required this.altText,
    required this.contentStatus,
    required this.rawData,
  });

  final int? id;
  final int orderNo;
  final String label;
  final String targetSceneKey;
  final String consequenceSummary;
  final EcoUnityMedia? choiceImage;
  final EcoUnityComicLayout portraitLayout;
  final EcoUnityComicLayout landscapeLayout;
  final int zIndex;
  final String altText;
  final EcoUnityContentStatus contentStatus;
  final Map<String, dynamic> rawData;

  factory EcoUnityComicDecision.fromJson(
    Map<String, dynamic> response, {
    String language = 'en',
  }) {
    final Map<String, dynamic> data = _unwrapData(response);
    return EcoUnityComicDecision(
      id: _readAnyInt(data, const ['id', 'objectid']),
      orderNo: _readInt(data['orderno']) ?? 0,
      label: _readLocalizedString(data, 'label', language),
      targetSceneKey: _readString(data['target_scene_key']).isNotEmpty
          ? _readString(data['target_scene_key'])
          : _readString(_firstMap(data['target_scene'])?['scene_key']),
      consequenceSummary: _readLocalizedString(
        data,
        'consequence_summary',
        language,
      ),
      choiceImage: _readMediaFromFields(
        data,
        objectKeys: const ['choice_image', 'image'],
        urlKeys: const ['choice_image_url', 'image_url', 'imageurl', 'url'],
        idKeys: const ['choice_image_id', 'image_id', 'imageid', 'fileid'],
        language: language,
      ),
      portraitLayout: EcoUnityComicLayout.fromJson(
        data['portrait_layout_json'],
      ),
      landscapeLayout: EcoUnityComicLayout.fromJson(
        data['landscape_layout_json'],
      ),
      zIndex: _readInt(data['z_index']) ?? 80,
      altText: _readLocalizedString(data, 'alt_text', language),
      contentStatus: _contentStatusFromWire(
        _readString(data['content_status']),
      ),
      rawData: data,
    );
  }

  EcoUnityComicLayout layoutFor(EcoUnityComicViewportKind kind) {
    return kind == EcoUnityComicViewportKind.landscape
        ? landscapeLayout
        : portraitLayout;
  }

  EcoUnityComicDrawableLayer toDrawableLayer(EcoUnityComicViewportKind kind) {
    final EcoUnityComicLayout layout = layoutFor(kind);
    return EcoUnityComicDrawableLayer(
      kind: EcoUnityComicLayerKind.decision,
      id: id,
      label: label,
      media: choiceImage,
      imageUrl: choiceImage?.url,
      altText: altText,
      layout: layout,
      orderNo: orderNo,
      effectiveZIndex: layout.zIndex ?? zIndex,
    );
  }
}

class EcoUnityComicDialogueEntry {
  const EcoUnityComicDialogueEntry({
    required this.id,
    required this.orderNo,
    required this.dialogue,
    required this.speechFeeling,
    required this.speechItems,
    required this.rawData,
  });

  final int? id;
  final int orderNo;
  final String dialogue;
  final String speechFeeling;
  final List<EcoUnityComicSpeechItem> speechItems;
  final Map<String, dynamic> rawData;

  factory EcoUnityComicDialogueEntry.fromJson(
    Map<String, dynamic> response, {
    String language = 'en',
  }) {
    final Map<String, dynamic> data = _unwrapData(response);
    return EcoUnityComicDialogueEntry(
      id: _readAnyInt(data, const ['id', 'objectid']),
      orderNo: _readInt(data['orderno']) ?? 0,
      dialogue: _readLocalizedString(data, 'dialogue', language),
      speechFeeling: _readString(data['speech_feeling']),
      speechItems:
          _readMapList(
              data['speech_items'],
            ).map((item) => EcoUnityComicSpeechItem.fromJson(item)).toList()
            ..sort((a, b) {
              final int byOrder = a.orderNo.compareTo(b.orderNo);
              if (byOrder != 0) {
                return byOrder;
              }
              return a.startMs.compareTo(b.startMs);
            }),
      rawData: data,
    );
  }

  EcoUnityComicSpeechItem? speechForLanguage(String language) {
    for (final EcoUnityComicSpeechItem speech in speechItems) {
      if (speech.language == language &&
          speech.generationStatus == EcoUnitySpeechGenerationStatus.ready) {
        return speech;
      }
    }
    for (final EcoUnityComicSpeechItem speech in speechItems) {
      if (speech.language == language) {
        return speech;
      }
    }
    return null;
  }
}

class EcoUnityComicSpeechItem {
  const EcoUnityComicSpeechItem({
    required this.id,
    required this.dialogueEntryId,
    required this.language,
    required this.audioFile,
    required this.dialogueText,
    required this.voice,
    required this.speechModel,
    required this.responseFormat,
    required this.speed,
    required this.startMs,
    required this.durationMs,
    required this.orderNo,
    required this.generationStatus,
    required this.rawData,
  });

  final int? id;
  final int? dialogueEntryId;
  final String language;
  final EcoUnityMedia? audioFile;
  final String dialogueText;
  final String voice;
  final String speechModel;
  final String responseFormat;
  final double speed;
  final int startMs;
  final int durationMs;
  final int orderNo;
  final EcoUnitySpeechGenerationStatus generationStatus;
  final Map<String, dynamic> rawData;

  bool get hasReadyAudio =>
      generationStatus == EcoUnitySpeechGenerationStatus.ready &&
      audioFile?.url != null &&
      audioFile!.url!.isNotEmpty;

  factory EcoUnityComicSpeechItem.fromJson(Map<String, dynamic> response) {
    final Map<String, dynamic> data = _unwrapData(response);
    return EcoUnityComicSpeechItem(
      id: _readAnyInt(data, const ['id', 'objectid']),
      dialogueEntryId: _readRelationId(data['dialogue_entry']),
      language: _readString(data['language'], fallback: 'en'),
      audioFile: EcoUnityMedia.fromJson(data['audio_file']),
      dialogueText: _readString(data['dialogue_text']),
      voice: _readString(data['voice']),
      speechModel: _readString(data['speech_model']),
      responseFormat: _readString(data['response_format'], fallback: 'mp3'),
      speed: _readDouble(data['speed']) ?? 1,
      startMs: _readInt(data['start_ms']) ?? 0,
      durationMs: _readInt(data['duration_ms']) ?? 0,
      orderNo: _readInt(data['orderno']) ?? 0,
      generationStatus: _speechGenerationStatusFromWire(
        _readString(data['generation_status']),
      ),
      rawData: data,
    );
  }
}

class EcoUnityComicTimelineEntry {
  const EcoUnityComicTimelineEntry({
    required this.castLayer,
    required this.dialogue,
    required this.speech,
    required this.startMs,
    required this.durationMs,
  });

  final EcoUnityComicCastLayer castLayer;
  final EcoUnityComicDialogueEntry dialogue;
  final EcoUnityComicSpeechItem? speech;
  final int startMs;
  final int durationMs;

  bool get hasReadyAudio => speech?.hasReadyAudio ?? false;
}

class EcoUnityComicLayout {
  const EcoUnityComicLayout({
    required this.x,
    required this.y,
    required this.scale,
    required this.bubbleX,
    required this.bubbleY,
    required this.rotation,
    required this.flipX,
    required this.zIndex,
    required this.rawData,
  });

  final double x;
  final double y;
  final double scale;
  final double bubbleX;
  final double bubbleY;
  final double rotation;
  final bool flipX;
  final int? zIndex;
  final Map<String, dynamic> rawData;

  static const EcoUnityComicLayout defaults = EcoUnityComicLayout(
    x: 0.5,
    y: 0.5,
    scale: 1,
    bubbleX: 0.5,
    bubbleY: 0.2,
    rotation: 0,
    flipX: false,
    zIndex: null,
    rawData: <String, dynamic>{},
  );

  factory EcoUnityComicLayout.fromJson(dynamic raw) {
    final Map<String, dynamic> data = _decodeJsonMap(raw);
    final double x = _readDouble(data['x']) ?? defaults.x;
    final double y = _readDouble(data['y']) ?? defaults.y;
    return EcoUnityComicLayout(
      x: x.clamp(0, 1).toDouble(),
      y: y.clamp(0, 1).toDouble(),
      scale: (_readDouble(data['scale']) ?? defaults.scale)
          .clamp(0, 4)
          .toDouble(),
      bubbleX: (_readDouble(data['bubble_x']) ?? x).clamp(0, 1).toDouble(),
      bubbleY: (_readDouble(data['bubble_y']) ?? defaults.bubbleY)
          .clamp(0, 1)
          .toDouble(),
      rotation: _readDouble(data['rotation']) ?? defaults.rotation,
      flipX: _readBool(data['flip_x']),
      zIndex: _readInt(data['z_index']),
      rawData: data,
    );
  }
}

class EcoUnityComicDrawableLayer {
  const EcoUnityComicDrawableLayer({
    required this.kind,
    required this.id,
    required this.label,
    required this.media,
    required this.imageUrl,
    required this.altText,
    required this.layout,
    required this.orderNo,
    required this.effectiveZIndex,
  });

  final EcoUnityComicLayerKind kind;
  final int? id;
  final String label;
  final EcoUnityMedia? media;
  final String? imageUrl;
  final String altText;
  final EcoUnityComicLayout layout;
  final int orderNo;
  final int effectiveZIndex;
}

class EcoUnityComicCharacter {
  const EcoUnityComicCharacter({
    required this.id,
    required this.slug,
    required this.name,
    required this.referenceImage,
    required this.rawData,
  });

  final int? id;
  final String slug;
  final String name;
  final EcoUnityMedia? referenceImage;
  final Map<String, dynamic> rawData;

  static EcoUnityComicCharacter? fromJson(
    dynamic raw, {
    String language = 'en',
  }) {
    final Map<String, dynamic>? data = _firstMap(raw);
    if (data == null) {
      return null;
    }
    return EcoUnityComicCharacter(
      id: _readAnyInt(data, const ['id', 'objectid']),
      slug: _readString(data['slug']),
      name: _readLocalizedString(data, 'name', language),
      referenceImage: EcoUnityMedia.fromJson(
        data['reference_image'] ?? data['image'],
        language: language,
      ),
      rawData: data,
    );
  }
}

class EcoUnityComicPoseLayer {
  const EcoUnityComicPoseLayer({
    required this.id,
    required this.slug,
    required this.generatedImage,
    required this.altText,
    required this.generationStatus,
    required this.rawData,
  });

  final int? id;
  final String slug;
  final EcoUnityMedia? generatedImage;
  final String altText;
  final EcoUnitySpeechGenerationStatus generationStatus;
  final Map<String, dynamic> rawData;

  static EcoUnityComicPoseLayer? fromJson(
    dynamic raw, {
    String language = 'en',
  }) {
    final Map<String, dynamic>? data = _firstMap(raw);
    if (data == null) {
      return null;
    }
    return EcoUnityComicPoseLayer(
      id: _readAnyInt(data, const ['id', 'objectid']),
      slug: _readString(data['slug']),
      generatedImage: _readMediaFromFields(
        data,
        objectKeys: const ['generated_image', 'image'],
        urlKeys: const ['generated_image_url', 'image_url', 'imageurl', 'url'],
        idKeys: const ['generated_image_id', 'image_id', 'imageid', 'fileid'],
        language: language,
      ),
      altText: _readLocalizedString(data, 'alt_text', language),
      generationStatus: _speechGenerationStatusFromWire(
        _readString(data['generation_status']),
      ),
      rawData: data,
    );
  }
}

class EcoUnityComicProp {
  const EcoUnityComicProp({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    required this.image,
    required this.altText,
    required this.rawData,
  });

  final int? id;
  final String slug;
  final String name;
  final String category;
  final EcoUnityMedia? image;
  final String altText;
  final Map<String, dynamic> rawData;

  static EcoUnityComicProp? fromJson(dynamic raw, {String language = 'en'}) {
    final Map<String, dynamic>? data = _firstMap(raw);
    if (data == null) {
      return null;
    }
    return EcoUnityComicProp(
      id: _readAnyInt(data, const ['id', 'objectid']),
      slug: _readString(data['slug']),
      name: _readLocalizedString(data, 'name', language),
      category: _readString(data['category'], fallback: 'general'),
      image: _readMediaFromFields(
        data,
        objectKeys: const ['image'],
        urlKeys: const ['image_url', 'imageurl', 'url'],
        idKeys: const ['image_id', 'imageid', 'fileid'],
        language: language,
      ),
      altText: _readLocalizedString(data, 'alt_text', language),
      rawData: data,
    );
  }
}

class EcoUnityProgressEntry {
  const EcoUnityProgressEntry({
    required this.id,
    required this.userId,
    required this.moduleId,
    required this.activityId,
    required this.language,
    required this.status,
    required this.source,
    required this.payload,
    required this.startedAt,
    required this.completedAt,
    required this.rawData,
  });

  final int? id;
  final int? userId;
  final int? moduleId;
  final int? activityId;
  final String language;
  final EcoUnityProgressStatus status;
  final String source;
  final Map<String, dynamic> payload;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> rawData;

  factory EcoUnityProgressEntry.fromJson(Map<String, dynamic> response) {
    final Map<String, dynamic> data = _unwrapData(response);
    return EcoUnityProgressEntry(
      id: _readAnyInt(data, const ['id', 'objectid']),
      userId: _readRelationId(data['user']),
      moduleId: _readRelationId(data['module']),
      activityId: _readRelationId(data['activity']),
      language: _readString(data['language'], fallback: 'en'),
      status: _progressStatusFromWire(_readString(data['status'])),
      source: _readString(data['source'], fallback: 'app'),
      payload: _decodeJsonMap(data['payload_json']),
      startedAt: _readDateTime(data['started_at']),
      completedAt: _readDateTime(data['completed_at']),
      rawData: data,
    );
  }
}

class EcoUnityBadgeSummary {
  const EcoUnityBadgeSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.requiredActivityIds,
    required this.rawData,
  });

  final int? id;
  final String name;
  final String description;
  final EcoUnityMedia? image;
  final List<int> requiredActivityIds;
  final Map<String, dynamic> rawData;

  factory EcoUnityBadgeSummary.fromJson(
    Map<String, dynamic> response, {
    String language = 'en',
  }) {
    final Map<String, dynamic> data = _unwrapData(response);
    return EcoUnityBadgeSummary(
      id: _readAnyInt(data, const ['id', 'objectid']),
      name: _readLocalizedString(data, 'name', language),
      description: _readLocalizedString(data, 'description', language),
      image: EcoUnityMedia.fromJson(
        data['image'] ?? data['badgeimageurl'],
        language: language,
      ),
      requiredActivityIds: _readMapList(
        data['requiredactivities'],
      ).map(_readRelationId).whereType<int>().toList(),
      rawData: data,
    );
  }
}

class EcoUnityTag {
  const EcoUnityTag({
    required this.id,
    required this.type,
    required this.name,
    required this.slug,
    required this.rawData,
  });

  final int? id;
  final String type;
  final String name;
  final String slug;
  final Map<String, dynamic> rawData;

  factory EcoUnityTag.fromJson(
    Map<String, dynamic> response, {
    String language = 'en',
  }) {
    final Map<String, dynamic> data = _unwrapData(response);
    return EcoUnityTag(
      id: _readAnyInt(data, const ['id', 'objectid']),
      type: _readString(data['tag_type']),
      name: _readLocalizedString(data, 'name', language),
      slug: _readString(data['slug']),
      rawData: data,
    );
  }
}

class EcoUnityMedia {
  const EcoUnityMedia({
    required this.id,
    required this.url,
    required this.title,
    required this.altText,
    required this.rawData,
  });

  final int? id;
  final String? url;
  final String title;
  final String altText;
  final Map<String, dynamic> rawData;

  static EcoUnityMedia? fromJson(dynamic raw, {String language = 'en'}) {
    if (raw == null) {
      return null;
    }
    if (raw is String) {
      final String value = raw.trim();
      if (value.isEmpty) {
        return null;
      }
      return EcoUnityMedia(
        id: null,
        url: value,
        title: '',
        altText: '',
        rawData: <String, dynamic>{'url': value},
      );
    }

    final Map<String, dynamic>? data = _firstMap(raw);
    if (data == null) {
      return null;
    }

    final String? url = _readFirstNonEmptyString(data, const [
      'url',
      'image_url',
      'imageurl',
      'file_url',
      'fileurl',
      'download_url',
      'badgeimageurl',
      'generated_image_url',
      'background_image_url',
      'choice_image_url',
    ]);

    if (url == null &&
        _readAnyInt(data, const ['id', 'objectid', 'imageid', 'fileid']) ==
            null) {
      return null;
    }

    return EcoUnityMedia(
      id: _readAnyInt(data, const ['id', 'objectid', 'imageid', 'fileid']),
      url: url,
      title: _readLocalizedString(data, 'title', language).isNotEmpty
          ? _readLocalizedString(data, 'title', language)
          : _readString(data['filename'] ?? data['name']),
      altText: _readLocalizedString(data, 'alt_text', language).isNotEmpty
          ? _readLocalizedString(data, 'alt_text', language)
          : _readLocalizedString(data, 'description', language),
      rawData: data,
    );
  }
}

EcoUnityMedia? _readMediaFromFields(
  Map<String, dynamic> data, {
  required List<String> objectKeys,
  required List<String> urlKeys,
  required List<String> idKeys,
  String language = 'en',
}) {
  for (final String key in objectKeys) {
    final EcoUnityMedia? media = EcoUnityMedia.fromJson(
      data[key],
      language: language,
    );
    if (media != null) {
      return media;
    }
  }

  final String? url = _readFirstNonEmptyString(data, urlKeys);
  final int? id = _readAnyInt(data, idKeys);
  if (url == null && id == null) {
    return null;
  }

  return EcoUnityMedia(
    id: id,
    url: url,
    title: _readLocalizedString(data, 'title', language).isNotEmpty
        ? _readLocalizedString(data, 'title', language)
        : _readString(data['name'] ?? data['filename']),
    altText: _readLocalizedString(data, 'alt_text', language).isNotEmpty
        ? _readLocalizedString(data, 'alt_text', language)
        : _readLocalizedString(data, 'description', language),
    rawData: data,
  );
}

List<EcoUnityComicViewport> _backgroundViewportsWithFallbackMedia(
  Map<String, dynamic> data,
  List<EcoUnityComicViewport> viewports, {
  required String language,
}) {
  if (viewports.any(
    (EcoUnityComicViewport viewport) => viewport.backgroundImage != null,
  )) {
    return viewports;
  }

  final EcoUnityMedia? portraitMedia = _readMediaFromFields(
    data,
    objectKeys: const ['portrait_background_image'],
    urlKeys: const ['portrait_background_image_url'],
    idKeys: const ['portrait_background_image_id'],
    language: language,
  );
  final EcoUnityMedia? landscapeMedia = _readMediaFromFields(
    data,
    objectKeys: const ['landscape_background_image'],
    urlKeys: const ['landscape_background_image_url'],
    idKeys: const ['landscape_background_image_id'],
    language: language,
  );

  final List<EcoUnityComicViewport> fallbackViewports = <EcoUnityComicViewport>[
    if (portraitMedia != null)
      _viewportWithMedia(
        _matchingViewport(viewports, EcoUnityComicViewportKind.portrait),
        data,
        EcoUnityComicViewportKind.portrait,
        portraitMedia,
        language: language,
      ),
    if (landscapeMedia != null)
      _viewportWithMedia(
        _matchingViewport(viewports, EcoUnityComicViewportKind.landscape),
        data,
        EcoUnityComicViewportKind.landscape,
        landscapeMedia,
        language: language,
      ),
  ];
  if (fallbackViewports.isNotEmpty) {
    return fallbackViewports;
  }

  final EcoUnityMedia? sharedMedia = _readMediaFromFields(
    data,
    objectKeys: const ['background_image', 'image'],
    urlKeys: const ['background_image_url', 'image_url', 'imageurl', 'url'],
    idKeys: const ['background_image_id', 'image_id', 'imageid', 'fileid'],
    language: language,
  );
  if (sharedMedia == null) {
    return viewports;
  }
  if (viewports.isNotEmpty) {
    return viewports
        .map(
          (EcoUnityComicViewport viewport) => _viewportWithMedia(
            viewport,
            data,
            viewport.kind,
            sharedMedia,
            language: language,
          ),
        )
        .toList();
  }
  return <EcoUnityComicViewport>[
    _viewportWithMedia(
      null,
      data,
      EcoUnityComicViewportKind.portrait,
      sharedMedia,
      language: language,
    ),
  ];
}

EcoUnityComicViewport? _matchingViewport(
  List<EcoUnityComicViewport> viewports,
  EcoUnityComicViewportKind kind,
) {
  for (final EcoUnityComicViewport viewport in viewports) {
    if (viewport.kind == kind) {
      return viewport;
    }
  }
  return null;
}

EcoUnityComicViewport _viewportWithMedia(
  EcoUnityComicViewport? base,
  Map<String, dynamic> data,
  EcoUnityComicViewportKind kind,
  EcoUnityMedia media, {
  required String language,
}) {
  final String title = base?.title.isNotEmpty ?? false
      ? base!.title
      : _readLocalizedString(data, 'title', language);
  return EcoUnityComicViewport(
    id: base?.id,
    kind: kind,
    title: title,
    backgroundImage: media,
    canvasWidth:
        base?.canvasWidth ??
        _readInt(data['canvas_width'] ?? data['width']) ??
        1024,
    canvasHeight:
        base?.canvasHeight ??
        _readInt(data['canvas_height'] ?? data['height']) ??
        1365,
    generationStatus:
        base?.generationStatus ??
        _speechGenerationStatusFromWire(_readString(data['generation_status'])),
    contentStatus:
        base?.contentStatus ??
        _contentStatusFromWire(_readString(data['content_status'])),
    rawData: base?.rawData ?? data,
  );
}

int _compareDrawableLayers(
  EcoUnityComicDrawableLayer a,
  EcoUnityComicDrawableLayer b,
) {
  final int byZIndex = a.effectiveZIndex.compareTo(b.effectiveZIndex);
  if (byZIndex != 0) {
    return byZIndex;
  }
  return a.orderNo.compareTo(b.orderNo);
}

Map<String, dynamic> _unwrapData(Map<String, dynamic> response) {
  final dynamic data = response['data'];
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return Map<String, dynamic>.from(response);
}

Map<String, dynamic>? _firstMap(dynamic raw) {
  if (raw is Map) {
    return _unwrapData(Map<String, dynamic>.from(raw));
  }
  if (raw is Iterable) {
    for (final dynamic item in raw) {
      final Map<String, dynamic>? data = _firstMap(item);
      if (data != null) {
        return data;
      }
    }
  }
  return null;
}

List<Map<String, dynamic>> _readMapList(dynamic raw) {
  if (raw == null) {
    return <Map<String, dynamic>>[];
  }
  if (raw is Map && raw['data'] is Iterable) {
    return _readMapList(raw['data']);
  }
  if (raw is Iterable) {
    return raw.map(_firstMap).whereType<Map<String, dynamic>>().toList();
  }
  final Map<String, dynamic>? single = _firstMap(raw);
  return single == null
      ? <Map<String, dynamic>>[]
      : <Map<String, dynamic>>[single];
}

String _readLocalizedString(
  Map<String, dynamic> data,
  String key,
  String language,
) {
  final String directValue = _stringFromValue(data[key], language) ?? '';
  if (directValue.isNotEmpty) {
    return directValue;
  }
  return _stringFromValue(data['${key}_$language'], language) ?? '';
}

dynamic _readLanguageValue(dynamic value, String language) {
  if (value is Map) {
    if (value.containsKey(language)) {
      return value[language];
    }
    if (value.containsKey('en')) {
      return value['en'];
    }
    if (value.containsKey('data')) {
      return _readLanguageValue(value['data'], language);
    }
    if (value.containsKey('value')) {
      return value['value'];
    }
  }
  if (value is Iterable) {
    for (final dynamic item in value) {
      if (item is Map && item['language'] == language) {
        return item['value'] ?? item['text'] ?? item['label'];
      }
    }
  }
  return value;
}

String? _stringFromValue(dynamic value, String language) {
  final dynamic localizedValue = _readLanguageValue(value, language);
  if (localizedValue == null) {
    return null;
  }
  if (localizedValue is String) {
    return localizedValue;
  }
  if (localizedValue is num || localizedValue is bool) {
    return localizedValue.toString();
  }
  if (localizedValue is Map) {
    for (final String key in const [
      'text',
      'label',
      'title',
      'name',
      'value',
    ]) {
      final String? result = _stringFromValue(localizedValue[key], language);
      if (result != null && result.isNotEmpty) {
        return result;
      }
    }
  }
  return null;
}

String _readString(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }
  if (value is String) {
    return value;
  }
  if (value is num || value is bool) {
    return value.toString();
  }
  if (value is Map) {
    return _stringFromValue(value, 'en') ?? fallback;
  }
  return fallback;
}

String? _readFirstNonEmptyString(Map<String, dynamic> data, List<String> keys) {
  for (final String key in keys) {
    final String value = _readString(data[key]).trim();
    if (value.isNotEmpty) {
      return value;
    }
  }
  return null;
}

int? _readAnyInt(Map<String, dynamic> data, List<String> keys) {
  for (final String key in keys) {
    final int? value = _readInt(data[key]);
    if (value != null) {
      return value;
    }
  }
  return null;
}

int? _readInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
  if (value is Map) {
    return _readAnyInt(Map<String, dynamic>.from(value), const [
      'id',
      'objectid',
      'value',
    ]);
  }
  return null;
}

int? _readRelationId(dynamic value) {
  if (value is Iterable) {
    for (final dynamic item in value) {
      final int? id = _readRelationId(item);
      if (id != null) {
        return id;
      }
    }
  }
  if (value is Map) {
    final Map<String, dynamic>? data = _firstMap(value);
    if (data != null) {
      return _readAnyInt(data, const ['id', 'objectid', 'value']);
    }
  }
  return _readInt(value);
}

double? _readDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.trim());
  }
  return null;
}

bool _readBool(dynamic value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final String normalized = value.trim().toLowerCase();
    if (normalized == '1' || normalized == 'true' || normalized == 'yes') {
      return true;
    }
    if (normalized == '0' || normalized == 'false' || normalized == 'no') {
      return false;
    }
  }
  return fallback;
}

DateTime? _readDateTime(dynamic value) {
  final String raw = _readString(value).trim();
  if (raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}

Map<String, dynamic> _decodeJsonMap(dynamic raw) {
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  if (raw is String) {
    final String normalized = raw
        .trim()
        .replaceAll('&quot;', '"')
        .replaceAll('&#34;', '"')
        .replaceAll('&#x22;', '"');
    if (normalized.isEmpty) {
      return <String, dynamic>{};
    }
    try {
      final dynamic decoded = jsonDecode(normalized);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } on FormatException {
      return <String, dynamic>{};
    }
  }
  return <String, dynamic>{};
}

List<String> _readStringListFromJson(dynamic raw) {
  dynamic value = raw;
  if (value is String) {
    try {
      value = jsonDecode(value);
    } on FormatException {
      value = value.split(',');
    }
  }
  if (value is Iterable) {
    return value
        .map((item) => _readString(item).trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return <String>[];
}

List<EcoUnityQuizOption> _parseQuizOptions(
  dynamic raw, {
  required String language,
}) {
  dynamic value = raw;
  if (value is String) {
    try {
      value = jsonDecode(value);
    } on FormatException {
      value = null;
    }
  }
  if (value is Iterable) {
    return value
        .map(_firstMap)
        .whereType<Map<String, dynamic>>()
        .map((item) => EcoUnityQuizOption.fromJson(item, language: language))
        .where((item) => item.id.isNotEmpty)
        .toList();
  }
  return <EcoUnityQuizOption>[];
}

bool _setEquals(Set<String> a, Set<String> b) {
  if (a.length != b.length) {
    return false;
  }
  for (final String item in a) {
    if (!b.contains(item)) {
      return false;
    }
  }
  return true;
}

EcoUnityContentStatus _contentStatusFromWire(String value) {
  return switch (value) {
    'draft' => EcoUnityContentStatus.draft,
    'review' => EcoUnityContentStatus.review,
    'approved' => EcoUnityContentStatus.approved,
    'published' => EcoUnityContentStatus.published,
    'archived' => EcoUnityContentStatus.archived,
    _ => EcoUnityContentStatus.unknown,
  };
}

EcoUnityActivityType _activityTypeFromWire(String value) {
  return switch (value) {
    'comic' => EcoUnityActivityType.comic,
    'mlr' => EcoUnityActivityType.mlr,
    'quiz' => EcoUnityActivityType.quiz,
    'reflection' => EcoUnityActivityType.reflection,
    'challenge' => EcoUnityActivityType.challenge,
    _ => EcoUnityActivityType.unknown,
  };
}

EcoUnityFlowStage _flowStageFromWire(String value) {
  return switch (value) {
    'discover' => EcoUnityFlowStage.discover,
    'explore' => EcoUnityFlowStage.explore,
    'learn' => EcoUnityFlowStage.learn,
    'reflect' => EcoUnityFlowStage.reflect,
    'act' => EcoUnityFlowStage.act,
    'progress' => EcoUnityFlowStage.progress,
    _ => EcoUnityFlowStage.unknown,
  };
}

EcoUnityQuizPassingLogic _passingLogicFromWire(String value) {
  return switch (value) {
    'minimum_score' => EcoUnityQuizPassingLogic.minimumScore,
    'completion_only' => EcoUnityQuizPassingLogic.completionOnly,
    _ => EcoUnityQuizPassingLogic.passFail,
  };
}

EcoUnityProgressStatus _progressStatusFromWire(String value) {
  return switch (value) {
    'completed' => EcoUnityProgressStatus.completed,
    'submitted' => EcoUnityProgressStatus.submitted,
    'reset' => EcoUnityProgressStatus.reset,
    _ => EcoUnityProgressStatus.opened,
  };
}

EcoUnityComicViewportKind _viewportKindFromWire(String value) {
  final String normalized = value.trim().toLowerCase();
  if (normalized.contains('landscape')) {
    return EcoUnityComicViewportKind.landscape;
  }
  return EcoUnityComicViewportKind.portrait;
}

EcoUnitySpeechGenerationStatus _speechGenerationStatusFromWire(String value) {
  return switch (value) {
    'needs_generation' => EcoUnitySpeechGenerationStatus.needsGeneration,
    'queued' => EcoUnitySpeechGenerationStatus.queued,
    'running' => EcoUnitySpeechGenerationStatus.running,
    'ready' => EcoUnitySpeechGenerationStatus.ready,
    'update_recommended' => EcoUnitySpeechGenerationStatus.updateRecommended,
    'failed' => EcoUnitySpeechGenerationStatus.failed,
    _ => EcoUnitySpeechGenerationStatus.unknown,
  };
}
