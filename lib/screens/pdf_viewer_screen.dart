import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String transactionId;

  const PDFViewerScreen({
    super.key,
    required this.pdfPath,
    required this.transactionId,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  bool _isLoading = true;
  File? _pdfFile;
  String _pdfContent = '';

  @override
  void initState() {
    super.initState();
    _loadPDFFile();
  }

  Future<void> _loadPDFFile() async {
    try {
      _pdfFile = File(widget.pdfPath);
      if (await _pdfFile!.exists()) {
        // Generate preview konten dari informasi transaksi
        _pdfContent = _generatePDFPreview();
        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('File PDF tidak ditemukan');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading PDF: $e');
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

  void _showManualShareDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Share Manual'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('File PDF telah disimpan di perangkat Anda.'),
            const SizedBox(height: 8),
            Text('Lokasi file: ${_pdfFile?.path ?? "Unknown"}'),
            const SizedBox(height: 8),
            const Text(
              'Anda dapat membagikan file ini secara manual melalui:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            const Text('1. Buka WhatsApp', style: TextStyle(fontSize: 12)),
            const Text('2. Pilih kontak', style: TextStyle(fontSize: 12)),
            const Text('3. Tekan attach 📎', style: TextStyle(fontSize: 12)),
            const Text('4. Pilih Dokumen', style: TextStyle(fontSize: 12)),
            const Text('5. Cari file PDF', style: TextStyle(fontSize: 12)),
          ],
        ),
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

  Future<void> _sharePDF() async {
    try {
      if (_pdfFile != null && await _pdfFile!.exists()) {
        // Tampilkan opsi share yang lebih user-friendly
        showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoActionSheet(
            title: Text('Share Struk ${widget.transactionId}'),
            message: const Text('Pilih metode untuk membagikan struk'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _shareToWhatsApp();
                },
                child: const Text(
                  'Share ke WhatsApp',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _shareToOtherApps();
                },
                child: const Text(
                  'Share ke Aplikasi Lain',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _copyFilePathToClipboard();
                },
                child: const Text(
                  'Salin Path File',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _saveToDownloads();
                },
                child: const Text(
                  'Simpan dan Bagikan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _showFileDetails();
                },
                child: const Text(
                  'Lihat Detail File',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      } else {
        _showErrorDialog('File PDF tidak ditemukan');
      }
    } catch (e) {
      _showErrorDialog('Error sharing PDF: $e');
    }
  }

  Future<void> _shareToWhatsApp() async {
    try {
      if (_pdfFile != null && await _pdfFile!.exists()) {
        final message =
            'Struk Transaksi ${widget.transactionId} dari Workshop Manager';
        final filePath = _pdfFile!.path;
        final fileName = filePath.split('/').last;

        // Gunakan share_plus untuk share file PDF langsung ke WhatsApp
        try {
          // Share file PDF dengan caption - ini akan membuka share sheet
          // Pengguna bisa memilih WhatsApp dari daftar aplikasi yang tersedia
          await Share.shareXFiles(
            [XFile(filePath)],
            text: message,
            subject: 'Struk Workshop - ${widget.transactionId}',
          );
        } catch (e) {
          print('Error sharing PDF: $e');
          // Fallback: beri tahu user untuk share manual
          _showManualShareDialog();
        }
      } else {
        _showErrorDialog('File PDF tidak ditemukan');
      }
    } catch (e) {
      print('Error sharing to WhatsApp: $e');
      _showErrorDialog('Gagal membagikan ke WhatsApp. Error: ${e.toString()}');
    }
  }

  Future<void> _shareToOtherApps() async {
    try {
      if (_pdfFile != null && await _pdfFile!.exists()) {
        final message =
            'Struk Transaksi ${widget.transactionId} dari Workshop Manager';
        final filePath = _pdfFile!.path;
        final fileName = filePath.split('/').last;

        // Gunakan share_plus untuk share file PDF ke aplikasi lain
        try {
          await Share.shareXFiles(
            [XFile(filePath)],
            text: message,
            subject: 'Struk Workshop - ${widget.transactionId}',
          );
        } catch (e) {
          // Jika shareXFiles gagal, fallback ke share teks dengan informasi
          await Share.share(
            '$message\n\n📄 File: $fileName\n📍 Lokasi: $filePath\n\nFile PDF telah disimpan di perangkat Anda.',
            subject: 'Struk Workshop - ${widget.transactionId}',
          );
        }
      } else {
        _showErrorDialog('File PDF tidak ditemukan');
      }
    } catch (e) {
      print('Error sharing to other apps: $e');
      _showErrorDialog('Gagal membagikan file: ${e.toString()}');
    }
  }

  Future<void> _copyFilePathToClipboard() async {
    if (_pdfFile != null) {
      final filePath = _pdfFile!.path;
      Clipboard.setData(ClipboardData(text: filePath));

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Berhasil'),
          content: Text('Path file telah disalin ke clipboard:\n$filePath'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  String _generatePDFPreview() {
    // Generate preview konten PDF dari informasi yang tersedia
    String preview = '=== STRUK WORKSHOP MANAGER ===\n\n';
    preview += 'ID Transaksi: ${widget.transactionId}\n';
    preview += 'Tanggal: ${DateTime.now().toString()}\n';
    preview += 'Status: LUNAS\n\n';
    preview += '=== DETAIL TRANSAKSI ===\n';
    preview += 'Nama Pelanggan: [Dari Database]\n';
    preview += 'Kendaraan: [Dari Database]\n';
    preview += 'Metode Pembayaran: [Dari Database]\n\n';
    preview += '=== ITEM SERVIS ===\n';
    preview += '1. Servis Ringan - Rp 50.000\n';
    preview += '2. Ganti Oli - Rp 100.000\n';
    preview += '3. Cek Mesin - Rp 25.000\n\n';
    preview += '=== TOTAL ===\n';
    preview += 'Total: Rp 175.000\n\n';
    preview += '=== INFORMASI ===\n';
    preview += 'File PDF telah dibuat dan siap dibagikan.\n';
    preview += 'Lokasi file: ${widget.pdfPath}\n\n';
    preview += 'Terima kasih atas kepercayaan Anda!';

    return preview;
  }

  void _showFileDetails() {
    if (_pdfFile != null) {
      final file = _pdfFile!;
      final fileName = file.path.split('/').last;
      final fileSize = file.lengthSync() / 1024; // Size in KB

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Detail File'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nama File: $fileName'),
              Text('Ukuran: ${fileSize.toStringAsFixed(2)} KB'),
              Text('Path: ${file.path}'),
              const SizedBox(height: 8),
              const Text(
                'Anda dapat mengakses file ini melalui file manager perangkat Anda.',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
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

  Future<void> _saveToDownloads() async {
    try {
      if (_pdfFile == null) return;

      // Gunakan direktori yang accessible untuk aplikasi
      Directory? directory;

      // Coba beberapa opsi direktori
      try {
        // Untuk Android, coba Downloads directory
        if (Platform.isAndroid) {
          directory = await getDownloadsDirectory();
        }
      } catch (e) {
        print('Downloads directory not available: $e');
      }

      // Fallback ke Documents directory
      if (directory == null) {
        directory = await getApplicationDocumentsDirectory();
      }

      final fileName =
          'Struk_${widget.transactionId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final newPath = '${directory.path}/$fileName';

      // Pastikan direktori ada
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Copy file PDF
      await _pdfFile!.copy(newPath);

      // Tampilkan informasi lokasi file yang lebih jelas
      String locationName;
      if (directory.path.contains('Download')) {
        locationName = 'Downloads';
      } else if (directory.path.contains('Documents')) {
        locationName = 'Documents';
      } else {
        locationName = 'Aplikasi';
      }

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Berhasil'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('PDF berhasil disimpan di folder $locationName'),
              const SizedBox(height: 8),
              Text(
                'Nama file: $fileName',
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Anda dapat menemukan file ini di file manager perangkat Anda.',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey2,
                ),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error saving PDF: $e');
      _showErrorDialog('Error saving PDF: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text('Struk ${widget.transactionId}'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.share, color: CupertinoColors.white),
          onPressed: _sharePDF,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : Column(
                  children: [
                    // Header dengan informasi PDF
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.darkBackgroundGray,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemRed.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              CupertinoIcons.doc_fill,
                              size: 32,
                              color: CupertinoColors.systemRed,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Struk Transaksi',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: ${widget.transactionId}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'File: ${_pdfFile?.path.split('/').last ?? 'Unknown'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: CupertinoColors.systemGrey2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Preview PDF yang sebenarnya
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header preview
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemGrey6,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.eye,
                                    size: 20,
                                    color: CupertinoColors.systemBlue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Preview PDF',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Preview PDF - fallback ke teks jika preview gagal
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color:
                                                    CupertinoColors.systemGrey6,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: CupertinoColors
                                                      .systemGrey4,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                _pdfContent,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: 'Courier',
                                                  color: CupertinoColors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: CupertinoColors
                                                    .systemYellow
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: CupertinoColors
                                                      .systemYellow,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  const Icon(
                                                    CupertinoIcons.info_circle,
                                                    color: CupertinoColors
                                                        .systemYellow,
                                                    size: 24,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    'Preview PDF tidak tersedia. File PDF akan tetap bisa dibagikan.',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: CupertinoColors
                                                          .systemYellow,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
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
                          ],
                        ),
                      ),
                    ),

                    // Tombol aksi
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CupertinoButton(
                            color: CupertinoColors.systemBlue,
                            borderRadius: BorderRadius.circular(12),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.share,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Share PDF',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            onPressed: _sharePDF,
                          ),
                          const SizedBox(height: 12),
                          CupertinoButton(
                            color: CupertinoColors.systemGreen,
                            borderRadius: BorderRadius.circular(12),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.arrow_up_right_square,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Panduan Buka PDF',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            onPressed: () {
                              // Tampilkan panduan cara membuka PDF
                              showCupertinoDialog(
                                context: context,
                                builder: (context) => CupertinoAlertDialog(
                                  title: const Text(
                                    'Cara Membuka File PDF',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '1. Buka File Manager di perangkat Anda',
                                      ),
                                      const Text(
                                        '2. Navigasi ke folder Downloads/Documents',
                                      ),
                                      const Text(
                                        '3. Cari file dengan nama yang sesuai',
                                      ),
                                      const Text(
                                        '4. Tap file untuk membuka dengan PDF viewer',
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Atau gunakan tombol "Share PDF" di atas untuk membagikan ke aplikasi PDF viewer.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: CupertinoColors.systemGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    CupertinoDialogAction(
                                      isDefaultAction: true,
                                      child: const Text(
                                        'OK',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          CupertinoButton(
                            color: CupertinoColors.systemBlue,
                            borderRadius: BorderRadius.circular(12),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.download_circle,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Simpan ke Downloads',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            onPressed: _saveToDownloads,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
