import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../widgets/onboarding_question.dart';

class ReminderTimeStep extends StatelessWidget {
  const ReminderTimeStep({
    super.key,
    required this.timeMinutes,
    required this.onPickTime,
  });

  final int timeMinutes;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    final timeOfDay = TimeOfDay(
      hour: timeMinutes ~/ 60,
      minute: timeMinutes % 60,
    );

    return OnboardingQuestion(
      title: 'Daily reminder time',
      subtitle: 'You can change this anytime in settings.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton(
            onPressed: onPickTime,
            child: Text(timeOfDay.format(context)),
          ),
          SizedBox(height: spacing.sm),
          Text(
            'We’ll schedule a gentle reminder at this time.',
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
