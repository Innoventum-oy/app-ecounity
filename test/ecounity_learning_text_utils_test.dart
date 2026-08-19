import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_text_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ecoUnityPlainText', () {
    test('extracts readable card copy from CMS HTML', () {
      final String text = ecoUnityPlainText(
        '<p>Use <strong>less</strong> water &amp; energy.</p>'
        '<ul><li>Repair first</li><li>Share items</li></ul>',
      );

      expect(text, 'Use less water & energy. Repair first Share items');
    });

    test('keeps non-HTML comparison text intact', () {
      expect(ecoUnityPlainText('2 < 3 > 1'), '2 < 3 > 1');
      expect(ecoUnityLooksLikeHtml('2 < 3 > 1'), isFalse);
    });

    test('truncates at a readable word boundary', () {
      expect(
        ecoUnityPlainText(
          'Responsible choices reduce waste and save resources',
          maxLength: 33,
        ),
        'Responsible choices reduce...',
      );
    });
  });

  group('ecoUnityReplaceMediaImageTokens', () {
    test('injects learning activity media images and removes stale tokens', () {
      final List<EcoUnityMedia> images = <EcoUnityMedia>[
        const EcoUnityMedia(
          id: 1,
          url: 'https://cdn.example.com/reuse.png',
          title: 'Reuse diagram',
          altText: 'Students reusing materials',
          rawData: <String, dynamic>{},
        ),
        const EcoUnityMedia(
          id: 2,
          url: null,
          title: 'Missing',
          altText: '',
          rawData: <String, dynamic>{},
        ),
      ];

      final String transformed = ecoUnityReplaceMediaImageTokens(
        '<p>%image.1%</p><p>%image.2%</p><p>%image.3%</p>',
        images,
      );

      expect(
        transformed,
        contains('src="https:&#47;&#47;cdn.example.com&#47;reuse.png"'),
      );
      expect(transformed, contains('alt="Students reusing materials"'));
      expect(transformed, isNot(contains('%image.1%')));
      expect(transformed, isNot(contains('%image.2%')));
      expect(transformed, isNot(contains('%image.3%')));
    });
  });
}
