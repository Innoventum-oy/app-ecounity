import 'package:core/core.dart' as core;
import 'package:ecounity/src/learning/ecounity_learning_models.dart';
import 'package:ecounity/src/learning/ecounity_learning_provider.dart';
import 'package:ecounity/src/learning/widgets/ecounity_comic_player.dart';
import 'package:ecounity/src/widgets/screenscaffold.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EcoUnityComicScreen extends StatefulWidget {
  const EcoUnityComicScreen({
    super.key,
    required this.navIndex,
    this.activity,
    this.activityId,
  });

  final int navIndex;
  final EcoUnityLearningActivity? activity;
  final int? activityId;

  @override
  State<EcoUnityComicScreen> createState() => _EcoUnityComicScreenState();
}

class _EcoUnityComicScreenState extends State<EcoUnityComicScreen> {
  Future<_ComicScreenData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _loadComicData();
  }

  @override
  void didUpdateWidget(covariant EcoUnityComicScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activity != widget.activity ||
        oldWidget.activityId != widget.activityId) {
      _future = _loadComicData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ComicScreenData>(
      future: _future,
      builder:
          (BuildContext context, AsyncSnapshot<_ComicScreenData> snapshot) {
            final EcoUnityLearningActivity? activity = snapshot.data?.activity;
            final String title = activity?.title ?? 'Comic';

            return ScreenScaffold(
              title: title,
              navigationIndex: widget.navIndex,
              fullWidth: true,
              child: _buildBody(context, snapshot),
            );
          },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<_ComicScreenData> snapshot,
  ) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Unable to load comic: ${snapshot.error}'));
    }

    final _ComicScreenData? data = snapshot.data;
    final EcoUnityLearningActivity? activity = data?.activity;
    if (data == null || activity == null || activity.comicScenes.isEmpty) {
      return const Center(child: Text('No comic scenes available'));
    }

    final EcoUnityComic comic = EcoUnityComic(
      activity: activity,
      scenes: activity.comicScenes,
      rawData: activity.rawData,
    );

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.78,
      child: EcoUnityComicPlayer(
        comic: comic,
        language: data.language,
        onCompleted: () => _markCompleted(activity, data.language),
        onReadySpeech: (EcoUnityComicSpeechItem speech) {
          if (kDebugMode) {
            debugPrint('Ready comic speech audio: ${speech.audioFile?.url}');
          }
        },
      ),
    );
  }

  Future<_ComicScreenData> _loadComicData() async {
    final EcoUnityLearningProvider learningProvider =
        Provider.of<EcoUnityLearningProvider>(context, listen: false);
    final String language = await core.Settings().getLanguage() ?? 'en';
    EcoUnityLearningActivity? activity = widget.activity;
    final int? activityId = widget.activityId;

    if (activity == null && activityId != null) {
      activity = await learningProvider.loadActivity(
        activityId,
        language: language,
      );
    }

    return _ComicScreenData(activity: activity, language: language);
  }

  Future<void> _markCompleted(
    EcoUnityLearningActivity activity,
    String language,
  ) async {
    final int? moduleId = activity.moduleId;
    final int? activityId = activity.id;
    if (moduleId == null || activityId == null) {
      return;
    }

    await Provider.of<EcoUnityLearningProvider>(
      context,
      listen: false,
    ).markActivityCompleted(
      moduleId: moduleId,
      activityId: activityId,
      language: language,
      payload: <String, dynamic>{'activity_type': 'comic'},
    );
  }
}

class _ComicScreenData {
  const _ComicScreenData({required this.activity, required this.language});

  final EcoUnityLearningActivity? activity;
  final String language;
}
