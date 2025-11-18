import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/product.dart';
import '../models/transaction.dart' as app_transaction;
import '../models/vehicle.dart';
import '../models/technician.dart';
import '../models/booking.dart';
import '../models/notification.dart' as app_notification;

// Import untuk platform desktop
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool _isInitialized = false;

  DatabaseHelper._init() {
    // Inisialisasi database factory hanya untuk platform desktop
    if (!_isInitialized) {
      try {
        // Cek apakah ini platform desktop (Windows, Linux, macOS)
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          sqfliteFfiInit();
          databaseFactory = databaseFactoryFfi;
          print('FFI database factory initialized for desktop platform');
        } else {
          // Untuk mobile (Android/iOS), gunakan factory default
          print('Using default database factory for mobile platform');
        }
        _isInitialized = true;
      } catch (e) {
        print('Warning: Could not initialize FFI database factory: $e');
        // Gunakan factory default jika FFI gagal
      }
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(
      'workshop_manager_v2.db',
    ); // Kembali ke versi sebelum barcode
    print('Database initialized successfully');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      // Untuk platform mobile, gunakan path yang benar
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      print('Initializing database at path: $path');

      // Tidak perlu membuat direktori, sqflite akan otomatis membuatnya

      // Gunakan database factory yang sesuai dengan platform
      final factory =
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
          ? databaseFactoryFfi
          : databaseFactory;

      return await factory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 4,
          onCreate: _createDB,
          onUpgrade: _onUpgrade, // Tambahkan handler untuk upgrade
          onConfigure: (db) async {
            // Enable foreign keys
            await db.execute('PRAGMA foreign_keys = ON');
            print('Database configured with foreign keys enabled');
          },
        ),
      );
    } catch (e) {
      // Fallback untuk development - gunakan database file di direktori yang sama
      print('Error initializing database: $e');
      // Fallback sederhana: gunakan current directory
      try {
        final fallbackPath = './workshop_manager_v3.db';
        print('Trying fallback path: $fallbackPath');

        // Gunakan database factory yang sesuai dengan platform
        final factory =
            (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
            ? databaseFactoryFfi
            : databaseFactory;

        return await factory.openDatabase(
          fallbackPath,
          options: OpenDatabaseOptions(
            version: 4,
            onCreate: _createDB,
            onUpgrade: _onUpgrade,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
          ),
        );
      } catch (e2) {
        print('Error with fallback database: $e2');
        // Fallback terakhir: gunakan in-memory untuk testing
        print('Using in-memory database as final fallback');

        // Gunakan database factory yang sesuai dengan platform
        final factory =
            (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
            ? databaseFactoryFfi
            : databaseFactory;

        return await factory.openDatabase(
          ':memory:',
          options: OpenDatabaseOptions(
            version: 4,
            onCreate: _createDB,
            onUpgrade: _onUpgrade,
            onConfigure: (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
          ),
        );
      }
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
        created_at INTEGER NOT NULL,
        barcode TEXT,
        min_stock INTEGER DEFAULT 5,
        supplier_name TEXT,
        supplier_phone TEXT,
        last_restock_date INTEGER,
        cost_price REAL DEFAULT 0
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
        estimated_cost REAL,
        payment_method TEXT,
        actual_cost REAL,
        is_paid INTEGER DEFAULT 0,
        technician_id TEXT,
        booking_id TEXT,
        service_reminder_date INTEGER,
        last_service_date INTEGER,
        mileage INTEGER,
        next_service_mileage INTEGER,
        customer_email TEXT,
        customer_address TEXT,
        membership_tier TEXT DEFAULT 'Bronze',
        reward_points INTEGER DEFAULT 0
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
        change_amount REAL,
        branch_id TEXT DEFAULT 'MAIN',
        invoice_number TEXT,
        payment_due_date INTEGER,
        is_debt INTEGER DEFAULT 0,
        debt_amount REAL DEFAULT 0,
        debt_paid_amount REAL DEFAULT 0,
        debt_status TEXT DEFAULT 'paid'
      )
    ''');

    // Create technicians table
    await db.execute('''
      CREATE TABLE technicians (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        specialization TEXT,
        experience_years INTEGER DEFAULT 0,
        status TEXT DEFAULT 'active',
        created_at INTEGER NOT NULL,
        last_active INTEGER,
        rating REAL DEFAULT 0,
        total_services INTEGER DEFAULT 0,
        salary_type TEXT DEFAULT 'daily',
        salary_amount REAL DEFAULT 0
      )
    ''');

    // Create bookings table
    await db.execute('''
      CREATE TABLE bookings (
        id TEXT PRIMARY KEY,
        customer_name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        email TEXT,
        vehicle_type TEXT NOT NULL,
        license_plate TEXT,
        service_type TEXT NOT NULL,
        preferred_date INTEGER NOT NULL,
        preferred_time TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        created_at INTEGER NOT NULL,
        confirmed_at INTEGER,
        completed_at INTEGER,
        technician_id TEXT,
        estimated_duration INTEGER,
        notes TEXT,
        reminder_sent INTEGER DEFAULT 0
      )
    ''');

    // Create notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        recipient_type TEXT NOT NULL,
        recipient_id TEXT,
        status TEXT DEFAULT 'pending',
        created_at INTEGER NOT NULL,
        sent_at INTEGER,
        read_at INTEGER,
        related_id TEXT,
        priority TEXT DEFAULT 'medium'
      )
    ''');

    // Create branches table
    await db.execute('''
      CREATE TABLE branches (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        manager_name TEXT,
        created_at INTEGER NOT NULL,
        is_active INTEGER DEFAULT 1,
        timezone TEXT DEFAULT 'Asia/Jakarta'
      )
    ''');

    // Create inventory_movements table
    await db.execute('''
      CREATE TABLE inventory_movements (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        movement_type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        previous_stock INTEGER NOT NULL,
        new_stock INTEGER NOT NULL,
        reference_id TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        branch_id TEXT DEFAULT 'MAIN',
        user_id TEXT
      )
    ''');

    // Create loyalty_programs table
    await db.execute('''
      CREATE TABLE loyalty_programs (
        id TEXT PRIMARY KEY,
        customer_phone TEXT NOT NULL,
        tier TEXT DEFAULT 'Bronze',
        points INTEGER DEFAULT 0,
        total_spent REAL DEFAULT 0,
        join_date INTEGER NOT NULL,
        last_activity INTEGER NOT NULL,
        discount_percentage REAL DEFAULT 0,
        special_benefits TEXT
      )
    ''');

    // Create service_reminders table
    await db.execute('''
      CREATE TABLE service_reminders (
        id TEXT PRIMARY KEY,
        vehicle_id TEXT NOT NULL,
        customer_phone TEXT NOT NULL,
        service_type TEXT NOT NULL,
        reminder_date INTEGER NOT NULL,
        mileage_threshold INTEGER,
        is_sent INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        sent_at INTEGER,
        response_status TEXT
      )
    ''');

    // Insert default products
    await _insertDefaultProducts(db);

    // Insert default branch
    await _insertDefaultBranch(db);

    // Insert default technicians
    await _insertDefaultTechnicians(db);
  }

  Future<void> _insertDefaultBranch(Database db) async {
    await db.insert('branches', {
      'id': 'MAIN',
      'name': 'Cabang Utama',
      'address': 'Jl. Utama No. 1',
      'phone': '021-12345678',
      'email': 'main@workshop.com',
      'manager_name': 'Manager Utama',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'is_active': 1,
      'timezone': 'Asia/Jakarta',
    });
  }

  Future<void> _insertDefaultTechnicians(Database db) async {
    final technicians = [
      {
        'id': 'TECH001',
        'name': 'Budi Santoso',
        'phone': '081234567890',
        'email': 'budi@workshop.com',
        'specialization': 'Mesin & Transmisi',
        'experience_years': 5,
        'status': 'active',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'rating': 4.5,
        'total_services': 0,
        'salary_type': 'daily',
        'salary_amount': 150000,
      },
      {
        'id': 'TECH002',
        'name': 'Ahmad Wijaya',
        'phone': '082345678901',
        'email': 'ahmad@workshop.com',
        'specialization': 'Kelistrikan & AC',
        'experience_years': 3,
        'status': 'active',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'rating': 4.3,
        'total_services': 0,
        'salary_type': 'daily',
        'salary_amount': 140000,
      },
    ];

    for (final tech in technicians) {
      await db.insert('technicians', tech);
    }
  }

  // Tambahkan method untuk migrasi database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      // Tambahkan kolom-kolom baru untuk pembayaran
      try {
        await db.execute('ALTER TABLE vehicles ADD COLUMN payment_method TEXT');
        print('Added payment_method column to vehicles table');
      } catch (e) {
        print('Column payment_method might already exist: $e');
      }

      try {
        await db.execute('ALTER TABLE vehicles ADD COLUMN actual_cost REAL');
        print('Added actual_cost column to vehicles table');
      } catch (e) {
        print('Column actual_cost might already exist: $e');
      }

      try {
        await db.execute(
          'ALTER TABLE vehicles ADD COLUMN is_paid INTEGER DEFAULT 0',
        );
        print('Added is_paid column to vehicles table');
      } catch (e) {
        print('Column is_paid might already exist: $e');
      }
    }

    if (oldVersion < 3) {
      // Tambahkan kolom-kolom baru untuk fitur multi-cabang dan hutang
      try {
        await db.execute(
          'ALTER TABLE transactions ADD COLUMN branch_id TEXT DEFAULT "MAIN"',
        );
        print('Added branch_id column to transactions table');
      } catch (e) {
        print('Column branch_id might already exist: $e');
      }

      try {
        await db.execute(
          'ALTER TABLE transactions ADD COLUMN invoice_number TEXT',
        );
        print('Added invoice_number column to transactions table');
      } catch (e) {
        print('Column invoice_number might already exist: $e');
      }

      try {
        await db.execute(
          'ALTER TABLE transactions ADD COLUMN payment_due_date INTEGER',
        );
        print('Added payment_due_date column to transactions table');
      } catch (e) {
        print('Column payment_due_date might already exist: $e');
      }

      try {
        await db.execute(
          'ALTER TABLE transactions ADD COLUMN is_debt INTEGER DEFAULT 0',
        );
        print('Added is_debt column to transactions table');
      } catch (e) {
        print('Column is_debt might already exist: $e');
      }

      try {
        await db.execute(
          'ALTER TABLE transactions ADD COLUMN debt_amount REAL DEFAULT 0',
        );
        print('Added debt_amount column to transactions table');
      } catch (e) {
        print('Column debt_amount might already exist: $e');
      }

      try {
        await db.execute(
          'ALTER TABLE transactions ADD COLUMN debt_paid_amount REAL DEFAULT 0',
        );
        print('Added debt_paid_amount column to transactions table');
      } catch (e) {
        print('Column debt_paid_amount might already exist: $e');
      }

      try {
        await db.execute(
          'ALTER TABLE transactions ADD COLUMN debt_status TEXT DEFAULT "paid"',
        );
        print('Added debt_status column to transactions table');
      } catch (e) {
        print('Column debt_status might already exist: $e');
      }

      // Tambahkan kolom untuk vehicles
      try {
        await db.execute('ALTER TABLE vehicles ADD COLUMN technician_id TEXT');
        print('Added technician_id column to vehicles table');
      } catch (e) {
        print('Column technician_id might already exist: $e');
      }

      try {
        await db.execute('ALTER TABLE vehicles ADD COLUMN booking_id TEXT');
        print('Added booking_id column to vehicles table');
      } catch (e) {
        print('Column booking_id might already exist: $e');
      }

      try {
        await db.execute(
          'ALTER TABLE vehicles ADD COLUMN service_reminder_date INTEGER',
        );
        print('Added service_reminder_date column to vehicles table');
      } catch (e) {
        print('Column service_reminder_date might already exist: $e');
      }

      try {
        await db.execute(
          'ALTER TABLE vehicles ADD COLUMN last_service_date INTEGER',
        );
        print('Added last_service_date column to vehicles table');
      } catch (e) {
        print('Column last_service_date might already exist: $e');
      }

      try {
        await db.execute('ALTER TABLE vehicles ADD COLUMN mileage INTEGER');
        print('Added mileage column to vehicles table');
      } catch (e) {
        print('Column mileage might already exist: $e');
      }

      try {
        await db.execute(
          'ALTER TABLE vehicles ADD COLUMN next_service_mileage INTEGER',
        );
        print('Added next_service_mileage column to vehicles table');
      } catch (e) {
        print('Column next_service_mileage might already exist: $e');
      }

      try {
        await db.execute('ALTER TABLE vehicles ADD COLUMN customer_email TEXT');
        print('Added customer_email column to vehicles table');
      } catch (e) {
        print('Column customer_email might already exist: $e');
      }

      try {
        await db.execute(
          'ALTER TABLE vehicles ADD COLUMN customer_address TEXT',
        );
        print('Added customer_address column to vehicles table');
      } catch (e) {
        print('Column customer_address might already exist: $e');
      }

      try {
        await db.execute(
          'ALTER TABLE vehicles ADD COLUMN membership_tier TEXT DEFAULT "Bronze"',
        );
        print('Added membership_tier column to vehicles table');
      } catch (e) {
        print('Column membership_tier might already exist: $e');
      }

      try {
        await db.execute(
          'ALTER TABLE vehicles ADD COLUMN reward_points INTEGER DEFAULT 0',
        );
        print('Added reward_points column to vehicles table');
      } catch (e) {
        print('Column reward_points might already exist: $e');
      }
    }

    if (oldVersion < 4) {
      // Tambahkan tabel technicians jika belum ada
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS technicians (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT,
            specialization TEXT,
            experience_years INTEGER DEFAULT 0,
            status TEXT DEFAULT 'active',
            created_at INTEGER NOT NULL,
            last_active INTEGER,
            rating REAL DEFAULT 0,
            total_services INTEGER DEFAULT 0,
            salary_type TEXT DEFAULT 'daily',
            salary_amount REAL DEFAULT 0
          )
        ''');
        print('Created technicians table for version 4 migration');

        // Insert default technicians
        await _insertDefaultTechnicians(db);
      } catch (e) {
        print('Error creating technicians table: $e');
      }

      // Tambahkan tabel bookings jika belum ada
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS bookings (
            id TEXT PRIMARY KEY,
            customer_name TEXT NOT NULL,
            phone_number TEXT NOT NULL,
            email TEXT,
            vehicle_type TEXT NOT NULL,
            license_plate TEXT,
            service_type TEXT NOT NULL,
            preferred_date INTEGER NOT NULL,
            preferred_time TEXT NOT NULL,
            status TEXT DEFAULT 'pending',
            created_at INTEGER NOT NULL,
            confirmed_at INTEGER,
            completed_at INTEGER,
            technician_id TEXT,
            estimated_duration INTEGER,
            notes TEXT,
            reminder_sent INTEGER DEFAULT 0
          )
        ''');
        print('Created bookings table for version 4 migration');
      } catch (e) {
        print('Error creating bookings table: $e');
      }

      // Tambahkan juga tabel notifications jika belum ada
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS notifications (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            title TEXT NOT NULL,
            message TEXT NOT NULL,
            recipient_type TEXT NOT NULL,
            recipient_id TEXT,
            status TEXT DEFAULT 'pending',
            created_at INTEGER NOT NULL,
            sent_at INTEGER,
            read_at INTEGER,
            related_id TEXT,
            priority TEXT DEFAULT 'medium'
          )
        ''');
        print('Created notifications table for version 4 migration');
      } catch (e) {
        print('Error creating notifications table: $e');
      }

      // Tambahkan juga tabel branches jika belum ada
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS branches (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            address TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT,
            manager_name TEXT,
            created_at INTEGER NOT NULL,
            is_active INTEGER DEFAULT 1,
            timezone TEXT DEFAULT 'Asia/Jakarta'
          )
        ''');
        print('Created branches table for version 4 migration');

        // Insert default branch
        await _insertDefaultBranch(db);
      } catch (e) {
        print('Error creating branches table: $e');
      }

      // Tambahkan juga tabel loyalty_programs jika belum ada
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS loyalty_programs (
            id TEXT PRIMARY KEY,
            customer_phone TEXT NOT NULL,
            tier TEXT DEFAULT 'Bronze',
            points INTEGER DEFAULT 0,
            total_spent REAL DEFAULT 0,
            join_date INTEGER NOT NULL,
            last_activity INTEGER NOT NULL,
            discount_percentage REAL DEFAULT 0,
            special_benefits TEXT
          )
        ''');
        print('Created loyalty_programs table for version 4 migration');
      } catch (e) {
        print('Error creating loyalty_programs table: $e');
      }

      // Tambahkan juga tabel service_reminders jika belum ada
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS service_reminders (
            id TEXT PRIMARY KEY,
            vehicle_id TEXT NOT NULL,
            customer_phone TEXT NOT NULL,
            service_type TEXT NOT NULL,
            reminder_date INTEGER NOT NULL,
            mileage_threshold INTEGER,
            is_sent INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL,
            sent_at INTEGER,
            response_status TEXT
          )
        ''');
        print('Created service_reminders table for version 4 migration');
      } catch (e) {
        print('Error creating service_reminders table: $e');
      }

      // Tambahkan juga tabel inventory_movements jika belum ada
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS inventory_movements (
            id TEXT PRIMARY KEY,
            product_id TEXT NOT NULL,
            movement_type TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            previous_stock INTEGER NOT NULL,
            new_stock INTEGER NOT NULL,
            reference_id TEXT,
            notes TEXT,
            created_at INTEGER NOT NULL,
            branch_id TEXT DEFAULT 'MAIN',
            user_id TEXT
          )
        ''');
        print('Created inventory_movements table for version 4 migration');
      } catch (e) {
        print('Error creating inventory_movements table: $e');
      }
    }
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
      // Check if product with same ID already exists
      final existing = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [product.id],
      );

      if (existing.isNotEmpty) {
        // Update existing product instead
        return await db.update(
          'products',
          _productToMap(product),
          where: 'id = ?',
          whereArgs: [product.id],
        );
      }

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
    try {
      final db = await database;
      // Check if transaction with same ID already exists
      final existing = await db.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [transaction.id],
      );

      if (existing.isNotEmpty) {
        // Update existing transaction instead
        return await db.update(
          'transactions',
          _transactionToMap(transaction),
          where: 'id = ?',
          whereArgs: [transaction.id],
        );
      }

      return await db.insert('transactions', _transactionToMap(transaction));
    } catch (e) {
      print('Error inserting transaction: $e');
      throw Exception('Failed to insert transaction: $e');
    }
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

  // Method untuk mendapatkan transaksi hari ini
  Future<List<app_transaction.Transaction>> getDailyTransactions() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await getTransactionsByDateRange(startOfDay, endOfDay);
  }

  // Method untuk mendapatkan total pendapatan hari ini
  Future<double> getDailyRevenue() async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      '''
      SELECT SUM(total_amount) as total_revenue
      FROM transactions
      WHERE created_at >= ? AND created_at < ? AND status = ?
    ''',
      [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
        app_transaction.TransactionStatus.paid.toString(),
      ],
    );

    return result.first['total_revenue'] as double? ?? 0.0;
  }

  // Method untuk mendapatkan jumlah kendaraan yang selesai hari ini
  Future<int> getDailyCompletedVehicles() async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as completed_count
      FROM vehicles
      WHERE created_at >= ? AND created_at < ? AND status = ?
    ''',
      [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
        VehicleStatus.completed.toString(),
      ],
    );

    return result.first['completed_count'] as int? ?? 0;
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

  // CRUD operations for Technician
  Future<int> insertTechnician(Technician technician) async {
    final db = await database;
    return await db.insert('technicians', _technicianToMap(technician));
  }

  Future<List<Technician>> getTechnicians() async {
    try {
      final db = await database;
      final result = await db.query('technicians', orderBy: 'created_at DESC');
      return result.map((map) => _mapToTechnician(map)).toList();
    } catch (e) {
      print('Error getting technicians: $e');
      // Jika tabel tidak ada, coba buat tabel dan kembalikan data default
      if (e.toString().contains('no such table')) {
        try {
          final db = await database;
          await db.execute('''
            CREATE TABLE IF NOT EXISTS technicians (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              phone TEXT NOT NULL,
              email TEXT,
              specialization TEXT,
              experience_years INTEGER DEFAULT 0,
              status TEXT DEFAULT 'active',
              created_at INTEGER NOT NULL,
              last_active INTEGER,
              rating REAL DEFAULT 0,
              total_services INTEGER DEFAULT 0,
              salary_type TEXT DEFAULT 'daily',
              salary_amount REAL DEFAULT 0
            )
          ''');
          print('Created technicians table on-demand');

          // Insert default technicians
          await _insertDefaultTechnicians(db);

          // Retry query
          final result = await db.query(
            'technicians',
            orderBy: 'created_at DESC',
          );
          return result.map((map) => _mapToTechnician(map)).toList();
        } catch (e2) {
          print('Error creating technicians table on-demand: $e2');
          return []; // Return empty list as fallback
        }
      }
      return []; // Return empty list for other errors
    }
  }

  Future<List<Technician>> getActiveTechnicians() async {
    final db = await database;
    final result = await db.query(
      'technicians',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'name ASC',
    );
    return result.map((map) => _mapToTechnician(map)).toList();
  }

  Future<int> updateTechnician(Technician technician) async {
    final db = await database;
    return await db.update(
      'technicians',
      _technicianToMap(technician),
      where: 'id = ?',
      whereArgs: [technician.id],
    );
  }

  Future<int> deleteTechnician(String id) async {
    final db = await database;
    return await db.delete('technicians', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD operations for Booking
  Future<int> insertBooking(Booking booking) async {
    final db = await database;
    return await db.insert('bookings', _bookingToMap(booking));
  }

  Future<List<Booking>> getBookings() async {
    final db = await database;
    final result = await db.query(
      'bookings',
      orderBy: 'preferred_date ASC, preferred_time ASC',
    );
    return result.map((map) => _mapToBooking(map)).toList();
  }

  Future<List<Booking>> getBookingsByStatus(BookingStatus status) async {
    try {
      final db = await database;
      final result = await db.query(
        'bookings',
        where: 'status = ?',
        whereArgs: [status.toString()],
        orderBy: 'preferred_date ASC, preferred_time ASC',
      );
      return result.map((map) => _mapToBooking(map)).toList();
    } catch (e) {
      print('Error getting bookings by status: $e');
      return []; // Return empty list jika terjadi error
    }
  }

  Future<List<Booking>> getBookingsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.query(
      'bookings',
      where: 'preferred_date >= ? AND preferred_date < ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
      orderBy: 'preferred_time ASC',
    );
    return result.map((map) => _mapToBooking(map)).toList();
  }

  Future<int> updateBooking(Booking booking) async {
    final db = await database;
    return await db.update(
      'bookings',
      _bookingToMap(booking),
      where: 'id = ?',
      whereArgs: [booking.id],
    );
  }

  Future<int> deleteBooking(String id) async {
    final db = await database;
    return await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD operations for Notification
  Future<int> insertNotification(
    app_notification.Notification notification,
  ) async {
    final db = await database;
    return await db.insert('notifications', _notificationToMap(notification));
  }

  Future<List<app_notification.Notification>> getNotifications() async {
    final db = await database;
    final result = await db.query('notifications', orderBy: 'created_at DESC');
    return result.map((map) => _mapToNotification(map)).toList();
  }

  Future<List<app_notification.Notification>> getPendingNotifications() async {
    final db = await database;
    final result = await db.query(
      'notifications',
      where: 'status = ?',
      whereArgs: ['NotificationStatus.pending'],
      orderBy: 'priority DESC, created_at ASC',
    );
    return result.map((map) => _mapToNotification(map)).toList();
  }

  Future<List<app_notification.Notification>> getNotificationsByRecipient(
    String recipientId,
    app_notification.NotificationRecipientType recipientType,
  ) async {
    final db = await database;
    final result = await db.query(
      'notifications',
      where: 'recipient_id = ? AND recipient_type = ?',
      whereArgs: [recipientId, recipientType.toString()],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => _mapToNotification(map)).toList();
  }

  Future<int> updateNotification(
    app_notification.Notification notification,
  ) async {
    final db = await database;
    return await db.update(
      'notifications',
      _notificationToMap(notification),
      where: 'id = ?',
      whereArgs: [notification.id],
    );
  }

  Future<int> markNotificationAsRead(String id) async {
    final db = await database;
    return await db.update(
      'notifications',
      {
        'status': 'NotificationStatus.read',
        'read_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNotification(String id) async {
    final db = await database;
    return await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  // Get dashboard analytics
  Future<Map<String, dynamic>> getDashboardAnalytics() async {
    final db = await database;
    final now = DateTime.now();

    // Get today's transactions
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final todayTransactions = await db.query(
      'transactions',
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [
        todayStart.millisecondsSinceEpoch,
        todayEnd.millisecondsSinceEpoch,
      ],
    );

    final dailyRevenue = todayTransactions.fold(0.0, (sum, t) {
      return sum + (t['total_amount'] as double);
    });

    // Get monthly transactions
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);

    final monthTransactions = await db.query(
      'transactions',
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [
        monthStart.millisecondsSinceEpoch,
        monthEnd.millisecondsSinceEpoch,
      ],
    );

    final monthlyRevenue = monthTransactions.fold(0.0, (sum, t) {
      return sum + (t['total_amount'] as double);
    });

    // Get pending bookings - handle jika tabel belum ada
    List<Map> pendingBookings = [];
    try {
      pendingBookings = await db.query(
        'bookings',
        where: 'status = ?',
        whereArgs: ['BookingStatus.pending'],
      );
    } catch (e) {
      print('Warning: Could not query bookings table: $e');
      pendingBookings = [];
    }

    // Get total products
    final totalProducts = await db.query('products');

    // Get total vehicles
    final totalVehicles = await db.query('vehicles');

    // Get total technicians
    final totalTechnicians = await db.query('technicians');

    return {
      'dailyRevenue': dailyRevenue,
      'dailyTransactions': todayTransactions.length,
      'monthlyRevenue': monthlyRevenue,
      'monthlyTransactions': monthTransactions.length,
      'pendingBookings': pendingBookings.length,
      'totalProducts': totalProducts.length,
      'totalVehicles': totalVehicles.length,
      'totalTechnicians': totalTechnicians.length,
    };
  }

  // Get transactions by date range
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

  // CRUD operations for Loyalty Program
  Future<int> insertLoyaltyMember(Map<String, dynamic> memberData) async {
    try {
      final db = await database;
      return await db.insert('loyalty_programs', memberData);
    } catch (e) {
      print('Warning: loyalty_programs table not found, returning 0: $e');
      return 0; // Return 0 jika tabel belum ada
    }
  }

  Future<List<Map<String, dynamic>>> getLoyaltyMembers() async {
    try {
      final db = await database;
      final result = await db.query(
        'loyalty_programs',
        orderBy: 'join_date DESC',
      );
      return result;
    } catch (e) {
      print(
        'Warning: loyalty_programs table not found, returning empty list: $e',
      );
      return []; // Return empty list jika tabel belum ada
    }
  }

  Future<List<Map<String, dynamic>>> getLoyaltyMembersByTier(
    String tier,
  ) async {
    try {
      final db = await database;
      final result = await db.query(
        'loyalty_programs',
        where: 'tier = ?',
        whereArgs: [tier],
        orderBy: 'total_spent DESC',
      );
      return result;
    } catch (e) {
      print(
        'Warning: loyalty_programs table not found, returning empty list: $e',
      );
      return []; // Return empty list jika tabel belum ada
    }
  }

  Future<Map<String, dynamic>?> getLoyaltyMemberByPhone(String phone) async {
    try {
      final db = await database;
      final result = await db.query(
        'loyalty_programs',
        where: 'customer_phone = ?',
        whereArgs: [phone],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Warning: loyalty_programs table not found, returning null: $e');
      return null; // Return null jika tabel belum ada
    }
  }

  Future<int> updateLoyaltyMember(Map<String, dynamic> memberData) async {
    try {
      final db = await database;
      return await db.update(
        'loyalty_programs',
        memberData,
        where: 'id = ?',
        whereArgs: [memberData['id']],
      );
    } catch (e) {
      print('Warning: loyalty_programs table not found, returning 0: $e');
      return 0; // Return 0 jika tabel belum ada
    }
  }

  Future<int> deleteLoyaltyMember(String id) async {
    try {
      final db = await database;
      return await db.delete(
        'loyalty_programs',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Warning: loyalty_programs table not found, returning 0: $e');
      return 0; // Return 0 jika tabel belum ada
    }
  }

  // Method untuk menambah poin loyalty
  Future<void> addLoyaltyPoints(
    String customerPhone,
    double points,
    double amountSpent,
  ) async {
    try {
      final db = await database;
      final member = await getLoyaltyMemberByPhone(customerPhone);

      if (member != null) {
        final newPoints = (member['points'] as double) + points;
        final newTotalSpent = (member['total_spent'] as double) + amountSpent;
        final newTier = _calculateTier(newPoints);

        await db.update(
          'loyalty_programs',
          {
            'points': newPoints,
            'total_spent': newTotalSpent,
            'tier': newTier,
            'last_activity': DateTime.now().millisecondsSinceEpoch,
            'discount_percentage': _getDiscountPercentage(newTier),
          },
          where: 'id = ?',
          whereArgs: [member['id']],
        );
      }
    } catch (e) {
      print(
        'Warning: loyalty_programs table not found, skipping points update: $e',
      );
      // Do nothing jika tabel belum ada
    }
  }

  String _calculateTier(double points) {
    if (points >= 10000) return 'Platinum';
    if (points >= 5000) return 'Gold';
    if (points >= 1000) return 'Silver';
    return 'Bronze';
  }

  double _getDiscountPercentage(String tier) {
    switch (tier) {
      case 'Platinum':
        return 15.0;
      case 'Gold':
        return 10.0;
      case 'Silver':
        return 5.0;
      case 'Bronze':
        return 0.0;
      default:
        return 0.0;
    }
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
      'payment_method': vehicle.paymentMethod?.toString(),
      'actual_cost': vehicle.actualCost,
      'is_paid': vehicle.isPaid ? 1 : 0,
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
      paymentMethod: map['payment_method'] != null
          ? _parsePaymentMethod(map['payment_method'])
          : null,
      actualCost: map['actual_cost'],
      isPaid: map['is_paid'] == 1,
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
      'branch_id': transaction.branchId ?? 'MAIN',
      'invoice_number': transaction.invoiceNumber,
      'payment_due_date': transaction.paymentDueDate?.millisecondsSinceEpoch,
      'is_debt': transaction.isDebt ? 1 : 0,
      'debt_amount': transaction.debtAmount,
      'debt_paid_amount': transaction.debtPaidAmount,
      'debt_status': transaction.debtStatus,
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
      isDebt: map['is_debt'] == 1,
      debtAmount: map['debt_amount']?.toDouble() ?? 0.0,
      debtPaidAmount: map['debt_paid_amount']?.toDouble() ?? 0.0,
      debtStatus: map['debt_status'] ?? 'paid',
      paymentDueDate: map['payment_due_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['payment_due_date'])
          : null,
      branchId: map['branch_id'] ?? 'MAIN',
      invoiceNumber: map['invoice_number'],
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
      case 'PaymentMethod.debt':
        return app_transaction.PaymentMethod.debt;
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

  // Helper methods for Technician
  Map<String, dynamic> _technicianToMap(Technician technician) {
    return {
      'id': technician.id,
      'name': technician.name,
      'phone': technician.phone,
      'email': technician.email,
      'specialization': technician.specialization,
      'experience_years': technician.experienceYears,
      'status': technician.status.toString(),
      'created_at': technician.createdAt.millisecondsSinceEpoch,
      'last_active': technician.lastActive?.millisecondsSinceEpoch,
      'rating': technician.rating,
      'total_services': technician.totalServices,
      'salary_type': technician.salaryType.toString(),
      'salary_amount': technician.salaryAmount,
    };
  }

  Technician _mapToTechnician(Map<String, dynamic> map) {
    return Technician(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      specialization: map['specialization'],
      experienceYears: map['experience_years'],
      status: _parseTechnicianStatus(map['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      lastActive: map['last_active'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_active'])
          : null,
      rating: map['rating']?.toDouble() ?? 0.0,
      totalServices: map['total_services'] ?? 0,
      salaryType: _parseSalaryType(map['salary_type']),
      salaryAmount: map['salary_amount']?.toDouble() ?? 0.0,
    );
  }

  // Helper methods for Booking
  Map<String, dynamic> _bookingToMap(Booking booking) {
    return {
      'id': booking.id,
      'customer_name': booking.customerName,
      'phone_number': booking.phoneNumber,
      'email': booking.email,
      'vehicle_type': booking.vehicleType,
      'license_plate': booking.licensePlate,
      'service_type': booking.serviceType,
      'preferred_date': booking.preferredDate.millisecondsSinceEpoch,
      'preferred_time': booking.preferredTime,
      'status': booking.status.toString(),
      'created_at': booking.createdAt.millisecondsSinceEpoch,
      'confirmed_at': booking.confirmedAt?.millisecondsSinceEpoch,
      'completed_at': booking.completedAt?.millisecondsSinceEpoch,
      'technician_id': booking.technicianId,
      'estimated_duration': booking.estimatedDuration,
      'notes': booking.notes,
      'reminder_sent': booking.reminderSent ? 1 : 0,
    };
  }

  Booking _mapToBooking(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      customerName: map['customer_name'],
      phoneNumber: map['phone_number'],
      email: map['email'],
      vehicleType: map['vehicle_type'],
      licensePlate: map['license_plate'],
      serviceType: map['service_type'],
      preferredDate: DateTime.fromMillisecondsSinceEpoch(map['preferred_date']),
      preferredTime: map['preferred_time'],
      status: _parseBookingStatus(map['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      confirmedAt: map['confirmed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['confirmed_at'])
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'])
          : null,
      technicianId: map['technician_id'],
      estimatedDuration: map['estimated_duration'],
      notes: map['notes'],
      reminderSent: map['reminder_sent'] == 1,
    );
  }

  // Helper methods for Notification
  Map<String, dynamic> _notificationToMap(
    app_notification.Notification notification,
  ) {
    return {
      'id': notification.id,
      'type': notification.type.toString(),
      'title': notification.title,
      'message': notification.message,
      'recipient_type': notification.recipientType.toString(),
      'recipient_id': notification.recipientId,
      'status': notification.status.toString(),
      'created_at': notification.createdAt.millisecondsSinceEpoch,
      'sent_at': notification.sentAt?.millisecondsSinceEpoch,
      'read_at': notification.readAt?.millisecondsSinceEpoch,
      'related_id': notification.relatedId,
      'priority': notification.priority.toString(),
    };
  }

  app_notification.Notification _mapToNotification(Map<String, dynamic> map) {
    return app_notification.Notification(
      id: map['id'],
      type: _parseNotificationType(map['type']),
      title: map['title'],
      message: map['message'],
      recipientType: _parseNotificationRecipientType(map['recipient_type']),
      recipientId: map['recipient_id'],
      status: _parseNotificationStatus(map['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      sentAt: map['sent_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['sent_at'])
          : null,
      readAt: map['read_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['read_at'])
          : null,
      relatedId: map['related_id'],
      priority: _parseNotificationPriority(map['priority']),
    );
  }

  // Parser methods for enums
  TechnicianStatus _parseTechnicianStatus(String status) {
    switch (status) {
      case 'TechnicianStatus.active':
        return TechnicianStatus.active;
      case 'TechnicianStatus.inactive':
        return TechnicianStatus.inactive;
      case 'TechnicianStatus.onLeave':
        return TechnicianStatus.onLeave;
      default:
        return TechnicianStatus.active;
    }
  }

  SalaryType _parseSalaryType(String type) {
    switch (type) {
      case 'SalaryType.daily':
        return SalaryType.daily;
      case 'SalaryType.monthly':
        return SalaryType.monthly;
      case 'SalaryType.commission':
        return SalaryType.commission;
      default:
        return SalaryType.daily;
    }
  }

  BookingStatus _parseBookingStatus(String status) {
    switch (status) {
      case 'BookingStatus.pending':
        return BookingStatus.pending;
      case 'BookingStatus.confirmed':
        return BookingStatus.confirmed;
      case 'BookingStatus.inProgress':
        return BookingStatus.inProgress;
      case 'BookingStatus.completed':
        return BookingStatus.completed;
      case 'BookingStatus.cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  app_notification.NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'NotificationType.serviceReminder':
        return app_notification.NotificationType.serviceReminder;
      case 'NotificationType.bookingConfirmation':
        return app_notification.NotificationType.bookingConfirmation;
      case 'NotificationType.paymentDue':
        return app_notification.NotificationType.paymentDue;
      case 'NotificationType.stockAlert':
        return app_notification.NotificationType.stockAlert;
      case 'NotificationType.systemAlert':
        return app_notification.NotificationType.systemAlert;
      default:
        return app_notification.NotificationType.systemAlert;
    }
  }

  app_notification.NotificationRecipientType _parseNotificationRecipientType(
    String type,
  ) {
    switch (type) {
      case 'NotificationRecipientType.customer':
        return app_notification.NotificationRecipientType.customer;
      case 'NotificationRecipientType.technician':
        return app_notification.NotificationRecipientType.technician;
      case 'NotificationRecipientType.manager':
        return app_notification.NotificationRecipientType.manager;
      case 'NotificationRecipientType.system':
        return app_notification.NotificationRecipientType.system;
      default:
        return app_notification.NotificationRecipientType.system;
    }
  }

  app_notification.NotificationStatus _parseNotificationStatus(String status) {
    switch (status) {
      case 'NotificationStatus.pending':
        return app_notification.NotificationStatus.pending;
      case 'NotificationStatus.sent':
        return app_notification.NotificationStatus.sent;
      case 'NotificationStatus.read':
        return app_notification.NotificationStatus.read;
      case 'NotificationStatus.failed':
        return app_notification.NotificationStatus.failed;
      default:
        return app_notification.NotificationStatus.pending;
    }
  }

  app_notification.NotificationPriority _parseNotificationPriority(
    String priority,
  ) {
    switch (priority) {
      case 'NotificationPriority.low':
        return app_notification.NotificationPriority.low;
      case 'NotificationPriority.medium':
        return app_notification.NotificationPriority.medium;
      case 'NotificationPriority.high':
        return app_notification.NotificationPriority.high;
      case 'NotificationPriority.urgent':
        return app_notification.NotificationPriority.urgent;
      default:
        return app_notification.NotificationPriority.medium;
    }
  }

  Future close() async {
    if (_database != null) {
      print('Closing database...');
      await _database!.close();
      _database = null;
      print('Database closed successfully');
    }
  }

  // Method untuk cek koneksi database
  Future<bool> isDatabaseOpen() async {
    try {
      final db = await database;
      await db.execute('SELECT 1');
      return true;
    } catch (e) {
      print('Database connection check failed: $e');
      return false;
    }
  }

  // Method untuk cek path database
  Future<String?> getDatabasePath() async {
    try {
      Directory? appDir;
      try {
        if (Platform.isAndroid || Platform.isIOS) {
          appDir = await getApplicationDocumentsDirectory();
        } else {
          appDir = Directory.current;
        }
      } catch (e) {
        appDir = Directory.current;
      }
      return join(appDir.path, 'workshop_manager_v2.db');
    } catch (e) {
      print('Error getting database path: $e');
      return null;
    }
  }

  // Method untuk reset database jika terjadi error
  Future<void> resetDatabase() async {
    try {
      print('Resetting database...');
      await close();

      // Hapus file database
      final dbPath = await getDatabasePath();
      if (dbPath != null) {
        final file = File(dbPath);
        if (file.existsSync()) {
          await file.delete();
          print('Database file deleted');
        }
      }

      // Reset database instance
      _database = null;
      print('Database reset completed');
    } catch (e) {
      print('Error resetting database: $e');
    }
  }
}
