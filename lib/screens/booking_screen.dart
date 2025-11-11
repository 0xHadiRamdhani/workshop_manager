import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../database/database_helper.dart';
import 'add_booking_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<Booking> _bookings = [];
  List<Booking> _filteredBookings = [];
  BookingStatus _selectedFilter = BookingStatus.pending;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await _databaseHelper.getBookings();
      setState(() {
        _bookings = bookings;
        _filterBookings();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading bookings: $e');
    }
  }

  void _filterBookings() {
    setState(() {
      _filteredBookings = _bookings
          .where((booking) => booking.status == _selectedFilter)
          .toList();
    });
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
          middle: Text('Booking Servis'),
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
        middle: const Text('Booking Servis'),
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
          onPressed: _showAddBookingDialog,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildStatusFilter(),
            Expanded(child: _buildBookingList()),
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
            color: CupertinoColors.systemGrey.withValues(alpha: 0.2),
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
            child: CupertinoSlidingSegmentedControl<BookingStatus>(
              children: {
                BookingStatus.pending: Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 11,
                    color: _selectedFilter == BookingStatus.pending
                        ? CupertinoColors.white
                        : CupertinoColors.systemGrey,
                  ),
                ),
                BookingStatus.confirmed: Text(
                  'Dikonfirmasi',
                  style: TextStyle(
                    fontSize: 11,
                    color: _selectedFilter == BookingStatus.confirmed
                        ? CupertinoColors.white
                        : CupertinoColors.systemGrey,
                  ),
                ),
                BookingStatus.completed: Text(
                  'Selesai',
                  style: TextStyle(
                    fontSize: 11,
                    color: _selectedFilter == BookingStatus.completed
                        ? CupertinoColors.white
                        : CupertinoColors.systemGrey,
                  ),
                ),
              },
              onValueChanged: (BookingStatus? value) {
                if (value != null) {
                  setState(() {
                    _selectedFilter = value;
                    _filterBookings();
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

  Widget _buildBookingList() {
    if (_filteredBookings.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada booking',
          style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = _filteredBookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: booking.statusColor.withValues(alpha: 0.2),
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
                      booking.customerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${booking.vehicleType} • ${booking.licensePlate ?? "Belum ada plat"}',
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
                  color: booking.statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: booking.statusColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  booking.statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: booking.statusColor,
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
                        booking.serviceType,
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
                      booking.phoneNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.calendar,
                      size: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${booking.formattedDate} • ${booking.formattedTime}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
                if (booking.isOverdue) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemRed.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: CupertinoColors.systemRed.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.exclamationmark_triangle_fill,
                          color: CupertinoColors.systemRed,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Terlambat',
                          style: TextStyle(
                            fontSize: 11,
                            color: CupertinoColors.systemRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
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
                  onPressed: () => _showBookingDetail(booking),
                ),
              ),
              const SizedBox(width: 8),
              if (booking.status == BookingStatus.pending)
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(8),
                    child: const Text(
                      'Konfirmasi',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () => _confirmBooking(booking),
                  ),
                ),
              if (booking.status == BookingStatus.confirmed)
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () => _completeBooking(booking),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddBookingDialog() {
    Navigator.of(context)
        .push(
          CupertinoPageRoute(builder: (context) => const AddBookingScreen()),
        )
        .then((_) {
          _loadBookings();
        });
  }

  void _showBookingDetail(Booking booking) {
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
                    'Detail Booking',
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
            _buildDetailItem('Nama Pelanggan', booking.customerName),
            _buildDetailItem('Telepon', booking.phoneNumber),
            if (booking.email != null)
              _buildDetailItem('Email', booking.email!),
            _buildDetailItem('Jenis Kendaraan', booking.vehicleType),
            if (booking.licensePlate != null)
              _buildDetailItem('Nomor Polisi', booking.licensePlate!),
            _buildDetailItem('Jenis Servis', booking.serviceType),
            _buildDetailItem('Tanggal', booking.formattedDate),
            _buildDetailItem('Waktu', booking.formattedTime),
            _buildDetailItem(
              'Status',
              booking.statusText,
              color: booking.statusColor,
            ),
            if (booking.notes != null)
              _buildDetailItem('Catatan', booking.notes!),
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

  void _confirmBooking(Booking booking) async {
    final updatedBooking = booking.copyWith(
      status: BookingStatus.confirmed,
      confirmedAt: DateTime.now(),
    );

    try {
      await _databaseHelper.updateBooking(updatedBooking);
      _loadBookings();
    } catch (e) {
      _showErrorDialog('Gagal mengkonfirmasi booking: $e');
    }
  }

  void _completeBooking(Booking booking) async {
    final updatedBooking = booking.copyWith(
      status: BookingStatus.completed,
      completedAt: DateTime.now(),
    );

    try {
      await _databaseHelper.updateBooking(updatedBooking);
      _loadBookings();
    } catch (e) {
      _showErrorDialog('Gagal menyelesaikan booking: $e');
    }
  }
}
