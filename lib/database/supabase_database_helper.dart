import 'dart:async';
import 'package:workshop_manager/database/database_helper.dart';
import 'package:workshop_manager/services/supabase_service.dart';
import '../models/product.dart';
import '../models/vehicle.dart';
import '../models/technician.dart';
import '../models/booking.dart';
import '../models/transaction.dart' as app_transaction;
import '../models/notification.dart' as app_notification;

/// Database helper yang menggabungkan SQLite lokal dan Supabase
/// Untuk migrasi dari lokal ke cloud secara bertahap
class SupabaseDatabaseHelper {
  static final SupabaseDatabaseHelper _instance =
      SupabaseDatabaseHelper._internal();
  factory SupabaseDatabaseHelper() => _instance;
  SupabaseDatabaseHelper._internal();

  final DatabaseHelper _localDB = DatabaseHelper.instance;
  final SupabaseService _supabaseService = SupabaseService();

  // Mode operasi: 'local', 'supabase', 'hybrid'
  String _mode =
      'local'; // Default ke local untuk menghindari error saat startup

  // Sinkronisasi otomatis
  Timer? _syncTimer;

  // Getter untuk mode
  String get mode => _mode;

  // Setter untuk mode
  set mode(String value) {
    if (['local', 'supabase', 'hybrid'].contains(value)) {
      String oldMode = _mode;
      _mode = value;

      print('Database mode changed from $oldMode to $_mode');

      if (value == 'hybrid') {
        _startAutoSync();
      } else {
        _stopAutoSync();
      }
    } else {
      print('Invalid database mode: $value. Using default: $_mode');
    }
  }

  /// Inisialisasi database helper
  Future<void> initialize() async {
    try {
      // Inisialisasi database lokal
      await _localDB.database;
      print('SupabaseDatabaseHelper: Local database initialized successfully');

      // Mulai sinkronisasi otomatis jika mode hybrid
      if (_mode == 'hybrid') {
        _startAutoSync();
        print('SupabaseDatabaseHelper: Auto sync started for hybrid mode');
      }
    } catch (e) {
      print('Error initializing SupabaseDatabaseHelper: $e');
      // Tetap lanjutkan meskipun ada error, fallback ke mode local
      _mode = 'local';
    }
  }

