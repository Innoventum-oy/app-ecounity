import 'package:flutter/material.dart';

class DragDropItem {
  //unique key for matching source and target
  //Accepts string
  final String key;
  //Value of a matching target
  //Accepts string

  final String value;
  //Widget to put into draggable
  //Any valid widget, else Text widget is used

  Widget? dragChild;
  //Widget to put into drop field/target
  //Any valid widget, else Text widget is used

  Widget? dropChild;
  //Icon for widget , [Optional]
  Widget? draggedItem;
  IconData? iconData;
  //Feedback widget on dragging, at the pointer
  Widget? feedbackItem;
  //Child to leave at source when dragging
  Widget? childWhenDragging;
  // Identifier of the draggable item currently accepted by this target.
  String? acceptedFromValue;
  //whether a drop target will accept this model or not
  //[boolean]
  bool willAccept = true;
  //whether the model is accepted or not
  //locked if isAccepted is true, else not
  bool isAccepted;
  bool isCorrect;
  //default text style for a drag/drop children
  TextStyle? defaultTextStyle;

  DragDropItem({
    required this.key,
    required this.value,
    this.iconData,
    this.dragChild,
    this.dropChild,
    this.feedbackItem,
    this.childWhenDragging,
    this.isAccepted = false,
    this.isCorrect = false,
    this.defaultTextStyle,
  }) {
    feedbackItem = dragChild ?? Icon(iconData, size: 30, color: Colors.teal);

    dropChild = dropChild ?? Text(value, style: TextStyle(fontSize: 20));
    childWhenDragging =
        dragChild ?? Text(value, style: TextStyle(fontSize: 20));
  }
  bool get isDraggable => dragChild != null;
}
