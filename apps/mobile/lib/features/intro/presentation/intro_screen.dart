import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
import '../../../shared/widgets/brand_mark.dart';
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: spacing.xl),
              Center(
                child: BrandMark(
                  logoSize: 36,
                  textStyle: typography.titleLarge,
                ),
              ),
              SizedBox(height: spacing.lg),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxImageHeight = (constraints.maxHeight * 0.74).clamp(
                      200.0,
                      450.0,
                    );
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: maxImageHeight,
                                ),
                                child: Image.asset(
                                  'assets/images/anulom-vilom.png',
                                  fit: BoxFit.contain,
                                  alignment: Alignment.bottomCenter,
                                  errorBuilder: (_, _, _) =>
                                      const SizedBox.shrink(),
                                ),
                              ),
                            ),
                            SizedBox(height: spacing.sm),
                            Text(
                              'Breathe with\nintention.',
                              style: typography.displayLarge.copyWith(
                                color: colors.textPrimary,
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacing.md),
                            Text(
                              'Guided pranayama for calm, focus,\nand daily practice.',
                              style: typography.bodyLarge.copyWith(
                                color: colors.textSecondary,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: spacing.lg),
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
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () => context.push('/auth/sign-in'),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: typography.labelLarge.copyWith(
                        color: colors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign in',
                          style: typography.labelLarge.copyWith(
                            color: colors.textPrimary,
                            decoration: TextDecoration.underline,
                            decorationColor: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: spacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
