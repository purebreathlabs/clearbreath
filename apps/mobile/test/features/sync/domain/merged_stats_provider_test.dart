import 'dart:async';
import 'dart:io';

import 'package:clearbreath/core/database/app_database.dart';
import 'package:clearbreath/core/network/models/user_models.dart';
import 'package:clearbreath/features/auth/domain/auth_controller.dart';
import 'package:clearbreath/features/auth/domain/auth_state.dart';
import 'package:clearbreath/features/auth/domain/auth_state_provider.dart';
import 'package:clearbreath/features/session/data/session_repository.dart';
import 'package:clearbreath/features/session/domain/local_session.dart';
import 'package:clearbreath/features/stats/data/stats_cache_repository.dart';
import 'package:clearbreath/features/stats/domain/stats_snapshot.dart';
import 'package:clearbreath/features/sync/domain/merged_stats_provider.dart';
import 'package:clearbreath/shared/providers/app_database_provider.dart';
import 'package:clearbreath/shared/providers/server_status_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stale cache fallback uses local streak instead of cached', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'clearbreath_merged_stats_',
    );
    final dbFile = File('${tempDir.path}/stats.sqlite');

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) {
          final db = AppDatabase(NativeDatabase(dbFile));
          ref.onDispose(db.close);
          return db;
        }),
        authStateProvider.overrideWith(_SignedInAuthController.new),
        serverStatusProvider.overrideWith((ref) {
          final c = StreamController<bool>();
          ref.onDispose(c.close);
          return c.stream;
        }),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await tempDir.delete(recursive: true);
    });

    final staleCache = StatsSnapshot(
      currentStreakDays: 2,
      longestStreakDays: 5,
      practiceDaysAllTime: 10,
      minutesThisWeek: 30,
      minutesAllTime: 200,
      sessionsAllTime: 40,
      minutesByTechnique: const {'box': 200},
      weeklyMinutesByDay: const [30, 0, 0, 0, 0, 0, 0],
      longestSessionMinutes: 20,
      favoriteTechniqueId: 'box',
      totalBreathsEstimated: 500,
      totalXP: 1000,
      currentLevel: 3,
      updatedAt: DateTime.now().toUtc().subtract(const Duration(days: 3)),
    );
    await container.read(statsCacheRepositoryProvider).writeCache(staleCache);

    final result = await container.read(mergedStatsProvider.future);

    expect(result.currentStreakDays, equals(0));
    expect(result.minutesAllTime, equals(200));
    expect(result.longestStreakDays, equals(5));
    expect(result.weeklyMinutesByDay, equals(const [0, 0, 0, 0, 0, 0, 0]));
  });

  test(
    'stale cache fallback picks max of cache and local for aggregates',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'clearbreath_merged_max_',
      );
      final dbFile = File('${tempDir.path}/stats.sqlite');

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            final db = AppDatabase(NativeDatabase(dbFile));
            ref.onDispose(db.close);
            return db;
          }),
          authStateProvider.overrideWith(_SignedInAuthController.new),
          serverStatusProvider.overrideWith((ref) {
            final c = StreamController<bool>();
            ref.onDispose(c.close);
            return c.stream;
          }),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await tempDir.delete(recursive: true);
      });

      final sessions = container.read(sessionRepositoryProvider);
      final now = DateTime.now().toUtc();
      await sessions.insert(
        LocalSession(
          clientSessionId: 's1',
          techniqueId: 'box',
          presetId: 'beginner',
          startedAtUtc: now.subtract(const Duration(minutes: 10)),
          endedAtUtc: now.subtract(const Duration(minutes: 5)),
          timezoneOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
          durationSecondsActual: 300,
          breathsCompletedEstimated: 42,
          endedEarly: false,
          syncedToCloud: false,
          createdAt: now,
        ),
      );

      final staleCache = StatsSnapshot(
        currentStreakDays: 3,
        longestStreakDays: 3,
        practiceDaysAllTime: 3,
        minutesThisWeek: 0,
        minutesAllTime: 100,
        sessionsAllTime: 20,
        minutesByTechnique: const {'box': 100},
        weeklyMinutesByDay: const [0, 0, 0, 0, 0, 0, 0],
        longestSessionMinutes: 10,
        favoriteTechniqueId: 'box',
        totalBreathsEstimated: 300,
        totalXP: 500,
        currentLevel: 2,
        updatedAt: DateTime.now().toUtc().subtract(const Duration(days: 3)),
      );
      await container.read(statsCacheRepositoryProvider).writeCache(staleCache);

      final result = await container.read(mergedStatsProvider.future);

      expect(result.currentStreakDays, equals(1));
      expect(result.minutesAllTime, equals(100));
      expect(result.sessionsAllTime, equals(20));
      expect(result.minutesThisWeek, greaterThan(0));
      expect(result.weeklyMinutesByDay.reduce((a, b) => a + b), greaterThan(0));
    },
  );

  test('guest uses local stats directly', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'clearbreath_merged_guest_',
    );
    final dbFile = File('${tempDir.path}/stats.sqlite');

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) {
          final db = AppDatabase(NativeDatabase(dbFile));
          ref.onDispose(db.close);
          return db;
        }),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await tempDir.delete(recursive: true);
    });

    final result = await container.read(mergedStatsProvider.future);

    expect(result.currentStreakDays, equals(0));
    expect(result.sessionsAllTime, equals(0));
  });
}

class _SignedInAuthController extends AuthController {
  @override
  AuthState build() {
    return AuthStateSignedIn(
      profile: UserProfile(
        id: 'user-test',
        username: 'tester',
        name: 'Tester',
        avatarSeed: 'seed',
        leaderboardOptIn: true,
        createdAtUtc: DateTime.utc(2026, 2, 22),
        timezoneOffsetMinutesLatest: 0,
      ),
    );
  }
}
