import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/preferences.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Preferences])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  factory AppDatabase.open() {
    return AppDatabase(_openConnection());
  }

  @override
  int get schemaVersion => 2;

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
