import 'dart:developer';

import 'package:ecounity/src/screens/slides/slides_carousel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:core/core.dart' as core;
import 'package:ecounity/src/util/core_compat.dart';
import 'package:ecounity/src/widgets/webpage_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/mark_pathway_completed.dart';
import '../../widgets/screenscaffold.dart';

class Slides extends WebpageScreen {
  const Slides(
      {super.key,
      required super.navIndex,
      required super.webPage,
      super.openIntroduction = false,
      super.pathways});

  @override
  State<StatefulWidget> createState() => SlidesState();
}

class SlidesState extends WebpageScreenState<Slides> {
  final _pageViewController = PageController(initialPage: 0);
  List<List<core.ImageObject>> imageLists = [];
  bool loading = false;
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

  Widget _buildSingleImage(core.ImageObject image) {
    List<String>? externalLinks =
        image.externalLinks is String && image.externalLinks!.isNotEmpty
            ? image.externalLinks!.split(';')
            : null;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Card(
            elevation: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                image.imageUrl!,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
        ),
        if (externalLinks != null && externalLinks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Text(
              AppLocalizations.of(context)!.links,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...externalLinks.map((link) => Padding(
                padding:
                    const EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
                child: ElevatedButton(
                  onPressed: () => _goToUrl(link),
                  child: Text(
                    link,
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
              )),
        ],
      ],
    );
  }

  void _goToUrl(String link) async {
    final Uri url = Uri.parse(link);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $link');
    }
  }

  void loadImages() async {
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
    String currentLanguage = Localizations.localeOf(context).languageCode;
    List<List<core.ImageObject>> filteredImageLists = [];

    if (imageLists.isNotEmpty) {
      for (List<core.ImageObject> imageList in imageLists) {
        List<core.ImageObject> filteredImages = imageList
            .where((el) =>
                (el.filelanguage == null || el.filelanguage == currentLanguage))
            .toList();
        if (filteredImages.isNotEmpty) {
          filteredImageLists.add(filteredImages);
        }
      }
    }

    imageLists = filteredImageLists;

    Widget slidesContent = SizedBox(
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

          return SingleChildScrollView(
            child: Column(
              children: [
                // Show full-width image if only one image, otherwise use carousel
                if (e.length == 1)
                  _buildSingleImage(e.first)
                else
                  SlidesCarousel(images: e),

                // Button for marking completion
                Padding(
                    padding: const EdgeInsets.only(
                        left: 0, right: 0, top: 20, bottom: 10),
                    child: Consumer<core.FileStorage>(
                      builder: (context, fileStorage, child) {
                        return FutureBuilder(
                          future: completePathwayButton(
                              context, widget.webPage, fileStorage),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                return snapshot.data!;
                              } else {
                                return Text(AppLocalizations.of(context)!
                                    .error_occurred);
                              }
                            }
                            return const CircularProgressIndicator();
                          },
                          initialData: const CircularProgressIndicator(),
                        );
                      },
                    ))
              ],
            ),
          );
        },
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
            padding: const EdgeInsets.only(left: 12.0, right: (12.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isCompleted
                    ? Expanded(
                        child: ListTile(
                          leading: const FaIcon(FontAwesomeIcons.check),
                          title: Text(context.l10n.completed),
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
              child: slidesContent,
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
