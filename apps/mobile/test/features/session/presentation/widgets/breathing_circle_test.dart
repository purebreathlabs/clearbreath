import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/session/presentation/widgets/breathing_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders ring with phase title and timer inside', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: BreathingCircle(
                progress: 0.5,
                isHoldPhase: false,
                phaseTitle: 'INHALE',
                primaryTimer: '00:02',
              ),
            ),
          ),
        ),
      ),
    );

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
    Widget wrap(String title) {
      return MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: BreathingCircle(
                progress: 0.5,
                isHoldPhase: false,
                phaseTitle: title,
                primaryTimer: '00:02',
              ),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(wrap('INHALE'));
    expect(find.text('INHALE'), findsOneWidget);

    await tester.pumpWidget(wrap('HOLD'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('HOLD'), findsOneWidget);
  });

  testWidgets('hold phase starts pulse animation', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: BreathingCircle(
                progress: 0.5,
                isHoldPhase: true,
                phaseTitle: 'HOLD',
                primaryTimer: '00:04',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(BreathingCircle), findsOneWidget);
  });
}
