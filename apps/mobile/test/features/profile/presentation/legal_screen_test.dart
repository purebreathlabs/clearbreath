import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/profile/presentation/legal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpLegal(
    WidgetTester tester, {
    required String type,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: LegalScreen(type: type),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('disclaimer renders markdown without raw newline escapes', (
    tester,
  ) async {
    await pumpLegal(tester, type: 'disclaimer');

    expect(find.text('Disclaimer'), findsWidgets);
    expect(
      find.textContaining(
        'ClearBreath is for wellness and relaxation purposes only.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining(r'\n'), findsNothing);
    expect(find.text('Latest version'), findsNothing);
  });

  testWidgets('privacy renders from asset and shows latest version', (
    tester,
  ) async {
    await pumpLegal(tester, type: 'privacy');

    expect(find.text('Privacy Policy'), findsWidgets);
    expect(find.textContaining('Last updated:'), findsOneWidget);
    expect(find.text('Latest version'), findsOneWidget);
  });

  testWidgets('terms renders from asset and shows latest version', (
    tester,
  ) async {
    await pumpLegal(tester, type: 'terms');

    expect(find.text('Terms of Service'), findsWidgets);
    expect(find.textContaining('Last updated:'), findsOneWidget);
    expect(find.text('Latest version'), findsOneWidget);
  });

  testWidgets('unknown type shows not found message', (tester) async {
    await pumpLegal(tester, type: 'does-not-exist');

    expect(find.text('Document not found.'), findsOneWidget);
  });
}
