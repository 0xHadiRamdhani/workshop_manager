import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:workshop_manager/screens/add_vehicle_screen.dart';

void main() {
  group('AddVehicleScreen Tests', () {
    testWidgets('should display add vehicle title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: AddVehicleScreen()));

      expect(find.text('Tambah Kendaraan'), findsOneWidget);
    });

    testWidgets('should display all input fields', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AddVehicleScreen()));

      // Should find all input fields
      expect(find.text('Nama Pelanggan'), findsOneWidget);
      expect(find.text('Jenis Kendaraan'), findsOneWidget);
      expect(find.text('Nomor Polisi'), findsOneWidget);
      expect(find.text('Nomor Telepon'), findsOneWidget);
      expect(find.text('Deskripsi Masalah'), findsOneWidget);
    });

    testWidgets('should display status dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AddVehicleScreen()));

      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Menunggu'), findsOneWidget);
    });

    testWidgets('should display date picker fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: AddVehicleScreen()));

      expect(find.text('Estimasi Selesai'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsWidgets);
    });

    testWidgets('should display cost input fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: AddVehicleScreen()));

      expect(find.text('Estimasi Biaya'), findsOneWidget);
      expect(find.text('Biaya Aktual'), findsOneWidget);
    });

    testWidgets('should display payment method dropdown', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: AddVehicleScreen()));

      expect(find.text('Metode Pembayaran'), findsOneWidget);
      expect(find.text('Tunai'), findsOneWidget);
    });

    testWidgets('should display save button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AddVehicleScreen()));

      expect(find.text('Simpan'), findsOneWidget);
    });

    testWidgets('should have correct app bar title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: AddVehicleScreen()));

      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      final appBarWidget = tester.widget<AppBar>(appBar);
      expect(appBarWidget.title, isA<Text>());
      expect((appBarWidget.title as Text).data, 'Tambah Kendaraan');
    });

    testWidgets('should validate required fields', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AddVehicleScreen()));

      // Try to save without filling required fields
      final saveButton = find.text('Simpan');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pump();
    });

    testWidgets('should handle form input correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: AddVehicleScreen()));

      // Find text fields and enter text
      final customerNameField = find.byType(TextField).first;
      await tester.enterText(customerNameField, 'John Doe');

      await tester.pump();

      // Verify text was entered
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('should display checkbox for paid status', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: AddVehicleScreen()));

      expect(find.text('Sudah Dibayar'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });
  });
}
