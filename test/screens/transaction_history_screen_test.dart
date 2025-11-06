import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:workshop_manager/screens/transaction_history_screen.dart';

void main() {
  group('TransactionHistoryScreen Tests', () {
    testWidgets('should display history title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: TransactionHistoryScreen()));

      expect(find.text('Riwayat Transaksi'), findsOneWidget);
    });

    testWidgets('should display date range selector', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: TransactionHistoryScreen()));

      expect(find.text('Pilih Rentang Tanggal'), findsOneWidget);
      expect(find.text('Dari:'), findsOneWidget);
      expect(find.text('Sampai:'), findsOneWidget);
    });

    testWidgets('should display filter options', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: TransactionHistoryScreen()));

      expect(find.text('Filter Status'), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Lunas'), findsOneWidget);
      expect(find.text('Dibatalkan'), findsOneWidget);
    });

    testWidgets('should display search field', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: TransactionHistoryScreen()));

      // Should find search field
      expect(find.byType(TextField), findsOneWidget);

      // Check hint text
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(
        (textField.decoration as InputDecoration).hintText,
        'Cari transaksi...',
      );
    });

    testWidgets('should display transaction list section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: TransactionHistoryScreen()));

      expect(find.text('Daftar Transaksi'), findsOneWidget);
    });

    testWidgets('should have correct app bar title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: TransactionHistoryScreen()));

      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      final appBarWidget = tester.widget<AppBar>(appBar);
      expect(appBarWidget.title, isA<Text>());
      expect((appBarWidget.title as Text).data, 'Riwayat Transaksi');
    });

    testWidgets('should display empty transaction message initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: TransactionHistoryScreen()));

      // Should show loading or empty state initially
      expect(find.text('Tidak ada transaksi'), findsOneWidget);
    });

    testWidgets('should have refresh functionality', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: TransactionHistoryScreen()));

      // Find and tap refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pump();
    });

    testWidgets('should display date picker buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: TransactionHistoryScreen()));

      // Should find date picker buttons
      expect(find.byIcon(Icons.calendar_today), findsWidgets);
    });

    testWidgets('should display total summary', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: TransactionHistoryScreen()));

      expect(find.text('Total:'), findsOneWidget);
      expect(find.text('Rp 0'), findsOneWidget);
    });
  });
}
