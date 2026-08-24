import 'dart:convert';

import 'package:core/core.dart' as core;
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

enum EcoUnityReviewStatus {
  notReady,
  needsReview,
  needsChanges,
  approved,
  published,
  unknown,
}

enum EcoUnityReviewScope {
  module,
  activity,
  question,
  note,
  comicScene,
  comicDialogue,
  comicDecision,
}

extension EcoUnityReviewScopeWire on EcoUnityReviewScope {
  String get wireName {
    return switch (this) {
      EcoUnityReviewScope.module => 'module',
      EcoUnityReviewScope.activity => 'activity',
      EcoUnityReviewScope.question => 'question',
      EcoUnityReviewScope.note => 'note',
      EcoUnityReviewScope.comicScene => 'comic_scene',
      EcoUnityReviewScope.comicDialogue => 'comic_dialogue',
      EcoUnityReviewScope.comicDecision => 'comic_decision',
    };
  }
}

class EcoUnityContentReviewRecord {
  const EcoUnityContentReviewRecord({
    required this.scope,
    required this.scopeId,
    required this.language,
    required this.reviewStatus,
    required this.rawData,
  });

  final EcoUnityReviewScope scope;
  final int scopeId;
  final String language;
  final EcoUnityReviewStatus reviewStatus;
  final Map<String, dynamic> rawData;

  factory EcoUnityContentReviewRecord.fromApiResponse(
    Map<String, dynamic> response, {
    required EcoUnityReviewScope scope,
    required int scopeId,
    required String language,
    EcoUnityContentStatus fallbackStatus = EcoUnityContentStatus.unknown,
    EcoUnityReviewStatus? fallbackReviewStatus,
  }) {
    final Map<String, dynamic> data = _reviewPayload(response);
    final EcoUnityReviewStatus parsedStatus = ecoUnityReviewStatusFromWire(
      _firstNonEmptyString(<Object?>[
        data['review_status'],
        data['reviewStatus'],
        data['status'],
        response['review_status'],
        response['reviewStatus'],
      ]),
    );
    final EcoUnityReviewStatus status =
        parsedStatus == EcoUnityReviewStatus.unknown
        ? fallbackReviewStatus ??
              ecoUnityReviewStatusFromContentStatus(fallbackStatus)
        : parsedStatus;

    return EcoUnityContentReviewRecord(
      scope: scope,
      scopeId: _readInt(data['scope_id'] ?? data['scopeId']) ?? scopeId,
      language: _normalizeLanguage(
        _firstNonEmptyString(<Object?>[data['language'], language]),
      ),
      reviewStatus: status,
      rawData: data.isEmpty ? response : data,
    );
  }
}

class EcoUnitySdgReviewQueue {
  const EcoUnitySdgReviewQueue({
    required this.moduleId,
    required this.language,
    required this.records,
    required this.rawData,
  });

  final int moduleId;
  final String language;
  final List<EcoUnityContentReviewRecord> records;
  final Map<String, dynamic> rawData;

  factory EcoUnitySdgReviewQueue.fromApiResponse(
    Map<String, dynamic> response, {
    required int moduleId,
    required String language,
  }) {
    final String normalizedLanguage = _normalizeLanguage(
      _firstNonEmptyString(<Object?>[response['language'], language]),
    );
    final List<EcoUnityContentReviewRecord> records =
        <EcoUnityContentReviewRecord>[];
    final Set<String> seen = <String>{};

    for (final Map<String, dynamic> item in _reviewQueueItemMaps(response)) {
      final EcoUnityReviewScope? scope = _reviewScopeFromMap(item);
      if (scope == null) {
        continue;
      }
      final int? objectId = _reviewObjectIdFromMap(item, scope);
      if (objectId == null) {
        continue;
      }

      final String key = '${scope.wireName}:$objectId:$normalizedLanguage';
      if (!seen.add(key)) {
        continue;
      }

      records.add(
        EcoUnityContentReviewRecord.fromApiResponse(
          item,
          scope: scope,
          scopeId: objectId,
          language: normalizedLanguage,
        ),
      );
    }

    return EcoUnitySdgReviewQueue(
      moduleId: moduleId,
      language: normalizedLanguage,
      records: records,
      rawData: response,
    );
  }
}

