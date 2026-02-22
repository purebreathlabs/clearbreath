import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/data/session_repository.dart';

final weeklyMinutesProvider = FutureProvider<List<int>>((ref) async {
  final minutesByDay =
      await ref.watch(sessionRepositoryProvider).minutesByLocalDay();

  final nowUtc = DateTime.now().toUtc();
  final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
  final nowLocal = nowUtc.add(Duration(minutes: offsetMinutes));
  final todayKey = DateTime.utc(nowLocal.year, nowLocal.month, nowLocal.day);
  final startOfWeekKey = _startOfWeekKey(todayKey);

  final result = <int>[];
  for (var i = 0; i < 7; i++) {
    final dayKey = startOfWeekKey.add(Duration(days: i));
    result.add(minutesByDay[dayKey] ?? 0);
  }
  return List.unmodifiable(result);
});

DateTime _startOfWeekKey(DateTime todayKey) {
  final daysSinceMonday = todayKey.weekday - DateTime.monday;
  return todayKey.subtract(Duration(days: daysSinceMonday));
}

