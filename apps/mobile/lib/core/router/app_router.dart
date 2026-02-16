import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/design_system/presentation/design_system_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/onboarding/domain/onboarding_gate.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/splash/domain/splash_gate.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/techniques/presentation/techniques_screen.dart';

final appInitialLocationProvider = Provider<String?>((ref) => null);

final appRouterProvider = Provider<GoRouter>((ref) {
  final splashGate = ref.read(splashGateProvider);
  final onboardingGate = ref.read(onboardingGateProvider);

  String? redirect(BuildContext context, GoRouterState state) {
    final isSplash = state.matchedLocation == '/splash';
    final isOnboarding = state.matchedLocation == '/onboarding';
    if (!splashGate.completed && !isSplash) {
      final from = Uri.encodeComponent(state.uri.toString());
      return '/splash?from=$from';
    }

    if (splashGate.completed && onboardingGate.isLoaded) {
      if (!onboardingGate.isComplete && !isOnboarding && !isSplash) {
        final from = Uri.encodeComponent(state.uri.toString());
        return '/onboarding?from=$from';
      }
      if (onboardingGate.isComplete && isOnboarding) {
        final from = state.uri.queryParameters['from'] ?? '/home';
        return _sanitizeDestination(from);
      }
    }

    return null;
  }

  final router = GoRouter(
    initialLocation: ref.read(appInitialLocationProvider),
    refreshListenable: Listenable.merge([splashGate, onboardingGate]),
    redirect: redirect,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(path: '/stats', redirect: (context, state) => '/profile'),
      GoRoute(
        path: '/design-system',
        redirect: (context, state) => '/home/design-system',
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'] ?? '/home';
          return OnboardingScreen(from: from);
        },
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'] ?? '/home';
          return SplashScreen(from: from);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'design-system',
                    builder: (context, state) => const DesignSystemScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/techniques',
                builder: (context, state) => const TechniquesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leaderboard',
                builder: (context, state) => const LeaderboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

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
