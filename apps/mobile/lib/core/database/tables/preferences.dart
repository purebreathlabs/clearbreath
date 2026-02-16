import 'package:drift/drift.dart';

class Preferences extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  BoolColumn get onboardingComplete =>
      boolean().withDefault(const Constant(false))();

  TextColumn get experienceLevel =>
      text().withDefault(const Constant('beginner'))();

  TextColumn get primaryGoal => text().withDefault(const Constant('calm'))();

  TextColumn get primaryGoalsJson =>
      text().withDefault(const Constant('["calm"]'))();

  TextColumn get practiceWindow =>
      text().withDefault(const Constant('morning'))();

  TextColumn get practiceWindowsJson =>
      text().withDefault(const Constant('["varies"]'))();

  IntColumn get sessionLengthMinutes =>
      integer().withDefault(const Constant(5))();

  BoolColumn get hapticsEnabled =>
      boolean().withDefault(const Constant(true))();

  BoolColumn get keepScreenAwake =>
      boolean().withDefault(const Constant(true))();

  IntColumn get reminderTimeMinutes =>
      integer().withDefault(const Constant(22 * 60))();

  TextColumn get displayName => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
