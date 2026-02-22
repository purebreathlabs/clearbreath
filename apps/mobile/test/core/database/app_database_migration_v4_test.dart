import 'dart:io';

import 'package:clearbreath/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('migrates v3 database to v4 with new tables', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'clearbreath_db_migration_',
    );
    final dbFile = File('${tempDir.path}/prefs.sqlite');

    final sqlite = sqlite3.open(dbFile.path);
    try {
      sqlite.execute('PRAGMA user_version = 3;');
      sqlite.execute('''
CREATE TABLE preferences (
  id INTEGER NOT NULL PRIMARY KEY,
  intro_complete INTEGER NOT NULL DEFAULT 0,
  onboarding_complete INTEGER NOT NULL DEFAULT 0,
  experience_level TEXT NOT NULL DEFAULT 'beginner',
  primary_goal TEXT NOT NULL DEFAULT 'calm',
  primary_goals_json TEXT NOT NULL DEFAULT '["calm"]',
  practice_window TEXT NOT NULL DEFAULT 'morning',
  practice_windows_json TEXT NOT NULL DEFAULT '["varies"]',
  session_length_minutes INTEGER NOT NULL DEFAULT 5,
  haptics_enabled INTEGER NOT NULL DEFAULT 1,
  keep_screen_awake INTEGER NOT NULL DEFAULT 1,
  reminder_time_minutes INTEGER NOT NULL DEFAULT 1320,
  display_name TEXT NOT NULL DEFAULT ''
);
''');

      sqlite.execute('''
INSERT INTO preferences (
  id,
  intro_complete,
  onboarding_complete,
  experience_level,
  primary_goal,
  primary_goals_json,
  practice_window,
  practice_windows_json,
  session_length_minutes,
  haptics_enabled,
  keep_screen_awake,
  reminder_time_minutes,
  display_name
) VALUES (1, 1, 0, 'beginner', 'calm', '["calm"]', 'morning', '["morning"]', 5, 1, 1, 1320, '');
''');
    } finally {
      sqlite.dispose();
    }

    try {
      final driftDb = AppDatabase(NativeDatabase(dbFile));

      await driftDb.select(driftDb.preferences).get();
      await driftDb.select(driftDb.sessions).get();
      await driftDb.select(driftDb.favorites).get();
      await driftDb.select(driftDb.safetyAck).get();
      await driftDb.select(driftDb.statsCache).get();
      await driftDb.select(driftDb.leaderboardCache).get();
      await driftDb.select(driftDb.syncQueue).get();

      final prefsRow = await driftDb.select(driftDb.preferences).getSingle();
      expect(prefsRow.introComplete, isTrue);
      expect(prefsRow.onboardingComplete, isFalse);

      await driftDb.close();
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
