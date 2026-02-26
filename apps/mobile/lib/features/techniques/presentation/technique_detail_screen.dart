import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
import '../../../shared/utils/technique_assets.dart';
import '../../xp/domain/xp_provider.dart';
import '../data/technique_repository.dart';
import '../domain/favorites_provider.dart';
import '../domain/favorites_repository.dart';
import '../domain/safety_acknowledgement_repository.dart';
import '../domain/technique.dart';
import '../domain/technique_preset.dart';
import '../../session/domain/active_session_config.dart';
import 'widgets/safety_warning_sheet.dart';

class TechniqueDetailScreen extends ConsumerStatefulWidget {
  const TechniqueDetailScreen({super.key, required this.techniqueId});

  final String techniqueId;

  @override
  ConsumerState<TechniqueDetailScreen> createState() =>
      _TechniqueDetailScreenState();
}

class _TechniqueDetailScreenState extends ConsumerState<TechniqueDetailScreen> {
  bool _starting = false;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final techniques = ref.watch(allTechniquesProvider);
    final favorites = ref.watch(favoriteTechniqueIdsProvider);
    final favoriteIds = favorites.maybeWhen(
      data: (ids) => ids,
      orElse: () => const <String>{},
    );
    final favorited = favoriteIds.contains(widget.techniqueId);
    final safetyAcks = ref.watch(safetyAcksProvider);

