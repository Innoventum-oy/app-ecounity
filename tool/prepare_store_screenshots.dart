import 'dart:io';

import 'package:image/image.dart' as img;

const List<String> defaultLocales = ['en', 'de', 'fi', 'it', 'pl', 'pt', 'uk'];
const List<String> defaultIosTargets = ['iphone_65', 'ipad_13'];
const List<String> defaultAndroidTargets = ['phone'];
const int playStoreMaxScreenshotsPerDeviceType = 8;

const Map<String, List<ScreenshotSize>> appStoreScreenshotSizes = {
  'iphone_65': [ScreenshotSize(1242, 2688), ScreenshotSize(1284, 2778)],
  'ipad_13': [ScreenshotSize(2064, 2752), ScreenshotSize(2048, 2732)],
};

const Map<String, String> appStoreLocales = {
  'en': 'en-GB',
  'de': 'de-DE',
  'fi': 'fi',
  'it': 'it',
  'pl': 'pl',
  'pt': 'pt-PT',
  'uk': 'uk',
};

const Map<String, String> playStoreLocales = {
  'en': 'en-GB',
  'de': 'de-DE',
  'fi': 'fi-FI',
  'it': 'it-IT',
  'pl': 'pl-PL',
  'pt': 'pt-PT',
  'uk': 'uk',
};

const Map<String, String> playStoreScreenshotDirectories = {
  'phone': 'phoneScreenshots',
  'seven_inch': 'sevenInchScreenshots',
  'ten_inch': 'tenInchScreenshots',
};

Future<void> main(List<String> args) async {
  final ParsedArgs parsedArgs = ParsedArgs.parse(args);
  final String platform = parsedArgs.value('platform') ?? 'all';
  final String rawDir = parsedArgs.value('raw-dir') ?? 'build/fastlane/raw';
  final List<String> locales =
      _csvList(parsedArgs.value('locales')) ?? defaultLocales;
  final List<String> iosTargets =
      _csvList(parsedArgs.value('ios-targets')) ?? defaultIosTargets;
  final List<String> androidTargets =
      _csvList(parsedArgs.value('android-targets')) ?? defaultAndroidTargets;
  final bool clean = parsedArgs.flag('clean');

  if (!['all', 'android', 'ios'].contains(platform)) {
    _fail('Unsupported --platform "$platform". Use android, ios, or all.');
  }

  final bool preparesIos = platform == 'all' || platform == 'ios';
  final bool preparesAndroid = platform == 'all' || platform == 'android';
  if (clean && preparesIos) {
    _deleteDirectory(Directory('ios/fastlane/screenshots'));
  }
  if (clean && preparesAndroid) {
    _deleteAndroidScreenshotDirectories();
  }

  for (final String locale in locales) {
    if (preparesIos) {
      _prepareIosScreenshots(
        rawDir: rawDir,
        locale: locale,
        targets: iosTargets,
      );
    }

    if (preparesAndroid) {
      _prepareAndroidScreenshots(
        rawDir: rawDir,
        locale: locale,
        targets: androidTargets,
      );
    }
  }
}

void _prepareAndroidScreenshots({
  required String rawDir,
  required String locale,
  required List<String> targets,
}) {
  for (final String target in targets) {
    final String normalizedTarget = target.replaceAll('-', '_');
    final String screenshotDirectory = _playStoreScreenshotDirectory(
      normalizedTarget,
    );
    Directory source = Directory('$rawDir/$normalizedTarget/$locale');
    List<File> screenshots = _screenshotsIn(source);

    if (screenshots.isEmpty && normalizedTarget == 'phone') {
      source = Directory('$rawDir/$locale');
      screenshots = _screenshotsIn(source);
    }

    if (screenshots.isEmpty) {
      _warnMissingScreenshots('$locale/$normalizedTarget', source);
      continue;
    }

    final Directory destination = Directory(
      'android/fastlane/metadata/android/${_playStoreLocale(locale)}/images/$screenshotDirectory',
    );
    final List<File> uploadableScreenshots = screenshots
        .take(playStoreMaxScreenshotsPerDeviceType)
        .toList();
    final int count = _copyScreenshots(
      uploadableScreenshots,
      destination,
      clean: false,
    );
    stdout.writeln('Prepared $count screenshots in ${destination.path}');

    if (screenshots.length > playStoreMaxScreenshotsPerDeviceType) {
      stdout.writeln(
        'Skipped ${screenshots.length - playStoreMaxScreenshotsPerDeviceType} '
        'extra screenshots for $locale/$normalizedTarget because Google Play '
        'allows $playStoreMaxScreenshotsPerDeviceType per device type.',
      );
    }
  }
}

