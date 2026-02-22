int currentStreak(Map<DateTime, int> minutesByLocalDay, DateTime today) {
  if (minutesByLocalDay.isEmpty) {
    return 0;
  }

  final normalized = _normalize(minutesByLocalDay);
  final todayKey = _dayKey(today);
  final todayMinutes = normalized[todayKey] ?? 0;
  final start = todayMinutes >= 2
      ? todayKey
      : todayKey.subtract(const Duration(days: 1));

  var streak = 0;
  var day = start;

  while (true) {
    final minutes = normalized[day] ?? 0;
    if (minutes < 2) {
      break;
    }
    streak += 1;
    day = day.subtract(const Duration(days: 1));
  }

  return streak;
}

int longestStreak(Map<DateTime, int> minutesByLocalDay) {
  if (minutesByLocalDay.isEmpty) {
    return 0;
  }

  final normalized = _normalize(minutesByLocalDay);
  final keys = normalized.keys.toList()..sort(_compareDays);

  var best = 0;
  var run = 0;
  DateTime? previous;

  for (final key in keys) {
    final minutes = normalized[key] ?? 0;
    if (minutes < 2) {
      run = 0;
      previous = key;
      continue;
    }

    if (previous != null && key.difference(previous).inDays == 1 && run > 0) {
      run += 1;
    } else {
      run = 1;
    }

    if (run > best) {
      best = run;
    }
    previous = key;
  }

  return best;
}

DateTime _dayKey(DateTime value) {
  return DateTime.utc(value.year, value.month, value.day);
}

int _compareDays(DateTime a, DateTime b) {
  return a.compareTo(b);
}

Map<DateTime, int> _normalize(Map<DateTime, int> input) {
  final result = <DateTime, int>{};
  for (final entry in input.entries) {
    final key = _dayKey(entry.key);
    result[key] = (result[key] ?? 0) + entry.value;
  }
  return result;
}
