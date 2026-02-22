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

    expect(find.text('2 minutes'), findsOneWidget);
    expect(find.text('5 minutes'), findsOneWidget);
    expect(find.text('10 minutes'), findsOneWidget);
    expect(find.text('20 minutes'), findsOneWidget);
    expect(find.text('15 minutes'), findsNothing);
    expect(find.text('30 minutes'), findsNothing);

    await tester.tap(find.text('2 minutes'));
    await tester.pump();
    expect(selected, 2);
  });
}
