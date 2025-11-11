import 'package:flutter/material.dart';

enum NotificationType {
  serviceReminder,
  bookingConfirmation,
  paymentDue,
  stockAlert,
  systemAlert,
}

enum NotificationRecipientType { customer, technician, manager, system }

enum NotificationPriority { low, medium, high, urgent }

enum NotificationStatus { pending, sent, read, failed }

class Notification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final NotificationRecipientType recipientType;
  final String? recipientId;
  final NotificationStatus status;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? readAt;
  final String? relatedId;
  final NotificationPriority priority;

  Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.recipientType,
    this.recipientId,
    required this.status,
    required this.createdAt,
    this.sentAt,
    this.readAt,
    this.relatedId,
    required this.priority,
  });

  Notification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    NotificationRecipientType? recipientType,
    String? recipientId,
    NotificationStatus? status,
    DateTime? createdAt,
    DateTime? sentAt,
    DateTime? readAt,
    String? relatedId,
    NotificationPriority? priority,
  }) {
    return Notification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      recipientType: recipientType ?? this.recipientType,
      recipientId: recipientId ?? this.recipientId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      relatedId: relatedId ?? this.relatedId,
      priority: priority ?? this.priority,
    );
  }

  String get typeText {
    switch (type) {
      case NotificationType.serviceReminder:
        return 'Pengingat Servis';
      case NotificationType.bookingConfirmation:
        return 'Konfirmasi Booking';
      case NotificationType.paymentDue:
        return 'Pembayaran Jatuh Tempo';
      case NotificationType.stockAlert:
        return 'Peringatan Stok';
      case NotificationType.systemAlert:
        return 'Peringatan Sistem';
    }
  }

  Color get typeColor {
    switch (type) {
      case NotificationType.serviceReminder:
        return const Color(0xFF007AFF);
      case NotificationType.bookingConfirmation:
        return const Color(0xFF34C759);
      case NotificationType.paymentDue:
        return const Color(0xFFFF9500);
      case NotificationType.stockAlert:
        return const Color(0xFFFF3B30);
      case NotificationType.systemAlert:
        return const Color(0xFF5856D6);
    }
  }

  String get priorityText {
    switch (priority) {
      case NotificationPriority.low:
        return 'Rendah';
      case NotificationPriority.medium:
        return 'Medium';
      case NotificationPriority.high:
        return 'Tinggi';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case NotificationPriority.low:
        return const Color(0xFF8E8E93);
      case NotificationPriority.medium:
        return const Color(0xFF007AFF);
      case NotificationPriority.high:
        return const Color(0xFFFF9500);
      case NotificationPriority.urgent:
        return const Color(0xFFFF3B30);
    }
  }

  String get statusText {
    switch (status) {
      case NotificationStatus.pending:
        return 'Pending';
      case NotificationStatus.sent:
        return 'Terkirim';
      case NotificationStatus.read:
        return 'Dibaca';
      case NotificationStatus.failed:
        return 'Gagal';
    }
  }

  Color get statusColor {
    switch (status) {
      case NotificationStatus.pending:
        return const Color(0xFFFF9500);
      case NotificationStatus.sent:
        return const Color(0xFF007AFF);
      case NotificationStatus.read:
        return const Color(0xFF34C759);
      case NotificationStatus.failed:
        return const Color(0xFFFF3B30);
    }
  }

  bool get isUrgent {
    return priority == NotificationPriority.urgent;
  }

  bool get isRead {
    return status == NotificationStatus.read;
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} menit lalu';
      }
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
