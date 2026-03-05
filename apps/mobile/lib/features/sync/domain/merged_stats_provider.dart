import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/server_status_provider.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/domain/auth_state_provider.dart';
import '../../stats/data/cloud_stats_repository.dart';
import '../../stats/data/stats_cache_repository.dart';
import '../../stats/domain/stats_engine.dart';
import '../../stats/domain/stats_snapshot.dart';

final mergedStatsProvider = FutureProvider<StatsSnapshot>((ref) async {
  final auth = ref.watch(authStateProvider);

  if (auth is AuthStateSignedIn) {
    StatsSnapshot? cached;
    try {
      cached = await ref.watch(statsCacheRepositoryProvider).readCached();
    } catch (_) {}

    if (cached != null) {
      final age = DateTime.now().toUtc().difference(cached.updatedAt.toUtc());
      if (age < const Duration(minutes: 5) &&
          cached.weeklyMinutesByDay.length == 7) {
        return cached;
      }
    }

    if (auth.sessionReady) {
      final serverOnline =
          ref.watch(serverStatusProvider).asData?.value == true;

      if (serverOnline) {
        try {
          final cloud = await ref.watch(cloudStatsProvider.future);
          if (cloud != null) {
            return cloud;
          }
        } catch (_) {}
      }
    }

    if (cached != null) {
      return cached;
    }

    final local = await ref.watch(localStatsProvider.future);
    return local;
  }

  return ref.watch(localStatsProvider.future);
});
