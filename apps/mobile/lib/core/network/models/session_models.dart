import 'json_parsing.dart';
import 'stats_models.dart';

class SessionSubmitPayload {
  const SessionSubmitPayload({
    required this.clientSessionId,
    required this.techniqueId,
    required this.presetId,
    required this.startedAtUtc,
    required this.endedAtUtc,
    required this.timezoneOffsetMinutes,
    required this.breathsCompletedEstimated,
    required this.endedEarly,
    required this.durationSecondsActual,
  });

  final String clientSessionId;
  final String techniqueId;
  final String presetId;
  final DateTime startedAtUtc;
  final DateTime endedAtUtc;
  final int timezoneOffsetMinutes;
  final int breathsCompletedEstimated;
  final bool endedEarly;
  final int durationSecondsActual;

  JsonMap toJson() {
    return {
      'client_session_id': clientSessionId,
      'technique_id': techniqueId,
      'preset_id': presetId,
      'started_at_utc': _formatUtc(startedAtUtc),
      'ended_at_utc': _formatUtc(endedAtUtc),
      'timezone_offset_minutes': timezoneOffsetMinutes,
      'breaths_completed_estimated': breathsCompletedEstimated,
      'ended_early': endedEarly,
      'duration_seconds_actual': durationSecondsActual,
    };
  }
}

class SessionsSubmitRequest {
  const SessionsSubmitRequest({required this.sessions});

  final List<SessionSubmitPayload> sessions;

  JsonMap toJson() {
    return {
      'sessions': sessions.map((s) => s.toJson()).toList(growable: false),
    };
  }
}

class RejectedSession {
  const RejectedSession({
    required this.clientSessionId,
    required this.code,
    required this.message,
  });

  factory RejectedSession.fromJson(JsonMap json) {
    return RejectedSession(
      clientSessionId: readString(json, 'client_session_id'),
      code: readString(json, 'code'),
      message: readString(json, 'message'),
    );
  }

  final String clientSessionId;
  final String code;
  final String message;
}

class SessionsIngestResponse {
  const SessionsIngestResponse({
    required this.acceptedCount,
    required this.duplicateCount,
    required this.rejected,
    required this.statsSnapshot,
  });

  factory SessionsIngestResponse.fromJson(JsonMap json) {
    return SessionsIngestResponse(
      acceptedCount: readInt(json, 'accepted_count'),
      duplicateCount: readInt(json, 'duplicate_count'),
      rejected: readMapList(
        json,
        'rejected',
      ).map(RejectedSession.fromJson).toList(growable: false),
      statsSnapshot: StatsSnapshot.fromJson(readMap(json, 'stats_snapshot')),
    );
  }

  final int acceptedCount;
  final int duplicateCount;
  final List<RejectedSession> rejected;
  final StatsSnapshot statsSnapshot;
}

String _formatUtc(DateTime value) {
  return value.toUtc().toIso8601String();
}
