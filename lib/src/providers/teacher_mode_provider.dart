import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherModeProvider with ChangeNotifier {
  TeacherModeProvider() {
    _load();
  }

  static const String _storageKey = 'ecounity_teacher_mode';

  bool _isTeacherMode = false;
  bool _loaded = false;

  bool get isTeacherMode => _isTeacherMode;
  bool get loaded => _loaded;

  Future<void> setTeacherMode(bool enabled) async {
    if (_isTeacherMode == enabled && _loaded) {
      return;
    }
    _isTeacherMode = enabled;
    _loaded = true;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, enabled);
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isTeacherMode = prefs.getBool(_storageKey) ?? false;
    _loaded = true;
    notifyListeners();
  }
}
