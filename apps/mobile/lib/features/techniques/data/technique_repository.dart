import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/domain/onboarding_answers.dart';
import '../domain/technique.dart';
import '../domain/technique_preset.dart';

final techniqueRepositoryProvider = Provider<TechniqueRepository>(
  (ref) => TechniqueRepository(),
);

final allTechniquesProvider = FutureProvider<List<Technique>>((ref) {
  return ref.read(techniqueRepositoryProvider).all();
});

class TechniqueRepository {
  List<Technique>? _cache;

  Future<List<Technique>> all() async {
    final cached = _cache;
    if (cached != null) {
      return cached;
    }

    final loaded = await _load();
    _cache = loaded;
    return loaded;
  }

  Future<Technique?> byId(String id) async {
    final techniques = await all();
    for (final technique in techniques) {
      if (technique.id == id) {
        return technique;
      }
    }
    return null;
  }

  Future<List<Technique>> safetyGated() async {
    final techniques = await all();
    return techniques
        .where((technique) => technique.safety.requiresAck)
        .toList(growable: false);
  }

  Future<List<Technique>> _load() async {
    final raw = await rootBundle.loadString(
      'assets/techniques/techniques_v1.json',
    );
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Techniques JSON must be a list.');
    }

    final techniques = <Technique>[];
    for (final item in decoded) {
      if (item is! Map) {
        throw const FormatException('Each technique must be a JSON object.');
      }
      techniques.add(_parseTechnique(item.cast<String, dynamic>()));
    }
    return List.unmodifiable(techniques);
  }

  Technique _parseTechnique(Map<String, dynamic> json) {
    final id = _readString(json, 'id');
    final name = _readString(json, 'name');
    final shortDescription = _readString(json, 'shortDescription');
    final goals = _readGoals(json, 'goals');

    final animationMode = _parseAnimationMode(
      _readString(json, 'animationMode'),
    );

    final safetyJson = _readMap(json, 'safety');
    final safety = TechniqueSafety(
      requiresAck: _readBool(safetyJson, 'requiresAck'),
      title: _readString(safetyJson, 'title'),
      body: _readString(safetyJson, 'body'),
    );

    final aboutJson = _readMap(json, 'about');
    final about = TechniqueAbout(
      what: _readString(aboutJson, 'what'),
      how: _readString(aboutJson, 'how'),
      bestTime: _readString(aboutJson, 'bestTime'),
      benefits: _readString(aboutJson, 'benefits'),
      warnings: _readString(aboutJson, 'warnings'),
    );

    final presetsJson = _readMap(json, 'presets');
    final presets = <String, TechniquePreset>{};
    for (final entry in presetsJson.entries) {
      if (entry.value is! Map) {
        throw const FormatException('Preset must be a JSON object.');
      }
      final presetId = entry.key;
      final presetJson = (entry.value as Map).cast<String, dynamic>();
      presets[presetId] = _parsePreset(presetId, presetJson);
    }

    return Technique(
      id: id,
      name: name,
      shortDescription: shortDescription,
      animationMode: animationMode,
      goals: goals,
      safety: safety,
      about: about,
      presets: presets,
    );
  }

  TechniquePreset _parsePreset(String id, Map<String, dynamic> json) {
    final label = _presetLabel(id);
    final mode = _readString(json, 'mode');
    final durations = _readIntList(json, 'recommendedDurationsMinutes');

    if (mode == 'phases') {
      return PhasePreset(
        id: id,
        label: label,
        inhaleMs: _readDurationMs(json, 'inhaleSeconds'),
        holdMs: _readDurationMs(json, 'holdSeconds'),
        exhaleMs: _readDurationMs(json, 'exhaleSeconds'),
        holdAfterExhaleMs: _readDurationMs(json, 'holdAfterExhaleSeconds'),
        recommendedDurationsMinutes: durations,
      );
    }

    if (mode == 'bpm_rounds') {
      return BpmRoundsPreset(
        id: id,
        label: label,
        bpm: _readInt(json, 'bpm'),
        rounds: _readInt(json, 'rounds'),
        roundSeconds: _readInt(json, 'roundSeconds'),
        restSeconds: _readInt(json, 'restSeconds'),
        recommendedDurationsMinutes: durations,
      );
    }

    throw FormatException('Unknown preset mode: $mode');
  }

  AnimationMode _parseAnimationMode(String value) {
    return switch (value) {
      'circle' => AnimationMode.circle,
      'metronome' => AnimationMode.metronome,
      'alternate_nostril' => AnimationMode.alternateNostril,
      _ => throw FormatException('Unknown animationMode: $value'),
    };
  }

  Set<PrimaryGoal> _readGoals(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! List) {
      throw FormatException('Missing or invalid $key.');
    }
    final result = <PrimaryGoal>{};
    for (final item in value) {
      if (item is! String) {
        throw FormatException('Invalid $key entry.');
      }
      result.add(_parseGoal(item));
    }
    return Set.unmodifiable(result);
  }

  PrimaryGoal _parseGoal(String value) {
    for (final goal in PrimaryGoal.values) {
      if (goal.name == value) {
        return goal;
      }
    }
    throw FormatException('Unknown goal: $value');
  }

  int _readDurationMs(Map<String, dynamic> json, String key) {
    final seconds = _readNum(json, key);
    return (seconds * 1000).round();
  }

  String _presetLabel(String id) {
    return switch (id) {
      'beginner' => 'Beginner',
      'intermediate' => 'Intermediate',
      'advanced' => 'Advanced',
      _ => id,
    };
  }

  Map<String, dynamic> _readMap(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is Map) {
      return value.cast<String, dynamic>();
    }
    throw FormatException('Missing or invalid $key.');
  }

  String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) {
      return value;
    }
    throw FormatException('Missing or invalid $key.');
  }

  bool _readBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is bool) {
      return value;
    }
    throw FormatException('Missing or invalid $key.');
  }

  int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    throw FormatException('Missing or invalid $key.');
  }

  num _readNum(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) {
      return value;
    }
    throw FormatException('Missing or invalid $key.');
  }

  List<int> _readIntList(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! List) {
      throw FormatException('Missing or invalid $key.');
    }
    final result = <int>[];
    for (final item in value) {
      if (item is int) {
        result.add(item);
        continue;
      }
      if (item is num) {
        result.add(item.round());
        continue;
      }
      throw FormatException('Invalid item in $key.');
    }
    return result;
  }
}
