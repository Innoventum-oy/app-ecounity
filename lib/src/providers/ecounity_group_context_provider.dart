import 'package:ecounity/src/analytics/ecounity_group_context.dart';
import 'package:ecounity/src/analytics/ecounity_group_enrollment_service.dart';
import 'package:flutter/foundation.dart';

class EcoUnityGroupContextProvider with ChangeNotifier {
  EcoUnityGroupContextProvider({EcoUnityGroupEnrollmentService? service})
    : _service = service ?? EcoUnityGroupEnrollmentService() {
    _load();
  }

  final EcoUnityGroupEnrollmentService _service;

  EcoUnityAnalyticsGroupContext? _currentGroup;
  bool _loaded = false;
  bool _enrolling = false;
  String? _error;

  EcoUnityAnalyticsGroupContext? get currentGroup => _currentGroup;
  bool get loaded => _loaded;
  bool get enrolling => _enrolling;
  String? get error => _error;

  Future<EcoUnityAnalyticsGroupContext> enrollWithCode(String code) async {
    _enrolling = true;
    _error = null;
    notifyListeners();
    try {
      final EcoUnityAnalyticsGroupContext group = await _service.enrollWithCode(
        code,
      );
      _currentGroup = group;
      _loaded = true;
      return group;
    } on EcoUnityGroupEnrollmentException catch (exception) {
      _error = exception.message;
      rethrow;
    } catch (_) {
      _error = 'Group enrollment link was not found or is not active.';
      rethrow;
    } finally {
      _enrolling = false;
      notifyListeners();
    }
  }

  Future<void> clearCurrentGroup() async {
    await _service.clearCurrentGroup();
    _currentGroup = null;
    _loaded = true;
    _error = null;
    notifyListeners();
  }

  Future<void> _load() async {
    _currentGroup = await _service.loadCurrentGroup();
    _loaded = true;
    notifyListeners();
  }
}
