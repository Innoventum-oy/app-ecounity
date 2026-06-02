import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../objects/pathway_status.dart';
import '../objects/pathway_status_item.dart';

class SelectedPathwayNotifier extends ValueNotifier<WebPage?> {
  SelectedPathwayNotifier() : super(null);

  void select(WebPage? page) {
    if (_samePage(value, page)) {
      return;
    }
    value = page;
  }

  void selectFirstIncomplete(
    List<WebPage> candidates,
    List<PathwayStatusItem>? statusItems,
  ) {
    select(_firstIncomplete(candidates, statusItems));
  }

  void reconcileSelection(
    List<WebPage> candidates,
    List<PathwayStatusItem>? statusItems,
  ) {
    final WebPage? currentSelection = candidates.firstWhereOrNull(
      (item) => item.id == value?.id,
    );

    if (currentSelection != null &&
        !_isCompleted(currentSelection, statusItems)) {
      select(currentSelection);
      return;
    }

    selectFirstIncomplete(candidates, statusItems);
  }

  static bool _samePage(WebPage? first, WebPage? second) {
    if (identical(first, second)) {
      return true;
    }
    return first?.id == second?.id;
  }

  static WebPage? _firstIncomplete(
    List<WebPage> candidates,
    List<PathwayStatusItem>? statusItems,
  ) {
    return candidates.firstWhereOrNull(
      (item) => !_isCompleted(item, statusItems),
    );
  }

  static bool _isCompleted(WebPage page, List<PathwayStatusItem>? statusItems) {
    final PathwayStatus? status = statusItems
        ?.firstWhereOrNull((item) => item.id == page.id)
        ?.status;
    return status == PathwayStatus.completed;
  }
}
