DateTime? nextStreakWarningTime(
  int currentStreakDays,
  bool hasQualifyingSessionToday,
  DateTime now,
) {
  if (currentStreakDays <= 0) {
    return null;
  }
  if (hasQualifyingSessionToday) {
    return null;
  }

  final localNow = now.isUtc ? now.toLocal() : now;
  final candidate = DateTime(
    localNow.year,
    localNow.month,
    localNow.day,
    22,
    0,
  );

  if (!candidate.isAfter(localNow)) {
    return null;
  }

  return candidate;
}

