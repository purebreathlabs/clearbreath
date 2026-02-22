import 'dart:io';

import 'package:clearbreath/core/database/app_database.dart';
import 'package:clearbreath/features/session/data/session_repository.dart';
import 'package:clearbreath/features/session/domain/local_session.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LocalSession buildSession({
    required String id,
    required DateTime startedAtUtc,
    required int timezoneOffsetMinutes,
    required int durationSecondsActual,
    required bool syncedToCloud,
  }) {
    final endedAtUtc = startedAtUtc.toUtc().add(
      Duration(seconds: durationSecondsActual),
    );
    return LocalSession(
      clientSessionId: id,
      techniqueId: 'box',
      presetId: 'beginner',
      startedAtUtc: startedAtUtc.toUtc(),
      endedAtUtc: endedAtUtc,
      timezoneOffsetMinutes: timezoneOffsetMinutes,
      durationSecondsActual: durationSecondsActual,
      breathsCompletedEstimated: 10,
      endedEarly: false,
      syncedToCloud: syncedToCloud,
      createdAt: endedAtUtc,
    );
  }

  test('insert queries and sync flags behave as expected', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'clearbreath_sessions_',
    );
    final dbFile = File('${tempDir.path}/sessions.sqlite');

    try {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SessionRepository(db);

      final s1 = buildSession(
        id: 's1',
        startedAtUtc: DateTime.utc(2026, 2, 20, 10),
        timezoneOffsetMinutes: 0,
        durationSecondsActual: 300,
        syncedToCloud: false,
      );
      final s2 = buildSession(
        id: 's2',
        startedAtUtc: DateTime.utc(2026, 2, 21, 23, 30),
        timezoneOffsetMinutes: 60,
        durationSecondsActual: 60,
        syncedToCloud: false,
      );
      final s3 = buildSession(
        id: 's3',
        startedAtUtc: DateTime.utc(2026, 2, 21, 1),
        timezoneOffsetMinutes: -480,
        durationSecondsActual: 119,
        syncedToCloud: false,
      );

      await repo.insert(s1);
      await repo.insert(s2);
      await repo.insert(s3);

      final all = await repo.all();
      expect(all.map((s) => s.clientSessionId), equals(['s2', 's3', 's1']));

      final range = await repo.forDateRange(
        DateTime.utc(2026, 2, 21),
        DateTime.utc(2026, 2, 22),
      );
      expect(range.map((s) => s.clientSessionId), equals(['s3', 's2']));

      final unsynced = await repo.unsynced();
      expect(
        unsynced.map((s) => s.clientSessionId).toSet(),
        equals({'s1', 's2', 's3'}),
      );

      await repo.markSynced(['s1', 's2']);
      final remaining = await repo.unsynced();
      expect(remaining.map((s) => s.clientSessionId), equals(['s3']));

      final minutes = await repo.minutesByLocalDay();
      expect(minutes[DateTime.utc(2026, 2, 20)], equals(6));
      expect(minutes[DateTime.utc(2026, 2, 22)], equals(1));

      await db.close();
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
