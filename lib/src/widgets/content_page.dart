import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:core/core.dart';


/// View for displaying selected webpage text contents from iCMS. Fetches the page contents from server based on commonname + language parameters.
/// Expects to receive array of text editor blocks to display


class ContentPage extends StatefulWidget {
  final String commonname;
  final String language;
  final WebPage? providedPage;
  final WebPageProvider pageProvider = WebPageProvider();
  final String? route;
  final Widget? bottomNavigationBar;

  ContentPage(this.commonname,
      {super.key, this.language='en',this.providedPage, this.route, this.bottomNavigationBar});
  @override
  ContentPageState createState() => ContentPageState();
}

class ContentPageState extends State<ContentPage> {
  String? errorMessage;
  WebPage page = WebPage();


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {


      if (widget.providedPage != null) {
        page =widget.providedPage!;

      } else {
        final Map<String, String> params = {
          'language': Localizations.localeOf(context).toString(),
          'commonname': widget.commonname,
          'fields': 'id,commonname,pagetitle,textcontents,thumbnailid',

        };
        widget.pageProvider.loadItem(params);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    page = Provider.of<WebPageProvider>(context).page ?? WebPage();

    String pageTitle = page.pagetitle ?? context.l10n.page_content;
    return Scaffold(
        appBar: AppBar(
          title: Text(pageTitle),
          elevation: 0.1,
        ),
        body: _pageContentSection(page),
        bottomNavigationBar: widget.bottomNavigationBar);
  }



  Widget _pageContentSection(WebPage page) {
    List<Widget> textContents = [];
    //textContents.add(Text(page.pagetitle!=null ? page.pagetitle : 'No title',style: Theme.of(context).textTheme.headline4),);
    if (page.textcontents != null) {
      dynamic textcontents = page.textcontents;
      for (var i in textcontents) {
        textContents.add(Html(data: i.toString()));
      }
    }
    if (widget.route == null) {
      textContents.add(Align(
        alignment: Alignment.center,
        child: ElevatedButton(
            onPressed: () {
              if (widget.route != null) {
                if(kDebugMode){
                  print('pushing route${widget.route!}');
                }
                Navigator.pushNamedAndRemoveUntil(
                    context, widget.route!, (Route<dynamic> route) => false);
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(context.l10n.button_back)),
      ));
    }
    return Column(children: textContents);
  }
}
