import 'package:flutter/material.dart';

enum VehicleStatus { waiting, inProgress, completed, delivered }

class Vehicle {
  final String id;
  final String customerName;
  final String vehicleType;
  final String licensePlate;
  final String phoneNumber;
  final String problemDescription;
  final VehicleStatus status;
  final DateTime createdAt;
  final DateTime? estimatedCompletion;
  final double? estimatedCost;

  Vehicle({
    required this.id,
    required this.customerName,
    required this.vehicleType,
    required this.licensePlate,
    required this.phoneNumber,
    required this.problemDescription,
    required this.status,
    required this.createdAt,
    this.estimatedCompletion,
    this.estimatedCost,
  });

  Vehicle copyWith({
    String? id,
    String? customerName,
    String? vehicleType,
    String? licensePlate,
    String? phoneNumber,
    String? problemDescription,
    VehicleStatus? status,
    DateTime? createdAt,
    DateTime? estimatedCompletion,
    double? estimatedCost,
  }) {
    return Vehicle(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      vehicleType: vehicleType ?? this.vehicleType,
      licensePlate: licensePlate ?? this.licensePlate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      problemDescription: problemDescription ?? this.problemDescription,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
      estimatedCost: estimatedCost ?? this.estimatedCost,
    );
  }

  String get statusText {
    switch (status) {
      case VehicleStatus.waiting:
        return 'Menunggu';
      case VehicleStatus.inProgress:
        return 'Dalam Proses';
      case VehicleStatus.completed:
        return 'Selesai';
      case VehicleStatus.delivered:
        return 'Diserahkan';
    }
  }

  Color get statusColor {
    switch (status) {
      case VehicleStatus.waiting:
        return const Color(0xFFFF9500);
      case VehicleStatus.inProgress:
        return const Color(0xFF007AFF);
      case VehicleStatus.completed:
        return const Color(0xFF34C759);
      case VehicleStatus.delivered:
        return const Color(0xFF5856D6);
    }
  }
}
