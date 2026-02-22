import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/onboarding/presentation/steps/session_length_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows 2/5/10/20 minute options', (tester) async {
    int? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: SessionLengthStep(
          valueMinutes: 5,
          onChanged: (value) => selected = value,
        ),
      ),
    );

    expect(find.text('2 min'), findsOneWidget);
    expect(find.text('5 min'), findsOneWidget);
    expect(find.text('10 min'), findsOneWidget);
    expect(find.text('20 min'), findsOneWidget);
    expect(find.text('15 min'), findsNothing);
    expect(find.text('30 min'), findsNothing);

    await tester.tap(find.text('2 min'));
    await tester.pump();
    expect(selected, 2);
  });
}
