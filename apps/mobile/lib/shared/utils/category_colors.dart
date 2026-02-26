import 'package:flutter/material.dart';

import '../../features/onboarding/domain/onboarding_answers.dart';

@immutable
class CategoryStyle {
  const CategoryStyle({required this.color, required this.label});

  final Color color;
  final String label;
}

CategoryStyle categoryStyleFor(PrimaryGoal goal) {
  return switch (goal) {
    PrimaryGoal.calm => const CategoryStyle(
      color: Color(0xFF4A9ECC),
      label: 'Calm',
    ),
    PrimaryGoal.sleep => const CategoryStyle(
      color: Color(0xFF7B68EE),
      label: 'Sleep',
    ),
    PrimaryGoal.focus => const CategoryStyle(
      color: Color(0xFFE8A838),
      label: 'Focus',
    ),
    PrimaryGoal.energy => const CategoryStyle(
      color: Color(0xFFE85D5D),
      label: 'Energy',
    ),
    PrimaryGoal.hrv => const CategoryStyle(
      color: Color(0xFF4ECDC4),
      label: 'HRV',
    ),
    PrimaryGoal.spiritual => const CategoryStyle(
      color: Color(0xFFB388FF),
      label: 'Spiritual',
    ),
  };
}
