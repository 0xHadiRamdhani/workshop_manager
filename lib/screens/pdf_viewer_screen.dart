import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
        // Baca konten PDF sebagai teks
        _pdfContent = await _pdfFile!.readAsString();
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
                  _copyFilePathToClipboard();
                },
                child: const Text('Salin Path File'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _saveToDownloads();
                },
                child: const Text('Simpan dan Bagikan'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _showFileDetails();
                },
                child: const Text('Lihat Detail File'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
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
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
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

      // Gunakan direktori dokumen sebagai fallback jika Downloads tidak tersedia
      Directory? directory;

      try {
        directory = await getDownloadsDirectory();
      } catch (e) {
        print('Downloads directory not available: $e');
      }

      // Jika Downloads tidak tersedia (di iOS), gunakan Documents directory
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

      await _pdfFile!.copy(newPath);

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Berhasil'),
          content: Text(
            'PDF berhasil disimpan di ${directory!.path.split('/').last} sebagai $fileName',
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

                    // Preview konten PDF
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
                            // Konten PDF
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGrey6,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: CupertinoColors.systemGrey4,
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
                                Icon(CupertinoIcons.share, size: 20),
                                SizedBox(width: 8),
                                Text('Share PDF'),
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
                                Icon(CupertinoIcons.download_circle, size: 20),
                                SizedBox(width: 8),
                                Text('Simpan ke Downloads'),
                              ],
                            ),
                            onPressed: _saveToDownloads,
                          ),
                          const SizedBox(height: 12),
                          CupertinoButton(
                            color: CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(12),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.printer, size: 20),
                                SizedBox(width: 8),
                                Text('Cetak Ulang'),
                              ],
                            ),
                            onPressed: () {
                              // Implement print functionality
                              showCupertinoDialog(
                                context: context,
                                builder: (context) => CupertinoAlertDialog(
                                  title: const Text('Info'),
                                  content: const Text(
                                    'Fitur cetak ulang akan segera tersedia',
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
                            },
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
