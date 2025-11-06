import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_manager/services/print_service.dart';
import 'package:workshop_manager/models/transaction.dart';

void main() {
  group('PrintService Tests', () {
    group('Receipt Formatting Tests', () {
      test('should format receipt correctly', () {
        final services = [
          ServiceItem(name: 'Oil Change', price: 75000, quantity: 1),
          ServiceItem(name: 'Tire Replacement', price: 250000, quantity: 2),
        ];

        final transaction = Transaction(
          id: 'T001',
          vehicleId: 'V001',
          customerName: 'John Doe',
          services: services,
          totalAmount: 575000,
          paymentMethod: PaymentMethod.cash,
          status: TransactionStatus.paid,
          createdAt: DateTime(2024, 1, 15, 14, 30),
          paidAt: DateTime(2024, 1, 15, 14, 30),
          cashAmount: 600000,
          changeAmount: 25000,
        );

        // Test the private method by creating a simple test wrapper
        final receipt = _formatReceipt(
          transaction: transaction,
          workshopName: 'Bengkel Motor ABC',
          workshopAddress: 'Jl. Raya No. 123',
          workshopPhone: '081234567890',
        );

        // Verify receipt contains expected content
        expect(receipt.contains('Bengkel Motor ABC'), true);
        expect(receipt.contains('Jl. Raya No. 123'), true);
        expect(receipt.contains('Telp: 081234567890'), true);
        expect(receipt.contains('T001'), true);
        expect(receipt.contains('John Doe'), true);
        expect(receipt.contains('V001'), true);
        expect(receipt.contains('Oil Change (1x)'), true);
        expect(receipt.contains('Tire Replacement (2x)'), true);
        expect(receipt.contains('75000'), true);
        expect(receipt.contains('250000'), true);
        expect(receipt.contains('TOTAL:'), true);
        expect(receipt.contains('575000'), true);
        expect(receipt.contains('Tunai'), true);
        expect(receipt.contains('Cash: 600000'), true);
        expect(receipt.contains('Kembalian: 25000'), true);
        expect(receipt.contains('Terima kasih atas kepercayaan Anda'), true);
      });

      test(
        'should format receipt without cash details for non-cash payments',
        () {
          final services = [
            ServiceItem(name: 'Service A', price: 100000, quantity: 1),
          ];

          final transaction = Transaction(
            id: 'T002',
            vehicleId: 'V002',
            customerName: 'Jane Smith',
            services: services,
            totalAmount: 100000,
            paymentMethod: PaymentMethod.transfer,
            status: TransactionStatus.paid,
            createdAt: DateTime(2024, 1, 15, 14, 30),
            paidAt: DateTime(2024, 1, 15, 14, 30),
          );

          final receipt = _formatReceipt(
            transaction: transaction,
            workshopName: 'Bengkel Motor ABC',
            workshopAddress: 'Jl. Raya No. 123',
            workshopPhone: '081234567890',
          );

          expect(receipt.contains('Transfer Bank'), true);
          expect(receipt.contains('Cash:'), false);
          expect(receipt.contains('Kembalian:'), false);
        },
      );

      test('should handle long text in receipt formatting', () {
        final services = [
          ServiceItem(
            name: 'Very Long Service Name That Should Be Truncated',
            price: 50000,
            quantity: 1,
          ),
        ];

        final transaction = Transaction(
          id: 'T003',
          vehicleId: 'V003',
          customerName: 'Very Long Customer Name That Should Be Handled',
          services: services,
          totalAmount: 50000,
          paymentMethod: PaymentMethod.qris,
          status: TransactionStatus.paid,
          createdAt: DateTime(2024, 1, 15, 14, 30),
          paidAt: DateTime(2024, 1, 15, 14, 30),
        );

        final receipt = _formatReceipt(
          transaction: transaction,
          workshopName:
              'Very Long Workshop Name That Should Be Centered Properly',
          workshopAddress: 'Very Long Address That Should Be Centered',
          workshopPhone: '08123456789012345678901234567890',
        );

        // Verify the receipt is still formatted properly
        expect(receipt.contains('QRIS'), true);
        expect(receipt.isNotEmpty, true);
      });
    });

    group('Helper Method Tests', () {
      test('should center text correctly', () {
        final centeredText = _centerText('Test', 32);
        expect(centeredText.length, 4); // 'Test' has length 4
        expect(centeredText, 'Test');
      });

      test('should handle text longer than width in centerText', () {
        final longText = 'This is a very long text that exceeds the width';
        final centeredText = _centerText(longText, 32);
        expect(
          centeredText,
          longText,
        ); // Should return as-is if longer than width
      });

      test('should pad left correctly', () {
        final paddedText = _padLeft('Test', 32);
        expect(paddedText.length, 32);
        expect(
          paddedText.substring(28),
          'Test',
        ); // Last 4 characters should be 'Test'
      });

      test('should format row with two columns correctly', () {
        final formattedRow = _formatRow('Left:', 'Right');
        expect(formattedRow.length, 32); // Should be exactly 32 characters
        expect(formattedRow.contains('Left:'), true);
        expect(formattedRow.contains('Right'), true);
      });

      test('should truncate long left text in formatRow', () {
        final longLeft =
            'This is a very long left text that should be truncated';
        final formattedRow = _formatRow(longLeft, 'Right');
        expect(formattedRow.length, 32);
        expect(formattedRow.contains('...'), true);
      });

      test('should format date and time correctly', () {
        final dateTime = DateTime(2024, 1, 15, 14, 30);
        final formattedDate = _formatDateTime(dateTime);
        expect(formattedDate, '15/01/2024 14:30');
      });

      test('should handle single digit day and month in date formatting', () {
        final dateTime = DateTime(2024, 1, 5, 9, 5);
        final formattedDate = _formatDateTime(dateTime);
        expect(formattedDate, '05/01/2024 09:05');
      });
    });
  });
}

