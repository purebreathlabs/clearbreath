import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/intro/domain/intro_gate.dart';
import '../../features/intro/presentation/intro_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/onboarding/domain/onboarding_gate.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/legal_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/session/domain/local_session.dart';
import '../../features/session/presentation/session_completion_screen.dart';
import '../../features/session/presentation/session_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/splash/domain/splash_gate.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/techniques/presentation/technique_detail_screen.dart';
import '../../features/techniques/presentation/techniques_screen.dart';

final appInitialLocationProvider = Provider<String?>((ref) => null);

final appRouterProvider = Provider<GoRouter>((ref) {
  final splashGate = ref.read(splashGateProvider);
  final onboardingGate = ref.read(onboardingGateProvider);
  final introGate = ref.read(introGateProvider);

  String? redirect(BuildContext context, GoRouterState state) {
    final isSplash = state.matchedLocation == '/splash';
    final isIntro = state.matchedLocation == '/intro';
    final isOnboarding = state.matchedLocation == '/onboarding';
    final isSignIn = state.matchedLocation == '/auth/sign-in';
    if (!splashGate.completed && !isSplash) {
      final from = Uri.encodeComponent(state.uri.toString());
      return '/splash?from=$from';
    }

    if (splashGate.completed && onboardingGate.isLoaded) {
      if (!onboardingGate.isComplete) {
        if (!introGate.isLoaded) {
          return null;
        }
        if (!introGate.isComplete) {
          if (isOnboarding) {
            final from = Uri.encodeComponent(
              state.uri.queryParameters['from'] ?? '/home',
            );
            return '/intro?from=$from';
          }
          if (!isIntro && !isSplash && !isSignIn) {
            final from = Uri.encodeComponent(state.uri.toString());
            return '/intro?from=$from';
          }
        } else if (!isOnboarding && !isSplash && !isSignIn) {
          final destination = isIntro
              ? (state.uri.queryParameters['from'] ?? '/home')
              : state.uri.toString();
          final from = Uri.encodeComponent(destination);
          return '/onboarding?from=$from';
        }
      }
      if (onboardingGate.isComplete && isOnboarding) {
        final from = state.uri.queryParameters['from'] ?? '/home';
        return _sanitizeDestination(from);
      }
      if (onboardingGate.isComplete && isIntro) {
        return '/home';
      }
    }

    return null;
  }

  final router = GoRouter(
    initialLocation: ref.read(appInitialLocationProvider),
    refreshListenable: Listenable.merge([
      splashGate,
      onboardingGate,
      introGate,
    ]),
    redirect: redirect,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(path: '/stats', redirect: (context, state) => '/profile/stats'),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'] ?? '/home';
          return OnboardingScreen(from: from);
        },
      ),
      GoRoute(
        path: '/intro',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'] ?? '/home';
          return IntroScreen(from: from);
        },
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'] ?? '/home';
          return SplashScreen(from: from);
        },
      ),
      GoRoute(
        path: '/auth/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/session',
        builder: (context, state) => const SessionScreen(),
      ),
      GoRoute(
        path: '/session/complete',
        builder: (context, state) {
          final extra = state.extra;
          return SessionCompletionScreen(
            session: extra is LocalSession ? extra : null,
          );
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
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/techniques',
                builder: (context, state) => const TechniquesScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return TechniqueDetailScreen(techniqueId: id);
                    },
                  ),
                ],
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
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'stats',
                    builder: (context, state) => const StatsScreen(),
                  ),
                  GoRoute(
                    path: 'legal/:type',
                    builder: (context, state) {
                      final type = state.pathParameters['type'] ?? '';
                      return LegalScreen(type: type);
                    },
                  ),
                ],
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
  if (destination.startsWith('/intro')) {
    return '/home';
  }
  return destination;
}
