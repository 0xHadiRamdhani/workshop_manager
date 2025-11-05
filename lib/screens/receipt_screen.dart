import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workshop_manager/main.dart';
import 'package:workshop_manager/screens/cashier_screen.dart';
import '../models/transaction.dart';
import '../models/cart_item.dart';
import 'dashboard_screen.dart';

class ReceiptScreen extends StatefulWidget {
  final Transaction transaction;
  final double? cashAmount;
  final double? change;

  const ReceiptScreen({
    super.key,
    required this.transaction,
    this.cashAmount,
    this.change,
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Struk Pembayaran'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.share,
            color: CupertinoColors.systemBlue,
          ),
          onPressed: _shareReceipt,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildReceiptHeader(),
                    const SizedBox(height: 24),
                    _buildTransactionDetails(),
                    const SizedBox(height: 24),
                    _buildItemsList(),
                    const SizedBox(height: 24),
                    _buildPaymentDetails(),
                    const SizedBox(height: 32),
                    _buildReceiptFooter(),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.systemBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.checkmark_circle_fill,
            size: 48,
            color: CupertinoColors.systemGreen,
          ),
          const SizedBox(height: 12),
          const Text(
            'PEMBAYARAN BERHASIL',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ID: ${widget.transaction.id}',
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDateTime(
              widget.transaction.paidAt ?? widget.transaction.createdAt,
            ),
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Transaksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Nama Pelanggan', widget.transaction.customerName),
          _buildDetailRow('ID Kendaraan', widget.transaction.vehicleId),
          _buildDetailRow(
            'Status',
            widget.transaction.statusText,
            color: widget.transaction.statusColor,
          ),
          _buildDetailRow('Metode Bayar', widget.transaction.paymentMethodText),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Item yang Dibeli',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.transaction.services.length,
            itemBuilder: (context, index) {
              final item = widget.transaction.services[index];
              return _buildItemRow(item);
            },
          ),
          const Divider(color: CupertinoColors.systemGrey4),
          _buildTotalRow(),
        ],
      ),
    );
  }

  Widget _buildItemRow(ServiceItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.white,
                  ),
                ),
                Text(
                  'Rp ${item.price.toStringAsFixed(0)} x ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rp ${item.totalPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Text(
            'TOTAL',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const Spacer(),
          Text(
            'Rp ${widget.transaction.totalAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    // Selalu tampilkan detail pembayaran untuk semua metode
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Metode Pembayaran',
            widget.transaction.paymentMethodText,
          ),
          // Untuk metode tunai, tampilkan detail uang
          if (widget.cashAmount != null && widget.change != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              'Uang yang Diterima',
              'Rp ${widget.cashAmount!.toStringAsFixed(0)}',
            ),
            _buildDetailRow(
              'Kembalian',
              'Rp ${widget.change!.toStringAsFixed(0)}',
            ),
          ],
          // Untuk metode non-tunai, tampilkan informasi tambahan
          if (widget.transaction.paymentMethod == PaymentMethod.qris) ...[
            const SizedBox(height: 8),
            const Text(
              'Pembayaran dilakukan melalui QRIS',
              style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
            ),
          ] else if (widget.transaction.paymentMethod ==
              PaymentMethod.transfer) ...[
            const SizedBox(height: 8),
            const Text(
              'Pembayaran dilakukan melalui transfer bank',
              style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReceiptFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4, width: 1),
      ),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.info_circle,
            size: 24,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 8),
          const Text(
            'Terima kasih atas kunjungan Anda!',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Simpan struk ini sebagai bukti pembayaran',
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color ?? CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        border: Border(
          top: BorderSide(color: CupertinoColors.systemGrey4.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(12),
              child: const Text(
                'Kembali',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(12),
              child: const Text(
                'Selesai',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                // Kembali ke screen sebelumnya dengan aman
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop('completed');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _shareReceipt() {
    final receiptText = _generateReceiptText();

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Bagikan Struk'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Struk telah disalin ke clipboard'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                receiptText,
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.white,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Tutup'),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: receiptText));
  }

  String _generateReceiptText() {
    String text = 'STRUK PEMBAYARAN\n';
    text += '================\n\n';
    text += 'ID: ${widget.transaction.id}\n';
    text +=
        'Tanggal: ${_formatDateTime(widget.transaction.paidAt ?? widget.transaction.createdAt)}\n';
    text += 'Pelanggan: ${widget.transaction.customerName}\n';
    text += 'Metode: ${widget.transaction.paymentMethodText}\n\n';
    text += 'ITEM:\n';

    for (final item in widget.transaction.services) {
      text +=
          '${item.name} x${item.quantity} @Rp${item.price.toStringAsFixed(0)} = Rp${item.totalPrice.toStringAsFixed(0)}\n';
    }

    text += '\nTOTAL: Rp${widget.transaction.totalAmount.toStringAsFixed(0)}\n';

    if (widget.cashAmount != null && widget.change != null) {
      text += 'Uang: Rp${widget.cashAmount!.toStringAsFixed(0)}\n';
      text += 'Kembali: Rp${widget.change!.toStringAsFixed(0)}\n';
    } else if (widget.transaction.paymentMethod == PaymentMethod.qris) {
      text += 'Metode: QRIS\n';
    } else if (widget.transaction.paymentMethod == PaymentMethod.transfer) {
      text += 'Metode: Transfer Bank\n';
    }

    text += '\nTerima kasih!';

    return text;
  }
}
