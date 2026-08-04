import 'dart:developer';

import 'package:core/core.dart' as core;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations_extension.dart';
import '../objects/pathway.dart';
import '../util/router.dart';
import 'mark_pathway_completed.dart';

class ScreenFooter extends StatelessWidget {
  final core.WebPage webPage;
  final int navIndex;
  final core.WebPageList? pathways;
  final bool isCompleted;
  final bool showOpenIntroduction;
  final bool showMarkCompleted;
  final bool showNextWhenCompleted;
  final bool showRestart;
  final bool restartButtonLoading;
  final VoidCallback? onRestart;
  final VoidCallback? onCompletionDialogShow;
  final VoidCallback? onCompletionDialogHide;
  final String? restartButtonLabel;
  final IconData restartButtonIcon;

  const ScreenFooter({
    super.key,
    required this.webPage,
    required this.navIndex,
    this.pathways,
    required this.isCompleted,
    this.showOpenIntroduction = true,
    this.showMarkCompleted = true,
    this.showNextWhenCompleted = true,
    this.showRestart = false,
    this.restartButtonLoading = false,
    this.onRestart,
    this.onCompletionDialogShow,
    this.onCompletionDialogHide,
    this.restartButtonLabel,
    this.restartButtonIcon = Icons.refresh,
  });

  core.WebPageList? _resolvePathways(BuildContext context) {
    final String currentLanguage = Localizations.localeOf(context).languageCode;

    if (pathways != null) {
      return _buildNavigationPathways(pathways!.webPages, currentLanguage);
    }

    final core.WebPageProvider webPageProvider =
        Provider.of<core.WebPageProvider>(context, listen: false);
    final List<core.WebPage>? providerPages = webPageProvider.list;
    if (providerPages == null || providerPages.isEmpty) {
      return null;
    }

    return _buildNavigationPathways(providerPages, currentLanguage);
  }

  core.WebPageList? _buildNavigationPathways(
    Iterable<core.WebPage> pages,
    String currentLanguage,
  ) {
    final List<core.WebPage> localizedPathways = pages
        .where((page) => _isAvailableInLanguage(page, currentLanguage))
        .toList();

    final List<core.WebPage> navigationPathways = localizedPathways
        .where((page) => !_isNavigationContainer(page, localizedPathways))
        .toList();

    return navigationPathways.isNotEmpty
        ? core.WebPageList(webPages: navigationPathways)
        : null;
  }

  bool _isNavigationContainer(
    core.WebPage page,
    List<core.WebPage> localizedPathways,
  ) {
    final int? pageId = page.id;
    final bool hasChildPages =
        pageId != null &&
        localizedPathways.any((candidate) => candidate.parent == pageId);

    return page.isMainModule ||
        page.isSubModule ||
        page.isMainResource ||
        hasChildPages;
  }

  bool _isAvailableInLanguage(core.WebPage page, String currentLanguage) {
    final dynamic rawLanguageValue = page.getValue('contentlanguages');
    if (rawLanguageValue == null) {
      return true;
    }
    final List<String> languages = _normalizeLanguageList(rawLanguageValue);
    return languages.isEmpty || languages.contains(currentLanguage);
  }

  List<String> _normalizeLanguageList(dynamic value) {
    if (value is String) {
      return value
          .replaceAll(' ', '')
          .split(',')
          .where((lang) => lang.isNotEmpty)
          .toList();
    }
    if (value is List) {
      return value.whereType<dynamic>().map((item) => '$item').toList();
    }
    return [];
  }

  void _openIntroduction(
    BuildContext context,
    core.WebPageList? resolvedPathways,
  ) {
    if (webPage.hasIntroduction()) {
      AppRouter.navigate(
        context,
        webPage.type.name,
        navIndex,
        replaceRoute: true,
        openIntroduction: true,
        data: webPage,
        pathways: resolvedPathways,
      );
    }
  }

  void _navigateToNext(
    BuildContext context,
    core.WebPageList? resolvedPathways,
  ) {
    if (resolvedPathways == null) {
      return;
    }

    final core.WebPage? next = _getNextTarget(resolvedPathways);
    if (next == null) {
      return;
    }
    AppRouter.navigate(
      context,
      next.type.name,
      navIndex,
      data: next,
      pathways: resolvedPathways,
    );
  }

  int _currentIndex(core.WebPageList? resolvedPathways) {
    if (resolvedPathways == null) {
      return -1;
    }

    final int? id = webPage.id;
    if (id == null) {
      return resolvedPathways.webPages.indexOf(webPage);
    }

    for (int i = 0; i < resolvedPathways.webPages.length; i++) {
      if (resolvedPathways.webPages[i].id == id) {
        return i;
      }
    }
    return resolvedPathways.webPages.indexOf(webPage);
  }

  core.WebPage? _getNextInSameModule(core.WebPageList? resolvedPathways) {
    if (resolvedPathways == null) {
      return null;
    }
    final int currentIndex = _currentIndex(resolvedPathways);
    if (currentIndex < 0) {
      return null;
    }

    final core.WebPage currentPage = resolvedPathways.webPages[currentIndex];
    final int? parentId = currentPage.parent;
    if (parentId == null) {
      return null;
    }

    final List<core.WebPage> sameModule = resolvedPathways.webPages
        .where((page) => page.parent == parentId)
        .toList(growable: false);
    if (sameModule.isEmpty) {
      return null;
    }

    final int indexInModule = sameModule.indexWhere(
      (page) => page.id == currentPage.id,
    );
    if (indexInModule < 0 || indexInModule >= sameModule.length - 1) {
      return null;
    }

    return sameModule[indexInModule + 1];
  }

