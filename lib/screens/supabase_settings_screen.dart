import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../database/supabase_database_helper.dart';

class SupabaseSettingsScreen extends StatefulWidget {
  const SupabaseSettingsScreen({super.key});

  @override
  State<SupabaseSettingsScreen> createState() => _SupabaseSettingsScreenState();
}

class _SupabaseSettingsScreenState extends State<SupabaseSettingsScreen> {
  final SupabaseDatabaseHelper _databaseHelper = SupabaseDatabaseHelper();
  String _currentMode = 'local'; // Default ke local untuk menghindari error
  bool _isSyncing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentMode();
  }

  Future<void> _loadCurrentMode() async {
    setState(() {
      _isLoading = true;
    });

    // Load current mode from database helper
    _currentMode = _databaseHelper.mode;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _changeMode(String newMode) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update mode in database helper
      _databaseHelper.mode = newMode;

      // Tunggu sebentar untuk memastikan perubahan diterapkan
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _currentMode = newMode;
        _isLoading = false;
      });

      // Show success message
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Sukses'),
            content: Text(
              'Mode database berhasil diubah ke ${newMode.toUpperCase()}',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Gagal mengubah mode: $e'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      // Sync data from local to Supabase
      await _databaseHelper.syncLocalToSupabase();

      setState(() {
        _isSyncing = false;
      });

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Sukses'),
            content: const Text('Sinkronisasi data berhasil dilakukan'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSyncing = false;
      });

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Gagal sinkronisasi: $e'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Pengaturan Supabase'),
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
          icon: const Icon(CupertinoIcons.bars),
        ),
        middle: const Text('Pengaturan Supabase'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection(),
              const SizedBox(height: 24),
              _buildModeSelection(),
              const SizedBox(height: 24),
              _buildSyncSection(),
              const SizedBox(height: 24),
              _buildStatusSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.cloud,
                color: CupertinoColors.systemBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Supabase Cloud Database',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Aplikasi ini sekarang mendukung database cloud Supabase untuk sinkronisasi data secara real-time.',
            style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
          ),
          const SizedBox(height: 8),
          Text(
            'Mode aktif: ${_currentMode.toUpperCase()}',
            style: TextStyle(
              fontSize: 14,
              color: _getModeColor(_currentMode),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mode Database',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pilih mode operasi database:',
            style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
          ),
          const SizedBox(height: 16),
          _buildModeOption(
            'local',
            'Lokal Only',
            'Gunakan database lokal saja',
            CupertinoIcons.device_phone_portrait,
          ),
          const SizedBox(height: 12),
          _buildModeOption(
            'supabase',
            'Supabase Only',
            'Gunakan database cloud Supabase',
            CupertinoIcons.cloud,
          ),
          const SizedBox(height: 12),
          _buildModeOption(
            'hybrid',
            'Hybrid Mode',
            'Gabungan lokal dan Supabase dengan sinkronisasi otomatis',
            CupertinoIcons.arrow_2_circlepath,
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption(
    String mode,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = _currentMode == mode;

    return GestureDetector(
      onTap: () => _changeMode(mode),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.systemBlue.withOpacity(0.2)
              : CupertinoColors.darkBackgroundGray,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? CupertinoColors.systemBlue
                : CupertinoColors.systemGrey4,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? CupertinoColors.systemBlue
                  : CupertinoColors.systemGrey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? CupertinoColors.white
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                CupertinoIcons.checkmark_alt_circle_fill,
                color: CupertinoColors.systemBlue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sinkronisasi Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sinkronkan data dari lokal ke Supabase:',
            style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              color: CupertinoColors.activeBlue,
              onPressed: _isSyncing ? null : _syncData,
              child: _isSyncing
                  ? const CupertinoActivityIndicator()
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.arrow_up_circle,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Sinkronkan Sekarang',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Koneksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                CupertinoIcons.wifi,
                color: CupertinoColors.systemGreen,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Terhubung ke Supabase',
                  style: TextStyle(fontSize: 14, color: CupertinoColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'URL: https://wsutnrbmgqhrtwggpvhj.supabase.co',
            style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
          ),
        ],
      ),
    );
  }

  Color _getModeColor(String mode) {
    switch (mode) {
      case 'local':
        return CupertinoColors.systemOrange;
      case 'supabase':
        return CupertinoColors.systemBlue;
      case 'hybrid':
        return CupertinoColors.systemGreen;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  @override
  void dispose() {
    _databaseHelper.dispose();
    super.dispose();
  }
}
