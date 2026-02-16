import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
import '../../auth/domain/auth_state_provider.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final isGuest = ref.watch(
      authStateProvider.select((state) => state.isGuest),
    );

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.divider)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 80,
            backgroundColor: colors.background,
            indicatorColor: colors.surface,
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(color: colors.textPrimary);
              }
              return IconThemeData(color: colors.textTertiary);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final base = typography.labelMedium;
              if (states.contains(WidgetState.selected)) {
                return base.copyWith(color: colors.textPrimary);
              }
              return base.copyWith(color: colors.textTertiary);
            }),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Techniques',
              ),
              NavigationDestination(
                icon: isGuest
                    ? const _LockedNavIcon(icon: Icons.emoji_events_outlined)
                    : const Icon(Icons.emoji_events_outlined),
                selectedIcon: isGuest
                    ? const _LockedNavIcon(icon: Icons.emoji_events_rounded)
                    : const Icon(Icons.emoji_events_rounded),
                label: 'Leaderboard',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedNavIcon extends StatelessWidget {
  const _LockedNavIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: colors.background,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.lock_rounded, size: 10),
          ),
        ),
      ],
    );
  }
}
