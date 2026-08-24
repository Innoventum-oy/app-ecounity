import 'dart:async';

import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/widgets/ecounity_comic_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('steps dialogue, cues ready audio, branches, and completes', (
    WidgetTester tester,
  ) async {
    final EcoUnityComic comic = EcoUnityComic.fromJson(_comicFixture());
    final List<EcoUnityComicSpeechItem> readySpeechItems =
        <EcoUnityComicSpeechItem>[];
    bool completed = false;

    await tester.pumpWidget(
      _comicTestHarness(
        SizedBox(
          width: 375,
          height: 720,
          child: EcoUnityComicPlayer(
            comic: comic,
            imageBuilder: _testImageBuilder,
            onReadySpeech: readySpeechItems.add,
            onCompleted: () {
              completed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Loading scene...'), findsWidgets);
    expect(find.text('First line'), findsNothing);

    await _pumpThroughSceneReveal(tester);

    expect(
      find.text('First line'),
      findsOneWidget,
      reason: tester
          .widgetList<Text>(find.byType(Text))
          .map((Text widget) => widget.data)
          .toList()
          .toString(),
    );
    expect(find.text('1 / 2'), findsOneWidget);
    expect(readySpeechItems, isEmpty);

    await tester.tap(find.byTooltip('Stop'));
    await tester.pump();

    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Second line'), findsOneWidget);
    expect(readySpeechItems.single.audioFile?.url, endsWith('second.mp3'));
    expect(find.text('Pick reuse'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('comic-layer-decision-901')),
      findsOneWidget,
    );
    expect(find.widgetWithText(ElevatedButton, 'Pick reuse'), findsNothing);

    await tester.tap(find.text('Pick reuse'));
    await tester.pump();
    await _pumpThroughSceneReveal(tester);

    expect(find.text('Branch line'), findsOneWidget);

    await tester.tap(find.byTooltip('Stop'));
    await tester.pump();

    await tester.tap(find.text('Complete'));
    await tester.pump();

    expect(completed, isTrue);
  });

  testWidgets('autoplays timeline cues after scene reveal', (
    WidgetTester tester,
  ) async {
    final EcoUnityComic comic = EcoUnityComic.fromJson(_comicFixture());
    final List<EcoUnityComicSpeechItem> readySpeechItems =
        <EcoUnityComicSpeechItem>[];

    await tester.pumpWidget(
      _comicTestHarness(
        SizedBox(
          width: 375,
          height: 720,
          child: EcoUnityComicPlayer(
            comic: comic,
            imageBuilder: _testImageBuilder,
            onReadySpeech: readySpeechItems.add,
          ),
        ),
      ),
    );

    expect(find.text('First line'), findsNothing);
    await _pumpThroughSceneReveal(tester);
    expect(find.text('First line'), findsOneWidget);
    expect(find.byTooltip('Stop'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Second line'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
    expect(readySpeechItems.single.audioFile?.url, endsWith('second.mp3'));
    expect(find.text('Choices'), findsNothing);
    expect(find.text('Pick reuse'), findsNothing);

    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.byTooltip('Play'), findsOneWidget);
    expect(find.text('Choices'), findsNothing);
    expect(find.text('Pick reuse'), findsOneWidget);
  });

  testWidgets(
    'spaces duplicate timeline starts so earlier bubbles are visible',
    (WidgetTester tester) async {
      final EcoUnityComic comic = EcoUnityComic.fromJson(
        _comicFixtureWithDuplicateTimelineStarts(),
      );

      await tester.pumpWidget(
        _comicTestHarness(
          SizedBox(
            width: 375,
            height: 720,
            child: EcoUnityComicPlayer(
              comic: comic,
              imageBuilder: _testImageBuilder,
            ),
          ),
        ),
      );

      await _pumpThroughSceneReveal(tester);

      expect(find.text('First line'), findsOneWidget);
      expect(find.text('Second line'), findsNothing);

      await tester.pump(const Duration(milliseconds: 720));
      await tester.pump();

      expect(find.text('Second line'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 320));

      expect(find.text('First line'), findsNothing);
      expect(find.text('Second line'), findsOneWidget);
    },
  );

  testWidgets('waits for speech preparation before revealing and autoplaying', (
    WidgetTester tester,
  ) async {
    final EcoUnityComic comic = EcoUnityComic.fromJson(_comicFixture());
    final Completer<void> speechPrepared = Completer<void>();
    final List<EcoUnityComicSpeechItem> preparedSpeechItems =
        <EcoUnityComicSpeechItem>[];

    await tester.pumpWidget(
      _comicTestHarness(
        SizedBox(
          width: 375,
          height: 720,
          child: EcoUnityComicPlayer(
            comic: comic,
            imageBuilder: _testImageBuilder,
            onPrepareSpeech: (List<EcoUnityComicSpeechItem> speechItems) {
              preparedSpeechItems.addAll(speechItems);
              return speechPrepared.future;
            },
          ),
        ),
      ),
    );

    await _pumpThroughSceneReveal(tester);
    await tester.pump(const Duration(milliseconds: 600));

    expect(preparedSpeechItems, hasLength(1));
    expect(preparedSpeechItems.single.audioFile?.url, endsWith('second.mp3'));
    expect(find.text('Loading scene...'), findsWidgets);
    expect(find.text('First line'), findsNothing);
    expect(find.byTooltip('Stop'), findsNothing);

    speechPrepared.complete();
    await tester.pump();
    await _pumpThroughSceneReveal(tester);

    expect(find.text('First line'), findsOneWidget);
    expect(find.byTooltip('Stop'), findsOneWidget);
  });

  testWidgets('does not autoplay current scene again when more scenes load', (
    WidgetTester tester,
  ) async {
    final EcoUnityComic initialComic = EcoUnityComic.fromJson(
      _comicFixtureWithOnlyStartScene(),
    );
    final EcoUnityComic fullComic = EcoUnityComic.fromJson(_comicFixture());
    final List<EcoUnityComicSpeechItem> readySpeechItems =
        <EcoUnityComicSpeechItem>[];

    await tester.pumpWidget(
      _comicTestHarness(
        SizedBox(
          width: 375,
          height: 720,
          child: EcoUnityComicPlayer(
            comic: initialComic,
            imageBuilder: _testImageBuilder,
            loadingAdditionalScenes: true,
            onReadySpeech: readySpeechItems.add,
          ),
        ),
      ),
    );

    await _pumpThroughSceneReveal(tester);
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump();

    expect(find.text('Pick reuse'), findsOneWidget);
    expect(find.byTooltip('Play'), findsOneWidget);
    expect(readySpeechItems, hasLength(1));

    await tester.pumpWidget(
      _comicTestHarness(
        SizedBox(
          width: 375,
          height: 720,
          child: EcoUnityComicPlayer(
            comic: fullComic,
            imageBuilder: _testImageBuilder,
            loadingAdditionalScenes: false,
            onReadySpeech: readySpeechItems.add,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.text('Pick reuse'), findsOneWidget);
    expect(find.byTooltip('Play'), findsOneWidget);
    expect(readySpeechItems, hasLength(1));
  });

  testWidgets('renders image-backed decisions as canvas hotspots', (
    WidgetTester tester,
  ) async {
    final EcoUnityComic comic = EcoUnityComic.fromJson(
      _comicFixtureWithVisualDecision(),
    );

    await tester.pumpWidget(
      _comicTestHarness(
        SizedBox(
          width: 375,
          height: 720,
          child: EcoUnityComicPlayer(
            comic: comic,
            imageBuilder: _testImageBuilder,
          ),
        ),
      ),
    );

    await _pumpThroughSceneReveal(tester);
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump();

    expect(
      find.byKey(
        const ValueKey<String>(
          'image:https://cdn.example.com/reuse-choice.png',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Pick reuse'), findsOneWidget);

    await tester.tap(find.text('Pick reuse'));
    await tester.pump();
    await _pumpThroughSceneReveal(tester);

    expect(find.text('Branch line'), findsOneWidget);
  });

  testWidgets('waits for scene images before revealing and autoplaying', (
    WidgetTester tester,
  ) async {
    final EcoUnityComic comic = EcoUnityComic.fromJson(_comicFixture());
    final _DeferredComicImageBuilder imageBuilder =
        _DeferredComicImageBuilder();
    final List<EcoUnityComicSpeechItem> readySpeechItems =
        <EcoUnityComicSpeechItem>[];

    await tester.pumpWidget(
      _comicTestHarness(
        SizedBox(
          width: 375,
          height: 720,
          child: EcoUnityComicPlayer(
            comic: comic,
            imageBuilder: imageBuilder.call,
            onReadySpeech: readySpeechItems.add,
          ),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Loading scene...'), findsWidgets);
    expect(find.text('First line'), findsNothing);
    expect(readySpeechItems, isEmpty);

    imageBuilder.markAllReady();
    await _pumpThroughSceneReveal(tester);

    expect(find.text('First line'), findsOneWidget);
    expect(find.byTooltip('Stop'), findsOneWidget);
    expect(readySpeechItems, isEmpty);
  });

  testWidgets('resets scene image readiness after branching', (
    WidgetTester tester,
  ) async {
    final EcoUnityComic comic = EcoUnityComic.fromJson(_comicFixture());
    final _DeferredComicImageBuilder imageBuilder =
        _DeferredComicImageBuilder();

    await tester.pumpWidget(
      _comicTestHarness(
        SizedBox(
          width: 375,
          height: 720,
          child: EcoUnityComicPlayer(
            comic: comic,
            imageBuilder: imageBuilder.call,
          ),
        ),
      ),
    );

    imageBuilder.markAllReady();
    await _pumpThroughSceneReveal(tester);

    await tester.tap(find.byTooltip('Stop'));
    await tester.pump();

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.tap(find.text('Pick reuse'));
    await tester.pump();

    expect(find.text('Loading scene...'), findsWidgets);
    expect(find.text('Branch line'), findsNothing);

    imageBuilder.markAllReady();
    await _pumpThroughSceneReveal(tester);

    expect(find.text('Branch line'), findsOneWidget);
  });

  testWidgets('shows full scene dialogue in a transcript dialog', (
    WidgetTester tester,
  ) async {
    final EcoUnityComic comic = EcoUnityComic.fromJson(_comicFixture());

    await tester.pumpWidget(
      _comicTestHarness(
        SizedBox(
          width: 375,
          height: 720,
          child: EcoUnityComicPlayer(
            comic: comic,
            imageBuilder: _testImageBuilder,
          ),
        ),
      ),
    );

    await _pumpThroughSceneReveal(tester);

    await tester.tap(find.byTooltip('View dialogue'));
    await tester.pumpAndSettle();

    final Finder dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.text('Start')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('First line')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('Second line')),
      findsOneWidget,
    );

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(dialog, findsNothing);
  });

  testWidgets('shows scene narration below the canvas and updates on branch', (
    WidgetTester tester,
  ) async {
    final EcoUnityComic comic = EcoUnityComic.fromJson(
      _comicFixtureWithNarration(),
    );

    await tester.pumpWidget(
      _comicTestHarness(
        SizedBox(
          width: 375,
          height: 720,
          child: EcoUnityComicPlayer(
            comic: comic,
            imageBuilder: _testImageBuilder,
          ),
        ),
      ),
    );

    expect(find.text('Narration'), findsNothing);
    expect(
      find.text('Aada notices an everyday choice waiting in the classroom.'),
      findsOneWidget,
    );

    await _pumpThroughSceneReveal(tester);
    await tester.tap(find.byTooltip('Stop'));
    await tester.pump();

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.tap(find.text('Pick reuse'));
    await tester.pump();
    await _pumpThroughSceneReveal(tester);

    expect(
      find.text('Aada notices an everyday choice waiting in the classroom.'),
      findsNothing,
    );
    expect(
      find.text('The reuse path shows how one small action changes the story.'),
      findsOneWidget,
    );
  });

  testWidgets('uses backend editor layer scale proportions', (
    WidgetTester tester,
  ) async {
    final EcoUnityComic comic = EcoUnityComic.fromJson(
      _comicFixtureWithScaledTable(),
    );

    await tester.pumpWidget(
      _comicTestHarness(
        SizedBox(
          width: 375,
          height: 720,
          child: EcoUnityComicPlayer(
            comic: comic,
            imageBuilder: _testImageBuilder,
          ),
        ),
      ),
    );

    await _pumpThroughSceneReveal(tester);

    final Size propSize = tester.getSize(
      find.byKey(const ValueKey<String>('comic-layer-prop-501')),
    );
    final Size characterSize = tester.getSize(
      find.byKey(const ValueKey<String>('comic-layer-character-601')),
    );

    expect(propSize.width, greaterThan(characterSize.width * 1.4));
  });

  testWidgets('uses portrait viewport from portrait media size', (
    WidgetTester tester,
  ) async {
    final EcoUnityComic comic = EcoUnityComic.fromJson(
      _comicFixtureWithBothViewports(),
    );

    await tester.pumpWidget(
      _comicTestHarness(
        SizedBox(
          width: 375,
          height: 260,
          child: EcoUnityComicPlayer(
            comic: comic,
            imageBuilder: _testImageBuilder,
          ),
        ),
      ),
    );

    expect(
      find.byKey(
        const ValueKey<String>('image:https://cdn.example.com/bg-portrait.png'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>(
          'image:https://cdn.example.com/bg-landscape.png',
        ),
      ),
      findsNothing,
    );
  });

  testWidgets('keeps scaled layer proportions after branching scenes', (
    WidgetTester tester,
  ) async {
    final EcoUnityComic comic = EcoUnityComic.fromJson(
      _comicFixtureWithScaledSecondScene(),
    );

    await tester.pumpWidget(
      _comicTestHarness(
        SizedBox(
          width: 375,
          height: 720,
          child: EcoUnityComicPlayer(
            comic: comic,
            imageBuilder: _testImageBuilder,
          ),
        ),
      ),
    );

    await _pumpThroughSceneReveal(tester);
    await tester.tap(find.byTooltip('Stop'));
    await tester.pump();

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.tap(find.text('Pick reuse'));
    await tester.pump();
    await _pumpThroughSceneReveal(tester);

    final Size propSize = tester.getSize(
      find.byKey(const ValueKey<String>('comic-layer-prop-502')),
    );
    final Size characterSize = tester.getSize(
      find.byKey(const ValueKey<String>('comic-layer-character-602')),
    );

    expect(propSize.width, greaterThan(characterSize.width * 1.4));
  });
}

Future<void> _pumpThroughSceneReveal(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pump();
}

Widget _comicTestHarness(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: const <Locale>[Locale('en')],
    home: MediaQuery(
      data: const MediaQueryData(size: Size(375, 812)),
      child: Scaffold(body: child),
    ),
  );
}

Widget _testImageBuilder(
  BuildContext context,
  EcoUnityMedia? media,
  String altText,
  BoxFit fit, {
  VoidCallback? onReady,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    onReady?.call();
  });
  return ColoredBox(
    key: ValueKey<String>('image:${media?.url ?? altText}'),
    color: Colors.green.shade100,
  );
}

class _DeferredComicImageBuilder {
  final List<VoidCallback> _pendingCallbacks = <VoidCallback>[];

  Widget call(
    BuildContext context,
    EcoUnityMedia? media,
    String altText,
    BoxFit fit, {
    VoidCallback? onReady,
  }) {
    if (onReady != null) {
      _pendingCallbacks.add(onReady);
    }
    return ColoredBox(
      key: ValueKey<String>('image:${media?.url ?? altText}'),
      color: Colors.green.shade100,
    );
  }

  void markAllReady() {
    final List<VoidCallback> callbacks = List<VoidCallback>.from(
      _pendingCallbacks,
    );
    _pendingCallbacks.clear();
    for (final VoidCallback callback in callbacks) {
      callback();
    }
  }
}

Map<String, dynamic> _comicFixture() {
  return <String, dynamic>{
    'id': 201,
    'module': <String, dynamic>{'id': 12},
    'sdg_number': 12,
    'slug': 'comic',
    'activity_type': 'comic',
    'flow_stage': 'discover',
    'orderno': 10,
    'title': <String, dynamic>{'en': 'Comic'},
    'comic_scenes': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 301,
        'scene_key': 'start',
        'orderno': 1,
        'title': <String, dynamic>{'en': 'Start'},
        'backgrounds': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 401,
            'viewports': <Map<String, dynamic>>[
              <String, dynamic>{
                'viewport': 'portrait',
                'background_image': <String, dynamic>{
                  'url': 'https://cdn.example.com/bg.png',
                },
                'canvas_width': 1024,
                'canvas_height': 1365,
              },
            ],
          },
        ],
        'props': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 501,
            'orderno': 1,
            'prop': <String, dynamic>{
              'slug': 'bottle',
              'name': <String, dynamic>{'en': 'Bottle'},
              'image': <String, dynamic>{
                'url': 'https://cdn.example.com/bottle.png',
              },
            },
            'portrait_layout_json': <String, dynamic>{
              'x': 0.2,
              'y': 0.8,
              'scale': 0.6,
            },
          },
        ],
        'cast': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 601,
            'orderno': 1,
            'character': <String, dynamic>{
              'slug': 'aada',
              'name': <String, dynamic>{'en': 'Aada'},
            },
            'pose_layer': <String, dynamic>{
              'slug': 'aada-neutral',
              'generated_image': <String, dynamic>{
                'url': 'https://cdn.example.com/aada.png',
              },
            },
            'portrait_layout_json': <String, dynamic>{
              'x': 0.48,
              'y': 0.7,
              'scale': 1,
              'bubble_x': 0.5,
              'bubble_y': 0.12,
            },
            'dialogue_entries': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 701,
                'orderno': 1,
                'dialogue': <String, dynamic>{'en': 'First line'},
                'speech_items': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 800,
                    'language': 'en',
                    'start_ms': 0,
                    'duration_ms': 900,
                    'generation_status': 'queued',
                  },
                ],
              },
              <String, dynamic>{
                'id': 702,
                'orderno': 2,
                'dialogue': <String, dynamic>{'en': 'Second line'},
                'speech_items': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 801,
                    'language': 'en',
                    'audio_file': <String, dynamic>{
                      'url': 'https://cdn.example.com/second.mp3',
                    },
                    'start_ms': 500,
                    'duration_ms': 1200,
                    'generation_status': 'ready',
                  },
                ],
              },
            ],
          },
        ],
        'decisions': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 901,
            'orderno': 1,
            'label': <String, dynamic>{'en': 'Pick reuse'},
            'target_scene_key': 'reuse',
          },
        ],
      },
      <String, dynamic>{
        'id': 302,
        'scene_key': 'reuse',
        'orderno': 2,
        'title': <String, dynamic>{'en': 'Reuse'},
        'backgrounds': <Map<String, dynamic>>[],
        'props': <Map<String, dynamic>>[],
        'cast': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 602,
            'orderno': 1,
            'character': <String, dynamic>{
              'slug': 'aada',
              'name': <String, dynamic>{'en': 'Aada'},
            },
            'pose_layer': <String, dynamic>{
              'slug': 'aada-happy',
              'generated_image': <String, dynamic>{
                'url': 'https://cdn.example.com/aada-happy.png',
              },
            },
            'portrait_layout_json': <String, dynamic>{
              'x': 0.48,
              'y': 0.7,
              'scale': 1,
              'bubble_x': 0.5,
              'bubble_y': 0.12,
            },
            'dialogue_entries': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 703,
                'orderno': 1,
                'dialogue': <String, dynamic>{'en': 'Branch line'},
                'speech_items': <Map<String, dynamic>>[],
              },
            ],
          },
        ],
        'decisions': <Map<String, dynamic>>[],
      },
    ],
  };
}

