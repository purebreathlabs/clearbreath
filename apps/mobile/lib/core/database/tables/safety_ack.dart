import 'package:drift/drift.dart';

class SafetyAck extends Table {
  TextColumn get techniqueId => text()();

  DateTimeColumn get acknowledgedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {techniqueId};
}
