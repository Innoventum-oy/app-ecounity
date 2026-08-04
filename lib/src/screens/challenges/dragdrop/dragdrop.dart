import 'dart:async';
import 'dart:developer';

import 'package:core/core.dart' as core;
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:ecounity/src/util/core_compat.dart';
import 'package:ecounity/src/widgets/webpage_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../widgets/completion_page.dart';
import '../../../widgets/popupdialog.dart';
import '../../../widgets/screen_footer.dart';
import '../../../widgets/screenscaffold.dart';
import 'components/dragdrop_challenge.dart';

const bool _screenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');

class DragDrop extends WebpageScreen {
  const DragDrop({
    super.key,
    required super.navIndex,
    required super.webPage,
    super.openIntroduction = false,
    super.skipAutoIntroduction = false,
    super.pathways,
  });

  @override
  State<StatefulWidget> createState() => DragDropState();
}

class DragDropState extends WebpageScreenState<DragDrop> {
  final _pageViewController = PageController(initialPage: 0);
  final formKey = GlobalKey<FormState>();
  List<List<core.ImageObject>> imageLists = [];
  static const String _progressStorageKeyPrefix = 'dragDropProgress_';
  final Map<int, Map<String, dynamic>> _pageStates = {};
  final Set<int> _completedPages = {};
  bool _initialized = false;
  bool _isCompleting = false;
  int _currentPageIndex = 0;
  int _restartToken = 0;
  int? _storedPageCount;

  String? get _progressStorageKey => widget.webPage.id == null
      ? null
      : '$_progressStorageKeyPrefix${widget.webPage.id}';

  @override
  void initState() {
    super.initState();
    if (!openIntroduction) {
      _initializeDragDrop();
    }
  }

  @override
  void listener() {
    final bool wasIntroductionOpen = openIntroduction;
    super.listener();
    if (wasIntroductionOpen && !openIntroduction && imageLists.isEmpty) {
      _initializeDragDrop();
    }
  }

