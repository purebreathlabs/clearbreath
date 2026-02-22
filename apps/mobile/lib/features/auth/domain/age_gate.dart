bool isEligible(int birthYear, DateTime now) {
  final year = now.year;
  if (birthYear < 1900 || birthYear > year) {
    return false;
  }
  final age = year - birthYear;
  return age >= 13;
}

