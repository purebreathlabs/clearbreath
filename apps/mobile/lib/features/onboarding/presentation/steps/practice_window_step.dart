import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/onboarding_answers.dart';
import '../widgets/onboarding_option_button.dart';
import '../widgets/onboarding_question.dart';

class PracticeWindowStep extends StatelessWidget {
  const PracticeWindowStep({
    super.key,
    required this.values,
    required this.onToggle,
  });

  final Set<PracticeWindow> values;
  final ValueChanged<PracticeWindow> onToggle;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;

    return OnboardingQuestion(
      title: 'When do you usually practice?',
      subtitle:
          'Select all that apply. Choose Varies if it changes day to day.',
      child: Column(
        children: [
          OnboardingOptionButton(
            label: 'Morning',
            subtitle: 'Start your day centered and clear',
            selected: values.contains(PracticeWindow.morning),
            onTap: () => onToggle(PracticeWindow.morning),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Afternoon',
            subtitle: 'A mid-day reset to recharge',
            selected: values.contains(PracticeWindow.afternoon),
            onTap: () => onToggle(PracticeWindow.afternoon),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Evening',
            subtitle: 'Wind down and prepare for rest',
            selected: values.contains(PracticeWindow.evening),
            onTap: () => onToggle(PracticeWindow.evening),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Varies',
            subtitle: 'No fixed schedule, practice when it fits',
            selected: values.contains(PracticeWindow.varies),
            onTap: () => onToggle(PracticeWindow.varies),
          ),
        ],
      ),
    );
  }
}
