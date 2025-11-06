import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:workshop_manager/screens/dashboard_screen.dart';

void main() {
  group('DashboardScreen Tests', () {
    testWidgets('should display dashboard title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: DashboardScreen()));

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('should display summary cards', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: DashboardScreen()));

      // Should find summary card titles
      expect(find.text('Transaksi Hari Ini'), findsOneWidget);
      expect(find.text('Pendapatan Hari Ini'), findsOneWidget);
      expect(find.text('Kendaraan Selesai'), findsOneWidget);
    });

    testWidgets('should display recent transactions section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: DashboardScreen()));

      expect(find.text('Transaksi Terbaru'), findsOneWidget);
    });

    testWidgets('should display refresh button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: DashboardScreen()));

      // Look for refresh icon
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should have correct app bar title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: DashboardScreen()));

      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      final appBarWidget = tester.widget<AppBar>(appBar);
      expect(appBarWidget.title, isA<Text>());
      expect((appBarWidget.title as Text).data, 'Dashboard');
    });

    testWidgets('should display loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: DashboardScreen()));

      // The screen should show loading initially while fetching data
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have refresh functionality', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: DashboardScreen()));

      // Find and tap refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pump();
    });
  });
}
