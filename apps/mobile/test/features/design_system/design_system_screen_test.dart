import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/design_system/presentation/design_system_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders typography palette and component previews', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark(), home: const DesignSystemScreen()),
    );

    final listView = find.byType(ListView);

    expect(find.text('Design System'), findsOneWidget);
    expect(find.text('Typography'), findsOneWidget);

    expect(find.text('Display Large'), findsOneWidget);
    await tester.drag(listView, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Body Medium'), findsOneWidget);

    await tester.drag(listView, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Color Palette'), findsOneWidget);
    expect(find.text('Background'), findsOneWidget);
    expect(find.text('Text Secondary'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);

    await tester.drag(listView, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Components'), findsOneWidget);
    expect(find.text('Primary Button'), findsOneWidget);
    expect(find.text('Disabled Button'), findsOneWidget);
    expect(find.text('Secondary Button'), findsOneWidget);

    expect(find.byType(Card), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
