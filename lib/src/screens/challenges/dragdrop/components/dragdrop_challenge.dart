import 'dart:developer';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:core/core.dart' as core;
import 'package:ecounity/src/objects/drag_drop_item.dart';
import 'package:ecounity/src/util/image_from_url.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../../../l10n/app_localizations_extension.dart';
import '../../../../util/core_compat.dart';
import 'grid_drag_drop_widget.dart';

typedef DragDropStateCallback = void Function(Map<String, dynamic> state);
typedef DragDropCompletedCallback = void Function(bool passed);

const bool _screenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');

class DragDropChallenge extends StatefulWidget {
  const DragDropChallenge({
    super.key,
    required this.onCompleted,
    required this.images,
    this.initialState,
    this.onStateChanged,
    this.onRestart,
  });

  final DragDropCompletedCallback onCompleted;
  final List<core.ImageObject> images;
  final Map<String, dynamic>? initialState;
  final DragDropStateCallback? onStateChanged;
  final VoidCallback? onRestart;

  @override
  DragDropChallengeState createState() => DragDropChallengeState();
}

class DragDropChallengeState extends State<DragDropChallenge> {
  List<DragDropItem> draggableItems = [];
  List<DragDropItem> dragTargets = [];
  List<DragDropItem> combinedItems = [];
  bool loaded = false;
  int itemsLeft = 0;
  int correctAnswers = 0;
  int incorrectAnswers = 0;
  double _gridAspectRatio = 1.0;
  int _ratioRequestToken = 0;

  bool get _isChallengeComplete =>
      dragTargets.isNotEmpty && dragTargets.every((item) => item.isAccepted);

  String _normalizeMatchId(String rawId) {
    if (rawId.startsWith('image-')) {
      return rawId.substring(6);
    }
    if (rawId.startsWith('text-')) {
      return rawId.substring(5);
    }
    return rawId;
  }

  void _trackAcceptedId(Set<String> acceptedDraggables, String rawId) {
    final String normalized = _normalizeMatchId(rawId);
    acceptedDraggables
      ..add(rawId)
      ..add(normalized)
      ..add('image-$normalized')
      ..add('text-$normalized');
  }

  bool _isAcceptedDrag(String value, Set<String> acceptedDraggables) {
    final String normalized = _normalizeMatchId(value);
    return acceptedDraggables.contains(value) ||
        acceptedDraggables.contains(normalized) ||
        acceptedDraggables.contains('image-$normalized') ||
        acceptedDraggables.contains('text-$normalized');
  }

  DragDropItem? _findByIdSuffix(Map<String, DragDropItem> items, String rawId) {
    final String normalized = _normalizeMatchId(rawId);
    final String imagePrefixed = 'image-$normalized';
    final String textPrefixed = 'text-$normalized';

    return items.entries
        .firstWhereOrNull(
          (MapEntry<String, DragDropItem> entry) =>
              entry.key == rawId ||
              entry.key == normalized ||
              entry.key == imagePrefixed ||
              entry.key == textPrefixed ||
              entry.key.endsWith('-$normalized'),
        )
        ?.value;
  }

  DragDropItem? _findDraggableByLegacyId(
    Map<String, DragDropItem> draggablesByValue,
    String rawId,
  ) {
    final DragDropItem? bySuffix = _findByIdSuffix(draggablesByValue, rawId);
    if (bySuffix != null) {
      return bySuffix;
    }

    final String exact = rawId;
    if (draggablesByValue.containsKey(exact)) {
      return draggablesByValue[exact];
    }

    final String normalized = _normalizeMatchId(rawId);
    if (draggablesByValue.containsKey('image-$normalized')) {
      return draggablesByValue['image-$normalized'];
    }

    if (draggablesByValue.containsKey('text-$normalized')) {
      return draggablesByValue['text-$normalized'];
    }

    return draggablesByValue[normalized];
  }

