import 'dart:async';

import 'package:clearbreath/core/network/models/user_models.dart';
import 'package:clearbreath/features/auth/domain/auth_controller.dart';
import 'package:clearbreath/features/auth/domain/auth_state.dart';
import 'package:clearbreath/features/auth/domain/auth_state_provider.dart';
import 'package:clearbreath/features/stats/domain/stats_snapshot.dart';
import 'package:clearbreath/features/stats/domain/weekly_minutes_provider.dart';
import 'package:clearbreath/features/sync/domain/merged_stats_provider.dart';
import 'package:clearbreath/shared/providers/server_status_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'current week uses merged snapshot when weekly array is present',
    () async {
      final container = ProviderContainer(
        overrides: [
          mergedStatsProvider.overrideWith(
            (ref) async => _snapshot(
              minutesThisWeek: 5,
              weeklyMinutesByDay: const [5, 0, 0, 0, 0, 0, 0],
            ),
          ),
          cloudWeeklyMinutesProvider.overrideWith(
            (ref, weekOffset) async => const [0, 0, 0, 0, 0, 0, 0],
          ),
          localWeeklyMinutesProvider.overrideWith(
            (ref, weekOffset) async => const [0, 0, 0, 0, 0, 0, 0],
          ),
        ],
      );
      addTearDown(container.dispose);

      final weekly = await container.read(
        mergedWeeklyMinutesProvider(0).future,
      );
      expect(weekly, equals(const [5, 0, 0, 0, 0, 0, 0]));
    },
  );

  test(
    'current week falls back to local for guest when merged snapshot is missing weekly data',
    () async {
      final container = ProviderContainer(
        overrides: [
          mergedStatsProvider.overrideWith(
            (ref) async =>
                _snapshot(minutesThisWeek: 0, weeklyMinutesByDay: const []),
          ),
          localWeeklyMinutesProvider.overrideWith(
            (ref, weekOffset) async => const [0, 2, 0, 0, 0, 0, 0],
          ),
        ],
      );
      addTearDown(container.dispose);

      final weekly = await container.read(
        mergedWeeklyMinutesProvider(0).future,
      );
      expect(weekly, equals(const [0, 2, 0, 0, 0, 0, 0]));
    },
  );

  test(
    'current week falls back to cloud for signed-in users when merged snapshot is missing weekly data',
    () async {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(_SignedInAuthController.new),
          serverStatusProvider.overrideWith((ref) => _serverStatus(true)),
          mergedStatsProvider.overrideWith(
            (ref) async =>
                _snapshot(minutesThisWeek: 0, weeklyMinutesByDay: const []),
          ),
          cloudWeeklyMinutesProvider.overrideWith(
            (ref, weekOffset) async => const [0, 0, 4, 0, 0, 0, 0],
          ),
        ],
      );
      addTearDown(container.dispose);
      await _awaitServerStatus(container, true);

      final weekly = await container.read(
        mergedWeeklyMinutesProvider(0).future,
      );
      expect(weekly, equals(const [0, 0, 4, 0, 0, 0, 0]));
    },
  );

  test('historical signed-in week uses cloud data when online', () async {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(_SignedInAuthController.new),
        serverStatusProvider.overrideWith((ref) => _serverStatus(true)),
        cloudWeeklyMinutesProvider.overrideWith(
          (ref, weekOffset) async => const [1, 1, 1, 1, 1, 1, 1],
        ),
        localWeeklyMinutesProvider.overrideWith(
          (ref, weekOffset) async => const [0, 0, 0, 0, 0, 0, 0],
        ),
      ],
    );
    addTearDown(container.dispose);
    await _awaitServerStatus(container, true);

    final weekly = await container.read(mergedWeeklyMinutesProvider(-1).future);
    expect(weekly, equals(const [1, 1, 1, 1, 1, 1, 1]));
  });

  test(
    'historical signed-in week falls back to local data when offline',
    () async {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(_SignedInAuthController.new),
          serverStatusProvider.overrideWith((ref) => _serverStatus(false)),
          localWeeklyMinutesProvider.overrideWith(
            (ref, weekOffset) async => const [3, 0, 0, 0, 0, 0, 0],
          ),
        ],
      );
      addTearDown(container.dispose);
      await _awaitServerStatus(container, false);

      final weekly = await container.read(
        mergedWeeklyMinutesProvider(-1).future,
      );
      expect(weekly, equals(const [3, 0, 0, 0, 0, 0, 0]));
    },
  );
}

StatsSnapshot _snapshot({
  required int minutesThisWeek,
  required List<int> weeklyMinutesByDay,
}) {
  return StatsSnapshot(
    currentStreakDays: 1,
    longestStreakDays: 1,
    practiceDaysAllTime: 1,
    minutesThisWeek: minutesThisWeek,
    minutesAllTime: 5,
    sessionsAllTime: 1,
    minutesByTechnique: const {'box': 5},
    weeklyMinutesByDay: weeklyMinutesByDay,
    longestSessionMinutes: 5,
    favoriteTechniqueId: 'box',
    totalBreathsEstimated: 30,
    updatedAt: DateTime.utc(2026, 3, 6),
    totalXP: 50,
    currentLevel: 2,
  );
}

class _SignedInAuthController extends AuthController {
  @override
  AuthState build() {
    return AuthStateSignedIn(profile: _profile());
  }
}

UserProfile _profile() {
  return UserProfile(
    id: 'user-a',
    username: 'rahul',
    name: 'Rahul',
    avatarSeed: 'seed-a',
    leaderboardOptIn: true,
    createdAtUtc: DateTime.utc(2026, 2, 22),
    timezoneOffsetMinutesLatest: 0,
  );
}

Stream<bool> _serverStatus(bool value) {
  return Stream<bool>.multi((controller) {
    controller.add(value);
    controller.close();
  });
}

Future<void> _awaitServerStatus(
  ProviderContainer container,
  bool expected,
) async {
  final completer = Completer<void>();
  final sub = container.listen<AsyncValue<bool>>(serverStatusProvider, (
    prev,
    next,
  ) {
    if (next case AsyncData<bool>(value: final value) when value == expected) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  });
  try {
    await completer.future;
  } finally {
    sub.close();
  }
}