  /// Mulai sinkronisasi otomatis setiap 5 menit
  void _startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncLocalToSupabase();
    });
  }

  /// Hentikan sinkronisasi otomatis
  void _stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Sinkronisasi data dari lokal ke Supabase
  Future<void> syncLocalToSupabase() async {
    try {
      print('Starting sync from local to Supabase...');

      // Sinkronisasi products
      await _syncProducts();

      // Sinkronisasi vehicles
      await _syncVehicles();

      // Sinkronisasi technicians
      await _syncTechnicians();

      // Sinkronisasi bookings
      await _syncBookings();

      // Sinkronisasi transactions
      await _syncTransactions();

      // Sinkronisasi notifications
      await _syncNotifications();

      print('Sync completed successfully');
    } catch (e) {
      print('Error during sync: $e');
    }
  }

  /// Sinkronisasi products
  Future<void> _syncProducts() async {
    try {
      final localProducts = await _localDB.getProducts();

      for (final product in localProducts) {
        // Cek apakah product sudah ada di Supabase
        final existingProduct = await _supabaseService.getProductById(
          product.id,
        );

        if (existingProduct == null) {
          // Insert ke Supabase jika belum ada
          await _supabaseService.insertProduct(product);
          print('Synced product: ${product.name}');
        }
      }
    } catch (e) {
      print('Error syncing products: $e');
    }
  }

  /// Sinkronisasi vehicles
  Future<void> _syncVehicles() async {
    try {
      final localVehicles = await _localDB.getVehicles();

      for (final vehicle in localVehicles) {
        // Cek apakah vehicle sudah ada di Supabase
        final existingVehicle = await _supabaseService.getVehicleById(
          vehicle.id,
        );

        if (existingVehicle == null) {
          // Insert ke Supabase jika belum ada
          await _supabaseService.insertVehicle(vehicle);
          print('Synced vehicle: ${vehicle.licensePlate}');
        }
      }
    } catch (e) {
      print('Error syncing vehicles: $e');
    }
  }

  /// Sinkronisasi technicians
  Future<void> _syncTechnicians() async {
    try {
      final localTechnicians = await _localDB.getTechnicians();

      for (final technician in localTechnicians) {
        // Cek apakah technician sudah ada di Supabase
        final existingTechnician = await _supabaseService.getTechnicianById(
          technician.id,
        );

        if (existingTechnician == null) {
          // Insert ke Supabase jika belum ada
          await _supabaseService.insertTechnician(technician);
          print('Synced technician: ${technician.name}');
        }
      }
    } catch (e) {
      print('Error syncing technicians: $e');
    }
  }

  /// Sinkronisasi bookings
  Future<void> _syncBookings() async {
    try {
      final localBookings = await _localDB.getBookings();

      for (final booking in localBookings) {
        // Cek apakah booking sudah ada di Supabase
        final existingBooking = await _supabaseService.getBookingById(
          booking.id,
        );

        if (existingBooking == null) {
          // Insert ke Supabase jika belum ada
          await _supabaseService.insertBooking(booking);
          print('Synced booking: ${booking.id}');
        }
      }
    } catch (e) {
      print('Error syncing bookings: $e');
    }
  }

  /// Sinkronisasi transactions
  Future<void> _syncTransactions() async {
    try {
      final localTransactions = await _localDB.getTransactions();

      for (final transaction in localTransactions) {
        // Cek apakah transaction sudah ada di Supabase
        final existingTransaction = await _supabaseService.getTransactionById(
          transaction.id,
        );

        if (existingTransaction == null) {
          // Insert ke Supabase jika belum ada
          await _supabaseService.insertTransaction(transaction);
          print('Synced transaction: ${transaction.id}');
        }
      }
    } catch (e) {
      print('Error syncing transactions: $e');
    }
  }

  /// Sinkronisasi notifications
  Future<void> _syncNotifications() async {
    try {
      final localNotifications = await _localDB.getNotifications();

      for (final notification in localNotifications) {
        // Insert semua notifications ke Supabase (tidak perlu cek duplikasi)
        await _supabaseService.insertNotification(notification);
        print('Synced notification: ${notification.id}');
      }
    } catch (e) {
      print('Error syncing notifications: $e');
    }
  }

  // ==================== PRODUCT OPERATIONS ====================

  Future<List<Product>> getProducts() async {
    try {
      if (_mode == 'supabase') {
        return await _supabaseService.getProducts();
      } else if (_mode == 'local') {
        return await _localDB.getProducts();
      } else {
        // Hybrid mode - prioritaskan Supabase, fallback ke lokal
        try {
          final products = await _supabaseService.getProducts();
          return products.isNotEmpty ? products : await _localDB.getProducts();
        } catch (e) {
          print(
            'Error getting products from Supabase, falling back to local: $e',
          );
          return await _localDB.getProducts();
        }
      }
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  Future<bool> insertProduct(Product product) async {
    try {
      bool success = true;

      if (_mode == 'supabase' || _mode == 'hybrid') {
        success = await _supabaseService.insertProduct(product);
      }

      if (_mode == 'local' || (_mode == 'hybrid' && !success)) {
        await _localDB.insertProduct(product);
      }

      return success;
    } catch (e) {
      print('Error inserting product: $e');
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      bool success = true;

      if (_mode == 'supabase' || _mode == 'hybrid') {
        success = await _supabaseService.updateProduct(product);
      }

      if (_mode == 'local' || (_mode == 'hybrid' && !success)) {
        await _localDB.updateProduct(product);
      }

      return success;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      bool success = true;

      if (_mode == 'supabase' || _mode == 'hybrid') {
        success = await _supabaseService.deleteProduct(id);
      }

      if (_mode == 'local' || (_mode == 'hybrid' && !success)) {
        await _localDB.deleteProduct(id);
      }

      return success;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // ==================== VEHICLE OPERATIONS ====================

  Future<List<Vehicle>> getVehicles() async {
    try {
      if (_mode == 'supabase') {
        return await _supabaseService.getVehicles();
      } else if (_mode == 'local') {
        return await _localDB.getVehicles();
      } else {
        // Hybrid mode - prioritaskan Supabase, fallback ke lokal
        try {
          final vehicles = await _supabaseService.getVehicles();
          return vehicles.isNotEmpty ? vehicles : await _localDB.getVehicles();
        } catch (e) {
          print(
            'Error getting vehicles from Supabase, falling back to local: $e',
          );
          return await _localDB.getVehicles();
        }
      }
    } catch (e) {
      print('Error getting vehicles: $e');
      return [];
    }
  }

  Future<bool> insertVehicle(Vehicle vehicle) async {
    try {
      bool success = true;

      if (_mode == 'supabase' || _mode == 'hybrid') {
        success = await _supabaseService.insertVehicle(vehicle);
      }

      if (_mode == 'local' || (_mode == 'hybrid' && !success)) {
        await _localDB.insertVehicle(vehicle);
      }

      return success;
    } catch (e) {
      print('Error inserting vehicle: $e');
      return false;
    }
  }

  Future<bool> updateVehicle(Vehicle vehicle) async {
    try {
      bool success = true;

      if (_mode == 'supabase' || _mode == 'hybrid') {
        success = await _supabaseService.updateVehicle(vehicle);
      }

      if (_mode == 'local' || (_mode == 'hybrid' && !success)) {
        await _localDB.updateVehicle(vehicle);
      }

      return success;
    } catch (e) {
      print('Error updating vehicle: $e');
      return false;
    }
  }

  Future<bool> deleteVehicle(String id) async {
    try {
      bool success = true;

      if (_mode == 'supabase' || _mode == 'hybrid') {
        success = await _supabaseService.deleteVehicle(id);
      }

      if (_mode == 'local' || (_mode == 'hybrid' && !success)) {
        await _localDB.deleteVehicle(id);
      }

      return success;
    } catch (e) {
      print('Error deleting vehicle: $e');
      return false;
    }
  }

  // ==================== TECHNICIAN OPERATIONS ====================

  Future<List<Technician>> getTechnicians() async {
    try {
      if (_mode == 'supabase') {
        return await _supabaseService.getTechnicians();
      } else if (_mode == 'local') {
        return await _localDB.getTechnicians();
      } else {
        // Hybrid mode - prioritaskan Supabase, fallback ke lokal
        try {
          final technicians = await _supabaseService.getTechnicians();
          return technicians.isNotEmpty
              ? technicians
              : await _localDB.getTechnicians();
        } catch (e) {
          print(
            'Error getting technicians from Supabase, falling back to local: $e',
          );
          return await _localDB.getTechnicians();
        }
      }
    } catch (e) {
      print('Error getting technicians: $e');
      return [];
    }
  }

  Future<bool> insertTechnician(Technician technician) async {
    try {
      bool success = true;

      if (_mode == 'supabase' || _mode == 'hybrid') {
        success = await _supabaseService.insertTechnician(technician);
      }

      if (_mode == 'local' || (_mode == 'hybrid' && !success)) {
        await _localDB.insertTechnician(technician);
      }

      return success;
    } catch (e) {
      print('Error inserting technician: $e');
      return false;
    }
  }

  Future<bool> updateTechnician(Technician technician) async {
    try {
      bool success = true;

      if (_mode == 'supabase' || _mode == 'hybrid') {
        success = await _supabaseService.updateTechnician(technician);
      }

      if (_mode == 'local' || (_mode == 'hybrid' && !success)) {
        await _localDB.updateTechnician(technician);
      }

      return success;
    } catch (e) {
      print('Error updating technician: $e');
      return false;
    }
  }

  Future<bool> deleteTechnician(String id) async {
    try {
      bool success = true;

      if (_mode == 'supabase' || _mode == 'hybrid') {
        success = await _supabaseService.deleteTechnician(id);
      }

      if (_mode == 'local' || (_mode == 'hybrid' && !success)) {
        await _localDB.deleteTechnician(id);
      }

      return success;
    } catch (e) {
      print('Error deleting technician: $e');
      return false;
    }
  }

  // ==================== BOOKING OPERATIONS ====================

  Future<List<Booking>> getBookings() async {
    try {
      if (_mode == 'supabase') {
        return await _supabaseService.getBookings();
      } else if (_mode == 'local') {
        return await _localDB.getBookings();
      } else {
        // Hybrid mode - prioritaskan Supabase, fallback ke lokal
        try {
          final bookings = await _supabaseService.getBookings();
          return bookings.isNotEmpty ? bookings : await _localDB.getBookings();
        } catch (e) {
          print(
            'Error getting bookings from Supabase, falling back to local: $e',
          );
          return await _localDB.getBookings();
        }
      }
    } catch (e) {
      print('Error getting bookings: $e');
      return [];
    }
  }

  Future<bool> insertBooking(Booking booking) async {
    try {
      bool success = true;

      if (_mode == 'supabase' || _mode == 'hybrid') {
        success = await _supabaseService.insertBooking(booking);
      }

      if (_mode == 'local' || (_mode == 'hybrid' && !success)) {
        await _localDB.insertBooking(booking);
      }

      return success;
    } catch (e) {
      print('Error inserting booking: $e');
      return false;
    }
  }

  Future<bool> updateBooking(Booking booking) async {
    try {
      bool success = true;

      if (_mode == 'supabase' || _mode == 'hybrid') {
        success = await _supabaseService.updateBooking(booking);
      }

      if (_mode == 'local' || (_mode == 'hybrid' && !success)) {
        await _localDB.updateBooking(booking);
      }

      return success;
    } catch (e) {
      print('Error updating booking: $e');
      return false;
    }
  }

  Future<bool> deleteBooking(String id) async {
    try {
      bool success = true;

      if (_mode == 'supabase' || _mode == 'hybrid') {
        success = await _supabaseService.deleteBooking(id);
      }

      if (_mode == 'local' || (_mode == 'hybrid' && !success)) {
        await _localDB.deleteBooking(id);
      }

      return success;
    } catch (e) {
      print('Error deleting booking: $e');
      return false;
    }
  }

  // ==================== TRANSACTION OPERATIONS ====================

  Future<List<app_transaction.Transaction>> getTransactions() async {
    try {
      if (_mode == 'supabase') {
        return await _supabaseService.getTransactions();
      } else if (_mode == 'local') {
        return await _localDB.getTransactions();
      } else {
        // Hybrid mode - prioritaskan Supabase, fallback ke lokal
        try {
          final transactions = await _supabaseService.getTransactions();
          return transactions.isNotEmpty
              ? transactions
              : await _localDB.getTransactions();
        } catch (e) {
          print(
            'Error getting transactions from Supabase, falling back to local: $e',
          );
          return await _localDB.getTransactions();
        }
      }
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  Future<bool> insertTransaction(
    app_transaction.Transaction transaction,
  ) async {
    try {
      bool success = true;

      if (_mode == 'supabase' || _mode == 'hybrid') {
        success = await _supabaseService.insertTransaction(transaction);
      }

      if (_mode == 'local' || (_mode == 'hybrid' && !success)) {
        await _localDB.insertTransaction(transaction);
      }

      return success;
    } catch (e) {
      print('Error inserting transaction: $e');
      return false;
    }
  }

  Future<bool> updateTransaction(
    app_transaction.Transaction transaction,
  ) async {
    try {
      bool success = true;

      if (_mode == 'supabase' || _mode == 'hybrid') {
        success = await _supabaseService.updateTransaction(transaction);
      }

      if (_mode == 'local' || (_mode == 'hybrid' && !success)) {
        await _localDB.updateTransaction(transaction);
      }

      return success;
    } catch (e) {
      print('Error updating transaction: $e');
      return false;
    }
  }

  // ==================== NOTIFICATION OPERATIONS ====================

  Future<List<app_notification.Notification>> getNotifications() async {
    try {
      if (_mode == 'supabase') {
        return await _supabaseService.getNotifications();
      } else if (_mode == 'local') {
        return await _localDB.getNotifications();
      } else {
        // Hybrid mode - prioritaskan Supabase, fallback ke lokal
        try {
          final notifications = await _supabaseService.getNotifications();
          return notifications.isNotEmpty
              ? notifications
              : await _localDB.getNotifications();
        } catch (e) {
          print(
            'Error getting notifications from Supabase, falling back to local: $e',
          );
          return await _localDB.getNotifications();
        }
      }
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  Future<bool> insertNotification(
    app_notification.Notification notification,
  ) async {
    try {
      bool success = true;

      if (_mode == 'supabase' || _mode == 'hybrid') {
        success = await _supabaseService.insertNotification(notification);
      }

      if (_mode == 'local' || (_mode == 'hybrid' && !success)) {
        await _localDB.insertNotification(notification);
      }

      return success;
    } catch (e) {
      print('Error inserting notification: $e');
      return false;
    }
  }

  Future<bool> updateNotification(
    app_notification.Notification notification,
  ) async {
    try {
      bool success = true;

      if (_mode == 'supabase' || _mode == 'hybrid') {
        success = await _supabaseService.updateNotification(notification);
      }

      if (_mode == 'local' || (_mode == 'hybrid' && !success)) {
        await _localDB.updateNotification(notification);
      }

      return success;
    } catch (e) {
      print('Error updating notification: $e');
      return false;
    }
  }

  // ==================== DASHBOARD ANALYTICS ====================

  Future<Map<String, dynamic>> getDashboardAnalytics() async {
    try {
      if (_mode == 'supabase') {
        return await _supabaseService.getDashboardAnalytics();
      } else if (_mode == 'local') {
        return await _localDB.getDashboardAnalytics();
      } else {
        // Hybrid mode - prioritaskan Supabase, fallback ke lokal
        try {
          final analytics = await _supabaseService.getDashboardAnalytics();
          return analytics['totalProducts'] > 0
              ? analytics
              : await _localDB.getDashboardAnalytics();
        } catch (e) {
          print(
            'Error getting dashboard analytics from Supabase, falling back to local: $e',
          );
          return await _localDB.getDashboardAnalytics();
        }
      }
    } catch (e) {
      print('Error getting dashboard analytics: $e');
      return {
        'dailyRevenue': 0.0,
        'dailyTransactions': 0,
        'monthlyRevenue': 0.0,
        'monthlyTransactions': 0,
        'pendingBookings': 0,
        'totalProducts': 0,
        'totalVehicles': 0,
        'totalTechnicians': 0,
      };
    }
  }

  // ==================== CLEANUP ====================

  Future<void> dispose() async {
    _stopAutoSync();
    // Jangan tutup database lokal, biarkan tetap terbuka selama aplikasi berjalan
    // await _localDB.close();
  }
}
