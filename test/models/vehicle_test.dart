import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:workshop_manager/models/vehicle.dart';
import 'package:workshop_manager/models/transaction.dart';

void main() {
  group('Vehicle Model Tests', () {
    test('should create Vehicle instance correctly', () {
      final vehicle = Vehicle(
        id: 'V001',
        customerName: 'John Doe',
        vehicleType: 'Honda Beat',
        licensePlate: 'B 1234 ABC',
        phoneNumber: '081234567890',
        problemDescription: 'Motor tidak bisa starter',
        status: VehicleStatus.waiting,
        createdAt: DateTime(2024, 1, 1),
        estimatedCompletion: DateTime(2024, 1, 3),
        estimatedCost: 150000,
        paymentMethod: PaymentMethod.cash,
        actualCost: 175000,
        isPaid: true,
      );

      expect(vehicle.id, 'V001');
      expect(vehicle.customerName, 'John Doe');
      expect(vehicle.vehicleType, 'Honda Beat');
      expect(vehicle.licensePlate, 'B 1234 ABC');
      expect(vehicle.phoneNumber, '081234567890');
      expect(vehicle.problemDescription, 'Motor tidak bisa starter');
      expect(vehicle.status, VehicleStatus.waiting);
      expect(vehicle.createdAt, DateTime(2024, 1, 1));
      expect(vehicle.estimatedCompletion, DateTime(2024, 1, 3));
      expect(vehicle.estimatedCost, 150000);
      expect(vehicle.paymentMethod, PaymentMethod.cash);
      expect(vehicle.actualCost, 175000);
      expect(vehicle.isPaid, true);
    });

    test('should create Vehicle with minimal required fields', () {
      final vehicle = Vehicle(
        id: 'V002',
        customerName: 'Jane Smith',
        vehicleType: 'Yamaha Mio',
        licensePlate: 'B 5678 DEF',
        phoneNumber: '089876543210',
        problemDescription: 'Ganti oli',
        status: VehicleStatus.inProgress,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(vehicle.estimatedCompletion, isNull);
      expect(vehicle.estimatedCost, isNull);
      expect(vehicle.paymentMethod, isNull);
      expect(vehicle.actualCost, isNull);
      expect(vehicle.isPaid, false);
    });

    test('copyWith should create new instance with updated values', () {
      final originalVehicle = Vehicle(
        id: 'V001',
        customerName: 'John Doe',
        vehicleType: 'Honda Beat',
        licensePlate: 'B 1234 ABC',
        phoneNumber: '081234567890',
        problemDescription: 'Motor tidak bisa starter',
        status: VehicleStatus.waiting,
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedVehicle = originalVehicle.copyWith(
        status: VehicleStatus.completed,
        actualCost: 175000,
        isPaid: true,
      );

      expect(updatedVehicle.id, 'V001'); // Unchanged
      expect(updatedVehicle.customerName, 'John Doe'); // Unchanged
      expect(updatedVehicle.status, VehicleStatus.completed); // Updated
      expect(updatedVehicle.actualCost, 175000); // Updated
      expect(updatedVehicle.isPaid, true); // Updated
      expect(updatedVehicle.createdAt, DateTime(2024, 1, 1)); // Unchanged
    });

    test('copyWith should not modify original vehicle', () {
      final originalVehicle = Vehicle(
        id: 'V001',
        customerName: 'John Doe',
        vehicleType: 'Honda Beat',
        licensePlate: 'B 1234 ABC',
        phoneNumber: '081234567890',
        problemDescription: 'Motor tidak bisa starter',
        status: VehicleStatus.waiting,
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedVehicle = originalVehicle.copyWith(
        status: VehicleStatus.completed,
      );

      expect(originalVehicle.status, VehicleStatus.waiting);
      expect(updatedVehicle.status, VehicleStatus.completed);
    });

    test('statusText should return correct text for all statuses', () {
      final waitingVehicle = Vehicle(
        id: 'V001',
        customerName: 'Test',
        vehicleType: 'Motor',
        licensePlate: 'B 1234',
        phoneNumber: '081234567890',
        problemDescription: 'Test',
        status: VehicleStatus.waiting,
        createdAt: DateTime(2024, 1, 1),
      );

      final inProgressVehicle = waitingVehicle.copyWith(
        status: VehicleStatus.inProgress,
      );
      final completedVehicle = waitingVehicle.copyWith(
        status: VehicleStatus.completed,
      );
      final deliveredVehicle = waitingVehicle.copyWith(
        status: VehicleStatus.delivered,
      );

      expect(waitingVehicle.statusText, 'Menunggu');
      expect(inProgressVehicle.statusText, 'Dalam Proses');
      expect(completedVehicle.statusText, 'Selesai');
      expect(deliveredVehicle.statusText, 'Diserahkan');
    });

    test('statusColor should return correct color for all statuses', () {
      final waitingVehicle = Vehicle(
        id: 'V001',
        customerName: 'Test',
        vehicleType: 'Motor',
        licensePlate: 'B 1234',
        phoneNumber: '081234567890',
        problemDescription: 'Test',
        status: VehicleStatus.waiting,
        createdAt: DateTime(2024, 1, 1),
      );

      final inProgressVehicle = waitingVehicle.copyWith(
        status: VehicleStatus.inProgress,
      );
      final completedVehicle = waitingVehicle.copyWith(
        status: VehicleStatus.completed,
      );
      final deliveredVehicle = waitingVehicle.copyWith(
        status: VehicleStatus.delivered,
      );

      expect(waitingVehicle.statusColor, const Color(0xFFFF9500));
      expect(inProgressVehicle.statusColor, const Color(0xFF007AFF));
      expect(completedVehicle.statusColor, const Color(0xFF34C759));
      expect(deliveredVehicle.statusColor, const Color(0xFF5856D6));
    });
  });

  group('VehicleStatus Enum Tests', () {
    test('VehicleStatus enum should have correct values', () {
      const statuses = VehicleStatus.values;
      expect(statuses.length, 4);
      expect(statuses.contains(VehicleStatus.waiting), true);
      expect(statuses.contains(VehicleStatus.inProgress), true);
      expect(statuses.contains(VehicleStatus.completed), true);
      expect(statuses.contains(VehicleStatus.delivered), true);
    });
  });
}
