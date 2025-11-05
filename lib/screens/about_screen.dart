import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Tentang Aplikasi'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Icon(
                  CupertinoIcons.wrench_fill,
                  size: 80,
                  color: CupertinoColors.systemBlue,
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Workshop Manager',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Versi 1.0.0',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildInfoSection(
                'Tentang Aplikasi',
                'Workshop Manager adalah aplikasi manajemen bengkel motor yang dirancang untuk membantu mencatat dan mengelola data kendaraan, transaksi servis, serta pembayaran dengan mudah dan efisien.',
              ),
              const SizedBox(height: 24),
              _buildInfoSection(
                'Dibuat oleh',
                'SMK Bani Ma\'sum\n\n'
                    'Programmer:\nHadi Ramdhani\n\n'
                    'UI/UX Designer:\nHadi Ramdhani',
              ),
              const SizedBox(height: 24),
              _buildInfoSection(
                'Fitur Utama',
                '• Manajemen kendaraan (tambah, edit, hapus)\n'
                    '• Transaksi servis dengan berbagai layanan\n'
                    '• Pembayaran tunai dan QRIS\n'
                    '• Riwayat transaksi lengkap\n'
                    '• Dashboard statistik harian\n'
                    '• Manajemen produk dan layanan\n'
                    '• Status kendaraan real-time',
              ),
              const SizedBox(height: 24),
              _buildInfoSection(
                'Teknologi',
                '• Flutter (Cross-platform)\n'
                    '• SQLite Database\n'
                    '• Dart Programming Language\n'
                    '• Cupertino Design (iOS Style)',
              ),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.darkBackgroundGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CupertinoColors.systemGrey.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        CupertinoIcons.checkmark_shield,
                        color: CupertinoColors.systemGreen,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Copyright © 2025 SMK Bani Ma\'sum',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Licensed under MIT License',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }
}
