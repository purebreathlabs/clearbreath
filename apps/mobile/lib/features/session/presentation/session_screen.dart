import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
import '../../techniques/data/technique_repository.dart';
import '../../techniques/domain/technique.dart';
import '../../techniques/domain/technique_preset.dart';
import '../domain/active_session_config.dart';
import '../domain/local_session.dart';
import '../domain/session_controller.dart';
import '../domain/session_phase.dart';
import '../domain/session_state.dart';
import 'session_ui_model.dart';
import 'widgets/alternate_nostril_indicator.dart';
import 'widgets/breathing_circle.dart';
import 'widgets/metronome_pulse.dart';
import 'widgets/session_audio_controls.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen>
    with WidgetsBindingObserver {
  late final SessionController _controller;
  bool _started = false;
  bool _allowPop = false;
  bool _handlingPop = false;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(sessionControllerProvider.notifier);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startIfNeeded());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _controller.stop();
    }
  }

  void _startIfNeeded() {
    if (!mounted || _started) {
      return;
    }

    final current = ref.read(sessionControllerProvider);
    if (!current.isIdle && !current.isCompleted) {
      _started = true;
      return;
    }

    final config = ref.read(activeSessionConfigProvider);
    if (config != null) {
      _controller.startSession(config);
      ref.read(activeSessionConfigProvider.notifier).clear();
    } else {
      _controller.startDefault();
    }
    _started = true;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LocalSession?>(lastCompletedSessionProvider, (previous, next) {
      if (next == null) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ref.read(lastCompletedSessionProvider.notifier).clear();
        context.go('/session/complete', extra: next);
      });
    });

    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    final state = ref.watch(sessionControllerProvider);

    final techniques = ref.watch(allTechniquesProvider);
    final technique = _findTechnique(techniques, state.techniqueId);
    final preset = technique != null
        ? technique.presets[state.presetId ?? '']
        : null;

    final uiModel = SessionUiModel.from(state, technique, preset);
    final bpm = preset is BpmRoundsPreset ? preset.bpm : 60;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenHeight < 760;
    final isNarrow = screenWidth < 360;
    final hPad = isNarrow ? spacing.md : spacing.lg;
    final maxRingSize = isCompact ? 220.0 : 280.0;

    final canPop = _allowPop || state.isIdle || state.isCompleted;

    return PopScope<Object?>(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          if (state.isCompleted) {
            _controller.stop();
          }
          return;
        }
        unawaited(_requestExit(confirm: true));
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // === HEADER ===
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: hPad,
                  vertical: spacing.md,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: colors.textSecondary,
                        ),
                        onPressed: () => _requestExit(
                          confirm:
                              state.isBreathing ||
                              state.isCountdown ||
                              state.isPaused,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    Expanded(
                      child: Text(
                        technique?.name ?? 'Session',
                        style: typography.titleMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SessionAudioControls(),
                  ],
                ),
              ),

              // === FOCAL STAGE ===
              Expanded(
                child: Center(
                  child: _buildStage(uiModel, state, bpm, maxRingSize),
                ),
              ),

              // === DOCK ===
              Padding(
                padding: EdgeInsets.fromLTRB(
                  hPad,
                  spacing.md,
                  hPad,
                  spacing.xl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Info row
                    if (uiModel.roundLabel != null &&
                        uiModel.stageMode != AnimationMode.metronome)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            uiModel.secondaryTimer,
                            style: typography.labelMedium.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                          Text(
                            uiModel.roundLabel!,
                            style: typography.labelMedium.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        uiModel.secondaryTimer,
                        style: typography.labelMedium.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    SizedBox(height: spacing.lg),

                    // Primary action
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: uiModel.canResume
                            ? _controller.resume
                            : uiModel.canPause
                            ? _controller.pause
                            : null,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(uiModel.canResume ? 'Resume' : 'Pause'),
                      ),
                    ),
                    SizedBox(height: spacing.md),

                    // End session link
                    TextButton(
                      onPressed: uiModel.canStop
                          ? () => _requestExit(confirm: !state.isCompleted)
                          : null,
                      style: TextButton.styleFrom(
                        foregroundColor: colors.textTertiary,
                        textStyle: typography.bodyMedium,
                      ),
                      child: const Text('End Session'),
                    ),
                  ],
                ),
              ),

              if (techniques.hasError)
                Padding(
                  padding: EdgeInsets.all(spacing.lg),
                  child: Text(
                    'Could not load technique visuals.',
                    style: typography.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStage(
    SessionUiModel uiModel,
    SessionState state,
    int bpm,
    double maxRingSize,
  ) {
    return switch (uiModel.stageMode) {
      AnimationMode.metronome => MetronomePulse(
        bpm: bpm,
        progress: uiModel.phaseProgress,
        isActiveRound: state.phase == SessionPhase.round,
        phaseTitle: uiModel.phaseTitle,
        primaryTimer: uiModel.primaryTimer,
        roundLabel: uiModel.roundLabel,
        arcColor: uiModel.phaseColor,
        maxRingSize: maxRingSize - 40,
      ),
      AnimationMode.alternateNostril => AlternateNostrilIndicator(
        activeNostril: state.activeNostril,
        progress: uiModel.phaseProgress,
        isHoldPhase: uiModel.isHoldPhase,
        phaseTitle: uiModel.phaseTitle,
        primaryTimer: uiModel.primaryTimer,
        arcColor: uiModel.phaseColor,
        phase: uiModel.phase,
        phaseDuration: uiModel.phaseDuration,
        phaseRemaining: uiModel.phaseRemaining,
        isPaused: uiModel.isPaused,
      ),
      AnimationMode.circle => RepaintBoundary(
        child: SizedBox(
          width: maxRingSize,
          height: maxRingSize,
          child: BreathingCircle(
            progress: uiModel.phaseProgress,
            isHoldPhase: uiModel.isHoldPhase,
            phaseTitle: uiModel.phaseTitle,
            primaryTimer: uiModel.primaryTimer,
            arcColor: uiModel.phaseColor,
            phase: uiModel.phase,
            phaseDuration: uiModel.phaseDuration,
            phaseRemaining: uiModel.phaseRemaining,
            isPaused: uiModel.isPaused,
          ),
        ),
      ),
    };
  }

  Technique? _findTechnique(
    AsyncValue<List<Technique>> techniques,
    String? id,
  ) {
    final list = techniques.asData?.value;
    if (list == null || id == null || id.isEmpty) {
      return null;
    }
    for (final technique in list) {
      if (technique.id == id) {
        return technique;
      }
    }
    return null;
  }

  Future<void> _requestExit({required bool confirm}) async {
    if (_handlingPop) {
      return;
    }
    _handlingPop = true;
    try {
      if (confirm) {
        final confirmed = await _confirmEndEarly();
        if (!mounted || confirmed != true) {
          return;
        }
      }

      if (confirm) {
        await _controller.endEarly();
      } else {
        _controller.stop();
      }
      if (!mounted) {
        return;
      }

      setState(() => _allowPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }
        final popped = await Navigator.of(context).maybePop();
        if (!popped && mounted) {
          context.go('/home');
        }
      });
    } finally {
      _handlingPop = false;
    }
  }

  Future<bool?> _confirmEndEarly() async {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('End session early?'),
          content: Text(
            'This session will stop and won\u2019t count as completed.',
            style: typography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('End'),
            ),
          ],
        );
      },
    );
  }
}
