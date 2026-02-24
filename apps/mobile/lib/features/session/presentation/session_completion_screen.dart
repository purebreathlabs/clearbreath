import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
import '../../notifications/domain/notification_controller.dart';
import '../../share/presentation/share_button.dart';
import '../../share/presentation/share_card_widget.dart';
import '../../techniques/data/technique_repository.dart';
import '../../techniques/domain/technique.dart';
import '../../stats/domain/stats_snapshot.dart';
import '../../sync/domain/merged_stats_provider.dart';
import '../domain/local_session.dart';

class SessionCompletionScreen extends ConsumerStatefulWidget {
  const SessionCompletionScreen({super.key, required this.session});

  final LocalSession? session;

  @override
  ConsumerState<SessionCompletionScreen> createState() =>
      _SessionCompletionScreenState();
}

class _SessionCompletionScreenState
    extends ConsumerState<SessionCompletionScreen> {
  var _permissionDialogShowing = false;
  final _shareCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    ref.listenManual(notificationControllerProvider, (previous, next) {
      if (!next.showPermissionPrompt) {
        return;
      }
      if (_permissionDialogShowing) {
        return;
      }
      _permissionDialogShowing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }
        await _showPermissionDialog();
        if (mounted) {
          _permissionDialogShowing = false;
        }
      });
    }, fireImmediately: true);
  }

  Future<void> _showPermissionDialog() async {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enable reminders'),
          content: Text(
            'Get a daily reminder and a streak warning. You can change this anytime in Settings.',
            style: typography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
          contentPadding: EdgeInsets.fromLTRB(
            spacing.lg,
            spacing.lg,
            spacing.lg,
            spacing.md,
          ),
          actionsPadding: EdgeInsets.only(
            left: spacing.lg,
            right: spacing.lg,
            bottom: spacing.lg,
          ),
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await ref
        .read(notificationControllerProvider.notifier)
        .requestPermissionFromPrompt();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    final current = widget.session;
    final techniques = ref.watch(allTechniquesProvider);
    final stats = ref.watch(mergedStatsProvider);
    final technique = current == null
        ? null
        : _findTechnique(techniques.asData?.value, current.techniqueId);

    final title = current == null
        ? 'Session complete'
        : (technique?.name ?? _titleCaseId(current.techniqueId));
    final presetLabel = current == null
        ? null
        : (technique?.presets[current.presetId]?.label ??
              _titleCaseId(current.presetId));
    final minutes = current == null
        ? null
        : max(0, (current.durationSecondsActual / 60).round());
    final streakValue = stats.when(
      data: (snapshot) => snapshot.currentStreakDays.toString(),
      loading: () => '—',
      error: (error, stackTrace) => '—',
    );
    final streakMessage = stats.when(
      data: (snapshot) => _streakMessage(snapshot),
      loading: () => 'Updating your streak...',
      error: (error, stackTrace) => 'Could not update streak.',
    );

    final statsSnapshot = stats.asData?.value;
    final canShare = current != null && statsSnapshot != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Complete')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: spacing.md),
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: colors.textPrimary,
                        size: 56,
                      ),
                      SizedBox(height: spacing.lg),
                      Text(
                        title,
                        key: const Key('completion_technique_title'),
                        style: typography.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      if (presetLabel != null) ...[
                        SizedBox(height: spacing.xs),
                        Text(
                          presetLabel,
                          key: const Key('completion_preset_label'),
                          style: typography.bodyLarge.copyWith(
                            color: colors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      SizedBox(height: spacing.xl),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final tileWidth =
                              (constraints.maxWidth - spacing.md) / 2.0;

                          return Wrap(
                            spacing: spacing.md,
                            runSpacing: spacing.md,
                            children: [
                              SizedBox(
                                width: tileWidth,
                                child: _MetricTile(
                                  key: const Key('completion_minutes_tile'),
                                  label: 'Minutes',
                                  value: minutes == null ? '—' : '$minutes',
                                ),
                              ),
                              SizedBox(
                                width: tileWidth,
                                child: _MetricTile(
                                  key: const Key('completion_breaths_tile'),
                                  label: 'Breaths',
                                  value: current == null
                                      ? '—'
                                      : '${current.breathsCompletedEstimated}',
                                ),
                              ),
                              SizedBox(
                                width: tileWidth,
                                child: _MetricTile(
                                  key: const Key('completion_streak_tile'),
                                  label: 'Streak',
                                  value: streakValue,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: spacing.xl),
                      Text(
                        streakMessage,
                        style: typography.bodyMedium.copyWith(
                          color: colors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (canShare) ...[
                        SizedBox(height: spacing.xl),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final size = min(constraints.maxWidth, 260.0);
                            return Center(
                              child: SizedBox(
                                width: size,
                                height: size,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: RepaintBoundary(
                                    key: _shareCardKey,
                                    child: SizedBox(
                                      width: 360,
                                      height: 360,
                                      child: ShareCardWidget(
                                        streakDays: statsSnapshot.currentStreakDays,
                                        minutesToday: minutes ?? 0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: spacing.lg),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: spacing.lg),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('Done'),
              ),
              SizedBox(height: spacing.sm),
              ShareButton(repaintBoundaryKey: _shareCardKey, enabled: canShare),
            ],
          ),
        ),
      ),
    );
  }

  Technique? _findTechnique(List<Technique>? items, String techniqueId) {
    if (items == null || items.isEmpty) {
      return null;
    }
    for (final technique in items) {
      if (technique.id == techniqueId) {
        return technique;
      }
    }
    return null;
  }

  String _titleCaseId(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'[_\\s-]+'))
        .where((p) => p.isNotEmpty);
    final words = parts
        .map((part) {
          if (part.isEmpty) {
            return part;
          }
          final lower = part.toLowerCase();
          return lower[0].toUpperCase() + lower.substring(1);
        })
        .toList(growable: false);
    return words.isEmpty ? value : words.join(' ');
  }

  String _streakMessage(StatsSnapshot snapshot) {
    final days = snapshot.currentStreakDays;
    if (days <= 0) {
      return 'Keep going — 2 min to start today’s streak.';
    }
    if (days == 1) {
      return 'Streak started!';
    }
    return 'Day $days streak!';
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(components.cardRadius),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.labelMedium.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.sm),
          Text(
            value,
            style: typography.headlineLarge.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
