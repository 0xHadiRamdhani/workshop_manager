import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';
import '../services/print_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<Transaction> _transactions = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _databaseHelper.getTransactions();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Histori Transaksi'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.xmark, color: CupertinoColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _transactions.isEmpty
            ? const Center(
                child: Text(
                  'Belum ada transaksi',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  return _buildTransactionCard(transaction);
                },
              ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.id,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(transaction.status).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getStatusText(transaction.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(transaction.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.darkBackgroundGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.money_dollar,
                      size: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Rp ${transaction.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.creditcard,
                      size: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _getPaymentMethodText(transaction.paymentMethod),
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.calendar,
                      size: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _formatDate(transaction.createdAt),
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                  ],
                ),
                if (transaction.cashAmount != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.money_dollar_circle,
                        size: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Cash: Rp ${transaction.cashAmount!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (transaction.changeAmount != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.arrow_right_arrow_left,
                        size: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Kembalian: Rp ${transaction.changeAmount!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: CupertinoColors.systemBlue,
                  borderRadius: BorderRadius.circular(8),
                  child: const Text(
                    'Lihat Detail',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _showTransactionDetail(transaction),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: CupertinoColors.systemGreen,
                  borderRadius: BorderRadius.circular(8),
                  child: const Text(
                    'Cetak Struk',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _printReceipt(transaction),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(Transaction transaction) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: CupertinoColors.darkBackgroundGray,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Detail Transaksi',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: CupertinoColors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('ID Transaksi', transaction.id),
            _buildDetailRow('Pelanggan', transaction.customerName),
            _buildDetailRow(
              'Total',
              'Rp ${transaction.totalAmount.toStringAsFixed(0)}',
            ),
            _buildDetailRow(
              'Metode Bayar',
              _getPaymentMethodText(transaction.paymentMethod),
            ),
            _buildDetailRow('Status', _getStatusText(transaction.status)),
            _buildDetailRow('Tanggal', _formatDate(transaction.createdAt)),
            if (transaction.cashAmount != null)
              _buildDetailRow(
                'Uang Cash',
                'Rp ${transaction.cashAmount!.toStringAsFixed(0)}',
              ),
            if (transaction.changeAmount != null)
              _buildDetailRow(
                'Kembalian',
                'Rp ${transaction.changeAmount!.toStringAsFixed(0)}',
              ),
            const SizedBox(height: 16),
            const Text(
              'Item Transaksi:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: transaction.services.length,
                itemBuilder: (context, index) {
                  final service = transaction.services[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${service.name} (${service.quantity}x)',
                            style: const TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ),
                        Text(
                          'Rp ${(service.price * service.quantity).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _printReceipt(Transaction transaction) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 280,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: CupertinoColors.darkBackgroundGray,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Cetak Struk',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: CupertinoColors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih metode pencetakan:',
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: CupertinoColors.systemBlue,
                        child: const Text(
                          'Cetak via Bluetooth',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () => _printViaBluetooth(transaction),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: CupertinoColors.systemOrange,
                        child: const Text(
                          'Cetak via WiFi/Network',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () => _printViaWiFi(transaction),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: CupertinoColors.systemGrey,
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printViaBluetooth(Transaction transaction) async {
    Navigator.pop(context); // Tutup dialog

    try {
      // Cek koneksi bluetooth
      bool isConnected = await PrintService.isBluetoothConnected();

      if (!isConnected) {
        // Scan dan hubungkan ke printer
        List<BluetoothDevice> devices =
            await PrintService.scanBluetoothPrinters();

        if (devices.isEmpty) {
          _showMessage('Tidak ada printer bluetooth yang tersedia');
          return;
        }

        // Tampilkan dialog pemilihan printer
        showCupertinoModalPopup(
          context: context,
          builder: (context) => Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: CupertinoColors.darkBackgroundGray,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Text(
                  'Pilih Printer Bluetooth',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      return CupertinoButton(
                        child: Text(devices[index].name ?? 'Unknown Device'),
                        onPressed: () async {
                          Navigator.pop(context);
                          bool connected =
                              await PrintService.connectBluetoothPrinter(
                                devices[index],
                              );
                          if (connected) {
                            _printViaBluetooth(transaction);
                          } else {
                            _showMessage('Gagal menghubungkan ke printer');
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
        return;
      }

      // Cetak struk
      bool success = await PrintService.printReceipt(
        transaction: transaction,
        workshopName: 'Bengkel Banimasum',
        workshopAddress: 'Jl. Raya Banimasum No. 123',
        workshopPhone: '0812-3456-7890',
      );

      if (success) {
        _showMessage('Struk berhasil dicetak');
      } else {
        _showMessage('Gagal mencetak struk');
      }
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  Future<void> _printViaWiFi(Transaction transaction) async {
    Navigator.pop(context); // Tutup dialog

    // Untuk sementara, WiFi printing belum diimplementasikan
    _showMessage(
      'Pencetakan via WiFi/Network belum tersedia. Silakan gunakan Bluetooth.',
    );
  }

  void _showMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Informasi'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.transfer:
        return 'Transfer Bank';
      case PaymentMethod.card:
        return 'Kartu Debit/Kredit';
      case PaymentMethod.qris:
        return 'QRIS';
    }
  }

  String _getStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.paid:
        return 'Lunas';
      case TransactionStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return CupertinoColors.systemOrange;
      case TransactionStatus.paid:
        return CupertinoColors.systemGreen;
      case TransactionStatus.cancelled:
        return CupertinoColors.systemRed;
    }
  }
}
