import 'package:core/core.dart' as core;

class EcoUnityAnalyticsGroupContext {
  const EcoUnityAnalyticsGroupContext({
    required this.joinToken,
    this.id,
    this.groupKey,
    this.pilotKey,
    this.groupIdentifier,
    this.name,
    this.country,
    this.language,
    this.status,
  });

  final String joinToken;
  final int? id;
  final String? groupKey;
  final String? pilotKey;
  final String? groupIdentifier;
  final String? name;
  final String? country;
  final String? language;
  final String? status;

  String? get effectivePilotKey => _firstText(<String?>[pilotKey, groupKey]);

  String get displayName {
    return _firstText(<String?>[name, groupKey, pilotKey, groupIdentifier]) ??
        joinToken;
  }

  bool get hasGroupKey => effectivePilotKey != null;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'join_token': joinToken,
      if (id != null) 'id': id,
      if (_hasText(groupKey)) 'group_key': groupKey,
      if (_hasText(pilotKey)) 'pilot_key': pilotKey,
      if (_hasText(groupIdentifier)) 'group_identifier': groupIdentifier,
      if (_hasText(name)) 'name': name,
      if (_hasText(country)) 'country': country,
      if (_hasText(language)) 'language': language,
      if (_hasText(status)) 'status': status,
    };
  }

  factory EcoUnityAnalyticsGroupContext.fromJson(Map<String, dynamic> json) {
    return EcoUnityAnalyticsGroupContext(
      joinToken:
          _readString(json['join_token'] ?? json['enrolment_token']) ?? '',
      id: _readInt(json['id']),
      groupKey: _readString(json['group_key']),
      pilotKey: _readString(json['pilot_key']),
      groupIdentifier: _readString(
        json['group_identifier'] ?? json['pilot_group_identifier'],
      ),
      name: _readString(json['name']),
      country: _readString(json['country']),
      language: _readString(json['language']),
      status: _readString(json['status']),
    );
  }

  factory EcoUnityAnalyticsGroupContext.fromEnrollmentResponse(
    Map<String, dynamic> response, {
    required String fallbackJoinToken,
  }) {
    final Map<String, dynamic> group =
        _readMap(response['group']) ?? _readMap(response['pilot']) ?? response;
    return EcoUnityAnalyticsGroupContext(
      joinToken:
          _readString(
            group['join_token'] ??
                group['enrolment_token'] ??
                group['enrollment_token'],
          ) ??
          fallbackJoinToken,
      id: _readInt(group['id']),
      groupKey: _readString(group['group_key']),
      pilotKey: _readString(group['pilot_key']),
      groupIdentifier: _readString(
        group['group_identifier'] ?? group['pilot_group_identifier'],
      ),
      name: _readString(group['name']),
      country: _readString(group['country']),
      language: _readString(group['language']),
      status: _readString(group['status']),
    );
  }
}

class EcoUnityAnalyticsGroupContextStore {
  EcoUnityAnalyticsGroupContextStore({
    core.FileStorage? fileStorage,
    this.boxName = 'ecounityAnalytics',
  }) : _fileStorage = fileStorage ?? core.FileStorage();

  static const String storageKey = 'group_context';

  final core.FileStorage _fileStorage;
  final String boxName;

  Future<EcoUnityAnalyticsGroupContext?> load() async {
    final Object? stored = await _fileStorage.getObject(
      storageKey,
      boxName: boxName,
    );
    if (stored is! Map) {
      return null;
    }
    final EcoUnityAnalyticsGroupContext context =
        EcoUnityAnalyticsGroupContext.fromJson(
          Map<String, dynamic>.from(stored),
        );
    if (context.joinToken.isEmpty && !context.hasGroupKey) {
      return null;
    }
    return context;
  }

  Future<void> save(EcoUnityAnalyticsGroupContext context) {
    return _fileStorage.setObject(
      storageKey,
      context.toJson(),
      boxName: boxName,
    );
  }

  Future<void> clear() {
    return _fileStorage.deleteObject(storageKey, boxName: boxName);
  }
}

Map<String, dynamic>? _readMap(Object? value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

String? _readString(Object? value) {
  final String? text = value?.toString().trim();
  if (text == null || text.isEmpty || text == 'null') {
    return null;
  }
  return text;
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

String? _firstText(Iterable<String?> values) {
  for (final String? value in values) {
    if (_hasText(value)) {
      return value!.trim();
    }
  }
  return null;
}

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}
