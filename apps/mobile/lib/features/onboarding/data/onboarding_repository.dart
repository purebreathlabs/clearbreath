import 'dart:convert';

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
            primaryGoalsJson: Value(_encodeEnumSet(answers.primaryGoals)),
            practiceWindowsJson: Value(_encodeEnumSet(answers.practiceWindows)),
            sessionLengthMinutes: Value(answers.sessionLengthMinutes),
            hapticsEnabled: Value(answers.hapticsEnabled),
            reminderTimeMinutes: Value(answers.reminderTimeMinutes),
            displayName: Value(_sanitizeDisplayName(answers.displayName)),
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

    final primaryGoals = _decodeEnumSet(
      PrimaryGoal.values,
      row.primaryGoalsJson,
      fallback: const {PrimaryGoal.calm},
    );

    final practiceWindows = _sanitizePracticeWindows(
      _decodeEnumSet(
        PracticeWindow.values,
        row.practiceWindowsJson,
        fallback: const {PracticeWindow.varies},
      ),
    );

    return OnboardingAnswers(
      experienceLevel: _safeEnum(
        ExperienceLevel.values,
        row.experienceLevel,
        ExperienceLevel.beginner,
      ),
      primaryGoals: primaryGoals,
      practiceWindows: practiceWindows,
      sessionLengthMinutes: row.sessionLengthMinutes,
      hapticsEnabled: row.hapticsEnabled,
      reminderTimeMinutes: row.reminderTimeMinutes,
      displayName: row.displayName,
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

  String _encodeEnumSet<T extends Enum>(Set<T> values) {
    final names = values.map((value) => value.name).toList()..sort();
    return jsonEncode(names);
  }

  Set<T> _decodeEnumSet<T extends Enum>(
    List<T> values,
    String encoded, {
    required Set<T> fallback,
  }) {
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) {
        return fallback;
      }
      final result = <T>{};
      for (final item in decoded) {
        if (item is! String) {
          continue;
        }
        final value = _tryEnum(values, item);
        if (value != null) {
          result.add(value);
        }
      }
      if (result.isEmpty) {
        return fallback;
      }
      return result;
    } catch (_) {
      return fallback;
    }
  }

  T? _tryEnum<T extends Enum>(List<T> values, String name) {
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }

  Set<PracticeWindow> _sanitizePracticeWindows(Set<PracticeWindow> value) {
    if (value.isEmpty) {
      return const {PracticeWindow.varies};
    }
    if (value.contains(PracticeWindow.varies) && value.length > 1) {
      return value.where((window) => window != PracticeWindow.varies).toSet();
    }
    return value;
  }

  String _sanitizeDisplayName(String value) {
    return value.trim();
  }
}
