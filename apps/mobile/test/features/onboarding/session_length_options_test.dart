import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/onboarding/presentation/steps/session_length_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows 2/5/10/20 minute options with subtitles', (tester) async {
    int? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SessionLengthStep(
            valueMinutes: 5,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(find.text('2 minutes'), findsOneWidget);
    expect(find.text('5 minutes'), findsOneWidget);
    expect(find.text('10 minutes'), findsOneWidget);
    expect(find.text('20 minutes'), findsOneWidget);
    expect(find.text('15 min'), findsNothing);
    expect(find.text('30 min'), findsNothing);

    expect(find.text('A quick reset between tasks'), findsOneWidget);
    expect(find.text('Enough to shift your state'), findsOneWidget);
    expect(find.text('A solid daily practice'), findsOneWidget);
    expect(
      find.text('Deep session for experienced practitioners'),
      findsOneWidget,
    );

    expect(find.text('Recommended'), findsOneWidget);

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('2 minutes'));
    await tester.pump();
    expect(selected, 2);
  });

  testWidgets('check icon follows selection', (tester) async {
    int currentValue = 5;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SessionLengthStep(
                valueMinutes: currentValue,
                onChanged: (value) => setState(() => currentValue = value),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('10 minutes'));
    await tester.pump();

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(currentValue, 10);
  });
}
