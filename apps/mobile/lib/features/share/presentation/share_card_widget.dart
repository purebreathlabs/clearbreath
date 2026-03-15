import 'package:flutter/material.dart';
import '../../../core/theme/theme_extensions.dart';

class ShareCardWidget extends StatelessWidget {
  const ShareCardWidget({
    super.key,
    required this.streakDays,
    required this.minutesToday,
  });

  final int streakDays;
  final int minutesToday;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final safeStreak = streakDays.clamp(0, 9999);
    final safeMinutes = minutesToday.clamp(0, 999);
    final minutesLine = safeMinutes == 1
        ? '1 min today'
        : '$safeMinutes min today';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(components.cardRadius),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/branding/logo.png',
                  width: 36,
                  height: 36,
                  color: colors.textPrimary,
                  colorBlendMode: BlendMode.srcIn,
                  semanticLabel: 'ClearBreath',
                ),
                SizedBox(width: spacing.sm),
                Text(
                  'ClearBreath',
                  style: typography.titleMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '$safeStreak',
              textAlign: TextAlign.center,
              style: typography.displayLarge.copyWith(
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              'day streak',
              textAlign: TextAlign.center,
              style: typography.titleLarge.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              minutesLine,
              textAlign: TextAlign.center,
              style: typography.bodyMedium.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
