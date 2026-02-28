import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_extensions.dart';
import '../providers/connection_status.dart';
import '../providers/connection_status_provider.dart';
import 'connection_status_sheet.dart';

class ServerStatusDot extends ConsumerWidget {
  const ServerStatusDot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final connectionAsync = ref.watch(connectionStatusProvider);

    final status = connectionAsync.when(
      data: (state) => state.status,
      loading: () => ConnectionStatus.checking,
      error: (_, _) => ConnectionStatus.checking,
    );

    final Color dotColor;
    final String label;
    final List<BoxShadow> shadows;

    switch (status) {
      case ConnectionStatus.online:
        dotColor = const Color(0xFF34C759);
        label = 'Online';
        shadows = [
          BoxShadow(
            color: const Color(0xFF34C759).withValues(alpha: 0.5),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ];
      case ConnectionStatus.userOffline:
        dotColor = colors.disabled;
        label = 'Offline';
        shadows = const [];
      case ConnectionStatus.serverDown:
        dotColor = colors.destructive;
        label = 'Issue';
        shadows = const [];
      case ConnectionStatus.checking:
        dotColor = colors.textTertiary;
        label = 'Checking';
        shadows = const [];
    }

    return Padding(
      padding: EdgeInsets.only(right: spacing.sm),
      child: Semantics(
        button: true,
        label: 'Connection status: $label',
        child: GestureDetector(
          onTap: () => _showStatusSheet(context),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceHigh,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    boxShadow: shadows,
                  ),
                ),
                SizedBox(width: spacing.xs),
                Text(
                  label,
                  style: typography.labelMedium.copyWith(
                    color: colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStatusSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ConnectionStatusSheet(),
    );
  }
}
