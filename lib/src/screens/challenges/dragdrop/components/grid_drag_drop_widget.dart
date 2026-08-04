import 'dart:developer';
import 'dart:math' as math;

import 'package:ecounity/src/objects/drag_drop_item.dart';
import 'package:flutter/material.dart';

typedef DragDropAction = void Function(DragDropItem item);
typedef DragDropOrderChanged = void Function(List<DragDropItem> items);

enum _GridDragKind { match, reorder }

class _GridDragPayload {
  const _GridDragPayload({required this.item, required this.kind});

  final DragDropItem item;
  final _GridDragKind kind;
}

class GridDragDropWidget extends StatefulWidget {
  final List<DragDropItem> items;
  final DragDropAction onMatched;
  final DragDropAction onMisMatched;
  final DragDropOrderChanged? onOrderChanged;
  final double aspectRatio;

  const GridDragDropWidget({
    super.key,
    required this.items,
    this.aspectRatio = 1.0,
    required this.onMatched,
    required this.onMisMatched,
    this.onOrderChanged,
  });

  @override
  GridDragDropWidgetState createState() => GridDragDropWidgetState();
}

class GridDragDropWidgetState extends State<GridDragDropWidget> {
  late List<DragDropItem> combinedItems;

  String _normalizeMatchId(String rawId) {
    if (rawId.startsWith('image-')) {
      return rawId.substring(6);
    }
    if (rawId.startsWith('text-')) {
      return rawId.substring(5);
    }
    return rawId;
  }

  bool _isSameItem(DragDropItem first, DragDropItem second) {
    if (identical(first, second)) {
      return true;
    }
    if (first.isDraggable && second.isDraggable) {
      return first.value == second.value;
    }
    if (!first.isDraggable && !second.isDraggable) {
      return first.key == second.key;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    combinedItems = List.from(widget.items);
  }

  @override
  void didUpdateWidget(covariant GridDragDropWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    combinedItems = List.from(widget.items);
  }

  Widget _buildTileContent(DragDropItem item) {
    return Container(
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (item.dropChild != null) item.dropChild!,
          if (item.draggedItem != null) item.draggedItem!,
        ],
      ),
    );
  }

  Widget _buildReorderPlaceholder() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.25),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.45)),
      ),
    );
  }

  Widget _withReorderTarget({
    required DragDropItem item,
    required Widget child,
  }) {
    return DragTarget<_GridDragPayload>(
      onWillAcceptWithDetails: (receivedItem) =>
          receivedItem.data.kind == _GridDragKind.reorder &&
          !_isSameItem(receivedItem.data.item, item),
      onAcceptWithDetails: (receivedItem) {
        _swapItems(receivedItem.data.item, item);
      },
      builder: (context, acceptedItems, rejectedItems) {
        final bool isReorderHover = acceptedItems
            .whereType<_GridDragPayload>()
            .any((payload) => payload.kind == _GridDragKind.reorder);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            border: Border.all(
              color: isReorderHover
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: child,
        );
      },
    );
  }

  Widget _buildReorderableTarget(DragDropItem item) {
    final Widget tileContent = _buildTileContent(item);
    return DragTarget<_GridDragPayload>(
      key: ValueKey(item.key),
      onAcceptWithDetails: (receivedItem) {
        if (receivedItem.data.kind == _GridDragKind.reorder) {
          _swapItems(receivedItem.data.item, item);
          return;
        }
        _handleMatchDrop(item, receivedItem.data.item);
      },
      onLeave: (receivedItem) {
        log('onLeave called');
        item.willAccept = false;
      },
      onWillAcceptWithDetails: (receivedItem) {
        if (receivedItem.data.kind == _GridDragKind.reorder) {
          return !_isSameItem(receivedItem.data.item, item);
        }
        final bool willAccept = !item.isAccepted;
        item.willAccept = willAccept;
        return willAccept;
      },
      builder: (context, acceptedItems, rejectedItem) {
        final bool isMatchHover = acceptedItems
            .whereType<_GridDragPayload>()
            .any((payload) => payload.kind == _GridDragKind.match);
        final bool isReorderHover = acceptedItems
            .whereType<_GridDragPayload>()
            .any((payload) => payload.kind == _GridDragKind.reorder);
        return MeasuredDraggable<_GridDragPayload>(
          data: _GridDragPayload(item: item, kind: _GridDragKind.reorder),
          childWhenDragging: _buildReorderPlaceholder(),
          feedback: Material(color: Colors.transparent, child: tileContent),
          dragChild: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              border: Border.all(
                color: isMatchHover || isReorderHover
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: tileContent,
          ),
          useLongPress: true,
        );
      },
    );
  }

  void _swapItems(DragDropItem draggedItem, DragDropItem targetItem) {
    final int draggedIndex = combinedItems.indexWhere(
      (item) => _isSameItem(item, draggedItem),
    );
    final int targetIndex = combinedItems.indexWhere(
      (item) => _isSameItem(item, targetItem),
    );
    if (draggedIndex == -1 ||
        targetIndex == -1 ||
        draggedIndex == targetIndex) {
      return;
    }

    setState(() {
      final DragDropItem movedItem = combinedItems[draggedIndex];
      combinedItems[draggedIndex] = combinedItems[targetIndex];
      combinedItems[targetIndex] = movedItem;
    });
    widget.onOrderChanged?.call(List<DragDropItem>.from(combinedItems));
  }

  void _handleMatchDrop(DragDropItem targetItem, DragDropItem receivedItem) {
    targetItem.draggedItem = receivedItem.dragChild ?? receivedItem.dropChild;
    targetItem.acceptedFromValue = receivedItem.value;
    log('onAcceptWithDetails: ${receivedItem.value} ${targetItem.key}');
    receivedItem.isAccepted = true;
    targetItem.isAccepted = true;
    final bool isCorrect =
        _normalizeMatchId(receivedItem.value) ==
        _normalizeMatchId(targetItem.key);
    if (isCorrect) {
      log('Matched: ${receivedItem.value} ${targetItem.key}');
      targetItem.isCorrect = true;
      widget.onMatched(receivedItem);
    } else {
      log('MisMatched: ${receivedItem.value} ${targetItem.key}');
      targetItem.isCorrect = false;
      widget.onMisMatched(receivedItem);
    }
    setState(() {
      combinedItems.removeWhere(
        (candidate) =>
            identical(candidate, receivedItem) ||
            (candidate.isDraggable && candidate.value == receivedItem.value),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = math.sqrt(combinedItems.length).ceil();
    // on narrow view widths, use 2 columns
    if (MediaQuery.of(context).size.width < 700) {
      crossAxisCount = math.min(crossAxisCount, 2);
    }
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: widget.aspectRatio,
      ),
      itemCount: combinedItems.length,
      itemBuilder: (context, index) {
        final item = combinedItems[index];

        if (item.isDraggable) {
          if (item.isAccepted) {
            return const SizedBox.shrink();
          }

          return _withReorderTarget(
            item: item,
            child: MeasuredDraggable<_GridDragPayload>(
              data: _GridDragPayload(item: item, kind: _GridDragKind.match),
              childWhenDragging:
                  item.childWhenDragging ??
                  item.dragChild ??
                  const SizedBox.shrink(),
              feedback: item.feedbackItem!,
              dragChild: item.dragChild!,
            ),
          );
        }

        return _buildReorderableTarget(item);
      },
    );
  }
}

