import 'package:get/get.dart';
import '../models/vehicle.dart';
import '../database/database_helper.dart';

class WorkshopController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Observable variables
  var vehicles = <Vehicle>[].obs;
  var isLoading = false.obs;
  var selectedStatus = 'Semua'.obs;

  @override
  void onInit() {
    super.onInit();
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    isLoading.value = true;
    try {
      final loadedVehicles = await _dbHelper.getVehicles();
      vehicles.assignAll(loadedVehicles);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data kendaraan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshVehicles() {
    loadVehicles();
  }

  List<Vehicle> get filteredVehicles {
    if (selectedStatus.value == 'Semua') {
      return vehicles;
    }
    return vehicles
        .where(
          (vehicle) =>
              vehicle.status.toString().split('.').last == selectedStatus.value,
        )
        .toList();
  }

  Future<void> updateVehicleStatus(
    Vehicle vehicle,
    VehicleStatus newStatus,
  ) async {
    try {
      final updatedVehicle = Vehicle(
        id: vehicle.id,
        customerName: vehicle.customerName,
        vehicleType: vehicle.vehicleType,
        licensePlate: vehicle.licensePlate,
        phoneNumber: vehicle.phoneNumber,
        problemDescription: vehicle.problemDescription,
        status: newStatus,
        createdAt: vehicle.createdAt,
        estimatedCompletion: vehicle.estimatedCompletion,
        estimatedCost: vehicle.estimatedCost,
        paymentMethod: vehicle.paymentMethod,
        actualCost: vehicle.actualCost,
        isPaid: vehicle.isPaid,
      );

      await _dbHelper.updateVehicle(updatedVehicle);
      await loadVehicles();

      Get.snackbar(
        'Berhasil',
        'Status kendaraan diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui status: $e');
    }
  }

  Future<void> deleteVehicle(Vehicle vehicle) async {
    try {
      await _dbHelper.deleteVehicle(vehicle.id);
      await loadVehicles();
      Get.snackbar('Berhasil', 'Data kendaraan dihapus');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus data: $e');
    }
  }

  void navigateToAddVehicle() {
    Get.toNamed('/add-vehicle')?.then((_) => loadVehicles());
  }

  void navigateToEditVehicle(Vehicle vehicle) {
    Get.toNamed(
      '/edit-vehicle',
      arguments: vehicle,
    )?.then((_) => loadVehicles());
  }

  void navigateToVehicleDetail(Vehicle vehicle) {
    Get.toNamed('/vehicle-detail', arguments: vehicle);
  }

  // Helper method to get status color
  String getStatusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.waiting:
        return 'orange';
      case VehicleStatus.inProgress:
        return 'blue';
      case VehicleStatus.completed:
        return 'green';
      case VehicleStatus.delivered:
        return 'grey';
    }
  }

  // Helper method to get status text
  String getStatusText(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.waiting:
        return 'Menunggu';
      case VehicleStatus.inProgress:
        return 'Dalam Proses';
      case VehicleStatus.completed:
        return 'Selesai';
      case VehicleStatus.delivered:
        return 'Diserahkan';
    }
  }
}
