import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/favorites.dart';
import 'tables/leaderboard_cache.dart';
import 'tables/preferences.dart';
import 'tables/safety_ack.dart';
import 'tables/sessions.dart';
import 'tables/stats_cache.dart';
import 'tables/sync_queue.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Preferences,
    Sessions,
    Favorites,
    SafetyAck,
    StatsCache,
    LeaderboardCache,
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  factory AppDatabase.open() {
    return AppDatabase(_openConnection());
  }

  Future<void> deleteAllData() {
    return transaction(() async {
      await delete(preferences).go();
      await delete(sessions).go();
      await delete(favorites).go();
      await delete(safetyAck).go();
      await delete(statsCache).go();
      await delete(leaderboardCache).go();
      await delete(syncQueue).go();
    });
  }

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        try {
          await migrator.addColumn(preferences, preferences.primaryGoalsJson);
        } catch (_) {}
        try {
          await migrator.addColumn(
            preferences,
            preferences.practiceWindowsJson,
          );
        } catch (_) {}
        try {
          await migrator.addColumn(preferences, preferences.displayName);
        } catch (_) {}

        await customStatement(
          "UPDATE preferences SET primary_goals_json = '[\"' || primary_goal || '\"]', "
          "practice_windows_json = '[\"' || practice_window || '\"]' "
          "WHERE onboarding_complete = 1 AND primary_goals_json = '[\"calm\"]';",
        );
      }
      if (from < 3) {
        try {
          await migrator.addColumn(preferences, preferences.introComplete);
        } catch (_) {}
      }
      if (from < 4) {
        await migrator.createTable(sessions);
        await migrator.createTable(favorites);
        await migrator.createTable(safetyAck);
        await migrator.createTable(statsCache);
        await migrator.createTable(leaderboardCache);
        await migrator.createTable(syncQueue);
      }
      if (from < 5) {
        try {
          await migrator.addColumn(preferences, preferences.reminderEnabled);
        } catch (_) {}
        try {
          await migrator.addColumn(
            preferences,
            preferences.streakWarningEnabled,
          );
        } catch (_) {}
      }
      if (from < 6) {
        try {
          await migrator.addColumn(
            preferences,
            preferences.firstSessionCompleted,
          );
        } catch (_) {}
        try {
          await migrator.addColumn(
            preferences,
            preferences.notificationPermissionAsked,
          );
        } catch (_) {}
      }
      if (from < 7) {
        try {
          await migrator.addColumn(statsCache, statsCache.totalXp);
        } catch (_) {}
        try {
          await migrator.addColumn(statsCache, statsCache.currentLevel);
        } catch (_) {}
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'clearbreath.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