class MeasuredDraggable<T extends Object> extends StatefulWidget {
  final T data;
  final Widget dragChild;
  final Widget childWhenDragging;
  final Widget? feedback;
  final bool useLongPress;

  const MeasuredDraggable({
    super.key,
    required this.data,
    required this.dragChild,
    required this.childWhenDragging,
    this.feedback,
    this.useLongPress = false,
  });

  @override
  MeasuredDraggableState<T> createState() => MeasuredDraggableState<T>();
}

class MeasuredDraggableState<T extends Object>
    extends State<MeasuredDraggable<T>> {
  final GlobalKey _dragChildKey = GlobalKey();
  Size? _dragChildSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _measureDragChild();
    });
  }

  void _measureDragChild() {
    if (!mounted) {
      return;
    }
    final renderBox =
        _dragChildKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.size != _dragChildSize) {
      setState(() {
        _dragChildSize = renderBox.size;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget feedback = _dragChildSize != null
        ? SizedBox(
            width: _dragChildSize!.width,
            height: _dragChildSize!.height,
            child: widget.feedback ?? widget.dragChild,
          )
        : widget.feedback ?? widget.dragChild;
    final Widget child = Container(key: _dragChildKey, child: widget.dragChild);

    if (widget.useLongPress) {
      return LongPressDraggable<T>(
        data: widget.data,
        childWhenDragging: widget.childWhenDragging,
        feedback: feedback,
        child: child,
      );
    }

    return Draggable<T>(
      data: widget.data,
      childWhenDragging: widget.childWhenDragging,
      feedback: feedback,
      child: child,
    );
  }
}
