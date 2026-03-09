import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/session/presentation/widgets/metronome_pulse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders ring with phase title and timer', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 400,
              child: MetronomePulse(
                bpm: 60,
                progress: 0.5,
                isActiveRound: true,
                phaseTitle: 'BREATHE',
                primaryTimer: '00:13',
                roundLabel: 'Round 1 of 3',
                arcColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.text('BREATHE'), findsOneWidget);
    expect(find.text('00:13'), findsOneWidget);
    expect(find.text('Round 1 of 3'), findsOneWidget);
  });

  testWidgets('shows REST during rest phase', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 400,
              child: MetronomePulse(
                bpm: 60,
                progress: 0.3,
                isActiveRound: false,
                phaseTitle: 'REST',
                primaryTimer: '00:08',
                roundLabel: 'Round 1 of 3',
                arcColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('REST'), findsOneWidget);
    expect(find.text('00:08'), findsOneWidget);
    expect(find.text('Round 1 of 3'), findsOneWidget);
  });

  testWidgets('pulse animation runs during active round', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 400,
              child: MetronomePulse(
                bpm: 60,
                progress: 0.5,
                isActiveRound: true,
                phaseTitle: 'BREATHE',
                primaryTimer: '00:10',
                roundLabel: null,
                arcColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(MetronomePulse), findsOneWidget);
  });
}