abstract class EcoUnityContentReviewTransport {
  Future<Map<String, dynamic>> getJson(
    String path, {
    required core.User user,
    String? language,
  });

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> payload, {
    required core.User user,
    String? language,
  });
}

class EcoUnityHttpContentReviewTransport
    implements EcoUnityContentReviewTransport {
  EcoUnityHttpContentReviewTransport({
    http.Client? httpClient,
    core.Settings? settings,
  }) : _httpClient = httpClient ?? http.Client(),
       _settings = settings ?? core.Settings();

  final http.Client _httpClient;
  final core.Settings _settings;
  Future<String>? _mobileAppHeaderFuture;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    required core.User user,
    String? language,
  }) async {
    final Uri uri = _apiUri(await _settings.getServer(), path);
    final http.Response response = await _httpClient.get(
      uri,
      headers: await _headers(user: user, language: language),
    );
    return _decodeOrThrow(response);
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> payload, {
    required core.User user,
    String? language,
  }) async {
    final Uri uri = _apiUri(await _settings.getServer(), path);
    final http.Response response = await _httpClient.post(
      uri,
      headers: await _headers(user: user, language: language, jsonBody: true),
      body: jsonEncode(payload),
    );
    return _decodeOrThrow(response);
  }

  Future<Map<String, String>> _headers({
    required core.User user,
    String? language,
    bool jsonBody = false,
  }) async {
    final String token = _reviewToken(user);
    final Map<String, String> headers = <String, String>{
      'Accept': 'application/json',
      'api-key': token,
      'Authorization': 'Bearer $token',
      'X-Mobile-App': await _mobileAppHeader(),
    };
    if (jsonBody) {
      headers['Content-Type'] = 'application/json';
    }
    final String normalizedLanguage = _normalizeLanguage(language);
    if (normalizedLanguage.isNotEmpty) {
      headers['Accept-Language'] = normalizedLanguage;
    }
    return headers;
  }

  Future<String> _mobileAppHeader() {
    return _mobileAppHeaderFuture ??= PackageInfo.fromPlatform().then((
      PackageInfo packageInfo,
    ) {
      return '${packageInfo.appName} / '
          '${packageInfo.version} ${packageInfo.buildNumber}';
    });
  }
}

class EcoUnityContentReviewService {
  EcoUnityContentReviewService({EcoUnityContentReviewTransport? transport})
    : _transport = transport ?? EcoUnityHttpContentReviewTransport();

  static const String learningModuleKey = 'ecounitylearning';

  final EcoUnityContentReviewTransport _transport;

  Future<bool> canModifyLearningContent({required core.User user}) async {
    if (!_hasReviewToken(user)) {
      return false;
    }

    try {
      final Map<String, dynamic> response = await _transport.getJson(
        '/api/accesslevels/modules/$learningModuleKey',
        user: user,
      );
      if (ecoUnityReviewAccessAllowsModify(response)) {
        return true;
      }
    } on EcoUnityContentReviewException catch (exception) {
      if (exception.statusCode == 401 || exception.statusCode == 403) {
        return false;
      }
    }

    try {
      final Map<String, dynamic> response = await _transport.getJson(
        '/api/accesslevels/modules',
        user: user,
      );
      return ecoUnityReviewAccessAllowsModify(response);
    } on EcoUnityContentReviewException catch (exception) {
      if (exception.statusCode == 401 || exception.statusCode == 403) {
        return false;
      }
      rethrow;
    }
  }

  Future<EcoUnityContentReviewRecord> loadReview({
    required core.User user,
    required EcoUnityReviewScope scope,
    required int objectId,
    required String language,
    EcoUnityContentStatus fallbackStatus = EcoUnityContentStatus.unknown,
  }) async {
    final String normalizedLanguage = _normalizeLanguage(language);
    final Map<String, dynamic> response = await _transport.getJson(
      '/api/ecounitylearning/review/${scope.wireName}/$objectId/'
      '${Uri.encodeComponent(normalizedLanguage)}',
      user: user,
      language: normalizedLanguage,
    );
    return EcoUnityContentReviewRecord.fromApiResponse(
      response,
      scope: scope,
      scopeId: objectId,
      language: normalizedLanguage,
      fallbackStatus: fallbackStatus,
    );
  }

