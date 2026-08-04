import 'dart:developer';

import 'package:core/core.dart' as core;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:ecounity/src/widgets/introduction_page.dart';
import 'package:ecounity/src/util/router.dart';

abstract class WebpageScreen extends StatefulWidget {
  final core.WebPage webPage;
  final int navIndex;
  final bool openIntroduction;
  final bool skipAutoIntroduction;
  final core.WebPageList? pathways;
  const WebpageScreen({
    super.key,
    required this.navIndex,
    required this.webPage,
    this.openIntroduction = false,
    this.skipAutoIntroduction = false,
    this.pathways,
  });
}

abstract class WebpageScreenState<T extends WebpageScreen> extends State<T> {
  PathwayStatus? status;
  bool loaded = false;
  late core.FileStorage fileStorage;
  bool openIntroduction = false;
  bool _hasIntroductionOpenRequest = false;
  bool _skipAutoIntroduction = false;
  final core.ApiClient apiClient = core.ApiClient();

  @override
  void initState() {
    // ensure initialized before adding listener
    openIntroduction = widget.openIntroduction;
    _hasIntroductionOpenRequest = widget.openIntroduction;
    _skipAutoIntroduction = widget.skipAutoIntroduction;
    if (kDebugMode) {
      log('WebpageScreenState initState, openIntroduction: $openIntroduction');
    }
    fileStorage = Provider.of<core.FileStorage>(context, listen: false);

    super.initState();
    load();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      fileStorage.addListener(listener);
    });

    // Add a statistics hit to the page
    int pageId = widget.webPage.id ?? 0;
    if (pageId > 0) {
      apiClient.addStatisticsHit(pageId);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fileStorage = Provider.of<core.FileStorage>(context, listen: false);
  }

  void listener() {
    if (!mounted) return;
    setState(() {
      if (kDebugMode) {
        print('Storage updated, refreshing webpagescreen');
      }
      openIntroduction = false;
      _hasIntroductionOpenRequest = false;
    });
    load();
  }

  @override
  void dispose() {
    fileStorage.removeListener(listener);
    super.dispose();
  }

  Future<void> load() async {
    final PathwayStatus? loadedStatus = await widget.webPage.status;
    if (!mounted) return;
    setState(() {
      status = loadedStatus;
      loaded = true;
    });
  }

  @override
  build(BuildContext context) {
    if (!loaded) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (_hasIntroductionOpenRequest) {
      openIntroduction = true;
    }
    if (openIntroduction && widget.webPage.hasIntroduction()) {
      return buildIntroductionScreen(context);
    }
    return !_skipAutoIntroduction &&
            widget.webPage.hasIntroduction() &&
            status == null
        ? buildIntroductionScreen(context)
        : buildScreen(context);
  }

  // To be overridden by the subclass
  Widget buildScreen(BuildContext context) {
    return Text('Screen not implemented');
  }

  // Shows introduction card for any web page
  Widget buildIntroductionScreen(BuildContext context) {
    return IntroductionPage(
      pathway: widget.webPage,
      navIndex: widget.navIndex,
      onClose: () async {
        AppRouter.navigate(
          context,
          widget.webPage.type.name,
          widget.navIndex,
          skipAutoOpenIntroduction: true,
          data: widget.webPage,
          pathways: widget.pathways,
        );
      },
    );
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
  Future<bool> addStatisticsHit(int pageId) async {
    // Build the dispatcher URL for the pagelist module
    String apiPath = await buildApiPath('dispatcher/pagelist/');
    Map<String, dynamic> params = {
      'objectid': pageId,
      'action': 'addhit',
      'method': 'json',
    };
    var url = Uri.https(
      await baseUrl,
      apiPath,
      params.map((key, value) => MapEntry(key, value.toString())),
    );

    return getJson(url)
        .then((core.ApiResponse response) {
          final dynamic rawData = response.rawData;
          if (rawData is Map<String, dynamic>) {
            return rawData['status'] == 'success';
          }
          if (rawData is Map) {
            return rawData['status'] == 'success';
          }
          return false;
        })
        .catchError((Object error, StackTrace stackTrace) {
          if (kDebugMode) {
            log(
              'Unable to add statistics hit: $error',
              name: 'WebpageScreen.addStatisticsHit',
              stackTrace: stackTrace,
            );
          }
          return false;
        });
  }
}
