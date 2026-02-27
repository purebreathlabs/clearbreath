import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../../../core/network/models/session_models.dart';
import '../../../core/network/models/stats_models.dart' as api;
import '../../auth/domain/auth_state.dart';
import '../../auth/domain/auth_state_provider.dart';
import '../../session/data/session_repository.dart';
import '../../session/domain/local_session.dart';
import '../../stats/data/stats_cache_repository.dart';
import '../../stats/domain/stats_snapshot.dart' as domain;
import '../../../shared/providers/server_status_provider.dart';
import '../../techniques/data/safety_sync_service.dart';
import '../../leaderboard/domain/leaderboard_controller.dart';
import '../data/sync_repository.dart';
import '../../stats/domain/weekly_minutes_provider.dart';
import 'merged_stats_provider.dart';
import 'sync_state.dart';
import '../../xp/data/daily_login_repository.dart';

final latestXpAwardsProvider =
    NotifierProvider<LatestXpAwardsController, List<XPAward>>(
      LatestXpAwardsController.new,
    );

class LatestXpAwardsController extends Notifier<List<XPAward>> {
  @override
  List<XPAward> build() => const [];

  void set(List<XPAward> awards) => state = awards;

  void clear() => state = const [];
}

final syncControllerProvider = NotifierProvider<SyncController, SyncState>(
  SyncController.new,
);

class SyncController extends Notifier<SyncState> {
  var _inProgress = false;
  var _pendingSync = false;

