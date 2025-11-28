import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/technician_controller.dart';
import '../controllers/main_controller.dart';
import '../models/technician.dart';

class TechnicianManagementScreen extends StatelessWidget {
  const TechnicianManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TechnicianController controller = Get.put(TechnicianController());

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
          'Manajemen Teknisi',
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
              onPressed: controller.refreshTechnicians,
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                CupertinoIcons.add,
                color: CupertinoColors.systemBlue,
              ),
              onPressed: controller.navigateToAddTechnician,
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSummarySection(controller),
            _buildFilterSection(controller),
            Expanded(child: _buildTechnicianList(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(TechnicianController controller) {
    return Obx(() {
      final metrics = controller.getPerformanceMetrics();
      final totalTechnicians = controller.totalTechnicians;
      final activeTechnicians = controller.activeTechnicians;
      final inactiveTechnicians = controller.inactiveTechnicians;
      final averageRating = controller.averageRating;

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
                    'Total Teknisi',
                    '$totalTechnicians',
                    CupertinoIcons.person_2,
                    CupertinoColors.systemBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Aktif',
                    '$activeTechnicians',
                    CupertinoIcons.checkmark_circle,
                    CupertinoColors.systemGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Tidak Aktif',
                    '$inactiveTechnicians',
                    CupertinoIcons.xmark_circle,
                    CupertinoColors.systemRed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Rating Rata-rata',
                    averageRating.toStringAsFixed(1),
                    CupertinoIcons.star,
                    CupertinoColors.systemYellow,
                  ),
                ),
              ],
            ),
            if (metrics['topPerformer'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CupertinoColors.systemYellow.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.star_fill,
                      color: CupertinoColors.systemYellow,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Top Performer',
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemYellow,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            (metrics['topPerformer'] as Technician).name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(metrics['topPerformer'] as Technician).rating}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemYellow,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  Widget _buildFilterSection(TechnicianController controller) {
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
            'Filter Teknisi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            placeholder: 'Cari teknisi...',
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
                _buildFilterChip('Aktif', controller),
                _buildFilterChip('Tidak Aktif', controller),
                _buildFilterChip('Cuti', controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, TechnicianController controller) {
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

  Widget _buildTechnicianList(TechnicianController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CupertinoActivityIndicator());
      }

      final technicians = controller.filteredTechnicians;

      if (technicians.isEmpty) {
        return const Center(
          child: Text(
            'Tidak ada data teknisi',
            style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: technicians.length,
        itemBuilder: (context, index) {
          final technician = technicians[index];
          return _buildTechnicianCard(technician, controller);
        },
      );
    });
  }

  Widget _buildTechnicianCard(
    Technician technician,
    TechnicianController controller,
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
              color: _getStatusColor(technician.status).withOpacity(0.2),
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
                        technician.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.white,
                        ),
                      ),
                      Text(
                        technician.specialization ?? 'Tidak ada spesialisasi',
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      Text(
                        '${technician.experienceYears} tahun pengalaman',
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
                        color: _getStatusColor(technician.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        controller.getStatusText(technician.status),
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.star_fill,
                          size: 14,
                          color: CupertinoColors.systemYellow,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${technician.rating}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ],
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
                _buildInfoRow(CupertinoIcons.phone, technician.phone),
                const SizedBox(height: 8),
                if (technician.email != null)
                  _buildInfoRow(CupertinoIcons.mail, technician.email!),
                const SizedBox(height: 8),
                _buildInfoRow(
                  CupertinoIcons.wrench,
                  '${technician.totalServices} layanan selesai',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  CupertinoIcons.money_dollar,
                  'Gaji: ${controller.getSalaryTypeText(technician.salaryType ?? SalaryType.daily)} - Rp ${technician.salaryAmount?.toStringAsFixed(0) ?? '0'}',
                ),
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
                            controller.navigateToTechnicianDetail(technician),
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
                            controller.navigateToEditTechnician(technician),
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
                            _showDeleteConfirmation(technician, controller),
                      ),
                    ),
                  ],
                ),
                if (technician.status == TechnicianStatus.active) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: CupertinoColors.systemOrange,
                      borderRadius: BorderRadius.circular(8),
                      child: const Text(
                        'Nonaktifkan',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => controller.updateTechnicianStatus(
                        technician,
                        TechnicianStatus.inactive,
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: CupertinoColors.systemGreen,
                      borderRadius: BorderRadius.circular(8),
                      child: const Text(
                        'Aktifkan',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => controller.updateTechnicianStatus(
                        technician,
                        TechnicianStatus.active,
                      ),
                    ),
                  ),
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

  void _showDeleteConfirmation(
    Technician technician,
    TechnicianController controller,
  ) {
    Get.dialog(
      CupertinoAlertDialog(
        title: const Text('Hapus Teknisi'),
        content: Text('Yakin ingin menghapus teknisi ${technician.name}?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Get.back();
              controller.deleteTechnician(technician);
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

  Color _getStatusColor(TechnicianStatus status) {
    switch (status) {
      case TechnicianStatus.active:
        return CupertinoColors.systemGreen;
      case TechnicianStatus.inactive:
        return CupertinoColors.systemRed;
      case TechnicianStatus.onLeave:
        return CupertinoColors.systemOrange;
    }
  }
}