  Future<EcoUnitySdgReviewQueue> loadSdgReviewQueue({
    required core.User user,
    required int moduleId,
    required String language,
  }) async {
    final String normalizedLanguage = _normalizeLanguage(language);
    final Map<String, dynamic> response = await _transport.getJson(
      '/api/ecounitylearning/sdg/$moduleId/review/'
      '${Uri.encodeComponent(normalizedLanguage)}',
      user: user,
      language: normalizedLanguage,
    );
    return EcoUnitySdgReviewQueue.fromApiResponse(
      response,
      moduleId: moduleId,
      language: normalizedLanguage,
    );
  }

  Future<EcoUnityContentReviewRecord> updateReview({
    required core.User user,
    required EcoUnityReviewScope scope,
    required int objectId,
    required String language,
    required EcoUnityReviewStatus reviewStatus,
  }) async {
    final String normalizedLanguage = _normalizeLanguage(language);
    final String primaryStatus = _reviewStatusToWire(reviewStatus);
    final String? retryStatus = _legacyContentStatusWire(reviewStatus);
    final String path =
        '/api/ecounitylearning/review/${scope.wireName}/$objectId/'
        '${Uri.encodeComponent(normalizedLanguage)}/update';

    try {
      return await _postReviewUpdate(
        path: path,
        user: user,
        scope: scope,
        objectId: objectId,
        language: normalizedLanguage,
        reviewStatus: primaryStatus,
      );
    } on EcoUnityContentReviewException catch (exception) {
      if (retryStatus == null ||
          retryStatus == primaryStatus ||
          (exception.statusCode != null && exception.statusCode! >= 500)) {
        rethrow;
      }
      return _postReviewUpdate(
        path: path,
        user: user,
        scope: scope,
        objectId: objectId,
        language: normalizedLanguage,
        reviewStatus: retryStatus,
      );
    }
  }

  Future<EcoUnityContentReviewRecord> _postReviewUpdate({
    required String path,
    required core.User user,
    required EcoUnityReviewScope scope,
    required int objectId,
    required String language,
    required String reviewStatus,
  }) async {
    final Map<String, dynamic> response = await _transport.postJson(
      path,
      <String, dynamic>{'review_status': reviewStatus},
      user: user,
      language: language,
    );
    return EcoUnityContentReviewRecord.fromApiResponse(
      response,
      scope: scope,
      scopeId: objectId,
      language: language,
      fallbackReviewStatus: ecoUnityReviewStatusFromWire(reviewStatus),
    );
  }
}

class EcoUnityContentReviewException implements Exception {
  const EcoUnityContentReviewException(this.statusCode, this.message);

  final int? statusCode;
  final String message;

  @override
  String toString() {
    return message;
  }
}

bool ecoUnityReviewAccessAllowsModify(
  Object? response, {
  String moduleKey = EcoUnityContentReviewService.learningModuleKey,
}) {
  return _allowsModify(response, _canonicalModuleKey(moduleKey));
}

EcoUnityReviewStatus ecoUnityReviewStatusFromWire(Object? value) {
  final String status = value?.toString().trim().toLowerCase() ?? '';
  return switch (status) {
    'not_ready' => EcoUnityReviewStatus.notReady,
    'notready' => EcoUnityReviewStatus.notReady,
    'draft' => EcoUnityReviewStatus.notReady,
    'needs_review' => EcoUnityReviewStatus.needsReview,
    'needsreview' => EcoUnityReviewStatus.needsReview,
    'review' => EcoUnityReviewStatus.needsReview,
    'in_review' => EcoUnityReviewStatus.needsReview,
    'needs_changes' => EcoUnityReviewStatus.needsChanges,
    'needs_change' => EcoUnityReviewStatus.needsChanges,
    'needschanges' => EcoUnityReviewStatus.needsChanges,
    'needs_work' => EcoUnityReviewStatus.needsChanges,
    'approved' => EcoUnityReviewStatus.approved,
    'reviewed' => EcoUnityReviewStatus.approved,
    'published' => EcoUnityReviewStatus.published,
    _ => EcoUnityReviewStatus.unknown,
  };
}

