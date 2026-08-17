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
}
