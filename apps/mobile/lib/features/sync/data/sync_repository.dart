import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/models/session_models.dart';
import '../../session/domain/local_session.dart';

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return SyncRepository(dio);
});

class SyncRepository {
  SyncRepository(this._dio);

  final Dio _dio;

  Future<SessionsIngestResponse> submit(List<LocalSession> sessions) async {
    return _ingest('/v1/sessions/submit', sessions);
  }

  Future<SessionsIngestResponse> sync(List<LocalSession> sessions) async {
    return _ingest('/v1/sessions/sync', sessions);
  }

  Future<SessionsIngestResponse> _ingest(
    String path,
    List<LocalSession> sessions,
  ) async {
    final payloads = sessions
        .map(
          (s) => SessionSubmitPayload(
            clientSessionId: s.clientSessionId,
            techniqueId: s.techniqueId,
            presetId: s.presetId,
            startedAtUtc: s.startedAtUtc,
            endedAtUtc: s.endedAtUtc,
            timezoneOffsetMinutes: s.timezoneOffsetMinutes,
            breathsCompletedEstimated: s.breathsCompletedEstimated,
            endedEarly: s.endedEarly,
            durationSecondsActual: s.durationSecondsActual,
          ),
        )
        .toList(growable: false);

    final resp = await _dio.post<dynamic>(
      path,
      data: SessionsSubmitRequest(sessions: payloads).toJson(),
    );

    final data = resp.data;
    if (data is! Map) {
      throw FormatException('Invalid sessions ingest response.');
    }
    return SessionsIngestResponse.fromJson(data.cast<String, dynamic>());
  }
}

