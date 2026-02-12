import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_color_tokens.dart';

@immutable
class AppComponentTokens extends ThemeExtension<AppComponentTokens> {
  const AppComponentTokens({
    required this.buttonHeightMedium,
    required this.buttonHeightLarge,
    required this.buttonHorizontalPadding,
    required this.buttonRadius,
    required this.buttonPrimaryBackground,
    required this.buttonPrimaryForeground,
    required this.buttonDisabledBackground,
    required this.buttonDisabledForeground,
    required this.buttonSecondaryBorder,
    required this.buttonSecondaryForeground,
    required this.cardRadius,
    required this.cardElevation,
    required this.cardPadding,
    required this.cardBackground,
    required this.cardBorder,
    required this.inputRadius,
    required this.inputHorizontalPadding,
    required this.inputVerticalPadding,
    required this.inputBackground,
    required this.inputDisabledBackground,
    required this.inputBorder,
    required this.inputFocusedBorder,
    required this.inputText,
    required this.inputHint,
  });

  factory AppComponentTokens.dark(AppColorTokens colors) {
    return AppComponentTokens(
      buttonHeightMedium: 48,
      buttonHeightLarge: 56,
      buttonHorizontalPadding: 20,
      buttonRadius: 14,
      buttonPrimaryBackground: colors.textPrimary,
      buttonPrimaryForeground: colors.background,
      buttonDisabledBackground: colors.disabled,
      buttonDisabledForeground: colors.surface,
      buttonSecondaryBorder: colors.border,
      buttonSecondaryForeground: colors.textPrimary,
      cardRadius: 18,
      cardElevation: 0,
      cardPadding: 20,
      cardBackground: colors.surface,
      cardBorder: colors.border,
      inputRadius: 14,
      inputHorizontalPadding: 16,
      inputVerticalPadding: 14,
      inputBackground: colors.surfaceLow,
      inputDisabledBackground: colors.surface,
      inputBorder: colors.border,
      inputFocusedBorder: colors.focus,
      inputText: colors.textPrimary,
      inputHint: colors.textTertiary,
    );
  }

  final double buttonHeightMedium;
  final double buttonHeightLarge;
  final double buttonHorizontalPadding;
  final double buttonRadius;
  final Color buttonPrimaryBackground;
  final Color buttonPrimaryForeground;
  final Color buttonDisabledBackground;
  final Color buttonDisabledForeground;
  final Color buttonSecondaryBorder;
  final Color buttonSecondaryForeground;
  final double cardRadius;
  final double cardElevation;
  final double cardPadding;
  final Color cardBackground;
  final Color cardBorder;
  final double inputRadius;
  final double inputHorizontalPadding;
  final double inputVerticalPadding;
  final Color inputBackground;
  final Color inputDisabledBackground;
  final Color inputBorder;
  final Color inputFocusedBorder;
  final Color inputText;
  final Color inputHint;

  @override
  AppComponentTokens copyWith({
    double? buttonHeightMedium,
    double? buttonHeightLarge,
    double? buttonHorizontalPadding,
    double? buttonRadius,
    Color? buttonPrimaryBackground,
    Color? buttonPrimaryForeground,
    Color? buttonDisabledBackground,
    Color? buttonDisabledForeground,
    Color? buttonSecondaryBorder,
    Color? buttonSecondaryForeground,
    double? cardRadius,
    double? cardElevation,
    double? cardPadding,
    Color? cardBackground,
    Color? cardBorder,
    double? inputRadius,
    double? inputHorizontalPadding,
    double? inputVerticalPadding,
    Color? inputBackground,
    Color? inputDisabledBackground,
    Color? inputBorder,
    Color? inputFocusedBorder,
    Color? inputText,
    Color? inputHint,
  }) {
    return AppComponentTokens(
      buttonHeightMedium: buttonHeightMedium ?? this.buttonHeightMedium,
      buttonHeightLarge: buttonHeightLarge ?? this.buttonHeightLarge,
      buttonHorizontalPadding:
          buttonHorizontalPadding ?? this.buttonHorizontalPadding,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      buttonPrimaryBackground:
          buttonPrimaryBackground ?? this.buttonPrimaryBackground,
      buttonPrimaryForeground:
          buttonPrimaryForeground ?? this.buttonPrimaryForeground,
      buttonDisabledBackground:
          buttonDisabledBackground ?? this.buttonDisabledBackground,
      buttonDisabledForeground:
          buttonDisabledForeground ?? this.buttonDisabledForeground,
      buttonSecondaryBorder: buttonSecondaryBorder ?? this.buttonSecondaryBorder,
      buttonSecondaryForeground:
          buttonSecondaryForeground ?? this.buttonSecondaryForeground,
      cardRadius: cardRadius ?? this.cardRadius,
      cardElevation: cardElevation ?? this.cardElevation,
      cardPadding: cardPadding ?? this.cardPadding,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      inputRadius: inputRadius ?? this.inputRadius,
      inputHorizontalPadding:
          inputHorizontalPadding ?? this.inputHorizontalPadding,
      inputVerticalPadding: inputVerticalPadding ?? this.inputVerticalPadding,
      inputBackground: inputBackground ?? this.inputBackground,
      inputDisabledBackground:
          inputDisabledBackground ?? this.inputDisabledBackground,
      inputBorder: inputBorder ?? this.inputBorder,
      inputFocusedBorder: inputFocusedBorder ?? this.inputFocusedBorder,
      inputText: inputText ?? this.inputText,
      inputHint: inputHint ?? this.inputHint,
    );
  }