Map<String, dynamic> _comicFixtureWithOnlyStartScene() {
  final Map<String, dynamic> data = _comicFixture();
  final List<Map<String, dynamic>> scenes =
      data['comic_scenes'] as List<Map<String, dynamic>>;
  data['comic_scenes'] = <Map<String, dynamic>>[scenes.first];
  return data;
}

Map<String, dynamic> _comicFixtureWithDuplicateTimelineStarts() {
  final Map<String, dynamic> data = _comicFixture();
  final List<Map<String, dynamic>> scenes =
      data['comic_scenes'] as List<Map<String, dynamic>>;
  final Map<String, dynamic> scene = scenes.first;
  final List<Map<String, dynamic>> cast =
      scene['cast'] as List<Map<String, dynamic>>;
  final List<Map<String, dynamic>> dialogueEntries =
      cast.first['dialogue_entries'] as List<Map<String, dynamic>>;
  final List<Map<String, dynamic>> secondSpeechItems =
      dialogueEntries[1]['speech_items'] as List<Map<String, dynamic>>;
  secondSpeechItems.first['start_ms'] = 0;
  return data;
}

Map<String, dynamic> _comicFixtureWithVisualDecision() {
  final Map<String, dynamic> data = _comicFixture();
  final List<Map<String, dynamic>> scenes =
      data['comic_scenes'] as List<Map<String, dynamic>>;
  final Map<String, dynamic> scene = scenes.first;
  final List<Map<String, dynamic>> decisions =
      scene['decisions'] as List<Map<String, dynamic>>;
  decisions.first['choice_image'] = <String, dynamic>{
    'url': 'https://cdn.example.com/reuse-choice.png',
  };
  decisions.first['portrait_layout_json'] = <String, dynamic>{
    'x': 0.5,
    'y': 0.8,
    'scale': 1.2,
  };
  return data;
}

