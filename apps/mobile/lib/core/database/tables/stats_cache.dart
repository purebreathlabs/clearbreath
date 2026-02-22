import 'package:drift/drift.dart';

class StatsCache extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  IntColumn get currentStreakDays => integer().withDefault(const Constant(0))();

  IntColumn get longestStreakDays => integer().withDefault(const Constant(0))();

  IntColumn get minutesThisWeek => integer().withDefault(const Constant(0))();

  IntColumn get minutesAllTime => integer().withDefault(const Constant(0))();

  IntColumn get sessionsAllTime => integer().withDefault(const Constant(0))();

  TextColumn get minutesByTechniqueJson =>
      text().withDefault(const Constant('{}'))();

  IntColumn get longestSessionMinutes =>
      integer().withDefault(const Constant(0))();

  TextColumn get favoriteTechniqueId => text().nullable()();

  IntColumn get totalBreathsEstimated =>
      integer().withDefault(const Constant(0))();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
