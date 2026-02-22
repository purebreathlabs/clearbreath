import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
import '../domain/intro_gate.dart';

class IntroScreen extends ConsumerWidget {
  const IntroScreen({super.key, required this.from});

  final String from;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    Future<void> handleSubmit() async {
      try {
        await ref.read(introGateProvider).complete();
        if (!context.mounted) {
          return;
        }
        final encodedFrom = Uri.encodeComponent(from);
        context.go('/onboarding?from=$encodedFrom');
      } catch (_) {
        if (!context.mounted) {
          return;
        }
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Could not continue. Please try again.',
              style: typography.bodyMedium.copyWith(color: colors.inverseText),
            ),
            backgroundColor: colors.inverseSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(components.buttonRadius),
            ),
          ),
        );
      }
    }

    return Scaffold(
      body: ColoredBox(
        color: colors.background,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: spacing.xl),
                            Center(
                              child: SvgPicture.asset(
                                'assets/branding/clearbreath_logo.svg',
                                width: 84,
                                height: 84,
                                colorFilter: ColorFilter.mode(
                                  colors.textPrimary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            SizedBox(height: spacing.lg),
                            Text(
                              'Meet ClearBreath',
                              style: typography.headlineLarge,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacing.sm),
                            Text(
                              'Breathe with intention.',
                              style: typography.bodyLarge.copyWith(
                                color: colors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacing.lg),
                            Text(
                              'A focused pranayama app with guided pacing and simple progress—built for daily practice.',
                              style: typography.bodyMedium.copyWith(
                                color: colors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacing.xl),
                            _FeatureTile(
                              icon: Icons.grid_view_rounded,
                              title: 'Authentic techniques',
                              description:
                                  'A complete library from beginner to advanced.',
                              radius: components.cardRadius,
                            ),
                            SizedBox(height: spacing.md),
                            _FeatureTile(
                              icon: Icons.timelapse_rounded,
                              title: 'Guided sessions',
                              description:
                                  'Clean visuals with optional cues and haptics.',
                              radius: components.cardRadius,
                            ),
                            SizedBox(height: spacing.md),
                            _FeatureTile(
                              icon: Icons.local_fire_department_rounded,
                              title: 'Streaks that motivate',
                              description:
                                  'Build consistency with a simple daily streak.',
                              radius: components.cardRadius,
                            ),
                            SizedBox(height: spacing.xl),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'No sign-up required.',
                      style: typography.labelMedium.copyWith(
                        color: colors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing.md),
                    FilledButton(
                      onPressed: () => handleSubmit(),
                      child: const Text('Get started'),
                    ),
                    SizedBox(height: spacing.sm),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.radius,
  });

  final IconData icon;
  final String title;
  final String description;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surfaceHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: colors.textPrimary, size: 22),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: typography.titleMedium),
                SizedBox(height: spacing.xs),
                Text(
                  description,
                  style: typography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
