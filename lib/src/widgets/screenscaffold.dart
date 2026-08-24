import 'dart:developer';

import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../util/router.dart';
import 'app_bar_user_identity.dart';
import 'bottom_navigation.dart';

class ScreenScaffold extends StatefulWidget {
  final String title; // Page title
  final Widget child; // Page contents
  final List<Widget>? appBarButtons; // Buttons to show on top appBar
  final int? navigationIndex; // index for bottomNavigation
  final bool refresh; // refresh view indicator
  final bool fullWidth;
  final Function?
  onRefresh; // refresh functionality, causes refresh button to appear
  const ScreenScaffold({
    super.key,
    required this.title,
    required this.child,
    this.appBarButtons,
    this.navigationIndex = 1,
    this.refresh = false,
    this.onRefresh,
    this.fullWidth = false,
  });

  @override
  State<ScreenScaffold> createState() => _ScreenScaffoldState();
}

class _ScreenScaffoldState extends State<ScreenScaffold> {
  @override
  Widget build(BuildContext context) {
    core.User user = Provider.of<core.UserProvider>(context).user;
    core.UserProvider userProvider = Provider.of<core.UserProvider>(
      context,
      listen: false,
    );
    if (kDebugMode) {
      print('building screen scaffold ${widget.title}');
    }

    Widget bodyContent = widget.child;
    if (widget.refresh && widget.onRefresh != null) {
      bodyContent = RefreshIndicator(
        onRefresh: () async {
          await widget.onRefresh!();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: bodyContent,
        ),
      );
    }
    if (kDebugMode) {
      log(
        'ScreenScaffold: user.id: ${user.id}, onRefresh: ${widget.onRefresh}',
      );
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(core.unescapeHTML(widget.title)),
        elevation: 0.1,
        leading: (Navigator.canPop(context) && ModalRoute.of(context)!.canPop)
            ? const BackButton()
            : ClipOval(
                child: Image.asset(
                  'assets/images/ecounity-logo.png',
                  fit: BoxFit.scaleDown,
                ),
              ),
        actions: [
          // Language selector
          /*
            IconButton(
                icon: const Icon(Icons.language),
                onPressed: () {
                  // open language chooser
                  popupDialog(context.l10n.language, LanguageSelector(), context);
                }),
             */
          if (widget.onRefresh != null)
            IconButton(
              onPressed: () => widget.onRefresh!(),
              icon: const Icon(Icons.refresh),
            ),
          ...?widget.appBarButtons,
          AppBarUserIdentity(user: user),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              AppRouter.navigate(context, '/settings', 0, replaceRoute: false);
            },
          ),
          if (user.id != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                core.User loggedInUser = userProvider.user;
                if (!loggedInUser.isGuestUser) {
                  await Provider.of<core.AuthProvider>(
                    context,
                    listen: false,
                  ).logout(loggedInUser);
                }
                userProvider.clearCurrentUser();

                setState(() {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (Route<dynamic> route) => false,
                  );
                });
              },
            ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: widget.fullWidth
              ? null
              : const BoxConstraints(maxWidth: 800),
          child: bodyContent,
        ),
      ),
      bottomNavigationBar: bottomNavigation(
        context,
        currentIndex: widget.navigationIndex ?? 1,
      ),
    );
  }
}
