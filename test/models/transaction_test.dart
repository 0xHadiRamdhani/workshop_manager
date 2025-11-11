import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:workshop_manager/models/transaction.dart';

void main() {
  group('Transaction Model Tests', () {
    test('should create Transaction instance correctly', () {
      final services = [
        ServiceItem(name: 'Service A', price: 50000, quantity: 1),
        ServiceItem(name: 'Service B', price: 75000, quantity: 2),
      ];

      final transaction = Transaction(
        id: 'T001',
        vehicleId: 'V001',
        customerName: 'John Doe',
        services: services,
        totalAmount: 200000,
        paymentMethod: PaymentMethod.cash,
        status: TransactionStatus.paid,
        createdAt: DateTime(2024, 1, 1),
        paidAt: DateTime(2024, 1, 1, 14, 30),
        cashAmount: 250000,
        changeAmount: 50000,
      );

      expect(transaction.id, 'T001');
      expect(transaction.vehicleId, 'V001');
      expect(transaction.customerName, 'John Doe');
      expect(transaction.services.length, 2);
      expect(transaction.totalAmount, 200000);
      expect(transaction.paymentMethod, PaymentMethod.cash);
      expect(transaction.status, TransactionStatus.paid);
      expect(transaction.createdAt, DateTime(2024, 1, 1));
      expect(transaction.paidAt, DateTime(2024, 1, 1, 14, 30));
      expect(transaction.cashAmount, 250000);
      expect(transaction.changeAmount, 50000);
    });

    test('should create Transaction with minimal required fields', () {
      final services = [
        ServiceItem(name: 'Service A', price: 50000, quantity: 1),
      ];

      final transaction = Transaction(
        id: 'T002',
        vehicleId: 'V002',
        customerName: 'Jane Smith',
        services: services,
        totalAmount: 50000,
        paymentMethod: PaymentMethod.transfer,
        status: TransactionStatus.pending,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(transaction.paidAt, isNull);
      expect(transaction.cashAmount, isNull);
      expect(transaction.changeAmount, isNull);
    });

    test('paymentMethodText should return correct text', () {
      final transactionCash = Transaction(
        id: 'T001',
        vehicleId: 'V001',
        customerName: 'Test',
        services: [ServiceItem(name: 'Service', price: 50000, quantity: 1)],
        totalAmount: 50000,
        paymentMethod: PaymentMethod.cash,
        status: TransactionStatus.paid,
        createdAt: DateTime(2024, 1, 1),
      );

      final transactionTransfer = Transaction(
        id: 'T002',
        vehicleId: 'V002',
        customerName: 'Test',
        services: [ServiceItem(name: 'Service', price: 50000, quantity: 1)],
        totalAmount: 50000,
        paymentMethod: PaymentMethod.transfer,
        status: TransactionStatus.paid,
        createdAt: DateTime(2024, 1, 1),
      );

      final transactionCard = Transaction(
        id: 'T003',
        vehicleId: 'V003',
        customerName: 'Test',
        services: [ServiceItem(name: 'Service', price: 50000, quantity: 1)],
        totalAmount: 50000,
        paymentMethod: PaymentMethod.card,
        status: TransactionStatus.paid,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(transactionCash.paymentMethodText, 'Tunai');
      expect(transactionTransfer.paymentMethodText, 'Transfer Bank');
      expect(transactionCard.paymentMethodText, 'Kartu Debit/Kredit');
    });

    test('statusText should return correct text', () {
      final transactionPending = Transaction(
        id: 'T001',
        vehicleId: 'V001',
        customerName: 'Test',
        services: [ServiceItem(name: 'Service', price: 50000, quantity: 1)],
        totalAmount: 50000,
        paymentMethod: PaymentMethod.cash,
        status: TransactionStatus.pending,
        createdAt: DateTime(2024, 1, 1),
      );

      final transactionPaid = Transaction(
        id: 'T002',
        vehicleId: 'V002',
        customerName: 'Test',
        services: [ServiceItem(name: 'Service', price: 50000, quantity: 1)],
        totalAmount: 50000,
        paymentMethod: PaymentMethod.cash,
        status: TransactionStatus.paid,
        createdAt: DateTime(2024, 1, 1),
      );

      final transactionCancelled = Transaction(
        id: 'T003',
        vehicleId: 'V003',
        customerName: 'Test',
        services: [ServiceItem(name: 'Service', price: 50000, quantity: 1)],
        totalAmount: 50000,
        paymentMethod: PaymentMethod.cash,
        status: TransactionStatus.cancelled,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(transactionPending.statusText, 'Pending');
      expect(transactionPaid.statusText, 'Lunas');
      expect(transactionCancelled.statusText, 'Dibatalkan');
    });

    test('statusColor should return correct color', () {
      final transactionPending = Transaction(
        id: 'T001',
        vehicleId: 'V001',
        customerName: 'Test',
        services: [ServiceItem(name: 'Service', price: 50000, quantity: 1)],
        totalAmount: 50000,
        paymentMethod: PaymentMethod.cash,
        status: TransactionStatus.pending,
        createdAt: DateTime(2024, 1, 1),
      );

      final transactionPaid = Transaction(
        id: 'T002',
        vehicleId: 'V002',
        customerName: 'Test',
        services: [ServiceItem(name: 'Service', price: 50000, quantity: 1)],
        totalAmount: 50000,
        paymentMethod: PaymentMethod.cash,
        status: TransactionStatus.paid,
        createdAt: DateTime(2024, 1, 1),
      );

      final transactionCancelled = Transaction(
        id: 'T003',
        vehicleId: 'V003',
        customerName: 'Test',
        services: [ServiceItem(name: 'Service', price: 50000, quantity: 1)],
        totalAmount: 50000,
        paymentMethod: PaymentMethod.cash,
        status: TransactionStatus.cancelled,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(transactionPending.statusColor, const Color(0xFFFF9500));
      expect(transactionPaid.statusColor, const Color(0xFF34C759));
      expect(transactionCancelled.statusColor, const Color(0xFFFF3B30));
    });
  });

  group('ServiceItem Model Tests', () {
    test('should create ServiceItem instance correctly', () {
      final serviceItem = ServiceItem(
        name: 'Oil Change',
        price: 75000,
        quantity: 1,
      );

      expect(serviceItem.name, 'Oil Change');
      expect(serviceItem.price, 75000);
      expect(serviceItem.quantity, 1);
    });

    test('should calculate total price correctly', () {
      final serviceItem = ServiceItem(
        name: 'Tire Replacement',
        price: 250000,
        quantity: 4,
      );

      expect(serviceItem.totalPrice, 1000000); // 250000 * 4
    });

    test('should handle decimal prices correctly', () {
      final serviceItem = ServiceItem(
        name: 'Service Detail',
        price: 125.50,
        quantity: 2,
      );

      expect(serviceItem.totalPrice, 251.0); // 125.50 * 2
    });
  });

  group('Enum Extension Tests', () {
    test('PaymentMethod enum should have correct values', () {
      const methods = PaymentMethod.values;
      expect(methods.length, 3);
      expect(methods.contains(PaymentMethod.cash), true);
      expect(methods.contains(PaymentMethod.transfer), true);
      expect(methods.contains(PaymentMethod.card), true);
    });

    test('TransactionStatus enum should have correct values', () {
      const statuses = TransactionStatus.values;
      expect(statuses.length, 3);
      expect(statuses.contains(TransactionStatus.pending), true);
      expect(statuses.contains(TransactionStatus.paid), true);
      expect(statuses.contains(TransactionStatus.cancelled), true);
    });
  });
}
