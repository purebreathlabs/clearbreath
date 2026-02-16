import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/onboarding_answers.dart';
import '../widgets/onboarding_option_button.dart';
import '../widgets/onboarding_question.dart';

class ExperienceStep extends StatelessWidget {
  const ExperienceStep({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ExperienceLevel value;
  final ValueChanged<ExperienceLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;

    return OnboardingQuestion(
      title: 'Your experience level',
      subtitle: 'We’ll tailor defaults to match your pace.',
      child: Column(
        children: [
          OnboardingOptionButton(
            label: 'Beginner',
            selected: value == ExperienceLevel.beginner,
            onTap: () => onChanged(ExperienceLevel.beginner),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Intermediate',
            selected: value == ExperienceLevel.intermediate,
            onTap: () => onChanged(ExperienceLevel.intermediate),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Advanced',
            selected: value == ExperienceLevel.advanced,
            onTap: () => onChanged(ExperienceLevel.advanced),
          ),
        ],
      ),
    );
  }
}
