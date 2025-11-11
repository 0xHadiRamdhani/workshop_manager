import 'package:flutter/material.dart';

enum TechnicianStatus { active, inactive, onLeave }

enum SalaryType { daily, monthly, commission }

class Technician {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String specialization;
  final int experienceYears;
  final TechnicianStatus status;
  final DateTime createdAt;
  final DateTime? lastActive;
  final double rating;
  final int totalServices;
  final SalaryType? salaryType;
  final double? salaryAmount;

  Technician({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.specialization,
    required this.experienceYears,
    required this.status,
    required this.createdAt,
    this.lastActive,
    this.rating = 0.0,
    this.totalServices = 0,
    this.salaryType,
    this.salaryAmount,
  });

  Technician copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? specialization,
    int? experienceYears,
    TechnicianStatus? status,
    DateTime? createdAt,
    DateTime? lastActive,
    double? rating,
    int? totalServices,
    SalaryType? salaryType,
    double? salaryAmount,
  }) {
    return Technician(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      specialization: specialization ?? this.specialization,
      experienceYears: experienceYears ?? this.experienceYears,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      rating: rating ?? this.rating,
      totalServices: totalServices ?? this.totalServices,
      salaryType: salaryType ?? this.salaryType,
      salaryAmount: salaryAmount ?? this.salaryAmount,
    );
  }

  String get statusText {
    switch (status) {
      case TechnicianStatus.active:
        return 'Aktif';
      case TechnicianStatus.inactive:
        return 'Tidak Aktif';
      case TechnicianStatus.onLeave:
        return 'Cuti';
    }
  }

  Color get statusColor {
    switch (status) {
      case TechnicianStatus.active:
        return const Color(0xFF34C759);
      case TechnicianStatus.inactive:
        return const Color(0xFF8E8E93);
      case TechnicianStatus.onLeave:
        return const Color(0xFFFF9500);
    }
  }

  String get salaryTypeText {
    switch (salaryType) {
      case SalaryType.daily:
        return 'Harian';
      case SalaryType.monthly:
        return 'Bulanan';
      case SalaryType.commission:
        return 'Komisi';
      case null:
        return 'Belum ditentukan';
    }
  }
}
