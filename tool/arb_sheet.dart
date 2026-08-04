import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

const String defaultArbDir = 'lib/l10n';
const String defaultTemplateLocale = 'en';
const String metadataColumn = 'metadata_json';

const Set<String> reservedColumns = {
  'key',
  'description',
  'placeholders',
  metadataColumn,
};

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.first == '--help' || args.first == '-h') {
    _printUsage();
    return;
  }

  final String command = args.first;
  final ParsedOptions options = ParsedOptions.parse(args.skip(1).toList());

  try {
    switch (command) {
      case 'export':
        await exportArbFiles(options);
        break;
      case 'import':
        await importSheet(options);
        break;
      default:
        throw UsageException('Unknown command "$command".');
    }
  } on UsageException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln('');
    _printUsage();
    exitCode = 64;
  }
}

Future<void> exportArbFiles(ParsedOptions options) async {
  final String arbDir = options.value('arb-dir') ?? defaultArbDir;
  final String outputPath = options.value('out') ?? 'translations.csv';
  final String format = options.value('format') ?? _formatFromPath(outputPath);
  final String separator = _separatorForFormat(format);
  final String templateLocale =
      options.value('template-locale') ?? defaultTemplateLocale;

  final ArbBundle bundle = loadArbBundle(arbDir, templateLocale);
  final List<String> locales = _orderedLocales(bundle.locales, templateLocale);
  final List<String> keys = _orderedMessageKeys(bundle.maps, locales);

  final List<List<String>> rows = [
    ['key', 'description', 'placeholders', metadataColumn, ...locales],
  ];

  for (final String key in keys) {
    final Map<String, dynamic>? metadata = _metadataForKey(
      key,
      bundle.maps,
      locales,
      templateLocale,
    );
    rows.add([
      key,
      metadata?['description']?.toString() ?? '',
      _placeholderSummary(metadata),
      metadata == null ? '' : jsonEncode(metadata),
      for (final String locale in locales)
        bundle.maps[locale]?[key]?.toString() ?? '',
    ]);
  }

  File(outputPath)
    ..createSync(recursive: true)
    ..writeAsStringSync(writeDelimited(rows, separator));

  stdout.writeln(
    'Exported ${keys.length} messages for ${locales.length} locales to $outputPath.',
  );
}

Future<void> importSheet(ParsedOptions options) async {
  final String? inputPath = options.value('input') ?? options.value('sheet');
  if (inputPath == null) {
    throw UsageException('Missing --input path.');
  }

  final String arbDir = options.value('arb-dir') ?? defaultArbDir;
  final bool emptyOverwrites = options.flag('empty-overwrites');
  final String format = options.value('format') ?? _formatFromPath(inputPath);
  final String templateLocale =
      options.value('template-locale') ?? defaultTemplateLocale;
  final List<List<String>> rows = readSheetRows(inputPath, format);
  if (rows.isEmpty) {
    throw UsageException('The input sheet has no rows.');
  }

  final List<String> header = rows.first.map((value) => value.trim()).toList();
  final int keyIndex = header.indexOf('key');
  if (keyIndex < 0) {
    throw UsageException('The sheet must contain a "key" column.');
  }

  final List<String> localeColumns = header
      .where((column) => column.isNotEmpty && !reservedColumns.contains(column))
      .toList();
  if (localeColumns.isEmpty) {
    throw UsageException(
      'The sheet must contain at least one locale column, for example "en".',
    );
  }

  final ArbBundle existing = Directory(arbDir).existsSync()
      ? loadArbBundle(arbDir, templateLocale)
      : ArbBundle(locales: const [], maps: const {});
  final Map<String, LinkedHashMap<String, dynamic>> outputMaps = {
    for (final String locale in localeColumns)
      locale: LinkedHashMap<String, dynamic>.from({'@@locale': locale}),
  };

  for (final List<String> row in rows.skip(1)) {
    final String key = _cell(row, keyIndex).trim();
    if (key.isEmpty) {
      continue;
    }

    final Map<String, dynamic>? metadata = _metadataFromRow(
      row,
      header,
      key,
      existing.maps,
      localeColumns,
      templateLocale,
    );

    for (final String locale in localeColumns) {
      final int columnIndex = header.indexOf(locale);
      String value = _cell(row, columnIndex);
      if (value.isEmpty && !emptyOverwrites) {
        value = existing.maps[locale]?[key]?.toString() ?? '';
      }

      if (metadata != null) {
        outputMaps[locale]!['@$key'] = metadata;
      }
      outputMaps[locale]![key] = value;
    }
  }

  Directory(arbDir).createSync(recursive: true);
  for (final String locale in localeColumns) {
    final String path = '$arbDir/intl_$locale.arb';
    File(path).writeAsStringSync('${prettyJson(outputMaps[locale]!)}\n');
    stdout.writeln('Wrote $path');
  }
}

