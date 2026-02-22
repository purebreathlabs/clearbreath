import 'package:drift/drift.dart';

class Favorites extends Table {
  TextColumn get techniqueId => text()();

  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {techniqueId};
}
