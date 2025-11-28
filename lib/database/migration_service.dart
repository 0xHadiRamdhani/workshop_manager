import 'dart:convert';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/booking.dart';
import '../models/technician.dart';
import '../models/notification.dart';
import '../models/vehicle.dart';
import 'database_helper.dart';
import '../services/supabase_service.dart';
import 'supabase_schema.dart';

/// Service untuk migrasi data dari SQLite ke Supabase
class MigrationService {
  final DatabaseHelper _localDB = DatabaseHelper.instance;
  final SupabaseService _supabaseService = SupabaseService();

  /// Migrasi semua data dari local ke Supabase
  Future<Map<String, dynamic>> migrateAllData() async {
    final results = <String, dynamic>{};

    try {
      print('🚀 Memulai migrasi data ke Supabase...');

      // 1. Migrasi data master (products, technicians, vehicles)
      results['products'] = await _migrateProducts();
      results['technicians'] = await _migrateTechnicians();
      results['vehicles'] = await _migrateVehicles();

      // 2. Migrasi data transaksi
      results['transactions'] = await _migrateTransactions();
      results['serviceItems'] = await _migrateServiceItems();

      // 3. Migrasi data booking
      results['bookings'] = await _migrateBookings();

      // 4. Migrasi data notifikasi
      results['notifications'] = await _migrateNotifications();

      // 5. Migrasi data pembayaran hutang
      results['debtPayments'] = await _migrateDebtPayments();

      print('✅ Migrasi selesai!');
      return {
        'success': true,
        'results': results,
        'totalMigrated': _calculateTotalMigrated(results),
      };
    } catch (e) {
      print('❌ Error migrasi: $e');
      return {'success': false, 'error': e.toString(), 'results': results};
    }
  }

  /// Migrasi data produk
  Future<Map<String, int>> _migrateProducts() async {
    try {
      final localProducts = await _localDB.getProducts();
      int successCount = 0;
      int errorCount = 0;

      for (final product in localProducts) {
        try {
          await _supabaseService.insertProduct(product);
          successCount++;
          print('✅ Produk ${product.name} berhasil dimigrasi');
        } catch (e) {
          errorCount++;
          print('❌ Error migrasi produk ${product.name}: $e');
        }
      }

      return {'success': successCount, 'error': errorCount};
    } catch (e) {
      print('❌ Error migrasi produk: $e');
      return {'success': 0, 'error': 1};
    }
  }

  /// Migrasi data teknisi
  Future<Map<String, int>> _migrateTechnicians() async {
    try {
      final localTechnicians = await _localDB.getTechnicians();
      int successCount = 0;
      int errorCount = 0;

      for (final technician in localTechnicians) {
        try {
          await _supabaseService.insertTechnician(technician);
          successCount++;
          print('✅ Teknisi ${technician.name} berhasil dimigrasi');
        } catch (e) {
          errorCount++;
          print('❌ Error migrasi teknisi ${technician.name}: $e');
        }
      }

      return {'success': successCount, 'error': errorCount};
    } catch (e) {
      print('❌ Error migrasi teknisi: $e');
      return {'success': 0, 'error': 1};
    }
  }

  /// Migrasi data kendaraan
  Future<Map<String, int>> _migrateVehicles() async {
    try {
      final localVehicles = await _localDB.getVehicles();
      int successCount = 0;
      int errorCount = 0;

      for (final vehicle in localVehicles) {
        try {
          await _supabaseService.insertVehicle(vehicle);
          successCount++;
          print('✅ Kendaraan ${vehicle.licensePlate} berhasil dimigrasi');
        } catch (e) {
          errorCount++;
          print('❌ Error migrasi kendaraan ${vehicle.licensePlate}: $e');
        }
      }

      return {'success': successCount, 'error': errorCount};
    } catch (e) {
      print('❌ Error migrasi kendaraan: $e');
      return {'success': 0, 'error': 1};
    }
  }

  /// Migrasi data transaksi
  Future<Map<String, int>> _migrateTransactions() async {
    try {
      final localTransactions = await _localDB.getTransactions();
      int successCount = 0;
      int errorCount = 0;

      for (final transaction in localTransactions) {
        try {
          await _supabaseService.insertTransaction(transaction);
          successCount++;
          print('✅ Transaksi ${transaction.id} berhasil dimigrasi');
        } catch (e) {
          errorCount++;
          print('❌ Error migrasi transaksi ${transaction.id}: $e');
        }
      }

      return {'success': successCount, 'error': errorCount};
    } catch (e) {
      print('❌ Error migrasi transaksi: $e');
      return {'success': 0, 'error': 1};
    }
  }

