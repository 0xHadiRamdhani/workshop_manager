import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/print_service.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  List<dynamic> _devices = [];
  dynamic _connectedDevice;
  bool _isLoading = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _loadPrinterStatus();
  }

  Future<void> _loadPrinterStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Untuk sementara, simulasi printer yang tersedia
      // Implementasi thermal printer akan dilakukan di versi berikutnya
      _devices = [
        {'name': 'Printer Thermal 1', 'address': '00:11:22:33:44:55'},
        {'name': 'Printer Thermal 2', 'address': '00:11:22:33:44:66'},
      ];
      _connectedDevice = null;
    } catch (e) {
      print('Error loading printer status: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _scanForPrinters() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Simulasi scan printer
      _devices = [
        {'name': 'Printer Thermal 1', 'address': '00:11:22:33:44:55'},
        {'name': 'Printer Thermal 2', 'address': '00:11:22:33:44:66'},
        {'name': 'Printer Thermal 3', 'address': '00:11:22:33:44:77'},
      ];
    } catch (e) {
      print('Error scanning printers: $e');
    }

    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _connectToPrinter(dynamic device) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulasi koneksi ke printer
      print('Connecting to printer: ${device['name']}');
      await Future.delayed(const Duration(seconds: 1)); // Simulasi delay

      // Simulasi koneksi berhasil
      _connectedDevice = device;
      _showMessage('Berhasil terhubung ke ${device['name']}');
    } catch (e) {
      _showMessage('Error connecting to printer: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _disconnectPrinter() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulasi disconnect
      await Future.delayed(const Duration(milliseconds: 500));
      _connectedDevice = null;
      _showMessage('Printer terputus');
    } catch (e) {
      _showMessage('Error disconnecting printer: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testPrint() async {
    if (_connectedDevice == null) {
      _showMessage('Tidak ada printer yang terhubung');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulasi test print
      print('=== TEST PRINT ===');
      print('Bengkel Banimasum');
      print('Jl. Raya Banimasum No. 123');
      print('Telp: 0812-3456-7890');
      print('Printer berhasil terhubung!');
      print('=== END TEST PRINT ===');

      _showMessage('Test print berhasil (simulasi)');
    } catch (e) {
      _showMessage('Error test print: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Informasi'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Pengaturan Printer'),
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
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : Column(
                children: [
                  // Status Printer
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.darkBackgroundGray,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CupertinoColors.systemGrey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _connectedDevice != null
                                  ? CupertinoIcons.checkmark_circle_fill
                                  : CupertinoIcons
                                        .exclamationmark_triangle_fill,
                              color: _connectedDevice != null
                                  ? CupertinoColors.systemGreen
                                  : CupertinoColors.systemOrange,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status Printer',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _connectedDevice != null
                                        ? 'Terhubung: ${_connectedDevice!['name']}'
                                        : 'Tidak ada printer yang terhubung',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_connectedDevice != null) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoButton(
                              color: CupertinoColors.systemRed,
                              child: const Text(
                                'Putuskan',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: _disconnectPrinter,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoButton(
                              color: CupertinoColors.systemBlue,
                              child: const Text(
                                'Test Print',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: _testPrint,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Daftar Printer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Printer Tersedia',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: _isScanning
                              ? const CupertinoActivityIndicator()
                              : const Icon(CupertinoIcons.refresh),
                          onPressed: _isScanning ? null : _scanForPrinters,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _devices.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.printer,
                                  size: 64,
                                  color: CupertinoColors.systemGrey.withOpacity(
                                    0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada printer yang ditemukan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: CupertinoColors.systemGrey
                                        .withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pastikan printer bluetooth dalam keadaan menyala',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.systemGrey
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _devices.length,
                            itemBuilder: (context, index) {
                              final device = _devices[index];
                              final isConnected =
                                  _connectedDevice?['address'] ==
                                  device['address'];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.darkBackgroundGray,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isConnected
                                        ? CupertinoColors.systemGreen
                                              .withOpacity(0.3)
                                        : CupertinoColors.systemGrey
                                              .withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isConnected
                                          ? CupertinoIcons.checkmark_circle_fill
                                          : CupertinoIcons.circle,
                                      color: isConnected
                                          ? CupertinoColors.systemGreen
                                          : CupertinoColors.systemGrey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            device['name'] ?? 'Unknown Device',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: CupertinoColors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            device['address'] ??
                                                'Unknown Address',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: CupertinoColors.systemGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isConnected)
                                      CupertinoButton(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        color: CupertinoColors.systemBlue,
                                        child: const Text(
                                          'Hubungkan',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () =>
                                            _connectToPrinter(device),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
