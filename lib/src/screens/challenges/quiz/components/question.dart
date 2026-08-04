import 'dart:developer';

import 'package:core/core.dart' as core;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class Question extends StatefulWidget {
  final core.FormElement element;

  final int? selectedOption; // default / original selected option
  final Function onChanged;
  final List<Widget>? buttons;
  final int index;
  final int pageCount;
  const Question({
    super.key,
    required this.element,
    required this.onChanged,
    required this.index,
    required this.pageCount,
    this.selectedOption,
    this.buttons,
  });

  @override
  RadioGroupWidget createState() => RadioGroupWidget();
}

class RadioGroupWidget extends State<Question> {
  // Default Radio Button Item
  int? selectedOptionValue;

  @override
  void initState() {
    super.initState();
    selectedOptionValue = widget.selectedOption;
  }

  @override
  void didUpdateWidget(covariant Question oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.element.id != widget.element.id ||
        oldWidget.selectedOption != widget.selectedOption) {
      selectedOptionValue = widget.selectedOption;
    }
  }

  List<Widget> _buildQuestionTypeContent(List<dynamic> options) {
    final List<Widget> children = [];
    switch (widget.element.type) {
      case 'radio':
        children.add(
          RadioGroup<dynamic>(
            groupValue: selectedOptionValue,
            onChanged: (val) {
              setState(() {
                selectedOptionValue = val is int
                    ? val
                    : int.tryParse(val?.toString() ?? '');
                widget.onChanged(val);
              });
            },
            child: Column(
              children: options
                  .map(
                    (data) => Card(
                      child: RadioListTile<dynamic>(
                        title: Text("${data.value}"),
                        value: data.id,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
        break;
      case 'heading':
        break;

      default:
        break;
    }
    return children;
  }

  List<Widget> _buildQuestionContent(List<Widget> typeContent) {
    return [
      Text(
        widget.element.title ?? '',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      if (widget.element.description != null)
        Text(widget.element.description ?? ''),
      if (widget.element.type == 'richtext' &&
          widget.element.htmldescription != null)
        Html(
          data: widget.element.htmldescription,
          style: {'ul': Style(padding: HtmlPaddings.only(left: 10))},
        ),
      ...typeContent,
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
    log(
      'Building Question ${widget.element.id} ${widget.element.title} with ${widget.element.elements?.length} options, selected: ${widget.selectedOption}',
    );

    final List<Widget> questionContent = _buildQuestionContent(
      _buildQuestionTypeContent(options),
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
