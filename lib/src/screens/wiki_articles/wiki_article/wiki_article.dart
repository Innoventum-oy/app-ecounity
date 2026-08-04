import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';
import 'package:ecounity/src/widgets/webpage_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../widgets/screen_footer.dart';

/// WikiwebPage widget
class WikiArticle extends WebpageScreen {
  const WikiArticle({
    super.key,
    required super.navIndex,
    required super.webPage,
    super.openIntroduction = false,
    super.skipAutoIntroduction = false,
    super.pathways,
  });

  @override
  WikiArticleState createState() => WikiArticleState();
}

class WikiArticleState extends WebpageScreenState<WikiArticle> {
  final ScrollController _scrollController = ScrollController();
  late Future<Widget?> _contentsFuture;

  @override
  void initState() {
    super.initState();
    _contentsFuture = widget.webPage.contents;
  }

  @override
  void didUpdateWidget(covariant WikiArticle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.webPage.id != widget.webPage.id) {
      _contentsFuture = widget.webPage.contents;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget buildScreen(BuildContext context) {
    final bool isContentCompleted = status == PathwayStatus.completed;
    //  List<core.WebPage>? parents = Provider.of<core.WebPageProvider>(context, listen: false).findByKey('id', widget.webPage.parent);

    return ScreenScaffold(
      key: const ValueKey('screenshot-content-wiki-screen'),
      title: widget.webPage.title,
      navigationIndex: widget.navIndex,
      child: SingleChildScrollView(
        key: PageStorageKey<String>('wiki-article-${widget.webPage.id}'),
        controller: _scrollController,
        child: Column(
          children: [
            // webPage Thumbnail in Card if available
            if (widget.webPage.thumbnail != null)
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: Card(
                  child: widget.webPage.imageBuilder(
                    widget.webPage.thumbnailImage,
                  ),
                ),
              ),
            // WikiwebPage content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<Widget?>(
                future: _contentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error == null
                            ? context.l10n.noContentFound
                            : '${context.l10n.error}: ${snapshot.error}',
                      ),
                    );
                  }
                  return KeyedSubtree(
                    key: const ValueKey('screenshot-content-wiki-loaded'),
                    child: snapshot.data ?? Text(context.l10n.noContentFound),
                  );
                },
              ),
            ),
            // Completion button (completePathwayButton in a FutureBuilder)
            if (widget.webPage.references != null &&
                widget.webPage.references!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.0,
                  children: [
                    Text(
                      context.l10n.references,
                      style: TextTheme.of(context).headlineSmall,
                      textAlign: TextAlign.left,
                    ),
                    HtmlWidget(widget.webPage.references ?? ' - '),
                  ],
                ),
              ),
            ScreenFooter(
              webPage: widget.webPage,
              navIndex: widget.navIndex,
              pathways: widget.pathways,
              isCompleted: isContentCompleted,
              showOpenIntroduction: true,
              showMarkCompleted: true,
            ),
          ],
        ),
      ),
    );
  }
}
