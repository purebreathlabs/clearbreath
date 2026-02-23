import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_error.dart';
import '../../../core/theme/theme_extensions.dart';
import '../domain/auth_controller.dart';
import '../domain/auth_state_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  var _loading = false;
  static Future<void>? _googleInit;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    Widget card({required Widget child}) {
      return Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(components.cardRadius),
          border: Border.all(color: colors.border),
        ),
        padding: EdgeInsets.all(components.cardPadding),
        child: child,
      );
    }

    Widget iconBox(Widget child) {
      return SizedBox(width: 20, height: 20, child: Center(child: child));
    }

    Widget googleIcon() {
      return SvgPicture.asset(
        'assets/branding/google_g.svg',
        width: 20,
        height: 20,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final contentMaxWidth = maxWidth.isFinite
                ? (maxWidth > 520 ? 520.0 : maxWidth)
                : 520.0;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Padding(
                    padding: EdgeInsets.all(spacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: spacing.xl),
                        Center(
                          child: SvgPicture.asset(
                            'assets/branding/clearbreath_logo.svg',
                            width: 72,
                            height: 72,
                            colorFilter: ColorFilter.mode(
                              colors.textPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(height: spacing.lg),
                        Text(
                          'ClearBreath',
                          style: typography.headlineLarge.copyWith(
                            color: colors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: spacing.xs),
                        Text(
                          'Sign in to sync sessions across devices and unlock the leaderboard.',
                          style: typography.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: spacing.xl),
                        card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Continue with',
                                style: typography.titleMedium.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                              SizedBox(height: spacing.md),
                              FilledButton.icon(
                                onPressed: _loading
                                    ? null
                                    : () => _signInApple(),
                                icon: iconBox(
                                  const Icon(Icons.apple, size: 20),
                                ),
                                label: Text(
                                  _loading
                                      ? 'Signing in...'
                                      : 'Sign in with Apple',
                                ),
                              ),
                              SizedBox(height: spacing.sm),
                              FilledButton.icon(
                                onPressed: _loading
                                    ? null
                                    : () => _signInGoogle(),
                                icon: iconBox(googleIcon()),
                                label: Text(
                                  _loading
                                      ? 'Signing in...'
                                      : 'Sign in with Google',
                                ),
                              ),
                              if (AppConfig.devAuthEnabled) ...[
                                SizedBox(height: spacing.sm),
                                OutlinedButton(
                                  onPressed: _loading
                                      ? null
                                      : () => _signInDev(),
                                  child: Text(
                                    _loading ? 'Signing in...' : 'Dev Sign In',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _signInApple() async {
    await _runSignIn(
      provider: AuthProvider.apple,
      idTokenLoader: () async {
        final cred = await SignInWithApple.getAppleIDCredential(
          scopes: const [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        final token = cred.identityToken?.trim();
        if (token == null || token.isEmpty) {
          throw const ApiError(
            statusCode: 401,
            code: 'invalid_provider_token',
            message: 'Invalid provider token.',
            requestId: null,
          );
        }
        return token;
      },
    );
  }

  Future<void> _signInGoogle() async {
    await _runSignIn(
      provider: AuthProvider.google,
      idTokenLoader: () async {
        await (_googleInit ??= GoogleSignIn.instance.initialize(
          serverClientId:
              '884656805579-ptcbmv99ha49rcfm7lelagp5e0ooeepm.apps.googleusercontent.com',
          clientId:
              '884656805579-kb298tik2g9e92fi5dbn5nas1ivlsvhl.apps.googleusercontent.com',
        ));

        try {
          final account = await GoogleSignIn.instance.authenticate();
          final token = account.authentication.idToken?.trim();
          if (token == null || token.isEmpty) {
            throw const ApiError(
              statusCode: 401,
              code: 'invalid_provider_token',
              message: 'Invalid provider token.',
              requestId: null,
            );
          }
          return token;
        } on GoogleSignInException catch (e) {
          if (e.code == GoogleSignInExceptionCode.canceled) {
            throw const ApiError(
              statusCode: 400,
              code: 'cancelled',
              message: 'Sign-in cancelled.',
              requestId: null,
            );
          }
          throw ApiError(
            statusCode: 401,
            code: 'invalid_provider_token',
            message: e.description ?? 'Invalid provider token.',
            requestId: null,
          );
        }
      },
    );
  }

  Future<void> _signInDev() async {
    await _runSignIn(provider: AuthProvider.dev, idTokenLoader: () async => '');
  }

  Future<void> _runSignIn({
    required AuthProvider provider,
    required Future<String> Function() idTokenLoader,
  }) async {
    if (_loading) {
      return;
    }

    setState(() => _loading = true);
    try {
      final token = await idTokenLoader();
      await ref
          .read(authStateProvider.notifier)
          .signIn(provider, idToken: token);
      if (!mounted) {
        return;
      }
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message = switch (e) {
        ApiError(:final code) when code == 'rate_limited' =>
          'Too many attempts. Please try again later.',
        ApiError(:final code) when code == 'provider_not_configured' =>
          'Sign-in provider is not configured yet.',
        ApiError(:final code) when code == 'cancelled' => 'Sign-in cancelled.',
        ApiError() => e.message,
        _ => 'Sign-in failed. Please try again.',
      };

      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showMessage(String message) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
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
