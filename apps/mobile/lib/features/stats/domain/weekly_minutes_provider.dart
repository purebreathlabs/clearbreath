import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/data/session_repository.dart';

final weeklyMinutesProvider =
    FutureProvider.family<List<int>, int>((ref, weekOffset) async {
  final minutesByDay =
      await ref.watch(sessionRepositoryProvider).minutesByLocalDay();

  final nowUtc = DateTime.now().toUtc();
  final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
  final nowLocal = nowUtc.add(Duration(minutes: offsetMinutes));
  final todayKey = DateTime.utc(nowLocal.year, nowLocal.month, nowLocal.day);
  final currentWeekStart = _startOfWeekKey(todayKey);
  final targetWeekStart =
      currentWeekStart.add(Duration(days: weekOffset * 7));

  final result = <int>[];
  for (var i = 0; i < 7; i++) {
    final dayKey = targetWeekStart.add(Duration(days: i));
    result.add(minutesByDay[dayKey] ?? 0);
  }
  return List.unmodifiable(result);
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
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}';
}
