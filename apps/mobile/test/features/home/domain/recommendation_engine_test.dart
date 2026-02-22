import 'package:clearbreath/features/home/domain/recommendation_engine.dart';
import 'package:clearbreath/features/onboarding/domain/onboarding_answers.dart';
import 'package:clearbreath/features/techniques/data/technique_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all goal/daypart/experience combos produce a valid recommendation', () async {
    final techniques = await TechniqueRepository().all();
    final engine = RecommendationEngine();

    for (final goal in PrimaryGoal.values) {
      for (final dayPart in DayPart.values) {
        for (final experience in ExperienceLevel.values) {
          final rec = await engine.recommend(
            goal: goal,
            dayPart: dayPart,
            experienceLevel: experience,
            techniques: techniques,
          );

          expect(rec.technique.id, equals(rec.techniqueId));
          expect(rec.presetId, equals(experience.name));
          expect(rec.rationale, isNotEmpty);
        }
      }
    }
  });
}
