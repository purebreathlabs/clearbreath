import 'package:drift/drift.dart';

import '../domain/onboarding_answers.dart';
import '../../../core/database/app_database.dart';

class OnboardingRepository {
  OnboardingRepository(this._db);

  static const int _rowId = 1;

  final AppDatabase _db;

  Future<bool> isOnboardingComplete() async {
    final row = await (_db.select(
      _db.preferences,
    )..where((row) => row.id.equals(_rowId))).getSingleOrNull();
    return row?.onboardingComplete ?? false;
  }

  Future<void> setOnboardingComplete(OnboardingAnswers answers) async {
    await _db
        .into(_db.preferences)
        .insertOnConflictUpdate(
          PreferencesCompanion(
            id: const Value(_rowId),
            onboardingComplete: const Value(true),
            experienceLevel: Value(answers.experienceLevel.name),
            primaryGoal: Value(answers.primaryGoal.name),
            practiceWindow: Value(answers.practiceWindow.name),
            sessionLengthMinutes: Value(answers.sessionLengthMinutes),
            hapticsEnabled: Value(answers.hapticsEnabled),
            keepScreenAwake: Value(answers.keepScreenAwake),
            reminderTimeMinutes: Value(answers.reminderTimeMinutes),
          ),
        );
  }

  Future<OnboardingAnswers?> readAnswers() async {
    final row = await (_db.select(
      _db.preferences,
    )..where((row) => row.id.equals(_rowId))).getSingleOrNull();
    if (row == null) {
      return null;
    }

    return OnboardingAnswers(
      experienceLevel: _safeEnum(
        ExperienceLevel.values,
        row.experienceLevel,
        ExperienceLevel.beginner,
      ),
      primaryGoal: _safeEnum(
        PrimaryGoal.values,
        row.primaryGoal,
        PrimaryGoal.calm,
      ),
      practiceWindow: _safeEnum(
        PracticeWindow.values,
        row.practiceWindow,
        PracticeWindow.morning,
      ),
      sessionLengthMinutes: row.sessionLengthMinutes,
      hapticsEnabled: row.hapticsEnabled,
      keepScreenAwake: row.keepScreenAwake,
      reminderTimeMinutes: row.reminderTimeMinutes,
    );
  }

  T _safeEnum<T extends Enum>(List<T> values, String name, T fallback) {
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return fallback;
  }
}
