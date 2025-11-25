import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _isLoading = true;
  Map<String, dynamic> _analytics = {};
  List<Map<String, dynamic>> _monthlyData = [];
  List<Map<String, dynamic>> _serviceData = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final analytics = await _databaseHelper.getDashboardAnalytics();
      final monthlyData = await _generateMonthlyData();
      final serviceData = await _generateServiceData();

      setState(() {
        _analytics = analytics;
        _monthlyData = monthlyData;
        _serviceData = serviceData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(
        'Error loading analytics: $e\n\nTry resetting the database if the problem persists.',
      );
    }
  }

  Future<void> _resetDatabase() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _databaseHelper.resetDatabase();

      setState(() {
        _isLoading = false;
      });

      _showSuccessDialog(
        'Database reset successfully. Please restart the app.',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error resetting database: $e');
    }
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
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

  void _showResetDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Reset Database'),
        content: const Text(
          'This will delete all data and recreate the database. Are you sure?',
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Reset'),
            onPressed: () {
              Navigator.pop(context);
              _resetDatabase();
            },
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _generateMonthlyData() async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> data = [];

    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final startOfMonth = DateTime(monthDate.year, monthDate.month, 1);
      final endOfMonth = DateTime(monthDate.year, monthDate.month + 1, 1);

      final transactions = await _databaseHelper.getTransactionsByDateRange(
        startOfMonth,
        endOfMonth,
      );
      final revenue = transactions.fold(0.0, (sum, t) => sum + t.totalAmount);

      data.add({
        'month': _getMonthName(monthDate.month),
        'revenue': revenue,
        'transactions': transactions.length,
      });
    }

    return data;
  }

  Future<List<Map<String, dynamic>>> _generateServiceData() async {
    return [
      {
        'service': 'Ganti Oli',
        'count': 45,
        'color': CupertinoColors.systemBlue,
      },
      {
        'service': 'Service Rutin',
        'count': 32,
        'color': CupertinoColors.systemGreen,
      },
      {
        'service': 'Ganti Ban',
        'count': 28,
        'color': CupertinoColors.systemOrange,
      },
      {
        'service': 'Tune Up',
        'count': 24,
        'color': CupertinoColors.systemPurple,
      },
      {'service': 'Ganti Rem', 'count': 18, 'color': CupertinoColors.systemRed},
    ];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Analitik Bisnis'),
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
        middle: const Text('Analitik Bisnis'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(
                CupertinoIcons.refresh,
                color: CupertinoColors.white,
              ),
              onPressed: _loadAnalytics,
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(
                CupertinoIcons.delete,
                color: CupertinoColors.white,
              ),
              onPressed: () => _showResetDialog(),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(),
              const SizedBox(height: 24),
              _buildMonthlyRevenueChart(),
              const SizedBox(height: 24),
              _buildServiceDistribution(),
              const SizedBox(height: 24),
              _buildTopServices(),
              const SizedBox(height: 24),
              _buildPerformanceMetrics(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Pendapatan Hari Ini',
                'Rp ${_analytics['dailyRevenue']?.toStringAsFixed(0) ?? '0'}',
                CupertinoColors.systemGreen,
                CupertinoIcons.money_dollar,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Transaksi Hari Ini',
                '${_analytics['dailyTransactions'] ?? 0}',
                CupertinoColors.systemBlue,
                CupertinoIcons.doc_text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Pendapatan Bulan Ini',
                'Rp ${_analytics['monthlyRevenue']?.toStringAsFixed(0) ?? '0'}',
                CupertinoColors.systemPurple,
                CupertinoIcons.chart_bar,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Booking Pending',
                '${_analytics['pendingBookings'] ?? 0}',
                CupertinoColors.systemOrange,
                CupertinoIcons.calendar_badge_minus,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pendapatan Bulanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _monthlyData.length,
              itemBuilder: (context, index) {
                final data = _monthlyData[index];
                final maxRevenue = _monthlyData.fold(
                  0.0,
                  (max, d) => d['revenue'] > max ? d['revenue'] : max,
                );
                final height = (data['revenue'] / maxRevenue) * 130;

                return Container(
                  width: 55,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      Container(
                        height: 130,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          data['month'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Rp ${(data['revenue'] / 1000000).toStringAsFixed(1)}M',
                          style: const TextStyle(
                            fontSize: 9,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDistribution() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribusi Layanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: _serviceData.map((data) {
              final totalCount = _serviceData.fold(
                0,
                (sum, d) => sum + (d['count'] as int),
              );
              final percentage = ((data['count'] as int) / totalCount) * 100;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: data['color'],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['service'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey5,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: percentage / 100,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: data['color'],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${data['count']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopServices() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Layanan Terpopuler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: _serviceData.take(3).map((data) {
              final index = _serviceData.indexOf(data);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.darkBackgroundGray,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: data['color'].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: data['color'],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          '#${index + 1}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['service'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.white,
                            ),
                          ),
                          Text(
                            '${data['count']} kali servis',
                            style: const TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${((data['count'] as int) / _serviceData.fold(0, (sum, d) => sum + (d['count'] as int)) * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metrik Kinerja',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Efisiensi',
                  '92%',
                  CupertinoColors.systemGreen,
                  'Rata-rata waktu servis',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Kepuasan',
                  '4.8/5',
                  CupertinoColors.systemBlue,
                  'Rating pelanggan',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Utilitas',
                  '85%',
                  CupertinoColors.systemOrange,
                  'Pemanfaatan teknisi',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Retensi',
                  '78%',
                  CupertinoColors.systemPurple,
                  'Pelanggan kembali',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CupertinoColors.systemGrey),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}
