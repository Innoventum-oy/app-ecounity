import 'dart:developer';

import 'package:ecounity/src/providers/teacher_mode_provider.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../util/navigation_item.dart';
import '../util/settings.dart' as constants;
import 'package:ecounity/l10n/app_localizations_extension.dart';
import '../util/router.dart';

Widget bottomNavigation(BuildContext context, {int currentIndex = 0}) {
  final bool teacherModeEnabled = Provider.of<TeacherModeProvider>(
    context,
  ).isTeacherMode;
  final List<NavigationItem> bottomNavItems = constants.navItems
      .where((item) => item.displayInBottomNavigation)
      .map((NavigationItem item) {
        if (!teacherModeEnabled || item.view != 'progress') {
          return item;
        }
        return NavigationItem(
          navigationIndex: item.navigationIndex,
          label: 'teacher',
          icon: const Icon(Icons.school_outlined),
          route: '/teacher',
          view: 'teacher',
          displayInDashboard: item.displayInDashboard,
          displayInBottomNavigation: item.displayInBottomNavigation,
        );
      })
      .toList();
  return DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: EcoUnityColors.outlineVariant)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 18,
          offset: Offset(0, -4),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Row(
          children: <Widget>[
            for (final NavigationItem navItem in bottomNavItems)
              Expanded(
                child: _BottomNavigationDestination(
                  navItem: navItem,
                  selected: navItem.navigationIndex == currentIndex,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _BottomNavigationDestination extends StatelessWidget {
  const _BottomNavigationDestination({
    required this.navItem,
    required this.selected,
  });

  final NavigationItem navItem;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final String label = context.l10n.navigation_item(navItem.label);
    final Color contentColor = selected
        ? EcoUnityColors.deepTeal
        : EcoUnityColors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _navigate(context, navItem),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFE6F8F7) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconTheme(
                    data: IconThemeData(color: contentColor, size: 22),
                    child: KeyedSubtree(
                      key: ValueKey('screenshot-bottom-nav-${navItem.view}'),
                      child: navItem.getIcon(),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: contentColor,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _navigate(BuildContext context, NavigationItem navItem) {
  if (kDebugMode) {
    log('${navItem.navigationIndex} ${navItem.view} ');
  }

  AppRouter.navigate(context, navItem.view, navItem.navigationIndex);
  // Navigator.pushNamedAndRemoveUntil(context, navItem.route, (Route<dynamic> route) => false);
}
