import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('uses dark mode and manrope', () {
      final theme = AppTheme.dark();
      expect(theme.brightness, Brightness.dark);
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Manrope');
      expect(theme.textTheme.titleLarge?.fontFamily, 'Manrope');
    });

    test('applies expected typography weights', () {
      final theme = AppTheme.dark();
      expect(theme.textTheme.bodyMedium?.fontWeight, FontWeight.w500);
      expect(theme.textTheme.titleMedium?.fontWeight, FontWeight.w600);
      expect(theme.textTheme.displayLarge?.fontWeight, FontWeight.w700);
    });

    test('registers all token extensions', () {
      final theme = AppTheme.dark();
      expect(theme.extension<AppColorTokens>(), isNotNull);
      expect(theme.extension<AppTypographyTokens>(), isNotNull);
      expect(theme.extension<AppSpacingTokens>(), isNotNull);
      expect(theme.extension<AppComponentTokens>(), isNotNull);
    });

    test('keeps palette grayscale', () {
      final colors = AppTheme.dark().extension<AppColorTokens>()!;
      expect(_isGrayscale(colors.background), isTrue);
      expect(_isGrayscale(colors.surface), isTrue);
      expect(_isGrayscale(colors.surfaceHigh), isTrue);
      expect(_isGrayscale(colors.surfaceLow), isTrue);
      expect(_isGrayscale(colors.border), isTrue);
      expect(_isGrayscale(colors.divider), isTrue);
      expect(_isGrayscale(colors.textPrimary), isTrue);
      expect(_isGrayscale(colors.textSecondary), isTrue);
      expect(_isGrayscale(colors.textTertiary), isTrue);
      expect(_isGrayscale(colors.disabled), isTrue);
      expect(_isGrayscale(colors.focus), isTrue);
      expect(_isGrayscale(colors.inverseSurface), isTrue);
      expect(_isGrayscale(colors.inverseText), isTrue);
    });
  });
}

bool _isGrayscale(Color color) {
  return color.r == color.g && color.g == color.b;
}
