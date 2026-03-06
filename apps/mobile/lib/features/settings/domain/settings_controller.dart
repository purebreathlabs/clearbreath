import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/providers/preferences_provider.dart';
import '../../notifications/data/notification_preferences_repository.dart';
import '../../notifications/domain/notification_constants.dart';
import '../data/settings_repository.dart';

@immutable
class SettingsState {
  const SettingsState({
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
        hapticsEnabled: true,
        keepScreenAwake: true,
        reminderEnabled: true,
        reminderTimeMinutes: kDefaultReminderTimeMinutes,
        streakWarningEnabled: true,
        displayName: '',
      );
    }

    return SettingsState(
      hapticsEnabled: prefs.hapticsEnabled,
      keepScreenAwake: prefs.keepScreenAwake,
      reminderEnabled: prefs.reminderEnabled,
      reminderTimeMinutes: prefs.reminderTimeMinutes,
      streakWarningEnabled: prefs.streakWarningEnabled,
      displayName: prefs.displayName,
    );
  }

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

  Future<void> setHapticsEnabled(bool value) async {
    await ref.read(settingsRepositoryProvider).setHapticsEnabled(value);
  }

  Future<void> setKeepScreenAwake(bool value) async {
    await ref.read(settingsRepositoryProvider).setKeepScreenAwake(value);
  }

  Future<void> setReminderEnabled(bool value) async {
    await ref.read(settingsRepositoryProvider).setReminderEnabled(value);
    _syncNotificationPrefs(
      reminderEnabled: value,
      reminderTimeMinutes: state.reminderTimeMinutes,
      streakWarningEnabled: state.streakWarningEnabled,
    );
  }

  Future<void> setReminderTime(int minutesFromMidnight) async {
    final safe = minutesFromMidnight.clamp(0, 23 * 60 + 59);
    await ref.read(settingsRepositoryProvider).setReminderTimeMinutes(safe);
    _syncNotificationPrefs(
      reminderEnabled: state.reminderEnabled,
      reminderTimeMinutes: safe,
      streakWarningEnabled: state.streakWarningEnabled,
    );
  }

  Future<void> setStreakWarningEnabled(bool value) async {
    await ref.read(settingsRepositoryProvider).setStreakWarningEnabled(value);
    _syncNotificationPrefs(
      reminderEnabled: state.reminderEnabled,
      reminderTimeMinutes: state.reminderTimeMinutes,
      streakWarningEnabled: value,
    );
  }

  void _syncNotificationPrefs({
    required bool reminderEnabled,
    required int reminderTimeMinutes,
    required bool streakWarningEnabled,
  }) {
    ref
        .read(notificationPreferencesRepositoryProvider)
        .syncToBackend(
          reminderEnabled: reminderEnabled,
          reminderTimeMinutes: reminderTimeMinutes,
          streakWarningEnabled: streakWarningEnabled,
        );
  }

  Future<void> setDisplayName(String value) async {
    await ref.read(settingsRepositoryProvider).setDisplayName(value);
  }
}
