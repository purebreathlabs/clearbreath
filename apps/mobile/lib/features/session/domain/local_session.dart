import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'active_session_config.dart';
import 'session_state.dart';

@immutable
class LocalSession {
  const LocalSession({
    required this.clientSessionId,
    required this.techniqueId,
    required this.presetId,
    required this.startedAtUtc,
    required this.endedAtUtc,
    required this.timezoneOffsetMinutes,
    required this.durationSecondsActual,
    required this.breathsCompletedEstimated,
    required this.endedEarly,
    required this.syncedToCloud,
    required this.createdAt,
  });

  final String clientSessionId;
  final String techniqueId;
  final String presetId;
  final DateTime startedAtUtc;
  final DateTime endedAtUtc;
  final int timezoneOffsetMinutes;
  final int durationSecondsActual;
  final int breathsCompletedEstimated;
  final bool endedEarly;
  final bool syncedToCloud;
  final DateTime createdAt;

  factory LocalSession.fromCompleted({
    required ActiveSessionConfig? config,
    required SessionState finalState,
    required DateTime startedAtUtc,
    required int timezoneOffsetMinutes,
    required bool endedEarly,
    String Function()? idGenerator,
    DateTime Function()? nowUtc,
  }) {
    final generateId = idGenerator ?? (() => const Uuid().v4());
    final id = generateId();
    final techniqueId =
        config?.technique.id ?? finalState.techniqueId ?? 'unknown';
    final presetId = config?.presetId ?? finalState.presetId ?? 'unknown';

    final elapsedSeconds = finalState.totalElapsed.inSeconds;
    final durationSecondsActual = elapsedSeconds < 0 ? 0 : elapsedSeconds;
    final breaths = finalState.breathsCompleted;
    final breathsCompletedEstimated = breaths < 0 ? 0 : breaths;

    final endedAtUtc = startedAtUtc.toUtc().add(finalState.totalElapsed);
    final createdAt = (nowUtc ?? () => DateTime.now().toUtc())();

    return LocalSession(
      clientSessionId: id,
      techniqueId: techniqueId,
      presetId: presetId,
      startedAtUtc: startedAtUtc.toUtc(),
      endedAtUtc: endedAtUtc.isBefore(startedAtUtc) ? startedAtUtc : endedAtUtc,
      timezoneOffsetMinutes: timezoneOffsetMinutes,
      durationSecondsActual: durationSecondsActual,
      breathsCompletedEstimated: breathsCompletedEstimated,
      endedEarly: endedEarly,
      syncedToCloud: false,
      createdAt: createdAt,
    );
  }
}

final lastCompletedSessionProvider = NotifierProvider<
  LastCompletedSessionController,
  LocalSession?
>(LastCompletedSessionController.new);

class LastCompletedSessionController extends Notifier<LocalSession?> {
  @override
  LocalSession? build() => null;

  void set(LocalSession session) => state = session;

  void clear() => state = null;
}
