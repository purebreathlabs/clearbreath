import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/onboarding_answers.dart';
import '../widgets/onboarding_option_button.dart';
import '../widgets/onboarding_question.dart';

class PrimaryGoalStep extends StatelessWidget {
  const PrimaryGoalStep({
    super.key,
    required this.values,
    required this.onToggle,
  });

  final Set<PrimaryGoal> values;
  final ValueChanged<PrimaryGoal> onToggle;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;

    return OnboardingQuestion(
      title: 'Your goals',
      subtitle: 'Select all that apply.',
      child: Column(
        children: [
          OnboardingOptionButton(
            label: 'Calm',
            selected: values.contains(PrimaryGoal.calm),
            onTap: () => onToggle(PrimaryGoal.calm),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Sleep',
            selected: values.contains(PrimaryGoal.sleep),
            onTap: () => onToggle(PrimaryGoal.sleep),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Focus',
            selected: values.contains(PrimaryGoal.focus),
            onTap: () => onToggle(PrimaryGoal.focus),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Energy',
            selected: values.contains(PrimaryGoal.energy),
            onTap: () => onToggle(PrimaryGoal.energy),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'HRV',
            selected: values.contains(PrimaryGoal.hrv),
            onTap: () => onToggle(PrimaryGoal.hrv),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Spiritual',
            selected: values.contains(PrimaryGoal.spiritual),
            onTap: () => onToggle(PrimaryGoal.spiritual),
          ),
        ],
      ),
    );
  }
}