  Future<void> _initializeDragDrop() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _loadStoredProgress();
    if (!openIntroduction) {
      await loadImages();
    }
  }

  Future<void> _loadStoredProgress() async {
    if (_screenshotMode) {
      return;
    }

    final String? storageKey = _progressStorageKey;
    if (storageKey == null) {
      return;
    }
    _storedPageCount = null;

    dynamic data = await fileStorage.getObject(storageKey, boxName: 'userData');
    if (data is! Map) {
      return;
    }

    final int? storedPageIndex = data['pageIndex'] is int
        ? data['pageIndex'] as int
        : int.tryParse('${data['pageIndex']}');
    final int storedRestartToken = data['restartToken'] is int
        ? data['restartToken'] as int
        : int.tryParse('${data['restartToken']}') ?? 0;
    _restartToken = storedRestartToken;
    _currentPageIndex = storedPageIndex ?? 0;

    _completedPages.clear();
    final dynamic storedCompletedPages = data['completedPages'];
    if (storedCompletedPages is List) {
      for (final dynamic value in storedCompletedPages) {
        final int? page = value is int ? value : int.tryParse('$value');
        if (page != null) {
          _completedPages.add(page);
        }
      }
    }

    final dynamic storedPageStates = data['pageStates'];
    if (storedPageStates is Map) {
      _pageStates.clear();
      storedPageStates.forEach((dynamic key, dynamic value) {
        final int? page = int.tryParse('$key');
        if (page == null || value is! Map) {
          return;
        }
        _pageStates[page] = {
          for (final dynamic mapKey in value.keys)
            mapKey.toString(): value[mapKey],
        };
      });
    }

    final dynamic storedPageCount = data['pageCount'];
    if (storedPageCount is int) {
      _storedPageCount = storedPageCount;
    } else {
      _storedPageCount = int.tryParse('$storedPageCount');
    }
  }

  Future<void> _saveProgress() async {
    if (_screenshotMode) {
      return;
    }

    final String? storageKey = _progressStorageKey;
    if (storageKey == null || imageLists.isEmpty) {
      return;
    }
    final Map<String, dynamic> serializedPageStates = {};
    for (final MapEntry<int, Map<String, dynamic>> entry
        in _pageStates.entries) {
      serializedPageStates[entry.key.toString()] = entry.value;
    }

    final Map<String, dynamic> progressData = {
      'pageIndex': _currentPageIndex,
      'restartToken': _restartToken,
      'completedPages': _completedPages.toList()..sort(),
      'pageStates': serializedPageStates,
      'pageCount': imageLists.length,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
    await fileStorage.setObject(storageKey, progressData, boxName: 'userData');
  }

  void _restorePagePosition() {
    if (imageLists.isEmpty) {
      return;
    }
    final int maxPageIndex = imageLists.length - 1;
    final int pageIndex = _currentPageIndex.clamp(
      0,
      maxPageIndex.clamp(0, maxPageIndex),
    );
    if (_currentPageIndex != pageIndex) {
      _currentPageIndex = pageIndex;
    }
    if (_pageViewController.hasClients) {
      _pageViewController.jumpToPage(_currentPageIndex);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageViewController.hasClients) {
          _pageViewController.jumpToPage(_currentPageIndex);
        }
      });
    }
  }

  Future<void> _clearStoredProgress() async {
    final String? storageKey = _progressStorageKey;
    if (storageKey == null) {
      return;
    }
    await fileStorage.deleteObject(storageKey, boxName: 'userData');
  }

  void _onPageChanged(int index) {
    _currentPageIndex = index;
    unawaited(_saveProgress());
  }

  Map<String, dynamic>? _getPageChallengeState(int pageIndex) {
    final Map<String, dynamic>? state = _pageStates[pageIndex];
    if (state == null) {
      return null;
    }

    if (imageLists.isEmpty ||
        pageIndex < 0 ||
        pageIndex >= imageLists.length ||
        !isChallengeStateCompatible(pageIndex, state)) {
      return null;
    }

    return state;
  }

  bool isChallengeStateCompatible(int pageIndex, Map<String, dynamic> state) {
    if (imageLists.isEmpty || pageIndex < 0 || pageIndex >= imageLists.length) {
      return false;
    }
    final List<core.ImageObject> images = imageLists[pageIndex];
    if (images.isEmpty) {
      return false;
    }

    final dynamic imageIds = state['imageIds'];
    if (imageIds == null) {
      return true;
    }
    if (imageIds is! List) {
      return false;
    }

    final List<String> storedIds = imageIds
        .map((dynamic id) => '$id')
        .where((String value) => value.isNotEmpty)
        .toList();
    final List<String> currentIds = images
        .map((core.ImageObject image) => '${image.id}')
        .toList();

    if (storedIds.length != currentIds.length) {
      return false;
    }

    final Map<String, int> storedCounts = {};
    for (final String value in storedIds) {
      storedCounts[value] = (storedCounts[value] ?? 0) + 1;
    }
    final Map<String, int> currentCounts = {};
    for (final String value in currentIds) {
      currentCounts[value] = (currentCounts[value] ?? 0) + 1;
    }

    if (storedCounts.length != currentCounts.length) {
      return false;
    }

    for (final MapEntry<String, int> entry in storedCounts.entries) {
      if (currentCounts[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  void _invalidateStoredProgress() {
    _pageStates.clear();
    _completedPages.clear();
  }

  void _updateChallengeState(int pageIndex, Map<String, dynamic> state) {
    if (pageIndex < 0 || imageLists.isEmpty || pageIndex >= imageLists.length) {
      return;
    }

    final Map<String, dynamic> normalizedState = Map<String, dynamic>.from(
      state,
    );
    final List<core.ImageObject> images = imageLists[pageIndex];
    normalizedState['imageIds'] = images
        .map((core.ImageObject image) => image.id)
        .toList();
    _pageStates[pageIndex] = normalizedState;
    unawaited(_saveProgress());
  }

  Future<void> _onChallengeCompleted(int index, bool passed) async {
    if (!passed || _isCompleting) {
      return;
    }
    _isCompleting = true;
    try {
      _completedPages.add(index);
      if (index < imageLists.length - 1) {
        _currentPageIndex = index + 1;
        if (_pageViewController.hasClients) {
          await _pageViewController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          );
        }
      } else {
        if (!mounted) {
          return;
        }
        final String completedLabel = context.l10n.pathway_completed;
        final String okLabel = context.l10n.ok;
        final core.WebPage completedPage = widget.webPage;
        await completedPage.setStatus(PathwayStatus.completed, context);
        if (!mounted) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          popupDialog(
            completedLabel,
            CompletionPage(pathway: completedPage),
            context,
            actions: [
              ElevatedButton(
                child: Text(okLabel),
                onPressed: () {
                  if (mounted) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                },
              ),
            ],
          );
        });
      }
      await _saveProgress();
    } finally {
      _isCompleting = false;
    }
  }

  Future<void> _restartChallenge() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _currentPageIndex = 0;
      _restartToken++;
      _invalidateStoredProgress();
    });
    if (_pageViewController.hasClients) {
      _pageViewController.jumpToPage(0);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageViewController.hasClients) {
          _pageViewController.jumpToPage(0);
        }
      });
    }
    await _clearStoredProgress();
    await _saveProgress();
  }

  void restartChallenge() {
    unawaited(_restartChallenge());
  }

  Widget _instructionStep(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _showDragDropInstructions() {
    popupDialog(
      'How to play',
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _instructionStep(
            Icons.text_fields,
            'Drag each text card onto the matching image.',
          ),
          _instructionStep(
            Icons.swap_vert,
            'If the image you need is off-screen, scroll the grid or long-press an image and drag it onto another tile to swap their positions.',
          ),
          _instructionStep(
            Icons.image_outlined,
            'Moving images only rearranges the grid. It does not submit an answer.',
          ),
          _instructionStep(
            Icons.check_circle_outline,
            'Matched pairs stay together. Use Play again to restart.',
          ),
        ],
      ),
      context,
    );
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  Future<void> loadImages() async {
    imageLists = [];
    final AppImageProvider imageProvider = Provider.of<AppImageProvider>(
      context,
      listen: false,
    );
    // Get image folders for the drag and drop challenge page
    dynamic folders = widget.webPage.getValue('imagefolders');
    if (kDebugMode) {
      log('Folders: $folders');
    }
    if (folders != null) {
      // Get images for each folder
      for (Map<dynamic, dynamic> folder in folders) {
        List<core.ImageObject> images = await imageProvider.getItems({
          'category': folder['objectid'],
        });
        images = images
            .where((image) => (image.imageUrl ?? '').trim().isNotEmpty)
            .toList();
        if (images.length >= 2) {
          // Add images to the list
          imageLists.add(images);
        }
      }
    }
    if (_storedPageCount != null && _storedPageCount != imageLists.length) {
      _invalidateStoredProgress();
    }
    if (mounted) {
      setState(() {});
      _restorePagePosition();
      _saveProgress();
    }
  }

  @override
  Widget buildScreen(BuildContext context) {
    final bool isContentCompleted = status == PathwayStatus.completed;
    final bool compactLayout = MediaQuery.sizeOf(context).width < 700;
    List<core.WebPage>? parents = Provider.of<core.WebPageProvider>(
      context,
      listen: false,
    ).findByKey('id', widget.webPage.parent);
    core.WebPage? parent = parents != null && parents.isNotEmpty
        ? parents.first
        : null;

    Widget quizContent = Form(
      key: formKey,
      child: PageView.builder(
        controller: _pageViewController,
        itemCount: imageLists.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final List<Widget> quizButtons = [];
          final List<core.ImageObject> e = imageLists.elementAt(index);
          if (index > 0) {
            quizButtons.add(
              ElevatedButton.icon(
                onPressed: () => _pageViewController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linear,
                ),
                icon: const Icon(Icons.arrow_back),
                label: Text(context.l10n.button_previous),
              ),
            );
          }
          if (index < imageLists.length - 1) {
            quizButtons.add(
              ElevatedButton.icon(
                onPressed: () {
                  if (_pageViewController.hasClients) {
                    _pageViewController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.linear,
                    );
                  }
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(context.l10n.button_next),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DragDropChallenge(
                  key: ValueKey('${widget.webPage.id}-$index-$_restartToken'),
                  images: e,
                  initialState: _screenshotMode
                      ? null
                      : _getPageChallengeState(index),
                  onStateChanged: (state) =>
                      _updateChallengeState(index, state),
                  onRestart: restartChallenge,
                  onCompleted: (bool passed) =>
                      _onChallengeCompleted(index, passed),
                ),
              ),
              if (quizButtons.isNotEmpty || imageLists.length > 1)
                Padding(
                  padding: EdgeInsets.only(top: compactLayout ? 8.0 : 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 12.0,
                          runSpacing: 8.0,
                          alignment: quizButtons.length > 1
                              ? WrapAlignment.spaceBetween
                              : index > 0
                              ? WrapAlignment.start
                              : WrapAlignment.end,
                          children: quizButtons,
                        ),
                      ),
                      if (imageLists.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            "${index + 1} / ${imageLists.length}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
    return ScreenScaffold(
      key: const ValueKey('screenshot-content-dragdrop-screen'),
      fullWidth: true,
      title: widget.webPage.title,
      appBarButtons: [
        IconButton(
          tooltip: 'How to play',
          icon: const Icon(Icons.lightbulb_outline),
          onPressed: _showDragDropInstructions,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              16.0,
              compactLayout ? 8.0 : 16.0,
              16.0,
              compactLayout ? 4.0 : 16.0,
            ),
            child: ListTile(
              dense: compactLayout,
              visualDensity: compactLayout
                  ? VisualDensity.compact
                  : VisualDensity.standard,
              leading: isContentCompleted
                  ? const FaIcon(FontAwesomeIcons.check)
                  : const Icon(Icons.question_mark),
              title: Text(
                "${context.l10n.pathway}: ${parent?.title ?? 'Unknown'}",
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                compactLayout ? 8.0 : 16.0,
                compactLayout ? 4.0 : 16.0,
                compactLayout ? 8.0 : 16.0,
                compactLayout ? 8.0 : 16.0,
              ),
              child: quizContent,
            ),
          ),
          ScreenFooter(
            webPage: widget.webPage,
            navIndex: widget.navIndex,
            pathways: widget.pathways,
            isCompleted: isContentCompleted,
            showOpenIntroduction: true,
            showMarkCompleted: false,
            showRestart: true,
            onRestart: restartChallenge,
          ),
        ],
      ),
    );
  }
}
