import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';
import 'add_vehicle_screen.dart';
import 'cash_input_screen.dart';
import 'receipt_screen.dart';

class WorkshopScreen extends StatefulWidget {
  const WorkshopScreen({super.key});

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  List<Vehicle> _vehicles = [];
  List<Vehicle> _filteredVehicles = [];
  VehicleStatus _selectedFilter = VehicleStatus.waiting;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data setiap kali screen ini muncul kembali
    print('Workshop: didChangeDependencies called');
    _loadVehicles();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    try {
      print('Workshop: Loading vehicles...');
      final vehicles = await _databaseHelper.getVehicles();
      print('Workshop: Found ${vehicles.length} vehicles');

      // Debug: print all vehicles
      for (var i = 0; i < vehicles.length; i++) {
        print(
          'Vehicle $i: ${vehicles[i].customerName} - ${vehicles[i].licensePlate} - Status: ${vehicles[i].status} - Created: ${vehicles[i].createdAt}',
        );
      }

      setState(() {
        _vehicles = vehicles;
        _filterVehicles();
        _isLoading = false;
      });
      print('Workshop: Filtered vehicles: ${_filteredVehicles.length}');
    } catch (e) {
      print('Workshop: Error loading vehicles: $e');
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  void _filterVehicles() {
    setState(() {
      _filteredVehicles = _vehicles
          .where((vehicle) => vehicle.status == _selectedFilter)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Workshop'),
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
        middle: Text('Workshop'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.add,
            color: CupertinoColors.systemBlue,
          ),
          onPressed: _showAddVehicleDialog,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildStatusFilter(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredVehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = _filteredVehicles[index];
                  return _buildVehicleCard(vehicle);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          const Icon(
            CupertinoIcons.slider_horizontal_3,
            color: CupertinoColors.systemGrey,
            size: 16,
          ),
          const SizedBox(width: 8),
          const Text(
            'Filter:',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CupertinoSlidingSegmentedControl<VehicleStatus>(
              children: {
                VehicleStatus.waiting: Text(
                  'Menunggu',
                  style: TextStyle(
                    fontSize: 11,
                    color: _selectedFilter == VehicleStatus.waiting
                        ? CupertinoColors.white
                        : CupertinoColors.systemGrey,
                  ),
                ),
                VehicleStatus.inProgress: Text(
                  'Proses',
                  style: TextStyle(
                    fontSize: 11,
                    color: _selectedFilter == VehicleStatus.inProgress
                        ? CupertinoColors.white
                        : CupertinoColors.systemGrey,
                  ),
                ),
                VehicleStatus.completed: Text(
                  'Selesai',
                  style: TextStyle(
                    fontSize: 11,
                    color: _selectedFilter == VehicleStatus.completed
                        ? CupertinoColors.white
                        : CupertinoColors.systemGrey,
                  ),
                ),
                VehicleStatus.delivered: Text(
                  'Diserahkan',
                  style: TextStyle(
                    fontSize: 11,
                    color: _selectedFilter == VehicleStatus.delivered
                        ? CupertinoColors.white
                        : CupertinoColors.systemGrey,
                  ),
                ),
              },
              onValueChanged: (VehicleStatus? value) {
                if (value != null) {
                  setState(() {
                    _selectedFilter = value;
                    _filterVehicles();
                  });
                }
              },
              groupValue: _selectedFilter,
              backgroundColor: CupertinoColors.darkBackgroundGray,
              thumbColor: CupertinoColors.systemBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: vehicle.statusColor.withOpacity(0.2),
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
                      vehicle.customerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: vehicle.statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: vehicle.statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  vehicle.statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: vehicle.statusColor,
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
                      CupertinoIcons.wrench,
                      size: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        vehicle.problemDescription,
                        style: const TextStyle(
                          fontSize: 14,
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
                      CupertinoIcons.phone,
                      size: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      vehicle.phoneNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimasi Biaya',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    Text(
                      'Rp ${vehicle.estimatedCost?.toStringAsFixed(0) ?? '0'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (vehicle.estimatedCompletion != null) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estimasi Selesai',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      Text(
                        _formatDate(vehicle.estimatedCompletion!),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (vehicle.isPaid || vehicle.status == VehicleStatus.delivered) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: vehicle.isPaid
                    ? CupertinoColors.systemGreen.withOpacity(0.2)
                    : CupertinoColors.systemRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: vehicle.isPaid
                      ? CupertinoColors.systemGreen.withOpacity(0.3)
                      : CupertinoColors.systemRed.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    vehicle.isPaid
                        ? CupertinoIcons.checkmark_circle_fill
                        : CupertinoIcons.exclamationmark_triangle_fill,
                    color: vehicle.isPaid
                        ? CupertinoColors.systemGreen
                        : CupertinoColors.systemRed,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    vehicle.isPaid ? 'Sudah Dibayar' : 'Belum Dibayar',
                    style: TextStyle(
                      fontSize: 11,
                      color: vehicle.isPaid
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.systemRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(8),
                  child: const Text(
                    'Detail',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () => _showVehicleDetail(vehicle),
                ),
              ),
              const SizedBox(width: 8),
              if (vehicle.status != VehicleStatus.delivered)
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: vehicle.status == VehicleStatus.completed
                        ? CupertinoColors.systemGreen
                        : CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(8),
                    child: Text(
                      vehicle.status == VehicleStatus.completed
                          ? 'Serahkan Motor'
                          : 'Update Status',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () => _showStatusUpdateDialog(vehicle),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Hari ini ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Besok ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAddVehicleDialog() {
    print('Workshop: Opening AddVehicleScreen...');
    Navigator.of(context)
        .push(
          CupertinoPageRoute(builder: (context) => const AddVehicleScreen()),
        )
        .then((_) {
          print('Workshop: Returned from AddVehicleScreen, refreshing...');
          // Refresh kendaraan setelah kembali dari AddVehicleScreen
          if (mounted) {
            _loadVehicles();
          }
        });
  }

  void _showVehicleDetail(Vehicle vehicle) {
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
                    'Detail Kendaraan',
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
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailItem('Nama Pelanggan', vehicle.customerName),
            _buildDetailItem('Jenis Kendaraan', vehicle.vehicleType),
            _buildDetailItem('Nomor Polisi', vehicle.licensePlate),
            _buildDetailItem('Nomor Telepon', vehicle.phoneNumber),
            _buildDetailItem('Keluhan', vehicle.problemDescription),
            _buildDetailItem('Status', vehicle.statusText),
            _buildDetailItem(
              'Estimasi Biaya',
              'Rp ${vehicle.estimatedCost?.toStringAsFixed(0) ?? '0'}',
            ),
            if (vehicle.actualCost != null)
              _buildDetailItem(
                'Biaya Aktual',
                'Rp ${vehicle.actualCost?.toStringAsFixed(0) ?? '0'}',
                color: CupertinoColors.systemGreen,
              ),
            if (vehicle.paymentMethod != null)
              _buildDetailItem(
                'Metode Pembayaran',
                _getPaymentMethodText(vehicle.paymentMethod!),
              ),
            if (vehicle.isPaid)
              _buildDetailItem(
                'Status Pembayaran',
                'Sudah Dibayar',
                color: CupertinoColors.systemGreen,
              )
            else if (vehicle.status == VehicleStatus.delivered)
              _buildDetailItem(
                'Status Pembayaran',
                'Belum Dibayar',
                color: CupertinoColors.systemRed,
              ),
            if (vehicle.estimatedCompletion != null)
              _buildDetailItem(
                'Estimasi Selesai',
                _formatDate(vehicle.estimatedCompletion!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color ?? CupertinoColors.white,
              fontWeight: FontWeight.w500,
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
        return 'Transfer Bank';
      case PaymentMethod.card:
        return 'Kartu Debit/Kredit';
    }
  }

  void _showStatusUpdateDialog(Vehicle vehicle) {
    // Jika status akan diubah ke delivered, tampilkan dialog pembayaran
    if (vehicle.status == VehicleStatus.completed) {
      _showPaymentDialog(vehicle);
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Update Status'),
          content: Text('Ubah status kendaraan ${vehicle.licensePlate}?'),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Batal'),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Update'),
              onPressed: () async {
                Navigator.pop(context);
                await _updateVehicleStatus(vehicle);
              },
            ),
          ],
        ),
      );
    }
  }

  void _showPaymentDialog(Vehicle vehicle) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 400,
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
                    'Pembayaran Servis',
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
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.darkBackgroundGray,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: CupertinoColors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pelanggan: ${vehicle.customerName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.white,
                    ),
                  ),
                  Text(
                    'Kendaraan: ${vehicle.vehicleType} • ${vehicle.licensePlate}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Biaya Servis: Rp ${vehicle.estimatedCost?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pilih Metode Pembayaran:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentOption('Tunai', PaymentMethod.cash, vehicle),
            const SizedBox(height: 8),
            _buildPaymentOption(
              'Transfer Bank',
              PaymentMethod.transfer,
              vehicle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String title,
    PaymentMethod method,
    Vehicle vehicle,
  ) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: CupertinoColors.systemBlue.withOpacity(0.2),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(
            _getPaymentIcon(method),
            color: CupertinoColors.systemBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            color: CupertinoColors.systemGrey,
            size: 16,
          ),
        ],
      ),
      onPressed: () => _processPayment(vehicle, method),
    );
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return CupertinoIcons.money_dollar;
      case PaymentMethod.transfer:
        return CupertinoIcons.building_2_fill;
      default:
        return CupertinoIcons.money_dollar;
    }
  }

  void _processPayment(Vehicle vehicle, PaymentMethod method) {
    // Tutup dialog pembayaran dengan aman
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    if (method == PaymentMethod.cash) {
      _showCashInputScreen(vehicle);
    } else {
      // Transfer bank
      _processBankTransfer(vehicle);
    }
  }

  void _showCashInputScreen(Vehicle vehicle) {
    print(
      'Workshop: Opening CashInputScreen for vehicle ${vehicle.licensePlate}',
    );
    Navigator.of(context)
        .push(
          CupertinoPageRoute(
            builder: (context) => CashInputScreen(
              totalAmount: vehicle.estimatedCost ?? 0,
              cartItems: [], // Kosongkan untuk workshop
              paymentMethod: PaymentMethod.cash,
            ),
          ),
        )
        .then((result) {
          print('Workshop: CashInputScreen returned with result: $result');
          if (result != null && result is Map<String, dynamic>) {
            final cashAmount = result['cashAmount'] as double;
            final change = result['change'] as double;
            print(
              'Workshop: Processing cash payment with cashAmount: $cashAmount, change: $change',
            );
            _completePayment(
              vehicle,
              PaymentMethod.cash,
              cashAmount: cashAmount,
              change: change,
            );
          }
        });
  }

  void _processBankTransfer(Vehicle vehicle) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Transfer Bank'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Silakan transfer ke rekening berikut:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.darkBackgroundGray,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: CupertinoColors.systemGrey4,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bank: BCA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const Text(
                    'No. Rekening: 1234567890',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                  const Text(
                    'Atas Nama: Workshop Manager',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jumlah: Rp ${vehicle.estimatedCost?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Setelah transfer, klik "Sudah Transfer" untuk melanjutkan.',
              style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Batal'),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Sudah Transfer'),
            onPressed: () {
              Navigator.pop(context);
              // Kembalikan data yang sama seperti metode lainnya
              _completePayment(
                vehicle,
                PaymentMethod.transfer,
                cashAmount: vehicle.estimatedCost,
                change: 0.0,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _completePayment(
    Vehicle vehicle,
    PaymentMethod method, {
    double? cashAmount,
    double? change,
  }) async {
    print(
      'Workshop: _completePayment called for vehicle ${vehicle.licensePlate} with method: $method',
    );

    // Update status kendaraan menjadi delivered
    final updatedVehicle = vehicle.copyWith(
      status: VehicleStatus.delivered,
      paymentMethod: method,
      actualCost: vehicle.estimatedCost,
      isPaid: true,
    );

    try {
      print('Workshop: Updating vehicle status to delivered...');
      await _databaseHelper.updateVehicle(updatedVehicle);
      print('Workshop: Vehicle status updated successfully');

      // Buat transaksi untuk pembayaran workshop
      final transaction = Transaction(
        id: 'W${DateTime.now().millisecondsSinceEpoch}',
        vehicleId: vehicle.id,
        customerName: vehicle.customerName,
        services: [
          ServiceItem(
            name: 'Servis ${vehicle.vehicleType} - ${vehicle.licensePlate}',
            price: vehicle.estimatedCost ?? 0,
            quantity: 1,
          ),
        ],
        totalAmount: vehicle.estimatedCost ?? 0,
        paymentMethod: method,
        status: TransactionStatus.paid,
        createdAt: DateTime.now(),
        paidAt: DateTime.now(),
        cashAmount: cashAmount,
        changeAmount: change,
      );

      print('Workshop: Inserting transaction...');
      await _databaseHelper.insertTransaction(transaction);
      print('Workshop: Transaction inserted successfully');

      // Simpan reference untuk navigasi
      final currentContext = context;

      print('Workshop: Loading vehicles...');
      _loadVehicles(); // Refresh data

      print('Workshop: Navigating to receipt screen...');

      // Navigasi ke receipt screen - lakukan setelah delay kecil untuk memastikan UI siap
      Future.delayed(const Duration(milliseconds: 100), () {
        print('Workshop: Executing delayed navigation to receipt screen');
        Navigator.of(currentContext)
            .push(
              CupertinoPageRoute(
                builder: (context) => ReceiptScreen(
                  transaction: transaction,
                  cashAmount: method == PaymentMethod.cash ? cashAmount : null,
                  change: method == PaymentMethod.cash ? change : null,
                ),
              ),
            )
            .then((result) {
              print('Workshop: Returned from receipt screen');
              // Refresh data setelah kembali dari receipt
              if (mounted) {
                print('Workshop: Refreshing vehicles after receipt screen');
                _loadVehicles();
              }
            });
      });

      print('Workshop: Navigation to receipt screen initiated');
    } catch (e) {
      print('Workshop: Error in _completePayment: $e');
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Gagal memproses pembayaran: $e'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      );
    }
  }

  Future<void> _updateVehicleStatus(Vehicle vehicle) async {
    // Jika status completed dan belum dibayar, tampilkan dialog pembayaran
    if (vehicle.status == VehicleStatus.completed && !vehicle.isPaid) {
      _showPaymentDialog(vehicle);
      return;
    }

    // Tentukan status berikutnya berdasarkan status saat ini
    VehicleStatus newStatus;
    switch (vehicle.status) {
      case VehicleStatus.waiting:
        newStatus = VehicleStatus.inProgress;
        break;
      case VehicleStatus.inProgress:
        newStatus = VehicleStatus.completed;
        break;
      case VehicleStatus.completed:
        newStatus = VehicleStatus.delivered;
        break;
      case VehicleStatus.delivered:
        newStatus = VehicleStatus.waiting;
        break;
    }

    final updatedVehicle = vehicle.copyWith(status: newStatus);

    try {
      await _databaseHelper.updateVehicle(updatedVehicle);
      _loadVehicles(); // Refresh data
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Gagal update status: $e'),
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
  }
}
