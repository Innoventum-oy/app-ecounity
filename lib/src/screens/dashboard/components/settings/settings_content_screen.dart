import 'package:core/core.dart' as core;
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class SettingsContentScreen extends StatefulWidget {
  final int navigationIndex;
  final String title;
  final String commonName;

  const SettingsContentScreen({
    required this.navigationIndex,
    required this.title,
    required this.commonName,
    super.key,
  });

  @override
  State<SettingsContentScreen> createState() => _SettingsContentScreenState();
}

class _SettingsContentScreenState extends State<SettingsContentScreen> {
  final core.WebPageProvider _pageProvider = core.WebPageProvider();
  Future<core.WebPage?>? _pageFuture;
  String? _loadedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String locale = Localizations.localeOf(context).toString();
    if (_pageFuture == null || _loadedLocale != locale) {
      _loadedLocale = locale;
      _pageFuture = _loadPage(locale);
    }
  }

  @override
  void didUpdateWidget(covariant SettingsContentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commonName != widget.commonName) {
      final String locale =
          _loadedLocale ?? Localizations.localeOf(context).toString();
      _pageFuture = _loadPage(locale);
    }
  }

  @override
  void dispose() {
    _pageProvider.dispose();
    super.dispose();
  }

  Future<core.WebPage?> _loadPage(String locale) {
    return _pageProvider.loadItem({
      'language': locale,
      'commonname': widget.commonName,
      'fields':
          'id,commonname,pagetitle,textcontents,thumbnailid,images,references',
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<core.WebPage?>(
      future: _pageFuture,
      builder: (context, snapshot) {
        final core.WebPage? page = snapshot.data;
        final String title = page != null && page.title.isNotEmpty
            ? page.title
            : widget.title;

        return ScreenScaffold(
          title: title,
          navigationIndex: widget.navigationIndex,
          child: _buildBody(context, snapshot),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<core.WebPage?> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('${context.l10n.error}: ${snapshot.error}'),
        ),
      );
    }

    final core.WebPage? page = snapshot.data;
    if (page == null) {
      return Center(child: Text(context.l10n.noContentFound));
    }

    return SingleChildScrollView(
      key: PageStorageKey<String>('settings-content-${widget.commonName}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (page.thumbnail != null)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Card(child: page.imageBuilder(page.thumbnailImage)),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<Widget?>(
              future: page.contents,
              builder: (context, contentSnapshot) {
                if (contentSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (contentSnapshot.hasError) {
                  return Center(
                    child: Text(
                      contentSnapshot.error == null
                          ? context.l10n.noContentFound
                          : '${context.l10n.error}: ${contentSnapshot.error}',
                    ),
                  );
                }
                return contentSnapshot.data ??
                    Text(context.l10n.noContentFound);
              },
            ),
          ),
          if (page.references != null && page.references!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8.0,
                children: [
                  Text(
                    context.l10n.references,
                    style: TextTheme.of(context).headlineSmall,
                  ),
                  HtmlWidget(page.references ?? ''),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
