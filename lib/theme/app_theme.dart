import 'package:flutter/material.dart';

class AppColors {
  static const darkBackground = Color(0xFF0E1110);
  static const darkSurface = Color(0xFF171B17);
  static const darkElevated = Color(0xFF20261F);
  static const darkBorder = Color(0xFF2B342D);
  static const darkMuted = Color(0xFFA7AEA6);

  static const lightBackground = Color(0xFFF5F7F5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightElevated = Color(0xFFEEF4EF);
  static const lightBorder = Color(0xFFD8E2DA);
  static const lightMuted = Color(0xFF667067);

  static const secureGreen = Color(0xFF39D98A);
  static const deepGreen = Color(0xFF167D4C);
  static const infoBlue = Color(0xFF4AA3FF);
  static const danger = Color(0xFFEF5B5B);

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkSurface
          : lightSurface;

  static Color elevated(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkElevated
          : lightElevated;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBorder
          : lightBorder;

  static Color muted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkMuted : lightMuted;

  static Color mutedForBrightness(bool isDark) =>
      isDark ? darkMuted : lightMuted;
}

class AppTheme {
  const AppTheme._();

  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: AppColors.deepGreen,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.deepGreen,
    secondary: AppColors.infoBlue,
    surface: AppColors.lightBackground,
    error: AppColors.danger,
  );

  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: AppColors.secureGreen,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.secureGreen,
    secondary: AppColors.infoBlue,
    surface: AppColors.darkBackground,
    error: AppColors.danger,
  );

  static ThemeData light() => _build(_lightScheme);

  static ThemeData dark() => _build(_darkScheme);

  static ThemeData _build(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final elevated = isDark ? AppColors.darkElevated : AppColors.lightElevated;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return ThemeData(
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: isDark ? AppColors.darkMuted : AppColors.lightMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor:
            colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.14),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? colorScheme.primary
                : AppColors.mutedForBrightness(isDark),
            size: selected ? 25 : 23,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected
                ? colorScheme.primary
                : AppColors.mutedForBrightness(isDark),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
