import 'dart:io';

import 'package:clearbreath/core/database/app_database.dart';
import 'package:clearbreath/features/onboarding/data/onboarding_repository.dart';
import 'package:clearbreath/features/onboarding/domain/onboarding_answers.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persists onboarding completion and answers', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'clearbreath_onboarding_',
    );
    final dbFile = File('${tempDir.path}/prefs.sqlite');

    final answers = OnboardingAnswers.defaults().copyWith(
      primaryGoals: {PrimaryGoal.sleep, PrimaryGoal.focus},
      practiceWindows: {PracticeWindow.morning, PracticeWindow.evening},
      sessionLengthMinutes: 20,
      hapticsEnabled: false,
      reminderTimeMinutes: 21 * 60 + 30,
      displayName: ' Rahul ',
    );

    try {
      final db1 = AppDatabase(NativeDatabase(dbFile));
      final repo1 = OnboardingRepository(db1);

      expect(await repo1.isOnboardingComplete(), isFalse);
      await repo1.setOnboardingComplete(answers);
      expect(await repo1.isOnboardingComplete(), isTrue);

      await db1.close();

      final db2 = AppDatabase(NativeDatabase(dbFile));
      final repo2 = OnboardingRepository(db2);

      expect(await repo2.isOnboardingComplete(), isTrue);
      final restored = await repo2.readAnswers();
      expect(restored, isNotNull);
      expect(
        restored!.primaryGoals,
        unorderedEquals([PrimaryGoal.sleep, PrimaryGoal.focus]),
      );
      expect(
        restored.practiceWindows,
        unorderedEquals([PracticeWindow.morning, PracticeWindow.evening]),
      );
      expect(restored.sessionLengthMinutes, 20);
      expect(restored.hapticsEnabled, isFalse);
      expect(restored.reminderTimeMinutes, 21 * 60 + 30);
      expect(restored.displayName, 'Rahul');

      await db2.close();
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
