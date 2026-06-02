import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../util/navigation_item.dart';
import '../util/settings.dart' as constants;
import 'package:ecounity/l10n/app_localizations_extension.dart';
import '../util/router.dart';

Widget bottomNavigation(BuildContext context, {int currentIndex = 0}) {

  List<NavigationItem> bottomNavItems = constants.navItems;
  bottomNavItems.removeWhere((item)=> item.displayInBottomNavigation==false);
  return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      items: [...bottomNavItems.map((navItem) =>  BottomNavigationBarItem(label: context.l10n.navigation_item(navItem.label), icon: navItem.getIcon()))],
      selectedItemColor: Colors.white,
      onTap: (index) {

          for(NavigationItem navItem in constants.navItems){
            if(navItem.navigationIndex == index) {
              if(kDebugMode){
                log('$index ${navItem.view.toString()} ');
              }

              AppRouter.navigate(context,navItem.view,index);
             // Navigator.pushNamedAndRemoveUntil(context, navItem.route, (Route<dynamic> route) => false);
            }
          }

      });
}
