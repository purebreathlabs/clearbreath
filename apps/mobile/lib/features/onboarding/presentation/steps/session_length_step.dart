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
            label: '2 minutes',
            subtitle: 'A quick reset between tasks',
            selected: valueMinutes == 2,
            onTap: () => onChanged(2),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: '5 minutes',
            subtitle: 'Enough to shift your state',
            selected: valueMinutes == 5,
            onTap: () => onChanged(5),
            recommended: true,
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: '10 minutes',
            subtitle: 'A solid daily practice',
            selected: valueMinutes == 10,
            onTap: () => onChanged(10),
          ),
          SizedBox(height: spacing.md),
          OnboardingOptionButton(
            label: '20 minutes',
            subtitle: 'Deep session for experienced practitioners',
            selected: valueMinutes == 20,
            onTap: () => onChanged(20),
          ),
        ],
      ),
    );
  }
}
