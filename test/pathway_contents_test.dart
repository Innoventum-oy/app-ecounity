import 'package:core/core.dart' as core;
import 'package:flutter_test/flutter_test.dart';

import 'package:ecounity/src/objects/pathway.dart';

void main() {
  test(
    'replaceImageTokens injects image tags and removes unmatched placeholders',
    () {
      final core.ImageObject imageWithUrl = core.ImageObject(
        data: {'imageurl': 'https://cdn.example.com/1.png'},
      );
      final core.ImageObject imageMissingUrl = core.ImageObject(
        data: {'imageurl': null},
      );

      const String source = '''
      <p>%image.1%</p>
      <p>%image.2%</p>
      <p>ignored %image.3% token</p>
    ''';

      final String transformed = replaceImageTokens(source, [
        imageWithUrl,
        imageMissingUrl,
      ]);

      expect(transformed, contains('<img src="https://cdn.example.com/1.png"'));
      expect(transformed, isNot(contains('%image.1%')));
      expect(transformed, isNot(contains('%image.2%')));
      expect(transformed, isNot(contains('%image.3%')));
    },
  );
}