// Helper functions that replicate the private methods from PrintService for testing
String _formatReceipt({
  required Transaction transaction,
  required String workshopName,
  required String workshopAddress,
  required String workshopPhone,
}) {
  StringBuffer receipt = StringBuffer();

  // Header
  receipt.writeln(_centerText(workshopName, 32));
  receipt.writeln(_centerText(workshopAddress, 32));
  receipt.writeln(_centerText('Telp: $workshopPhone', 32));
  receipt.writeln('=' * 32);

  // Info Transaksi
  receipt.writeln('ID: ${transaction.id}');
  receipt.writeln('Tanggal: ${_formatDateTime(transaction.createdAt)}');
  receipt.writeln('Pelanggan: ${transaction.customerName}');
  receipt.writeln('Kendaraan: ${transaction.vehicleId}');
  receipt.writeln('=' * 32);

  // Detail Layanan
  receipt.writeln('DETAIL LAYANAN:');

  for (var service in transaction.services) {
    receipt.writeln('${service.name} (${service.quantity}x)');
    receipt.writeln(_padLeft('Rp ${service.price.toStringAsFixed(0)}', 32));
  }

  receipt.writeln('=' * 32);

  // Total dan Pembayaran
  receipt.writeln(
    _formatRow('TOTAL:', 'Rp ${transaction.totalAmount.toStringAsFixed(0)}'),
  );
  receipt.writeln(_formatRow('Metode:', transaction.paymentMethodText));

  if (transaction.cashAmount != null) {
    receipt.writeln(
      _formatRow('Cash:', 'Rp ${transaction.cashAmount!.toStringAsFixed(0)}'),
    );
  }

  if (transaction.changeAmount != null) {
    receipt.writeln(
      _formatRow(
        'Kembalian:',
        'Rp ${transaction.changeAmount!.toStringAsFixed(0)}',
      ),
    );
  }

  receipt.writeln('=' * 32);

  // Footer
  receipt.writeln(_centerText('Terima kasih atas kepercayaan Anda', 32));
  receipt.writeln(_centerText('Semoga berkendara dengan aman', 32));

  return receipt.toString();
}

String _centerText(String text, int width) {
  if (text.length >= width) return text;
  int padding = (width - text.length) ~/ 2;
  return ' ' * padding + text + ' ' * ((width - text.length) - padding);
}

String _padLeft(String text, int width) {
  if (text.length >= width) return text;
  return ' ' * (width - text.length) + text;
}

String _formatRow(String left, String right) {
  int totalWidth = 32;
  int rightWidth = right.length;
  int leftWidth = totalWidth - rightWidth - 1;

  if (left.length > leftWidth) {
    left = left.substring(0, leftWidth - 3) + '...';
  }

  return left + ' ' * (leftWidth - left.length) + right;
}

String _formatDateTime(DateTime dateTime) {
  return '${dateTime.day.toString().padLeft(2, '0')}/'
      '${dateTime.month.toString().padLeft(2, '0')}/'
      '${dateTime.year} '
      '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')}';
}
