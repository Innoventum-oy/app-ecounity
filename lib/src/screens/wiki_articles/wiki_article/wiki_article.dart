

import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:core/core.dart' as core;
import 'package:ecounity/src/widgets/screenscaffold.dart';
import 'package:ecounity/src/widgets/webpage_screen.dart';
import '../../../util/router.dart';
import '../../../widgets/mark_pathway_completed.dart';

/// WikiwebPage widget
class WikiArticle extends WebpageScreen{
  const WikiArticle({super.key, required super.navIndex, required super.webPage, super.openIntroduction = false,super.pathways});

  @override
  WebpageScreenState createState() => WikiArticleState();
}
class WikiArticleState extends WebpageScreenState {

  @override
  Widget buildScreen(BuildContext context,{List<Widget> buttons = const []}) {
  //  List<core.WebPage>? parents = Provider.of<core.WebPageProvider>(context, listen: false).findByKey('id', widget.webPage.parent);


    return ScreenScaffold(
      title: widget.webPage.title,
      navigationIndex: widget.navIndex,
      child: SingleChildScrollView(child:Column(
        children: [
          // webPage Thumbnail in Card if available
          if(widget.webPage.thumbnail!=null)
            Padding(
              padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0
                ),
                child: Card(
                  child: widget.webPage.imageBuilder(widget.webPage.thumbnailImage)
                )
            ),
          // WikiwebPage content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget.webPage.contents ?? Text(context.l10n.noContentFound),
          ),
          // Completion button (completePathwayButton in a FutureBuilder)
    Padding(
    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child:
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  // Button to reopen the introduction (navigate to this screen with openIntroduction = true)
                 if( widget.webPage.hasIntroduction()) ElevatedButton(
                    onPressed: () {

                      AppRouter.navigate(context, widget.webPage.type.name, widget.navIndex, openIntroduction: true,data: widget.webPage);
                    },
                    child: Text(context.l10n.view_introduction),
                  ),
                  Consumer<core.FileStorage>(
                  builder: (context, fileStorage, child) {
                    return FutureBuilder(
                      future: completePathwayButton(context, widget.webPage,fileStorage),
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
                ]
              )
            )
    ]),
    ),
    Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
          // Previous button
          buttons
        ,
      ),
        ],
      ),
      ),
    );
  }
}