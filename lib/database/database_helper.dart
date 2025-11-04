import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/transaction.dart' as app_transaction;
import '../models/vehicle.dart';

// Import untuk platform desktop
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    // Inisialisasi database factory untuk platform desktop
    if (!kIsWeb) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('workshop_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDB,
          onConfigure: (db) async {
            // Enable foreign keys
            await db.execute('PRAGMA foreign_keys = ON');
          },
        ),
      );
    } catch (e) {
      // Fallback untuk development - gunakan database in-memory
      print('Error initializing database: $e');
      return await databaseFactory.openDatabase(
        ':memory:',
        options: OpenDatabaseOptions(version: 1, onCreate: _createDB),
      );
    }
  }

  Future _createDB(Database db, int version) async {
    // Create products table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create vehicles table
    await db.execute('''
      CREATE TABLE vehicles (
        id TEXT PRIMARY KEY,
        customer_name TEXT NOT NULL,
        vehicle_type TEXT NOT NULL,
        license_plate TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        problem_description TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        estimated_completion INTEGER,
        estimated_cost REAL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        vehicle_id TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        services TEXT NOT NULL,
        total_amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        paid_at INTEGER,
        cash_amount REAL,
        change_amount REAL
      )
    ''');

    // Insert default products
    await _insertDefaultProducts(db);
  }

  Future<void> _insertDefaultProducts(Database db) async {
    final defaultProducts = [
      Product(
        id: 'P001',
        name: 'Oli Motor 1L',
        category: 'Oli',
        price: 45000,
        stock: 50,
        description: 'Oli motor premium 1 liter',
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'P002',
        name: 'Kampas Rem Depan',
        category: 'Rem',
        price: 120000,
        stock: 25,
        description: 'Kampas rem depan motor',
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'P003',
        name: 'Busi Standard',
        category: 'Mesin',
        price: 25000,
        stock: 100,
        description: 'Busi motor standard',
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'P004',
        name: 'Filter Udara',
        category: 'Mesin',
        price: 35000,
        stock: 40,
        description: 'Filter udara motor',
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'P005',
        name: 'Rantai Motor',
        category: 'Transmisi',
        price: 180000,
        stock: 15,
        description: 'Rantai motor heavy duty',
        createdAt: DateTime.now(),
      ),
    ];

    for (final product in defaultProducts) {
      await db.insert('products', _productToMap(product));
    }
  }

  // Product CRUD operations
  Future<int> insertProduct(Product product) async {
    try {
      final db = await database;
      return await db.insert('products', _productToMap(product));
    } catch (e) {
      print('Error inserting product: $e');
      throw Exception('Failed to insert product: $e');
    }
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final result = await db.query('products', orderBy: 'created_at DESC');
    return result.map((map) => _mapToProduct(map)).toList();
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => _mapToProduct(map)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => _mapToProduct(map)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      _productToMap(product),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(String id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Vehicle CRUD operations
  Future<int> insertVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.insert('vehicles', _vehicleToMap(vehicle));
  }

  Future<List<Vehicle>> getVehicles() async {
    final db = await database;
    final result = await db.query('vehicles', orderBy: 'created_at DESC');
    return result.map((map) => _mapToVehicle(map)).toList();
  }

  Future<int> updateVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.update(
      'vehicles',
      _vehicleToMap(vehicle),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<int> deleteVehicle(String id) async {
    final db = await database;
    return await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  // Transaction CRUD operations
  Future<int> insertTransaction(app_transaction.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', _transactionToMap(transaction));
  }

  Future<List<app_transaction.Transaction>> getTransactions() async {
    final db = await database;
    final result = await db.query('transactions', orderBy: 'created_at DESC');
    return result.map((map) => _mapToTransaction(map)).toList();
  }

  Future<List<app_transaction.Transaction>> getTransactionsByStatus(
    app_transaction.TransactionStatus status,
  ) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'status = ?',
      whereArgs: [status.toString()],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => _mapToTransaction(map)).toList();
  }

  Future<List<app_transaction.Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => _mapToTransaction(map)).toList();
  }

  Future<int> updateTransaction(app_transaction.Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      _transactionToMap(transaction),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Helper methods for Product
  Map<String, dynamic> _productToMap(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'category': product.category,
      'price': product.price,
      'stock': product.stock,
      'description': product.description,
      'created_at': product.createdAt.millisecondsSinceEpoch,
    };
  }

  Product _mapToProduct(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      stock: map['stock'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  // Helper methods for Vehicle
  Map<String, dynamic> _vehicleToMap(Vehicle vehicle) {
    return {
      'id': vehicle.id,
      'customer_name': vehicle.customerName,
      'vehicle_type': vehicle.vehicleType,
      'license_plate': vehicle.licensePlate,
      'phone_number': vehicle.phoneNumber,
      'problem_description': vehicle.problemDescription,
      'status': vehicle.status.toString(),
      'created_at': vehicle.createdAt.millisecondsSinceEpoch,
      'estimated_completion':
          vehicle.estimatedCompletion?.millisecondsSinceEpoch,
      'estimated_cost': vehicle.estimatedCost,
    };
  }

  Vehicle _mapToVehicle(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      customerName: map['customer_name'],
      vehicleType: map['vehicle_type'],
      licensePlate: map['license_plate'],
      phoneNumber: map['phone_number'],
      problemDescription: map['problem_description'],
      status: _parseVehicleStatus(map['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      estimatedCompletion: map['estimated_completion'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['estimated_completion'])
          : null,
      estimatedCost: map['estimated_cost'],
    );
  }

  // Helper methods for Transaction
  Map<String, dynamic> _transactionToMap(
    app_transaction.Transaction transaction,
  ) {
    return {
      'id': transaction.id,
      'vehicle_id': transaction.vehicleId,
      'customer_name': transaction.customerName,
      'services': _servicesToJson(transaction.services),
      'total_amount': transaction.totalAmount,
      'payment_method': transaction.paymentMethod.toString(),
      'status': transaction.status.toString(),
      'created_at': transaction.createdAt.millisecondsSinceEpoch,
      'paid_at': transaction.paidAt?.millisecondsSinceEpoch,
      'cash_amount': transaction.cashAmount,
      'change_amount': transaction.changeAmount,
    };
  }

  app_transaction.Transaction _mapToTransaction(Map<String, dynamic> map) {
    return app_transaction.Transaction(
      id: map['id'],
      vehicleId: map['vehicle_id'],
      customerName: map['customer_name'],
      services: _jsonToServices(map['services']),
      totalAmount: map['total_amount'],
      paymentMethod: _parsePaymentMethod(map['payment_method']),
      status: _parseTransactionStatus(map['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      paidAt: map['paid_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['paid_at'])
          : null,
      cashAmount: map['cash_amount'],
      changeAmount: map['change_amount'],
    );
  }

  String _servicesToJson(List<app_transaction.ServiceItem> services) {
    return services
        .map(
          (service) => '${service.name}|${service.price}|${service.quantity}',
        )
        .join(',');
  }

  List<app_transaction.ServiceItem> _jsonToServices(String servicesJson) {
    return servicesJson.split(',').map((serviceStr) {
      final parts = serviceStr.split('|');
      return app_transaction.ServiceItem(
        name: parts[0],
        price: double.parse(parts[1]),
        quantity: int.parse(parts[2]),
      );
    }).toList();
  }

  VehicleStatus _parseVehicleStatus(String status) {
    switch (status) {
      case 'VehicleStatus.waiting':
        return VehicleStatus.waiting;
      case 'VehicleStatus.inProgress':
        return VehicleStatus.inProgress;
      case 'VehicleStatus.completed':
        return VehicleStatus.completed;
      case 'VehicleStatus.delivered':
        return VehicleStatus.delivered;
      default:
        return VehicleStatus.waiting;
    }
  }

  app_transaction.PaymentMethod _parsePaymentMethod(String method) {
    switch (method) {
      case 'PaymentMethod.cash':
        return app_transaction.PaymentMethod.cash;
      case 'PaymentMethod.transfer':
        return app_transaction.PaymentMethod.transfer;
      case 'PaymentMethod.card':
        return app_transaction.PaymentMethod.card;
      default:
        return app_transaction.PaymentMethod.cash;
    }
  }

  app_transaction.TransactionStatus _parseTransactionStatus(String status) {
    switch (status) {
      case 'TransactionStatus.pending':
        return app_transaction.TransactionStatus.pending;
      case 'TransactionStatus.paid':
        return app_transaction.TransactionStatus.paid;
      case 'TransactionStatus.cancelled':
        return app_transaction.TransactionStatus.cancelled;
      default:
        return app_transaction.TransactionStatus.pending;
    }
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
