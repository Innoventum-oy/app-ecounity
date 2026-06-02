import 'package:core/core.dart' as core;
import 'package:ecounity/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:ecounity/src/util/core_compat.dart';
import 'package:ecounity/src/util/image_from_url.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SlidesCarousel extends StatefulWidget {
  const SlidesCarousel({super.key, required this.images, this.maxHeight});
  final List<core.ImageObject> images;
  final double? maxHeight;

  @override
  SlidesCarouselState createState() => SlidesCarouselState();
}

class SlidesCarouselState extends State<SlidesCarousel> {
  bool loaded = false;
  List<Widget> imageWidgets = [];
  List<Widget> linkWidgets = [];
  int currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // ...existing code...

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    // Ensure that you are not accessing the widget tree here
    super.dispose();
  }

  void initialize() {
    // Create widgets for the images

    for (var i = 0; i < widget.images.length; i++) {
      var image = widget.images[i];
      List<String>? externalLinks =
          image.externalLinks is String && image.externalLinks!.isNotEmpty
              ? image.externalLinks!.split(';')
              : null;

      Widget imageWidget = Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: Card(
              elevation: 4,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ImageFromUrl.get(image.imageUrl!,
                      fillContainer: false))));
      imageWidgets.add(imageWidget);

      if (externalLinks != null && externalLinks.isNotEmpty) {
        linkWidgets.addAll(
            List<Widget>.generate(externalLinks.length, (int linkIndex) {
          return Padding(
              padding:
                  const EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
              child: ElevatedButton(
                  onPressed: () {
                    goToUrl(externalLinks[linkIndex]);
                  },
                  child: Text(externalLinks[linkIndex],
                      style: const TextStyle(color: Colors.orange))));
        }));
      }
    }

    setState(() {
      loaded = true;
    });
  }

  void goToUrl(String link) async {
    final Uri url = Uri.parse(link);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $link');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.no_images_found));
    }

    if (loaded) {
      List<Widget> columnContents = [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            autoPlay: false,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            aspectRatio:
                16 / 9, // Default aspect ratio, will be overridden by image
            initialPage: 0,
            enableInfiniteScroll: widget.images.length > 1,
            height: widget.maxHeight ?? MediaQuery.sizeOf(context).height * 0.5,
            onPageChanged: (index, reason) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
          items: imageWidgets,
        ),
        // Page indicator dots
        if (widget.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
      ];

      if (linkWidgets.isNotEmpty) {
        columnContents.add(Padding(
            padding:
                const EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 10),
            child: Text(AppLocalizations.of(context)!.links,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold))));

        columnContents.addAll(linkWidgets);
      }

      return Column(children: columnContents);
    } else {
      return const CircularProgressIndicator();
    }
  }
}
