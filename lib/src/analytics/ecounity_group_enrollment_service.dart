import 'dart:convert';

import 'package:core/core.dart' as core;
import 'package:ecounity/src/analytics/ecounity_group_context.dart';
import 'package:http/http.dart' as http;

abstract class EcoUnityGroupEnrollmentTransport {
  Future<Map<String, dynamic>> getJson(String path);
}

class EcoUnityHttpGroupEnrollmentTransport
    implements EcoUnityGroupEnrollmentTransport {
  EcoUnityHttpGroupEnrollmentTransport({
    http.Client? httpClient,
    core.Settings? settings,
  }) : _httpClient = httpClient ?? http.Client(),
       _settings = settings ?? core.Settings();

  final http.Client _httpClient;
  final core.Settings _settings;

  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    final Uri uri = _apiUri(await _settings.getServer(), path);
    final http.Response response = await _httpClient.get(
      uri,
      headers: const <String, String>{'Accept': 'application/json'},
    );
    final Map<String, dynamic> decoded = _decodeResponseBody(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    throw EcoUnityGroupEnrollmentException(
      response.statusCode,
      _readErrorMessage(decoded),
    );
  }
}

class EcoUnityGroupEnrollmentService {
  EcoUnityGroupEnrollmentService({
    EcoUnityGroupEnrollmentTransport? transport,
    EcoUnityAnalyticsGroupContextStore? store,
    bool persistContext = true,
  }) : _transport = transport ?? EcoUnityHttpGroupEnrollmentTransport(),
       _store = persistContext
           ? store ?? EcoUnityAnalyticsGroupContextStore()
           : store;

  final EcoUnityGroupEnrollmentTransport _transport;
  final EcoUnityAnalyticsGroupContextStore? _store;

  Future<EcoUnityAnalyticsGroupContext?> loadCurrentGroup() {
    return _store?.load() ?? Future<EcoUnityAnalyticsGroupContext?>.value();
  }

  Future<EcoUnityAnalyticsGroupContext> enrollWithCode(String input) async {
    final String joinToken = normalizeJoinCode(input);
    if (joinToken.isEmpty) {
      throw const EcoUnityGroupEnrollmentException(null, 'Enter a group code.');
    }

    final Map<String, dynamic> response = await _transport.getJson(
      '/api/ecounitylearning/group/${Uri.encodeComponent(joinToken)}',
    );
    final String status = '${response['status'] ?? ''}'.toLowerCase();
    if (status == 'error') {
      throw EcoUnityGroupEnrollmentException(null, _readErrorMessage(response));
    }

    final EcoUnityAnalyticsGroupContext group =
        EcoUnityAnalyticsGroupContext.fromEnrollmentResponse(
          response,
          fallbackJoinToken: joinToken,
        );
    if (!group.hasGroupKey && group.joinToken.isEmpty) {
      throw const EcoUnityGroupEnrollmentException(
        null,
        'Group enrollment link was not found or is not active.',
      );
    }
    await _store?.save(group);
    return group;
  }

  Future<void> clearCurrentGroup() {
    return _store?.clear() ?? Future<void>.value();
  }

  static String normalizeJoinCode(String input) {
    final String trimmed = input.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final Uri? uri = Uri.tryParse(trimmed);
    if (uri != null && (uri.hasScheme || trimmed.contains('/'))) {
      final String? token = joinTokenFromUri(uri);
      if (token != null && token.isNotEmpty) {
        return token;
      }
    }

    final int queryIndex = trimmed.indexOf('?');
    final int fragmentIndex = trimmed.indexOf('#');
    final int endIndex = <int>[
      if (queryIndex >= 0) queryIndex,
      if (fragmentIndex >= 0) fragmentIndex,
      trimmed.length,
    ].reduce((int a, int b) => a < b ? a : b);
    return trimmed.substring(0, endIndex).trim();
  }

  static String? joinTokenFromUri(Uri uri) {
    final List<String> segments = uri.pathSegments
        .map(Uri.decodeComponent)
        .where((String segment) => segment.trim().isNotEmpty)
        .toList();
    for (int index = 0; index < segments.length - 1; index += 1) {
      final String current = segments[index].toLowerCase();
      if (current != 'group' && current != 'pilot') {
        continue;
      }
      final bool hasEcoUnityLearningParent =
          index > 0 && segments[index - 1].toLowerCase() == 'ecounitylearning';
      if (hasEcoUnityLearningParent) {
        return segments[index + 1].trim();
      }
    }
    return null;
  }
}

class EcoUnityGroupEnrollmentException implements Exception {
  const EcoUnityGroupEnrollmentException(this.statusCode, this.message);

  final int? statusCode;
  final String message;

  @override
  String toString() =>
      'EcoUnityGroupEnrollmentException($statusCode, $message)';
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
  final String? message = decoded['message']?.toString().trim();
  if (message != null && message.isNotEmpty) {
    return message;
  }
  return 'Group enrollment link was not found or is not active.';
}
