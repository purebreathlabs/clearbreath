import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/onboarding_answers.dart';
import '../widgets/onboarding_option_button.dart';
import '../widgets/onboarding_question.dart';

class PrimaryGoalStep extends StatelessWidget {
  const PrimaryGoalStep({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final PrimaryGoal value;
  final ValueChanged<PrimaryGoal> onChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;

    return OnboardingQuestion(
      title: 'Your primary goal',
      subtitle: 'We’ll suggest a daily practice that fits your intent.',
      child: Column(
        children: [
          OnboardingOptionButton(
            label: 'Calm',
            selected: value == PrimaryGoal.calm,
            onTap: () => onChanged(PrimaryGoal.calm),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Sleep',
            selected: value == PrimaryGoal.sleep,
            onTap: () => onChanged(PrimaryGoal.sleep),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Focus',
            selected: value == PrimaryGoal.focus,
            onTap: () => onChanged(PrimaryGoal.focus),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Energy',
            selected: value == PrimaryGoal.energy,
            onTap: () => onChanged(PrimaryGoal.energy),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'HRV',
            selected: value == PrimaryGoal.hrv,
            onTap: () => onChanged(PrimaryGoal.hrv),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Spiritual',
            selected: value == PrimaryGoal.spiritual,
            onTap: () => onChanged(PrimaryGoal.spiritual),
          ),
        ],
      ),
    );
  }
}
