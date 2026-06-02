
import 'package:flutter/material.dart';

enum InfoWidgetStyle{
  info,
  warning,
  error,
  success
}
// Default icons for the InfoWidget based on the style
final Map<InfoWidgetStyle,Icon> infoWidgetIcons = {
  InfoWidgetStyle.info: const Icon(Icons.info, color: Colors.blue),
  InfoWidgetStyle.warning: const Icon(Icons.warning,color: Colors.orange,),
  InfoWidgetStyle.error: const Icon(Icons.error, color: Colors.red,),
  InfoWidgetStyle.success: const Icon(Icons.check, color: Colors.green),
};
/// stateless info widget to be displayed as part of page contents
class InfoWidget extends StatelessWidget{
  final String title;
  final String content;
  final InfoWidgetStyle style;
  final Icon? icon;
  const InfoWidget({super.key, required this.title, required this.content,this.icon, this.style = InfoWidgetStyle.info});
  Icon getIcon(InfoWidgetStyle style){
    return infoWidgetIcons[style] ?? const Icon(Icons.question_mark);
  }
  @override
  Widget build(BuildContext context) {
    // If no icon is provided, use the default info icon
    Icon displayIcon = icon ?? getIcon(style);
    // Return a ListTile wrapped in a Card widget
    return Card(
      child: ListTile(
        leading: displayIcon,
        title: Text(title),
        subtitle: Text(content),
      ),
    );
  }
}