void _prepareIosScreenshots({
  required String rawDir,
  required String locale,
  required List<String> targets,
}) {
  final Directory destination = Directory(
    'ios/fastlane/screenshots/${_appStoreLocale(locale)}',
  );

  int preparedCount = 0;
  bool foundTargetSource = false;

  for (final String target in targets) {
    final Directory source = Directory('$rawDir/$target/$locale');
    final List<File> screenshots = _screenshotsIn(source);
    if (screenshots.isEmpty) {
      _warnMissingScreenshots('$locale/$target', source);
      continue;
    }

    foundTargetSource = true;
    preparedCount += _copyScreenshots(
      screenshots,
      destination,
      clean: false,
      filePrefix: '${target}_',
      allowedSizes: appStoreScreenshotSizes[target] ?? const [],
    );
  }

  if (!foundTargetSource) {
    final Directory source = Directory('$rawDir/$locale');
    final List<File> screenshots = _screenshotsIn(source);
    if (screenshots.isNotEmpty) {
      preparedCount += _copyScreenshots(screenshots, destination, clean: false);
    } else {
      _warnMissingScreenshots(locale, source);
    }
  }

  if (preparedCount > 0) {
    stdout.writeln(
      'Prepared $preparedCount screenshots in ${destination.path}',
    );
  }
}

void _deleteDirectory(Directory directory) {
  if (directory.existsSync()) {
    directory.deleteSync(recursive: true);
  }
}

void _deleteAndroidScreenshotDirectories() {
  final Directory metadataRoot = Directory('android/fastlane/metadata/android');
  if (!metadataRoot.existsSync()) {
    return;
  }

  for (final FileSystemEntity locale in metadataRoot.listSync()) {
    if (locale is! Directory) {
      continue;
    }

    for (final String screenshotDirectory
        in playStoreScreenshotDirectories.values) {
      _deleteDirectory(Directory('${locale.path}/images/$screenshotDirectory'));
    }
  }
}

