import 'package:ecounity/src/learning/ecounity_learning_text_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class EcoUnityLearningCopy extends StatelessWidget {
  const EcoUnityLearningCopy({
    super.key,
    required this.text,
    this.style,
    this.compactPlainText = false,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final bool compactPlainText;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const SizedBox.shrink();
    }

    if (ecoUnityLooksLikeHtml(trimmed)) {
      return HtmlWidget(trimmed, textStyle: style);
    }

    return Text(
      compactPlainText ? ecoUnityPlainText(trimmed) : trimmed,
      maxLines: maxLines,
      overflow: overflow,
      style: style,
    );
  }
}
