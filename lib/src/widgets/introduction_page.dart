
// Introduction for a Page (Pathway)
import 'package:core/core.dart' as core;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/objects/pathway.dart';

import 'mark_pathway_completed.dart';
class IntroductionPage extends StatefulWidget {
  final core.WebPage pathway;
  final int navIndex;

  const IntroductionPage(
      {super.key, required this.pathway, required this.navIndex});

  @override
  State<IntroductionPage> createState() => IntroductionPageState();
}

class IntroductionPageState extends State<IntroductionPage> {
  Widget? introductionImage;

  void buildIntroductionImage() {
    if(widget.pathway.hasIntroductionImage()) {
      introductionImage =
          widget.pathway.imageBuilder(widget.pathway.introductionImage);

      if(introductionImage != null) {
        setState(() { });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    buildIntroductionImage();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
        title: widget.pathway.pagetitle ?? context.l10n.introduction,
        navigationIndex: widget.navIndex,
        child: SingleChildScrollView(child:Column(
          children: [
            Text(context.l10n.introduction),
            // Article Thumbnail in Card if available
            if(introductionImage != null)
              Card(
                  child: introductionImage
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: widget.pathway.introductionText ?? Text(context.l10n.noContentFound),
            ),
            // Completion button (completePathwayButton in a FutureBuilder)
            Consumer<core.FileStorage>(
              builder: (context, fileStorage, child) {
                return FutureBuilder(
                  future: openPathwayButton(context, widget.pathway),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return snapshot.data!;
                      } else {
                        return Text(context.l10n.error_loading_button);
                      }
                    }
                    return const CircularProgressIndicator();
                  },
                  initialData: const CircularProgressIndicator(),
                );
              },
            ),

          ],
        ),
        ));
  }
}