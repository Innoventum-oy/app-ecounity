import 'dart:convert';

import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EcoUnitySdgModule', () {
    test(
      'parses activities, localized copy, and evaluates minimum-score quiz',
      () {
        final EcoUnitySdgModule module = EcoUnitySdgModule.fromJson(
          _sdgModuleFixture(),
        );

        expect(module.sdgNumber, 12);
        expect(module.title, 'Responsible Consumption');
        expect(module.activities.map((activity) => activity.slug), <String>[
          'intro-comic',
          'everyday-choices',
          'check-understanding',
        ]);

        final EcoUnityLearningActivity quiz = module.activities.last;
        expect(quiz.type, EcoUnityActivityType.quiz);
        expect(quiz.questions.map((question) => question.id), <int?>[501, 502]);
        expect(
          quiz.questions.first.options.map((option) => option.label),
          <String>['Reuse or repair items', 'Buy disposable items'],
        );

        final EcoUnityQuizResult passingResult = quiz.evaluateQuizAnswers(
          <int, Set<String>>{
            501: <String>{'reuse'},
            502: <String>{'repair'},
          },
        );

        expect(passingResult.score, 3);
        expect(passingResult.possibleScore, 3);
        expect(passingResult.passed, isTrue);

        final EcoUnityQuizResult failingResult = quiz.evaluateQuizAnswers(
          <int, Set<String>>{
            501: <String>{'disposable'},
            502: <String>{'repair'},
          },
        );

        expect(failingResult.score, 1);
        expect(failingResult.passed, isFalse);
      },
    );

    test('calculates completion ratio from wrapped progress relations', () {
      final EcoUnitySdgModule module = EcoUnitySdgModule.fromJson(
        _sdgModuleFixture(),
      );

      final List<EcoUnityProgressEntry> progressEntries =
          <EcoUnityProgressEntry>[
            EcoUnityProgressEntry.fromJson(<String, dynamic>{
              'id': 1,
              'module': <String, dynamic>{
                'data': <String, dynamic>{'id': 12},
              },
              'activity': <String, dynamic>{
                'data': <String, dynamic>{'id': 101},
              },
              'language': 'en',
              'status': 'completed',
            }),
            EcoUnityProgressEntry.fromJson(<String, dynamic>{
              'id': 2,
              'activity': 102,
              'language': 'en',
              'status': 'opened',
            }),
          ];

      expect(module.completionRatio(progressEntries), closeTo(1 / 3, 0.001));
    });
  });

  group('EcoUnityComic', () {
    test('parses native comic graph and resolves branching decisions', () {
      final EcoUnityComic comic = EcoUnityComic.fromJson(
        _comicActivityFixture(),
      );

      expect(comic.activity.isComic, isTrue);
      expect(comic.startScene?.sceneKey, 'start');

      final EcoUnityComicScene startScene = comic.startScene!;
      expect(
        startScene
            .viewportFor(EcoUnityComicViewportKind.portrait)
            ?.backgroundImage
            ?.url,
        'https://cdn.example.com/backgrounds/kitchen-portrait.png',
      );
      expect(
        comic.sceneForDecision(startScene.decisions.single)?.sceneKey,
        'reuse',
      );
    });

    test('sorts drawable layers using layout z-index overrides', () {
      final EcoUnityComicScene startScene = EcoUnityComic.fromJson(
        _comicActivityFixture(),
      ).startScene!;

      final List<EcoUnityComicDrawableLayer> layers = startScene
          .drawableLayersFor(EcoUnityComicViewportKind.portrait);

      expect(layers.map((layer) => layer.kind), <EcoUnityComicLayerKind>[
        EcoUnityComicLayerKind.prop,
        EcoUnityComicLayerKind.character,
      ]);
      expect(layers.first.label, 'Recycling bin');
      expect(layers.first.effectiveZIndex, 5);
      expect(layers.last.effectiveZIndex, 30);
    });

    test('keeps drawable layers when comic media only has backend IDs', () {
      final EcoUnityComicScene scene = EcoUnityComicScene.fromJson(
        <String, dynamic>{
          'id': 301,
          'scene_key': 'start',
          'orderno': 1,
          'title': <String, dynamic>{'en': 'Start'},
          'backgrounds': <Map<String, dynamic>>[],
          'props': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 601,
              'orderno': 1,
              'prop': <String, dynamic>{
                'slug': 'recycling-bin',
                'name': <String, dynamic>{'en': 'Recycling bin'},
                'image': <String, dynamic>{'id': 901},
              },
            },
          ],
          'cast': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 701,
              'orderno': 2,
              'character': <String, dynamic>{
                'slug': 'aada',
                'name': <String, dynamic>{'en': 'Aada'},
              },
              'pose_layer': <String, dynamic>{
                'slug': 'aada-happy',
                'generated_image': <String, dynamic>{'id': 902},
              },
            },
          ],
          'decisions': <Map<String, dynamic>>[],
        },
      );

      final List<EcoUnityComicDrawableLayer> layers = scene.drawableLayersFor(
        EcoUnityComicViewportKind.portrait,
      );

      expect(layers, hasLength(2));
      expect(
        layers.map((EcoUnityComicDrawableLayer layer) => layer.media?.id),
        containsAll(<int>[901, 902]),
      );
      expect(
        layers.map((EcoUnityComicDrawableLayer layer) => layer.imageUrl),
        everyElement(isNull),
      );
    });

    test('parses enriched comic relation media URLs without extra details', () {
      final EcoUnityComicScene scene = EcoUnityComicScene.fromJson(
        <String, dynamic>{
          'id': 301,
          'scene_key': 'start',
          'orderno': 1,
          'title': <String, dynamic>{'en': 'Start'},
          'backgrounds': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 401,
              'title': 'The Innovation Fair background',
              'background_alt_text': 'Bright school hall',
              'viewports': <Map<String, dynamic>>[
                <String, dynamic>{
                  'objectid': 9,
                  'name': 'Landscape background',
                  'background_image_url':
                      'https://cdn.example.com/background-landscape.png',
                  'canvas_width': 1792,
                  'canvas_height': 1024,
                },
                <String, dynamic>{
                  'objectid': 8,
                  'name': 'Portrait background',
                  'background_image_url':
                      'https://cdn.example.com/background-portrait.png',
                  'canvas_width': 1024,
                  'canvas_height': 1365,
                },
              ],
            },
          ],
          'props': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 601,
              'orderno': 1,
              'prop': <String, dynamic>{
                'objectid': 12,
                'name': 'Prototype table',
                'image_url': 'https://cdn.example.com/prop-table.png',
              },
            },
          ],
          'cast': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 701,
              'orderno': 2,
              'character': <String, dynamic>{'objectid': 3, 'name': 'Sofia'},
              'pose_layer': <String, dynamic>{
                'objectid': 31,
                'name': 'sofia-neutral-standing',
                'generated_image_url':
                    'https://cdn.example.com/sofia-neutral.png',
              },
              'portrait_layout_json':
                  '{&quot;x&quot;:0.63,&quot;y&quot;:0.57,'
                  '&quot;scale&quot;:1.15,&quot;flip_x&quot;:true}',
            },
          ],
          'decisions': <Map<String, dynamic>>[],
        },
      );

      expect(
        scene
            .viewportFor(EcoUnityComicViewportKind.landscape)
            ?.backgroundImage
            ?.url,
        'https://cdn.example.com/background-landscape.png',
      );
      expect(
        scene
            .viewportFor(EcoUnityComicViewportKind.portrait)
            ?.backgroundImage
            ?.url,
        'https://cdn.example.com/background-portrait.png',
      );

      final List<EcoUnityComicDrawableLayer> layers = scene.drawableLayersFor(
        EcoUnityComicViewportKind.portrait,
      );

      expect(
        layers.map((EcoUnityComicDrawableLayer layer) => layer.media?.url),
        containsAll(<String>[
          'https://cdn.example.com/prop-table.png',
          'https://cdn.example.com/sofia-neutral.png',
        ]),
      );
      expect(
        scene.cast.single.layoutFor(EcoUnityComicViewportKind.portrait).flipX,
        isTrue,
      );
    });

    test('builds dialogue timeline with ready audio and text fallback', () {
      final EcoUnityComicScene startScene = EcoUnityComic.fromJson(
        _comicActivityFixture(),
      ).startScene!;

      final List<EcoUnityComicTimelineEntry> timeline = startScene
          .dialogueTimeline('en');

      expect(timeline.map((entry) => entry.dialogue.dialogue), <String>[
        'Text fallback line',
        'Ready audio line',
      ]);
      expect(timeline.first.startMs, 100);
      expect(timeline.first.hasReadyAudio, isFalse);
      expect(timeline.last.startMs, 700);
      expect(timeline.last.hasReadyAudio, isTrue);
    });

    test('clamps layout values and tolerates invalid layout JSON', () {
      final EcoUnityComicLayout layout = EcoUnityComicLayout.fromJson(
        '{"x":1.5,"y":-0.25,"scale":5,"bubble_x":1.25,'
        '"bubble_y":-1,"rotation":12,"flip_x":"true","z_index":"12"}',
      );

      expect(layout.x, 1);
      expect(layout.y, 0);
      expect(layout.scale, 4);
      expect(layout.bubbleX, 1);
      expect(layout.bubbleY, 0);
      expect(layout.rotation, 12);
      expect(layout.flipX, isTrue);
      expect(layout.zIndex, 12);

      final EcoUnityComicLayout fallback = EcoUnityComicLayout.fromJson(
        'not json',
      );
      expect(fallback.x, EcoUnityComicLayout.defaults.x);
      expect(fallback.y, EcoUnityComicLayout.defaults.y);
    });
  });
}

