import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../database/database_helper.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _problemDescriptionController = TextEditingController();
  final _estimatedCostController = TextEditingController();
  DateTime? _estimatedCompletion;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    _phoneNumberController.dispose();
    _problemDescriptionController.dispose();
    _estimatedCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Tambah Kendaraan'),
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCustomerInfoSection(),
                      const SizedBox(height: 24),
                      _buildVehicleInfoSection(),
                      const SizedBox(height: 24),
                      _buildProblemSection(),
                      const SizedBox(height: 24),
                      _buildEstimationSection(),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Pelanggan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _customerNameController,
            label: 'Nama Pelanggan',
            placeholder: 'Masukkan nama pelanggan',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama pelanggan tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneNumberController,
            label: 'Nomor Telepon',
            placeholder: 'Masukkan nomor telepon',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nomor telepon tidak boleh kosong';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Kendaraan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _vehicleTypeController,
            label: 'Jenis Kendaraan',
            placeholder: 'Contoh: Honda Beat, Yamaha NMAX',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jenis kendaraan tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _licensePlateController,
            label: 'Nomor Polisi',
            placeholder: 'Contoh: B 1234 ABC',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nomor polisi tidak boleh kosong';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProblemSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keluhan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _problemDescriptionController,
            label: 'Deskripsi Masalah',
            placeholder: 'Jelaskan masalah yang dialami',
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Deskripsi masalah tidak boleh kosong';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEstimationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estimasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _estimatedCostController,
            label: 'Estimasi Biaya (Rp)',
            placeholder: 'Masukkan estimasi biaya',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Estimasi biaya tidak boleh kosong';
              }
              if (double.tryParse(value) == null) {
                return 'Estimasi biaya harus berupa angka';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDatePicker(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(8),
          ),
          style: const TextStyle(fontSize: 16, color: CupertinoColors.white),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estimasi Selesai',
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          color: CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _estimatedCompletion != null
                      ? '${_estimatedCompletion!.day}/${_estimatedCompletion!.month}/${_estimatedCompletion!.year}'
                      : 'Pilih tanggal',
                  style: TextStyle(
                    fontSize: 16,
                    color: _estimatedCompletion != null
                        ? CupertinoColors.white
                        : CupertinoColors.systemGrey,
                  ),
                ),
              ),
              const Icon(
                CupertinoIcons.calendar,
                color: CupertinoColors.systemGrey,
                size: 16,
              ),
            ],
          ),
          onPressed: _showDatePicker,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        border: Border(
          top: BorderSide(color: CupertinoColors.systemGrey4.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(12),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(12),
              child: const Text(
                'Simpan',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _isLoading ? null : _saveVehicle,
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: CupertinoColors.darkBackgroundGray,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.darkBackgroundGray,
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.systemGrey4.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Pilih Tanggal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime:
                    _estimatedCompletion ??
                    DateTime.now().add(const Duration(days: 1)),
                minimumDate: DateTime.now(),
                onDateTimeChanged: (dateTime) {
                  setState(() {
                    _estimatedCompletion = dateTime;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Validasi dan konversi estimasi biaya
        final estimatedCostText = _estimatedCostController.text.trim();
        double? estimatedCost;

        if (estimatedCostText.isNotEmpty) {
          estimatedCost = double.tryParse(estimatedCostText);
          if (estimatedCost == null) {
            throw FormatException(
              'Estimasi biaya harus berupa angka yang valid',
            );
          }
        }

        final vehicle = Vehicle(
          id: 'V${DateTime.now().millisecondsSinceEpoch}',
          customerName: _customerNameController.text.trim(),
          vehicleType: _vehicleTypeController.text.trim(),
          licensePlate: _licensePlateController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
          problemDescription: _problemDescriptionController.text.trim(),
          status: VehicleStatus.waiting,
          createdAt: DateTime.now(),
          estimatedCompletion: _estimatedCompletion,
          estimatedCost: estimatedCost,
        );

        print('AddVehicle: Saving vehicle...');
        print('AddVehicle: Customer: ${vehicle.customerName}');
        print('AddVehicle: License: ${vehicle.licensePlate}');
        print('AddVehicle: Created: ${vehicle.createdAt}');

        await _databaseHelper.insertVehicle(vehicle);
        print('AddVehicle: Vehicle saved successfully!');

        Navigator.pop(context);

        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Berhasil'),
            content: const Text('Kendaraan berhasil ditambahkan'),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog sukses
                  Navigator.pop(context); // Kembali ke WorkshopScreen
                },
              ),
            ],
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Gagal menambahkan kendaraan: $e'),
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
}
