import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../services/print_service.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  final BlueThermalPrinter _bluetoothPrinter = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _connectedDevice;
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
      // Cek printer yang terhubung
      bool? isConnected = await _bluetoothPrinter.isConnected;
      if (isConnected == true) {
        // Dapatkan device yang terhubung
        List<BluetoothDevice> bondedDevices = await _bluetoothPrinter
            .getBondedDevices();
        if (bondedDevices.isNotEmpty) {
          _connectedDevice = bondedDevices.first;
        }
      }

      // Scan printer yang tersedia
      _devices = await _bluetoothPrinter.getBondedDevices();
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
      // Scan ulang printer
      _devices = await _bluetoothPrinter.getBondedDevices();

      // Cek yang terhubung
      bool? isConnected = await _bluetoothPrinter.isConnected;
      if (isConnected == true) {
        List<BluetoothDevice> bondedDevices = await _bluetoothPrinter
            .getBondedDevices();
        if (bondedDevices.isNotEmpty) {
          _connectedDevice = bondedDevices.first;
        }
      }
    } catch (e) {
      print('Error scanning printers: $e');
    }

    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _connectToPrinter(BluetoothDevice device) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Disconnect dari printer lama jika ada
      if (_connectedDevice != null) {
        await _bluetoothPrinter.disconnect();
      }

      // Connect ke printer baru
      await _bluetoothPrinter.connect(device);

      // Test koneksi
      bool? isConnected = await _bluetoothPrinter.isConnected;
      if (isConnected == true) {
        _connectedDevice = device;
        _showMessage('Berhasil terhubung ke ${device.name}');
      } else {
        _showMessage('Gagal terhubung ke printer');
      }
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
      await _bluetoothPrinter.disconnect();
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
      // Cetak test page
      await _bluetoothPrinter.printCustom('=== TEST PRINT ===', 1, 1);
      await _bluetoothPrinter.printCustom('Bengkel Banimasum', 2, 2);
      await _bluetoothPrinter.printCustom('Jl. Raya Banimasum No. 123', 0, 0);
      await _bluetoothPrinter.printCustom('Telp: 0812-3456-7890', 0, 0);
      await _bluetoothPrinter.printNewLine();
      await _bluetoothPrinter.printCustom('Printer berhasil terhubung!', 0, 0);
      await _bluetoothPrinter.printNewLine();
      await _bluetoothPrinter.printNewLine();
      await _bluetoothPrinter.printNewLine();

      _showMessage('Test print berhasil');
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
                                        ? 'Terhubung: ${_connectedDevice!.name}'
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
                              child: const Text('Putuskan'),
                              onPressed: _disconnectPrinter,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoButton(
                              color: CupertinoColors.systemBlue,
                              child: const Text('Test Print'),
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
                                  _connectedDevice?.address == device.address;

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
                                            device.name ?? 'Unknown Device',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: CupertinoColors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            device.address ?? 'Unknown Address',
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
                                        child: const Text('Hubungkan'),
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
