import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
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
  String _presetId = 'beginner';
  int? _durationMinutes;
  bool _starting = false;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    final techniques = ref.watch(allTechniquesProvider);
    final favorites = ref.watch(favoriteTechniqueIdsProvider);
    final favoriteIds = favorites.maybeWhen(
      data: (ids) => ids,
      orElse: () => const <String>{},
    );
    final favorited = favoriteIds.contains(widget.techniqueId);

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
            final technique = items
                .cast<Technique?>()
                .firstWhere(
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

            final preset = technique.presets[_presetId]!;
            final durations = preset.recommendedDurationsMinutes;
            final effectiveMinutes = _durationMinutes ?? _defaultMinutes(durations);

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
                          SizedBox(height: spacing.xl),
                          Text('Preset', style: typography.titleMedium),
                          SizedBox(height: spacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: _SelectionPill(
                                  key: const Key('preset_beginner'),
                                  label: 'Beginner',
                                  selected: _presetId == 'beginner',
                                  onTap: () => _setPreset('beginner', technique),
                                ),
                              ),
                              SizedBox(width: spacing.sm),
                              Expanded(
                                child: _SelectionPill(
                                  key: const Key('preset_intermediate'),
                                  label: 'Intermediate',
                                  selected: _presetId == 'intermediate',
                                  onTap: () =>
                                      _setPreset('intermediate', technique),
                                ),
                              ),
                              SizedBox(width: spacing.sm),
                              Expanded(
                                child: _SelectionPill(
                                  key: const Key('preset_advanced'),
                                  label: 'Advanced',
                                  selected: _presetId == 'advanced',
                                  onTap: () => _setPreset('advanced', technique),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: spacing.lg),
                          Text('Duration', style: typography.titleMedium),
                          SizedBox(height: spacing.sm),
                          Wrap(
                            spacing: spacing.sm,
                            runSpacing: spacing.sm,
                            children: [
                              for (final minutes in durations)
                                _SelectionPill(
                                  key: Key('duration_$minutes'),
                                  label: '${minutes}m',
                                  selected: effectiveMinutes == minutes,
                                  onTap: () =>
                                      setState(() => _durationMinutes = minutes),
                                ),
                            ],
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
                        : () => _startSession(
                              technique: technique,
                              preset: preset,
                              presetId: _presetId,
                              durationMinutes: effectiveMinutes,
                            ),
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

  int _defaultMinutes(List<int> options) {
    if (options.contains(5)) {
      return 5;
    }
    return options.isEmpty ? 5 : options.first;
  }

  void _setPreset(String id, Technique technique) {
    if (_presetId == id) {
      return;
    }
    final preset = technique.presets[id];
    if (preset == null) {
      return;
    }

    setState(() {
      _presetId = id;
      _durationMinutes = _defaultMinutes(preset.recommendedDurationsMinutes);
    });
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
    required int durationMinutes,
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

      ref.read(activeSessionConfigProvider.notifier).setConfig(
        ActiveSessionConfig(
          technique: technique,
          preset: preset,
          presetId: presetId,
          durationLimitSeconds: durationMinutes * 60,
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

class _SelectionPill extends StatelessWidget {
  const _SelectionPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(components.buttonRadius),
      side: BorderSide(color: selected ? colors.focus : colors.border),
    );

    return Material(
      color: selected ? colors.surfaceHigh : colors.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          child: Center(
            child: Text(
              label,
              style: typography.labelLarge.copyWith(color: colors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