  DragDropItem? _findTargetByLegacyId(
    Map<String, DragDropItem> targetsByKey,
    String rawId,
  ) {
    final DragDropItem? bySuffix = _findByIdSuffix(targetsByKey, rawId);
    if (bySuffix != null) {
      return bySuffix;
    }

    final String exact = rawId;
    if (targetsByKey.containsKey(exact)) {
      return targetsByKey[exact];
    }

    final String normalized = _normalizeMatchId(rawId);
    if (targetsByKey.containsKey('image-$normalized')) {
      return targetsByKey['image-$normalized'];
    }

    if (targetsByKey.containsKey('text-$normalized')) {
      return targetsByKey['text-$normalized'];
    }

    return targetsByKey[normalized];
  }

  Map<String, dynamic>? _findTargetPair(
    Map<String, Map<String, dynamic>> targetPairs,
    String rawId,
  ) {
    final Map<String, dynamic>? bySuffix = targetPairs.entries
        .firstWhereOrNull(
          (MapEntry<String, Map<String, dynamic>> entry) =>
              entry.key == rawId ||
              entry.key == _normalizeMatchId(rawId) ||
              entry.key == 'image-${_normalizeMatchId(rawId)}' ||
              entry.key == 'text-${_normalizeMatchId(rawId)}' ||
              entry.key.endsWith('-${_normalizeMatchId(rawId)}'),
        )
        ?.value;
    if (bySuffix != null) {
      return bySuffix;
    }

    final String exact = rawId;
    final Map<String, dynamic>? exactPair = targetPairs[exact];
    if (exactPair != null) {
      return exactPair;
    }

    final String normalized = _normalizeMatchId(rawId);
    final Map<String, dynamic>? imagePrefixedPair =
        targetPairs['image-$normalized'];
    if (imagePrefixedPair != null) {
      return imagePrefixedPair;
    }

    return targetPairs['text-$normalized'] ?? targetPairs[normalized];
  }

  double? _parseDimension(dynamic value) {
    if (value is int) {
      return value.toDouble();
    }
    if (value is double) {
      return value;
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  double? _readImageDimension(core.ImageObject image, String key) {
    final double? value = _parseDimension(image.getValue(key));
    if (value != null && value > 0) {
      return value;
    }
    return null;
  }

  double? _resolveImageRatioFromMetadata(core.ImageObject image) {
    final double? width =
        _readImageDimension(image, 'width') ??
        _readImageDimension(image, 'imagewidth') ??
        _readImageDimension(image, 'imageWidth') ??
        _readImageDimension(image, 'imgWidth') ??
        _readImageDimension(image, 'thumbnailwidth') ??
        _readImageDimension(image, 'thumbnailWidth');
    final double? height =
        _readImageDimension(image, 'height') ??
        _readImageDimension(image, 'imageheight') ??
        _readImageDimension(image, 'imageHeight') ??
        _readImageDimension(image, 'imgHeight') ??
        _readImageDimension(image, 'thumbnailheight') ??
        _readImageDimension(image, 'thumbnailHeight');

    if (width == null || height == null || height <= 0) {
      return null;
    }

    return width / height;
  }

  double? _resolveImageAspectRatio(core.ImageObject image) =>
      _resolveImageRatioFromMetadata(image);

  double _chooseUniformAspectRatio(List<double> ratios) {
    if (ratios.isEmpty) {
      return 1.0;
    }

    final List<double> normalizedRatios = List<double>.from(ratios)
      ..sort((double a, double b) => a.compareTo(b));
    final int mid = normalizedRatios.length ~/ 2;
    return normalizedRatios[mid].clamp(0.5, 2.5).toDouble();
  }

  Future<double> _resolveGridAspectRatio() async {
    if (widget.images.isEmpty) {
      return 1.0;
    }

    final Iterable<double?> ratios = widget.images.map(
      _resolveImageAspectRatio,
    );
    final List<double> usableRatios = ratios.whereType<double>().toList()
      ..removeWhere((double ratio) => ratio <= 0 || ratio > 10 || ratio < 0.2);
    return _chooseUniformAspectRatio(usableRatios);
  }

  @override
  void initState() {
    super.initState();
    _initializeChallenge(initialState: widget.initialState, notify: false);
  }

  @override
  void didUpdateWidget(covariant DragDropChallenge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.images, widget.images) ||
        !_initialStatesEqual(oldWidget.initialState, widget.initialState)) {
      _initializeChallenge(initialState: widget.initialState);
    }
  }

