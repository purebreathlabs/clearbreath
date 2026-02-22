import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/session/domain/session_phase.dart';
import 'package:clearbreath/features/session/presentation/widgets/metronome_pulse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders round label when round info provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: MetronomePulse(
                bpm: 60,
                phase: SessionPhase.round,
                phaseRemaining: Duration(seconds: 2),
                phaseDuration: Duration(seconds: 2),
                currentRound: 2,
                totalRounds: 3,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('metronome_round_label')), findsOneWidget);
    expect(find.text('Round 2 of 3'), findsOneWidget);
    expect(find.byKey(const Key('metronome_rest_remaining')), findsNothing);
  });

  testWidgets('renders rest remaining during rest phase', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: MetronomePulse(
                bpm: 60,
                phase: SessionPhase.rest,
                phaseRemaining: Duration(seconds: 2),
                phaseDuration: Duration(seconds: 1),
                currentRound: 1,
                totalRounds: 3,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('metronome_rest_remaining')), findsOneWidget);
    expect(find.text('00:02'), findsOneWidget);
  });
}