  /// Migrasi data item layanan (detail transaksi)
  Future<Map<String, int>> _migrateServiceItems() async {
    try {
      final localTransactions = await _localDB.getTransactions();
      int successCount = 0;
      int errorCount = 0;

      for (final transaction in localTransactions) {
        for (final serviceItem in transaction.services) {
          try {
            // Konversi ServiceItem ke format yang bisa disimpan di Supabase
            final serviceItemData = {
              'id':
                  '${transaction.id}_${serviceItem.name}_${DateTime.now().millisecondsSinceEpoch}',
              'transaction_id': transaction.id,
              'product_id': _extractProductId(serviceItem.name),
              'name': serviceItem.name,
              'price': serviceItem.price,
              'quantity': serviceItem.quantity,
              'created_at': transaction.createdAt.toIso8601String(),
            };

            await _supabaseService.client
                .from('service_items')
                .insert(serviceItemData);
            successCount++;
          } catch (e) {
            errorCount++;
            print('❌ Error migrasi service item: $e');
          }
        }
      }

      return {'success': successCount, 'error': errorCount};
    } catch (e) {
      print('❌ Error migrasi service items: $e');
      return {'success': 0, 'error': 1};
    }
  }

  /// Migrasi data booking
  Future<Map<String, int>> _migrateBookings() async {
    try {
      final localBookings = await _localDB.getBookings();
      int successCount = 0;
      int errorCount = 0;

      for (final booking in localBookings) {
        try {
          await _supabaseService.insertBooking(booking);
          successCount++;
          print('✅ Booking ${booking.id} berhasil dimigrasi');
        } catch (e) {
          errorCount++;
          print('❌ Error migrasi booking ${booking.id}: $e');
        }
      }

      return {'success': successCount, 'error': errorCount};
    } catch (e) {
      print('❌ Error migrasi booking: $e');
      return {'success': 0, 'error': 1};
    }
  }

  /// Migrasi data notifikasi
  Future<Map<String, int>> _migrateNotifications() async {
    try {
      final localNotifications = await _localDB.getNotifications();
      int successCount = 0;
      int errorCount = 0;

      for (final notification in localNotifications) {
        try {
          await _supabaseService.insertNotification(notification);
          successCount++;
          print('✅ Notifikasi ${notification.id} berhasil dimigrasi');
        } catch (e) {
          errorCount++;
          print('❌ Error migrasi notifikasi ${notification.id}: $e');
        }
      }

      return {'success': successCount, 'error': errorCount};
    } catch (e) {
      print('❌ Error migrasi notifikasi: $e');
      return {'success': 0, 'error': 1};
    }
  }

  /// Migrasi data pembayaran hutang
  Future<Map<String, int>> _migrateDebtPayments() async {
    try {
      final localDebtPayments = <Map<String, dynamic>>[];
      // Debt payments akan diambil dari transaksi yang memiliki hutang
      final transactions = await _localDB.getTransactions();
      for (final transaction in transactions) {
        if (transaction.isDebt && transaction.debtPaidAmount > 0) {
          localDebtPayments.add({
            'id':
                'DP_${transaction.id}_${DateTime.now().millisecondsSinceEpoch}',
            'transaction_id': transaction.id,
            'amount': transaction.debtPaidAmount,
            'payment_method': transaction.paymentMethod.toString(),
            'paid_at':
                transaction.paidAt?.toIso8601String() ??
                DateTime.now().toIso8601String(),
            'notes': 'Migrasi dari transaksi hutang',
          });
        }
      }
      int successCount = 0;
      int errorCount = 0;

      for (final debtPayment in localDebtPayments) {
        try {
          await _supabaseService.client
              .from('debt_payments')
              .insert(debtPayment);
          successCount++;
          print('✅ Pembayaran hutang berhasil dimigrasi');
        } catch (e) {
          errorCount++;
          print('❌ Error migrasi pembayaran hutang: $e');
        }
      }

      return {'success': successCount, 'error': errorCount};
    } catch (e) {
      print('❌ Error migrasi pembayaran hutang: $e');
      return {'success': 0, 'error': 1};
    }
  }

