import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CupertinoColors.systemBlue.withOpacity(0.2),
                  CupertinoColors.systemBlue.withOpacity(0.1),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50),
                      const Text(
                        'Workshop Manager',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.white,
                        ),
                      ),
                      Text(
                        'Bengkel Modern & Efisien',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: _buildMenuItems(),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.darkBackgroundGray,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.person_circle,
                      color: CupertinoColors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Hadi Ramdhani',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'v2.0 - Premium Features',
                  style: TextStyle(
                    fontSize: 10,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    final items = [
      _buildMenuItem(icon: CupertinoIcons.home, title: 'Dashboard', index: 0),
      _buildMenuItem(icon: CupertinoIcons.wrench, title: 'Workshop', index: 1),
      _buildMenuItem(
        icon: CupertinoIcons.money_dollar,
        title: 'Kasir',
        index: 2,
      ),
      _buildMenuItem(
        icon: CupertinoIcons.doc_text,
        title: 'Riwayat Transaksi',
        index: 3,
      ),
      const Divider(
        color: CupertinoColors.systemGrey4,
        thickness: 0.5,
        height: 16,
      ),
      _buildMenuItem(
        icon: CupertinoIcons.person_2,
        title: 'Manajemen Teknisi',
        index: 4,
      ),
      _buildMenuItem(
        icon: CupertinoIcons.calendar,
        title: 'Booking Online',
        index: 5,
      ),
      _buildMenuItem(
        icon: CupertinoIcons.bell,
        title: 'Notifikasi',
        index: 6,
        badge: '3',
      ),
      const Divider(
        color: CupertinoColors.systemGrey4,
        thickness: 0.5,
        height: 16,
      ),
      _buildMenuItem(
        icon: CupertinoIcons.chart_bar,
        title: 'Analitik Bisnis',
        index: 7,
      ),
      _buildMenuItem(
        icon: CupertinoIcons.money_dollar_circle,
        title: 'Manajemen Hutang',
        index: 8,
      ),
      _buildMenuItem(
        icon: CupertinoIcons.star,
        title: 'Program Loyalty',
        index: 9,
      ),
      const Divider(
        color: CupertinoColors.systemGrey4,
        thickness: 0.5,
        height: 16,
      ),
      _buildMenuItem(
        icon: CupertinoIcons.settings,
        title: 'Pengaturan',
        index: 10,
      ),
      _buildMenuItem(
        icon: CupertinoIcons.info,
        title: 'Tentang Aplikasi',
        index: 11,
      ),
      _buildMenuItem(
        icon: CupertinoIcons.info,
        title: 'Tentang Sekolah',
        index: 12,
      ),
    ];

    return items;
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
    String? badge,
  }) {
    final isSelected = currentIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => onItemSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? CupertinoColors.systemBlue.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? CupertinoColors.systemBlue
                    : CupertinoColors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? CupertinoColors.systemBlue
                        : CupertinoColors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isSelected)
                Icon(
                  CupertinoIcons.chevron_right,
                  color: CupertinoColors.systemBlue,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
