import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/session/domain/session_tick_source.dart';
import 'package:clearbreath/features/session/presentation/session_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('runs countdown and transitions into phases', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionTickSourceProvider.overrideWithValue(
            FixedSessionTickSource(const Duration(milliseconds: 50)),
          ),
        ],
        child: MaterialApp(theme: AppTheme.dark(), home: const SessionScreen()),
      ),
    );

    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(find.text('Countdown'), findsOneWidget);
    expect(find.byKey(const Key('session_countdown_value')), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('Inhale'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump();

    expect(find.text('Hold'), findsOneWidget);
  });

  testWidgets('pause resume and stop update the screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionTickSourceProvider.overrideWithValue(
            FixedSessionTickSource(const Duration(milliseconds: 50)),
          ),
        ],
        child: MaterialApp(theme: AppTheme.dark(), home: const SessionScreen()),
      ),
    );

    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('Inhale'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);

    await tester.tap(find.text('Pause'));
    await tester.pump();

    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Paused'), findsOneWidget);

    await tester.tap(find.text('Resume'));
    await tester.pump();
    expect(find.text('Paused'), findsNothing);

    await tester.tap(find.text('Stop'));
    await tester.pump();
    expect(find.text('Ready'), findsOneWidget);
  });
}
