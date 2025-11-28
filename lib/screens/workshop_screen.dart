import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/workshop_controller.dart';
import '../controllers/main_controller.dart';
import '../models/vehicle.dart';

class WorkshopScreen extends StatelessWidget {
  const WorkshopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkshopController controller = Get.put(WorkshopController());

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
        middle: const Text('Bengkel', style: TextStyle(color: Colors.white)),
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
              onPressed: controller.refreshVehicles,
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                CupertinoIcons.add,
                color: CupertinoColors.systemBlue,
              ),
              onPressed: controller.navigateToAddVehicle,
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildFilterSection(controller),
            Expanded(child: _buildVehicleList(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(WorkshopController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildStatusChip('Semua', controller),
                _buildStatusChip('waiting', controller),
                _buildStatusChip('inProgress', controller),
                _buildStatusChip('completed', controller),
                _buildStatusChip('delivered', controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, WorkshopController controller) {
    return Obx(() {
      final isSelected = controller.selectedStatus.value == status;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isSelected
              ? CupertinoColors.systemBlue
              : CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(20),
          child: Text(
            controller.getStatusText(_parseStatus(status)),
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? CupertinoColors.white : CupertinoColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () => controller.selectedStatus.value = status,
        ),
      );
    });
  }

  Widget _buildVehicleList(WorkshopController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CupertinoActivityIndicator());
      }

      final vehicles = controller.filteredVehicles;

      if (vehicles.isEmpty) {
        return const Center(
          child: Text(
            'Tidak ada data kendaraan',
            style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return _buildVehicleCard(vehicle, controller);
        },
      );
    });
  }

  Widget _buildVehicleCard(Vehicle vehicle, WorkshopController controller) {
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
              color: _getStatusColor(vehicle.status).withOpacity(0.2),
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
                        vehicle.customerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.white,
                        ),
                      ),
                      Text(
                        '${vehicle.vehicleType} - ${vehicle.licensePlate}',
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
                    color: _getStatusColor(vehicle.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.getStatusText(vehicle.status),
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(CupertinoIcons.phone, vehicle.phoneNumber),
                const SizedBox(height: 8),
                _buildInfoRow(
                  CupertinoIcons.wrench,
                  vehicle.problemDescription,
                ),
                if (vehicle.estimatedCost != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    CupertinoIcons.money_dollar,
                    'Estimasi: Rp ${vehicle.estimatedCost!.toStringAsFixed(0)}',
                  ),
                ],
                if (vehicle.estimatedCompletion != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    CupertinoIcons.clock,
                    'Estimasi selesai: ${_formatDate(vehicle.estimatedCompletion!)}',
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
                            controller.navigateToVehicleDetail(vehicle),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: CupertinoColors.systemOrange,
                        borderRadius: BorderRadius.circular(8),
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () =>
                            controller.navigateToEditVehicle(vehicle),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: CupertinoColors.systemRed,
                        borderRadius: BorderRadius.circular(8),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () =>
                            _showDeleteConfirmation(vehicle, controller),
                      ),
                    ),
                  ],
                ),
                if (vehicle.status != VehicleStatus.delivered) ...[
                  const SizedBox(height: 8),
                  _buildStatusUpdateButtons(vehicle, controller),
                ],
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

  Widget _buildStatusUpdateButtons(
    Vehicle vehicle,
    WorkshopController controller,
  ) {
    return Row(
      children: [
        if (vehicle.status == VehicleStatus.waiting)
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(8),
              child: const Text(
                'Mulai Servis',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => controller.updateVehicleStatus(
                vehicle,
                VehicleStatus.inProgress,
              ),
            ),
          ),
        if (vehicle.status == VehicleStatus.inProgress) ...[
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: CupertinoColors.systemGreen,
              borderRadius: BorderRadius.circular(8),
              child: const Text(
                'Selesai',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => controller.updateVehicleStatus(
                vehicle,
                VehicleStatus.completed,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: CupertinoColors.systemOrange,
              borderRadius: BorderRadius.circular(8),
              child: const Text(
                'Tunda',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => controller.updateVehicleStatus(
                vehicle,
                VehicleStatus.waiting,
              ),
            ),
          ),
        ],
        if (vehicle.status == VehicleStatus.completed)
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: CupertinoColors.systemIndigo,
              borderRadius: BorderRadius.circular(8),
              child: const Text(
                'Serahkan',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => controller.updateVehicleStatus(
                vehicle,
                VehicleStatus.delivered,
              ),
            ),
          ),
      ],
    );
  }

  void _showDeleteConfirmation(Vehicle vehicle, WorkshopController controller) {
    Get.dialog(
      CupertinoAlertDialog(
        title: const Text('Hapus Data'),
        content: Text(
          'Yakin ingin menghapus data kendaraan ${vehicle.licensePlate}?',
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Get.back();
              controller.deleteVehicle(vehicle);
            },
            child: const Text('Hapus'),
          ),
          CupertinoDialogAction(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.waiting:
        return CupertinoColors.systemOrange;
      case VehicleStatus.inProgress:
        return CupertinoColors.systemBlue;
      case VehicleStatus.completed:
        return CupertinoColors.systemGreen;
      case VehicleStatus.delivered:
        return CupertinoColors.systemGrey;
    }
  }

  VehicleStatus _parseStatus(String status) {
    switch (status) {
      case 'waiting':
        return VehicleStatus.waiting;
      case 'inProgress':
        return VehicleStatus.inProgress;
      case 'completed':
        return VehicleStatus.completed;
      case 'delivered':
        return VehicleStatus.delivered;
      default:
        return VehicleStatus.waiting;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
