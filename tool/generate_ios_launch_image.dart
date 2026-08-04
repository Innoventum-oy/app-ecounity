import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const String defaultLogoPath = 'assets/images/ecounity-logo.png';
const String defaultOutputDir =
    'ios/Runner/Assets.xcassets/LaunchImage.imageset';

const List<LaunchImageSpec> launchImages = [
  LaunchImageSpec('LaunchImage.png', 168, 185),
  LaunchImageSpec('LaunchImage@2x.png', 336, 370),
  LaunchImageSpec('LaunchImage@3x.png', 504, 555),
];

void main(List<String> args) {
  final ParsedArgs parsedArgs = ParsedArgs.parse(args);
  final String logoPath = parsedArgs.value('logo') ?? defaultLogoPath;
  final String outputDir = parsedArgs.value('out-dir') ?? defaultOutputDir;

  final img.Image logo = _readPng(logoPath);
  Directory(outputDir).createSync(recursive: true);

  for (final LaunchImageSpec spec in launchImages) {
    final img.Image launchImage = _createLaunchImage(logo, spec);
    final String outputPath = '$outputDir/${spec.fileName}';
    File(outputPath).writeAsBytesSync(img.encodePng(launchImage, level: 6));
    stdout.writeln('Wrote $outputPath (${spec.width}x${spec.height})');
  }
}

img.Image _readPng(String path) {
  final File file = File(path);
  if (!file.existsSync()) {
    _fail('Logo file does not exist: $path');
  }

  final img.Image? decoded = img.decodePng(file.readAsBytesSync());
  if (decoded == null) {
    _fail('Could not decode $path as a PNG.');
  }

  return decoded;
}

img.Image _createLaunchImage(img.Image logo, LaunchImageSpec spec) {
  final img.Image canvas = img.Image(
    width: spec.width,
    height: spec.height,
    format: img.Format.uint8,
    numChannels: 3,
  );
  img.fill(canvas, color: img.ColorRgb8(255, 255, 255));

  final int logoSize = math.min(spec.width, spec.height);
  final img.Image resizedLogo = _resizeToFit(logo, logoSize);
  img.compositeImage(
    canvas,
    resizedLogo,
    dstX: (spec.width - resizedLogo.width) ~/ 2,
    dstY: (spec.height - resizedLogo.height) ~/ 2,
  );

  return canvas;
}

img.Image _resizeToFit(img.Image source, int maxSize) {
  final double scale = maxSize / math.max(source.width, source.height);
  final int width = (source.width * scale).round().clamp(1, maxSize);
  final int height = (source.height * scale).round().clamp(1, maxSize);

  return img.copyResize(
    source,
    width: width,
    height: height,
    interpolation: img.Interpolation.cubic,
  );
}

Never _fail(String message) {
  stderr.writeln(message);
  exitCode = 64;
  throw UsageException(message);
}

class LaunchImageSpec {
  final String fileName;
  final int width;
  final int height;

  const LaunchImageSpec(this.fileName, this.width, this.height);
}

class ParsedArgs {
  final Map<String, String> _values;

  ParsedArgs(this._values);

  factory ParsedArgs.parse(List<String> args) {
    final Map<String, String> values = {};
    for (int i = 0; i < args.length; i++) {
      final String arg = args[i];
      if (!arg.startsWith('--')) {
        throw UsageException('Unexpected positional argument "$arg".');
      }

      final int equalsIndex = arg.indexOf('=');
      if (equalsIndex > 0) {
        values[arg.substring(2, equalsIndex)] = arg.substring(equalsIndex + 1);
        continue;
      }

      final String name = arg.substring(2);
      if (i + 1 >= args.length || args[i + 1].startsWith('--')) {
        throw UsageException('Missing value for --$name.');
      }
      values[name] = args[++i];
    }
    return ParsedArgs(values);
  }

  String? value(String name) => _values[name];
}

class UsageException implements Exception {
  final String message;

  UsageException(this.message);
}
