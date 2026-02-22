import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/providers/preferences_provider.dart';
import '../data/settings_repository.dart';

@immutable
class SettingsState {
  const SettingsState({
    required this.sessionLengthMinutes,
    required this.hapticsEnabled,
    required this.keepScreenAwake,
    required this.reminderEnabled,
    required this.reminderTimeMinutes,
    required this.streakWarningEnabled,
    required this.displayName,
  });

  factory SettingsState.fromPreferences(Preference? prefs) {
    if (prefs == null) {
      return const SettingsState(
        sessionLengthMinutes: 5,
        hapticsEnabled: true,
        keepScreenAwake: true,
        reminderEnabled: true,
        reminderTimeMinutes: 22 * 60,
        streakWarningEnabled: true,
        displayName: '',
      );
    }

    return SettingsState(
      sessionLengthMinutes: prefs.sessionLengthMinutes,
      hapticsEnabled: prefs.hapticsEnabled,
      keepScreenAwake: prefs.keepScreenAwake,
      reminderEnabled: prefs.reminderEnabled,
      reminderTimeMinutes: prefs.reminderTimeMinutes,
      streakWarningEnabled: prefs.streakWarningEnabled,
      displayName: prefs.displayName,
    );
  }

  final int sessionLengthMinutes;
  final bool hapticsEnabled;
  final bool keepScreenAwake;
  final bool reminderEnabled;
  final int reminderTimeMinutes;
  final bool streakWarningEnabled;
  final String displayName;
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final prefs = ref.watch(preferencesProvider);
    final row = prefs.asData?.value;
    return SettingsState.fromPreferences(row);
  }

  Future<void> setSessionLength(int minutes) async {
    final sanitized = _sanitizeSessionLength(minutes);
    await ref
        .read(settingsRepositoryProvider)
        .setSessionLengthMinutes(sanitized);
  }

  Future<void> setHapticsEnabled(bool value) async {
    await ref.read(settingsRepositoryProvider).setHapticsEnabled(value);
  }

  Future<void> setKeepScreenAwake(bool value) async {
    await ref.read(settingsRepositoryProvider).setKeepScreenAwake(value);
  }

  Future<void> setReminderEnabled(bool value) async {
    await ref.read(settingsRepositoryProvider).setReminderEnabled(value);
  }

  Future<void> setReminderTime(int minutesFromMidnight) async {
    final safe = minutesFromMidnight.clamp(0, 23 * 60 + 59);
    await ref.read(settingsRepositoryProvider).setReminderTimeMinutes(safe);
  }

  Future<void> setStreakWarningEnabled(bool value) async {
    await ref.read(settingsRepositoryProvider).setStreakWarningEnabled(value);
  }

  Future<void> setDisplayName(String value) async {
    await ref.read(settingsRepositoryProvider).setDisplayName(value);
  }

  int _sanitizeSessionLength(int value) {
    const allowed = [2, 5, 10, 20];
    if (allowed.contains(value)) {
      return value;
    }
    return 5;
  }
}
