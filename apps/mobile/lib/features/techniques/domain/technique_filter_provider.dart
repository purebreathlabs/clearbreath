import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/domain/onboarding_answers.dart';
import '../data/technique_repository.dart';
import 'technique.dart';

@immutable
class TechniqueFilterState {
  const TechniqueFilterState({
    this.selectedGoals = const {},
    this.searchQuery = '',
  });

  final Set<PrimaryGoal> selectedGoals;
  final String searchQuery;

  TechniqueFilterState copyWith({
    Set<PrimaryGoal>? selectedGoals,
    String? searchQuery,
  }) {
    return TechniqueFilterState(
      selectedGoals: selectedGoals ?? this.selectedGoals,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class TechniqueFilterController extends Notifier<TechniqueFilterState> {
  @override
  TechniqueFilterState build() => const TechniqueFilterState();

  void update(TechniqueFilterState newState) => state = newState;

  void reset() => state = const TechniqueFilterState();
}

final techniqueFilterProvider =
    NotifierProvider<TechniqueFilterController, TechniqueFilterState>(
      TechniqueFilterController.new,
    );

final filteredTechniquesProvider = Provider<AsyncValue<List<Technique>>>((ref) {
  final techniques = ref.watch(allTechniquesProvider);
  final filter = ref.watch(techniqueFilterProvider);

  return techniques.whenData((items) {
    var filtered = items;

    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        return t.name.toLowerCase().contains(query) ||
            t.shortDescription.toLowerCase().contains(query);
      }).toList();
    }

    if (filter.selectedGoals.isNotEmpty) {
      filtered = filtered.where((t) {
        return t.goals.intersection(filter.selectedGoals).isNotEmpty;
      }).toList();
    }

    return filtered;
  });
});
