import 'package:core/core.dart' as core;
import 'package:ecounity/src/learning/ecounity_content_review_service.dart';
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:flutter/foundation.dart';

class EcoUnityContentReviewProvider with ChangeNotifier {
  EcoUnityContentReviewProvider({EcoUnityContentReviewService? service})
    : _service = service ?? EcoUnityContentReviewService();

  final EcoUnityContentReviewService _service;

  final Map<String, EcoUnityContentReviewRecord> _records =
      <String, EcoUnityContentReviewRecord>{};
  final Map<String, Future<EcoUnityContentReviewRecord?>> _loadFutures =
      <String, Future<EcoUnityContentReviewRecord?>>{};
  final Map<String, Future<List<EcoUnityContentReviewRecord>>> _queueFutures =
      <String, Future<List<EcoUnityContentReviewRecord>>>{};
  final Set<String> _loadingKeys = <String>{};
  final Set<String> _queueLoadingKeys = <String>{};
  final Set<String> _savingKeys = <String>{};
  final Map<String, String> _errors = <String, String>{};
  final Map<String, String> _queueErrors = <String, String>{};

  String? _permissionUserKey;
  bool? _canReview;
  bool _checkingPermission = false;
  String? _permissionError;
  Future<bool>? _permissionFuture;

  bool get checkingPermission => _checkingPermission;
  String? get permissionError => _permissionError;

  bool hasPermissionResultFor(core.User user) {
    return _permissionUserKey == _userKey(user) && _canReview != null;
  }

  bool canReviewFor(core.User user) {
    return _permissionUserKey == _userKey(user) && _canReview == true;
  }

  EcoUnityContentReviewRecord? recordFor({
    required EcoUnityReviewScope scope,
    required int objectId,
    required String language,
  }) {
    return _records[_reviewKey(scope, objectId, language)];
  }

  bool isLoading({
    required EcoUnityReviewScope scope,
    required int objectId,
    required String language,
  }) {
    return _loadingKeys.contains(_reviewKey(scope, objectId, language));
  }

  bool isSaving({
    required EcoUnityReviewScope scope,
    required int objectId,
    required String language,
  }) {
    return _savingKeys.contains(_reviewKey(scope, objectId, language));
  }

  String? errorFor({
    required EcoUnityReviewScope scope,
    required int objectId,
    required String language,
  }) {
    return _errors[_reviewKey(scope, objectId, language)];
  }

  bool isSdgReviewQueueLoading({
    required int moduleId,
    required String language,
    required core.User user,
  }) {
    return _queueLoadingKeys.contains(_queueKey(moduleId, language, user));
  }

  String? sdgReviewQueueErrorFor({
    required int moduleId,
    required String language,
    required core.User user,
  }) {
    return _queueErrors[_queueKey(moduleId, language, user)];
  }

  Future<bool> ensureReviewAccess(core.User user) {
    if (!_isLoggedInReviewerCandidate(user)) {
      _setPermission(user, false);
      return Future<bool>.value(false);
    }

    final String userKey = _userKey(user);
    if (_permissionUserKey == userKey && _canReview != null) {
      return Future<bool>.value(_canReview!);
    }

    final Future<bool>? current = _permissionFuture;
    if (_permissionUserKey == userKey && current != null) {
      return current;
    }

    _permissionUserKey = userKey;
    _canReview = null;
    _permissionError = null;
    _checkingPermission = true;
    notifyListeners();

    late final Future<bool> future;
    future = _service
        .canModifyLearningContent(user: user)
        .then((bool canReview) {
          if (_permissionUserKey == userKey) {
            _canReview = canReview;
          }
          return canReview;
        })
        .catchError((Object error) {
          if (_permissionUserKey == userKey) {
            _canReview = false;
            _permissionError = error.toString();
          }
          return false;
        })
        .whenComplete(() {
          if (_permissionUserKey == userKey) {
            _checkingPermission = false;
            _permissionFuture = null;
            notifyListeners();
          }
        });
    _permissionFuture = future;
    return future;
  }