List<File> _screenshotsIn(Directory source) {
  if (!source.existsSync()) {
    return const [];
  }

  return source
      .listSync()
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith('.png'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

int _copyScreenshots(
  List<File> screenshots,
  Directory destination, {
  required bool clean,
  String filePrefix = '',
  List<ScreenshotSize> allowedSizes = const [],
}) {
  if (clean && destination.existsSync()) {
    destination.deleteSync(recursive: true);
  }

  destination.createSync(recursive: true);
  for (final File screenshot in screenshots) {
    _validateScreenshotDimensions(screenshot, allowedSizes);
    final String fileName = screenshot.uri.pathSegments.last;
    _writeOpaquePng(screenshot, '${destination.path}/$filePrefix$fileName');
  }

  return screenshots.length;
}

void _writeOpaquePng(File source, String destinationPath) {
  final img.Image? decoded = img.decodePng(source.readAsBytesSync());
  if (decoded == null) {
    _fail('Could not decode ${source.path} as a PNG screenshot.');
  }

  final img.Image rgba = decoded.convert(
    format: img.Format.uint8,
    numChannels: 4,
    noAnimation: true,
  );
  final img.Image rgb = img.Image(
    width: rgba.width,
    height: rgba.height,
    format: img.Format.uint8,
    numChannels: 3,
  );

  for (final img.Pixel pixel in rgba) {
    final num alpha = pixel.aNormalized;
    rgb.setPixelRgb(
      pixel.x,
      pixel.y,
      _flattenChannel(pixel.r, alpha),
      _flattenChannel(pixel.g, alpha),
      _flattenChannel(pixel.b, alpha),
    );
  }

  File(destinationPath).writeAsBytesSync(img.encodePng(rgb, level: 6));
}

int _flattenChannel(num channel, num alpha) {
  return ((channel * alpha) + (255 * (1 - alpha))).round().clamp(0, 255);
}

void _validateScreenshotDimensions(
  File screenshot,
  List<ScreenshotSize> allowedSizes,
) {
  if (allowedSizes.isEmpty) {
    return;
  }

  final ScreenshotSize actualSize = _pngSize(screenshot);
  final bool allowed = allowedSizes.any(actualSize.matches);
  if (!allowed) {
    _fail(
      '${screenshot.path} is ${actualSize.label}; expected one of '
      '${_formatSizes(allowedSizes)}.',
    );
  }
}

ScreenshotSize _pngSize(File file) {
  final List<int> bytes = file.readAsBytesSync();
  const List<int> signature = [137, 80, 78, 71, 13, 10, 26, 10];
  if (bytes.length < 24) {
    _fail('${file.path} is too small to be a PNG screenshot.');
  }
  for (int index = 0; index < signature.length; index++) {
    if (bytes[index] != signature[index]) {
      _fail('${file.path} is not a PNG screenshot.');
    }
  }

  return ScreenshotSize(_uint32(bytes, 16), _uint32(bytes, 20));
}

int _uint32(List<int> bytes, int offset) {
  return (bytes[offset] << 24) |
      (bytes[offset + 1] << 16) |
      (bytes[offset + 2] << 8) |
      bytes[offset + 3];
}

String _formatSizes(List<ScreenshotSize> sizes) {
  return sizes.map((size) => size.label).join(', ');
}

void _warnMissingScreenshots(String locale, Directory source) {
  stderr.writeln('Skipping $locale: no screenshots found in ${source.path}');
}

List<String>? _csvList(String? value) {
  return value
      ?.split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

String _appStoreLocale(String locale) {
  return appStoreLocales[locale] ?? locale;
}

String _playStoreLocale(String locale) {
  return playStoreLocales[locale] ?? locale;
}

String _playStoreScreenshotDirectory(String target) {
  final String? directory = playStoreScreenshotDirectories[target];
  if (directory == null) {
    _fail(
      'Unsupported Android screenshot target "$target". Use phone, '
      'seven_inch, or ten_inch.',
    );
  }
  return directory;
}

Never _fail(String message) {
  stderr.writeln(message);
  exitCode = 64;
  throw const _Exit();
}

class ParsedArgs {
  final Map<String, String> _values;
  final Set<String> _flags;

  ParsedArgs(this._values, this._flags);

  factory ParsedArgs.parse(List<String> args) {
    final Map<String, String> values = {};
    final Set<String> flags = {};

    for (int index = 0; index < args.length; index++) {
      final String arg = args[index];
      if (!arg.startsWith('--')) {
        _fail('Unexpected positional argument "$arg".');
      }

      final int equalsIndex = arg.indexOf('=');
      if (equalsIndex > 0) {
        values[arg.substring(2, equalsIndex)] = arg.substring(equalsIndex + 1);
        continue;
      }

      final String name = arg.substring(2);
      if (name == 'clean') {
        flags.add(name);
        continue;
      }

      if (index + 1 >= args.length || args[index + 1].startsWith('--')) {
        _fail('Missing value for --$name.');
      }
      values[name] = args[++index];
    }

    return ParsedArgs(values, flags);
  }

  String? value(String name) => _values[name];

  bool flag(String name) => _flags.contains(name);
}

class ScreenshotSize {
  final int width;
  final int height;

  const ScreenshotSize(this.width, this.height);

  String get label => '${width}x$height';

  bool matches(ScreenshotSize other) {
    return width == other.width && height == other.height;
  }
}

class _Exit implements Exception {
  const _Exit();
}
