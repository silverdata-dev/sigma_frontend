import 'package:flutter/material.dart';

// ── Paleta Sigma ────────────────────────────────────────────────────────────
class SigmaColors {
  static const navy        = Color(0xFF0C1F4A);
  static const navyLight   = Color(0xFF14306A);
  static const blue        = Color(0xFF1B8FCC);
  static const teal        = Color(0xFF19B4B4);
  static const green       = Color(0xFF27AE83);
  static const amber       = Color(0xFFE8A030);
  static const red         = Color(0xFFE85A5A);
  static const purple      = Color(0xFF7B5EA7);
  static const surface     = Color(0xFFF0F4F8);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A2340);
  static const textSub     = Color(0xFF8899AA);
  static const snowWhite   = Color(0xFFFAFCFF);

  // Color por materia/índice — mismo orden que en las pantallas
  static const List<Color> subject = [blue, teal, green, amber, red, purple];

  static Color subjectAt(int i) => subject[i % subject.length];
}

// ── ThemeData ────────────────────────────────────────────────────────────────
ThemeData buildSigmaTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary:          SigmaColors.blue,
    onPrimary:        SigmaColors.snowWhite,
    primaryContainer: Color(0xFFD6EEFF),
    onPrimaryContainer: SigmaColors.navy,
    secondary:        SigmaColors.teal,
    onSecondary:      SigmaColors.snowWhite,
    secondaryContainer: Color(0xFFCCF5F5),
    onSecondaryContainer: SigmaColors.navy,
    tertiary:         SigmaColors.amber,
    onTertiary:       SigmaColors.snowWhite,
    tertiaryContainer: Color(0xFFFFE9C0),
    onTertiaryContainer: SigmaColors.navy,
    error:            SigmaColors.red,
    onError:          SigmaColors.snowWhite,
    errorContainer:   Color(0xFFFFDADA),
    onErrorContainer: SigmaColors.navy,
    surface:          SigmaColors.surface,
    onSurface:        SigmaColors.textPrimary,
    surfaceContainerHighest: Color(0xFFE2E8F0),
    outline:          Color(0xFFCBD5E0),
    outlineVariant:   Color(0xFFE2E8F0),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: SigmaColors.surface,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: SigmaColors.navy,
      foregroundColor: SigmaColors.snowWhite,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: SigmaColors.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: SigmaColors.surfaceCard,
      indicatorColor: SigmaColors.blue.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final active = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? SigmaColors.blue : SigmaColors.textSub,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final active = states.contains(WidgetState.selected);
        return IconThemeData(
          color: active ? SigmaColors.blue : SigmaColors.textSub,
          size: 22,
        );
      }),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: SigmaColors.navy,
      selectedIconTheme: IconThemeData(color: SigmaColors.snowWhite, size: 20),
      unselectedIconTheme: IconThemeData(color: Color(0xFF8899BB), size: 20),
      selectedLabelTextStyle: TextStyle(color: SigmaColors.snowWhite, fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: TextStyle(color: Color(0xFF8899BB), fontSize: 13),
      indicatorColor: Color(0xFF1B8FCC),
    ),
  );
}
