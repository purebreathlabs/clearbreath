import 'package:flutter/foundation.dart';

import '../../onboarding/domain/onboarding_answers.dart';
import 'technique_preset.dart';

enum AnimationMode { circle, metronome, alternateNostril }

@immutable
class TechniqueSafety {
  const TechniqueSafety({
    required this.requiresAck,
    required this.title,
    required this.body,
  });

  final bool requiresAck;
  final String title;
  final String body;
}

@immutable
class TechniqueAbout {
  const TechniqueAbout({
    required this.what,
    required this.how,
    required this.bestTime,
    required this.benefits,
    required this.warnings,
  });

  final String what;
  final String how;
  final String bestTime;
  final String benefits;
  final String warnings;
}

@immutable
class Technique {
  Technique({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.animationMode,
    required Set<PrimaryGoal> goals,
    required this.safety,
    required this.about,
    required Map<String, TechniquePreset> presets,
  }) : goals = Set.unmodifiable(goals),
       presets = Map.unmodifiable(presets);

  final String id;
  final String name;
  final String shortDescription;
  final AnimationMode animationMode;
  final Set<PrimaryGoal> goals;
  final TechniqueSafety safety;
  final TechniqueAbout about;
  final Map<String, TechniquePreset> presets;

  bool get presetsAreEquivalent {
    final values = presets.values.toList();
    if (values.length <= 1) return true;
    final first = values.first;
    for (var i = 1; i < values.length; i++) {
      if (!_presetsMatchTiming(first, values[i])) return false;
    }
    return true;
  }

  static bool _presetsMatchTiming(TechniquePreset a, TechniquePreset b) {
    if (a is PhasePreset && b is PhasePreset) {
      return a.inhaleMs == b.inhaleMs &&
          a.holdMs == b.holdMs &&
          a.exhaleMs == b.exhaleMs &&
          a.holdAfterExhaleMs == b.holdAfterExhaleMs;
    }
    if (a is BpmRoundsPreset && b is BpmRoundsPreset) {
      return a.bpm == b.bpm &&
          a.rounds == b.rounds &&
          a.roundSeconds == b.roundSeconds &&
          a.restSeconds == b.restSeconds;
    }
    return false;
  }
}
