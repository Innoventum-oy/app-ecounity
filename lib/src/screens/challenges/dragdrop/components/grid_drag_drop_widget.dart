import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:ecounity/src/objects/drag_drop_item.dart';
import 'dart:math' as math;

typedef DragDropAction = void Function(DragDropItem item);

class GridDragDropWidget extends StatefulWidget {
  final List<DragDropItem> items;
  final DragDropAction onMatched;
  final DragDropAction onMisMatched;

  const GridDragDropWidget({
    super.key,
    required this.items,
    required this.onMatched,
    required this.onMisMatched,
  });

  @override
  GridDragDropWidgetState createState() => GridDragDropWidgetState();
}

class GridDragDropWidgetState extends State<GridDragDropWidget> {
  late List<DragDropItem> combinedItems;

  @override
  void initState() {
    super.initState();
    combinedItems = List.from(widget.items);
    combinedItems.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = math.sqrt(combinedItems.length).ceil();
    // on narrow view widths, use 2 columns
    if (MediaQuery.of(context).size.width < 700) {
      crossAxisCount = math.min(crossAxisCount, 2);
    }
    return GridView.builder(
      shrinkWrap: true, // Ensures the GridView does not expand infinitely
   //   physics: const NeverScrollableScrollPhysics(), // Prevents GridView from handling its own scrolling
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1,
      ),
      itemCount: combinedItems.length,
      itemBuilder: (context, index) {
        final item = combinedItems[index];

        return SizedBox(
          width: 100, // Set explicit width
          height: 100, // Set explicit height
          child: item.isDraggable
              ? (item.isAccepted ? Container() : MeasuredDraggable<DragDropItem>(
            data: item,
            childWhenDragging: Container(),//item.childWhenDragging,
            feedback: item.feedbackItem!,
            dragChild: item.dragChild!,
           // child: item.isAccepted ? item.dragChild! : item.dragChild!,
          )
          )  :  item.draggedItem!=null ? Container(
            decoration: BoxDecoration(
              /*border: Border.all(
                color: item.isCorrect ? Colors.green : Colors.red,
                width: 2.0,
              ),*/
            ),
            child: Stack(
              children: [
                if(item.dropChild!=null) item.dropChild!,
                if(item.draggedItem!=null) item.draggedItem!,
              ],
            ),
          ) : DragTarget<DragDropItem>( key: ValueKey(item.key), // Assign unique key
            onAcceptWithDetails: (receivedItem) {
              if(kDebugMode){
                item.draggedItem = receivedItem.data.dropChild;
                log('onAcceptWithDetails: ${receivedItem.data.value} ${item.key}');
              }
              receivedItem.data.isAccepted = true;
              item.isAccepted = true;
              if (receivedItem.data.value == item.key) {
                if(kDebugMode){
                  log('Matched: ${receivedItem.data.value} ${item.key}');
                }
                item.isCorrect = true;
                widget.onMatched(receivedItem.data);
              }
              else {
                if(kDebugMode){
                  log('MisMatched: ${receivedItem.data.value} ${item.key}');
                }
                item.isCorrect = false;
                widget.onMisMatched(receivedItem.data);
              }
              setState(() {
                combinedItems.remove(receivedItem.data);
              });
            },
            onLeave: (receivedItem) {
              if(kDebugMode){
                log('onLeave called');
              }
              item.willAccept = false;

            },
            onWillAcceptWithDetails: (receivedItem) {

              bool willAccept = receivedItem.data.value == item.key && !item.isAccepted;
              item.willAccept = willAccept;
              return true;// willAccept;
            },
            builder: (context, acceptedItems, rejectedItem) => Container(
              alignment: Alignment.center,
              // margin: const EdgeInsets.all(8.0),
                //  color: item.isCorrect ? Colors.green : (item.isAccepted ? Colors.red : Colors.transparent),
              child:  item.dropChild!,
            ),
          ),
        );
      },
    );
  }
}

class MeasuredDraggable<T extends Object> extends StatefulWidget {
  final T data;
  final Widget dragChild;
  final Widget childWhenDragging;
  final Widget? feedback;

  const MeasuredDraggable({
    super.key,
    required this.data,
    required this.dragChild,
    required this.childWhenDragging,
    this.feedback,
  });

  @override
  MeasuredDraggableState<T> createState() => MeasuredDraggableState<T>();
}

class MeasuredDraggableState<T extends Object> extends State<MeasuredDraggable<T>> {
  final GlobalKey _dragChildKey = GlobalKey();
  Size? _dragChildSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureDragChild();
    });
  }

  void _measureDragChild() {
    final renderBox = _dragChildKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _dragChildSize = renderBox.size;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<T>(
      data: widget.data,
      childWhenDragging: widget.childWhenDragging,
      feedback: _dragChildSize != null
          ? SizedBox(
        width: _dragChildSize!.width,
        height: _dragChildSize!.height,
        child: widget.feedback ?? widget.dragChild,
      )
          : widget.feedback ?? widget.dragChild,
      child: Container(
        key: _dragChildKey,
        child: widget.dragChild,
      ),
    );
  }
}