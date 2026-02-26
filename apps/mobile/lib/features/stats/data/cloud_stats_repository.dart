import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/models/stats_models.dart' as api;
import '../../auth/domain/auth_state.dart';
import '../../auth/domain/auth_state_provider.dart';
import '../domain/stats_snapshot.dart';
import 'stats_cache_repository.dart';

final cloudStatsRepositoryProvider = Provider<CloudStatsRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  final cache = ref.watch(statsCacheRepositoryProvider);
  return CloudStatsRepository(dio: dio, cache: cache);
});

final cloudStatsProvider = FutureProvider<StatsSnapshot?>((ref) async {
  final auth = ref.watch(authStateProvider);
  if (auth is! AuthStateSignedIn || !auth.sessionReady) {
    return null;
  }
  return ref.watch(cloudStatsRepositoryProvider).fetchAndCache();
});

class CloudStatsRepository {
  CloudStatsRepository({required Dio dio, required StatsCacheRepository cache})
    : _dio = dio,
      _cache = cache;

  final Dio _dio;
  final StatsCacheRepository _cache;

  Future<StatsSnapshot> fetchAndCache() async {
    final resp = await _dio.get<dynamic>('/v1/stats/snapshot');
    final data = resp.data;
    if (data is! Map) {
      throw FormatException('Invalid stats response.');
    }

    final cloud = api.StatsSnapshot.fromJson(data.cast<String, dynamic>());
    final existing = await _cache.readCached();
    final merged = _toDomain(cloud, existing);

    try {
      await _cache.writeCache(merged);
    } catch (_) {}

    return merged;
  }

  StatsSnapshot _toDomain(api.StatsSnapshot cloud, StatsSnapshot? existing) {
    return StatsSnapshot(
      currentStreakDays: cloud.currentStreakDays,
      longestStreakDays: cloud.longestStreakDays,
      practiceDaysAllTime: cloud.practiceDaysAllTime,
      minutesThisWeek: cloud.minutesThisWeek,
      minutesAllTime: cloud.minutesAllTime,
      sessionsAllTime: cloud.sessionsAllTime,
      minutesByTechnique: cloud.minutesByTechnique,
      longestSessionMinutes: existing?.longestSessionMinutes ?? 0,
      favoriteTechniqueId: existing?.favoriteTechniqueId,
      totalBreathsEstimated: existing?.totalBreathsEstimated ?? 0,
      totalXP: cloud.totalXp,
      currentLevel: cloud.currentLevel,
      updatedAt: cloud.updatedAtUtc,
    );
  }
}
