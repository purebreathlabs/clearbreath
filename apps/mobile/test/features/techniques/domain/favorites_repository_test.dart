import 'dart:io';

import 'package:clearbreath/core/database/app_database.dart';
import 'package:clearbreath/features/techniques/domain/favorites_repository.dart';
import 'package:clearbreath/features/techniques/domain/technique.dart';
import 'package:clearbreath/features/techniques/domain/technique_preset.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Technique buildTechnique(String id) {
    return Technique(
      id: id,
      name: id,
      shortDescription: id,
      animationMode: AnimationMode.circle,
      safety: const TechniqueSafety(requiresAck: false, title: '', body: ''),
      about: const TechniqueAbout(
        what: '',
        how: '',
        bestTime: '',
        benefits: '',
        warnings: '',
      ),
      presets: {
        'beginner': PhasePreset(
          id: 'beginner',
          label: 'Beginner',
          inhaleMs: 4000,
          holdMs: 0,
          exhaleMs: 6000,
          holdAfterExhaleMs: 0,
          recommendedDurationsMinutes: const [2, 5, 10, 20],
        ),
      },
    );
  }

  test('add remove toggle and queries behave as expected', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'clearbreath_favorites_',
    );
    final dbFile = File('${tempDir.path}/favorites.sqlite');

    try {
      final db1 = AppDatabase(NativeDatabase(dbFile));
      final repo1 = FavoritesRepository(db1);

      expect(await repo1.isFavorite('box'), isFalse);
      expect(await repo1.allFavoriteIds(), isEmpty);

      await repo1.add('box');
      expect(await repo1.isFavorite('box'), isTrue);
      expect(await repo1.allFavoriteIds(), equals({'box'}));

      await repo1.add('box');
      expect(await repo1.allFavoriteIds(), equals({'box'}));

      await repo1.toggle('box');
      expect(await repo1.isFavorite('box'), isFalse);
      expect(await repo1.allFavoriteIds(), isEmpty);

      await repo1.toggle('box');
      expect(await repo1.isFavorite('box'), isTrue);
      expect(await repo1.allFavoriteIds(), equals({'box'}));

      await repo1.remove('box');
      expect(await repo1.isFavorite('box'), isFalse);

      await repo1.add('box');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await repo1.add('ujjayi');

      final favoriteIds = await repo1.allFavoriteIds();
      expect(favoriteIds, equals({'box', 'ujjayi'}));

      final favorites = await repo1.allFavorites([
        buildTechnique('box'),
        buildTechnique('ujjayi'),
        buildTechnique('bhramari'),
      ]);
      expect(favorites.length, equals(2));
      expect(
        favorites.map((technique) => technique.id).toSet(),
        equals({'box', 'ujjayi'}),
      );

      await db1.close();

      final db2 = AppDatabase(NativeDatabase(dbFile));
      final repo2 = FavoritesRepository(db2);
      expect(await repo2.allFavoriteIds(), equals({'box', 'ujjayi'}));

      await db2.close();
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
