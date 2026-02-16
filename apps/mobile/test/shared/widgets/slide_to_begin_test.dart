import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/shared/widgets/slide_to_begin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('slide to begin submits when dragged far enough', (tester) async {
    var submitted = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: SlideToBegin(
                key: const Key('slide_to_begin'),
                label: 'Slide to begin',
                onSubmitted: () => submitted = true,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.drag(
      find.byKey(const Key('slide_to_begin')),
      const Offset(600, 0),
    );
    await tester.pumpAndSettle();

    expect(submitted, isTrue);
  });

  testWidgets('slide to begin resets when released early', (tester) async {
    var submitted = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: SlideToBegin(
                key: const Key('slide_to_begin'),
                label: 'Slide to begin',
                onSubmitted: () => submitted = true,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.drag(
      find.byKey(const Key('slide_to_begin')),
      const Offset(80, 0),
    );
    await tester.pumpAndSettle();

    expect(submitted, isFalse);
  });
}
