import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/providers/app_database_provider.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SettingsRepository(db);
});

class SettingsRepository {
  SettingsRepository(this._db);

  static const int _rowId = 1;

  final AppDatabase _db;

  Future<void> setSessionLengthMinutes(int minutes) async {
    await _db
        .into(_db.preferences)
        .insertOnConflictUpdate(
          PreferencesCompanion(
            id: const Value(_rowId),
            sessionLengthMinutes: Value(minutes),
          ),
        );
  }

  Future<void> setHapticsEnabled(bool value) async {
    await _db
        .into(_db.preferences)
        .insertOnConflictUpdate(
          PreferencesCompanion(
            id: const Value(_rowId),
            hapticsEnabled: Value(value),
          ),
        );
  }

  Future<void> setKeepScreenAwake(bool value) async {
    await _db
        .into(_db.preferences)
        .insertOnConflictUpdate(
          PreferencesCompanion(
            id: const Value(_rowId),
            keepScreenAwake: Value(value),
          ),
        );
  }

  Future<void> setReminderEnabled(bool value) async {
    await _db
        .into(_db.preferences)
        .insertOnConflictUpdate(
          PreferencesCompanion(
            id: const Value(_rowId),
            reminderEnabled: Value(value),
          ),
        );
  }

  Future<void> setReminderTimeMinutes(int value) async {
    await _db
        .into(_db.preferences)
        .insertOnConflictUpdate(
          PreferencesCompanion(
            id: const Value(_rowId),
            reminderTimeMinutes: Value(value),
          ),
        );
  }

  Future<void> setStreakWarningEnabled(bool value) async {
    await _db
        .into(_db.preferences)
        .insertOnConflictUpdate(
          PreferencesCompanion(
            id: const Value(_rowId),
            streakWarningEnabled: Value(value),
          ),
        );
  }

  Future<void> setDisplayName(String value) async {
    await _db
        .into(_db.preferences)
        .insertOnConflictUpdate(
          PreferencesCompanion(
            id: const Value(_rowId),
            displayName: Value(value.trim()),
          ),
        );
  }
}
