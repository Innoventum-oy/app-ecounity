import 'dart:developer';

import 'package:core/core.dart';
import 'package:ecounity/src/objects/badge_status_item.dart';
import 'package:ecounity/src/objects/ecounity_badge.dart';
import 'package:ecounity/src/objects/pathway_stage.dart';
import 'package:ecounity/src/objects/pathway_status.dart';
import 'package:ecounity/src/objects/pathway_status_item.dart';
import 'package:ecounity/src/objects/pathway_type.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class EcoUnityStorage {
  final FileStorage _fileStorage;

  EcoUnityStorage(this._fileStorage);

  void _registerAppAdapter<T>(TypeAdapter<T> adapter) {
    if (_isAdapterRegisteredForType<T>()) {
      return;
    }

    if (Hive.isAdapterRegistered(adapter.typeId)) {
      // Web hot restart can leave Hive with a stale adapter for the numeric
      // typeId but no adapter for the current Dart runtime type.
      Hive.registerAdapter<T>(adapter, override: true);
    } else {
      Hive.registerAdapter<T>(adapter);
    }
  }

  bool _isAdapterRegisteredForType<T>() {
    try {
      return (Hive as dynamic).findAdapterForType<T>() != null;
    } catch (_) {
      return false;
    }
  }

  static bool completedPathwaysEqual(
    List<PathwayStatusItem>? first,
    List<PathwayStatusItem>? second,
  ) {
    first = normalizeCompletedPathways(first);
    second = normalizeCompletedPathways(second);

    if (identical(first, second)) {
      return true;
    }
    if (first == null || second == null) {
      return first == second;
    }
    if (first.length != second.length) {
      return false;
    }

    final normalizedFirst = [...first]
      ..sort((a, b) {
        final byId = a.id.compareTo(b.id);
        if (byId != 0) {
          return byId;
        }
        return a.status.index.compareTo(b.status.index);
      });
    final normalizedSecond = [...second]
      ..sort((a, b) {
        final byId = a.id.compareTo(b.id);
        if (byId != 0) {
          return byId;
        }
        return a.status.index.compareTo(b.status.index);
      });

    for (var index = 0; index < normalizedFirst.length; index++) {
      if (normalizedFirst[index].id != normalizedSecond[index].id ||
          normalizedFirst[index].status != normalizedSecond[index].status) {
        return false;
      }
    }

    return true;
  }

  static List<PathwayStatusItem>? normalizeCompletedPathways(
    Iterable<PathwayStatusItem>? items,
  ) {
    if (items == null) {
      return null;
    }

    final Map<int, PathwayStatusItem> latestById = <int, PathwayStatusItem>{};
    for (final PathwayStatusItem item in items.toList().reversed) {
      latestById.putIfAbsent(item.id, () => item);
    }

    return latestById.values.toList().reversed.toList();
  }

  // Register adapters once so startup retries and hot restarts stay safe.
  Future<void> registerAdapters() async {
    log('Ensuring adapters are registered', name: 'EcoUnityStorage');

    // Register app-specific adapters by Dart type, not just numeric typeId.
    // Hot restart on web can leave stale typeId entries behind.
    _registerAppAdapter<BadgeStatusItem>(BadgeStatusItemAdapter());
    _registerAppAdapter<EcoUnityBadge>(EcoUnityBadgeAdapter());
    _registerAppAdapter<PathwayStage>(PathwayStageAdapter());
    _registerAppAdapter<PathwayStatus>(PathwayStatusAdapter());
    _registerAppAdapter<PathwayStatusItem>(PathwayStatusItemAdapter());
    _registerAppAdapter<PathwayType>(PathwayTypeAdapter());

    log('All adapters ensured successfully', name: 'EcoUnityStorage');
  }

  Future<void> _purgeCompletedPathwaysStorage() async {
    try {
      final Box<dynamic>? box = await _fileStorage.init('userData');
      if (box == null) {
        return;
      }
      if (box.containsKey('completedPathways')) {
        await box.delete('completedPathways');
      }
    } catch (error) {
      log(
        'Failed to remove corrupted completedPathways entry: $error',
        name: 'EcoUnityStorage',
      );
    }
  }

  Future<List<PathwayStatusItem>?> getCompletedPathways() async {
    List<PathwayStatusItem>? items;
    try {
      items =
          (await _fileStorage.getObject(
                    'completedPathways',
                    boxName: 'userData',
                  )
                  as List<dynamic>?)
              ?.map((item) => item as PathwayStatusItem)
              .toList();
    } catch (error) {
      log(
        'Unable to read completedPathways Hive entry. Removing only that key: $error',
        name: 'EcoUnityStorage',
      );
      await _purgeCompletedPathwaysStorage();
      return <PathwayStatusItem>[];
    }

    return normalizeCompletedPathways(items);
  }
}
