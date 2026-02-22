import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_error.dart';
import '../../../core/theme/theme_extensions.dart';
import '../domain/age_gate.dart';
import '../domain/auth_controller.dart';
import '../domain/auth_state_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  late int _birthYear;
  var _loading = false;
  static Future<void>? _googleInit;

  @override
  void initState() {
    super.initState();
    _birthYear = DateTime.now().year - 25;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final eligible = isEligible(_birthYear, DateTime.now());

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
                        card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Birth year',
                                style: typography.titleMedium.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                              SizedBox(height: spacing.sm),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '$_birthYear',
                                      style: typography.titleLarge.copyWith(
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: _loading ? null : _pickBirthYear,
                                    child: const Text('Change'),
                                  ),
                                ],
                              ),
                              SizedBox(height: spacing.sm),
                              Text(
                                eligible
                                    ? 'Sign-in is available for ages 13+.'
                                    : 'Sign-in is not available for this age. Guest mode is fully functional.',
                                style: typography.bodyMedium.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
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
                                onPressed: _loading || !eligible
                                    ? null
                                    : () => _signInApple(),
                                icon: const Icon(Icons.apple),
                                label: Text(
                                  _loading
                                      ? 'Signing in...'
                                      : 'Sign in with Apple',
                                ),
                              ),
                              SizedBox(height: spacing.sm),
                              FilledButton.icon(
                                onPressed: _loading || !eligible
                                    ? null
                                    : () => _signInGoogle(),
                                icon: const Icon(Icons.g_mobiledata_rounded),
                                label: Text(
                                  _loading
                                      ? 'Signing in...'
                                      : 'Sign in with Google',
                                ),
                              ),
                              if (AppConfig.devAuthEnabled) ...[
                                SizedBox(height: spacing.sm),
                                OutlinedButton(
                                  onPressed: _loading || !eligible
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

  Future<void> _pickBirthYear() async {
    final yearNow = DateTime.now().year;
    final years = [for (var y = yearNow; y >= 1900; y--) y];
    final index = years.indexOf(_birthYear).clamp(0, years.length - 1);

    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
        final colors = Theme.of(context).extension<AppColorTokens>()!;
        final typography = Theme.of(context).extension<AppTypographyTokens>()!;

        var selected = years[index];
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Select birth year',
                  style: typography.titleLarge.copyWith(color: colors.textPrimary),
                ),
                SizedBox(height: spacing.md),
                SizedBox(
                  height: 180,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: index,
                    ),
                    itemExtent: 36,
                    onSelectedItemChanged: (i) => selected = years[i],
                    children: [
                      for (final y in years)
                        Center(
                          child: Text(
                            '$y',
                            style: typography.titleMedium.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.md),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(selected),
                  child: const Text('Done'),
                ),
                SizedBox(height: spacing.sm),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked == null) {
      return;
    }
    setState(() => _birthYear = picked);
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
        await (_googleInit ??= GoogleSignIn.instance.initialize());

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
    await _runSignIn(
      provider: AuthProvider.dev,
      idTokenLoader: () async => '',
    );
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
          .signIn(provider, birthYear: _birthYear, idToken: token);
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
        ApiError(:final code) when code == 'age_restricted' =>
          'Sign-in is not available for this age.',
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
