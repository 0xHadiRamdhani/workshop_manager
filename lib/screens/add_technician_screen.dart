import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/technician.dart';
import '../database/database_helper.dart';

class AddTechnicianScreen extends StatefulWidget {
  const AddTechnicianScreen({super.key});

  @override
  State<AddTechnicianScreen> createState() => _AddTechnicianScreenState();
}

class _AddTechnicianScreenState extends State<AddTechnicianScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _salaryController = TextEditingController();

  SalaryType _selectedSalaryType = SalaryType.daily;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _saveTechnician() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final technician = Technician(
        id: 'TECH${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        specialization: _specializationController.text,
        experienceYears: int.parse(_experienceController.text),
        status: TechnicianStatus.active,
        createdAt: DateTime.now(),
        salaryType: _selectedSalaryType,
        salaryAmount: double.parse(_salaryController.text),
      );

      await DatabaseHelper.instance.insertTechnician(technician);

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Gagal menyimpan teknisi: $e'),
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Tambah Teknisi'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.xmark, color: CupertinoColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  placeholder: 'Masukkan nama teknisi',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Nomor Telepon',
                  placeholder: '081234567890',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Nomor telepon wajib diisi';
                    if (value.length < 10)
                      return 'Nomor telepon minimal 10 digit';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email (Opsional)',
                  placeholder: 'email@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _specializationController,
                  label: 'Spesialisasi',
                  placeholder: 'Contoh: Mesin, Kelistrikan, AC',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Spesialisasi wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _experienceController,
                  label: 'Pengalaman (Tahun)',
                  placeholder: '5',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Pengalaman wajib diisi';
                    if (int.tryParse(value) == null)
                      return 'Harus berupa angka';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildSalaryTypeSelector(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _salaryController,
                  label: 'Jumlah Gaji',
                  placeholder: '150000',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Jumlah gaji wajib diisi';
                    if (double.tryParse(value) == null)
                      return 'Harus berupa angka';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(12),
                    child: _isLoading
                        ? const CupertinoActivityIndicator()
                        : const Text(
                            'SIMPAN TEKNISI',
                            style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    onPressed: _isLoading ? null : _saveTechnician,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(8),
          ),
          style: const TextStyle(color: CupertinoColors.white),
          placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey),
        ),
      ],
    );
  }

  Widget _buildSalaryTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipe Gaji',
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSalaryTypeOption('Harian', SalaryType.daily),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSalaryTypeOption('Bulanan', SalaryType.monthly),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSalaryTypeOption('Komisi', SalaryType.commission),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryTypeOption(String label, SalaryType type) {
    final isSelected = _selectedSalaryType == type;
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: isSelected
          ? CupertinoColors.systemBlue
          : CupertinoColors.systemGrey6,
      borderRadius: BorderRadius.circular(6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected
              ? CupertinoColors.white
              : CupertinoColors.white.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () {
        setState(() {
          _selectedSalaryType = type;
        });
      },
    );
  }
}
