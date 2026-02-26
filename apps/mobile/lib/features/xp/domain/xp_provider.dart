import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sync/domain/merged_stats_provider.dart';
import 'xp_state.dart';

final mergedXPProvider = FutureProvider<XPState>((ref) async {
  final stats = await ref.watch(mergedStatsProvider.future);
  return XPState.fromTotalXP(
    totalXP: stats.totalXP,
    currentStreakDays: stats.currentStreakDays,
    practiceDaysAllTime: stats.practiceDaysAllTime,
  );
});
