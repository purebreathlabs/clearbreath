import 'package:drift/drift.dart';

class LeaderboardCache extends Table {
  TextColumn get ranking => text()();

  TextColumn get rowsJson => text()();

  DateTimeColumn get generatedAtUtc => dateTime()();

  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {ranking};
}
