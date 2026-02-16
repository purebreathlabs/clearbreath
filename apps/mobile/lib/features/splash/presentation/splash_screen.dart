import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
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
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _duration);
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.72,
          end: 1.16,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.16,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 30,
      ),
    ]).animate(_controller);

    _controller.forward();
    _navigationTimer = Timer(_duration, _finish);
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    return Scaffold(
      body: ColoredBox(
        color: colors.background,
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(scale: _scale.value, child: child);
              },
              child: RepaintBoundary(
                child: SvgPicture.asset(
                  'assets/branding/clearbreath_logo.svg',
                  width: 160,
                  height: 160,
                  colorFilter: ColorFilter.mode(
                    colors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
