import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../database/database_helper.dart';

class AddBookingScreen extends StatefulWidget {
  const AddBookingScreen({super.key});

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '09:00';
  bool _isLoading = false;

  final List<String> _availableTimes = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    _serviceTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final booking = Booking(
        id: 'BOOK${DateTime.now().millisecondsSinceEpoch}',
        customerName: _nameController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        vehicleType: _vehicleTypeController.text,
        licensePlate: _licensePlateController.text.isEmpty
            ? null
            : _licensePlateController.text,
        serviceType: _serviceTypeController.text,
        preferredDate: _selectedDate,
        preferredTime: _selectedTime,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await DatabaseHelper.instance.insertBooking(booking);

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Gagal menyimpan booking: $e'),
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

  Future<void> _selectDate() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.darkBackgroundGray,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pilih Tanggal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    child: const Text('Selesai'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                minimumDate: DateTime.now(),
                maximumDate: DateTime.now().add(const Duration(days: 30)),
                onDateTimeChanged: (dateTime) {
                  setState(() {
                    _selectedDate = dateTime;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Tambah Booking'),
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
          child: Material(
            type: MaterialType.transparency,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nama Pelanggan',
                    placeholder: 'Masukkan nama pelanggan',
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
                    controller: _vehicleTypeController,
                    label: 'Jenis Kendaraan',
                    placeholder: 'Contoh: Honda Beat, Yamaha NMAX',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Jenis kendaraan wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _licensePlateController,
                    label: 'Nomor Polisi (Opsional)',
                    placeholder: 'B 1234 ABC',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _serviceTypeController,
                    label: 'Jenis Servis',
                    placeholder: 'Contoh: Ganti Oli, Service Rutin',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Jenis servis wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDateTimeSelector(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _notesController,
                    label: 'Catatan (Opsional)',
                    placeholder: 'Catatan tambahan',
                    maxLines: 3,
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
                              'SIMPAN BOOKING',
                              style: TextStyle(
                                fontSize: 16,
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      onPressed: _isLoading ? null : _saveBooking,
                    ),
                  ),
                ],
              ),
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
    int? maxLines,
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
          maxLines: maxLines,
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

  Widget _buildDateTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal & Waktu',
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.calendar,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(color: CupertinoColors.white),
                    ),
                  ],
                ),
                onPressed: _selectDate,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.clock,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedTime,
                      style: const TextStyle(color: CupertinoColors.white),
                    ),
                  ],
                ),
                onPressed: _showTimePicker,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showTimePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.darkBackgroundGray,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pilih Waktu',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    child: const Text('Selesai'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedTime = _availableTimes[index];
                  });
                },
                children: _availableTimes
                    .map(
                      (time) => Center(
                        child: Text(
                          time,
                          style: const TextStyle(color: CupertinoColors.white),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
