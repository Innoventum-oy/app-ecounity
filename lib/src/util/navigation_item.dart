import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NavigationItem {
  int navigationIndex;
  String label;
  Icon? icon;
  FaIcon? faIcon;
  String route;
  String view;
  bool displayInBottomNavigation;
  bool displayInDashboard;
  bool subMenu=false;

  NavigationItem({required this.navigationIndex,required this.label, this.icon, this.faIcon,required this.route, required this.view,this.displayInBottomNavigation=true,this.displayInDashboard=true,this.subMenu=false});

  dynamic getIcon(){
    if(icon!=null){
      return icon;
    }
    else if(faIcon!=null){
      return faIcon;
    }
    else{
      return const Icon(Icons.error);
    }
  }

}