List<List<String>> readSheetRows(String inputPath, String format) {
  switch (format) {
    case 'csv':
      return parseDelimited(File(inputPath).readAsStringSync(), ',');
    case 'tsv':
      return parseDelimited(File(inputPath).readAsStringSync(), '\t');
    case 'xlsx':
      return readXlsx(inputPath);
    default:
      throw UsageException(
        'Unsupported input format "$format". Use csv, tsv, or xlsx.',
      );
  }
}

ArbBundle loadArbBundle(String arbDir, String templateLocale) {
  final Directory directory = Directory(arbDir);
  if (!directory.existsSync()) {
    throw UsageException('ARB directory does not exist: $arbDir');
  }

  final List<File> files =
      directory
          .listSync()
          .whereType<File>()
          .where((file) => _isArbFilePath(file.path))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  if (files.isEmpty) {
    throw UsageException('No intl_*.arb files found in $arbDir.');
  }

  final Map<String, LinkedHashMap<String, dynamic>> maps = {};
  for (final File file in files) {
    final dynamic decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map) {
      throw UsageException('${file.path} does not contain a JSON object.');
    }

    final LinkedHashMap<String, dynamic> map = LinkedHashMap.from(decoded);
    final String locale =
        map['@@locale']?.toString() ?? _localeFromPath(file.path);
    maps[locale] = map;
  }

  final List<String> locales = _orderedLocales(
    maps.keys.toList(),
    templateLocale,
  );
  return ArbBundle(locales: locales, maps: maps);
}

List<String> _orderedLocales(List<String> locales, String templateLocale) {
  final List<String> sorted = locales.toSet().toList()..sort();
  if (sorted.remove(templateLocale)) {
    sorted.insert(0, templateLocale);
  }
  return sorted;
}

List<String> _orderedMessageKeys(
  Map<String, Map<String, dynamic>> maps,
  List<String> locales,
) {
  final LinkedHashSet<String> keys = LinkedHashSet<String>();

  for (final String locale in locales) {
    final Map<String, dynamic>? map = maps[locale];
    if (map == null) {
      continue;
    }
    for (final String key in map.keys) {
      if (!_isMetadataKey(key)) {
        keys.add(key);
      }
    }
  }

  return keys.toList();
}

Map<String, dynamic>? _metadataForKey(
  String key,
  Map<String, Map<String, dynamic>> maps,
  List<String> locales,
  String templateLocale,
) {
  final List<String> searchOrder = _orderedLocales(locales, templateLocale);
  for (final String locale in searchOrder) {
    final dynamic metadata = maps[locale]?['@$key'];
    if (metadata is Map) {
      return Map<String, dynamic>.from(metadata);
    }
  }
  return null;
}

Map<String, dynamic>? _metadataFromRow(
  List<String> row,
  List<String> header,
  String key,
  Map<String, Map<String, dynamic>> existingMaps,
  List<String> localeColumns,
  String templateLocale,
) {
  final int metadataIndex = header.indexOf(metadataColumn);
  if (metadataIndex >= 0) {
    final String raw = _cell(row, metadataIndex).trim();
    if (raw.isNotEmpty) {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      throw UsageException('metadata_json for "$key" is not a JSON object.');
    }
  }

  final Map<String, dynamic>? existing = _metadataForKey(
    key,
    existingMaps,
    localeColumns,
    templateLocale,
  );
  if (existing != null) {
    return existing;
  }

  final int descriptionIndex = header.indexOf('description');
  final String description = _cell(row, descriptionIndex).trim();
  if (description.isEmpty) {
    return null;
  }
  return <String, dynamic>{'description': description};
}

String _placeholderSummary(Map<String, dynamic>? metadata) {
  final dynamic placeholders = metadata?['placeholders'];
  if (placeholders is Map) {
    return placeholders.keys.map((key) => key.toString()).join(', ');
  }
  return '';
}

bool _isMetadataKey(String key) {
  return key == '@@locale' || key.startsWith('@');
}

String _localeFromPath(String path) {
  final String fileName = path.split(Platform.pathSeparator).last;
  if (!_isArbFilePath(fileName)) {
    throw UsageException('Could not infer locale from $path.');
  }
  return fileName.substring('intl_'.length, fileName.length - '.arb'.length);
}

