import 'package:clearbreath/features/onboarding/domain/onboarding_answers.dart';
import 'package:clearbreath/features/techniques/data/technique_repository.dart';
import 'package:clearbreath/features/techniques/domain/technique.dart';
import 'package:clearbreath/features/techniques/domain/technique_filter_provider.dart';
import 'package:clearbreath/features/techniques/domain/technique_preset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Technique _buildTechnique({
  required String id,
  required String name,
  required String shortDescription,
  Set<PrimaryGoal> goals = const {PrimaryGoal.calm},
}) {
  return Technique(
    id: id,
    name: name,
    shortDescription: shortDescription,
    animationMode: AnimationMode.circle,
    goals: goals,
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
        recommendedDurationsMinutes: const [2, 5],
      ),
    },
  );
}

void main() {
  final techniques = [
    _buildTechnique(
      id: 'box',
      name: 'Box Breathing',
      shortDescription: 'A balanced four-part breath.',
      goals: {PrimaryGoal.calm, PrimaryGoal.focus},
    ),
    _buildTechnique(
      id: 'kapalbhati',
      name: 'Kapalbhati',
      shortDescription: 'Energizing skull-shining breath.',
      goals: {PrimaryGoal.energy},
    ),
    _buildTechnique(
      id: 'bhramari',
      name: 'Bhramari',
      shortDescription: 'Humming bee breath for calm.',
      goals: {PrimaryGoal.calm, PrimaryGoal.sleep},
    ),
  ];

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        allTechniquesProvider.overrideWith((ref) async => techniques),
      ],
    );
  }

  test('no filter returns all techniques', () async {
    final container = buildContainer();
    await container.read(allTechniquesProvider.future);
    final result = container.read(filteredTechniquesProvider);
    expect(result.value?.length, 3);
  });

  test('search filters by name', () async {
    final container = buildContainer();
    await container.read(allTechniquesProvider.future);
    container
        .read(techniqueFilterProvider.notifier)
        .update(const TechniqueFilterState(searchQuery: 'box'));
    final result = container.read(filteredTechniquesProvider);
    expect(result.value?.length, 1);
    expect(result.value?.first.id, 'box');
  });

  test('search filters by description', () async {
    final container = buildContainer();
    await container.read(allTechniquesProvider.future);
    container
        .read(techniqueFilterProvider.notifier)
        .update(const TechniqueFilterState(searchQuery: 'humming'));
    final result = container.read(filteredTechniquesProvider);
    expect(result.value?.length, 1);
    expect(result.value?.first.id, 'bhramari');
  });

  test('goal filter returns matching techniques', () async {
    final container = buildContainer();
    await container.read(allTechniquesProvider.future);
    container
        .read(techniqueFilterProvider.notifier)
        .update(
          const TechniqueFilterState(selectedGoals: {PrimaryGoal.energy}),
        );
    final result = container.read(filteredTechniquesProvider);
    expect(result.value?.length, 1);
    expect(result.value?.first.id, 'kapalbhati');
  });

  test('goal filter with multiple goals', () async {
    final container = buildContainer();
    await container.read(allTechniquesProvider.future);
    container
        .read(techniqueFilterProvider.notifier)
        .update(const TechniqueFilterState(selectedGoals: {PrimaryGoal.calm}));
    final result = container.read(filteredTechniquesProvider);
    expect(result.value?.length, 2);
  });

  test('combined search + goal filter', () async {
    final container = buildContainer();
    await container.read(allTechniquesProvider.future);
    container
        .read(techniqueFilterProvider.notifier)
        .update(
          const TechniqueFilterState(
            searchQuery: 'balanced',
            selectedGoals: {PrimaryGoal.calm},
          ),
        );
    final result = container.read(filteredTechniquesProvider);
    expect(result.value?.length, 1);
    expect(result.value?.first.id, 'box');
  });
}
