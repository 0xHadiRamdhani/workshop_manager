/// Skema tabel Supabase untuk Workshop Manager
/// File ini berisi definisi tabel dan relasi untuk semua data

class SupabaseSchema {
  // Nama tabel
  static const String products = 'products';
  static const String transactions = 'transactions';
  static const String bookings = 'bookings';
  static const String technicians = 'technicians';
  static const String notifications = 'notifications';
  static const String vehicles = 'vehicles';
  static const String serviceItems = 'service_items';
  static const String debtPayments = 'debt_payments';

  // Skema tabel Products
  static const String createProductsTable = '''
    CREATE TABLE IF NOT EXISTS products (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      price REAL NOT NULL,
      stock INTEGER NOT NULL DEFAULT 0,
      description TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    -- Index untuk pencarian dan filter
    CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
    CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
    CREATE INDEX IF NOT EXISTS idx_products_stock ON products(stock);
  ''';

  // Skema tabel Technicians
  static const String createTechniciansTable = '''
    CREATE TABLE IF NOT EXISTS technicians (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      specialization TEXT,
      phone TEXT,
      email TEXT,
      is_available BOOLEAN DEFAULT true,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    CREATE INDEX IF NOT EXISTS idx_technicians_specialization ON technicians(specialization);
    CREATE INDEX IF NOT EXISTS idx_technicians_available ON technicians(is_available);
  ''';

  // Skema tabel Vehicles
  static const String createVehiclesTable = '''
    CREATE TABLE IF NOT EXISTS vehicles (
      id TEXT PRIMARY KEY,
      owner_name TEXT NOT NULL,
      phone TEXT,
      vehicle_type TEXT NOT NULL,
      brand TEXT NOT NULL,
      model TEXT NOT NULL,
      year INTEGER,
      license_plate TEXT UNIQUE,
      color TEXT,
      notes TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    CREATE INDEX IF NOT EXISTS idx_vehicles_owner ON vehicles(owner_name);
    CREATE INDEX IF NOT EXISTS idx_vehicles_plate ON vehicles(license_plate);
  ''';

  // Skema tabel Transactions
  static const String createTransactionsTable = '''
    CREATE TABLE IF NOT EXISTS transactions (
      id TEXT PRIMARY KEY,
      vehicle_id TEXT REFERENCES vehicles(id),
      customer_name TEXT NOT NULL,
      total_amount REAL NOT NULL,
      payment_method TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      paid_at TIMESTAMP WITH TIME ZONE,
      cash_amount REAL,
      change_amount REAL,
      is_debt BOOLEAN DEFAULT false,
      debt_amount REAL DEFAULT 0,
      debt_paid_amount REAL DEFAULT 0,
      debt_status TEXT DEFAULT 'none',
      payment_due_date TIMESTAMP WITH TIME ZONE,
      notes TEXT,
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    CREATE INDEX IF NOT EXISTS idx_transactions_vehicle ON transactions(vehicle_id);
    CREATE INDEX IF NOT EXISTS idx_transactions_customer ON transactions(customer_name);
    CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(status);
    CREATE INDEX IF NOT EXISTS idx_transactions_payment_method ON transactions(payment_method);
    CREATE INDEX IF NOT EXISTS idx_transactions_debt ON transactions(is_debt);
    CREATE INDEX IF NOT EXISTS idx_transactions_created ON transactions(created_at);
  ''';

  // Skema tabel ServiceItems (detail transaksi)
  static const String createServiceItemsTable = '''
    CREATE TABLE IF NOT EXISTS service_items (
      id TEXT PRIMARY KEY,
      transaction_id TEXT NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
      product_id TEXT REFERENCES products(id),
      name TEXT NOT NULL,
      price REAL NOT NULL,
      quantity INTEGER NOT NULL DEFAULT 1,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    CREATE INDEX IF NOT EXISTS idx_service_items_transaction ON service_items(transaction_id);
    CREATE INDEX IF NOT EXISTS idx_service_items_product ON service_items(product_id);
  ''';

