import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/share/domain/share_card_renderer.dart';
import 'package:clearbreath/features/share/presentation/share_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('generates non-empty PNG bytes', (tester) async {
    final repaintKey = GlobalKey();
    const renderer = ShareCardRenderer();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: repaintKey,
              child: const SizedBox(
                width: 360,
                height: 360,
                child: ShareCardWidget(
                  streakDays: 5,
                  minutesToday: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final bytes = await tester.runAsync(() async {
      return renderer
          .renderPngBytes(repaintKey, pixelRatio: 1.0)
          .timeout(const Duration(seconds: 2));
    });
    expect(bytes, isNotNull);
    final data = bytes!;
    expect(data.length, greaterThan(100));
    expect(
      data.sublist(0, 8),
      equals(<int>[137, 80, 78, 71, 13, 10, 26, 10]),
    );
  });
}
