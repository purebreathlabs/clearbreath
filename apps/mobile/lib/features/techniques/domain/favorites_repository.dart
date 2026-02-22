import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/providers/app_database_provider.dart';
import 'technique.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return FavoritesRepository(db);
});

class FavoritesRepository {
  FavoritesRepository(this._db);

  final AppDatabase _db;

  Future<void> add(String techniqueId) async {
    await _db.into(_db.favorites).insertOnConflictUpdate(
          FavoritesCompanion(
            techniqueId: Value(techniqueId),
            addedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  Future<void> remove(String techniqueId) async {
    await (_db.delete(_db.favorites)
          ..where((row) => row.techniqueId.equals(techniqueId)))
        .go();
  }

  Future<void> toggle(String techniqueId) async {
    final deleted = await (_db.delete(_db.favorites)
          ..where((row) => row.techniqueId.equals(techniqueId)))
        .go();
    if (deleted > 0) {
      return;
    }
    await add(techniqueId);
  }

  Future<bool> isFavorite(String techniqueId) async {
    final row = await (_db.select(_db.favorites)
          ..where((row) => row.techniqueId.equals(techniqueId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<Set<String>> allFavoriteIds() async {
    final rows = await _db.select(_db.favorites).get();
    return rows.map((row) => row.techniqueId).toSet();
  }

  Future<List<Technique>> allFavorites(List<Technique> allTechniques) async {
    final favorites =
        await (_db.select(_db.favorites)
              ..orderBy([
                (row) => OrderingTerm(
                  expression: row.addedAt,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();

    final byId = <String, Technique>{};
    for (final technique in allTechniques) {
      byId[technique.id] = technique;
    }

    final result = <Technique>[];
    for (final favorite in favorites) {
      final technique = byId[favorite.techniqueId];
      if (technique != null) {
        result.add(technique);
      }
    }
    return result;
  }
}
