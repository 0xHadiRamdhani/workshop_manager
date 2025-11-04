import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../database/database_helper.dart';
import 'add_vehicle_screen.dart';

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

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await _databaseHelper.getVehicles();
      setState(() {
        _vehicles = vehicles;
        _filterVehicles();
        _isLoading = false;
      });
    } catch (e) {
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
                    fontSize: 12,
                    color: _selectedFilter == VehicleStatus.waiting
                        ? CupertinoColors.white
                        : CupertinoColors.systemGrey,
                  ),
                ),
                VehicleStatus.inProgress: Text(
                  'Proses',
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedFilter == VehicleStatus.inProgress
                        ? CupertinoColors.white
                        : CupertinoColors.systemGrey,
                  ),
                ),
                VehicleStatus.completed: Text(
                  'Selesai',
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedFilter == VehicleStatus.completed
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
              backgroundColor: CupertinoColors.systemGrey5,
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
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: CupertinoColors.systemBlue,
                  borderRadius: BorderRadius.circular(8),
                  child: const Text(
                    'Update Status',
                    style: TextStyle(
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
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const AddVehicleScreen()),
    ).then((_) {
      // Refresh kendaraan setelah kembali dari AddVehicleScreen
      _loadVehicles();
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
                  onPressed: () => Navigator.pop(context),
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

  Widget _buildDetailItem(String label, String value) {
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
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(Vehicle vehicle) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Update Status'),
        content: Text('Ubah status kendaraan ${vehicle.licensePlate}?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
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

  Future<void> _updateVehicleStatus(Vehicle vehicle) async {
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
