import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../widgets/onboarding_option_button.dart';
import '../widgets/onboarding_question.dart';

class SessionLengthStep extends StatelessWidget {
  const SessionLengthStep({
    super.key,
    required this.valueMinutes,
    required this.onChanged,
  });

  final int valueMinutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;

    return OnboardingQuestion(
      title: 'Typical session length',
      subtitle: 'Pick what feels realistic for most days.',
      child: Column(
        children: [
          OnboardingOptionButton(
            label: '5 minutes',
            selected: valueMinutes == 5,
            onTap: () => onChanged(5),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: '10 minutes',
            selected: valueMinutes == 10,
            onTap: () => onChanged(10),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: '15 minutes',
            selected: valueMinutes == 15,
            onTap: () => onChanged(15),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: '30 minutes',
            selected: valueMinutes == 30,
            onTap: () => onChanged(30),
          ),
        ],
      ),
    );
  }
}
