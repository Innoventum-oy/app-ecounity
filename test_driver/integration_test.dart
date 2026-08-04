import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final String outputRoot =
      Platform.environment['SCREENSHOT_OUTPUT_DIR'] ??
      'build/fastlane/raw/unknown';
  final String locale = Platform.environment['SCREENSHOT_LOCALE'] ?? 'en';

  await integrationDriver(
    onScreenshot:
        (
          String screenshotName,
          List<int> screenshotBytes, [
          Map<String, Object?>? args,
        ]) async {
          final String screenshotLocale = args?['locale']?.toString() ?? locale;
          final Directory outputDirectory = Directory(
            '$outputRoot/$screenshotLocale',
          )..createSync(recursive: true);
          final File image = File(
            '${outputDirectory.path}/$screenshotName.png',
          );
          image.writeAsBytesSync(screenshotBytes);
          return true;
        },
  );
}
