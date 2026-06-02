import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:core/core.dart' as core;
import 'package:ecounity/src/util/core_compat.dart';
import 'package:ecounity/src/widgets/webpage_screen.dart';
import '../../../widgets/completion_page.dart';
import '../../../widgets/popupdialog.dart';
import '../../../widgets/screenscaffold.dart';
import 'components/dragdrop_challenge.dart';

class DragDrop extends WebpageScreen {
  const DragDrop(
      {super.key,
      required super.navIndex,
      required super.webPage,
      super.openIntroduction = false,
      super.pathways});

  @override
  State<StatefulWidget> createState() => DragDropState();
}

class DragDropState extends WebpageScreenState<DragDrop> {
  final _pageViewController = PageController(initialPage: 0);
  final formKey = GlobalKey<FormState>();
  List<List<core.ImageObject>> imageLists = [];
  bool loading = false;
  Map<int, dynamic> formData = {};
  bool isCompleted = false;
  @override
  void initState() {
    loadImages();
    super.initState();
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  Future<void> loadImages() async {
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
        List<core.ImageObject> images = await imageProvider
            .getItems({'category': folder['objectid']}, reload: true);
        if (images.isNotEmpty) {
          // Add images to the list
          imageLists.add(images);
        }
      }
    }
    isCompleted = await widget.webPage.isCompleted();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget buildScreen(BuildContext context, {List<Widget> buttons = const []}) {
    List<core.WebPage>? parents =
        Provider.of<core.WebPageProvider>(context, listen: false)
            .findByKey('id', widget.webPage.parent);
    core.WebPage? parent =
        parents != null && parents.isNotEmpty ? parents.first : null;

    Widget quizContent = Form(
      key: formKey,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: PageView.builder(
          controller: _pageViewController,
          itemCount: imageLists.length,
          itemBuilder: (context, index) {
            List<Widget> quizButtons = [];
            List<core.ImageObject> e = imageLists.elementAt(index);
            if (index > 0) {
              quizButtons.add(ElevatedButton.icon(
                onPressed: () => _pageViewController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.linear),
                icon: const Icon(Icons.arrow_back),
                label: Text(context.l10n.button_previous),
              ));
            }
            if (index < imageLists.length - 1) {
              quizButtons.add(ElevatedButton.icon(
                onPressed: () {
                  if (_pageViewController.hasClients) {
                    _pageViewController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linear);
                  }
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(context.l10n.button_next),
              ));
            } else if (index == imageLists.length - 1) {}
            double maxHeight = MediaQuery.of(context).size.height * 0.75;
            return SingleChildScrollView(
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    child: DragDropChallenge(
                      images: e,
                      onCompleted: () async {
                        if (kDebugMode) {
                          log('Drag and drop completed, index: $index, imageLists: ${imageLists.length}');
                        }
                        if (index < imageLists.length - 1) {
                          // Move to the next page
                          if (kDebugMode) {
                            log('Moving to next page since $index < ${imageLists.length - 1}');
                          }
                          _pageViewController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.linear);
                        } else {
                          // Mark the challenge as completed and display the completion page
                          if (mounted) {
                            if (kDebugMode) {
                              log('Marking challenge as completed');
                            }
                            await widget.webPage
                                .setStatus(PathwayStatus.completed, context);
                          }
                          if (context.mounted) {
                            if (kDebugMode) {
                              log('Showing completion popup');
                            }
                            // if the pathway has completion text, show completion popup

                            popupDialog(
                                context.l10n.pathway_completed,
                                CompletionPage(pathway: widget.webPage),
                                context,
                                actions: [
                                  ElevatedButton(
                                      child: Text(context.l10n.ok),
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                      })
                                ]);
                          } else if (kDebugMode) {
                            log('Challenge completed, but no completion popup shown, context not mounted');
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    spacing: 12,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: quizButtons,
                  ),
                  if (imageLists.length > 1)
                    Center(
                      child: Text(
                        "${index + 1} / ${imageLists.length}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );

    return ScreenScaffold(
      fullWidth: true,
      title: widget.webPage.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.question_mark),
                    title: Text(
                        "${context.l10n.pathway}: ${parent?.title ?? 'Unknown'}"),
                  ),
                ),
                isCompleted
                    ? Expanded(
                        child: ListTile(
                          leading: const FaIcon(FontAwesomeIcons.check),
                          title: Text(context.l10n.completed),
                          //subtitle: Text(AppLocalizations.of(context)!.completed_on(widget.webPage.completedDate)),
                        ),
                      )
                    : const Spacer(),
              ],
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: quizContent,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                // Previous button
                buttons,
          ),
        ],
      ),
    );
  }
}
