import 'package:flutter/material.dart';
import 'package:ecounity/src/util/ecounity_design_tokens.dart';

final ThemeData appTheme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: EcoUnityColors.deepTeal,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD2F4F2),
    onPrimaryContainer: EcoUnityColors.deepTeal,
    secondary: EcoUnityColors.turquoise,
    onSecondary: EcoUnityColors.deepTeal,
    secondaryContainer: Color(0xFFC8F8F7),
    onSecondaryContainer: EcoUnityColors.deepTeal,
    tertiary: EcoUnityColors.leafGreen,
    onTertiary: EcoUnityColors.deepTeal,
    tertiaryContainer: Color(0xFFDDFACF),
    onTertiaryContainer: Color(0xFF143D05),
    error: EcoUnityColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: EcoUnityColors.surface,
    onSurface: EcoUnityColors.textPrimary,
    surfaceContainerHighest: EcoUnityColors.surfaceContainerHigh,
    onSurfaceVariant: EcoUnityColors.textSecondary,
    outline: EcoUnityColors.outline,
    outlineVariant: EcoUnityColors.outlineVariant,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: EcoUnityColors.deepTeal,
    onInverseSurface: Colors.white,
    inversePrimary: EcoUnityColors.turquoise,
  ),
  useMaterial3: true,
  scaffoldBackgroundColor: EcoUnityColors.surface,
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    backgroundColor: EcoUnityColors.surface,
    foregroundColor: EcoUnityColors.deepTeal,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: EcoUnityColors.deepTeal,
    unselectedItemColor: EcoUnityColors.textSecondary,
    type: BottomNavigationBarType.fixed,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: EcoUnityColors.deepTeal,
      foregroundColor: Colors.white,
      minimumSize: const Size(44, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: EcoUnityColors.deepTeal,
      minimumSize: const Size(44, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: EcoUnityColors.outlineVariant),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: EcoUnityColors.surfaceContainer,
    selectedColor: const Color(0xFFC8F8F7),
    labelStyle: const TextStyle(color: EcoUnityColors.deepTeal),
    secondaryLabelStyle: const TextStyle(color: EcoUnityColors.deepTeal),
    side: const BorderSide(color: EcoUnityColors.outlineVariant),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: EcoUnityColors.leafGreen,
    linearTrackColor: EcoUnityColors.surfaceContainerHigh,
    circularTrackColor: EcoUnityColors.surfaceContainerHigh,
  ),
  tabBarTheme: TabBarThemeData(
    labelColor: EcoUnityColors.deepTeal,
    unselectedLabelColor: EcoUnityColors.textSecondary,
    labelPadding: const EdgeInsets.symmetric(horizontal: 18),
    labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    unselectedLabelStyle: const TextStyle(fontSize: 16),
    indicatorSize: TabBarIndicatorSize.label,
    indicator: _PaddedTabIndicator(
      color: EcoUnityColors.warmOrange,
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
  Color get secondaryBackgroundColor => EcoUnityColors.surfaceContainer;

  // Custom listTileThemes for the stages before, during, after, any:
  ListTileThemeData get listTileThemeBefore => listTileTheme.copyWith(
    tileColor: EcoUnityColors.deepTeal,
    selectedTileColor: EcoUnityColors.turquoise,
    textColor: Colors.white,
  );
  ListTileThemeData get listTileThemeDuring => listTileTheme.copyWith(
    tileColor: EcoUnityColors.surfaceContainer,
    selectedTileColor: EcoUnityColors.turquoise,
    textColor: EcoUnityColors.textPrimary,
  );
  ListTileThemeData get listTileThemeAfter => listTileTheme.copyWith(
    tileColor: EcoUnityColors.warmOrange,
    selectedTileColor: EcoUnityColors.leafGreen,
    textColor: EcoUnityColors.textPrimary,
  );
}
