import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:workshop_manager/screens/cashier_screen.dart';

void main() {
  group('CashierScreen Tests', () {
    testWidgets('should display cashier title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: CashierScreen()));

      expect(find.text('Kasir'), findsOneWidget);
    });

    testWidgets('should display product search field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: CashierScreen()));

      // Should find search field
      expect(find.byType(TextField), findsOneWidget);

      // Check hint text
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(
        (textField.decoration as InputDecoration).hintText,
        'Cari produk...',
      );
    });

    testWidgets('should display cart section', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: CashierScreen()));

      expect(find.text('Keranjang'), findsOneWidget);
      expect(find.text('Total:'), findsOneWidget);
    });

    testWidgets('should display payment method selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: CashierScreen()));

      expect(find.text('Metode Pembayaran'), findsOneWidget);
    });

    testWidgets('should display bayar button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: CashierScreen()));

      expect(find.text('Bayar'), findsOneWidget);
    });

    testWidgets('should have correct app bar title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: CashierScreen()));

      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      final appBarWidget = tester.widget<AppBar>(appBar);
      expect(appBarWidget.title, isA<Text>());
      expect((appBarWidget.title as Text).data, 'Kasir');
    });

    testWidgets('should display empty cart message initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: CashierScreen()));

      // Should show loading or empty state initially
      expect(find.text('Keranjang kosong'), findsOneWidget);
    });

    testWidgets('should display product categories', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: CashierScreen()));

      // Should find category filter chips or buttons
      expect(find.text('Semua'), findsOneWidget);
    });

    testWidgets('should have add product functionality', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: CashierScreen()));

      // Look for add buttons or icons
      expect(find.byIcon(Icons.add), findsWidgets);
    });
  });
}