  // Skema tabel Bookings
  static const String createBookingsTable = '''
    CREATE TABLE IF NOT EXISTS bookings (
      id TEXT PRIMARY KEY,
      vehicle_id TEXT NOT NULL REFERENCES vehicles(id),
      technician_id TEXT REFERENCES technicians(id),
      customer_name TEXT NOT NULL,
      service_type TEXT NOT NULL,
      booking_date TIMESTAMP WITH TIME ZONE NOT NULL,
      time_slot TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending',
      notes TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    CREATE INDEX IF NOT EXISTS idx_bookings_vehicle ON bookings(vehicle_id);
    CREATE INDEX IF NOT EXISTS idx_bookings_technician ON bookings(technician_id);
    CREATE INDEX IF NOT EXISTS idx_bookings_date ON bookings(booking_date);
    CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
  ''';

  // Skema tabel Notifications
  static const String createNotificationsTable = '''
    CREATE TABLE IF NOT EXISTS notifications (
      id TEXT PRIMARY KEY,
      type TEXT NOT NULL,
      title TEXT NOT NULL,
      message TEXT NOT NULL,
      is_read BOOLEAN DEFAULT false,
      related_id TEXT,
      related_type TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      read_at TIMESTAMP WITH TIME ZONE
    );

    CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);
    CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read);
    CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at);
  ''';

  // Skema tabel DebtPayments (cicilan hutang)
  static const String createDebtPaymentsTable = '''
    CREATE TABLE IF NOT EXISTS debt_payments (
      id TEXT PRIMARY KEY,
      transaction_id TEXT NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
      amount REAL NOT NULL,
      payment_method TEXT NOT NULL,
      paid_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      notes TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    CREATE INDEX IF NOT EXISTS idx_debt_payments_transaction ON debt_payments(transaction_id);
    CREATE INDEX IF NOT EXISTS idx_debt_payments_date ON debt_payments(paid_at);
  ''';

  // Fungsi untuk membuat semua tabel
  static Future<void> createAllTables(supabase) async {
    try {
      await supabase.rpc('exec_sql', params: {'sql': createProductsTable});
      await supabase.rpc('exec_sql', params: {'sql': createTechniciansTable});
      await supabase.rpc('exec_sql', params: {'sql': createVehiclesTable});
      await supabase.rpc('exec_sql', params: {'sql': createTransactionsTable});
      await supabase.rpc('exec_sql', params: {'sql': createServiceItemsTable});
      await supabase.rpc('exec_sql', params: {'sql': createBookingsTable});
      await supabase.rpc('exec_sql', params: {'sql': createNotificationsTable});
      await supabase.rpc('exec_sql', params: {'sql': createDebtPaymentsTable});
    } catch (e) {
      print('Error creating tables: $e');
      rethrow;
    }
  }

  // Policies RLS (Row Level Security)
  static const String enableRLS = '''
    ALTER TABLE products ENABLE ROW LEVEL SECURITY;
    ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
    ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
    ALTER TABLE technicians ENABLE ROW LEVEL SECURITY;
    ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
    ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
    ALTER TABLE service_items ENABLE ROW LEVEL SECURITY;
    ALTER TABLE debt_payments ENABLE ROW LEVEL SECURITY;
  ''';

  // Sample data untuk testing
  static const List<Map<String, dynamic>> sampleProducts = [
    {
      'id': 'P001',
      'name': 'Oli Mesin 10W-40',
      'category': 'Oli',
      'price': 85000,
      'stock': 50,
      'description': 'Oli mesin sintetik untuk kendaraan',
    },
    {
      'id': 'P002',
      'name': 'Kampas Rem Depan',
      'category': 'Rem',
      'price': 180000,
      'stock': 30,
      'description': 'Kampas rem berkualitas tinggi',
    },
    {
      'id': 'P003',
      'name': 'Filter Udara',
      'category': 'Mesin',
      'price': 45000,
      'stock': 25,
      'description': 'Filter udara untuk mesin',
    },
  ];

  static const List<Map<String, dynamic>> sampleTechnicians = [
    {
      'id': 'T001',
      'name': 'Budi Santoso',
      'specialization': 'Mesin & Transmisi',
      'phone': '081234567890',
      'email': 'budi@workshop.com',
      'is_available': true,
    },
    {
      'id': 'T002',
      'name': 'Siti Nurhaliza',
      'specialization': 'Listrik & AC',
      'phone': '082345678901',
      'email': 'siti@workshop.com',
      'is_available': true,
    },
  ];
}
