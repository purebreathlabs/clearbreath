import 'package:clearbreath/features/techniques/data/technique_repository.dart';
import 'package:clearbreath/features/techniques/domain/technique.dart';
import 'package:clearbreath/features/techniques/domain/technique_preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads canonical techniques from JSON', () async {
    final repo = TechniqueRepository();

    final techniques = await repo.all();
    expect(techniques, hasLength(9));

    final ids = techniques.map((technique) => technique.id).toSet();
    expect(
      ids,
      equals({
        'hrv_resonance',
        'ultra_slow',
        'box',
        'four_seven_eight',
        'anulom_vilom',
        'ujjayi',
        'bhramari',
        'kapalbhati',
        'bhastrika',
      }),
    );

    for (final technique in techniques) {
      expect(technique.presets, hasLength(3));
      expect(
        technique.presets.keys.toSet(),
        equals({'beginner', 'intermediate', 'advanced'}),
      );
      expect(technique.goals, isNotEmpty);
    }

    final safetyGated = await repo.safetyGated();
    expect(
      safetyGated.map((technique) => technique.id).toSet(),
      equals({'kapalbhati', 'bhastrika', 'ultra_slow'}),
    );

    final byId = {for (final technique in techniques) technique.id: technique};
    expect(byId['kapalbhati']!.animationMode, AnimationMode.metronome);
    expect(byId['bhastrika']!.animationMode, AnimationMode.metronome);
    expect(byId['anulom_vilom']!.animationMode, AnimationMode.alternateNostril);

    for (final id in ids) {
      if (id == 'kapalbhati' || id == 'bhastrika' || id == 'anulom_vilom') {
        continue;
      }
      expect(byId[id]!.animationMode, AnimationMode.circle);
    }

    expect(byId['box']!.presets['beginner'], isA<PhasePreset>());
    expect(byId['kapalbhati']!.presets['beginner'], isA<BpmRoundsPreset>());

    final anulomIntermediate =
        byId['anulom_vilom']!.presets['intermediate'] as PhasePreset;
    expect(anulomIntermediate.inhaleMs, equals(4000));
    expect(anulomIntermediate.holdMs, equals(4000));
    expect(anulomIntermediate.exhaleMs, equals(8000));
    expect(anulomIntermediate.holdAfterExhaleMs, equals(0));

    final anulomAdvanced =
        byId['anulom_vilom']!.presets['advanced'] as PhasePreset;
    expect(anulomAdvanced.holdMs, equals(16000));
    expect(anulomAdvanced.exhaleMs, equals(8000));

    final kapalbhatiIntermediate =
        byId['kapalbhati']!.presets['intermediate'] as BpmRoundsPreset;
    expect(kapalbhatiIntermediate.bpm, equals(80));
    expect(kapalbhatiIntermediate.roundSeconds, equals(45));
    expect(kapalbhatiIntermediate.restSeconds, equals(30));

    final kapalbhatiAdvanced =
        byId['kapalbhati']!.presets['advanced'] as BpmRoundsPreset;
    expect(kapalbhatiAdvanced.bpm, equals(120));
    expect(kapalbhatiAdvanced.roundSeconds, equals(60));
    expect(kapalbhatiAdvanced.restSeconds, equals(45));

    final bhastrikaBeginner =
        byId['bhastrika']!.presets['beginner'] as BpmRoundsPreset;
    expect(bhastrikaBeginner.bpm, equals(30));
    expect(bhastrikaBeginner.roundSeconds, equals(30));
    expect(bhastrikaBeginner.restSeconds, equals(60));

    final bhastrikaIntermediate =
        byId['bhastrika']!.presets['intermediate'] as BpmRoundsPreset;
    expect(bhastrikaIntermediate.bpm, equals(60));
    expect(bhastrikaIntermediate.roundSeconds, equals(30));
    expect(bhastrikaIntermediate.restSeconds, equals(90));

    final bhastrikaAdvanced =
        byId['bhastrika']!.presets['advanced'] as BpmRoundsPreset;
    expect(bhastrikaAdvanced.bpm, equals(90));
    expect(bhastrikaAdvanced.roundSeconds, equals(40));
    expect(bhastrikaAdvanced.restSeconds, equals(120));

    expect(await repo.byId('box'), isNotNull);
    expect(await repo.byId('missing'), isNull);
  });
}
