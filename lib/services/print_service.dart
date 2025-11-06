import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../models/transaction.dart';

/// Service untuk pencetakan struk menggunakan printer thermal bluetooth
class PrintService {
  static final BlueThermalPrinter _bluetoothPrinter =
      BlueThermalPrinter.instance;

  /// Cetak struk via Bluetooth Thermal Printer
  static Future<bool> printReceipt({
    required Transaction transaction,
    required String workshopName,
    required String workshopAddress,
    required String workshopPhone,
  }) async {
    try {
      // Cek apakah printer bluetooth terhubung
      bool? isConnected = await _bluetoothPrinter.isConnected;

      if (isConnected != true) {
        print('Printer bluetooth tidak terhubung');
        return false;
      }

      // Format struk
      String receipt = _formatReceipt(
        transaction: transaction,
        workshopName: workshopName,
        workshopAddress: workshopAddress,
        workshopPhone: workshopPhone,
      );

      // Cetak struk
      await _bluetoothPrinter.printCustom(receipt, 0, 0);
      await _bluetoothPrinter.printNewLine();
      await _bluetoothPrinter.printNewLine();
      await _bluetoothPrinter.printNewLine();

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
  static Future<List<BluetoothDevice>> scanBluetoothPrinters() async {
    try {
      return await _bluetoothPrinter.getBondedDevices();
    } catch (e) {
      print('Error scanning Bluetooth printers: $e');
      return [];
    }
  }

  /// Hubungkan ke printer bluetooth
  static Future<bool> connectBluetoothPrinter(BluetoothDevice device) async {
    try {
      await _bluetoothPrinter.connect(device);
      return true;
    } catch (e) {
      print('Error connecting to Bluetooth printer: $e');
      return false;
    }
  }

  /// Disconnect printer bluetooth
  static Future<void> disconnectBluetoothPrinter() async {
    try {
      await _bluetoothPrinter.disconnect();
    } catch (e) {
      print('Error disconnecting Bluetooth printer: $e');
    }
  }

  /// Cek status koneksi bluetooth
  static Future<bool> isBluetoothConnected() async {
    try {
      bool? isConnected = await _bluetoothPrinter.isConnected;
      return isConnected ?? false;
    } catch (e) {
      return false;
    }
  }
}
