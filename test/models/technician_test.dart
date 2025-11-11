import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_manager/models/technician.dart';

void main() {
  group('Technician Model Tests', () {
    test('should create Technician with all required fields', () {
      final technician = Technician(
        id: 'TECH001',
        name: 'Budi Santoso',
        phone: '081234567890',
        email: 'budi@workshop.com',
        specialization: 'Mesin & Transmisi',
        experienceYears: 5,
        status: TechnicianStatus.active,
        createdAt: DateTime.now(),
        rating: 4.5,
        totalServices: 10,
        salaryType: SalaryType.daily,
        salaryAmount: 150000,
      );

      expect(technician.id, 'TECH001');
      expect(technician.name, 'Budi Santoso');
      expect(technician.phone, '081234567890');
      expect(technician.email, 'budi@workshop.com');
      expect(technician.specialization, 'Mesin & Transmisi');
      expect(technician.experienceYears, 5);
      expect(technician.status, TechnicianStatus.active);
      expect(technician.rating, 4.5);
      expect(technician.totalServices, 10);
      expect(technician.salaryType, SalaryType.daily);
      expect(technician.salaryAmount, 150000);
    });

    test('should create Technician with minimal required fields', () {
      final now = DateTime.now();
      final technician = Technician(
        id: 'TECH002',
        name: 'Ahmad Wijaya',
        phone: '082345678901',
        specialization: 'Kelistrikan',
        experienceYears: 3,
        status: TechnicianStatus.active,
        createdAt: now,
      );

      expect(technician.id, 'TECH002');
      expect(technician.name, 'Ahmad Wijaya');
      expect(technician.phone, '082345678901');
      expect(technician.specialization, 'Kelistrikan');
      expect(technician.experienceYears, 3);
      expect(technician.status, TechnicianStatus.active);
      expect(technician.createdAt, now);
      expect(technician.email, isNull);
      expect(technician.rating, 0.0);
      expect(technician.totalServices, 0);
      expect(technician.salaryType, isNull);
      expect(technician.salaryAmount, isNull);
      expect(technician.lastActive, isNull);
    });

    test('should handle different technician statuses', () {
      final activeTech = Technician(
        id: 'TECH001',
        name: 'Active Tech',
        phone: '081111111111',
        specialization: 'General',
        experienceYears: 2,
        status: TechnicianStatus.active,
        createdAt: DateTime.now(),
      );

      final inactiveTech = Technician(
        id: 'TECH002',
        name: 'Inactive Tech',
        phone: '082222222222',
        specialization: 'General',
        experienceYears: 2,
        status: TechnicianStatus.inactive,
        createdAt: DateTime.now(),
      );

      final onLeaveTech = Technician(
        id: 'TECH003',
        name: 'On Leave Tech',
        phone: '083333333333',
        specialization: 'General',
        experienceYears: 2,
        status: TechnicianStatus.onLeave,
        createdAt: DateTime.now(),
      );

      expect(activeTech.status, TechnicianStatus.active);
      expect(inactiveTech.status, TechnicianStatus.inactive);
      expect(onLeaveTech.status, TechnicianStatus.onLeave);
    });

    test('should handle different salary types', () {
      final dailyTech = Technician(
        id: 'TECH001',
        name: 'Daily Tech',
        phone: '081111111111',
        specialization: 'General',
        experienceYears: 2,
        status: TechnicianStatus.active,
        createdAt: DateTime.now(),
        salaryType: SalaryType.daily,
        salaryAmount: 150000,
      );

      final monthlyTech = Technician(
        id: 'TECH002',
        name: 'Monthly Tech',
        phone: '082222222222',
        specialization: 'General',
        experienceYears: 2,
        status: TechnicianStatus.active,
        createdAt: DateTime.now(),
        salaryType: SalaryType.monthly,
        salaryAmount: 4000000,
      );

      final commissionTech = Technician(
        id: 'TECH003',
        name: 'Commission Tech',
        phone: '083333333333',
        specialization: 'General',
        experienceYears: 2,
        status: TechnicianStatus.active,
        createdAt: DateTime.now(),
        salaryType: SalaryType.commission,
        salaryAmount: 0,
      );

      expect(dailyTech.salaryType, SalaryType.daily);
      expect(dailyTech.salaryAmount, 150000);
      expect(monthlyTech.salaryType, SalaryType.monthly);
      expect(monthlyTech.salaryAmount, 4000000);
      expect(commissionTech.salaryType, SalaryType.commission);
      expect(commissionTech.salaryAmount, 0);
    });
  });
}
