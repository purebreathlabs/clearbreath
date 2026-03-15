import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
import '../../onboarding/domain/onboarding_gate.dart';
import '../domain/splash_gate.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key, required this.from});

  final String from;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(seconds: 2);

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _textOpacity;
  Timer? _navigationTimer;
  Timer? _readinessTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _duration);
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.6,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 70,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 30),
    ]).animate(_controller);

    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.70, curve: Curves.easeIn),
    );

    _controller.forward();
    _navigationTimer = Timer(_duration, _waitForReadiness);
  }

  void _waitForReadiness() {
    if (!mounted) {
      return;
    }

    final gate = ref.read(onboardingGateProvider);
    if (gate.isLoaded) {
      _finish();
      return;
    }

    _readinessTimer?.cancel();
    _readinessTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (ref.read(onboardingGateProvider).isLoaded) {
        timer.cancel();
        _finish();
      }
    });
  }

  void _finish() {
    if (!mounted) {
      return;
    }

    ref.read(splashGateProvider).complete();
    context.go(_sanitizeDestination(widget.from));
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
    return destination;
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _readinessTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;

    return Scaffold(
      body: ColoredBox(
        color: colors.background,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(scale: _scale.value, child: child);
                  },
                  child: RepaintBoundary(
                    child: Image.asset(
                      'assets/branding/logo.png',
                      width: 160,
                      height: 160,
                      color: colors.textPrimary,
                      colorBlendMode: BlendMode.srcIn,
                      semanticLabel: 'ClearBreath',
                    ),
                  ),
                ),
                SizedBox(height: spacing.xxl),
                FadeTransition(
                  opacity: _textOpacity,
                  child: Text(
                    'ClearBreath',
                    style: typography.headlineLarge.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