Map<String, dynamic> _sdgModuleFixture() {
  return <String, dynamic>{
    'id': 12,
    'sdg_number': 12,
    'slug': 'responsible-consumption',
    'title': <String, dynamic>{'en': 'Responsible Consumption'},
    'introduction': <String, dynamic>{
      'en': 'Explore everyday choices that reduce waste.',
    },
    'learning_objective_en': 'Explain how reuse reduces resource pressure.',
    'estimated_minutes': '25',
    'difficulty': 'starter',
    'content_status': 'published',
    'activities': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 103,
        'module': <String, dynamic>{'id': 12},
        'sdg_number': 12,
        'slug': 'check-understanding',
        'activity_type': 'quiz',
        'flow_stage': 'reflect',
        'orderno': 30,
        'title': <String, dynamic>{'en': 'Check understanding'},
        'completion_required': true,
        'passing_logic': 'minimum_score',
        'minimum_score': 2,
        'questions': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 502,
            'activity': <String, dynamic>{
              'data': <String, dynamic>{'id': 103},
            },
            'orderno': 2,
            'question_type': 'single_choice',
            'prompt': <String, dynamic>{'en': 'Which action helps most?'},
            'options_json': jsonEncode(<Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'repair',
                'label': <String, dynamic>{'en': 'Repair before replacing'},
              },
              <String, dynamic>{
                'id': 'replace',
                'label': <String, dynamic>{'en': 'Replace immediately'},
              },
            ]),
            'correct_answers_json': jsonEncode(<String>['repair']),
            'points': 1,
            'required': true,
            'content_status': 'published',
          },
          <String, dynamic>{
            'id': 501,
            'activity': 103,
            'orderno': 1,
            'question_type': 'single_choice',
            'prompt': <String, dynamic>{'en': 'What is a circular habit?'},
            'options_json': jsonEncode(<Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'reuse',
                'label': <String, dynamic>{'en': 'Reuse or repair items'},
              },
              <String, dynamic>{
                'id': 'disposable',
                'label': <String, dynamic>{'en': 'Buy disposable items'},
              },
            ]),
            'correct_answers_json': jsonEncode(<String>['reuse']),
            'points': 2,
            'required': true,
            'content_status': 'published',
          },
        ],
      },
      <String, dynamic>{
        'id': 101,
        'module': <String, dynamic>{
          'data': <String, dynamic>{'id': 12},
        },
        'sdg_number': 12,
        'slug': 'intro-comic',
        'activity_type': 'comic',
        'flow_stage': 'discover',
        'orderno': 10,
        'title_en': 'A day of choices',
        'completion_required': true,
        'content_status': 'published',
      },
      <String, dynamic>{
        'id': 102,
        'module': 12,
        'sdg_number': 12,
        'slug': 'everyday-choices',
        'activity_type': 'mlr',
        'flow_stage': 'learn',
        'orderno': 20,
        'title': <String, dynamic>{'en': 'Everyday choices'},
        'body': <String, dynamic>{
          'en': '<p>Small habits matter when they become shared.</p>',
        },
        'completion_required': true,
        'content_status': 'published',
      },
    ],
  };
}

