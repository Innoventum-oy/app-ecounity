
// Completion for a Page (Pathway)
import 'package:core/core.dart' as core;
import 'package:flutter/material.dart';
import 'package:ecounity/src/objects/pathway.dart';

class CompletionPage extends StatelessWidget {
  final core.WebPage pathway;

  const CompletionPage({super.key, required this.pathway});


  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width*0.9;
    return SingleChildScrollView(child:Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Thumbnail in Card if available
            
              Card(
                child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: 400 ),
                    child:pathway.hasCompletionImage() ? pathway.imageBuilder(pathway.completionImage) : Image.asset('assets/images/thumb-up.png'),
                ),
              ),

              pathway.getCompletionText(context)


          ],
        ),
        );
  }
}