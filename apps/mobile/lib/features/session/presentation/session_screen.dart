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
import 'widgets/alternate_nostril_indicator.dart';
import 'widgets/breathing_circle.dart';
import 'widgets/metronome_pulse.dart';
import 'widgets/session_audio_controls.dart';
import 'widgets/session_phase_label.dart';
import 'widgets/session_timer_display.dart';

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

    final animationMode =
        technique?.animationMode ?? _fallbackAnimationMode(state.techniqueId);
    final bpm = preset is BpmRoundsPreset ? preset.bpm : 60;
    final phaseDuration = _phaseDurationFor(state, preset);

    final phaseWidget = switch (animationMode) {
      AnimationMode.metronome => MetronomePulse(
        bpm: bpm,
        phase: state.phase,
        phaseRemaining: state.phaseRemaining,
        phaseDuration: phaseDuration,
        currentRound: state.currentRound,
        totalRounds: state.totalRounds,
      ),
      AnimationMode.alternateNostril => AlternateNostrilIndicator(
        activeNostril: state.activeNostril,
        phase: state.phase,
        phaseRemaining: state.phaseRemaining,
        phaseDuration: phaseDuration,
      ),
      AnimationMode.circle => BreathingCircle(
        phase: state.phase,
        phaseRemaining: state.phaseRemaining,
        phaseDuration: phaseDuration,
      ),
    };

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
        appBar: AppBar(title: Text(technique?.name ?? 'Session')),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (animationMode == AnimationMode.metronome)
                      SessionPhaseLabel(phase: state.phase),
                    if (animationMode == AnimationMode.metronome)
                      SizedBox(height: spacing.lg),
                    Expanded(child: Center(child: phaseWidget)),
                    SizedBox(height: spacing.xl),
                    SessionTimerDisplay(
                      phaseRemaining: state.phaseRemaining,
                      totalElapsed: state.totalElapsed,
                      currentRound: state.currentRound,
                      totalRounds: state.totalRounds,
                    ),
                    SizedBox(height: spacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: state.canResume
                                ? _controller.resume
                                : state.canPause
                                ? _controller.pause
                                : null,
                            child: Text(
                              state.canResume
                                  ? 'Resume'
                                  : state.canPause
                                  ? 'Pause'
                                  : 'Pause',
                            ),
                          ),
                        ),
                        SizedBox(width: spacing.md),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: state.canStop
                                ? () =>
                                      _requestExit(confirm: !state.isCompleted)
                                : null,
                            child: const Text('Stop'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: const SessionAudioControls(),
                ),
                if (techniques.hasError)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: spacing.lg),
                      child: Text(
                        'Could not load technique visuals.',
                        style: typography.bodyMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
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

  AnimationMode _fallbackAnimationMode(String? techniqueId) {
    return switch (techniqueId) {
      'kapalbhati' || 'bhastrika' => AnimationMode.metronome,
      'anulom_vilom' => AnimationMode.alternateNostril,
      _ => AnimationMode.circle,
    };
  }

  Duration _phaseDurationFor(SessionState state, TechniquePreset? preset) {
    if (state.phase == SessionPhase.countdown) {
      return const Duration(seconds: 3);
    }

    if (preset is PhasePreset) {
      return switch (state.phase) {
        SessionPhase.inhale => Duration(milliseconds: preset.inhaleMs),
        SessionPhase.hold => Duration(milliseconds: preset.holdMs),
        SessionPhase.exhale => Duration(milliseconds: preset.exhaleMs),
        SessionPhase.holdAfterExhale => Duration(
          milliseconds: preset.holdAfterExhaleMs,
        ),
        _ => const Duration(seconds: 1),
      };
    }

    if (preset is BpmRoundsPreset) {
      return switch (state.phase) {
        SessionPhase.round => Duration(seconds: preset.roundSeconds),
        SessionPhase.rest => Duration(seconds: preset.restSeconds),
        _ => const Duration(seconds: 1),
      };
    }

    return const Duration(seconds: 1);
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
            'This session will stop and won’t count as completed.',
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
