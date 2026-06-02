import 'dart:developer';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecounity/l10n/app_localizations_extension.dart';
import 'package:core/core.dart' as core;
import 'package:ecounity/src/objects/ecounity_badge.dart';
import '../../util/navigation_item.dart';
import '../../util/settings.dart';
import '../../widgets/bottom_navigation.dart';

import 'components/badge_icon_display.dart';
import 'components/badges_widget.dart';
import 'components/dashboard_progress_card.dart';
import 'package:ecounity/src/util/router.dart';

import 'components/next_pathway.dart';

class DashBoard extends StatefulWidget {
  final String viewTitle = 'dashboard'; // This is the common name of the view
  final int navIndex; // The index of the navigation item to be highlighted
  final bool refresh; // Whether to refresh the view

  const DashBoard({this.navIndex = 0, this.refresh = false, super.key});

  @override
  DashBoardState createState() => DashBoardState();
}

class DashBoardState extends State<DashBoard> {
  int buildIteration = 1; // The number of times the view has been built
  bool loaded = false; // Whether the view has been loaded
  core.User user = core.User(); // The current user
  List<EcoUnityBadge> badges = []; // The list of badges
  bool loginPopupDisplayed =
      false; // Whether the login popup has been displayed
  String? errorMessage; // The error message
  core.FileStorage fileStorage = core.FileStorage();

  @override
  void initState() {
    // Add listener to file storage
    fileStorage.addListener(_fileStorageListener);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      buildIteration = 1; // Reset the build iteration
      user = Provider.of<core.UserProvider>(
        context,
        listen: false,
      ).user; // Get the current user
      load();
    });

    super.initState();
  }

  @override
  void dispose() {
    fileStorage.removeListener(_fileStorageListener);
    super.dispose();
  }

  void _fileStorageListener() async {
    if (mounted) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> load() async {
    loaded = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      log('Building dashboard, iteration $buildIteration');
    }
    buildIteration++;
    user = Provider.of<core.UserProvider>(context).user; // Get the current user

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/ecounity-logo.png', height: 60),
        elevation: 0.1,
        actions: [
          /*
              IconButton(
                  icon: const Icon(Icons.language),
                  onPressed: () {
                    // open language chooser
                    popupDialog(context.l10n.language, LanguageSelector(), context);
                  }),
               */
          //Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              if (!user.isGuest) {
                Provider.of<core.UserProvider>(
                  context,
                  listen: false,
                ).refreshUser();
              }
            },
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              AppRouter.navigate(context, '/settings', 0, replaceRoute: false);
            },
          ),
          //Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Logout the user with the auth provider

              Navigator.of(context).pop();
              //
              UserProvider userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              User loggedInUser = userProvider.user;
              if (!loggedInUser.isGuest) {
                // only logout if the user is not a guest
                await Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).logout(loggedInUser);
              }
              // Clear the current user from the user provider
              userProvider.clearCurrentUser();
              if (mounted) {
                setState(() {
                  // Navigate to the home screen
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (Route<dynamic> route) => false,
                  );
                });
              }
            },
          ),
          //User card link
        ],
      ),
      body: !loaded
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(
                  children: <Widget>[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final bool useColumn = constraints.maxWidth < 700;
                          final List<Widget> cards = const [
                            DashboardProgressCard(),
                            NextPathway(),
                          ];

                          if (useColumn) {
                            return Column(
                              children: [
                                for (int i = 0; i < cards.length; i++) ...[
                                  cards[i],
                                  if (i < cards.length - 1)
                                    const SizedBox(height: 10),
                                ],
                              ],
                            );
                          }

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (int i = 0; i < cards.length; i++) ...[
                                  Expanded(child: cards[i]),
                                  if (i < cards.length - 1)
                                    const SizedBox(width: 10),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                      child: Card(
                        elevation: 3.0,
                        child: dashboardBadgesWidget(user, badges, context),
                      ),
                    ),
                    ...navItems.map(
                      (navItem) => (navItem.displayInDashboard
                          ? dashboardTile(navItem)
                          : Container()),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: bottomNavigation(
        context,
        currentIndex: widget.navIndex,
      ),
    );
  }

  Widget dashboardTile(NavigationItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Card(
        elevation: 3.0,
        child: ListTile(
          leading: item.subMenu ? const Icon(Icons.arrow_right) : null,
          visualDensity: const VisualDensity(
            vertical: VisualDensity.maximumDensity,
          ),
          title: Text(
            context.l10n.navigation_item(item.label),
            style: const TextStyle(fontSize: 20),
          ),
          trailing: item.icon ?? item.faIcon,
          onTap: () {
            AppRouter.navigate(context, item.view, item.navigationIndex);
          },
        ),
      ),
    );
  }

  /* Widget list creator for collected badges */
  List<Widget> collectedBadges(
    List<EcoUnityBadge> collectedBadges,
    BuildContext context,
  ) {
    List<Widget> data = [];
    if (collectedBadges.isEmpty) return data;
    for (EcoUnityBadge badge in collectedBadges) {
      data.add(badgeIconDisplay(badge, context));
    }
    return data;
  }
}
