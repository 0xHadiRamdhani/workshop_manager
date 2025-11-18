import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';
import '../services/print_service.dart';
import 'pdf_viewer_screen.dart';

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
  bool _isGeneratingPDF = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Struk Pembayaran'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _shareReceipt,
              child: const Icon(
                CupertinoIcons.share,
                color: CupertinoColors.systemBlue,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _generatePDF,
              child: const Icon(
                CupertinoIcons.doc_fill,
                color: CupertinoColors.systemGreen,
              ),
            ),
          ],
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
    final isDebt = widget.transaction.paymentMethod == PaymentMethod.debt;
    final headerColor = isDebt
        ? CupertinoColors.systemOrange.withOpacity(0.2)
        : CupertinoColors.systemBlue.withOpacity(0.2);
    final borderColor = isDebt
        ? CupertinoColors.systemOrange.withOpacity(0.3)
        : CupertinoColors.systemBlue.withOpacity(0.3);
    final iconColor = isDebt
        ? CupertinoColors.systemOrange
        : CupertinoColors.systemGreen;
    final titleText = isDebt ? 'TRANSAKSI HUTANG' : 'PEMBAYARAN BERHASIL';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            isDebt
                ? CupertinoIcons.clock
                : CupertinoIcons.checkmark_circle_fill,
            size: 48,
            color: iconColor,
          ),
          const SizedBox(height: 12),
          Material(
            type: MaterialType.transparency,
            child: Text(
              titleText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Material(
            type: MaterialType.transparency,
            child: Text(
              'ID: ${widget.transaction.id}',
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Material(
            type: MaterialType.transparency,
            child: Text(
              _formatDateTime(
                widget.transaction.paidAt ?? widget.transaction.createdAt,
              ),
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
          if (isDebt) ...[
            const SizedBox(height: 8),
            Material(
              type: MaterialType.transparency,
              child: Text(
                'Status: ${widget.transaction.statusText}',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.transaction.statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
          Material(
            type: MaterialType.transparency,
            child: const Text(
              'Detail Transaksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
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
          Material(
            type: MaterialType.transparency,
            child: const Text(
              'Item yang Dibeli',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
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
                Material(
                  type: MaterialType.transparency,
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: Text(
                    'Rp ${item.price.toStringAsFixed(0)} x ${item.quantity}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: Text(
              'Rp ${item.totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
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
          Material(
            type: MaterialType.transparency,
            child: const Text(
              'TOTAL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
          ),
          const Spacer(),
          Material(
            type: MaterialType.transparency,
            child: Text(
              'Rp ${widget.transaction.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.systemGreen,
              ),
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
          Material(
            type: MaterialType.transparency,
            child: const Text(
              'Detail Pembayaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
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
          if (widget.transaction.paymentMethod == PaymentMethod.transfer) ...[
            const SizedBox(height: 8),
            const Text(
              'Pembayaran dilakukan melalui transfer bank',
              style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
            ),
          ],
          // Untuk metode hutang, tampilkan informasi hutang
          if (widget.transaction.paymentMethod == PaymentMethod.debt) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              'Total Hutang',
              'Rp ${widget.transaction.debtAmount.toStringAsFixed(0)}',
            ),
            _buildDetailRow(
              'Sudah Dibayar',
              'Rp ${widget.transaction.debtPaidAmount.toStringAsFixed(0)}',
            ),
            _buildDetailRow(
              'Sisa Hutang',
              'Rp ${(widget.transaction.debtAmount - widget.transaction.debtPaidAmount).toStringAsFixed(0)}',
            ),
            if (widget.transaction.paymentDueDate != null) ...[
              const SizedBox(height: 4),
              _buildDetailRow(
                'Jatuh Tempo',
                _formatDate(widget.transaction.paymentDueDate!),
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: CupertinoColors.systemYellow,
                  width: 1,
                ),
              ),
              child: const Text(
                'Pembayaran dapat dilakukan melalui menu Manajemen Hutang',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemYellow,
                ),
                textAlign: TextAlign.center,
              ),
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
          Material(
            type: MaterialType.transparency,
            child: const Text(
              'Terima kasih atas kunjungan Anda!',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Material(
            type: MaterialType.transparency,
            child: Text(
              'Simpan struk ini sebagai bukti pembayaran',
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
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
          Material(
            type: MaterialType.transparency,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
          const Spacer(),
          Material(
            type: MaterialType.transparency,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color ?? CupertinoColors.white,
              ),
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
          top: BorderSide(
            color: CupertinoColors.systemGrey4.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: CupertinoColors.systemGreen,
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isGeneratingPDF
                          ? const CupertinoActivityIndicator()
                          : const Icon(CupertinoIcons.doc_fill, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _isGeneratingPDF
                            ? 'Membuat PDF...'
                            : 'Simpan sebagai PDF',
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  onPressed: _isGeneratingPDF ? null : _generatePDF,
                ),
              ),
            ],
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
                color: CupertinoColors.darkBackgroundGray,
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

  Future<void> _generatePDF() async {
    setState(() {
      _isGeneratingPDF = true;
    });

    try {
      // Generate PDF menggunakan PrintService
      final pdfPath = await PrintService.generateAndSaveReceiptPDF(
        transaction: widget.transaction,
        workshopName: 'Workshop Manager',
        workshopAddress: 'Jl. Workshop No. 123',
        workshopPhone: '0812-3456-7890',
      );

      if (pdfPath != null) {
        // Navigasi ke PDF viewer screen
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => PDFViewerScreen(
              pdfPath: pdfPath,
              transactionId: widget.transaction.id,
            ),
          ),
        );
      } else {
        _showErrorDialog('Gagal membuat PDF');
      }
    } catch (e) {
      _showErrorDialog('Error generating PDF: $e');
    } finally {
      setState(() {
        _isGeneratingPDF = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  String _generateReceiptText() {
    final isDebt = widget.transaction.paymentMethod == PaymentMethod.debt;
    String text = isDebt ? 'STRUK TRANSAKSI HUTANG\n' : 'STRUK PEMBAYARAN\n';
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
    } else if (widget.transaction.paymentMethod == PaymentMethod.transfer) {
      text += 'Metode: Transfer Bank\n';
    } else if (isDebt) {
      text += '\nDETAIL HUTANG:\n';
      text +=
          'Total Hutang: Rp${widget.transaction.debtAmount.toStringAsFixed(0)}\n';
      text +=
          'Sudah Dibayar: Rp${widget.transaction.debtPaidAmount.toStringAsFixed(0)}\n';
      text +=
          'Sisa Hutang: Rp${(widget.transaction.debtAmount - widget.transaction.debtPaidAmount).toStringAsFixed(0)}\n';
      if (widget.transaction.paymentDueDate != null) {
        text +=
            'Jatuh Tempo: ${_formatDate(widget.transaction.paymentDueDate!)}\n';
      }
      text += '\nPembayaran dapat dilakukan melalui menu Manajemen Hutang\n';
    }

    text += '\nTerima kasih!';

    return text;
  }
}
