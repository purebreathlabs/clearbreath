import 'dart:ui';

import '../domain/session_phase.dart';

abstract final class PhaseColors {
  static const Color inhale = Color(0xFF6EBAD2);
  static const Color exhale = Color(0xFFD4A574);
  static const Color hold = Color(0xFFA78BBA);
  static const Color rest = Color(0xFF7EC9A3);
  static const Color round = Color(0xFFD4836D);
  static const Color countdown = Color(0xFF8A8A8A);
  static const Color paused = Color(0xFF5C5C5C);
  static const Color completed = Color(0xFFFFFFFF);

  static Color forPhase(SessionPhase phase) {
    return switch (phase) {
      SessionPhase.inhale => inhale,
      SessionPhase.exhale => exhale,
      SessionPhase.hold || SessionPhase.holdAfterExhale => hold,
      SessionPhase.rest => rest,
      SessionPhase.round => round,
      SessionPhase.countdown || SessionPhase.idle => countdown,
      SessionPhase.paused => paused,
      SessionPhase.completed => completed,
    };
  }
}
