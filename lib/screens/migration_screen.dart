import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/migration_service.dart';
import '../database/supabase_schema.dart';
import '../database/supabase_table_creator.dart';
import '../database/manual_table_setup.dart';
import '../services/supabase_data_seeder.dart';

class MigrationScreen extends StatefulWidget {
  const MigrationScreen({super.key});

  @override
  State<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  final MigrationService _migrationService = MigrationService();
  final SupabaseDataSeeder _dataSeeder = SupabaseDataSeeder();
  final SupabaseTableCreator _tableCreator = SupabaseTableCreator();
  bool _isLoading = false;
  bool _isCreatingTables = false;
  bool _isSeedingData = false;
  String _status = '';
  Map<String, dynamic>? _migrationResult;

  @override
  void initState() {
    super.initState();
    _checkMigrationStatus();
  }

  Future<void> _checkMigrationStatus() async {
    setState(() {
      _isLoading = true;
      _status = 'Memeriksa status migrasi...';
    });

    try {
      final needsMigration = await _migrationService.needsMigration();
      setState(() {
        _status = needsMigration
            ? 'Data lokal ditemukan. Siap untuk migrasi.'
            : 'Tidak ada data yang perlu dimigrasi.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _createSupabaseTables() async {
    setState(() {
      _isCreatingTables = true;
      _status = 'Mencoba membuat tabel otomatis...';
    });

    try {
      // Coba buat tabel otomatis
      await _tableCreator.createAllTables();

      setState(() {
        _status = '✅ Tabel berhasil dibuat di Supabase!';
        _isCreatingTables = false;
      });
    } catch (e) {
      setState(() {
        _status =
            '⚠️ Error otomatis: ${e.toString()}\n\nGunakan panduan manual di bawah.';
        _isCreatingTables = false;
      });
      // Tampilkan instruksi manual
      _showManualSetupInstructions();
    }
  }

  void _showManualSetupInstructions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
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
                  const Expanded(
                    child: Text(
                      'Panduan Setup Manual',
                      style: TextStyle(
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemYellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: CupertinoColors.systemYellow.withOpacity(
                              0.3,
                            ),
                          ),
                        ),
                        child: const Text(
                          '⚠️ Karena masalah API key, Anda perlu membuat tabel manual melalui dashboard Supabase.',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemYellow,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'LANGKAH-LANGKAH:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStep(
                        '1',
                        'Buka dashboard Supabase di https://app.supabase.com',
                      ),
                      _buildStep('2', 'Pilih project workshop-manager Anda'),
                      _buildStep('3', 'Klik menu "SQL Editor" di sidebar'),
                      _buildStep(
                        '4',
                        'Copy SQL script dari file lib/database/manual_table_setup.dart',
                      ),
                      _buildStep('5', 'Paste dan jalankan query SQL'),
                      _buildStep(
                        '6',
                        'Verifikasi tabel di menu "Table Editor"',
                      ),
                      const SizedBox(height: 16),
                      CupertinoButton(
                        color: CupertinoColors.systemBlue,
                        borderRadius: BorderRadius.circular(12),
                        child: const Text('📋 Copy SQL Script'),
                        onPressed: () {
                          // Copy SQL script ke clipboard
                          final sqlScript = ManualTableSetup.setupInstructions;
                          // Implementasi copy to clipboard bisa ditambahkan di sini
                          Navigator.of(context).pop();
                          setState(() {
                            _status =
                                '✅ Panduan setup ditampilkan. Copy SQL script dari manual_table_setup.dart';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seedSampleData() async {
    setState(() {
      _isSeedingData = true;
      _status = 'Mengisi data contoh ke Supabase...';
    });

    try {
      await _dataSeeder.seedAllData();
      setState(() {
        _status = '✅ Data contoh berhasil diisi ke Supabase!';
        _isSeedingData = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error mengisi data: ${e.toString()}';
        _isSeedingData = false;
      });
    }
  }

  Future<void> _migrateData() async {
    setState(() {
      _isLoading = true;
      _status = 'Memulai migrasi data...';
    });

    try {
      // Backup data sebelum migrasi
      final backupFile = await _migrationService.backupLocalData();
      print('✅ Data dibackup ke: $backupFile');

      // Mulai migrasi
      final result = await _migrationService.migrateAllData();

      setState(() {
        _migrationResult = result;
        if (result['success'] == true) {
          _status =
              '✅ Migrasi berhasil! Total data: ${result['totalMigrated']}';
        } else {
          _status = '❌ Migrasi gagal: ${result['error']}';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error migrasi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _showMigrationDetails() async {
    if (_migrationResult == null) return;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                  const Expanded(
                    child: Text(
                      'Detail Migrasi',
                      style: TextStyle(
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_migrationResult!['results'] != null) ...[
                        _buildDetailRow(
                          'Produk',
                          _migrationResult!['results']['products'],
                        ),
                        _buildDetailRow(
                          'Teknisi',
                          _migrationResult!['results']['technicians'],
                        ),
                        _buildDetailRow(
                          'Kendaraan',
                          _migrationResult!['results']['vehicles'],
                        ),
                        _buildDetailRow(
                          'Transaksi',
                          _migrationResult!['results']['transactions'],
                        ),
                        _buildDetailRow(
                          'Item Layanan',
                          _migrationResult!['results']['serviceItems'],
                        ),
                        _buildDetailRow(
                          'Booking',
                          _migrationResult!['results']['bookings'],
                        ),
                        _buildDetailRow(
                          'Notifikasi',
                          _migrationResult!['results']['notifications'],
                        ),
                        _buildDetailRow(
                          'Pembayaran Hutang',
                          _migrationResult!['results']['debtPayments'],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        'Total: ${_migrationResult!['totalMigrated'] ?? 0} data',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.systemBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, Map<String, int>? data) {
    if (data == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${data['success'] ?? 0} berhasil, ${data['error'] ?? 0} gagal',
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        middle: const Text('Migrasi Data'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.darkBackgroundGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Migrasi ke Supabase',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_migrationResult != null)
                CupertinoButton(
                  color: CupertinoColors.systemBlue,
                  borderRadius: BorderRadius.circular(12),
                  child: const Text('Lihat Detail Migrasi'),
                  onPressed: _showMigrationDetails,
                ),
              const SizedBox(height: 20),
              CupertinoButton(
                color: CupertinoColors.systemOrange,
                borderRadius: BorderRadius.circular(12),
                child: _isCreatingTables
                    ? const CupertinoActivityIndicator()
                    : const Text(
                        'Buat Tabel Supabase',
                        style: TextStyle(color: Colors.white),
                      ),
                onPressed: _isCreatingTables ? null : _createSupabaseTables,
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                color: CupertinoColors.systemPurple,
                borderRadius: BorderRadius.circular(12),
                child: _isSeedingData
                    ? const CupertinoActivityIndicator()
                    : const Text(
                        'Isi Data Contoh',
                        style: TextStyle(color: Colors.white),
                      ),
                onPressed: _isSeedingData ? null : _seedSampleData,
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                color: CupertinoColors.systemGreen,
                borderRadius: BorderRadius.circular(12),
                child: _isLoading
                    ? const CupertinoActivityIndicator()
                    : const Text(
                        'Mulai Migrasi',
                        style: TextStyle(color: Colors.white),
                      ),
                onPressed: _isLoading ? null : _migrateData,
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                color: CupertinoColors.systemGrey,
                borderRadius: BorderRadius.circular(12),
                child: const Text(
                  'Refresh Status',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _checkMigrationStatus,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CupertinoColors.systemYellow.withOpacity(0.3),
                  ),
                ),
                child: const Text(
                  '⚠️ Pastikan koneksi internet stabil selama proses migrasi. Data akan dibackup otomatis sebelum migrasi.',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemYellow,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
