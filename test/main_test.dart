import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:workshop_manager/main.dart';

void main() {
  group('Main App Tests', () {
    testWidgets('should create WorkshopManagerApp', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(WorkshopManagerApp());

      expect(find.byType(WorkshopManagerApp), findsOneWidget);
    });

    testWidgets('should have MainScreen as home', (WidgetTester tester) async {
      await tester.pumpWidget(WorkshopManagerApp());

      final mainScreen = find.byType(MainScreen);
      expect(mainScreen, findsOneWidget);
    });
  });

  group('MainScreen Tests', () {
    testWidgets('should create MainScreen with correct structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(CupertinoApp(home: MainScreen()));

      expect(find.byType(MainScreen), findsOneWidget);
      expect(find.byType(CupertinoTabScaffold), findsOneWidget);
    });

    testWidgets('should have three tabs', (WidgetTester tester) async {
      await tester.pumpWidget(CupertinoApp(home: MainScreen()));

      final tabBar = find.byType(CupertinoTabBar);
      expect(tabBar, findsOneWidget);

      final tabBarWidget = tester.widget<CupertinoTabBar>(tabBar);
      expect(tabBarWidget.items.length, 3);
    });

    testWidgets('should have correct tab labels', (WidgetTester tester) async {
      await tester.pumpWidget(CupertinoApp(home: MainScreen()));

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Workshop'), findsOneWidget);
      expect(find.text('Kasir'), findsOneWidget);
    });

    testWidgets('should have correct tab icons', (WidgetTester tester) async {
      await tester.pumpWidget(CupertinoApp(home: MainScreen()));

      expect(find.byIcon(CupertinoIcons.home), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.wrench), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.money_dollar), findsOneWidget);
    });

    testWidgets('should switch between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(CupertinoApp(home: MainScreen()));

      // Initially should show Dashboard
      expect(find.text('Dashboard'), findsOneWidget);

      // Find and tap on Workshop tab
      final workshopTab = find.text('Workshop');
      expect(workshopTab, findsOneWidget);

      await tester.tap(workshopTab);
      await tester.pumpAndSettle();

      // Should still find Workshop after tapping
      expect(find.text('Workshop'), findsOneWidget);
    });
  });
}