  @override
  AppComponentTokens lerp(ThemeExtension<AppComponentTokens>? other, double t) {
    if (other is! AppComponentTokens) {
      return this;
    }

    return AppComponentTokens(
      buttonHeightMedium:
          lerpDouble(buttonHeightMedium, other.buttonHeightMedium, t) ??
              buttonHeightMedium,
      buttonHeightLarge:
          lerpDouble(buttonHeightLarge, other.buttonHeightLarge, t) ??
              buttonHeightLarge,
      buttonHorizontalPadding:
          lerpDouble(buttonHorizontalPadding, other.buttonHorizontalPadding, t) ??
              buttonHorizontalPadding,
      buttonRadius: lerpDouble(buttonRadius, other.buttonRadius, t) ?? buttonRadius,
      buttonPrimaryBackground:
          Color.lerp(buttonPrimaryBackground, other.buttonPrimaryBackground, t) ??
              buttonPrimaryBackground,
      buttonPrimaryForeground:
          Color.lerp(buttonPrimaryForeground, other.buttonPrimaryForeground, t) ??
              buttonPrimaryForeground,
      buttonDisabledBackground: Color.lerp(
            buttonDisabledBackground,
            other.buttonDisabledBackground,
            t,
          ) ??
          buttonDisabledBackground,
      buttonDisabledForeground: Color.lerp(
            buttonDisabledForeground,
            other.buttonDisabledForeground,
            t,
          ) ??
          buttonDisabledForeground,
      buttonSecondaryBorder:
          Color.lerp(buttonSecondaryBorder, other.buttonSecondaryBorder, t) ??
              buttonSecondaryBorder,
      buttonSecondaryForeground: Color.lerp(
            buttonSecondaryForeground,
            other.buttonSecondaryForeground,
            t,
          ) ??
          buttonSecondaryForeground,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t) ?? cardRadius,
      cardElevation: lerpDouble(cardElevation, other.cardElevation, t) ?? cardElevation,
      cardPadding: lerpDouble(cardPadding, other.cardPadding, t) ?? cardPadding,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t) ?? cardBackground,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t) ?? cardBorder,
      inputRadius: lerpDouble(inputRadius, other.inputRadius, t) ?? inputRadius,
      inputHorizontalPadding:
          lerpDouble(inputHorizontalPadding, other.inputHorizontalPadding, t) ??
              inputHorizontalPadding,
      inputVerticalPadding:
          lerpDouble(inputVerticalPadding, other.inputVerticalPadding, t) ??
              inputVerticalPadding,
      inputBackground:
          Color.lerp(inputBackground, other.inputBackground, t) ?? inputBackground,
      inputDisabledBackground: Color.lerp(
            inputDisabledBackground,
            other.inputDisabledBackground,
            t,
          ) ??
          inputDisabledBackground,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t) ?? inputBorder,
      inputFocusedBorder:
          Color.lerp(inputFocusedBorder, other.inputFocusedBorder, t) ??
              inputFocusedBorder,
      inputText: Color.lerp(inputText, other.inputText, t) ?? inputText,
      inputHint: Color.lerp(inputHint, other.inputHint, t) ?? inputHint,
    );
  }
}
