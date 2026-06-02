import 'package:flutter/material.dart';
import 'package:ecounity/src/util/utils.dart';

final ThemeData appTheme = ThemeData(

  colorScheme: ColorScheme.fromSeed(seedColor: HexColor.fromHex('#4bc0ae'),brightness: Brightness.dark),
  useMaterial3: true,
  scaffoldBackgroundColor: HexColor.fromHex('#2a2a2a'),
  brightness: Brightness.dark,
  tabBarTheme: TabBarThemeData(
    labelColor: Colors.white,
    unselectedLabelColor: HexColor.fromHex('#FFFFFF').withOpacity(0.7),
    labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    unselectedLabelStyle: const TextStyle(fontSize: 16),
    indicator: BoxDecoration(
      color: HexColor.fromHex('#f36c3d'),
      borderRadius: BorderRadius.circular(5),

    ),
  ),
  listTileTheme: ListTileThemeData(
    // rounded corners
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),

  ),
);

extension CustomStyles on ThemeData {

  // Lighter background for login/auth screens (for black text visibility)
  Color get secondaryBackgroundColor => HexColor.fromHex('#fcc021');

  // Custom listTileThemes for the stages before, during, after, any:
  ListTileThemeData get listTileThemeBefore => listTileTheme.copyWith(
    tileColor: HexColor.fromHex('#4bc0ae'),
    selectedTileColor: HexColor.fromHex('#26B1FA'),

    textColor: HexColor.fromHex('#FFFFFF'),
  );
  ListTileThemeData get listTileThemeDuring => listTileTheme.copyWith(
    tileColor: HexColor.fromHex('#fcc021'),
    selectedTileColor: HexColor.fromHex('#26B1FA'),

    textColor: HexColor.fromHex('#333333'),
  );
  ListTileThemeData get listTileThemeAfter => listTileTheme.copyWith(
    tileColor: HexColor.fromHex('#f36c3d'),
    selectedTileColor: HexColor.fromHex('#26B1FA'),

    textColor: HexColor.fromHex('#FFFFFF'),
  );
}