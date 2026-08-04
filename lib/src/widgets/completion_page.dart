// Completion for a Page (Pathway)
import 'package:core/core.dart' as core;
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/objects/pathway.dart';
import 'package:ecounity/src/util/core_compat.dart';
import 'package:ecounity/src/util/image_from_url.dart';
import 'package:flutter/material.dart';

class CompletionPage extends StatelessWidget {
  final core.WebPage pathway;

  const CompletionPage({super.key, required this.pathway});

  Widget _buildCompletionImage(BuildContext context) {
    if (!pathway.hasCompletionImage()) {
      return Image.asset('assets/images/completed.png', fit: BoxFit.contain);
    }

    return FutureBuilder<core.ImageObject?>(
      future: pathway.completionImage,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text(context.l10n.error_default));
        }

        final String? imageUrl = snapshot.data?.imageUrl;
        if (imageUrl == null || imageUrl.isEmpty) {
          return Center(child: Text(context.l10n.no_image_available));
        }

        return ImageFromUrl.get(imageUrl);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double imageWidth = (MediaQuery.sizeOf(context).width * 0.72).clamp(
      180.0,
      360.0,
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article Thumbnail in Card if available
          Center(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: imageWidth,
                  maxHeight: 400,
                ),
                child: SizedBox(
                  width: imageWidth,
                  child: _buildCompletionImage(context),
                ),
              ),
            ),
          ),

          pathway.getCompletionText(context),
        ],
      ),
    );
  }
}
