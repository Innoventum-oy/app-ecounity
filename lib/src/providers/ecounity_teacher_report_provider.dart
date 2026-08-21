import 'package:core/core.dart' as core;
import 'package:ecounity/src/analytics/ecounity_teacher_report_models.dart';
import 'package:ecounity/src/analytics/ecounity_teacher_report_service.dart';
import 'package:flutter/foundation.dart';

class EcoUnityTeacherReportProvider with ChangeNotifier {
  EcoUnityTeacherReportProvider({
    EcoUnityTeacherReportService? service,
    EcoUnityTeacherReportStore? store,
  }) : _service = service ?? EcoUnityTeacherReportService(),
       _store = store ?? EcoUnityTeacherReportStore() {
    _load();
  }

  final EcoUnityTeacherReportService _service;
  final EcoUnityTeacherReportStore _store;

  final List<EcoUnityTeacherGroupReport> _reports =
      <EcoUnityTeacherGroupReport>[];
  String? _activeTeacherToken;
  bool _loaded = false;
  bool _loading = false;
  String? _error;

  List<EcoUnityTeacherGroupReport> get reports =>
      List<EcoUnityTeacherGroupReport>.unmodifiable(_reports);
  bool get loaded => _loaded;
  bool get loading => _loading;
  String? get error => _error;
  String? get activeTeacherToken => _activeTeacherToken;

  EcoUnityTeacherGroupReport? get activeReport {
    if (_reports.isEmpty) {
      return null;
    }
    final String? activeToken = _activeTeacherToken;
    if (activeToken != null) {
      for (final EcoUnityTeacherGroupReport report in _reports) {
        if (report.teacherToken == activeToken) {
          return report;
        }
      }
    }
    return _reports.first;
  }

  Future<EcoUnityTeacherGroupReport> addOrRefreshToken(String input) async {
    final String teacherToken =
        EcoUnityTeacherReportService.normalizeTeacherToken(input);
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final EcoUnityTeacherGroupReport report = await _service.loadReport(
        teacherToken,
      );
      _upsert(report);
      _activeTeacherToken = report.teacherToken;
      _loaded = true;
      await _save();
      return report;
    } on EcoUnityTeacherReportException catch (exception) {
      _error = exception.message;
      rethrow;
    } catch (_) {
      _error = 'Group report token was not found.';
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshActiveReport() async {
    final EcoUnityTeacherGroupReport? report = activeReport;
    if (report == null) {
      return;
    }
    await addOrRefreshToken(report.teacherToken);
  }

  Future<void> refreshReport(EcoUnityTeacherGroupReport report) async {
    await addOrRefreshToken(report.teacherToken);
  }

  Future<void> selectReport(String teacherToken) async {
    final String normalized =
        EcoUnityTeacherReportService.normalizeTeacherToken(teacherToken);
    if (!_reports.any((EcoUnityTeacherGroupReport report) {
      return report.teacherToken == normalized;
    })) {
      return;
    }
    _activeTeacherToken = normalized;
    _error = null;
    await _save();
    notifyListeners();
  }

  Future<void> removeReport(String teacherToken) async {
    final String normalized =
        EcoUnityTeacherReportService.normalizeTeacherToken(teacherToken);
    _reports.removeWhere((EcoUnityTeacherGroupReport report) {
      return report.teacherToken == normalized;
    });
    if (_activeTeacherToken == normalized) {
      _activeTeacherToken = _reports.isEmpty
          ? null
          : _reports.first.teacherToken;
    }
    _error = null;
    await _save();
    notifyListeners();
  }

  Future<void> _load() async {
    final EcoUnityTeacherReportStoreData stored = await _store.load();
    _reports
      ..clear()
      ..addAll(stored.reports);
    _activeTeacherToken = stored.activeTeacherToken;
    if (_activeTeacherToken == null && _reports.isNotEmpty) {
      _activeTeacherToken = _reports.first.teacherToken;
    }
    _loaded = true;
    notifyListeners();
  }

  void _upsert(EcoUnityTeacherGroupReport report) {
    final int index = _reports.indexWhere((EcoUnityTeacherGroupReport item) {
      return item.teacherToken == report.teacherToken;
    });
    if (index >= 0) {
      _reports[index] = report;
    } else {
      _reports.add(report);
    }
  }

  Future<void> _save() {
    return _store.save(
      reports: _reports,
      activeTeacherToken: _activeTeacherToken,
    );
  }
}

class EcoUnityTeacherReportStoreData {
  const EcoUnityTeacherReportStoreData({
    required this.reports,
    this.activeTeacherToken,
  });

  final List<EcoUnityTeacherGroupReport> reports;
  final String? activeTeacherToken;
}

class EcoUnityTeacherReportStore {
  EcoUnityTeacherReportStore({
    core.FileStorage? fileStorage,
    this.boxName = 'ecounityAnalytics',
  }) : _fileStorage = fileStorage ?? core.FileStorage();

  static const String storageKey = 'teacher_group_reports';

  final core.FileStorage _fileStorage;
  final String boxName;

  Future<EcoUnityTeacherReportStoreData> load() async {
    final Object? stored = await _fileStorage.getObject(
      storageKey,
      boxName: boxName,
    );
    if (stored is Map) {
      final Map<String, dynamic> json = Map<String, dynamic>.from(stored);
      return EcoUnityTeacherReportStoreData(
        reports: _readStoredReports(json['reports']),
        activeTeacherToken: _readOptionalString(
          json['active_teacher_token'] ?? json['activeTeacherToken'],
        ),
      );
    }
    if (stored is List) {
      return EcoUnityTeacherReportStoreData(
        reports: _readStoredReports(stored),
      );
    }
    return const EcoUnityTeacherReportStoreData(
      reports: <EcoUnityTeacherGroupReport>[],
    );
  }

  Future<void> save({
    required List<EcoUnityTeacherGroupReport> reports,
    required String? activeTeacherToken,
  }) {
    return _fileStorage.setObject(storageKey, <String, dynamic>{
      'active_teacher_token': activeTeacherToken,
      'reports': reports.map((EcoUnityTeacherGroupReport report) {
        return report.toJson();
      }).toList(),
    }, boxName: boxName);
  }
}

List<EcoUnityTeacherGroupReport> _readStoredReports(Object? value) {
  if (value is! List) {
    return const <EcoUnityTeacherGroupReport>[];
  }
  return value
      .whereType<Map>()
      .map((Map item) {
        return EcoUnityTeacherGroupReport.fromJson(
          Map<String, dynamic>.from(item),
        );
      })
      .where((EcoUnityTeacherGroupReport report) {
        return report.teacherToken.isNotEmpty;
      })
      .toList();
}

String? _readOptionalString(Object? value) {
  final String? text = value?.toString().trim();
  if (text == null || text.isEmpty || text == 'null') {
    return null;
  }
  return text;
}
