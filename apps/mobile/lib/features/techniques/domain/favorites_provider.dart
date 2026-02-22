import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/technique_repository.dart';
import 'favorites_repository.dart';
import 'technique.dart';

final favoriteTechniqueIdsProvider = FutureProvider<Set<String>>((ref) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.allFavoriteIds();
});

final favoriteTechniquesProvider = FutureProvider<List<Technique>>((ref) async {
  await ref.watch(favoriteTechniqueIdsProvider.future);
  final techniques = await ref.watch(allTechniquesProvider.future);
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.allFavorites(techniques);
});
