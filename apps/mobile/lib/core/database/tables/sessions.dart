import 'package:drift/drift.dart';

class Sessions extends Table {
  TextColumn get clientSessionId => text()();

  TextColumn get techniqueId => text()();

  TextColumn get presetId => text()();

  DateTimeColumn get startedAtUtc => dateTime()();

  DateTimeColumn get endedAtUtc => dateTime()();

  IntColumn get timezoneOffsetMinutes => integer()();

  IntColumn get durationSecondsActual => integer()();

  IntColumn get breathsCompletedEstimated => integer()();

  BoolColumn get endedEarly => boolean().withDefault(const Constant(false))();

  BoolColumn get syncedToCloud =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {clientSessionId};
}