  Future<EcoUnityContentReviewRecord?> loadReview({
    required core.User user,
    required EcoUnityReviewScope scope,
    required int objectId,
    required String language,
    EcoUnityContentStatus fallbackStatus = EcoUnityContentStatus.unknown,
  }) async {
    final bool canReview = await ensureReviewAccess(user);
    if (!canReview) {
      return null;
    }

    final String key = _reviewKey(scope, objectId, language);
    final EcoUnityContentReviewRecord? cached = _records[key];
    if (cached != null) {
      return cached;
    }

    final Future<EcoUnityContentReviewRecord?>? current = _loadFutures[key];
    if (current != null) {
      return current;
    }

    _loadingKeys.add(key);
    _errors.remove(key);
    notifyListeners();

    late final Future<EcoUnityContentReviewRecord?> future;
    future = () async {
      try {
        final EcoUnityContentReviewRecord record = await _service.loadReview(
          user: user,
          scope: scope,
          objectId: objectId,
          language: language,
          fallbackStatus: fallbackStatus,
        );
        _records[key] = record;
        return record;
      } catch (error) {
        _errors[key] = error.toString();
        return null;
      } finally {
        _loadingKeys.remove(key);
        _loadFutures.remove(key);
        notifyListeners();
      }
    }();
    _loadFutures[key] = future;
    return future;
  }

  Future<List<EcoUnityContentReviewRecord>> loadSdgReviewQueue({
    required core.User user,
    required int moduleId,
    required String language,
  }) async {
    final bool canReview = await ensureReviewAccess(user);
    if (!canReview) {
      return const <EcoUnityContentReviewRecord>[];
    }

    final String key = _queueKey(moduleId, language, user);
    final Future<List<EcoUnityContentReviewRecord>>? current =
        _queueFutures[key];
    if (current != null) {
      return current;
    }

    _queueLoadingKeys.add(key);
    _queueErrors.remove(key);
    notifyListeners();

    late final Future<List<EcoUnityContentReviewRecord>> future;
    future = () async {
      try {
        final EcoUnitySdgReviewQueue queue = await _service.loadSdgReviewQueue(
          user: user,
          moduleId: moduleId,
          language: language,
        );
        for (final EcoUnityContentReviewRecord record in queue.records) {
          _records[_reviewKey(record.scope, record.scopeId, record.language)] =
              record;
        }
        return queue.records;
      } catch (error) {
        _queueErrors[key] = error.toString();
        return const <EcoUnityContentReviewRecord>[];
      } finally {
        _queueLoadingKeys.remove(key);
        _queueFutures.remove(key);
        notifyListeners();
      }
    }();
    _queueFutures[key] = future;
    return future;
  }

  Future<EcoUnityContentReviewRecord> updateReview({
    required core.User user,
    required EcoUnityReviewScope scope,
    required int objectId,
    required String language,
    required EcoUnityReviewStatus reviewStatus,
    String? comment,
  }) async {
    final bool canReview = await ensureReviewAccess(user);
    if (!canReview) {
      throw const EcoUnityContentReviewException(
        403,
        'This account cannot review EcoUnity content.',
      );
    }

    final String key = _reviewKey(scope, objectId, language);
    _savingKeys.add(key);
    _errors.remove(key);
    notifyListeners();
    try {
      final EcoUnityContentReviewRecord record = await _service.updateReview(
        user: user,
        scope: scope,
        objectId: objectId,
        language: language,
        reviewStatus: reviewStatus,
        comment: comment,
      );
      _records[key] = record;
      return record;
    } catch (error) {
      _errors[key] = error.toString();
      rethrow;
    } finally {
      _savingKeys.remove(key);
      notifyListeners();
    }
  }

  void _setPermission(core.User user, bool canReview) {
    final String userKey = _userKey(user);
    if (_permissionUserKey == userKey && _canReview == canReview) {
      return;
    }
    _permissionUserKey = userKey;
    _canReview = canReview;
    _permissionError = null;
    _checkingPermission = false;
    _permissionFuture = null;
    notifyListeners();
  }
}

bool _isLoggedInReviewerCandidate(core.User user) {
  return user.id != null &&
      !user.isGuestUser &&
      (user.token?.trim().isNotEmpty ?? false);
}

String _reviewKey(EcoUnityReviewScope scope, int objectId, String language) {
  return '${scope.wireName}:$objectId:${_normalizeLanguage(language)}';
}

String _queueKey(int moduleId, String language, core.User user) {
  return '$moduleId:${_normalizeLanguage(language)}:${_userKey(user)}';
}

String _userKey(core.User user) {
  return '${user.id ?? ''}:${user.token ?? ''}';
}

String _normalizeLanguage(String language) {
  final String normalized = language.trim().toLowerCase();
  return normalized.isEmpty ? 'en' : normalized;
}
