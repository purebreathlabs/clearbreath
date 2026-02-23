import 'package:flutter/material.dart';

import '../../../core/theme/theme_extensions.dart';

class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Design System')),
      body: ListView(
        padding: EdgeInsets.all(spacing.lg),
        children: [
          Text('Typography', style: typography.titleLarge),
          SizedBox(height: spacing.md),
          _TypographyRow(
            label: 'Display Large',
            style: typography.displayLarge,
          ),
          _TypographyRow(
            label: 'Display Medium',
            style: typography.displayMedium,
          ),
          _TypographyRow(
            label: 'Headline Large',
            style: typography.headlineLarge,
          ),
          _TypographyRow(label: 'Title Large', style: typography.titleLarge),
          _TypographyRow(label: 'Title Medium', style: typography.titleMedium),
          _TypographyRow(label: 'Body Large', style: typography.bodyLarge),
          _TypographyRow(label: 'Body Medium', style: typography.bodyMedium),
          _TypographyRow(label: 'Label Large', style: typography.labelLarge),
          _TypographyRow(label: 'Label Medium', style: typography.labelMedium),
          SizedBox(height: spacing.xxl),
          Text('Color Palette', style: typography.titleLarge),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.md,
            runSpacing: spacing.md,
            children: [
              _ColorSwatch(name: 'Background', color: colors.background),
              _ColorSwatch(name: 'Surface', color: colors.surface),
              _ColorSwatch(name: 'Surface High', color: colors.surfaceHigh),
              _ColorSwatch(name: 'Surface Low', color: colors.surfaceLow),
              _ColorSwatch(name: 'Border', color: colors.border),
              _ColorSwatch(name: 'Divider', color: colors.divider),
              _ColorSwatch(name: 'Text Primary', color: colors.textPrimary),
              _ColorSwatch(name: 'Text Secondary', color: colors.textSecondary),
              _ColorSwatch(name: 'Text Tertiary', color: colors.textTertiary),
              _ColorSwatch(name: 'Disabled', color: colors.disabled),
              _ColorSwatch(name: 'Focus', color: colors.focus),
              _ColorSwatch(name: 'Destructive', color: colors.destructive),
            ],
          ),
          SizedBox(height: spacing.xxl),
          Text('Components', style: typography.titleLarge),
          SizedBox(height: spacing.md),
          FilledButton(onPressed: () {}, child: const Text('Primary Button')),
          SizedBox(height: spacing.sm),
          const FilledButton(onPressed: null, child: Text('Disabled Button')),
          SizedBox(height: spacing.sm),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Secondary Button'),
          ),
          SizedBox(height: spacing.lg),
          Card(
            child: Padding(
              padding: EdgeInsets.all(components.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card Title', style: typography.titleMedium),
                  SizedBox(height: spacing.sm),
                  Text(
                    'This is a sample card using theme tokens.',
                    style: typography.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: spacing.lg),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Input',
              hintText: 'Write a breath note',
            ),
          ),
          SizedBox(height: spacing.sm),
          const TextField(
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Disabled Input',
              hintText: 'Disabled state',
            ),
          ),
        ],
      ),
    );
  }
}

class _TypographyRow extends StatelessWidget {
  const _TypographyRow({required this.label, required this.style});

  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          SizedBox(height: spacing.xs),
          Text(
            'Breathe with intention 123',
            style: style.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final textColor = color.computeLuminance() > 0.4
        ? Colors.black
        : Colors.white;

    return Container(
      width: 150,
      padding: EdgeInsets.all(spacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              _toHex(color),
              style: typography.labelMedium.copyWith(color: textColor),
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(name, style: typography.labelLarge),
        ],
      ),
    );
  }

  String _toHex(Color color) {
    final value = color
        .toARGB32()
        .toRadixString(16)
        .padLeft(8, '0')
        .toUpperCase();
    return '#${value.substring(2)}';
  }
}
