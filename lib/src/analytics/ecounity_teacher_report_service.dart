import 'dart:convert';

import 'package:core/core.dart' as core;
import 'package:ecounity/src/analytics/ecounity_teacher_report_models.dart';
import 'package:http/http.dart' as http;

abstract class EcoUnityTeacherReportTransport {
  Future<Map<String, dynamic>> getJson(String path);
}

class EcoUnityHttpTeacherReportTransport
    implements EcoUnityTeacherReportTransport {
  EcoUnityHttpTeacherReportTransport({
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
    throw EcoUnityTeacherReportException(
      response.statusCode,
      _readErrorMessage(decoded),
    );
  }
}

class EcoUnityTeacherReportService {
  EcoUnityTeacherReportService({EcoUnityTeacherReportTransport? transport})
    : _transport = transport ?? EcoUnityHttpTeacherReportTransport();

  final EcoUnityTeacherReportTransport _transport;

  Future<EcoUnityTeacherGroupReport> loadReport(String input) async {
    final String teacherToken = normalizeTeacherToken(input);
    if (teacherToken.isEmpty) {
      throw const EcoUnityTeacherReportException(
        null,
        'Enter a teacher token.',
      );
    }

    final Map<String, dynamic> response = await _transport.getJson(
      '/api/ecounitylearning/groups/${Uri.encodeComponent(teacherToken)}/report',
    );
    final String status = '${response['status'] ?? ''}'.toLowerCase();
    if (status == 'error') {
      throw EcoUnityTeacherReportException(null, _readErrorMessage(response));
    }

    final EcoUnityTeacherGroupReport report =
        EcoUnityTeacherGroupReport.fromApiResponse(
          response,
          teacherToken: teacherToken,
        );
    if (report.teacherToken.isEmpty) {
      throw const EcoUnityTeacherReportException(
        null,
        'Group report token was not found.',
      );
    }
    return report;
  }

  static String normalizeTeacherToken(String input) {
    final StringBuffer buffer = StringBuffer();
    for (final int codeUnit in input.trim().codeUnits) {
      if (codeUnit > 32) {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString().toUpperCase();
  }
}

class EcoUnityTeacherReportException implements Exception {
  const EcoUnityTeacherReportException(this.statusCode, this.message);

  final int? statusCode;
  final String message;

  @override
  String toString() => 'EcoUnityTeacherReportException($statusCode, $message)';
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
  return 'Group report token was not found.';
}
