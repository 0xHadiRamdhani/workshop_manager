import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/technician.dart';
import '../database/database_helper.dart';
import 'add_technician_screen.dart';

class TechnicianManagementScreen extends StatefulWidget {
  const TechnicianManagementScreen({super.key});

  @override
  State<TechnicianManagementScreen> createState() =>
      _TechnicianManagementScreenState();
}

class _TechnicianManagementScreenState
    extends State<TechnicianManagementScreen> {
  List<Technician> _technicians = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
  }

  Future<void> _loadTechnicians() async {
    try {
      final technicians = await _databaseHelper.getTechnicians();
      setState(() {
        _technicians = technicians;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading technicians: $e');
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Manajemen Teknisi'),
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
        middle: const Text('Manajemen Teknisi'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.add,
            color: CupertinoColors.systemBlue,
          ),
          onPressed: _showAddTechnicianDialog,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSummaryCards(),
            Expanded(child: _buildTechnicianList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final activeTechnicians = _technicians
        .where((t) => t.status == TechnicianStatus.active)
        .length;
    final totalServices = _technicians.fold(
      0,
      (sum, t) => sum + t.totalServices,
    );
    final avgRating = _technicians.isEmpty
        ? 0.0
        : _technicians.map((t) => t.rating).reduce((a, b) => a + b) /
              _technicians.length;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Teknisi Aktif',
                  '$activeTechnicians',
                  CupertinoColors.systemBlue,
                  CupertinoIcons.person_2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Servis',
                  '$totalServices',
                  CupertinoColors.systemGreen,
                  CupertinoIcons.wrench,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Rating Rata-rata',
                  avgRating.toStringAsFixed(1),
                  CupertinoColors.systemOrange,
                  CupertinoIcons.star,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Teknisi',
                  '${_technicians.length}',
                  CupertinoColors.systemPurple,
                  CupertinoIcons.group,
                ),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildTechnicianList() {
    if (_technicians.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada teknisi terdaftar',
          style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _technicians.length,
      itemBuilder: (context, index) {
        final technician = _technicians[index];
        return _buildTechnicianCard(technician);
      },
    );
  }

  Widget _buildTechnicianCard(Technician technician) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: technician.statusColor.withOpacity(0.2),
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
                      technician.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      technician.specialization,
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
                  color: technician.statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: technician.statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  technician.statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: technician.statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rating',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.star_fill,
                          color: CupertinoColors.systemYellow,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          technician.rating.toStringAsFixed(1),
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
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Servis Selesai',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    Text(
                      '${technician.totalServices}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gaji',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    Text(
                      'Rp ${technician.salaryAmount?.toStringAsFixed(0) ?? '0'}/${technician.salaryTypeText}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
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
                  onPressed: () => _showTechnicianDetail(technician),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: technician.status == TechnicianStatus.active
                      ? CupertinoColors.systemOrange
                      : CupertinoColors.systemGreen,
                  borderRadius: BorderRadius.circular(8),
                  child: Text(
                    technician.status == TechnicianStatus.active
                        ? 'Nonaktifkan'
                        : 'Aktifkan',
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () => _toggleTechnicianStatus(technician),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTechnicianDialog() {
    Navigator.of(context)
        .push(
          CupertinoPageRoute(builder: (context) => const AddTechnicianScreen()),
        )
        .then((_) {
          _loadTechnicians();
        });
  }

  void _showTechnicianDetail(Technician technician) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: CupertinoColors.darkBackgroundGray,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Detail Teknisi',
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
              _buildDetailItem('Nama', technician.name),
              _buildDetailItem('Telepon', technician.phone),
              if (technician.email != null)
                _buildDetailItem('Email', technician.email!),
              _buildDetailItem('Spesialisasi', technician.specialization),
              _buildDetailItem(
                'Pengalaman',
                '${technician.experienceYears} tahun',
              ),
              _buildDetailItem(
                'Status',
                technician.statusText,
                color: technician.statusColor,
              ),
              _buildDetailItem(
                'Rating',
                '${technician.rating.toStringAsFixed(1)} / 5.0',
              ),
              _buildDetailItem(
                'Total Servis',
                '${technician.totalServices} kendaraan',
              ),
              _buildDetailItem('Tipe Gaji', technician.salaryTypeText),
              _buildDetailItem(
                'Jumlah Gaji',
                'Rp ${technician.salaryAmount?.toStringAsFixed(0) ?? '0'}',
              ),
            ],
          ),
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

  void _toggleTechnicianStatus(Technician technician) async {
    final newStatus = technician.status == TechnicianStatus.active
        ? TechnicianStatus.inactive
        : TechnicianStatus.active;

    final updatedTechnician = technician.copyWith(status: newStatus);

    try {
      await _databaseHelper.updateTechnician(updatedTechnician);
      _loadTechnicians();
    } catch (e) {
      _showErrorDialog('Gagal update status teknisi: $e');
    }
  }
}
