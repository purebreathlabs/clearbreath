import 'package:clearbreath/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('tab branches preserve navigation stack', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ClearBreathApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Design System'));
    await tester.pumpAndSettle();
    expect(find.text('Design System'), findsOneWidget);

    await tester.tap(find.text('Techniques'));
    await tester.pumpAndSettle();
    expect(find.text('Design System'), findsNothing);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Design System'), findsOneWidget);
  });
}
