import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_manager/main.dart';
import 'package:workshop_manager/widgets/app_drawer.dart';

void main() {
  group('Main App Tests', () {
    testWidgets('should render MyApp widget', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(MyApp), findsOneWidget);
    });

    testWidgets('should render MainScreen with drawer navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(MainScreen), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should show drawer when menu button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      // Find and tap the menu button
      final menuButton = find.byIcon(Icons.menu);
      expect(menuButton, findsOneWidget);

      await tester.tap(menuButton);
      await tester.pump(); // Use pump instead of pumpAndSettle

      // Drawer should be visible
      expect(find.byType(AppDrawer), findsOneWidget);
    });

    testWidgets('should navigate between screens', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump();

      // Tap on Workshop menu item
      await tester.tap(find.text('Workshop'));
      await tester.pump();

      // Should navigate to Workshop screen
      expect(find.text('Workshop'), findsOneWidget);
    });
  });
}