  Future<void> _initializeChallenge({
    Map<String, dynamic>? initialState,
    bool notify = true,
  }) async {
    final int requestToken = ++_ratioRequestToken;
    final double resolvedRatio = await _resolveGridAspectRatio();
    if (!mounted || requestToken != _ratioRequestToken) {
      return;
    }

    if (_gridAspectRatio != resolvedRatio) {
      setState(() {
        _gridAspectRatio = resolvedRatio;
      });
    }

    reset(notify: notify, initialState: initialState);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Map<String, DragDropItem> _getDragDropImagesByValue(
    List<DragDropItem> items,
  ) => {for (final item in items) item.value: item};

  void _restoreFromState(Map<String, dynamic> state) {
    if (widget.images.isEmpty) {
      loaded = true;
      return;
    }

    final Map<String, DragDropItem> targetsByKey = _getDragDropImagesByKey(
      dragTargets,
    );
    final Map<String, DragDropItem> draggablesByValue =
        _getDragDropImagesByValue(draggableItems);

    final Map<String, Map<String, dynamic>> targetPairs = {};
    final dynamic storedPairs = state['targetPairs'];
    if (storedPairs is List) {
      for (final dynamic rawPair in storedPairs) {
        if (rawPair is! Map) {
          continue;
        }

        final String? target = rawPair['target']?.toString();
        if (target == null) {
          continue;
        }

        final String? draggedFrom = rawPair['draggedFrom']?.toString();
        if (draggedFrom == null) {
          continue;
        }

        targetPairs[target] = {
          'draggedFrom': draggedFrom,
          'isCorrect': rawPair['isCorrect'] == true,
        };
      }
    }

    final Set<String> acceptedDraggables = <String>{};
    final Set<String> restoredTargets = <String>{};
    final List<DragDropItem> orderedItems = [];
    final dynamic storedOrder = state['combinedOrder'];

    final bool hasStoredOrder = storedOrder is List;
    if (hasStoredOrder) {
      for (final dynamic rawOrderItem in storedOrder) {
        if (rawOrderItem is! Map) {
          continue;
        }
        final String? type = rawOrderItem['type']?.toString();
        final String? id = rawOrderItem['id']?.toString();
        if (type == null || id == null) {
          continue;
        }

        if (type == 'target') {
          final DragDropItem? target = _findTargetByLegacyId(targetsByKey, id);
          if (target == null) {
            continue;
          }
          restoredTargets.add(target.key);

          final Map<String, dynamic>? pair = _findTargetPair(targetPairs, id);
          if (pair != null) {
            final String? draggedFrom = pair['draggedFrom']?.toString();
            if (draggedFrom != null) {
              final DragDropItem? draggable = _findDraggableByLegacyId(
                draggablesByValue,
                draggedFrom,
              );
              target.isAccepted = true;
              target.isCorrect = pair['isCorrect'] == true;
              target.acceptedFromValue = draggable?.value ?? draggedFrom;
              target.draggedItem = draggable?.dragChild ?? draggable?.dropChild;
              if (draggable != null) {
                _trackAcceptedId(acceptedDraggables, draggable.value);
              } else {
                _trackAcceptedId(acceptedDraggables, draggedFrom);
              }
            }
          }
          orderedItems.add(target);
          continue;
        }

        if (type == 'draggable') {
          final DragDropItem? draggable =
              draggablesByValue[id] ??
              _findDraggableByLegacyId(draggablesByValue, id);
          if (draggable == null ||
              draggable.isAccepted ||
              _isAcceptedDrag(id, acceptedDraggables) ||
              _isAcceptedDrag(draggable.value, acceptedDraggables)) {
            continue;
          }
          orderedItems.add(draggable);
        }
      }
    } else if (targetPairs.isNotEmpty) {
      for (final MapEntry<String, Map<String, dynamic>> entry
          in targetPairs.entries) {
        final DragDropItem? target = _findTargetByLegacyId(
          targetsByKey,
          entry.key,
        );
        if (target == null) {
          continue;
        }

        if (!restoredTargets.contains(target.key)) {
          restoredTargets.add(target.key);
        }

        final String? draggedFrom = entry.value['draggedFrom']?.toString();
        if (draggedFrom != null) {
          final DragDropItem? draggable = _findDraggableByLegacyId(
            draggablesByValue,
            draggedFrom,
          );
          target.isAccepted = true;
          target.isCorrect = entry.value['isCorrect'] == true;
          target.acceptedFromValue = draggable?.value ?? draggedFrom;
          target.draggedItem = draggable?.dragChild ?? draggable?.dropChild;
          final String acceptedFrom = target.acceptedFromValue ?? draggedFrom;
          _trackAcceptedId(acceptedDraggables, acceptedFrom);
          orderedItems.add(target);
        }
      }
    }

    for (final MapEntry<String, Map<String, dynamic>> entry
        in targetPairs.entries) {
      final DragDropItem? target = _findTargetByLegacyId(
        targetsByKey,
        entry.key,
      );
      if (target == null || restoredTargets.contains(target.key)) {
        continue;
      }

      final String? draggedFrom = entry.value['draggedFrom']?.toString();
      if (draggedFrom != null) {
        final DragDropItem? draggable = _findDraggableByLegacyId(
          draggablesByValue,
          draggedFrom,
        );
        target.isAccepted = true;
        target.isCorrect = entry.value['isCorrect'] == true;
        target.acceptedFromValue = draggable?.value ?? draggedFrom;
        target.draggedItem = draggable?.dragChild ?? draggable?.dropChild;
        final String acceptedFrom = target.acceptedFromValue ?? draggedFrom;
        _trackAcceptedId(acceptedDraggables, acceptedFrom);
      }
      orderedItems.add(target);
    }

    draggableItems = [
      for (final DragDropItem item in draggablesByValue.values.where(
        (el) => !_isAcceptedDrag(el.value, acceptedDraggables),
      ))
        item,
    ];

    final Set<String> alreadyAdded = {
      for (final DragDropItem item in orderedItems)
        item.isDraggable ? item.value : item.key,
    };
    for (final DragDropItem target in dragTargets) {
      final String key = target.key;
      if (!alreadyAdded.contains(key)) {
        orderedItems.add(target);
      }
    }
    for (final DragDropItem draggable in draggableItems) {
      final String id = draggable.value;
      if (!alreadyAdded.contains(id)) {
        orderedItems.add(draggable);
      }
    }

    combinedItems = orderedItems;
    itemsLeft = draggableItems.length;
    correctAnswers = state['correctAnswers'] is int
        ? state['correctAnswers'] as int
        : int.tryParse('${state['correctAnswers']}') ?? 0;
    incorrectAnswers = state['incorrectAnswers'] is int
        ? state['incorrectAnswers'] as int
        : int.tryParse('${state['incorrectAnswers']}') ?? 0;
    final int loadedItemsLeft = state['itemsLeft'] is int
        ? state['itemsLeft'] as int
        : int.tryParse('${state['itemsLeft']}') ?? itemsLeft;
    itemsLeft = loadedItemsLeft.clamp(0, draggableItems.length);

    if (!mounted) {
      loaded = true;
      _notifyStateChanged();
      return;
    }
    setState(() {
      loaded = true;
    });
    _notifyStateChanged();
  }

  void reset({bool notify = true, Map<String, dynamic>? initialState}) {
    /// Reset state variables
    draggableItems = [];
    dragTargets = [];
    combinedItems = [];
    loaded = false;
    itemsLeft = 0;
    correctAnswers = 0;
    incorrectAnswers = 0;

    /// Create draggable items and drag target
    for (core.ImageObject image in widget.images) {
      final String? imageUrl = image.imageUrl;
      if (imageUrl == null || imageUrl.isEmpty) {
        if (kDebugMode) {
          log('Skipping drag/drop image ${image.id} because imageUrl is empty');
        }
        continue;
      }

      Widget imageWidget = Card(
        child: AspectRatio(
          aspectRatio: _gridAspectRatio,
          child: ImageFromUrl.get(
            imageUrl,
            fillContainer: true,
            loadedKey: dragTargets.isEmpty
                ? const ValueKey('screenshot-content-dragdrop-loaded')
                : null,
          ),
          //   child: Image.asset('assets/images/ecounity-logo.png'),
        ),
      );
      // The child when dragging is just a plain grey card with no text
      Widget emptyGreyCard = Container(
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.35),
          borderRadius: BorderRadius.zero,
        ),
        child: const Center(child: Text('')),
      );

      Widget dragItemContent = DecoratedBox(
        decoration: BoxDecoration(
          color: const Color.fromARGB(210, 225, 245, 254),
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: const Color.fromARGB(130, 144, 202, 249),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (image.getValue('title') != null)
                      Text(
                        image.getValue('title') ??
                            '${context.l10n.no_title} ${image.id}',
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    if (image.getValue('text') != null)
                      const SizedBox(height: 8),
                    if (image.getValue('text') != null)
                      Expanded(
                        child: ClipRect(
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: HtmlWidget(
                              image.getValue('text'),
                              textStyle: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      Widget dragItem = dragItemContent;
      // Create dropchild using the dragItemContent, placing it on a translucent grey card
      Widget dropChild = Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(170, 200, 245, 204),
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: const Color.fromARGB(130, 129, 199, 132),
            width: 1,
          ),
        ),
        child: dragItemContent,
      );
      // Add the image titles as draggable items
      draggableItems.add(
        DragDropItem(
          key: 'text-${image.id}',
          dragChild: dragItem,
          childWhenDragging: emptyGreyCard,
          dropChild: dropChild,
          value: 'image-${image.id}',
        ),
      );
      // Add the images as drag targets
      dragTargets.add(
        DragDropItem(
          key: 'image-${image.id}',
          dragChild: null,
          dropChild: imageWidget,
          value: 'text-${image.id}',
        ),
      );
    }

    if (initialState != null) {
      _restoreFromState(initialState);
      return;
    }

    combinedItems = _screenshotMode
        ? _screenshotOrderedItems()
        : [...draggableItems, ...dragTargets];
    if (!_screenshotMode) {
      combinedItems.shuffle();
    }
    itemsLeft = draggableItems.length;

    if (!mounted) {
      loaded = true;
      return;
    }

    setState(() {
      loaded = true;
    });
    if (notify) {
      _notifyStateChanged();
    }
  }

  /// Find and remove the matched item from draggable items list
  void findMatchedItem(DragDropItem item) {
    // Find the item in the draggable items list
    final int index = draggableItems.indexWhere((i) => i.value == item.value);
    if (index != -1) {
      // Remove the matched item from the list
      draggableItems.removeAt(index);
      // Remove from combined list too so persisted and restored state matches UI.
      final int combinedIndex = combinedItems.indexWhere(
        (i) => i == item || (i.isDraggable && i.value == item.value),
      );
      if (combinedIndex != -1) {
        combinedItems.removeAt(combinedIndex);
      }

      // Update the state to reflect the changes
      itemsLeft = draggableItems.length;
      setState(() {
        if (kDebugMode) {
          log('Item matched: ${item.value}');
        }
      });
      _notifyStateChanged();
    }
  }

  void _handleDropResult(DragDropItem item, bool correct) {
    if (correct) {
      correctAnswers++;
    } else {
      incorrectAnswers++;
    }
    findMatchedItem(item);
  }

  void _handleOrderChanged(List<DragDropItem> orderedItems) {
    combinedItems = List<DragDropItem>.from(orderedItems);
    _notifyStateChanged();
  }

  void _notifyStateChanged() {
    if (widget.onStateChanged == null) {
      return;
    }
    widget.onStateChanged!(_buildStateSnapshot());
  }

  Map<String, dynamic> _buildStateSnapshot() {
    final List<Map<String, String>> combinedOrder = [];
    final List<Map<String, dynamic>> targetPairs = [];

    for (final DragDropItem item in combinedItems) {
      if (item.isDraggable) {
        combinedOrder.add({'type': 'draggable', 'id': item.value});
      } else {
        combinedOrder.add({'type': 'target', 'id': item.key});
        if (item.isAccepted && item.acceptedFromValue != null) {
          targetPairs.add({
            'target': item.key,
            'draggedFrom': item.acceptedFromValue,
            'isCorrect': item.isCorrect,
          });
        }
      }
    }

    return {
      'combinedOrder': combinedOrder,
      'targetPairs': targetPairs,
      'itemsLeft': itemsLeft,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
    };
  }

  List<DragDropItem> _screenshotOrderedItems() {
    final List<DragDropItem> items = [];
    final int maxLength = math.max(draggableItems.length, dragTargets.length);
    for (int index = 0; index < maxLength; index++) {
      if (index < dragTargets.length) {
        items.add(dragTargets[index]);
      }
      if (index < draggableItems.length) {
        items.add(draggableItems[index]);
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      log(
        'Items to match left: $itemsLeft. Correct answers: $correctAnswers. Incorrect answers: $incorrectAnswers',
      );
    }

    if (loaded && dragTargets.isEmpty) {
      return Center(child: Text(context.l10n.no_images_found));
    }

    if (loaded && dragTargets.length < 2) {
      return Center(child: Text(context.l10n.not_enough_images_to_match));
    }

    if (_isChallengeComplete && loaded) {
      final bool passed = incorrectAnswers == 0;
      // Display result and reset button
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            passed
                ? Text(context.l10n.all_items_matched)
                : Text(
                    '${context.l10n.items_matched}: $correctAnswers / ${widget.images.length}',
                  ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: passed
                  ? () => widget.onCompleted(passed)
                  : (widget.onRestart ?? reset),
              child: Text(
                passed ? context.l10n.button_next : context.l10n.play_again,
              ),
            ),
          ],
        ),
      );
    }
    if (!loaded) {
      return const Center(
        child: SizedBox.square(
          dimension: 48,
          child: CircularProgressIndicator(),
        ),
      );
    }

    return GridDragDropWidget(
      items: combinedItems,
      aspectRatio: _gridAspectRatio,
      onOrderChanged: _handleOrderChanged,
      onMatched: (DragDropItem? item) {
        if (kDebugMode) {
          log('onMatched called: ${item!.value}');
        }
        _handleDropResult(item!, true);
      },
      onMisMatched: (DragDropItem? item) {
        _handleDropResult(item!, false);
      },
    );
  }

  Map<String, DragDropItem> _getDragDropImagesByKey(List<DragDropItem> items) =>
      {for (final item in items) item.key: item};

  bool _initialStatesEqual(
    Map<String, dynamic>? previous,
    Map<String, dynamic>? next,
  ) {
    if (identical(previous, next)) {
      return true;
    }
    if (previous == null || next == null) {
      return previous == next;
    }
    return const DeepCollectionEquality().equals(previous, next);
  }
}