EcoUnityReviewStatus ecoUnityReviewStatusFromContentStatus(
  EcoUnityContentStatus status,
) {
  return switch (status) {
    EcoUnityContentStatus.draft => EcoUnityReviewStatus.notReady,
    EcoUnityContentStatus.review => EcoUnityReviewStatus.needsReview,
    EcoUnityContentStatus.approved => EcoUnityReviewStatus.approved,
    EcoUnityContentStatus.published => EcoUnityReviewStatus.published,
    EcoUnityContentStatus.archived => EcoUnityReviewStatus.notReady,
    EcoUnityContentStatus.unknown => EcoUnityReviewStatus.unknown,
  };
}

String _reviewToken(core.User user) {
  final String? token = user.token?.trim();
  if (token == null || token.isEmpty) {
    throw const EcoUnityContentReviewException(
      401,
      'Log in to review EcoUnity content.',
    );
  }
  return token;
}

bool _hasReviewToken(core.User user) {
  return user.id != null &&
      !user.isGuestUser &&
      (user.token?.isNotEmpty ?? false);
}

Map<String, dynamic> _decodeOrThrow(http.Response response) {
  final Map<String, dynamic> decoded = _decodeResponseBody(response.body);
  if (response.statusCode >= 200 && response.statusCode < 300) {
    final String status = '${decoded['status'] ?? ''}'.trim().toLowerCase();
    if (status == 'error') {
      throw EcoUnityContentReviewException(
        response.statusCode,
        _readErrorMessage(decoded),
      );
    }
    return decoded;
  }
  throw EcoUnityContentReviewException(
    response.statusCode,
    _readErrorMessage(decoded),
  );
}

Uri _apiUri(String rawBase, String path) {
  final String trimmedBase = rawBase.trim();
  final Uri base = trimmedBase.contains('://')
      ? Uri.parse(trimmedBase)
      : Uri(scheme: 'https', host: trimmedBase);
  final String cleanPath = path.startsWith('/') ? path.substring(1) : path;
  final String basePath = base.path.endsWith('/')
      ? base.path.substring(0, base.path.length - 1)
      : base.path;
  return base.replace(
    path: basePath.isEmpty ? cleanPath : '$basePath/$cleanPath',
  );
}

Map<String, dynamic> _decodeResponseBody(String body) {
  if (body.trim().isEmpty) {
    return <String, dynamic>{};
  }
  final Object? decoded = jsonDecode(body);
  if (decoded is Map) {
    return Map<String, dynamic>.from(decoded);
  }
  return <String, dynamic>{'data': decoded};
}

String _readErrorMessage(Map<String, dynamic> decoded) {
  final String message = _firstNonEmptyString(<Object?>[
    decoded['message'],
    decoded['error'],
    decoded['error_message'],
    decoded['statusText'],
  ]);
  return message.isEmpty ? 'Unable to update review status.' : message;
}

Map<String, dynamic> _reviewPayload(Map<String, dynamic> response) {
  for (final String key in const <String>[
    'data',
    'marker',
    'review',
    'locale',
    'content_locale',
    'contentLocale',
    'item',
    'object',
  ]) {
    final Map<String, dynamic>? map = _asMap(response[key]);
    if (map != null) {
      return map;
    }
    final Map<String, dynamic>? first = _firstMap(response[key]);
    if (first != null) {
      return first;
    }
  }
  if (response.containsKey('review_status') ||
      response.containsKey('reviewStatus')) {
    return response;
  }
  return <String, dynamic>{};
}

Iterable<Map<String, dynamic>> _reviewQueueItemMaps(Object? value) sync* {
  if (value is Iterable) {
    for (final Object? item in value) {
      yield* _reviewQueueItemMaps(item);
    }
    return;
  }

  final Map<String, dynamic>? map = _asMap(value);
  if (map == null) {
    return;
  }

  if (_reviewScopeFromMap(map) != null) {
    yield map;
  }

  for (final String key in const <String>[
    'data',
    'result',
    'items',
    'groups',
    'children',
    'records',
    'markers',
    'reviewItems',
    'review_items',
    'activities',
    'questions',
    'notes',
    'comicScenes',
    'comic_scenes',
    'comicDialogues',
    'comic_dialogues',
    'comicDecisions',
    'comic_decisions',
    'dialogues',
    'decisions',
  ]) {
    if (map.containsKey(key)) {
      yield* _reviewQueueItemMaps(map[key]);
    }
  }
}

