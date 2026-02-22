import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/providers/app_database_provider.dart';

final safetyAckRepositoryProvider = Provider<SafetyAcknowledgementRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SafetyAcknowledgementRepository(db);
});

final safetyAcksProvider = FutureProvider<Set<String>>((ref) async {
  final repository = ref.watch(safetyAckRepositoryProvider);
  return repository.allAcknowledged();
});

class SafetyAcknowledgementRepository {
  SafetyAcknowledgementRepository(this._db);

  final AppDatabase _db;

  Future<bool> isAcknowledged(String techniqueId) async {
    final row = await (_db.select(
      _db.safetyAck,
    )..where((row) => row.techniqueId.equals(techniqueId))).getSingleOrNull();
    return row != null;
  }

  Future<void> acknowledge(String techniqueId) async {
    await _db.into(_db.safetyAck).insertOnConflictUpdate(
      SafetyAckCompanion(
        techniqueId: Value(techniqueId),
        acknowledgedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<Set<String>> allAcknowledged() async {
    final rows = await _db.select(_db.safetyAck).get();
    return rows.map((row) => row.techniqueId).toSet();
  }
}
