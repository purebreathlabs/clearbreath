import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_extensions.dart';
import '../providers/connection_status.dart';
import '../providers/connection_status_provider.dart';

class ConnectionStatusSheet extends ConsumerStatefulWidget {
  const ConnectionStatusSheet({super.key});

  @override
  ConsumerState<ConnectionStatusSheet> createState() =>
      _ConnectionStatusSheetState();
}

class _ConnectionStatusSheetState extends ConsumerState<ConnectionStatusSheet> {
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final connectionAsync = ref.watch(connectionStatusProvider);
    final connectionState =
        connectionAsync.asData?.value ?? const AppConnectionState.initial();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Material(
          color: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(components.cardRadius),
            side: BorderSide(color: colors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.all(components.cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Connection Status',
                        style: typography.titleMedium.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: colors.textTertiary,
                      tooltip: 'Close',
                    ),
                  ],
                ),
                SizedBox(height: spacing.md),
                _StatusRow(
                  label: 'Internet',
                  value: _internetLabel(connectionState),
                  dotColor: _internetColor(connectionState, colors),
                ),
                SizedBox(height: spacing.sm),
                _StatusRow(
                  label: 'Server',
                  value: _serverLabel(connectionState),
                  dotColor: _serverColor(connectionState, colors),
                ),
                SizedBox(height: spacing.md),
                Text(
                  _lastCheckedText(connectionState),
                  style: typography.bodyMedium.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                SizedBox(height: spacing.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _internetLabel(AppConnectionState state) {
    return switch (state.hasInternet) {
      true => 'Connected',
      false => 'Disconnected',
      null => 'Checking\u2026',
    };
  }

  Color _internetColor(AppConnectionState state, AppColorTokens colors) {
    return switch (state.hasInternet) {
      true => const Color(0xFF34C759),
      false => colors.disabled,
      null => colors.textTertiary,
    };
  }

  String _serverLabel(AppConnectionState state) {
    if (state.hasInternet == false) return 'Unknown';
    return switch (state.serverReachable) {
      true => 'Online',
      false => 'Unavailable',
      null => 'Checking\u2026',
    };
  }

  Color _serverColor(AppConnectionState state, AppColorTokens colors) {
    if (state.hasInternet == false) return colors.disabled;
    return switch (state.serverReachable) {
      true => const Color(0xFF34C759),
      false => colors.destructive,
      null => colors.textTertiary,
    };
  }

  String _lastCheckedText(AppConnectionState state) {
    final lastChecked = state.lastCheckedAt;
    if (lastChecked == null) return 'Checking\u2026';

    final seconds = DateTime.now().difference(lastChecked).inSeconds;
    if (seconds < 3) return 'Last checked: just now';
    if (seconds < 60) return 'Last checked: ${seconds}s ago';

    final minutes = seconds ~/ 60;
    return 'Last checked: ${minutes}m ago';
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.dotColor,
  });

  final String label;
  final String value;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
        ),
        SizedBox(width: spacing.sm),
        Text(
          label,
          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: typography.bodyMedium.copyWith(color: colors.textPrimary),
        ),
      ],
    );
  }
}