EcoUnityReviewScope? _reviewScopeFromMap(Map<String, dynamic> map) {
  final String scopeText = _firstNonEmptyString(<Object?>[
    map['scope_type'],
    map['scopeType'],
    map['scope'],
    map['type'],
    map['object_type'],
    map['objectType'],
    map['_objecttype'],
    map['objecttype'],
  ]);
  if (scopeText.isEmpty) {
    return null;
  }

  return _reviewScopeFromWire(scopeText);
}

EcoUnityReviewScope? _reviewScopeFromWire(Object? value) {
  final String scope = _canonicalModuleKey(value?.toString() ?? '');
  return switch (scope) {
    'module' ||
    'sdg' ||
    'sdgmodule' ||
    'ecounitysdgmodule' ||
    'ecounitylearningmodule' => EcoUnityReviewScope.module,
    'activity' ||
    'learningactivity' ||
    'ecounitylearningactivity' => EcoUnityReviewScope.activity,
    'question' ||
    'quizquestion' ||
    'ecounityquestion' => EcoUnityReviewScope.question,
    'note' || 'ecounitynote' => EcoUnityReviewScope.note,
    'comicscene' ||
    'scene' ||
    'ecounitycomicscene' => EcoUnityReviewScope.comicScene,
    'comicdialogue' ||
    'dialogue' ||
    'ecounityscenedialogue' => EcoUnityReviewScope.comicDialogue,
    'comicdecision' ||
    'decision' ||
    'ecounitycomicdecision' => EcoUnityReviewScope.comicDecision,
    _ => null,
  };
}

int? _reviewObjectIdFromMap(
  Map<String, dynamic> map,
  EcoUnityReviewScope scope,
) {
  final int? direct = _readInt(
    map['scope_id'] ??
        map['scopeId'] ??
        map['object_id'] ??
        map['objectId'] ??
        map['content_object_id'] ??
        map['contentObjectId'],
  );
  if (direct != null) {
    return direct;
  }

  final int? scopedReference = switch (scope) {
    EcoUnityReviewScope.module => _objectReferenceId(map['module']),
    EcoUnityReviewScope.activity => _objectReferenceId(map['activity']),
    EcoUnityReviewScope.question => _objectReferenceId(map['question']),
    EcoUnityReviewScope.note => _objectReferenceId(map['note']),
    EcoUnityReviewScope.comicScene =>
      _objectReferenceId(map['comic_scene']) ??
          _objectReferenceId(map['comicScene']) ??
          _objectReferenceId(map['scene']),
    EcoUnityReviewScope.comicDialogue =>
      _objectReferenceId(map['comic_dialogue']) ??
          _objectReferenceId(map['comicDialogue']) ??
          _objectReferenceId(map['dialogue']),
    EcoUnityReviewScope.comicDecision =>
      _objectReferenceId(map['comic_decision']) ??
          _objectReferenceId(map['comicDecision']) ??
          _objectReferenceId(map['decision']),
  };
  if (scopedReference != null) {
    return scopedReference;
  }

  final int? objectReference =
      _objectReferenceId(map['object']) ??
      _objectReferenceId(map['content_object']) ??
      _objectReferenceId(map['contentObject']);
  if (objectReference != null) {
    return objectReference;
  }

  if (!map.containsKey('localeId') && !map.containsKey('locale_id')) {
    return _readInt(map['id']);
  }
  return null;
}

int? _objectReferenceId(Object? value) {
  final Map<String, dynamic>? map = _asMap(value);
  if (map == null) {
    return _readInt(value);
  }
  return _readInt(
    map['objectid'] ??
        map['objectId'] ??
        map['object_id'] ??
        map['id'] ??
        map['value'],
  );
}

