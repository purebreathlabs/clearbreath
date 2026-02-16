import 'dart:io';

import 'package:clearbreath/core/database/app_database.dart';
import 'package:clearbreath/features/onboarding/data/onboarding_repository.dart';
import 'package:clearbreath/features/onboarding/domain/onboarding_answers.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('migrates v1 onboarding answers to v2 columns', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'clearbreath_migration_',
    );
    final dbFile = File('${tempDir.path}/prefs.sqlite');

    final sqlite = sqlite3.open(dbFile.path);
    try {
      sqlite.execute('PRAGMA user_version = 1;');
      sqlite.execute('''
CREATE TABLE preferences (
  id INTEGER NOT NULL PRIMARY KEY,
  onboarding_complete INTEGER NOT NULL DEFAULT 0,
  experience_level TEXT NOT NULL DEFAULT 'beginner',
  primary_goal TEXT NOT NULL DEFAULT 'calm',
  practice_window TEXT NOT NULL DEFAULT 'morning',
  session_length_minutes INTEGER NOT NULL DEFAULT 5,
  haptics_enabled INTEGER NOT NULL DEFAULT 1,
  keep_screen_awake INTEGER NOT NULL DEFAULT 1,
  reminder_time_minutes INTEGER NOT NULL DEFAULT 1320
);
''');

      sqlite.execute('''
INSERT INTO preferences (
  id,
  onboarding_complete,
  experience_level,
  primary_goal,
  practice_window,
  session_length_minutes,
  haptics_enabled,
  keep_screen_awake,
  reminder_time_minutes
) VALUES (1, 1, 'intermediate', 'sleep', 'evening', 10, 0, 1, 1290);
''');
    } finally {
      sqlite.dispose();
    }

    try {
      final driftDb = AppDatabase(NativeDatabase(dbFile));
      final repo = OnboardingRepository(driftDb);

      expect(await repo.isOnboardingComplete(), isTrue);
      final restored = await repo.readAnswers();
      expect(restored, isNotNull);
      expect(restored!.experienceLevel, ExperienceLevel.intermediate);
      expect(restored.primaryGoals, unorderedEquals([PrimaryGoal.sleep]));
      expect(
        restored.practiceWindows,
        unorderedEquals([PracticeWindow.evening]),
      );
      expect(restored.sessionLengthMinutes, 10);
      expect(restored.hapticsEnabled, isFalse);
      expect(restored.reminderTimeMinutes, 21 * 60 + 30);
      expect(restored.displayName, '');

      await driftDb.close();
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
