import 'package:get/get.dart';
import '../models/technician.dart';
import '../database/database_helper.dart';

class TechnicianController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Observable variables
  var technicians = <Technician>[].obs;
  var isLoading = false.obs;
  var selectedFilter = 'Semua'.obs;
  var searchQuery = ''.obs;

  // Computed properties
  List<Technician> get filteredTechnicians {
    var filtered = technicians.toList();

    // Filter by status
    if (selectedFilter.value != 'Semua') {
      filtered = filtered.where((t) {
        switch (selectedFilter.value) {
          case 'Aktif':
            return t.status == TechnicianStatus.active;
          case 'Tidak Aktif':
            return t.status == TechnicianStatus.inactive;
          case 'Cuti':
            return t.status == TechnicianStatus.onLeave;
          default:
            return true;
        }
      }).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((t) {
        final nameMatch = t.name.toLowerCase().contains(
          searchQuery.value.toLowerCase(),
        );
        final specializationMatch =
            t.specialization?.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ) ??
            false;
        return nameMatch || specializationMatch;
      }).toList();
    }

    return filtered;
  }

  // Statistics
  int get totalTechnicians => technicians.length;
  int get activeTechnicians =>
      technicians.where((t) => t.status == TechnicianStatus.active).length;
  int get inactiveTechnicians =>
      technicians.where((t) => t.status == TechnicianStatus.inactive).length;
  double get averageRating => technicians.isEmpty
      ? 0.0
      : technicians.fold(0.0, (sum, t) => sum + t.rating) / technicians.length;

  @override
  void onInit() {
    super.onInit();
    loadTechnicians();
  }

  Future<void> loadTechnicians() async {
    isLoading.value = true;
    try {
      final loadedTechnicians = await _dbHelper.getTechnicians();
      technicians.assignAll(loadedTechnicians);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data teknisi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshTechnicians() {
    loadTechnicians();
  }

  Future<void> addTechnician(Technician technician) async {
    try {
      await _dbHelper.insertTechnician(technician);
      await loadTechnicians();
      Get.snackbar('Berhasil', 'Teknisi berhasil ditambahkan');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan teknisi: $e');
    }
  }

  Future<void> updateTechnician(Technician technician) async {
    try {
      await _dbHelper.updateTechnician(technician);
      await loadTechnicians();
      Get.snackbar('Berhasil', 'Data teknisi diperbarui');
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui data teknisi: $e');
    }
  }

  Future<void> deleteTechnician(Technician technician) async {
    try {
      await _dbHelper.deleteTechnician(technician.id);
      await loadTechnicians();
      Get.snackbar('Berhasil', 'Teknisi dihapus');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus teknisi: $e');
    }
  }

  Future<void> updateTechnicianStatus(
    Technician technician,
    TechnicianStatus newStatus,
  ) async {
    try {
      final updatedTechnician = Technician(
        id: technician.id,
        name: technician.name,
        phone: technician.phone,
        email: technician.email,
        specialization: technician.specialization,
        experienceYears: technician.experienceYears,
        status: newStatus,
        createdAt: technician.createdAt,
        lastActive: technician.lastActive,
        rating: technician.rating,
        totalServices: technician.totalServices,
        salaryType: technician.salaryType,
        salaryAmount: technician.salaryAmount,
      );

      await updateTechnician(updatedTechnician);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui status teknisi: $e');
    }
  }

  void navigateToAddTechnician() {
    Get.toNamed('/add-technician')?.then((_) => loadTechnicians());
  }

  void navigateToEditTechnician(Technician technician) {
    Get.toNamed(
      '/edit-technician',
      arguments: technician,
    )?.then((_) => loadTechnicians());
  }

  void navigateToTechnicianDetail(Technician technician) {
    Get.toNamed('/technician-detail', arguments: technician);
  }

  // Helper method to get status color
  String getStatusColor(TechnicianStatus status) {
    switch (status) {
      case TechnicianStatus.active:
        return 'green';
      case TechnicianStatus.inactive:
        return 'red';
      case TechnicianStatus.onLeave:
        return 'orange';
    }
  }

  // Helper method to get status text
  String getStatusText(TechnicianStatus status) {
    switch (status) {
      case TechnicianStatus.active:
        return 'Aktif';
      case TechnicianStatus.inactive:
        return 'Tidak Aktif';
      case TechnicianStatus.onLeave:
        return 'Cuti';
    }
  }

  // Helper method to get salary type text
  String getSalaryTypeText(SalaryType type) {
    switch (type) {
      case SalaryType.daily:
        return 'Harian';
      case SalaryType.monthly:
        return 'Bulanan';
      case SalaryType.commission:
        return 'Komisi';
    }
  }

  // Calculate performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    if (technicians.isEmpty) {
      return {
        'averageRating': 0.0,
        'totalServices': 0,
        'topPerformer': null,
        'activePercentage': 0.0,
      };
    }

    final totalServices = technicians.fold(
      0,
      (sum, t) => sum + t.totalServices,
    );
    final topPerformer = technicians.reduce(
      (a, b) => a.rating > b.rating ? a : b,
    );
    final activePercentage = (activeTechnicians / totalTechnicians) * 100;

    return {
      'averageRating': averageRating,
      'totalServices': totalServices,
      'topPerformer': topPerformer,
      'activePercentage': activePercentage,
    };
  }
}
