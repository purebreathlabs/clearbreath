import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../widgets/onboarding_question.dart';

class DisplayNameStep extends StatefulWidget {
  const DisplayNameStep({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<DisplayNameStep> createState() => _DisplayNameStepState();
}

class _DisplayNameStepState extends State<DisplayNameStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(DisplayNameStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value || _controller.text == widget.value) {
      return;
    }

    _controller.value = _controller.value.copyWith(
      text: widget.value,
      selection: TextSelection.collapsed(offset: widget.value.length),
      composing: TextRange.empty,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    return OnboardingQuestion(
      title: 'What should we call you?',
      subtitle: 'Optional, but it helps personalize your practice.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Name (optional)',
              hintText: 'Your name',
            ),
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            maxLength: 20,
            onChanged: widget.onChanged,
          ),
          SizedBox(height: spacing.sm),
          Text(
            'This appears on your profile and reminders.',
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
