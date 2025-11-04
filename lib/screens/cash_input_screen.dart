import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/cart_item.dart';

class CashInputScreen extends StatefulWidget {
  final double totalAmount;
  final List<ShoppingCartItem> cartItems;
  final PaymentMethod paymentMethod;

  const CashInputScreen({
    super.key,
    required this.totalAmount,
    required this.cartItems,
    required this.paymentMethod,
  });

  @override
  State<CashInputScreen> createState() => _CashInputScreenState();
}

class _CashInputScreenState extends State<CashInputScreen> {
  final TextEditingController _cashController = TextEditingController();
  double _cashAmount = 0;
  double _change = 0;

  @override
  void initState() {
    super.initState();
    _cashController.addListener(_calculateChange);
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  void _calculateChange() {
    setState(() {
      _cashAmount = double.tryParse(_cashController.text) ?? 0;
      _change = _cashAmount - widget.totalAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Input Uang Cash'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTotalSection(),
                    const SizedBox(height: 24),
                    _buildCashInputSection(),
                    const SizedBox(height: 24),
                    _buildChangeSection(),
                    const SizedBox(height: 32),
                    _buildPaymentSummary(),
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

  Widget _buildTotalSection() {
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
          const Text(
            'Total Pembayaran',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${widget.totalAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CupertinoColors.systemGrey4, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Masukkan Jumlah Uang',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _cashController,
            placeholder: 'Masukkan jumlah uang',
            keyboardType: TextInputType.number,
            prefix: const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                'Rp',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(12),
            ),
            style: const TextStyle(
              fontSize: 20,
              color: CupertinoColors.white,
              fontWeight: FontWeight.bold,
            ),
            onChanged: (value) {
              _calculateChange();
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Metode: ${_getPaymentMethodText(widget.paymentMethod)}',
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _change >= 0
            ? CupertinoColors.systemGreen.withOpacity(0.2)
            : CupertinoColors.systemRed.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _change >= 0
              ? CupertinoColors.systemGreen.withOpacity(0.3)
              : CupertinoColors.systemRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            _change >= 0 ? 'Kembalian' : 'Kurang Bayar',
            style: TextStyle(
              fontSize: 16,
              color: _change >= 0
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemRed,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${_change.abs().toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _change >= 0
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
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
            'Ringkasan Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Total Tagihan',
            'Rp ${widget.totalAmount.toStringAsFixed(0)}',
          ),
          _buildSummaryRow(
            'Uang Diterima',
            'Rp ${_cashAmount.toStringAsFixed(0)}',
          ),
          const Divider(color: CupertinoColors.systemGrey4),
          _buildSummaryRow(
            _change >= 0 ? 'Kembalian' : 'Kurang Bayar',
            'Rp ${_change.abs().toStringAsFixed(0)}',
            isImportant: true,
            color: _change >= 0
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemRed,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isImportant = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: isImportant ? 16 : 14,
              fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
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
                'Batal',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: _cashAmount >= widget.totalAmount
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemGrey4,
              borderRadius: BorderRadius.circular(12),
              child: const Text(
                'Proses Bayar',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _cashAmount >= widget.totalAmount
                  ? _processPayment
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.transfer:
        return 'Transfer';
      case PaymentMethod.card:
        return 'Kartu';
    }
  }

  void _processPayment() {
    if (_cashAmount < widget.totalAmount) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Pembayaran Gagal'),
          content: const Text('Jumlah uang tidak cukup untuk pembayaran'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.pop(context, {'cashAmount': _cashAmount, 'change': _change});
  }
}
