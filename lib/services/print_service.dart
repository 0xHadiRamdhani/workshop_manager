import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import '../models/transaction.dart';

/// Service untuk pencetakan struk menggunakan printer thermal bluetooth
class PrintService {
  static FlutterBluetoothPrinter? _bluetoothPrinter;
  static String? _connectedDeviceId;

  /// Cetak struk via Bluetooth Thermal Printer
  static Future<bool> printReceipt({
    required Transaction transaction,
    required String workshopName,
    required String workshopAddress,
    required String workshopPhone,
  }) async {
    try {
      // Format struk
      String receipt = _formatReceipt(
        transaction: transaction,
        workshopName: workshopName,
        workshopAddress: workshopAddress,
        workshopPhone: workshopPhone,
      );

      // Untuk sementaga, print ke console saja sebagai simulasi
      // Nanti bisa diimplementasikan dengan thermal printer yang sesuai
      print('=== SIMULASI CETAK STRUK ===');
      print(receipt);
      print('=== AKHIR STRUK ===');

      return true;
    } catch (e) {
      print('Error printing receipt: $e');
      return false;
    }
  }

  /// Format struk untuk dicetak
  static String _formatReceipt({
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

  /// Helper untuk center text
  static String _centerText(String text, int width) {
    if (text.length >= width) return text;
    int padding = (width - text.length) ~/ 2;
    return ' ' * padding + text;
  }

  /// Helper untuk right align text
  static String _padLeft(String text, int width) {
    if (text.length >= width) return text;
    return ' ' * (width - text.length) + text;
  }

  /// Helper untuk format row dengan dua kolom
  static String _formatRow(String left, String right) {
    int totalWidth = 32;
    int rightWidth = right.length;
    int leftWidth = totalWidth - rightWidth - 1;

    if (left.length > leftWidth) {
      left = left.substring(0, leftWidth - 3) + '...';
    }

    return left + ' ' * (leftWidth - left.length) + right;
  }

  /// Format tanggal dan waktu
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Scan printer bluetooth yang tersedia
  static Future<List<dynamic>> scanBluetoothPrinters() async {
    try {
      // Untuk sementara return list kosong
      // Implementasi thermal printer akan dilakukan di versi berikutnya
      return [];
    } catch (e) {
      print('Error scanning Bluetooth printers: $e');
      return [];
    }
  }

  /// Hubungkan ke printer bluetooth
  static Future<bool> connectBluetoothPrinter(dynamic device) async {
    try {
      // Implementasi koneksi printer akan dilakukan di versi berikutnya
      print('Connecting to printer... (simulasi)');
      return true;
    } catch (e) {
      print('Error connecting to Bluetooth printer: $e');
      return false;
    }
  }

  /// Disconnect printer bluetooth
  static Future<void> disconnectBluetoothPrinter() async {
    try {
      // Implementasi disconnect printer akan dilakukan di versi berikutnya
      print('Disconnecting printer... (simulasi)');
    } catch (e) {
      print('Error disconnecting Bluetooth printer: $e');
    }
  }

  /// Cek status koneksi bluetooth
  static Future<bool> isBluetoothConnected() async {
    try {
      // Implementasi cek koneksi akan dilakukan di versi berikutnya
      return false;
    } catch (e) {
      return false;
    }
  }
}
