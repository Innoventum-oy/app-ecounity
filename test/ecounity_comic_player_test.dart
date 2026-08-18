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
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
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
      ),
    );

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

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Second line'), findsOneWidget);
    expect(readySpeechItems.single.audioFile?.url, endsWith('second.mp3'));

    await tester.tap(find.text('Choices'));
    await tester.pump();

    expect(find.text('Pick reuse'), findsOneWidget);

    await tester.tap(find.text('Pick reuse'));
    await tester.pump();

    expect(find.text('Branch line'), findsOneWidget);

    await tester.tap(find.text('Complete'));
    await tester.pump();

    expect(completed, isTrue);
  });

  testWidgets('plays timeline cues from the playback button', (
    WidgetTester tester,
  ) async {
    final EcoUnityComic comic = EcoUnityComic.fromJson(_comicFixture());
    final List<EcoUnityComicSpeechItem> readySpeechItems =
        <EcoUnityComicSpeechItem>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 375,
            height: 720,
            child: EcoUnityComicPlayer(
              comic: comic,
              imageBuilder: _testImageBuilder,
              onReadySpeech: readySpeechItems.add,
            ),
          ),
        ),
      ),
    );

    expect(find.text('First line'), findsOneWidget);
    expect(find.byTooltip('Play'), findsOneWidget);

    await tester.tap(find.byTooltip('Play'));
    await tester.pump();

    expect(find.byTooltip('Stop'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Second line'), findsOneWidget);
    expect(readySpeechItems.single.audioFile?.url, endsWith('second.mp3'));

    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.byTooltip('Play'), findsOneWidget);
    expect(find.text('Pick reuse'), findsOneWidget);
  });

  testWidgets('shows full scene dialogue in a transcript dialog', (
    WidgetTester tester,
  ) async {
    final EcoUnityComic comic = EcoUnityComic.fromJson(_comicFixture());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 375,
            height: 720,
            child: EcoUnityComicPlayer(
              comic: comic,
              imageBuilder: _testImageBuilder,
            ),
          ),
        ),
      ),
    );

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

  testWidgets('uses backend editor layer scale proportions', (
    WidgetTester tester,
  ) async {
    final EcoUnityComic comic = EcoUnityComic.fromJson(
      _comicFixtureWithScaledTable(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 375,
            height: 720,
            child: EcoUnityComicPlayer(
              comic: comic,
              imageBuilder: _testImageBuilder,
            ),
          ),
        ),
      ),
    );

    final Size propSize = tester.getSize(
      find.byKey(const ValueKey<String>('comic-layer-prop-501')),
    );
    final Size characterSize = tester.getSize(
      find.byKey(const ValueKey<String>('comic-layer-character-601')),
    );

    expect(propSize.width, greaterThan(characterSize.width * 1.4));
  });
}

Widget _testImageBuilder(
  BuildContext context,
  EcoUnityMedia? media,
  String altText,
  BoxFit fit,
) {
  return ColoredBox(
    key: ValueKey<String>('image:${media?.url ?? altText}'),
    color: Colors.green.shade100,
  );
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
