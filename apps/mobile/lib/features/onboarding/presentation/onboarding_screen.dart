import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
import '../domain/onboarding_gate.dart';
import '../domain/onboarding_controller.dart';
import '../domain/onboarding_answers.dart';
import 'steps/experience_step.dart';
import 'steps/haptics_step.dart';
import 'steps/keep_awake_step.dart';
import 'steps/practice_window_step.dart';
import 'steps/primary_goal_step.dart';
import 'steps/reminder_time_step.dart';
import 'steps/session_length_step.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.from});

  final String from;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;

    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    Widget step(Widget child) {
      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(bottom: spacing.lg),
        child: child,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup'),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => _confirmSkip(state.answers),
            style: TextButton.styleFrom(
              foregroundColor: colors.textTertiary,
              textStyle: typography.labelMedium,
            ),
            child: const Text('Skip setup'),
          ),
          SizedBox(width: spacing.sm),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: state.progress,
                      minHeight: 6,
                      backgroundColor: colors.surface,
                      valueColor: AlwaysStoppedAnimation(colors.textPrimary),
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  Text(
                    '${state.stepIndex + 1} of ${OnboardingState.totalSteps}',
                    style: typography.labelMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.lg),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    step(
                      ExperienceStep(
                        value: state.answers.experienceLevel,
                        onChanged: controller.setExperienceLevel,
                      ),
                    ),
                    step(
                      PrimaryGoalStep(
                        value: state.answers.primaryGoal,
                        onChanged: controller.setPrimaryGoal,
                      ),
                    ),
                    step(
                      PracticeWindowStep(
                        value: state.answers.practiceWindow,
                        onChanged: controller.setPracticeWindow,
                      ),
                    ),
                    step(
                      SessionLengthStep(
                        valueMinutes: state.answers.sessionLengthMinutes,
                        onChanged: controller.setSessionLengthMinutes,
                      ),
                    ),
                    step(
                      HapticsStep(
                        enabled: state.answers.hapticsEnabled,
                        onChanged: controller.setHapticsEnabled,
                      ),
                    ),
                    step(
                      KeepAwakeStep(
                        enabled: state.answers.keepScreenAwake,
                        onChanged: controller.setKeepScreenAwake,
                      ),
                    ),
                    step(
                      ReminderTimeStep(
                        timeMinutes: state.answers.reminderTimeMinutes,
                        onPickTime: () => _pickReminderTime(controller),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing.lg),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: !_saving && state.canGoBack
                          ? () => _goBack(state, controller)
                          : null,
                      child: const Text('Back'),
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving
                          ? null
                          : state.isLastStep
                          ? () => _finish(state.answers)
                          : () => _goNext(state, controller),
                      child: _saving
                          ? const Text('Saving...')
                          : Text(state.isLastStep ? 'Finish' : 'Continue'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSkip(OnboardingAnswers answers) async {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Skip setup?'),
          content: Text(
            'You can update these preferences later in your profile.',
            style: typography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Skip'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    await _finish(answers);
  }

  void _goBack(OnboardingState state, OnboardingController controller) {
    controller.back();
    _pageController.animateToPage(
      state.stepIndex - 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _goNext(OnboardingState state, OnboardingController controller) {
    controller.next();
    _pageController.animateToPage(
      state.stepIndex + 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _pickReminderTime(OnboardingController controller) async {
    final state = ref.read(onboardingControllerProvider);
    final initialTime = TimeOfDay(
      hour: state.answers.reminderTimeMinutes ~/ 60,
      minute: state.answers.reminderTimeMinutes % 60,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked == null) {
      return;
    }

    controller.setReminderTimeMinutes(picked.hour * 60 + picked.minute);
  }

  Future<void> _finish(OnboardingAnswers answers) async {
    if (_saving) {
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(onboardingGateProvider).complete(answers);
      if (!mounted) {
        return;
      }
      context.go(_sanitizeDestination(widget.from));
    } catch (_) {
      if (!mounted) {
        return;
      }
      final typography = Theme.of(context).extension<AppTypographyTokens>()!;
      final colors = Theme.of(context).extension<AppColorTokens>()!;
      final components = Theme.of(context).extension<AppComponentTokens>()!;
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Could not save setup. Please try again.',
            style: typography.bodyMedium.copyWith(color: colors.inverseText),
          ),
          backgroundColor: colors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(components.buttonRadius),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String _sanitizeDestination(String destination) {
    if (destination.isEmpty) {
      return '/home';
    }
    if (!destination.startsWith('/')) {
      return '/home';
    }
    if (destination.startsWith('/splash')) {
      return '/home';
    }
    if (destination.startsWith('/onboarding')) {
      return '/home';
    }
    return destination;
  }
}
