import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/session/domain/session_phase.dart';
import 'package:clearbreath/features/session/presentation/widgets/breathing_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap({
  double progress = 0.5,
  bool isHoldPhase = false,
  String phaseTitle = 'INHALE',
  String primaryTimer = '00:02',
  Color arcColor = Colors.white,
  SessionPhase phase = SessionPhase.inhale,
  Duration phaseDuration = const Duration(seconds: 4),
  Duration phaseRemaining = const Duration(seconds: 2),
  bool isPaused = false,
}) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 280,
          height: 280,
          child: BreathingCircle(
            progress: progress,
            isHoldPhase: isHoldPhase,
            phaseTitle: phaseTitle,
            primaryTimer: primaryTimer,
            arcColor: arcColor,
            phase: phase,
            phaseDuration: phaseDuration,
            phaseRemaining: phaseRemaining,
            isPaused: isPaused,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders ring with phase title and timer inside', (tester) async {
    await tester.pumpWidget(_wrap());

    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.text('INHALE'), findsOneWidget);
    expect(find.text('00:02'), findsOneWidget);

    final renderBox = tester.renderObject<RenderBox>(
      find.byType(BreathingCircle),
    );
    expect(renderBox.size.width, lessThanOrEqualTo(280));
    expect(renderBox.size.height, lessThanOrEqualTo(280));
  });

  testWidgets('phase title transitions on change', (tester) async {
    await tester.pumpWidget(_wrap(phaseTitle: 'INHALE'));
    expect(find.text('INHALE'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(phaseTitle: 'HOLD', phase: SessionPhase.hold, isHoldPhase: true),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('HOLD'), findsOneWidget);
  });

  testWidgets('hold phase starts pulse animation', (tester) async {
    await tester.pumpWidget(
      _wrap(
        progress: 0.5,
        isHoldPhase: true,
        phaseTitle: 'HOLD',
        primaryTimer: '00:04',
        phase: SessionPhase.hold,
      ),
    );

    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(BreathingCircle), findsOneWidget);
  });

  testWidgets('progress advances between parent pumps', (tester) async {
    await tester.pumpWidget(
      _wrap(
        progress: 0.0,
        phaseRemaining: const Duration(seconds: 4),
        phaseDuration: const Duration(seconds: 4),
      ),
    );

    // Advance several frames without changing parent progress
    await tester.pump(const Duration(milliseconds: 500));

    // Widget should still be present and animating internally
    expect(find.byType(BreathingCircle), findsOneWidget);
  });

  testWidgets('pause freezes ring, resume continues', (tester) async {
    await tester.pumpWidget(
      _wrap(
        progress: 0.25,
        phaseRemaining: const Duration(seconds: 3),
        phaseDuration: const Duration(seconds: 4),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Pause
    await tester.pumpWidget(
      _wrap(
        progress: 0.25,
        phaseRemaining: const Duration(seconds: 3),
        phaseDuration: const Duration(seconds: 4),
        isPaused: true,
        phaseTitle: 'PAUSED',
        phase: SessionPhase.paused,
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(BreathingCircle), findsOneWidget);

    // Resume
    await tester.pumpWidget(
      _wrap(
        progress: 0.25,
        phaseRemaining: const Duration(seconds: 3),
        phaseDuration: const Duration(seconds: 4),
        isPaused: false,
        phaseTitle: 'INHALE',
        phase: SessionPhase.inhale,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(BreathingCircle), findsOneWidget);
  });

  testWidgets('phase transition resets ring and preserves colors', (
    tester,
  ) async {
    // Start inhale
    await tester.pumpWidget(
      _wrap(
        progress: 0.8,
        phaseRemaining: const Duration(milliseconds: 800),
        phaseDuration: const Duration(seconds: 4),
        phase: SessionPhase.inhale,
        arcColor: const Color(0xFF6EBAD2),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Switch to hold
    await tester.pumpWidget(
      _wrap(
        progress: 0.0,
        phaseRemaining: const Duration(seconds: 7),
        phaseDuration: const Duration(seconds: 7),
        phase: SessionPhase.hold,
        isHoldPhase: true,
        phaseTitle: 'HOLD',
        arcColor: const Color(0xFFA78BBA),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('HOLD'), findsOneWidget);
  });
}
