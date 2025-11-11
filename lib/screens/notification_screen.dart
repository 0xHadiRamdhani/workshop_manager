import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/notification.dart' as app_notification;
import '../database/database_helper.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<app_notification.Notification> _notifications = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await _databaseHelper.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading notifications: $e');
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Notifikasi'),
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
        middle: const Text('Notifikasi'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.refresh,
            color: CupertinoColors.white,
          ),
          onPressed: _loadNotifications,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildNotificationStats(),
            Expanded(child: _buildNotificationList()),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationStats() {
    final totalNotifications = _notifications.length;
    final unreadNotifications = _notifications.where((n) => !n.isRead).length;
    final urgentNotifications = _notifications.where((n) => n.isUrgent).length;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total',
                  '$totalNotifications',
                  CupertinoColors.systemBlue,
                  CupertinoIcons.bell,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Belum Dibaca',
                  '$unreadNotifications',
                  CupertinoColors.systemOrange,
                  CupertinoIcons.bell_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Urgent',
                  '$urgentNotifications',
                  CupertinoColors.systemRed,
                  CupertinoIcons.exclamationmark_triangle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Prioritas',
                  'Tinggi',
                  CupertinoColors.systemPurple,
                  CupertinoIcons.flag,
                ),
              ),
            ],
          ),
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

  Widget _buildNotificationList() {
    if (_notifications.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada notifikasi',
          style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(app_notification.Notification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead
            ? CupertinoColors.darkBackgroundGray.withOpacity(0.7)
            : CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: notification.typeColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      _getNotificationIcon(notification.type),
                      color: notification.typeColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      notification.typeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: notification.typeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: notification.priorityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: notification.priorityColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        notification.priorityText,
                        style: TextStyle(
                          fontSize: 10,
                          color: notification.priorityColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notification.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            notification.message,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  notification.formattedTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
              if (!notification.isRead)
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  color: CupertinoColors.systemBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  child: const Text(
                    'Tandai Dibaca',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () => _markAsRead(notification),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(app_notification.NotificationType type) {
    switch (type) {
      case app_notification.NotificationType.serviceReminder:
        return CupertinoIcons.wrench;
      case app_notification.NotificationType.bookingConfirmation:
        return CupertinoIcons.checkmark_circle;
      case app_notification.NotificationType.paymentDue:
        return CupertinoIcons.money_dollar;
      case app_notification.NotificationType.stockAlert:
        return CupertinoIcons.exclamationmark_triangle;
      case app_notification.NotificationType.systemAlert:
        return CupertinoIcons.bell;
    }
  }

  void _markAsRead(app_notification.Notification notification) async {
    try {
      await _databaseHelper.markNotificationAsRead(notification.id);
      _loadNotifications();
    } catch (e) {
      _showErrorDialog('Gagal menandai notifikasi sebagai dibaca: $e');
    }
  }
}