    final xpAsync = ref.watch(mergedXPProvider);
    final xpState = xpAsync.asData?.value;
    final currentLevel = xpState?.currentLevel ?? 0;
    final practiceDaysAllTime = xpState?.practiceDaysAllTime ?? 0;
    final presetId = xpState?.presetId ?? 'beginner';
    final durationMinutes = xpState?.durationMinutes ?? 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Technique'),
        actions: [
          IconButton(
            key: const Key('technique_detail_favorite_toggle'),
            onPressed: _toggleFavorite,
            icon: Icon(
              favorited
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ),
            tooltip: favorited ? 'Unfavorite' : 'Favorite',
          ),
        ],
      ),
      body: SafeArea(
        child: techniques.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(spacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Could not load technique.',
                      style: typography.bodyLarge.copyWith(
                        color: colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing.lg),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(allTechniquesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          },
          data: (items) {
            final technique = items.cast<Technique?>().firstWhere(
              (t) => t?.id == widget.techniqueId,
              orElse: () => null,
            );
            if (technique == null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(spacing.lg),
                  child: Text(
                    'Technique not found.',
                    style: typography.bodyLarge.copyWith(
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final effectivePresetId = _resolvePresetId(technique, presetId);
            final preset = technique.presets[effectivePresetId]!;
            final isRoundBased = preset is BpmRoundsPreset;
            final effectiveMinutes = isRoundBased ? 0 : durationMinutes;
            final safetyAcked =
                safetyAcks.asData?.value.contains(technique.id) ?? false;

            final imagePath = techniqueImageAsset(technique.id);

            return Padding(
              padding: EdgeInsets.all(spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroImage(
                            imagePath: imagePath,
                            techniqueName: technique.name,
                          ),
                          SizedBox(height: spacing.lg),
                          Text(
                            technique.name,
                            style: typography.headlineLarge.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: spacing.xs),
                          Text(
                            technique.shortDescription,
                            style: typography.bodyLarge.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          if (technique.safety.requiresAck) ...[
                            SizedBox(height: spacing.lg),
                            Container(
                              padding: EdgeInsets.all(components.cardPadding),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(
                                  components.cardRadius,
                                ),
                                border: Border.all(color: colors.border),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    safetyAcked
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.warning_amber_rounded,
                                    color: colors.textPrimary,
                                    size: 20,
                                  ),
                                  SizedBox(width: spacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          safetyAcked
                                              ? 'Safety acknowledged'
                                              : 'Safety notice',
                                          style: typography.titleMedium
                                              .copyWith(
                                                color: colors.textPrimary,
                                              ),
                                        ),
                                        SizedBox(height: spacing.xs),
                                        Text(
                                          safetyAcked
                                              ? 'You\u2019ve acknowledged the safety guidance for this technique.'
                                              : 'You\u2019ll be asked to acknowledge the safety guidance before your first session.',
                                          style: typography.bodyMedium.copyWith(
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: spacing.xl),
                          _SessionInfoCard(
                            currentLevel: currentLevel,
                            practiceDaysAllTime: practiceDaysAllTime,
                            presetId: effectivePresetId,
                            durationMinutes: effectiveMinutes,
                            isRoundBased: isRoundBased,
                            preset: preset,
                          ),
                          SizedBox(height: spacing.xl),
                          _Section(
                            title: 'What It Is',
                            body: technique.about.what,
                          ),
                          _Section(
                            title: 'How To Do It',
                            body: technique.about.how,
                          ),
                          _Section(
                            title: 'Best Time',
                            body: technique.about.bestTime,
                          ),
                          _Section(
                            title: 'Benefits',
                            body: technique.about.benefits,
                          ),
                          _Section(
                            title: 'Warnings',
                            body: technique.about.warnings,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.lg),
                  FilledButton(
                    onPressed: _starting
                        ? null
                        : () {
                            final durationLimitSeconds =
                                preset is BpmRoundsPreset
                                ? preset.naturalDurationSeconds
                                : effectiveMinutes * 60;
                            _startSession(
                              technique: technique,
                              preset: preset,
                              presetId: effectivePresetId,
                              durationLimitSeconds: durationLimitSeconds,
                            );
                          },
                    child: Text(_starting ? 'Starting...' : 'Start Session'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _resolvePresetId(Technique technique, String preferred) {
    if (technique.presets.containsKey(preferred)) return preferred;
    if (technique.presets.containsKey('beginner')) return 'beginner';
    return technique.presets.keys.first;
  }

  Future<void> _toggleFavorite() async {
    try {
      await ref.read(favoritesRepositoryProvider).toggle(widget.techniqueId);
      ref.invalidate(favoriteTechniqueIdsProvider);
    } catch (_) {
      if (!mounted) {
        return;
      }
      final typography = Theme.of(context).extension<AppTypographyTokens>()!;
      final colors = Theme.of(context).extension<AppColorTokens>()!;
      final components = Theme.of(context).extension<AppComponentTokens>()!;
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Could not update favorite. Please try again.',
            style: typography.bodyMedium.copyWith(color: colors.inverseText),
          ),
          backgroundColor: colors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(components.buttonRadius),
          ),
        ),
      );
    }
  }

  Future<void> _startSession({
    required Technique technique,
    required TechniquePreset preset,
    required String presetId,
    required int durationLimitSeconds,
  }) async {
    if (_starting) {
      return;
    }

    setState(() => _starting = true);
    try {
      if (technique.safety.requiresAck) {
        final acks = await ref.read(safetyAcksProvider.future);
        if (!mounted) {
          return;
        }
        if (!acks.contains(technique.id)) {
          final confirmed = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (context) => SafetyWarningSheet(technique: technique),
          );
          if (confirmed != true) {
            return;
          }
        }
      }

      ref
          .read(activeSessionConfigProvider.notifier)
          .setConfig(
            ActiveSessionConfig(
              technique: technique,
              preset: preset,
              presetId: presetId,
              durationLimitSeconds: durationLimitSeconds,
            ),
          );

      if (!mounted) {
        return;
      }
      context.go('/session');
    } catch (_) {
      if (!mounted) {
        return;
      }
      final typography = Theme.of(context).extension<AppTypographyTokens>()!;
      final colors = Theme.of(context).extension<AppColorTokens>()!;
      final components = Theme.of(context).extension<AppComponentTokens>()!;
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Could not start session. Please try again.',
            style: typography.bodyMedium.copyWith(color: colors.inverseText),
          ),
          backgroundColor: colors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(components.buttonRadius),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _starting = false);
      }
    }
  }
}

class _SessionInfoCard extends StatelessWidget {
  const _SessionInfoCard({
    required this.currentLevel,
    required this.practiceDaysAllTime,
    required this.presetId,
    required this.durationMinutes,
    required this.isRoundBased,
    required this.preset,
  });

  final int currentLevel;
  final int practiceDaysAllTime;
  final String presetId;
  final int durationMinutes;
  final bool isRoundBased;
  final TechniquePreset preset;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final presetLabel = presetId[0].toUpperCase() + presetId.substring(1);
    final nextUnlock = _nextUnlockText(practiceDaysAllTime);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(components.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(components.cardRadius),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Session',
            style: typography.titleMedium.copyWith(color: colors.textPrimary),
          ),
          SizedBox(height: spacing.md),
          Row(
            children: [
              _InfoChip(label: 'Level $currentLevel'),
              SizedBox(width: spacing.sm),
              _InfoChip(label: presetLabel),
              if (!isRoundBased) ...[
                SizedBox(width: spacing.sm),
                _InfoChip(label: '$durationMinutes min'),
              ],
            ],
          ),
          if (isRoundBased && preset is BpmRoundsPreset) ...[
            SizedBox(height: spacing.md),
            _RoundInfo(preset: preset as BpmRoundsPreset),
          ],
          if (nextUnlock != null) ...[
            SizedBox(height: spacing.md),
            Text(
              nextUnlock,
              style: typography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _nextUnlockText(int practiceDays) {
    final candidates = <(int unlockPracticeDays, String label)>[];

    if (!isRoundBased) {
      if (durationMinutes < 5) {
        candidates.add((7, '5 min sessions'));
      } else if (durationMinutes < 10) {
        candidates.add((30, '10 min sessions'));
      } else if (durationMinutes < 15) {
        candidates.add((60, '15 min sessions'));
      } else if (durationMinutes < 20) {
        candidates.add((100, '20 min sessions'));
      }
    }

    if (presetId == 'beginner') {
      candidates.add((15, 'intermediate pace'));
    } else if (presetId == 'intermediate') {
      candidates.add((50, 'advanced pace'));
    }

    candidates.sort((a, b) => a.$1.compareTo(b.$1));
    for (final (unlockPracticeDays, label) in candidates) {
      if (practiceDays < unlockPracticeDays) {
        final remaining = unlockPracticeDays - practiceDays;
        final dayLabel = remaining == 1 ? 'day' : 'days';
        return 'Next unlock in $remaining practice $dayLabel: $label';
      }
    }
    return null;
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: typography.labelMedium.copyWith(color: colors.textPrimary),
      ),
    );
  }
}

class _RoundInfo extends StatelessWidget {
  const _RoundInfo({required this.preset});

  final BpmRoundsPreset preset;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    final totalSeconds = preset.naturalDurationSeconds;
    final totalMin = totalSeconds ~/ 60;
    final totalSec = totalSeconds % 60;
    final totalLabel = totalMin > 0
        ? (totalSec > 0 ? '~${totalMin}m ${totalSec}s' : '~${totalMin}m')
        : '~${totalSec}s';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${preset.rounds} rounds \u00b7 ${preset.roundSeconds}s each',
          style: typography.bodyMedium.copyWith(color: colors.textPrimary),
        ),
        if (preset.rounds > 1) ...[
          SizedBox(height: spacing.xs),
          Text(
            '${preset.restSeconds}s rest between rounds',
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
        ],
        SizedBox(height: spacing.xs),
        Text(
          'Total: $totalLabel',
          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imagePath, required this.techniqueName});

  final String? imagePath;
  final String techniqueName;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(components.cardRadius),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: colors.surfaceHigh),
              )
            else
              Container(color: colors.surfaceHigh),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: typography.titleMedium),
          SizedBox(height: spacing.sm),
          Text(
            body,
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
