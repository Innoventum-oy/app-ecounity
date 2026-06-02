import 'package:core/core.dart' as core;
import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class TextAreaQuestion extends StatefulWidget {
  final core.FormElement element;

  final String? currentValue; // default / original value
  final Function onChanged;
  final List<Widget>? buttons;
  final int index;
  final int pageCount;
  final Map<String, dynamic>? params;

  const TextAreaQuestion({
    super.key,
    required this.element,
    required this.onChanged,
    required this.index,
    required this.pageCount,
    this.currentValue,
    this.buttons,
    this.params,
  });

  @override
  TextAreaWidget createState() => TextAreaWidget();
}

class TextAreaWidget extends State<TextAreaQuestion> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.element.title ?? '',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        if (widget.element.description != null)
          Text(widget.element.description ?? ''),

        TextFormFieldItem(
          element: widget.element,
          value: widget.currentValue ?? '',
          params: widget.params,
          onChanged: widget.onChanged,
        ),

        SizedBox(height: 12),
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
      ],
    );
  }
}

class TextFormFieldItem extends StatefulWidget {
  final core.FormElement element;
  final String? value;
  final Map<String, dynamic>? params;
  final Function onChanged;

  const TextFormFieldItem({
    super.key,
    required this.element,
    required this.value,
    this.params,
    required this.onChanged,
  });

  @override
  TextFormFieldItemState createState() => TextFormFieldItemState();
}

class TextFormFieldItemState extends State<TextFormFieldItem> {
  late String? selectedValue;
  final _textEditingController = TextEditingController();
  bool _syncingText = false;

  @override
  void initState() {
    super.initState();

    // print('textformfield initialValue in initState: '+widget.value);
    // Start listening to changes.
    _textEditingController.text = widget.value ?? '';
    _textEditingController.addListener(updateTextFieldValue);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    _textEditingController.dispose();
    super.dispose();
  }

  void updateTextFieldValue() {
    String? value = _textEditingController.text;
    if (_syncingText) {
      selectedValue = value;
      return;
    }
    //  print('running updateTextFieldValue, value: '+value);
    setState(() {
      selectedValue = value;
      widget.onChanged(selectedValue);
    });
  }

  @override
  void didUpdateWidget(covariant TextFormFieldItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String nextValue = widget.value ?? '';
    if (oldWidget.value != widget.value &&
        _textEditingController.text != nextValue) {
      _syncingText = true;
      _textEditingController.value = TextEditingValue(
        text: nextValue,
        selection: TextSelection.collapsed(offset: nextValue.length),
      );
      _syncingText = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    //  print('building textformfield '+widget.element.id.toString()+', initialValue: '+widget.value);
    selectedValue = widget.value;
    return TextFormField(
      autovalidateMode: AutovalidateMode.always,
      controller: _textEditingController,
      // initialValue: widget.value,
      maxLines: widget.params?['maxlines'] ?? 5,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).writeAnswerHere,
      ),
      validator: (String? value) {
        if (widget.element.required == false) {
          //   print('element is not required!');
          return null;
        }
        return value != null
            ? null
            : AppLocalizations.of(context).fieldCannotBeEmpty;
      },
    );
  }
}
