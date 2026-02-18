class SessionPreset {
  const SessionPreset({
    required this.inhaleMs,
    required this.holdMs,
    required this.exhaleMs,
    this.holdAfterExhaleMs = 0,
  });

  final int inhaleMs;
  final int holdMs;
  final int exhaleMs;
  final int holdAfterExhaleMs;
}
