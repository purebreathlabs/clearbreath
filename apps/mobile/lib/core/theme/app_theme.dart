import 'package:flutter/material.dart';

import 'theme_extensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final colors = AppColorTokens.dark();
    final textTheme = AppTypographyTokens.buildTextTheme();
    final typography = AppTypographyTokens.fromTextTheme(textTheme);
    final spacing = AppSpacingTokens.base();
    final components = AppComponentTokens.dark(colors);

    final colorScheme = const ColorScheme.dark().copyWith(
      primary: colors.textPrimary,
      onPrimary: colors.background,
      secondary: colors.textSecondary,
      onSecondary: colors.background,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      outline: colors.border,
      outlineVariant: colors.divider,
      inverseSurface: colors.inverseSurface,
      onInverseSurface: colors.inverseText,
      surfaceTint: Colors.transparent,
      scrim: Colors.black,
      shadow: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      dividerColor: colors.divider,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        titleTextStyle: typography.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(
            Size.fromHeight(components.buttonHeightMedium),
          ),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(horizontal: components.buttonHorizontalPadding),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(components.buttonRadius),
            ),
          ),
          textStyle: WidgetStateProperty.all(typography.labelLarge),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return components.buttonDisabledBackground;
            }
            return components.buttonPrimaryBackground;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return components.buttonDisabledForeground;
            }
            return components.buttonPrimaryForeground;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(
            Size.fromHeight(components.buttonHeightMedium),
          ),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(horizontal: components.buttonHorizontalPadding),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(components.buttonRadius),
            ),
          ),
          textStyle: WidgetStateProperty.all(typography.labelLarge),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(color: components.buttonDisabledBackground);
            }
            return BorderSide(color: components.buttonSecondaryBorder);
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return components.buttonDisabledBackground;
            }
            return components.buttonSecondaryForeground;
          }),
        ),
      ),
      cardTheme: CardThemeData(
        color: components.cardBackground,
        elevation: components.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(components.cardRadius),
          side: BorderSide(color: components.cardBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: components.inputBackground,
        hintStyle: typography.bodyMedium.copyWith(color: components.inputHint),
        labelStyle: typography.labelMedium.copyWith(color: colors.textSecondary),
        contentPadding: EdgeInsets.symmetric(
          horizontal: components.inputHorizontalPadding,
          vertical: components.inputVerticalPadding,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(components.inputRadius),
          borderSide: BorderSide(color: components.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(components.inputRadius),
          borderSide: BorderSide(color: components.inputFocusedBorder, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(components.inputRadius),
          borderSide: BorderSide(color: components.inputBorder),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        colors,
        typography,
        spacing,
        components,
      ],
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.xs,
        ),
      ),
    );
  }
}
