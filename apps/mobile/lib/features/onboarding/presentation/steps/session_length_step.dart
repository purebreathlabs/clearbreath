import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/widgets/selection_pill.dart';
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileWidth = (constraints.maxWidth - spacing.md) / 2.0;
          return Wrap(
            spacing: spacing.md,
            runSpacing: spacing.md,
            children: [
              SizedBox(
                width: tileWidth,
                child: SelectionPill(
                  label: '2 min',
                  selected: valueMinutes == 2,
                  onTap: () => onChanged(2),
                ),
              ),
              SizedBox(
                width: tileWidth,
                child: SelectionPill(
                  label: '5 min',
                  selected: valueMinutes == 5,
                  onTap: () => onChanged(5),
                ),
              ),
              SizedBox(
                width: tileWidth,
                child: SelectionPill(
                  label: '10 min',
                  selected: valueMinutes == 10,
                  onTap: () => onChanged(10),
                ),
              ),
              SizedBox(
                width: tileWidth,
                child: SelectionPill(
                  label: '20 min',
                  selected: valueMinutes == 20,
                  onTap: () => onChanged(20),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
