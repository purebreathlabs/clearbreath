import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/onboarding_answers.dart';
import '../widgets/onboarding_option_button.dart';
import '../widgets/onboarding_question.dart';

class PracticeWindowStep extends StatelessWidget {
  const PracticeWindowStep({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final PracticeWindow value;
  final ValueChanged<PracticeWindow> onChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;

    return OnboardingQuestion(
      title: 'When do you usually practice?',
      subtitle: 'This helps us tune your recommendation timing.',
      child: Column(
        children: [
          OnboardingOptionButton(
            label: 'Morning',
            selected: value == PracticeWindow.morning,
            onTap: () => onChanged(PracticeWindow.morning),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Afternoon',
            selected: value == PracticeWindow.afternoon,
            onTap: () => onChanged(PracticeWindow.afternoon),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Evening',
            selected: value == PracticeWindow.evening,
            onTap: () => onChanged(PracticeWindow.evening),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: 'Varies',
            selected: value == PracticeWindow.varies,
            onTap: () => onChanged(PracticeWindow.varies),
          ),
        ],
      ),
    );
  }
}
