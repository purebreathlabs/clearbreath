import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/server_status_provider.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/domain/auth_state_provider.dart';
import '../data/cloud_stats_repository.dart';
import '../../session/data/session_repository.dart';
import '../../sync/domain/merged_stats_provider.dart';

final localWeeklyMinutesProvider = FutureProvider.family<List<int>, int>((
  ref,
  weekOffset,
) async {
  final minutesByDay = await ref
      .watch(sessionRepositoryProvider)
      .minutesByLocalDay();

  final nowUtc = DateTime.now().toUtc();
  final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
  final nowLocal = nowUtc.add(Duration(minutes: offsetMinutes));
  final todayKey = DateTime.utc(nowLocal.year, nowLocal.month, nowLocal.day);
  final currentWeekStart = _startOfWeekKey(todayKey);
  final targetWeekStart = currentWeekStart.add(Duration(days: weekOffset * 7));

  final result = <int>[];
  for (var i = 0; i < 7; i++) {
    final dayKey = targetWeekStart.add(Duration(days: i));
    result.add(minutesByDay[dayKey] ?? 0);
  }
  return List.unmodifiable(result);
});

final cloudWeeklyMinutesProvider = FutureProvider.family<List<int>, int>((
  ref,
  weekOffset,
) async {
  final auth = ref.watch(authStateProvider);
  if (auth is! AuthStateSignedIn || !auth.sessionReady) {
    throw StateError('Cloud weekly minutes require a signed-in session.');
  }
  return ref.watch(cloudStatsRepositoryProvider).fetchWeeklyMinutes(weekOffset);
});

final mergedWeeklyMinutesProvider = FutureProvider.family<List<int>, int>((
  ref,
  weekOffset,
) async {
  if (weekOffset == 0) {
    final snapshot = await ref.watch(mergedStatsProvider.future);
    if (snapshot.weeklyMinutesByDay.length == 7) {
      return snapshot.weeklyMinutesByDay;
    }
  }

  final auth = ref.watch(authStateProvider);
  if (auth is AuthStateSignedIn && auth.sessionReady) {
    final serverOnline = ref.watch(serverStatusProvider).asData?.value == true;
    if (serverOnline) {
      try {
        return await ref.watch(cloudWeeklyMinutesProvider(weekOffset).future);
      } catch (_) {}
    }
  }

  return ref.watch(localWeeklyMinutesProvider(weekOffset).future);
});

DateTime _startOfWeekKey(DateTime todayKey) {
  final daysSinceMonday = todayKey.weekday - DateTime.monday;
  return todayKey.subtract(Duration(days: daysSinceMonday));
}

DateTime weekStartForOffset(int weekOffset) {
  final nowUtc = DateTime.now().toUtc();
  final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
  final nowLocal = nowUtc.add(Duration(minutes: offsetMinutes));
  final todayKey = DateTime.utc(nowLocal.year, nowLocal.month, nowLocal.day);
  final currentWeekStart = _startOfWeekKey(todayKey);
  return currentWeekStart.add(Duration(days: weekOffset * 7));
}

String weekTitle(int weekOffset) {
  if (weekOffset == 0) return 'This week';
  if (weekOffset == -1) return 'Last week';
  final monday = weekStartForOffset(weekOffset);
  final sunday = monday.add(const Duration(days: 6));
  return '${_formatShortDate(monday)} \u2013 ${_formatShortDate(sunday)}';
}

String _formatShortDate(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}';
}