Map<String, dynamic> _comicFixtureWithNarration() {
  final Map<String, dynamic> data = _comicFixture();
  final List<Map<String, dynamic>> scenes =
      data['comic_scenes'] as List<Map<String, dynamic>>;
  scenes.first['narration'] = <String, dynamic>{
    'en': 'Aada notices an everyday choice waiting in the classroom.',
  };
  scenes[1]['narration'] = <String, dynamic>{
    'en': 'The reuse path shows how one small action changes the story.',
  };
  return data;
}

Map<String, dynamic> _comicFixtureWithScaledTable() {
  final Map<String, dynamic> data = _comicFixture();
  final List<Map<String, dynamic>> scenes =
      data['comic_scenes'] as List<Map<String, dynamic>>;
  final Map<String, dynamic> scene = scenes.first;
  final List<Map<String, dynamic>> props =
      scene['props'] as List<Map<String, dynamic>>;
  final List<Map<String, dynamic>> cast =
      scene['cast'] as List<Map<String, dynamic>>;

  props.first['portrait_layout_json'] = <String, dynamic>{
    'x': 0.2,
    'y': 0.8,
    'scale': 2,
  };
  cast.first['portrait_layout_json'] = <String, dynamic>{
    'x': 0.48,
    'y': 0.7,
    'scale': 1.15,
    'bubble_x': 0.5,
    'bubble_y': 0.12,
  };

  return data;
}

