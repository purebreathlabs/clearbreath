import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_extensions.dart';
import '../providers/server_status_provider.dart';

class ServerStatusDot extends ConsumerWidget {
  const ServerStatusDot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final status = ref.watch(serverStatusProvider);

    final Color dotColor;
    final String tooltip;
    final List<BoxShadow> shadows;

    switch (status) {
      case AsyncData(value: true):
        dotColor = const Color(0xFF34C759);
        tooltip = 'Server online';
        shadows = [
          BoxShadow(
            color: const Color(0xFF34C759).withValues(alpha: 0.5),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ];
      case AsyncData(value: false):
        dotColor = colors.destructive;
        tooltip = 'Server offline';
        shadows = const [];
      default:
        dotColor = colors.textTertiary;
        tooltip = "Checking\u2026";
        shadows = const [];
    }

    return Padding(
      padding: EdgeInsets.only(right: spacing.sm),
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
                boxShadow: shadows,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
