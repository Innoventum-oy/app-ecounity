import 'package:flutter/material.dart';
import 'package:ecounity/src/util/utils.dart';

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: HexColor.fromHex('#4bc0ae'),
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
  scaffoldBackgroundColor: HexColor.fromHex('#2a2a2a'),
  brightness: Brightness.dark,
  tabBarTheme: TabBarThemeData(
    labelColor: Colors.white,
    unselectedLabelColor: HexColor.fromHex('#FFFFFF').withValues(alpha: 0.7),
    labelPadding: const EdgeInsets.symmetric(horizontal: 18),
    labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    unselectedLabelStyle: const TextStyle(fontSize: 16),
    indicatorSize: TabBarIndicatorSize.label,
    indicator: _PaddedTabIndicator(
      color: HexColor.fromHex('#f36c3d'),
      horizontalPadding: 12,
      verticalInset: 7,
      radius: 6,
    ),
  ),
  listTileTheme: ListTileThemeData(
    // rounded corners
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
);

class _PaddedTabIndicator extends Decoration {
  const _PaddedTabIndicator({
    required this.color,
    required this.horizontalPadding,
    required this.verticalInset,
    required this.radius,
  });

  final Color color;
  final double horizontalPadding;
  final double verticalInset;
  final double radius;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _PaddedTabIndicatorPainter(this);
  }
}

class _PaddedTabIndicatorPainter extends BoxPainter {
  const _PaddedTabIndicatorPainter(this.decoration);

  final _PaddedTabIndicator decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Size? size = configuration.size;
    if (size == null) {
      return;
    }

    final Rect rect = Rect.fromLTRB(
      offset.dx - decoration.horizontalPadding,
      offset.dy + decoration.verticalInset,
      offset.dx + size.width + decoration.horizontalPadding,
      offset.dy + size.height - decoration.verticalInset,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(decoration.radius)),
      Paint()..color = decoration.color,
    );
  }
}

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
