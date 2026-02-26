import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/providers/app_database_provider.dart';
import '../domain/stats_snapshot.dart';

final statsCacheRepositoryProvider = Provider<StatsCacheRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return StatsCacheRepository(db);
});

class StatsCacheRepository {
  StatsCacheRepository(this._db);

  static const int _rowId = 1;

  final AppDatabase _db;

  Future<StatsSnapshot?> readCached() async {
    final row = await (_db.select(
      _db.statsCache,
    )..where((row) => row.id.equals(_rowId))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _toDomain(row);
  }

  Future<void> writeCache(StatsSnapshot snapshot) async {
    await _db
        .into(_db.statsCache)
        .insertOnConflictUpdate(
          StatsCacheCompanion(
            id: const Value(_rowId),
            currentStreakDays: Value(snapshot.currentStreakDays),
            longestStreakDays: Value(snapshot.longestStreakDays),
            practiceDaysAllTime: Value(snapshot.practiceDaysAllTime),
            minutesThisWeek: Value(snapshot.minutesThisWeek),
            minutesAllTime: Value(snapshot.minutesAllTime),
            sessionsAllTime: Value(snapshot.sessionsAllTime),
            minutesByTechniqueJson: Value(
              jsonEncode(snapshot.minutesByTechnique),
            ),
            longestSessionMinutes: Value(snapshot.longestSessionMinutes),
            favoriteTechniqueId: Value(snapshot.favoriteTechniqueId),
            totalBreathsEstimated: Value(snapshot.totalBreathsEstimated),
            totalXp: Value(snapshot.totalXP),
            currentLevel: Value(snapshot.currentLevel),
            updatedAt: Value(snapshot.updatedAt.toUtc()),
          ),
        );
  }

  StatsSnapshot _toDomain(StatsCacheData row) {
    return StatsSnapshot(
      currentStreakDays: row.currentStreakDays,
      longestStreakDays: row.longestStreakDays,
      practiceDaysAllTime: row.practiceDaysAllTime,
      minutesThisWeek: row.minutesThisWeek,
      minutesAllTime: row.minutesAllTime,
      sessionsAllTime: row.sessionsAllTime,
      minutesByTechnique: _decodeMinutesByTechnique(row.minutesByTechniqueJson),
      longestSessionMinutes: row.longestSessionMinutes,
      favoriteTechniqueId: row.favoriteTechniqueId,
      totalBreathsEstimated: row.totalBreathsEstimated,
      totalXP: row.totalXp,
      currentLevel: row.currentLevel,
      updatedAt: row.updatedAt,
    );
  }

  Map<String, int> _decodeMinutesByTechnique(String encoded) {
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) {
        return const {};
      }
      final result = <String, int>{};
      for (final entry in decoded.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is! String) {
          continue;
        }
        if (value is int) {
          result[key] = value;
          continue;
        }
        if (value is num) {
          result[key] = value.round();
          continue;
        }
      }
      return result;
    } catch (_) {
      return const {};
    }
  }
}
