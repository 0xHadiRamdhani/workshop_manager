import 'package:flutter/material.dart';

enum PaymentMethod { cash, transfer, card }

enum TransactionStatus { pending, paid, cancelled }

class Transaction {
  final String id;
  final String vehicleId;
  final String customerName;
  final List<ServiceItem> services;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? paidAt;
  final double? cashAmount;
  final double? changeAmount;

  Transaction({
    required this.id,
    required this.vehicleId,
    required this.customerName,
    required this.services,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.paidAt,
    this.cashAmount,
    this.changeAmount,
  });

  String get paymentMethodText {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.transfer:
        return 'Transfer';
      case PaymentMethod.card:
        return 'Kartu';
    }
  }

  String get statusText {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.paid:
        return 'Lunas';
      case TransactionStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Color get statusColor {
    switch (status) {
      case TransactionStatus.pending:
        return const Color(0xFFFF9500);
      case TransactionStatus.paid:
        return const Color(0xFF34C759);
      case TransactionStatus.cancelled:
        return const Color(0xFFFF3B30);
    }
  }
}

class ServiceItem {
  final String name;
  final double price;
  final int quantity;

  ServiceItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;
}
