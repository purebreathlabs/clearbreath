import 'dart:typed_data';

import 'package:clearbreath/features/session/domain/local_session.dart';
import 'package:clearbreath/features/sync/data/sync_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds correct session ingest payload', () async {
    final session = LocalSession(
      clientSessionId: 's1',
      techniqueId: 'box',
      presetId: 'beginner',
      startedAtUtc: DateTime.utc(2026, 2, 22, 10, 0),
      endedAtUtc: DateTime.utc(2026, 2, 22, 10, 5),
      timezoneOffsetMinutes: 60,
      durationSecondsActual: 300,
      breathsCompletedEstimated: 42,
      endedEarly: false,
      syncedToCloud: false,
      createdAt: DateTime.utc(2026, 2, 22, 10, 5),
    );

    final dio = Dio();
    dio.httpClientAdapter = _Adapter((options) async {
      expect(options.path, equals('/v1/sessions/submit'));
      expect(options.method, equals('POST'));

      final data = options.data;
      expect(data, isA<Map>());
      final map = (data as Map).cast<String, dynamic>();
      final list = map['sessions'] as List;
      expect(list, hasLength(1));

      final item = (list.first as Map).cast<String, dynamic>();
      expect(item['client_session_id'], equals('s1'));
      expect(item['technique_id'], equals('box'));
      expect(item['preset_id'], equals('beginner'));
      expect(
        item['started_at_utc'],
        equals(session.startedAtUtc.toUtc().toIso8601String()),
      );
      expect(
        item['ended_at_utc'],
        equals(session.endedAtUtc.toUtc().toIso8601String()),
      );
      expect(item['timezone_offset_minutes'], equals(60));
      expect(item['breaths_completed_estimated'], equals(42));
      expect(item['ended_early'], isFalse);
      expect(item['duration_seconds_actual'], equals(300));

      return ResponseBody.fromString(
        '''
{
  "accepted_count": 1,
  "duplicate_count": 0,
  "rejected": [],
  "stats_snapshot": {
    "current_streak_days": 1,
    "longest_streak_days": 1,
    "minutes_this_week": 5,
    "minutes_all_time": 5,
    "sessions_all_time": 1,
    "minutes_by_technique": {"box": 5},
    "updated_at_utc": "2026-02-22T10:06:00Z"
  }
}
''',
        200,
        headers: {'content-type': ['application/json']},
      );
    });

    final repo = SyncRepository(dio);
    final resp = await repo.submit([session]);
    expect(resp.acceptedCount, equals(1));
    expect(resp.duplicateCount, equals(0));
    expect(resp.rejected, isEmpty);
    expect(resp.statsSnapshot.minutesAllTime, equals(5));
  });
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

