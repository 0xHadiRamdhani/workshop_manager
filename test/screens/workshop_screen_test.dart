import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:workshop_manager/screens/workshop_screen.dart';

void main() {
  group('WorkshopScreen Tests', () {
    testWidgets('should display workshop title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: WorkshopScreen()));

      expect(find.text('Bengkel'), findsOneWidget);
    });

    testWidgets('should display vehicle list section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: WorkshopScreen()));

      expect(find.text('Daftar Kendaraan'), findsOneWidget);
    });

    testWidgets('should display add vehicle button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: WorkshopScreen()));

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Tambah Kendaraan'), findsOneWidget);
    });

    testWidgets('should display vehicle status filters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: WorkshopScreen()));

      // Should find status filter chips or buttons
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Menunggu'), findsOneWidget);
      expect(find.text('Dalam Proses'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
    });

    testWidgets('should display search field', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: WorkshopScreen()));

      // Should find search field
      expect(find.byType(TextField), findsOneWidget);

      // Check hint text
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(
        (textField.decoration as InputDecoration).hintText,
        'Cari kendaraan...',
      );
    });

    testWidgets('should have correct app bar title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: WorkshopScreen()));

      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      final appBarWidget = tester.widget<AppBar>(appBar);
      expect(appBarWidget.title, isA<Text>());
      expect((appBarWidget.title as Text).data, 'Bengkel');
    });

    testWidgets('should display empty vehicle message initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: WorkshopScreen()));

      // Should show loading or empty state initially
      expect(find.text('Tidak ada kendaraan'), findsOneWidget);
    });

    testWidgets('should have refresh functionality', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: WorkshopScreen()));

      // Find and tap refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pump();
    });

    testWidgets('should display vehicle cards when data is loaded', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: WorkshopScreen()));

      // Should find vehicle card structure
      expect(find.byType(Card), findsWidgets);
    });
  });
}