bool _isArbFilePath(String path) {
  final String fileName = path.split(Platform.pathSeparator).last;
  return fileName.startsWith('intl_') &&
      fileName.endsWith('.arb') &&
      fileName.length > 'intl_.arb'.length;
}

String _cell(List<String> row, int index) {
  if (index < 0 || index >= row.length) {
    return '';
  }
  return row[index];
}

String _formatFromPath(String path) {
  final String extension = path.split('.').last.toLowerCase();
  if (extension == 'csv' || extension == 'tsv' || extension == 'xlsx') {
    return extension;
  }
  return 'csv';
}

String _separatorForFormat(String format) {
  switch (format) {
    case 'csv':
      return ',';
    case 'tsv':
      return '\t';
    default:
      throw UsageException('Export supports csv or tsv. Got "$format".');
  }
}

String writeDelimited(List<List<String>> rows, String separator) {
  return rows
      .map(
        (row) => row.map((cell) => encodeCell(cell, separator)).join(separator),
      )
      .join('\n');
}

String encodeCell(String value, String separator) {
  final bool needsQuotes =
      value.contains(separator) ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r');
  if (!needsQuotes) {
    return value;
  }
  return '"${value.replaceAll('"', '""')}"';
}

List<List<String>> parseDelimited(String content, String separator) {
  final List<List<String>> rows = [];
  List<String> row = [];
  final StringBuffer cell = StringBuffer();
  bool inQuotes = false;

  void endCell() {
    row.add(cell.toString());
    cell.clear();
  }

  void endRow() {
    endCell();
    rows.add(row);
    row = [];
  }

  for (int i = 0; i < content.length; i++) {
    final String char = content[i];
    if (inQuotes) {
      if (char == '"') {
        if (i + 1 < content.length && content[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        cell.write(char);
      }
      continue;
    }

    if (char == '"') {
      inQuotes = true;
    } else if (char == separator) {
      endCell();
    } else if (char == '\n') {
      endRow();
    } else if (char == '\r') {
      if (i + 1 < content.length && content[i + 1] == '\n') {
        i++;
      }
      endRow();
    } else {
      cell.write(char);
    }
  }

  if (inQuotes) {
    throw UsageException('Unterminated quoted cell in delimited input.');
  }
  if (cell.isNotEmpty || row.isNotEmpty) {
    endRow();
  }
  return rows;
}

List<List<String>> readXlsx(String inputPath) {
  final Archive archive = ZipDecoder().decodeBytes(
    File(inputPath).readAsBytesSync(),
  );
  final List<String> sharedStrings = _readSharedStrings(archive);
  final String sheetPath = _firstWorksheetPath(archive);
  final String worksheetXml = _archiveText(archive, sheetPath);
  final XmlDocument document = XmlDocument.parse(worksheetXml);
  final List<List<String>> rows = [];

  for (final XmlElement rowElement in _elements(document, 'row')) {
    final List<String> row = [];
    for (final XmlElement cellElement in _childElements(rowElement, 'c')) {
      final int columnIndex = _columnIndex(cellElement.getAttribute('r') ?? '');
      while (row.length < columnIndex) {
        row.add('');
      }
      row.add(_xlsxCellValue(cellElement, sharedStrings));
    }
    rows.add(row);
  }
  return rows;
}

List<String> _readSharedStrings(Archive archive) {
  final ArchiveFile? file = archive.findFile('xl/sharedStrings.xml');
  if (file == null) {
    return const [];
  }

  final XmlDocument document = XmlDocument.parse(
    utf8.decode(_archiveFileBytes(file, 'xl/sharedStrings.xml')),
  );
  return _elements(
    document,
    'si',
  ).map((si) => _elements(si, 't').map((t) => t.innerText).join()).toList();
}

String _firstWorksheetPath(Archive archive) {
  final String workbookXml = _archiveText(archive, 'xl/workbook.xml');
  final String relsXml = _archiveText(archive, 'xl/_rels/workbook.xml.rels');
  final XmlDocument workbook = XmlDocument.parse(workbookXml);
  final XmlDocument rels = XmlDocument.parse(relsXml);
  final XmlElement? firstSheet = _elements(workbook, 'sheet').firstOrNull;
  if (firstSheet == null) {
    throw UsageException('No worksheet found in xlsx file.');
  }

  final String? relationId = firstSheet.getAttribute('r:id');
  if (relationId == null) {
    throw UsageException('The first worksheet has no relationship id.');
  }

  for (final XmlElement relationship in _elements(rels, 'Relationship')) {
    if (relationship.getAttribute('Id') == relationId) {
      final String? target = relationship.getAttribute('Target');
      if (target == null) {
        break;
      }
      if (target.startsWith('/')) {
        return target.substring(1);
      }
      return 'xl/$target'.replaceAll('/../', '/');
    }
  }

  throw UsageException('Could not resolve first worksheet in xlsx file.');
}

String _archiveText(Archive archive, String path) {
  final ArchiveFile? file = archive.findFile(path);
  if (file == null) {
    throw UsageException('Missing $path in xlsx file.');
  }
  return utf8.decode(_archiveFileBytes(file, path));
}

String _xlsxCellValue(XmlElement cell, List<String> sharedStrings) {
  final String? type = cell.getAttribute('t');
  if (type == 'inlineStr') {
    return _elements(cell, 't').map((element) => element.innerText).join();
  }

  final String rawValue =
      _childElements(cell, 'v').firstOrNull?.innerText ?? '';
  if (type == 's') {
    final int? index = int.tryParse(rawValue);
    if (index == null || index < 0 || index >= sharedStrings.length) {
      return '';
    }
    return sharedStrings[index];
  }
  if (type == 'b') {
    return rawValue == '1' ? 'TRUE' : 'FALSE';
  }
  return rawValue;
}

int _columnIndex(String cellReference) {
  final StringBuffer letters = StringBuffer();
  for (final int codeUnit in cellReference.toUpperCase().codeUnits) {
    if (codeUnit < 65 || codeUnit > 90) {
      break;
    }
    letters.writeCharCode(codeUnit);
  }
  final String columnLetters = letters.isEmpty ? 'A' : letters.toString();
  int index = 0;
  for (final int codeUnit in columnLetters.codeUnits) {
    index = index * 26 + (codeUnit - 64);
  }
  return index - 1;
}

List<int> _archiveFileBytes(ArchiveFile file, String path) {
  final List<int>? bytes = file.readBytes();
  if (bytes == null) {
    throw UsageException('Could not read $path from xlsx file.');
  }
  return bytes;
}

Iterable<XmlElement> _elements(XmlNode node, String localName) {
  return node.descendants.whereType<XmlElement>().where(
    (element) => element.name.local == localName,
  );
}

Iterable<XmlElement> _childElements(XmlElement node, String localName) {
  return node.children.whereType<XmlElement>().where(
    (element) => element.name.local == localName,
  );
}

String prettyJson(Map<String, dynamic> map) {
  return const JsonEncoder.withIndent('  ').convert(map);
}

void _printUsage() {
  stdout.writeln('''
ARB <-> Google Sheets helper

Export ARB files to CSV:
  dart tool/arb_sheet.dart export --arb-dir lib/l10n --out translations.csv

Export ARB files to TSV:
  dart tool/arb_sheet.dart export --out translations.tsv --format tsv

Import a CSV/TSV/XLSX downloaded from Google Sheets:
  dart tool/arb_sheet.dart import --input translations.csv --arb-dir lib/l10n
  dart tool/arb_sheet.dart import --input translations.xlsx --arb-dir lib/l10n

Columns:
  key, description, placeholders, metadata_json, en, de, fi, it, pl, pt, uk

Translators should edit locale columns only. The metadata_json column preserves
Flutter ARB placeholder metadata. Empty translation cells preserve the existing
ARB value unless --empty-overwrites is passed.

Options:
  --arb-dir <dir>           Defaults to lib/l10n
  --out <file>              Export output path, defaults to translations.csv
  --input <file>            Import input path
  --format <csv|tsv|xlsx>   Inferred from file extension when omitted
  --template-locale <code>  Defaults to en
  --empty-overwrites        Allow empty cells to overwrite existing values
''');
}

class ArbBundle {
  final List<String> locales;
  final Map<String, LinkedHashMap<String, dynamic>> maps;

  ArbBundle({required this.locales, required this.maps});
}

class ParsedOptions {
  final Map<String, String?> _values;
  final Set<String> _flags;

  ParsedOptions(this._values, this._flags);

  factory ParsedOptions.parse(List<String> args) {
    final Map<String, String?> values = {};
    final Set<String> flags = {};

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
      if (name == 'empty-overwrites') {
        flags.add(name);
        continue;
      }

      if (i + 1 >= args.length || args[i + 1].startsWith('--')) {
        throw UsageException('Missing value for --$name.');
      }
      values[name] = args[++i];
    }

    return ParsedOptions(values, flags);
  }

  String? value(String name) => _values[name];

  bool flag(String name) => _flags.contains(name);
}

class UsageException implements Exception {
  final String message;

  UsageException(this.message);
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final Iterator<T> iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
