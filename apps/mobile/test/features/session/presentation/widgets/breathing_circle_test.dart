import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/session/domain/session_phase.dart';
import 'package:clearbreath/features/session/presentation/widgets/breathing_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders phase label and updates on change', (tester) async {
    Widget wrap(SessionPhase phase) {
      return MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: BreathingCircle(
                phase: phase,
                phaseRemaining: const Duration(milliseconds: 500),
                phaseDuration: const Duration(seconds: 1),
              ),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(wrap(SessionPhase.inhale));
    expect(find.text('INHALE'), findsOneWidget);

    await tester.pumpWidget(wrap(SessionPhase.exhale));
    await tester.pump();
    expect(find.text('EXHALE'), findsOneWidget);

    await tester.pumpWidget(wrap(SessionPhase.hold));
    await tester.pump();
    expect(find.text('HOLD'), findsOneWidget);
  });
}

