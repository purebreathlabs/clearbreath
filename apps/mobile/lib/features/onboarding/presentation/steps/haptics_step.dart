import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../widgets/onboarding_option_button.dart';
import '../widgets/onboarding_question.dart';

class HapticsStep extends StatelessWidget {
  const HapticsStep({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    return OnboardingQuestion(
      title: 'Haptic guidance',
      subtitle: 'Gentle vibration at phase transitions.',
      child: Column(
        children: [
          if (enabled) ...[
            Material(
              color: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(components.cardRadius),
                side: BorderSide(color: colors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Vibration.vibrate(duration: 40),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.lg,
                    vertical: spacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.vibration,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                      SizedBox(width: spacing.sm),
                      Text(
                        'Try it',
                        style: typography.labelLarge.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing.xl),
          ],
          OnboardingOptionButton(
            label: 'On',
            selected: enabled,
            onTap: () => onChanged(true),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Off',
            selected: !enabled,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}
