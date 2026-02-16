import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../widgets/onboarding_option_button.dart';
import '../widgets/onboarding_question.dart';

class KeepAwakeStep extends StatelessWidget {
  const KeepAwakeStep({
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
      title: 'Keep screen awake',
      subtitle: 'Prevent your phone from sleeping during sessions.',
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
