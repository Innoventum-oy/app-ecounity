import 'dart:developer';

import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CheckboxQuestion extends StatefulWidget {
  final core.FormElement element;

  final List<dynamic> selectedOptions; // default / original selected options
  final Function onChanged;
  final List<Widget>? buttons;
  final int index;
  final int pageCount;
  const CheckboxQuestion({
    super.key,
    required this.element,
    required this.onChanged,
    required this.index,
    required this.pageCount,
    required this.selectedOptions,
    this.buttons,
  });

  @override
  CheckboxGroupWidget createState() => CheckboxGroupWidget();
}

class CheckboxGroupWidget extends State<CheckboxQuestion> {
  List<dynamic> selectedOptionValues = [];

  @override
  void initState() {
    super.initState();
    selectedOptionValues = List<dynamic>.from(widget.selectedOptions);
  }

  @override
  void didUpdateWidget(covariant CheckboxQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.element.id != widget.element.id ||
        !listEquals(oldWidget.selectedOptions, widget.selectedOptions)) {
      selectedOptionValues = List<dynamic>.from(widget.selectedOptions);
    }
  }

  List<Widget> _buildOptions(List<dynamic> options) {
    return options
        .map(
          (data) => Card(
            child: CheckboxListTile(
              title: Text("${data.value}"),
              value: selectedOptionValues.contains(data.id),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    if (!selectedOptionValues.contains(data.id)) {
                      selectedOptionValues.add(data.id);
                    }
                  } else {
                    selectedOptionValues.remove(data.id);
                  }
                  widget.onChanged(List<dynamic>.from(selectedOptionValues));
                });
              },
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildQuestionContent(List<Widget> options) {
    return [
      Text(
        widget.element.title ?? '',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      if (widget.element.description != null)
        Text(widget.element.description ?? ''),
      ...options,
    ];
  }

  List<Widget> _buildPageControls() {
    return [
      const SizedBox(height: 12),
      if (widget.buttons != null)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceAround,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 10,
                children: widget.buttons ?? [],
              ),
            ),
          ],
        ),
      const SizedBox(height: 12),
      Center(
        child: Text(
          "${widget.index} / ${widget.pageCount}",
          style: const TextStyle(fontSize: 14),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> options = widget.element.elements ?? [];
    if (kDebugMode) {
      log(
        'Building Question ${widget.element.id} ${widget.element.title} with ${widget.element.elements?.length} options, selected: ${widget.selectedOptions}',
      );
    }

    final List<Widget> questionContent = _buildQuestionContent(
      _buildOptions(options),
    );
    final List<Widget> pageControls = _buildPageControls();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [...questionContent, ...pageControls],
      ),
    );
  }
}
