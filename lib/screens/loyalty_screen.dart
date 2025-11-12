import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _loyaltyMembers = [];
  Map<String, dynamic> _loyaltyStats = {};

  @override
  void initState() {
    super.initState();
    _loadLoyaltyData();
  }

  Future<void> _loadLoyaltyData() async {
    try {
      final members = await _databaseHelper.getLoyaltyMembers();
      final stats = await _calculateLoyaltyStats(members);

      setState(() {
        _loyaltyMembers = members;
        _loyaltyStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading loyalty data: $e');
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: CupertinoAlertDialog(
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
      ),
    );
  }

  Future<Map<String, dynamic>> _calculateLoyaltyStats(
    List<Map<String, dynamic>> members,
  ) async {
    int totalMembers = members.length;
    int bronzeMembers = members.where((m) => m['tier'] == 'Bronze').length;
    int silverMembers = members.where((m) => m['tier'] == 'Silver').length;
    int goldMembers = members.where((m) => m['tier'] == 'Gold').length;
    int platinumMembers = members.where((m) => m['tier'] == 'Platinum').length;

    double totalPoints = members.fold(
      0.0,
      (sum, m) => sum + (m['points'] as double),
    );
    double totalSpent = members.fold(
      0.0,
      (sum, m) => sum + (m['total_spent'] as double),
    );

    return {
      'totalMembers': totalMembers,
      'bronzeMembers': bronzeMembers,
      'silverMembers': silverMembers,
      'goldMembers': goldMembers,
      'platinumMembers': platinumMembers,
      'totalPoints': totalPoints,
      'totalSpent': totalSpent,
      'avgPointsPerMember': totalMembers > 0 ? totalPoints / totalMembers : 0,
      'avgSpentPerMember': totalMembers > 0 ? totalSpent / totalMembers : 0,
    };
  }

  void _showAddMemberDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (context) => SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 100,
        child: CupertinoAlertDialog(
          title: const Text('Tambah Member Baru'),
          content: Column(
            children: [
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: nameController,
                placeholder: 'Nama Lengkap',
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: phoneController,
                placeholder: 'Nomor Telepon',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: emailController,
                placeholder: 'Email (opsional)',
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Batal'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Tambah'),
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty) {
                  _addLoyaltyMember(
                    nameController.text,
                    phoneController.text,
                    emailController.text,
                  );
                  Navigator.pop(context);
                } else {
                  _showErrorDialog('Nama dan nomor telepon harus diisi');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addLoyaltyMember(
    String name,
    String phone,
    String email,
  ) async {
    try {
      final now = DateTime.now();
      final memberData = {
        'id': 'LOYAL${now.millisecondsSinceEpoch}',
        'customer_phone': phone,
        'customer_name': name,
        'customer_email': email,
        'tier': 'Bronze',
        'points': 0,
        'total_spent': 0.0,
        'join_date': now.millisecondsSinceEpoch,
        'last_activity': now.millisecondsSinceEpoch,
        'discount_percentage': 0.0,
        'special_benefits': 'Welcome bonus: 10% discount on first service',
      };

      await _databaseHelper.insertLoyaltyMember(memberData);
      _loadLoyaltyData();

      showCupertinoDialog(
        context: context,
        builder: (context) => SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: CupertinoAlertDialog(
            title: const Text('Berhasil'),
            content: Text('$name telah ditambahkan sebagai member Bronze'),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      _showErrorDialog('Error adding member: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Program Loyalty'),
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
        middle: const Text('Program Loyalty'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add, color: CupertinoColors.white),
          onPressed: _showAddMemberDialog,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSummaryCards(),
            Expanded(
              child: _loyaltyMembers.isEmpty
                  ? _buildEmptyState()
                  : _buildMemberList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Member',
                  '${_loyaltyStats['totalMembers'] ?? 0}',
                  CupertinoColors.systemBlue,
                  CupertinoIcons.person_2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Poin',
                  '${(_loyaltyStats['totalPoints'] ?? 0).toStringAsFixed(0)}',
                  CupertinoColors.systemPurple,
                  CupertinoIcons.star,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Pengeluaran',
                  'Rp ${(_loyaltyStats['totalSpent'] ?? 0).toStringAsFixed(0)}',
                  CupertinoColors.systemGreen,
                  CupertinoIcons.money_dollar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Rata-rata Poin',
                  '${(_loyaltyStats['avgPointsPerMember'] ?? 0).toStringAsFixed(0)}',
                  CupertinoColors.systemOrange,
                  CupertinoIcons.chart_bar,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTierDistribution(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierDistribution() {
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
            'Distribusi Tier Member',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTierCard(
                  'Bronze',
                  '${_loyaltyStats['bronzeMembers'] ?? 0}',
                  CupertinoColors.systemBrown,
                  '0-999 poin',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTierCard(
                  'Silver',
                  '${_loyaltyStats['silverMembers'] ?? 0}',
                  CupertinoColors.systemGrey,
                  '1000-4999 poin',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTierCard(
                  'Gold',
                  '${_loyaltyStats['goldMembers'] ?? 0}',
                  CupertinoColors.systemYellow,
                  '5000-9999 poin',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTierCard(
                  'Platinum',
                  '${_loyaltyStats['platinumMembers'] ?? 0}',
                  CupertinoColors.systemPurple,
                  '10000+ poin',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard(String tier, String count, Color color, String range) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                tier.substring(0, 1),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          Text(
            tier,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
          Text(
            range,
            style: const TextStyle(
              fontSize: 10,
              color: CupertinoColors.systemGrey2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.star,
            size: 64,
            color: CupertinoColors.systemYellow,
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Member',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan member baru untuk memulai program loyalty',
            style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            color: CupertinoColors.systemBlue,
            child: const Text('Tambah Member'),
            onPressed: _showAddMemberDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildMemberList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _loyaltyMembers.length,
      itemBuilder: (context, index) {
        final member = _loyaltyMembers[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.darkBackgroundGray,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTierColor(member['tier']).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    member['tier'].substring(0, 1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getTierColor(member['tier']),
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
                      member['customer_name'] ?? member['customer_phone'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member['customer_phone'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    if (member['customer_email'] != null &&
                        member['customer_email'].isNotEmpty)
                      Text(
                        member['customer_email'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey2,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${member['points']} poin',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemYellow,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tier ${member['tier']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getTierColor(member['tier']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Diskon ${member['discount_percentage']}%',
                    style: const TextStyle(
                      fontSize: 10,
                      color: CupertinoColors.systemGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'Bronze':
        return CupertinoColors.systemBrown;
      case 'Silver':
        return CupertinoColors.systemGrey;
      case 'Gold':
        return CupertinoColors.systemYellow;
      case 'Platinum':
        return CupertinoColors.systemPurple;
      default:
        return CupertinoColors.systemGrey;
    }
  }
}
