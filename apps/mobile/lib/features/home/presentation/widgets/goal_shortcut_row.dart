import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../onboarding/domain/onboarding_answers.dart';

class GoalShortcutRow extends StatelessWidget {
  const GoalShortcutRow({
    super.key,
    required this.selectedGoal,
    required this.onSelect,
  });

  final PrimaryGoal selectedGoal;
  final ValueChanged<PrimaryGoal> onSelect;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    Widget chip({required PrimaryGoal goal, required String label}) {
      final selected = goal == selectedGoal;
      final shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(components.buttonRadius),
        side: BorderSide(color: selected ? colors.focus : colors.border),
      );

      return Padding(
        padding: EdgeInsets.only(right: spacing.sm),
        child: Material(
          color: selected ? colors.surfaceHigh : colors.surface,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onSelect(goal),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.sm,
              ),
              child: Text(
                label,
                style: typography.labelLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: Row(
        children: [
          chip(goal: PrimaryGoal.calm, label: 'Calm'),
          chip(goal: PrimaryGoal.sleep, label: 'Sleep'),
          chip(goal: PrimaryGoal.focus, label: 'Focus'),
          chip(goal: PrimaryGoal.energy, label: 'Energy'),
          chip(goal: PrimaryGoal.hrv, label: 'HRV'),
          chip(goal: PrimaryGoal.spiritual, label: 'Spiritual'),
        ],
      ),
    );
  }
}
