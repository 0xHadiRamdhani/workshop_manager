import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/main_controller.dart';
import '../models/transaction.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController controller = Get.put(TransactionController());

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: IconButton(
          onPressed: () {
            // Gunakan controller untuk membuka drawer
            final mainController = Get.find<MainController>();
            mainController.openDrawer();
          },
          icon: Icon(CupertinoIcons.bars),
        ),
        middle: const Text(
          'Riwayat Transaksi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                CupertinoIcons.refresh,
                color: CupertinoColors.systemBlue,
              ),
              onPressed: controller.refreshTransactions,
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSummarySection(controller),
            _buildFilterSection(controller),
            Expanded(child: _buildTransactionList(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(TransactionController controller) {
    return Obx(() {
      final totalRevenue = controller.totalRevenue;
      final totalTransactions = controller.totalTransactions;
      final pendingCount = controller.pendingCount;
      final completedCount = controller.completedCount;

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.darkBackgroundGray,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Pendapatan',
                    'Rp ${totalRevenue.toStringAsFixed(0)}',
                    CupertinoIcons.money_dollar,
                    CupertinoColors.systemGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Transaksi',
                    '$totalTransactions',
                    CupertinoIcons.doc_text,
                    CupertinoColors.systemBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Pending',
                    '$pendingCount',
                    CupertinoIcons.clock,
                    CupertinoColors.systemOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Selesai',
                    '$completedCount',
                    CupertinoIcons.checkmark_circle,
                    CupertinoColors.systemGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(TransactionController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Transaksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            placeholder: 'Cari transaksi...',
            prefix: const Icon(
              CupertinoIcons.search,
              color: CupertinoColors.systemGrey,
            ),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(8),
            ),
            onChanged: (value) => controller.searchQuery.value = value,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Semua', controller),
                _buildFilterChip('Hari Ini', controller),
                _buildFilterChip('Minggu Ini', controller),
                _buildFilterChip('Bulan Ini', controller),
                _buildFilterChip('Pending', controller),
                _buildFilterChip('Lunas', controller),
                _buildFilterChip('Dibatalkan', controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, TransactionController controller) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == filter;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isSelected
              ? CupertinoColors.systemBlue
              : CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(20),
          child: Text(
            filter,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? CupertinoColors.white : CupertinoColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () => controller.selectedFilter.value = filter,
        ),
      );
    });
  }

  Widget _buildTransactionList(TransactionController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CupertinoActivityIndicator());
      }

      final transactions = controller.filteredTransactions;

      if (transactions.isEmpty) {
        return const Center(
          child: Text(
            'Tidak ada data transaksi',
            style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildTransactionCard(transaction, controller);
        },
      );
    });
  }

  Widget _buildTransactionCard(
    Transaction transaction,
    TransactionController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(transaction.status).withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
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
                      Text(
                        'ID: ${transaction.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      Text(
                        '${transaction.services.length} layanan',
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transaction.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        controller.getStatusText(transaction.status),
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${transaction.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  CupertinoIcons.money_dollar,
                  'Metode: ${controller.getPaymentMethodText(transaction.paymentMethod)}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  CupertinoIcons.clock,
                  'Tanggal: ${_formatDate(transaction.createdAt)}',
                ),
                if (transaction.paidAt != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    CupertinoIcons.checkmark_circle,
                    'Dibayar: ${_formatDate(transaction.paidAt!)}',
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: CupertinoColors.systemBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        child: const Text(
                          'Detail',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onPressed: () =>
                            controller.navigateToTransactionDetail(transaction),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: CupertinoColors.systemGreen,
                        borderRadius: BorderRadius.circular(8),
                        child: const Text(
                          'Nota',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () =>
                            controller.navigateToReceipt(transaction),
                      ),
                    ),
                    if (transaction.status == TransactionStatus.pending) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          color: CupertinoColors.systemGreen,
                          borderRadius: BorderRadius.circular(8),
                          child: const Text(
                            'Bayar',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () => controller.updateTransactionStatus(
                            transaction,
                            TransactionStatus.paid,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: CupertinoColors.systemGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: CupertinoColors.white),
          ),
        ),
      ],
    );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
