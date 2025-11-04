import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Vehicle> _vehicles = [];
  List<Transaction> _transactions = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data setiap kali screen ini muncul kembali
    print('Dashboard: didChangeDependencies called');
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Method untuk refresh data yang bisa dipanggil dari luar
  Future<void> refreshData() async {
    await _loadData();
  }

  Future<void> _loadData() async {
    try {
      print('Dashboard: Loading data...');
      final vehicles = await _databaseHelper.getVehicles();
      final transactions = await _databaseHelper.getTransactions();

      print('Dashboard: Found ${vehicles.length} vehicles');
      print('Dashboard: Found ${transactions.length} transactions');

      // Debug: print vehicle details
      for (var i = 0; i < vehicles.length; i++) {
        print(
          'Vehicle $i: ${vehicles[i].customerName} - ${vehicles[i].licensePlate} - Created: ${vehicles[i].createdAt}',
        );
      }

      // Urutkan kendaraan berdasarkan tanggal terbaru
      final sortedVehicles = vehicles.toList();
      sortedVehicles.sort((a, b) {
        final comparison = b.createdAt.compareTo(a.createdAt);
        print(
          'Sorting: ${a.customerName} (${a.createdAt}) vs ${b.customerName} (${b.createdAt}) = $comparison',
        );
        return comparison;
      });

      // Urutkan transaksi berdasarkan tanggal terbaru
      final sortedTransactions = transactions.toList();
      sortedTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _vehicles = sortedVehicles;
        _transactions = sortedTransactions;
        _isLoading = false;
      });

      print(
        'Dashboard: Data loaded and sorted. Showing ${_vehicles.length} vehicles',
      );
    } catch (e) {
      print('Dashboard: Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Dashboard'),
          backgroundColor: CupertinoColors.darkBackgroundGray,
        ),
        child: SafeArea(child: Center(child: CupertinoActivityIndicator())),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Dashboard'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(),
              const SizedBox(height: 24),
              _buildRecentVehicles(),
              const SizedBox(height: 24),
              _buildRecentTransactions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Kendaraan Aktif',
                '${_vehicles.length}',
                CupertinoColors.systemBlue,
                CupertinoIcons.car,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Pendapatan Hari Ini',
                'Rp 1.250.000',
                CupertinoColors.systemGreen,
                CupertinoIcons.money_dollar,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Transaksi Hari Ini',
                '12',
                CupertinoColors.systemOrange,
                CupertinoIcons.doc_text,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Selesai Hari Ini',
                '8',
                CupertinoColors.systemPurple,
                CupertinoIcons.checkmark_seal,
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildRecentVehicles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kendaraan Terbaru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _vehicles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final vehicle = _vehicles[index];
            return _buildVehicleCard(vehicle);
          },
        ),
      ],
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                    Text(
                      '${vehicle.vehicleType} • ${vehicle.licensePlate}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: vehicle.statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  vehicle.statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: vehicle.statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            vehicle.problemDescription,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaksi Terbaru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final transaction = _transactions[index];
            return _buildTransactionCard(transaction);
          },
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Container(
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
                  '${transaction.services.length} layanan',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${transaction.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
              ),
              Text(
                transaction.statusText,
                style: TextStyle(
                  fontSize: 12,
                  color: transaction.statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
