import 'dart:developer';

import 'package:core/core.dart' as core;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:ecounity/src/widgets/introduction_page.dart';

import '../util/router.dart';


abstract class WebpageScreen extends StatefulWidget{
  final core.WebPage webPage;
  final int navIndex;
  final bool openIntroduction ;
  final core.WebPageList? pathways;
  const WebpageScreen({super.key, required this.navIndex, required this.webPage, this.openIntroduction = false, this.pathways});

}
abstract class WebpageScreenState <T extends WebpageScreen> extends State<T>{
  PathwayStatus? status;
  bool loaded = false;
  late core.FileStorage fileStorage;
  bool openIntroduction = false;
  final core.ApiClient apiClient = core.ApiClient();

  @override
  void initState(){
    // ensure initialized before adding listener
    openIntroduction = widget.openIntroduction;
    if(kDebugMode){
      log('WebpageScreenState initState, openIntroduction: $openIntroduction');
    }
    fileStorage = Provider.of<core.FileStorage>(context, listen: false);

    super.initState();
    load();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      fileStorage.addListener(listener);
    });

    // Add a statistics hit to the page
    int pageId = widget.webPage.id ?? 0;
    if(pageId > 0) {
      apiClient.addStatisticsHit(pageId);
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fileStorage = Provider.of<core.FileStorage>(context, listen: false);
  }
  void listener(){

    setState(() {
      if(kDebugMode){
        print('Storage updated, refreshing webpagescreen');
      }
      openIntroduction = false;
    });
    load();
  }

  @override
  void dispose() {
    fileStorage.removeListener(listener);
    super.dispose();
  }

  void load() async{
    status = await widget.webPage.status;
   setState(() {
     loaded = true;
   });
  }

  @override
  build(BuildContext context){

    List<Widget>? buttons = [];

    if(!loaded){
      return const Center(child: CupertinoActivityIndicator());
    }
    // Check if the pathways has previous and next items
    if (widget.pathways != null) {
      if(kDebugMode){
        log('Pathways: ${widget.pathways!.length}, has previous: ${widget.pathways!.hasPrevious()}, has next: ${widget.pathways!.hasNext()}');
      }
      widget.pathways?.setIndex(widget.webPage);
      if (widget.pathways!.hasPrevious()) {
        core.WebPage? previous = widget.pathways!.getPrevious();
        buttons.add(
          IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: previous?.pagetitle,
            onPressed: () {
              AppRouter.navigate(context, previous!.type.name, widget.navIndex, data: previous,pathways: widget.pathways);
            },
          ),
        );
      }
      if (widget.pathways!.hasNext()) {
        core.WebPage? next = widget.pathways!.getNext();
        buttons.add(
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: next?.pagetitle,
            onPressed: () {
              AppRouter.navigate(context, next!.type.name, widget.navIndex, data: next,pathways: widget.pathways);
            },
          ),
        );
      }
    }
    return ((status != null && !openIntroduction ) || !widget.webPage.hasIntroduction())  ? buildScreen(context,buttons:buttons) : buildIntroductionScreen(context);
  }
  // To be overridden by the subclass
  Widget buildScreen(BuildContext context,{List<Widget> buttons = const []}) {
    return  Text('Screen not implemented');
  }

  // Shows introduction card for any web page
  Widget buildIntroductionScreen(BuildContext context){
    return IntroductionPage(pathway: widget.webPage, navIndex: widget.navIndex);
  }

}

extension on core.ApiClient {
  /// Add a statistics hit.
  ///
  /// Parameters:
  /// - pageId: page ID
  ///
  /// Returns:
  /// - True on success, or false on failure
  Future<bool> addStatisticsHit(
      int pageId) async {
    // Build the dispatcher URL for the pagelist module
    String apiPath = await buildApiPath('dispatcher/pagelist/');
    Map<String, dynamic> params = {
      'objectid': pageId,
      'action': 'addhit',
      'method': 'json'
    };
    var url = Uri.https(await baseUrl, apiPath, params.map((key, value) => MapEntry(key, value.toString())));

    return getJson(url).then((core.ApiResponse response) {
      Map<String, dynamic>? responseData = response.rawData as Map<String, dynamic>?;
      return responseData?['status'] == 'success';
    });
  }
}