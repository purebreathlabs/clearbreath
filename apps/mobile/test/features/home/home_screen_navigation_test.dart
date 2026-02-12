import 'package:clearbreath/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('navigates from home to design system', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ClearBreathApp(),
      ),
    );

    expect(find.text('Open Design System'), findsOneWidget);
    await tester.tap(find.text('Open Design System'));
    await tester.pumpAndSettle();

    expect(find.text('Design System'), findsOneWidget);
    expect(find.text('Typography'), findsOneWidget);
  });
}