  @override
  SyncState build() {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      final becameReady =
          (previous is! AuthStateSignedIn || !previous.sessionReady) &&
          next is AuthStateSignedIn &&
          next.sessionReady;
      if (becameReady) {
        unawaited(syncUnsyncedSessions());
        unawaited(ref.read(safetySyncServiceProvider).pullAndMerge());
        unawaited(_claimDailyOpen(next.profile.id));
      }
      if (next is AuthStateGuest) {
        state = const SyncIdle();
      }
    });

    ref.listen<AsyncValue<bool>>(serverStatusProvider, (prev, next) {
      final wasOffline = prev?.asData?.value != true;
      final isOnline = next.asData?.value == true;
      if (wasOffline && isOnline) {
        final auth = ref.read(authStateProvider);
        if (auth is AuthStateSignedIn && auth.sessionReady) {
          unawaited(syncUnsyncedSessions());
          unawaited(_claimDailyOpen(auth.profile.id));
        }
      }
    });

    final auth = ref.read(authStateProvider);
    if (auth is AuthStateSignedIn && auth.sessionReady) {
      unawaited(syncUnsyncedSessions());
      unawaited(ref.read(safetySyncServiceProvider).pullAndMerge());
      unawaited(_claimDailyOpen(auth.profile.id));
    }

    return const SyncIdle();
  }

  Future<void> _claimDailyOpen(String userId) async {
    final result = await ref
        .read(dailyLoginRepositoryProvider)
        .claimIfNeeded(userId: userId);
    if (result == null) {
      return;
    }

    final cache = ref.read(statsCacheRepositoryProvider);
    domain.StatsSnapshot? existing;
    try {
      existing = await cache.readCached();
    } catch (_) {}

    if (existing != null) {
      final merged = domain.StatsSnapshot(
        currentStreakDays: existing.currentStreakDays,
        longestStreakDays: existing.longestStreakDays,
        practiceDaysAllTime: existing.practiceDaysAllTime,
        minutesThisWeek: existing.minutesThisWeek,
        minutesAllTime: existing.minutesAllTime,
        sessionsAllTime: existing.sessionsAllTime,
        minutesByTechnique: existing.minutesByTechnique,
        longestSessionMinutes: existing.longestSessionMinutes,
        favoriteTechniqueId: existing.favoriteTechniqueId,
        totalBreathsEstimated: existing.totalBreathsEstimated,
        totalXP: result.totalXp,
        currentLevel: result.currentLevel,
        updatedAt: existing.updatedAt,
      );
      try {
        await cache.writeCache(merged);
      } catch (_) {}
    }

    ref.invalidate(mergedStatsProvider);
  }

  Future<void> syncUnsyncedSessions() async {
    if (_inProgress) {
      _pendingSync = true;
      return;
    }
    final auth = ref.read(authStateProvider);
    if (auth is! AuthStateSignedIn || !auth.sessionReady) {
      return;
    }

    _inProgress = true;
    state = const SyncInProgress('Syncing sessions...');

    try {
      final sessions = await ref.read(sessionRepositoryProvider).unsynced();
      final batch = sessions.take(500).toList(growable: false);
      if (batch.isEmpty) {
        state = const SyncIdle();
        return;
      }

      final resp = await ref.read(syncRepositoryProvider).sync(batch);
      await _applyIngestResult(submitted: batch, response: resp);

      state = SyncComplete(
        accepted: resp.acceptedCount,
        duplicates: resp.duplicateCount,
        rejected: resp.rejected.length,
      );
    } on DioException catch (e) {
      final apiError = ApiError.fromDioException(e);
      state = SyncFailed(apiError.message);
    } catch (_) {
      state = const SyncFailed('Sync failed.');
    } finally {
      _inProgress = false;
      if (_pendingSync) {
        _pendingSync = false;
        unawaited(syncUnsyncedSessions());
      }
    }
  }

  Future<void> submitSession(LocalSession session) async {
    if (_inProgress) {
      _pendingSync = true;
      return;
    }
    final auth = ref.read(authStateProvider);
    if (auth is! AuthStateSignedIn || !auth.sessionReady) {
      return;
    }

    _inProgress = true;
    state = const SyncInProgress('Submitting session...');

    try {
      final resp = await ref.read(syncRepositoryProvider).submit([session]);
      await _applyIngestResult(submitted: [session], response: resp);
      state = SyncComplete(
        accepted: resp.acceptedCount,
        duplicates: resp.duplicateCount,
        rejected: resp.rejected.length,
      );
    } on DioException catch (e) {
      final apiError = ApiError.fromDioException(e);
      state = SyncFailed(apiError.message);
    } catch (_) {
      state = const SyncFailed('Sync failed.');
    } finally {
      _inProgress = false;
      if (_pendingSync) {
        _pendingSync = false;
        unawaited(syncUnsyncedSessions());
      }
    }
  }

  Future<void> _applyIngestResult({
    required List<LocalSession> submitted,
    required SessionsIngestResponse response,
  }) async {
    final rejected = <String>{};
    for (final item in response.rejected) {
      rejected.add(item.clientSessionId);
    }

    final synced = <String>[];
    for (final session in submitted) {
      if (!rejected.contains(session.clientSessionId)) {
        synced.add(session.clientSessionId);
      }
    }
    await ref.read(sessionRepositoryProvider).markSynced(synced);

    await _writeServerStatsCache(response.statsSnapshot);

    ref.read(latestXpAwardsProvider.notifier).set(response.xpAwards);

    ref.invalidate(mergedStatsProvider);
    ref.invalidate(weeklyMinutesProvider);

    if (response.acceptedCount > 0) {
      Future.delayed(const Duration(seconds: 2), () {
        ref.read(leaderboardControllerProvider.notifier).load();
      });
    }
  }

  Future<void> _writeServerStatsCache(api.StatsSnapshot snapshot) async {
    final cache = ref.read(statsCacheRepositoryProvider);
    final existing = await cache.readCached();
    final merged = domain.StatsSnapshot(
      currentStreakDays: snapshot.currentStreakDays,
      longestStreakDays: snapshot.longestStreakDays,
      practiceDaysAllTime: snapshot.practiceDaysAllTime,
      minutesThisWeek: snapshot.minutesThisWeek,
      minutesAllTime: snapshot.minutesAllTime,
      sessionsAllTime: snapshot.sessionsAllTime,
      minutesByTechnique: snapshot.minutesByTechnique,
      longestSessionMinutes: existing?.longestSessionMinutes ?? 0,
      favoriteTechniqueId: existing?.favoriteTechniqueId,
      totalBreathsEstimated: existing?.totalBreathsEstimated ?? 0,
      totalXP: snapshot.totalXp,
      currentLevel: snapshot.currentLevel,
      updatedAt: snapshot.updatedAtUtc,
    );

    try {
      await cache.writeCache(merged);
    } catch (_) {}
  }
}
