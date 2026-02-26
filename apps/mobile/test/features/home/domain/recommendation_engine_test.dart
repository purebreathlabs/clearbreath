import 'package:clearbreath/features/home/domain/recommendation_engine.dart';
import 'package:clearbreath/features/onboarding/domain/onboarding_answers.dart';
import 'package:clearbreath/features/techniques/data/technique_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'all goal/daypart/preset combos produce a valid recommendation',
    () async {
      final techniques = await TechniqueRepository().all();
      final engine = RecommendationEngine();

      const presetIds = ['beginner', 'intermediate', 'advanced'];

      for (final goal in PrimaryGoal.values) {
        for (final dayPart in DayPart.values) {
          for (final presetId in presetIds) {
            final rec = await engine.recommend(
              goal: goal,
              dayPart: dayPart,
              presetId: presetId,
              techniques: techniques,
            );

            expect(rec.technique.id, equals(rec.techniqueId));
            expect(rec.presetId, equals(presetId));
            expect(rec.rationale, isNotEmpty);
          }
        }
      }
    },
  );
}