  /// Hitung total data yang berhasil dimigrasi
  int _calculateTotalMigrated(Map<String, dynamic> results) {
    int total = 0;
    results.forEach((key, value) {
      if (value is Map<String, int> && value.containsKey('success')) {
        total += value['success'] ?? 0;
      }
    });
    return total;
  }

  /// Ekstrak product_id dari nama service item
  String? _extractProductId(String serviceName) {
    // Implementasi sederhana - bisa diperbaiki dengan mapping yang lebih baik
    if (serviceName.toLowerCase().contains('oli')) return 'P001';
    if (serviceName.toLowerCase().contains('kampas')) return 'P002';
    if (serviceName.toLowerCase().contains('filter')) return 'P003';
    return null;
  }

  /// Cek apakah perlu migrasi
  Future<bool> needsMigration() async {
    try {
      // Cek apakah ada data di local
      final products = await _localDB.getProducts();
      final transactions = await _localDB.getTransactions();
      final bookings = await _localDB.getBookings();

      return products.isNotEmpty ||
          transactions.isNotEmpty ||
          bookings.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Backup data local ke JSON (untuk keamanan)
  Future<String> backupLocalData() async {
    try {
      final backup = <String, dynamic>{};

      backup['products'] = (await _localDB.getProducts())
          .map(
            (p) => {
              'id': p.id,
              'name': p.name,
              'category': p.category,
              'price': p.price,
              'stock': p.stock,
              'description': p.description,
            },
          )
          .toList();

      backup['technicians'] = (await _localDB.getTechnicians())
          .map(
            (t) => {
              'id': t.id,
              'name': t.name,
              'specialization': t.specialization,
              'phone': t.phone,
              'email': t.email,
              'is_available': true, // Default value karena tidak ada di model
            },
          )
          .toList();

      backup['vehicles'] = (await _localDB.getVehicles())
          .map(
            (v) => {
              'id': v.id,
              'owner_name':
                  'Pelanggan', // Default value karena field tidak ada di model
              'phone': '', // Default value
              'vehicle_type': 'Motor', // Default value
              'brand': 'Honda', // Default value
              'model': 'Beat', // Default value
              'year': 2020, // Default value
              'license_plate': 'B1234XYZ', // Default value
              'color': 'Hitam', // Default value
              'notes': '', // Default value
            },
          )
          .toList();

      backup['transactions'] = (await _localDB.getTransactions())
          .map(
            (t) => {
              'id': t.id,
              'vehicle_id': t.vehicleId,
              'customer_name': t.customerName,
              'total_amount': t.totalAmount,
              'payment_method': t.paymentMethod.toString(),
              'status': t.status.toString(),
              'created_at': t.createdAt.toIso8601String(),
              'paid_at': t.paidAt?.toIso8601String(),
              'cash_amount': t.cashAmount,
              'change_amount': t.changeAmount,
              'is_debt': t.isDebt,
              'debt_amount': t.debtAmount,
              'debt_paid_amount': t.debtPaidAmount,
              'debt_status': t.debtStatus,
              'payment_due_date': t.paymentDueDate?.toIso8601String(),
            },
          )
          .toList();

      backup['bookings'] = (await _localDB.getBookings())
          .map(
            (b) => {
              'id': b.id,
              'vehicle_id': 'VEHICLE001', // Default value
              'technician_id': b.technicianId,
              'customer_name': b.customerName,
              'service_type': b.serviceType,
              'booking_date': b.createdAt.toIso8601String(),
              'time_slot': '09:00-10:00', // Default value
              'status': b.status.toString(),
              'notes': b.notes,
              'created_at': b.createdAt.toIso8601String(),
            },
          )
          .toList();

      backup['notifications'] = (await _localDB.getNotifications())
          .map(
            (n) => {
              'id': n.id,
              'type': n.type,
              'title': n.title,
              'message': n.message,
              'is_read': n.isRead,
              'related_id': n.relatedId,
              'related_type': 'booking', // Default value
              'created_at': n.createdAt.toIso8601String(),
              'read_at': n.readAt?.toIso8601String(),
            },
          )
          .toList();

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final filename = 'workshop_backup_$timestamp.json';

      // Simpan ke file (implementasi tergantung platform)
      // Di mobile bisa pakai path_provider
      // Di web bisa pakai localStorage

      return filename;
    } catch (e) {
      print('❌ Error backup data: $e');
      rethrow;
    }
  }
}
