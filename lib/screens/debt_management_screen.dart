import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart' as app_transaction;

class DebtManagementScreen extends StatefulWidget {
  const DebtManagementScreen({super.key});

  @override
  State<DebtManagementScreen> createState() => _DebtManagementScreenState();
}

class _DebtManagementScreenState extends State<DebtManagementScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _isLoading = true;
  List<app_transaction.Transaction> _debtTransactions = [];
  double _totalDebt = 0.0;
  double _totalPaid = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDebtData();
  }

  Future<void> _loadDebtData() async {
    try {
      final allTransactions = await _databaseHelper.getTransactions();

      // Debug: Print semua transaksi untuk melihat data
      print('DEBUG: Total transactions: ${allTransactions.length}');
      for (final t in allTransactions) {
        print(
          'DEBUG: Transaction ${t.id} - isDebt: ${t.isDebt}, debtAmount: ${t.debtAmount}, debtPaidAmount: ${t.debtPaidAmount}, paymentMethod: ${t.paymentMethod}',
        );
      }

      // Filter transaksi yang memiliki hutang (isDebt = true) atau yang memiliki debtAmount > 0
      final debtTransactions = allTransactions
          .where((t) => t.isDebt || t.debtAmount > 0)
          .toList();

      print('DEBUG: Filtered debt transactions: ${debtTransactions.length}');
      for (final t in debtTransactions) {
        print(
          'DEBUG: Debt transaction ${t.id} - debtAmount: ${t.debtAmount}, debtPaidAmount: ${t.debtPaidAmount}',
        );
      }

      double totalDebt = 0.0;
      double totalPaid = 0.0;

      for (final transaction in debtTransactions) {
        totalDebt += transaction.debtAmount;
        totalPaid += transaction.debtPaidAmount;
      }

      print('DEBUG: totalDebt: $totalDebt, totalPaid: $totalPaid');

      setState(() {
        _debtTransactions = debtTransactions;
        _totalDebt = totalDebt;
        _totalPaid = totalPaid;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading debt data: $e');
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

  void _showPaymentDialog(app_transaction.Transaction transaction) {
    final TextEditingController amountController = TextEditingController();
    double remainingAmount =
        transaction.debtAmount - transaction.debtPaidAmount;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Pembayaran Hutang'),
        content: Column(
          children: [
            const SizedBox(height: 16),
            Text('Sisa hutang: Rp ${remainingAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: amountController,
              placeholder: 'Jumlah pembayaran',
              keyboardType: TextInputType.number,
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text('Rp '),
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Bayar'),
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0 && amount <= remainingAmount) {
                _processPayment(transaction, amount);
                Navigator.pop(context);
              } else {
                _showErrorDialog('Jumlah pembayaran tidak valid');
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(
    app_transaction.Transaction transaction,
    double amount,
  ) async {
    try {
      final newPaidAmount = transaction.debtPaidAmount + amount;
      final isFullyPaid = newPaidAmount >= transaction.debtAmount;

      final updatedTransaction = app_transaction.Transaction(
        id: transaction.id,
        vehicleId: transaction.vehicleId,
        customerName: transaction.customerName,
        services: transaction.services,
        totalAmount: transaction.totalAmount,
        paymentMethod: transaction.paymentMethod,
        status: isFullyPaid
            ? app_transaction.TransactionStatus.paid
            : transaction.status,
        createdAt: transaction.createdAt,
        paidAt: isFullyPaid ? DateTime.now() : transaction.paidAt,
        cashAmount: transaction.cashAmount,
        changeAmount: transaction.changeAmount,
        isDebt: !isFullyPaid,
        debtAmount: transaction.debtAmount,
        debtPaidAmount: newPaidAmount,
        debtStatus: isFullyPaid ? 'paid' : 'partial',
      );

      await _databaseHelper.updateTransaction(updatedTransaction);
      _loadDebtData();

      // Show success notification
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Berhasil'),
          content: Text(
            isFullyPaid
                ? 'Pembayaran berhasil! Hutang telah lunas.'
                : 'Pembayaran berhasil! Sisa hutang: Rp ${(transaction.debtAmount - newPaidAmount).toStringAsFixed(0)}',
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorDialog('Error processing payment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Manajemen Hutang'),
          backgroundColor: CupertinoColors.darkBackgroundGray,
        ),
        child: SafeArea(child: Center(child: CupertinoActivityIndicator())),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: IconButton(
          onPressed: () {
            // Akses scaffold dari parent MaterialApp
            final scaffoldState = Scaffold.maybeOf(context);
            if (scaffoldState != null && scaffoldState.hasDrawer) {
              scaffoldState.openDrawer();
            }
          },
          icon: Icon(CupertinoIcons.bars),
        ),
        middle: const Text('Manajemen Hutang'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.refresh,
            color: CupertinoColors.white,
          ),
          onPressed: _loadDebtData,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSummaryCards(),
            Expanded(
              child: _debtTransactions.isEmpty
                  ? _buildEmptyState()
                  : _buildDebtList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final remainingDebt = _totalDebt - _totalPaid;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Hutang',
                  'Rp ${_totalDebt.toStringAsFixed(0)}',
                  CupertinoColors.systemRed,
                  CupertinoIcons.money_dollar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Sudah Dibayar',
                  'Rp ${_totalPaid.toStringAsFixed(0)}',
                  CupertinoColors.systemGreen,
                  CupertinoIcons.check_mark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.darkBackgroundGray,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemOrange.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  color: CupertinoColors.systemOrange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sisa Hutang',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${remainingDebt.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          color: CupertinoColors.systemOrange,
                          fontWeight: FontWeight.bold,
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
                    color: CupertinoColors.systemOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${((remainingDebt / _totalDebt) * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.checkmark_circle,
            size: 64,
            color: CupertinoColors.systemGreen,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak Ada Hutang',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Semua transaksi sudah lunas',
            style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _debtTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _debtTransactions[index];
        final remainingAmount =
            transaction.debtAmount - transaction.debtPaidAmount;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.darkBackgroundGray,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
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
                          transaction.customerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: Rp ${transaction.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: transaction.debtStatus == 'paid'
                          ? CupertinoColors.systemGreen.withOpacity(0.2)
                          : CupertinoColors.systemOrange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      transaction.debtStatus == 'paid' ? 'Lunas' : 'Sebagian',
                      style: TextStyle(
                        fontSize: 12,
                        color: transaction.debtStatus == 'paid'
                            ? CupertinoColors.systemGreen
                            : CupertinoColors.systemOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hutang',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        Text(
                          'Rp ${transaction.debtAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dibayar',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        Text(
                          'Rp ${transaction.debtPaidAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sisa',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        Text(
                          'Rp ${remainingAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (remainingAmount > 0)
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: CupertinoColors.systemBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Text(
                      'Bayar Sekarang',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => _showPaymentDialog(transaction),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
