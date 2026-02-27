import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/providers/app_database_provider.dart';
import '../domain/local_session.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SessionRepository(db);
});

class SessionRepository {
  SessionRepository(this._db);

  final AppDatabase _db;

  Future<void> insert(LocalSession session) async {
    await _db
        .into(_db.sessions)
        .insertOnConflictUpdate(
          SessionsCompanion(
            clientSessionId: Value(session.clientSessionId),
            techniqueId: Value(session.techniqueId),
            presetId: Value(session.presetId),
            startedAtUtc: Value(session.startedAtUtc),
            endedAtUtc: Value(session.endedAtUtc),
            timezoneOffsetMinutes: Value(session.timezoneOffsetMinutes),
            durationSecondsActual: Value(session.durationSecondsActual),
            breathsCompletedEstimated: Value(session.breathsCompletedEstimated),
            endedEarly: Value(session.endedEarly),
            syncedToCloud: Value(session.syncedToCloud),
            createdAt: Value(session.createdAt),
          ),
        );
  }

  Future<int> completedSessionsCount() async {
    final count = _db.sessions.clientSessionId.count();
    final query = _db.selectOnly(_db.sessions)
      ..addColumns([count])
      ..where(_db.sessions.endedEarly.equals(false));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<List<LocalSession>> all() async {
    final rows =
        await (_db.select(_db.sessions)..orderBy([
              (row) => OrderingTerm(
                expression: row.startedAtUtc,
                mode: OrderingMode.desc,
              ),
            ]))
            .get();
    return rows.map(_toDomain).toList(growable: false);
  }

  Future<List<LocalSession>> unsynced() async {
    final rows =
        await (_db.select(_db.sessions)
              ..where((row) => row.syncedToCloud.equals(false))
              ..orderBy([
                (row) => OrderingTerm(
                  expression: row.startedAtUtc,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();
    return rows.map(_toDomain).toList(growable: false);
  }

  Future<void> markSynced(List<String> clientSessionIds) async {
    if (clientSessionIds.isEmpty) {
      return;
    }
    await (_db.update(_db.sessions)
          ..where((row) => row.clientSessionId.isIn(clientSessionIds)))
        .write(const SessionsCompanion(syncedToCloud: Value(true)));
  }

  Future<List<LocalSession>> forDateRange(
    DateTime startUtc,
    DateTime endUtc,
  ) async {
    final rows =
        await (_db.select(_db.sessions)
              ..where(
                (row) =>
                    row.startedAtUtc.isBiggerOrEqualValue(startUtc.toUtc()) &
                    row.startedAtUtc.isSmallerThanValue(endUtc.toUtc()),
              )
              ..orderBy([
                (row) => OrderingTerm(
                  expression: row.startedAtUtc,
                  mode: OrderingMode.asc,
                ),
              ]))
            .get();
    return rows.map(_toDomain).toList(growable: false);
  }

  Future<Map<DateTime, int>> minutesByLocalDay() async {
    final rows = await _db.select(_db.sessions).get();

    final secondsByDay = <DateTime, int>{};
    for (final row in rows) {
      final localStart = row.startedAtUtc.add(
        Duration(minutes: row.timezoneOffsetMinutes),
      );
      final day = DateTime.utc(
        localStart.year,
        localStart.month,
        localStart.day,
      );
      secondsByDay[day] = (secondsByDay[day] ?? 0) + row.durationSecondsActual;
    }

    final minutesByDay = <DateTime, int>{};
    for (final entry in secondsByDay.entries) {
      minutesByDay[entry.key] = entry.value ~/ 60;
    }
    return minutesByDay;
  }

  LocalSession _toDomain(Session row) {
    return LocalSession(
      clientSessionId: row.clientSessionId,
      techniqueId: row.techniqueId,
      presetId: row.presetId,
      startedAtUtc: row.startedAtUtc,
      endedAtUtc: row.endedAtUtc,
      timezoneOffsetMinutes: row.timezoneOffsetMinutes,
      durationSecondsActual: row.durationSecondsActual,
      breathsCompletedEstimated: row.breathsCompletedEstimated,
      endedEarly: row.endedEarly,
      syncedToCloud: row.syncedToCloud,
      createdAt: row.createdAt,
    );
  }
}
