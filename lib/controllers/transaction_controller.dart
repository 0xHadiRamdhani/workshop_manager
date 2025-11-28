import 'package:get/get.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';

class TransactionController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Observable variables
  var transactions = <Transaction>[].obs;
  var isLoading = false.obs;
  var selectedFilter = 'Semua'.obs;
  var searchQuery = ''.obs;

  // Computed properties
  List<Transaction> get filteredTransactions {
    var filtered = transactions.toList();

    // Filter by status
    if (selectedFilter.value != 'Semua') {
      filtered = filtered.where((t) {
        switch (selectedFilter.value) {
          case 'Hari Ini':
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            return t.createdAt.isAfter(today) ||
                t.createdAt.isAtSameMomentAs(today);
          case 'Minggu Ini':
            final now = DateTime.now();
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            return t.createdAt.isAfter(weekStart) ||
                t.createdAt.isAtSameMomentAs(weekStart);
          case 'Bulan Ini':
            final now = DateTime.now();
            return t.createdAt.month == now.month &&
                t.createdAt.year == now.year;
          case 'Pending':
            return t.status == TransactionStatus.pending;
          case 'Lunas':
            return t.status == TransactionStatus.paid;
          case 'Dibatalkan':
            return t.status == TransactionStatus.cancelled;
          default:
            return true;
        }
      }).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where(
            (t) =>
                t.customerName.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                t.vehicleId.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ),
          )
          .toList();
    }

    return filtered;
  }

  // Calculate totals
  double get totalRevenue {
    return filteredTransactions
        .where((t) => t.status == TransactionStatus.paid)
        .fold(0.0, (sum, t) => sum + t.totalAmount);
  }

  int get totalTransactions => filteredTransactions.length;
  int get pendingCount =>
      transactions.where((t) => t.status == TransactionStatus.pending).length;
  int get completedCount =>
      transactions.where((t) => t.status == TransactionStatus.paid).length;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    isLoading.value = true;
    try {
      final loadedTransactions = await _dbHelper.getTransactions();
      transactions.assignAll(loadedTransactions);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data transaksi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshTransactions() {
    loadTransactions();
  }

  Future<void> updateTransactionStatus(
    Transaction transaction,
    TransactionStatus newStatus,
  ) async {
    try {
      final updatedTransaction = Transaction(
        id: transaction.id,
        vehicleId: transaction.vehicleId,
        customerName: transaction.customerName,
        services: transaction.services,
        totalAmount: transaction.totalAmount,
        paymentMethod: transaction.paymentMethod,
        status: newStatus,
        createdAt: transaction.createdAt,
        paidAt: newStatus == TransactionStatus.paid
            ? DateTime.now()
            : transaction.paidAt,
        cashAmount: transaction.cashAmount,
        changeAmount: transaction.changeAmount,
        isDebt: transaction.isDebt,
        debtAmount: transaction.debtAmount,
        debtPaidAmount: transaction.debtPaidAmount,
        debtStatus: transaction.debtStatus,
        paymentDueDate: transaction.paymentDueDate,
        branchId: transaction.branchId,
        invoiceNumber: transaction.invoiceNumber,
      );

      await _dbHelper.updateTransaction(updatedTransaction);
      await loadTransactions();

      Get.snackbar(
        'Berhasil',
        'Status transaksi diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui status: $e');
    }
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    try {
      await _dbHelper.deleteTransaction(transaction.id);
      await loadTransactions();
      Get.snackbar('Berhasil', 'Transaksi dihapus');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus transaksi: $e');
    }
  }

  void navigateToTransactionDetail(Transaction transaction) {
    Get.toNamed('/transaction-detail', arguments: transaction);
  }

  void navigateToReceipt(Transaction transaction) {
    Get.toNamed('/receipt', arguments: transaction);
  }

  // Helper method to get status color
  String getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'orange';
      case TransactionStatus.paid:
        return 'green';
      case TransactionStatus.cancelled:
        return 'red';
    }
  }

  // Helper method to get status text
  String getStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.paid:
        return 'Lunas';
      case TransactionStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  // Helper method to get payment method text
  String getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.transfer:
        return 'Transfer Bank';
      case PaymentMethod.card:
        return 'Kartu Debit/Kredit';
      case PaymentMethod.debt:
        return 'Hutang';
    }
  }
}