Map<String, dynamic> _comicActivityFixture() {
  return <String, dynamic>{
    'id': 201,
    'module': <String, dynamic>{
      'data': <String, dynamic>{'id': 12},
    },
    'sdg_number': 12,
    'slug': 'branching-comic',
    'activity_type': 'comic',
    'flow_stage': 'discover',
    'orderno': 1,
    'title': <String, dynamic>{'en': 'A day of choices'},
    'completion_required': true,
    'content_status': 'published',
    'comic_scenes': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 301,
        'scene_key': 'start',
        'orderno': 1,
        'title': <String, dynamic>{'en': 'Kitchen'},
        'backgrounds': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 401,
            'category': 'home',
            'title': 'Kitchen background',
            'background_alt_text': <String, dynamic>{'en': 'A bright kitchen'},
            'viewports': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 501,
                'viewport': 'portrait',
                'background_image': <String, dynamic>{
                  'url':
                      'https://cdn.example.com/backgrounds/kitchen-portrait.png',
                },
                'canvas_width': 1024,
                'canvas_height': 1365,
                'generation_status': 'ready',
                'content_status': 'published',
              },
            ],
          },
        ],
        'props': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 601,
            'orderno': 2,
            'z_index': 20,
            'prop': <String, dynamic>{
              'slug': 'recycling-bin',
              'name': <String, dynamic>{'en': 'Recycling bin'},
              'image': <String, dynamic>{
                'url': 'https://cdn.example.com/props/recycling-bin.png',
              },
              'alt_text': <String, dynamic>{'en': 'A recycling bin'},
            },
            'portrait_layout_json': <String, dynamic>{
              'x': 0.2,
              'y': 0.8,
              'scale': 0.7,
              'z_index': 5,
            },
            'landscape_layout_json': <String, dynamic>{
              'x': 0.2,
              'y': 0.8,
              'scale': 0.7,
            },
          },
        ],
        'cast': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 701,
            'orderno': 1,
            'z_index': 10,
            'character': <String, dynamic>{
              'slug': 'aada',
              'name': <String, dynamic>{'en': 'Aada'},
            },
            'pose_layer': <String, dynamic>{
              'slug': 'aada-happy',
              'generated_image': <String, dynamic>{
                'url': 'https://cdn.example.com/characters/aada-happy.png',
              },
              'alt_text': <String, dynamic>{'en': 'Aada smiling'},
              'generation_status': 'ready',
            },
            'portrait_layout_json': jsonEncode(<String, dynamic>{
              'x': 0.45,
              'y': 0.72,
              'scale': 1.1,
              'bubble_x': 0.32,
              'bubble_y': 0.18,
              'z_index': 30,
            }),
            'landscape_layout_json': <String, dynamic>{
              'x': 0.5,
              'y': 0.5,
              'scale': 1,
            },
            'dialogue_entries': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 801,
                'orderno': 2,
                'dialogue': <String, dynamic>{'en': 'Ready audio line'},
                'speech_items': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 901,
                    'language': 'en',
                    'audio_file': <String, dynamic>{
                      'url': 'https://cdn.example.com/audio/ready-line.mp3',
                    },
                    'start_ms': 700,
                    'duration_ms': 1300,
                    'orderno': 1,
                    'generation_status': 'ready',
                  },
                ],
              },
              <String, dynamic>{
                'id': 802,
                'orderno': 1,
                'dialogue': <String, dynamic>{'en': 'Text fallback line'},
                'speech_items': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 902,
                    'language': 'en',
                    'audio_file': <String, dynamic>{
                      'url': 'https://cdn.example.com/audio/not-ready.mp3',
                    },
                    'start_ms': 100,
                    'duration_ms': 900,
                    'orderno': 1,
                    'generation_status': 'queued',
                  },
                ],
              },
            ],
          },
        ],
        'decisions': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 1001,
            'orderno': 1,
            'label': <String, dynamic>{'en': 'Choose reusable bottle'},
            'target_scene_key': 'reuse',
            'choice_image': <String, dynamic>{
              'url': 'https://cdn.example.com/choices/reuse.png',
            },
            'portrait_layout_json': <String, dynamic>{
              'x': 0.5,
              'y': 0.9,
              'scale': 0.8,
            },
            'landscape_layout_json': <String, dynamic>{
              'x': 0.8,
              'y': 0.6,
              'scale': 0.8,
            },
            'z_index': 80,
          },
        ],
      },
      <String, dynamic>{
        'id': 302,
        'scene_key': 'reuse',
        'orderno': 2,
        'title': <String, dynamic>{'en': 'Reuse branch'},
        'backgrounds': <Map<String, dynamic>>[],
        'cast': <Map<String, dynamic>>[],
        'props': <Map<String, dynamic>>[],
        'decisions': <Map<String, dynamic>>[],
      },
    ],
  };
}
