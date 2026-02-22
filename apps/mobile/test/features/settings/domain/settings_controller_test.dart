import 'dart:io';
import 'dart:async';

import 'package:clearbreath/core/database/app_database.dart';
import 'package:clearbreath/features/settings/domain/settings_controller.dart';
import 'package:clearbreath/shared/providers/app_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('settings persist through preferences table', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'clearbreath_settings_',
    );
    final dbFile = File('${tempDir.path}/settings.sqlite');

    ProviderContainer container(File file) {
      return ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            final db = AppDatabase(NativeDatabase(file));
            ref.onDispose(db.close);
            return db;
          }),
        ],
      );
    }

    try {
      final c1 = container(dbFile);

      final controller1 = c1.read(settingsControllerProvider.notifier);
      await controller1.setSessionLength(10);
      await controller1.setHapticsEnabled(false);
      await controller1.setKeepScreenAwake(false);
      await controller1.setReminderEnabled(false);
      await controller1.setReminderTime(8 * 60 + 30);
      await controller1.setStreakWarningEnabled(false);
      await controller1.setDisplayName('Rahul');

      final db1 = c1.read(appDatabaseProvider);
      final row1 = await (db1.select(db1.preferences)
            ..where((row) => row.id.equals(1)))
          .getSingleOrNull();
      expect(row1, isNotNull);
      expect(row1!.sessionLengthMinutes, equals(10));
      expect(row1.hapticsEnabled, isFalse);
      expect(row1.keepScreenAwake, isFalse);
      expect(row1.reminderEnabled, isFalse);
      expect(row1.reminderTimeMinutes, equals(8 * 60 + 30));
      expect(row1.streakWarningEnabled, isFalse);
      expect(row1.displayName, equals('Rahul'));

      c1.dispose();

      final c2 = container(dbFile);

      Future<SettingsState> waitForState(
        bool Function(SettingsState) predicate,
      ) async {
        final completer = Completer<SettingsState>();
        late final ProviderSubscription<SettingsState> sub;
        sub = c2.listen(
          settingsControllerProvider,
          (previous, next) {
            if (!completer.isCompleted && predicate(next)) {
              completer.complete(next);
              sub.close();
            }
          },
          fireImmediately: true,
        );
        return completer.future.timeout(const Duration(seconds: 2));
      }

      final state2 = await waitForState((s) => s.sessionLengthMinutes == 10);
      expect(state2.sessionLengthMinutes, equals(10));
      expect(state2.hapticsEnabled, isFalse);
      expect(state2.keepScreenAwake, isFalse);
      expect(state2.reminderEnabled, isFalse);
      expect(state2.reminderTimeMinutes, equals(8 * 60 + 30));
      expect(state2.streakWarningEnabled, isFalse);
      expect(state2.displayName, equals('Rahul'));

      c2.dispose();
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