  core.WebPage? _getNextGlobal(core.WebPageList? resolvedPathways) {
    if (resolvedPathways == null) {
      return null;
    }
    final int currentIndex = _currentIndex(resolvedPathways);
    if (currentIndex < 0 ||
        currentIndex >= resolvedPathways.webPages.length - 1) {
      return null;
    }
    return resolvedPathways.webPages[currentIndex + 1];
  }

  core.WebPage? _getPreviousGlobal(core.WebPageList? resolvedPathways) {
    if (resolvedPathways == null) {
      return null;
    }
    final int currentIndex = _currentIndex(resolvedPathways);
    if (currentIndex <= 0) {
      return null;
    }
    return resolvedPathways.webPages[currentIndex - 1];
  }

  core.WebPage? _getNextTarget(core.WebPageList? resolvedPathways) {
    final core.WebPage? sameModule = _getNextInSameModule(resolvedPathways);
    if (sameModule != null) {
      return sameModule;
    }
    return _getNextGlobal(resolvedPathways);
  }

  core.WebPage? _getPreviousTarget(core.WebPageList? resolvedPathways) {
    final core.WebPage? sameModule = _getPreviousInSameModule(resolvedPathways);
    if (sameModule != null) {
      return sameModule;
    }
    return _getPreviousGlobal(resolvedPathways);
  }

  @visibleForTesting
  core.WebPage? getNextTargetForTesting(
    core.WebPageList pathways, {
    String currentLanguage = 'en',
  }) {
    return _getNextTarget(
      _buildNavigationPathways(pathways.webPages, currentLanguage),
    );
  }

  core.WebPage? _getPreviousInSameModule(core.WebPageList? resolvedPathways) {
    if (resolvedPathways == null) {
      return null;
    }
    final int currentIndex = _currentIndex(resolvedPathways);
    if (currentIndex < 0) {
      return null;
    }

    final core.WebPage currentPage = resolvedPathways.webPages[currentIndex];
    final int? parentId = currentPage.parent;
    if (parentId == null) {
      return null;
    }

    final List<core.WebPage> sameModule = resolvedPathways.webPages
        .where((page) => page.parent == parentId)
        .toList(growable: false);
    if (sameModule.isEmpty) {
      return null;
    }

    final int indexInModule = sameModule.indexWhere(
      (page) => page.id == currentPage.id,
    );
    if (indexInModule <= 0) {
      return null;
    }
    return sameModule[indexInModule - 1];
  }

  List<Widget> _navigationButtons(
    BuildContext context,
    core.WebPageList? resolvedPathways,
    bool isContentCompleted,
  ) {
    if (resolvedPathways == null) {
      return const [];
    }

    final List<Widget> items = [];

    final core.WebPage? previous = _getPreviousTarget(resolvedPathways);
    if (previous != null) {
      items.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.arrow_back),
          label: Text(context.l10n.previous),
          onPressed: () {
            AppRouter.navigate(
              context,
              previous.type.name,
              navIndex,
              data: previous,
              pathways: resolvedPathways,
            );
          },
        ),
      );
    }

    final bool shouldShowNext = showNextWhenCompleted
        ? isContentCompleted
        : true;
    final core.WebPage? nextInCurrentContext = _getNextTarget(resolvedPathways);
    if (nextInCurrentContext != null && shouldShowNext) {
      log('adding button to next content');
      items.add(
        ElevatedButton.icon(
          onPressed: () => _navigateToNext(context, resolvedPathways),
          icon: const Icon(Icons.arrow_forward),
          label: Text(context.l10n.next),
        ),
      );
    } else {
      log(
        'nextInCurrentContext: $nextInCurrentContext, shouldShowNext: $shouldShowNext}',
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final core.WebPageList? resolvedPathways = _resolvePathways(context);
    final List<Widget> footerButtons = [];

    if (showOpenIntroduction && webPage.hasIntroduction()) {
      footerButtons.add(
        ElevatedButton(
          onPressed: () => _openIntroduction(context, resolvedPathways),
          child: Text(context.l10n.view_introduction),
        ),
      );
    }

    if (showMarkCompleted) {
      footerButtons.add(
        Consumer<core.FileStorage>(
          builder: (context, fileStorage, child) {
            return FutureBuilder<Widget>(
              future: completePathwayButton(
                context,
                webPage,
                fileStorage,
                onDialogShow: onCompletionDialogShow,
                onDialogHide: onCompletionDialogHide,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return snapshot.data!;
                  }
                  return Text(context.l10n.error_loading_button);
                }
                return const CircularProgressIndicator();
              },
              initialData: const CircularProgressIndicator(),
            );
          },
        ),
      );
    }

    if (showRestart && onRestart != null) {
      footerButtons.add(
        ElevatedButton.icon(
          onPressed: restartButtonLoading ? null : onRestart,
          icon: restartButtonLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(restartButtonIcon),
          label: Text(restartButtonLabel ?? context.l10n.play_again),
        ),
      );
    }

    if (!showNextWhenCompleted) {
      footerButtons.addAll(_navigationButtons(context, resolvedPathways, true));
    }

    if (footerButtons.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!showNextWhenCompleted) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          alignment: WrapAlignment.center,
          children: footerButtons,
        ),
      );
    }

    return FutureBuilder<PathwayStatus?>(
      future: webPage.status,
      builder: (context, snapshot) {
        final PathwayStatus? status = snapshot.data;
        final bool effectiveCompleted =
            isCompleted || status == PathwayStatus.completed;
        final List<Widget> buttons = List<Widget>.from(footerButtons);
        log('effective completed: $effectiveCompleted');
        buttons.addAll(
          _navigationButtons(context, resolvedPathways, effectiveCompleted),
        );
        if (buttons.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            alignment: WrapAlignment.center,
            children: buttons,
          ),
        );
      },
    );
  }
}
