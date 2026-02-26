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

class XPAward {
  const XPAward({
    required this.amount,
    required this.baseAmount,
    required this.multiplier,
    required this.source,
    required this.dailyCapped,
    required this.newTotalXp,
    required this.newLevel,
    required this.prevLevel,
    required this.leveledUp,
  });

  factory XPAward.fromJson(JsonMap json) {
    return XPAward(
      amount: readInt(json, 'amount'),
      baseAmount: readInt(json, 'base_amount'),
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      source: readString(json, 'source'),
      dailyCapped: json['daily_capped'] == true,
      newTotalXp: readInt(json, 'new_total_xp'),
      newLevel: readInt(json, 'new_level'),
      prevLevel: readInt(json, 'prev_level'),
      leveledUp: json['leveled_up'] == true,
    );
  }

  final int amount;
  final int baseAmount;
  final double multiplier;
  final String source;
  final bool dailyCapped;
  final int newTotalXp;
  final int newLevel;
  final int prevLevel;
  final bool leveledUp;
}

class SessionsIngestResponse {
  const SessionsIngestResponse({
    required this.acceptedCount,
    required this.duplicateCount,
    required this.rejected,
    required this.statsSnapshot,
    required this.xpAwards,
    required this.totalXp,
    required this.currentLevel,
  });

  factory SessionsIngestResponse.fromJson(JsonMap json) {
    final totalXp = readInt(json, 'total_xp');
    final currentLevel = readInt(json, 'current_level');

    final statsMap = readMap(json, 'stats_snapshot');
    statsMap.putIfAbsent('total_xp', () => totalXp);
    statsMap.putIfAbsent('current_level', () => currentLevel);

    return SessionsIngestResponse(
      acceptedCount: readInt(json, 'accepted_count'),
      duplicateCount: readInt(json, 'duplicate_count'),
      rejected: readMapList(
        json,
        'rejected',
      ).map(RejectedSession.fromJson).toList(growable: false),
      statsSnapshot: StatsSnapshot.fromJson(statsMap),
      xpAwards: readMapList(json, 'xp_awards')
          .map(XPAward.fromJson)
          .toList(growable: false),
      totalXp: totalXp,
      currentLevel: currentLevel,
    );
  }

  final int acceptedCount;
  final int duplicateCount;
  final List<RejectedSession> rejected;
  final StatsSnapshot statsSnapshot;
  final List<XPAward> xpAwards;
  final int totalXp;
  final int currentLevel;
}

String _formatUtc(DateTime value) {
  return value.toUtc().toIso8601String();
}
