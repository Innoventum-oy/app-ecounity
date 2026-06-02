import 'dart:developer';
import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:ecounity/src/objects/drag_drop_item.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/src/util/image_from_url.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../../../l10n/app_localizations_extension.dart';
import '../../../../util/core_compat.dart';
import 'grid_drag_drop_widget.dart';

class DragDropChallenge extends StatefulWidget {
  const DragDropChallenge({
    super.key,
    required this.onCompleted,
    required this.images,
  });
  final Function onCompleted;
  final List<core.ImageObject> images;
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
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    reset();
  }

  @override
  void dispose() {
    // Ensure that you are not accessing the widget tree here
    super.dispose();
  }

  void reset() {
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
      Widget imageWidget = Card(
        child: AspectRatio(
          aspectRatio: 1,
          child: ImageFromUrl.get(image.imageUrl!, fillContainer: true),
          //   child: Image.asset('assets/images/ecounity-logo.png'),
        ),
      );
      // The child when dragging is just a plain grey card with no text
      Widget emptyGreyCard = Card(
        color: Colors.grey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 100, minHeight: 100),
          child: const Center(child: Text('')),
        ),
      );

      Widget dragItemContent = ConstrainedBox(
        constraints: BoxConstraints(minWidth: 100, minHeight: 100),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8.0,
              children: [
                Text(
                  image.getValue('title') ??
                      '${context.l10n.no_title} ${image.id}',
                  maxLines: 2,
                  style: TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
                if (image.getValue('text') != null)
                  HtmlWidget(
                    image.getValue('text'),
                    textStyle: TextStyle(
                      overflow: TextOverflow.ellipsis
                    )
                  ),
              ],
            ),
          ),
        ),
      );
      Widget dragItem = Card(child: dragItemContent);
      // Create dropchild using the dragItemContent, placing it on a 50% transparent grey card
      Widget dropChild = Card(
        color: Colors.grey.withAlpha(50),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 100, minHeight: 100),
          child: dragItemContent,
        ),
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
    itemsLeft = draggableItems.length;
    combinedItems.addAll(draggableItems);
    combinedItems.addAll(dragTargets);
    combinedItems.shuffle();
    setState(() {
      loaded = true;
    });
  }

  /// Find and remove the matched item from draggable items list
  void findMatchedItem(DragDropItem item) {
    // Find the item in the draggable items list
    int index = draggableItems.indexWhere((i) => i.value == item.value);
    if (index != -1) {
      // Remove the matched item from the list
      draggableItems.removeAt(index);
      // Update the state to reflect the changes
      itemsLeft = draggableItems.length;
      if (itemsLeft == 0) {
        if (incorrectAnswers == 0) {
          widget.onCompleted();
        } else {}
      }
      setState(() {
        if (kDebugMode) {
          log('Item matched: ${item.value}');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      log(
        'Items to match left: $itemsLeft. Correct answers: $correctAnswers. Incorrect answers: $incorrectAnswers',
      );
    }

    if (widget.images.isEmpty) {
      return Center(child: Text(context.l10n.no_images_found));
    }

    if (widget.images.length < 2) {
      return Center(child: Text('${context.l10n.not_enough_images_to_match}'));
    }

    if (itemsLeft == 0 && loaded) {
      // Display result and reset button
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            incorrectAnswers == 0
                ? Text(context.l10n.all_items_matched)
                : Text(
                    '${context.l10n.items_matched}: $correctAnswers / ${widget.images.length}',
                  ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                reset();
              },
              child: Text(context.l10n.play_again),
            ),
          ],
        ),
      );
    }
    return loaded
        ? GridDragDropWidget(
            items: combinedItems,
            onMatched: (DragDropItem? item) {
              if (kDebugMode) {
                log('onMatched called: ${item!.value}');
              }
              correctAnswers++;
              findMatchedItem(item!);
            },
            onMisMatched: (DragDropItem? item) {
              incorrectAnswers++;
              findMatchedItem(item!);
            },
          )
        : const CircularProgressIndicator();
  }
}
