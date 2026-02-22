import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height * 0.55,
            child: Image.asset(
              'assets/images/anulom-vilom.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colors.background.withValues(alpha: 0.3),
                    colors.background.withValues(alpha: 0.85),
                    colors.background,
                    colors.background,
                  ],
                  stops: const [0.0, 0.25, 0.42, 0.52, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.xl),
              child: Column(
                children: [
                  const Spacer(flex: 5),
                  Text(
                    'Breathe with\nintention.',
                    style: typography.displayLarge.copyWith(
                      color: colors.textPrimary,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing.lg),
                  Text(
                    'Guided pranayama for calm, focus,\nand daily practice.',
                    style: typography.bodyLarge.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 2),
                  Text(
                    'No sign-up required.',
                    style: typography.labelMedium.copyWith(
                      color: colors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => handleSubmit(),
                      child: const Text('Get started'),
                    ),
                  ),
                  SizedBox(height: spacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
