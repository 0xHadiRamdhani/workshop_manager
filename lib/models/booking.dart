import 'package:flutter/material.dart';

enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

class Booking {
  final String id;
  final String customerName;
  final String phoneNumber;
  final String? email;
  final String vehicleType;
  final String? licensePlate;
  final String serviceType;
  final DateTime preferredDate;
  final String preferredTime;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final String? technicianId;
  final int? estimatedDuration;
  final String? notes;
  final bool reminderSent;

  Booking({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    this.email,
    required this.vehicleType,
    this.licensePlate,
    required this.serviceType,
    required this.preferredDate,
    required this.preferredTime,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.completedAt,
    this.technicianId,
    this.estimatedDuration,
    this.notes,
    this.reminderSent = false,
  });

  Booking copyWith({
    String? id,
    String? customerName,
    String? phoneNumber,
    String? email,
    String? vehicleType,
    String? licensePlate,
    String? serviceType,
    DateTime? preferredDate,
    String? preferredTime,
    BookingStatus? status,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? completedAt,
    String? technicianId,
    int? estimatedDuration,
    String? notes,
    bool? reminderSent,
  }) {
    return Booking(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      vehicleType: vehicleType ?? this.vehicleType,
      licensePlate: licensePlate ?? this.licensePlate,
      serviceType: serviceType ?? this.serviceType,
      preferredDate: preferredDate ?? this.preferredDate,
      preferredTime: preferredTime ?? this.preferredTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      completedAt: completedAt ?? this.completedAt,
      technicianId: technicianId ?? this.technicianId,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      notes: notes ?? this.notes,
      reminderSent: reminderSent ?? this.reminderSent,
    );
  }

  String get statusText {
    switch (status) {
      case BookingStatus.pending:
        return 'Menunggu';
      case BookingStatus.confirmed:
        return 'Dikonfirmasi';
      case BookingStatus.inProgress:
        return 'Dalam Proses';
      case BookingStatus.completed:
        return 'Selesai';
      case BookingStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Color get statusColor {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFFF9500);
      case BookingStatus.confirmed:
        return const Color(0xFF007AFF);
      case BookingStatus.inProgress:
        return const Color(0xFF5856D6);
      case BookingStatus.completed:
        return const Color(0xFF34C759);
      case BookingStatus.cancelled:
        return const Color(0xFFFF3B30);
    }
  }

  String get formattedDate {
    return '${preferredDate.day}/${preferredDate.month}/${preferredDate.year}';
  }

  String get formattedTime {
    return preferredTime;
  }

  bool get isOverdue {
    return preferredDate.isBefore(DateTime.now()) &&
        status == BookingStatus.pending;
  }
}
