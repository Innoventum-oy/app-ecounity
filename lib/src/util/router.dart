import 'dart:developer';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:ecounity/src/providers/selected_pathway_notifier.dart';
import 'package:ecounity/src/screens/achievements/achievements_view.dart';
import 'package:ecounity/src/screens/challenges/challenges_screen.dart';
import 'package:ecounity/src/screens/challenges/dragdrop/dragdrop.dart';
import 'package:ecounity/src/screens/register/registration_form.dart';
import 'package:ecounity/src/screens/challenges/quiz/quiz.dart';
import 'package:ecounity/src/screens/video_list/video_list_screen.dart';
import '../objects/ecounity_badge.dart';
import '../screens/badge_view/badge_view.dart';
import '../screens/dashboard/components/settings_screen.dart';
import '../screens/dashboard/components/settings/settings_content_screen.dart';
import '../screens/dashboard/dashboard.dart';
import '../screens/login/login_form.dart';
import '../screens/modules/modules.dart';
import '../screens/modules/submodules.dart';
import '../screens/pathways/pathways.dart';
import '../screens/resources/resources.dart';
import '../screens/slides/slides.dart';
import '../screens/video_list/video/video.dart';
import '../screens/wiki_articles/wiki_article/wiki_article.dart';
import '../screens/wiki_articles/lessons_screen.dart';
import '../widgets/notifydialog.dart';

/// This router class takes care of navigating to different page routes defined by NavigationItems
class AppRouter {
  static const Set<String> _trackedPathwayViews = {
    'dragdrop',
    'quiz',
    'slides',
    'video',
    'wiki',
  };

  static void navigate(
    BuildContext context,
    String view,
    int navIndex, {
    refresh = false,
    replaceRoute = true,
    dynamic data,
    openIntroduction = false,
    skipAutoOpenIntroduction = false,
    WebPageList? pathways,
    callback,
  }) {
    if (kDebugMode) {
      log("Navigating to route $view, navIndex: $navIndex");
      if (pathways != null) {
        log("Pathways: ${pathways.length}");
      } else {
        log("Pathways: null");
      }
    }
    bool routeFound = false;
    Widget targetWidget = Text(context.l10n.errorViewNotFound(view));
    // Strip slashes from view
    view = view.replaceAll('/', '').toLowerCase();
    _updateSelectedPathway(context, view, data);
    switch (view) {
      case 'dashboard':
        targetWidget = DashBoard(navIndex: navIndex, refresh: refresh);
        routeFound = true;
        break;

      case 'webpage':
        //   targetWidget = WebPageView();
        routeFound = true;
        break;

      case 'pathways':
        targetWidget = const PathwaysScreen(navIndex: 1);
        routeFound = true;
        break;

      case 'videolist':
        targetWidget = const VideoListScreen(navIndex: 2);
        routeFound = true;
        break;
      case 'video':
        targetWidget = Video(
          navIndex: navIndex,
          webPage: data as WebPage,
          openIntroduction: openIntroduction,
          skipAutoIntroduction: skipAutoOpenIntroduction,
          pathways: pathways,
        );
        routeFound = true;
        break;

      case 'challenges':
        targetWidget = const ChallengesScreen(navIndex: 4);
        routeFound = true;
        break;
      case 'dragdrop':
        targetWidget = DragDrop(
          navIndex: navIndex,
          webPage: data as WebPage,
          openIntroduction: openIntroduction,
          skipAutoIntroduction: skipAutoOpenIntroduction,
          pathways: pathways,
        );
        routeFound = true;
        break;
      case 'slides':
        targetWidget = Slides(
          navIndex: navIndex,
          webPage: data as WebPage,
          openIntroduction: openIntroduction,
          skipAutoIntroduction: skipAutoOpenIntroduction,
          pathways: pathways,
        );
        routeFound = true;
        break;

      case 'quiz':
        targetWidget = Quiz(
          navIndex: navIndex,
          webPage: data as WebPage,
          openIntroduction: openIntroduction,
          skipAutoIntroduction: skipAutoOpenIntroduction,
          pathways: pathways,
        );
        routeFound = true;
        break;

      case 'wikiarticles':
        targetWidget = const WikiArticlesScreen(navIndex: 3);
        routeFound = true;
        break;
      case 'wiki':
        targetWidget = WikiArticle(
          navIndex: navIndex,
          webPage: data as WebPage,
          openIntroduction: openIntroduction,
          skipAutoIntroduction: skipAutoOpenIntroduction,
          pathways: pathways,
        );
        routeFound = true;
        break;
      case 'login':
        targetWidget = const Login();
        routeFound = true;
        break;

      case 'register':
        targetWidget = const RegistrationForm();
        routeFound = true;
        break;

      case 'settings':
        targetWidget = SettingsScreen(navigationIndex: navIndex);
        routeFound = true;
        break;

      case 'settingsprivacy':
        targetWidget = SettingsContentScreen(
          navigationIndex: navIndex,
          title: context.l10n.privacy_policy,
          commonName: 'app-privacy-policy',
        );
        routeFound = true;
        break;

      case 'settingsabout':
        targetWidget = SettingsContentScreen(
          navigationIndex: navIndex,
          title: context.l10n.about,
          commonName: 'app-about',
        );
        routeFound = true;
        break;

      case 'achievements':
        targetWidget = AchievementsView(navIndex: navIndex);
        routeFound = true;
        break;

      case 'badge':
        targetWidget = BadgeView(navIndex: navIndex, data as EcoUnityBadge);
        routeFound = true;
        break;

      case 'modules':
        targetWidget = ModulesView(navIndex: navIndex);
        routeFound = true;
        break;

      case 'submodules':
        targetWidget = SubModulesView(
          navIndex: navIndex,
          parent: data as WebPage,
        );
        routeFound = true;
        break;

      case 'resources':
        targetWidget = ResourcesView(
          navIndex: navIndex,
          webPage: (data != null) ? data as WebPage : null,
        );
        routeFound = true;
    }
    if (routeFound) {
      MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => targetWidget,
      );
      // if replaceRoute == true, replace the current route
      if (replaceRoute) {
        if (callback != null) {
          Navigator.of(context).pushReplacement(route).then(callback);
        } else {
          Navigator.of(context).pushReplacement(route);
        }
      } else {
        // push route
        if (callback != null) {
          Navigator.of(context).push(route).then(callback);
        } else {
          Navigator.of(context).push(route);
        }
      }
    } else {
      // Display error
      notifyDialog(context.l10n.error(''), targetWidget, context);
    }
  }

  static void _updateSelectedPathway(
    BuildContext context,
    String view,
    dynamic data,
  ) {
    if (!_trackedPathwayViews.contains(view) || data is! WebPage) {
      return;
    }

    Provider.of<SelectedPathwayNotifier>(context, listen: false).select(data);
  }
}