bool _allowsModify(Object? value, String moduleKey) {
  if (value == null) {
    return false;
  }
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value > 10;
  }
  if (value is String) {
    return _textAllowsModify(value);
  }
  if (value is Iterable) {
    for (final Object? item in value) {
      if (_allowsModify(item, moduleKey)) {
        return true;
      }
    }
    return false;
  }
  if (value is Map) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(value);
    final String? identifiedModule = _moduleIdentifier(map);
    if (identifiedModule != null &&
        _canonicalModuleKey(identifiedModule) != moduleKey) {
      return false;
    }

    if (map.containsKey(moduleKey) &&
        _allowsModify(map[moduleKey], moduleKey)) {
      return true;
    }

    for (final String key in const <String>[
      'can_modify',
      'canModify',
      'has_modify_access',
      'hasModifyAccess',
      'modify',
      'MODIFY',
      'write',
      'update',
    ]) {
      if (map.containsKey(key) && _allowsModify(map[key], moduleKey)) {
        return true;
      }
    }

    for (final String key in const <String>[
      'access',
      'access_level',
      'accessLevel',
      'accesslevel',
      'acl',
      'acl_level',
      'level',
      'value',
      'label',
      'permission',
      'permissions',
      'actions',
      'rights',
      'role',
    ]) {
      if (map.containsKey(key) && _allowsModify(map[key], moduleKey)) {
        return true;
      }
    }

    for (final String key in const <String>[
      'data',
      'result',
      'module',
      'modules',
      'accesslevels',
      'accessLevels',
      'items',
    ]) {
      if (map.containsKey(key) && _allowsModify(map[key], moduleKey)) {
        return true;
      }
    }
  }
  return false;
}

String? _moduleIdentifier(Map<String, dynamic> map) {
  for (final String key in const <String>[
    'module_key',
    'moduleKey',
    'key',
    'module',
    'module_name',
    'moduleName',
    'name',
  ]) {
    final String text = _firstNonEmptyString(<Object?>[map[key]]);
    if (text.isNotEmpty) {
      return text;
    }
  }
  return null;
}

bool _textAllowsModify(String value) {
  final String text = value.trim().toLowerCase();
  if (text.isEmpty || text == 'false' || text == 'no' || text == 'none') {
    return false;
  }
  final num? numeric = num.tryParse(text);
  if (numeric != null) {
    return numeric > 10;
  }
  return text == 'modify' ||
      text == 'write' ||
      text == 'admin' ||
      text == 'owner' ||
      text == 'full' ||
      text == 'true' ||
      text == '1' ||
      text.contains('modify');
}

String _canonicalModuleKey(String value) {
  final String text = value.trim().toLowerCase();
  final StringBuffer buffer = StringBuffer();
  for (final int codeUnit in text.codeUnits) {
    final bool isDigit = codeUnit >= 48 && codeUnit <= 57;
    final bool isLowercaseLetter = codeUnit >= 97 && codeUnit <= 122;
    if (isDigit || isLowercaseLetter) {
      buffer.writeCharCode(codeUnit);
    }
  }
  return buffer.toString();
}

String _reviewStatusToWire(EcoUnityReviewStatus status) {
  return switch (status) {
    EcoUnityReviewStatus.notReady => 'not_ready',
    EcoUnityReviewStatus.needsReview => 'needs_review',
    EcoUnityReviewStatus.needsChanges => 'needs_changes',
    EcoUnityReviewStatus.approved => 'approved',
    EcoUnityReviewStatus.published => 'published',
    EcoUnityReviewStatus.unknown => 'needs_review',
  };
}

String? _legacyContentStatusWire(EcoUnityReviewStatus status) {
  return switch (status) {
    EcoUnityReviewStatus.notReady => 'draft',
    EcoUnityReviewStatus.needsReview => 'review',
    EcoUnityReviewStatus.needsChanges => null,
    EcoUnityReviewStatus.approved => null,
    EcoUnityReviewStatus.published => null,
    EcoUnityReviewStatus.unknown => null,
  };
}

String _normalizeLanguage(Object? language) {
  final String normalized = language?.toString().trim().toLowerCase() ?? '';
  return normalized.isEmpty ? 'en' : normalized;
}

String _firstNonEmptyString(Iterable<Object?> values) {
  for (final Object? value in values) {
    final String text = value?.toString().trim() ?? '';
    if (text.isNotEmpty && text != 'null') {
      return text;
    }
  }
  return '';
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

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

Map<String, dynamic>? _firstMap(Object? value) {
  if (value is! Iterable) {
    return null;
  }
  for (final Object? item in value) {
    final Map<String, dynamic>? map = _asMap(item);
    if (map != null) {
      return map;
    }
  }
  return null;
}