Map<String, dynamic> _comicFixtureWithBothViewports() {
  final Map<String, dynamic> data = _comicFixture();
  final List<Map<String, dynamic>> scenes =
      data['comic_scenes'] as List<Map<String, dynamic>>;
  final Map<String, dynamic> scene = scenes.first;
  final List<Map<String, dynamic>> backgrounds =
      scene['backgrounds'] as List<Map<String, dynamic>>;
  final Map<String, dynamic> background = backgrounds.first;
  background['viewports'] = <Map<String, dynamic>>[
    <String, dynamic>{
      'viewport': 'portrait',
      'background_image': <String, dynamic>{
        'url': 'https://cdn.example.com/bg-portrait.png',
      },
      'canvas_width': 1024,
      'canvas_height': 1365,
    },
    <String, dynamic>{
      'viewport': 'landscape',
      'background_image': <String, dynamic>{
        'url': 'https://cdn.example.com/bg-landscape.png',
      },
      'canvas_width': 1365,
      'canvas_height': 1024,
    },
  ];
  return data;
}

Map<String, dynamic> _comicFixtureWithScaledSecondScene() {
  final Map<String, dynamic> data = _comicFixture();
  final List<Map<String, dynamic>> scenes =
      data['comic_scenes'] as List<Map<String, dynamic>>;
  final Map<String, dynamic> secondScene = scenes[1];
  secondScene['props'] = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 502,
      'orderno': 1,
      'prop': <String, dynamic>{
        'slug': 'table',
        'name': <String, dynamic>{'en': 'Table'},
        'image': <String, dynamic>{'url': 'https://cdn.example.com/table.png'},
      },
      'portrait_layout_json': <String, dynamic>{
        'x': 0.48,
        'y': 0.78,
        'scale': 2,
      },
    },
  ];

  final List<Map<String, dynamic>> cast =
      secondScene['cast'] as List<Map<String, dynamic>>;
  cast.first['portrait_layout_json'] = <String, dynamic>{
    'x': 0.48,
    'y': 0.62,
    'scale': 1.15,
    'bubble_x': 0.5,
    'bubble_y': 0.12,
  };

  return data;
}
