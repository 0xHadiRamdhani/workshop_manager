import 'package:get/get.dart';
import '../models/vehicle.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';

class DashboardController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Observable variables
  var vehicles = <Vehicle>[].obs;
  var transactions = <Transaction>[].obs;
  var isLoading = true.obs;
  var dailyTransactionCount = 0.obs;
  var dailyRevenue = 0.0.obs;
  var dailyCompletedVehicles = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      print('Dashboard: Loading data...');
      final vehiclesData = await _dbHelper.getVehicles();
      final transactionsData = await _dbHelper.getTransactions();

      // Ambil data harian dari analytics
      final analytics = await _dbHelper.getDashboardAnalytics();
      final dailyTransactions = transactionsData.where((t) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        return t.createdAt.isAfter(today) &&
            t.createdAt.isBefore(today.add(const Duration(days: 1)));
      }).toList();
      final dailyRevenueValue = analytics['dailyRevenue'] as double;
      final dailyCompletedVehiclesCount = vehiclesData.where((v) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        return v.createdAt.isAfter(today) &&
            v.createdAt.isBefore(today.add(const Duration(days: 1))) &&
            v.status == VehicleStatus.completed;
      }).length;

      print('Dashboard: Found ${vehiclesData.length} vehicles');
      print('Dashboard: Found ${transactionsData.length} transactions');
      print('Dashboard: Daily transactions: ${dailyTransactions.length}');
      print(
        'Dashboard: Daily revenue: Rp ${dailyRevenueValue.toStringAsFixed(0)}',
      );
      print(
        'Dashboard: Daily completed vehicles: $dailyCompletedVehiclesCount',
      );

      // Urutkan kendaraan berdasarkan tanggal terbaru
      final sortedVehicles = vehiclesData.toList();
      sortedVehicles.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Urutkan transaksi berdasarkan tanggal terbaru
      final sortedTransactions = transactionsData.toList();
      sortedTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Update observable variables
      vehicles.assignAll(sortedVehicles);
      transactions.assignAll(sortedTransactions);
      dailyTransactionCount.value = dailyTransactions.length;
      dailyRevenue.value = dailyRevenueValue;
      dailyCompletedVehicles.value = dailyCompletedVehiclesCount;
      isLoading.value = false;

      print(
        'Dashboard: Data loaded and sorted. Showing ${vehicles.length} vehicles',
      );
    } catch (e) {
      print('Dashboard: Error loading data: $e');
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }

  int get activeVehiclesCount {
    return vehicles
        .where((vehicle) => vehicle.status != VehicleStatus.delivered)
        .length;
  }

  @override
  void onClose() {
    // No need to dispose database helper as it's a singleton
    super.onClose();
  }
}
