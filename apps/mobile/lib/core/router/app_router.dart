import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/design_system/presentation/design_system_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_locked_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/splash/domain/splash_gate.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/techniques/presentation/techniques_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final splashGate = ref.read(splashGateProvider);

  String? redirect(BuildContext context, GoRouterState state) {
    final isSplash = state.matchedLocation == '/splash';
    if (!splashGate.completed && !isSplash) {
      final from = Uri.encodeComponent(state.uri.toString());
      return '/splash?from=$from';
    }

    return null;
  }

  final router = GoRouter(
    refreshListenable: splashGate,
    redirect: redirect,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(path: '/stats', redirect: (context, state) => '/profile'),
      GoRoute(
        path: '/design-system',
        redirect: (context, state) => '/home/design-system',
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
                builder: (context, state) => const LeaderboardLockedScreen(),
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
