import 'package:flutter/material.dart';

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

    return OnboardingQuestion(
      title: 'Haptic guidance',
      subtitle: 'Gentle vibration at phase transitions.',
      child: Column(
        children: [
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
