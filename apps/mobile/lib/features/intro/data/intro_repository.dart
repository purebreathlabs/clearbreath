import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class IntroRepository {
  IntroRepository(this._db);

  static const int _rowId = 1;

  final AppDatabase _db;

  Future<bool> isIntroComplete() async {
    final row = await (_db.select(
      _db.preferences,
    )..where((row) => row.id.equals(_rowId))).getSingleOrNull();
    return row?.introComplete ?? false;
  }

  Future<void> setIntroComplete() async {
    final updated = await (_db.update(
      _db.preferences,
    )..where((row) => row.id.equals(_rowId))).write(
      PreferencesCompanion(introComplete: const Value(true)),
    );
    if (updated > 0) {
      return;
    }

    await _db.into(_db.preferences).insert(
      PreferencesCompanion(
        id: const Value(_rowId),
        introComplete: const Value(true),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }
}
