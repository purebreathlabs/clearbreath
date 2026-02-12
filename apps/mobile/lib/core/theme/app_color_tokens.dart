import 'package:flutter/material.dart';

@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.surfaceLow,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.disabled,
    required this.focus,
    required this.inverseSurface,
    required this.inverseText,
  });

  factory AppColorTokens.dark() {
    return const AppColorTokens(
      background: Color(0xFF000000),
      surface: Color(0xFF0D0D0D),
      surfaceHigh: Color(0xFF151515),
      surfaceLow: Color(0xFF080808),
      border: Color(0xFF2B2B2B),
      divider: Color(0xFF1F1F1F),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFB5B5B5),
      textTertiary: Color(0xFF8A8A8A),
      disabled: Color(0xFF5C5C5C),
      focus: Color(0xFFE6E6E6),
      inverseSurface: Color(0xFFFFFFFF),
      inverseText: Color(0xFF000000),
    );
  }

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color surfaceLow;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color disabled;
  final Color focus;
  final Color inverseSurface;
  final Color inverseText;

  @override
  AppColorTokens copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? surfaceLow,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? disabled,
    Color? focus,
    Color? inverseSurface,
    Color? inverseText,
  }) {
    return AppColorTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      surfaceLow: surfaceLow ?? this.surfaceLow,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      disabled: disabled ?? this.disabled,
      focus: focus ?? this.focus,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      inverseText: inverseText ?? this.inverseText,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) {
      return this;
    }

    return AppColorTokens(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t) ?? surfaceHigh,
      surfaceLow: Color.lerp(surfaceLow, other.surfaceLow, t) ?? surfaceLow,
      border: Color.lerp(border, other.border, t) ?? border,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textTertiary:
          Color.lerp(textTertiary, other.textTertiary, t) ?? textTertiary,
      disabled: Color.lerp(disabled, other.disabled, t) ?? disabled,
      focus: Color.lerp(focus, other.focus, t) ?? focus,
      inverseSurface:
          Color.lerp(inverseSurface, other.inverseSurface, t) ?? inverseSurface,
      inverseText: Color.lerp(inverseText, other.inverseText, t) ?? inverseText,
    );
  }
}
