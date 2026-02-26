import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/domain/onboarding_answers.dart';
import '../../onboarding/domain/onboarding_answers_provider.dart';
import '../../techniques/data/technique_repository.dart';
import '../../techniques/domain/technique.dart';
import '../../techniques/domain/technique_preset.dart';
import '../../xp/domain/xp_provider.dart';

enum DayPart { morning, afternoon, evening, night }

DayPart currentDayPart(DateTime now) {
  final hour = now.hour;
  if (hour >= 5 && hour < 11) {
    return DayPart.morning;
  }
  if (hour >= 11 && hour < 17) {
    return DayPart.afternoon;
  }
  if (hour >= 17 && hour < 22) {
    return DayPart.evening;
  }
  return DayPart.night;
}

class Recommendation {
  const Recommendation({
    required this.techniqueId,
    required this.presetId,
    required this.rationale,
    required this.technique,
    required this.preset,
  });

  final String techniqueId;
  final String presetId;
  final String rationale;
  final Technique technique;
  final TechniquePreset preset;
}

final recommendationEngineProvider = Provider<RecommendationEngine>(
  (ref) => RecommendationEngine(),
);

final dailyRecommendationProvider = FutureProvider<Recommendation>((ref) async {
  final engine = ref.watch(recommendationEngineProvider);
  final answers = await ref.watch(onboardingAnswersProvider.future);
  final techniques = await ref.watch(allTechniquesProvider.future);
  final xp = await ref.watch(mergedXPProvider.future);

  final goal = _selectGoal(answers.primaryGoals);

  final dayPart = currentDayPart(DateTime.now());
  return engine.recommend(
    goal: goal,
    dayPart: dayPart,
    presetId: xp.presetId,
    techniques: techniques,
  );
});

PrimaryGoal _selectGoal(Set<PrimaryGoal> goals) {
  for (final goal in PrimaryGoal.values) {
    if (goals.contains(goal)) {
      return goal;
    }
  }
  return PrimaryGoal.calm;
}

class RecommendationEngine {
  Map<PrimaryGoal, Map<DayPart, _RecommendationSpec>>? _cache;

  Future<Recommendation> recommend({
    required PrimaryGoal goal,
    required DayPart dayPart,
    required String presetId,
    required List<Technique> techniques,
  }) async {
    final map = await _load();
    final byDayPart = map[goal];
    final spec = byDayPart?[dayPart];
    if (spec == null) {
      throw FormatException(
        'Missing recommendation for ${goal.name}/${dayPart.name}.',
      );
    }

    final technique = _findTechnique(techniques, spec.techniqueId);
    if (technique == null) {
      throw FormatException('Unknown techniqueId: ${spec.techniqueId}');
    }

    final preset = technique.presets[presetId] ?? technique.presets['beginner'];
    if (preset == null) {
      throw FormatException(
        'Technique ${technique.id} missing preset: $presetId',
      );
    }

    return Recommendation(
      techniqueId: technique.id,
      presetId: presetId,
      rationale: spec.rationale,
      technique: technique,
      preset: preset,
    );
  }

  Future<Map<PrimaryGoal, Map<DayPart, _RecommendationSpec>>> _load() async {
    final cached = _cache;
    if (cached != null) {
      return cached;
    }

    final raw = await rootBundle.loadString(
      'assets/recommendations/recommendations_v1.json',
    );
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Recommendations JSON must be a list.');
    }

    final result = <PrimaryGoal, Map<DayPart, _RecommendationSpec>>{};
    for (final item in decoded) {
      if (item is! Map) {
        throw const FormatException(
          'Each recommendation must be a JSON object.',
        );
      }
      final json = item.cast<String, dynamic>();
      final goal = _parseGoal(_readString(json, 'goal'));
      final dayPart = _parseDayPart(_readString(json, 'daypart'));
      final techniqueId = _readString(json, 'techniqueId');
      final rationale = _readString(json, 'rationale');

      final byDayPart = result.putIfAbsent(
        goal,
        () => <DayPart, _RecommendationSpec>{},
      );
      if (byDayPart.containsKey(dayPart)) {
        throw FormatException(
          'Duplicate recommendation for ${goal.name}/${dayPart.name}.',
        );
      }
      byDayPart[dayPart] = _RecommendationSpec(
        techniqueId: techniqueId,
        rationale: rationale,
      );
    }

    final frozen = <PrimaryGoal, Map<DayPart, _RecommendationSpec>>{};
    for (final entry in result.entries) {
      frozen[entry.key] = Map.unmodifiable(entry.value);
    }

    _cache = Map.unmodifiable(frozen);
    return _cache!;
  }

  PrimaryGoal _parseGoal(String value) {
    for (final goal in PrimaryGoal.values) {
      if (goal.name == value) {
        return goal;
      }
    }
    throw FormatException('Unknown goal: $value');
  }

  DayPart _parseDayPart(String value) {
    for (final part in DayPart.values) {
      if (part.name == value) {
        return part;
      }
    }
    throw FormatException('Unknown daypart: $value');
  }

  Technique? _findTechnique(List<Technique> techniques, String id) {
    for (final technique in techniques) {
      if (technique.id == id) {
        return technique;
      }
    }
    return null;
  }

  String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) {
      return value;
    }
    throw FormatException('Missing or invalid $key.');
  }
}

class _RecommendationSpec {
  const _RecommendationSpec({
    required this.techniqueId,
    required this.rationale,
  });

  final String techniqueId;
  final String rationale;
}
