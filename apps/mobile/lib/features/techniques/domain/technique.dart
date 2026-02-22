import 'package:flutter/foundation.dart';

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
    required this.safety,
    required this.about,
    required Map<String, TechniquePreset> presets,
  }) : presets = Map.unmodifiable(presets);

  final String id;
  final String name;
  final String shortDescription;
  final AnimationMode animationMode;
  final TechniqueSafety safety;
  final TechniqueAbout about;
  final Map<String, TechniquePreset> presets;
}
