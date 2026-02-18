import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/intro/presentation/intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('intro screen shows copy and slider', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const IntroScreen(from: '/home'),
        ),
      ),
    );

    expect(find.text('Meet ClearBreath'), findsOneWidget);
    expect(find.text('Breathe with intention.'), findsOneWidget);
    expect(find.text('Authentic techniques'), findsOneWidget);
    expect(find.text('Guided sessions'), findsOneWidget);
    expect(find.text('Streaks that motivate'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });
}
