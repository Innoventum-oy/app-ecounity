// navItems is used for Dashboard tiles and bottomNavigation

import 'package:flutter/material.dart';

import 'navigation_item.dart';

List<NavigationItem> navItems = [
  NavigationItem(navigationIndex: 0, label: 'home', icon: const Icon(Icons.home), route: '/dashboard',view: 'dashboard',displayInDashboard:false),
 // NavigationItem(navigationIndex: 1, label: 'pathways', icon: const Icon(Icons.menu_book), route: '/pathways', view: 'pathways',),
 // NavigationItem(navigationIndex: 2, label: 'videolist', icon: const Icon(Icons.video_camera_back), route: '/videoList', view: 'videoList',subMenu: true),
 //NavigationItem(navigationIndex: 3, label: 'lessons', icon: const Icon(Icons.library_books), route: '/lessons', view: 'wikiArticles',subMenu: true),
//  NavigationItem(navigationIndex: 4, label: 'challenges', icon: const Icon(Icons.quiz_outlined), route: '/challenges', view: 'challenges',subMenu: true),
 // NavigationItem(navigationIndex: 5, label: 'selfReflectionHub', icon: const Icon(Icons.my_library_books_outlined),route: '/self-reflection-hub', view: 'self-reflection-hub'),
  NavigationItem(navigationIndex: 1, label: 'modules', icon: const Icon(Icons.source_outlined),route: '/modules', view: 'modules'),
  NavigationItem(navigationIndex: 2, label: 'resources', icon: const Icon(Icons.perm_media_outlined),route: '/resources', view: 'resources'),
];

enum LoadingState { idle, done, loading, waiting, error }
class AppDefaults{
  static String? anonymousApiKey = '';
}
class AppRoutes{
  static const String dashboard = '/dashboard';
  static const String pathways = '/pathways';
  static const String lessons = '/lessons';
  static const String videoList = '/videolist';
  static const String challenges = '/challenges';
  static const String login = '/login';
  static const String register = '/register';
  static const String modules = '/modules';
  static const String submodules = '/submodules';
  static const String resources = '/resources';
}
final List<String> pathwayFields = [
  'id',
  'orderno',
  'pagetitle',
  'title',
  'textcontents',
  'thumbnailid',
  'accesslevel',
  'commonname',
  'pagecategory',
  'references',
  'maincategory',
  'pageid',
  'video',
  'authornametext',
  'pagecategory',
  'stage',
  'imagefolders',
  'introductionimage',
  'introductiontext',
  'completionimage',
  'completiontext',
  'form',
  'contentlanguages'
];
final Map<String, String> pathwayLoadParameters = {
  'fields': pathwayFields.join(','),
  'sort': 'pagetitle',
  'status': '2',
  'show_in_menu': '1',
  // 'language' : await Settings().getValue('language'),
  'pagecategory' : "isset:",
};
final Map<String, dynamic> badgeParams = {
  'fields' : 'name,description,image,badgeimageurl,requiredpathways,requiredpathwaydata,id',
  'sort': 'position'
  //'requiredactivities': "gt:0",
  // 'sort': 'requiredactivities',
};
