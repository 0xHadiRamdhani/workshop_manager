/// Panduan manual untuk setup tabel di Supabase Dashboard
/// Karena terdapat masalah dengan API key, user perlu setup manual melalui dashboard Supabase

class ManualTableSetup {
  /// Instruksi lengkap untuk membuat tabel di Supabase Dashboard
  static const String setupInstructions = '''
🚀 PANDUAN SETUP TABEL SUPABASE MANUAL

📋 LANGKAH-LANGKAH:

1️⃣ BUKA DASHBOARD SUPABASE
   • Buka https://app.supabase.com
   • Login dengan akun Anda
   • Pilih project "workshop-manager" atau buat project baru

2️⃣ BUKA SQL EDITOR
   • Klik menu "SQL Editor" di sidebar
   • Klik "New query" untuk membuat query baru

3️⃣ COPY & PASTE SQL BERIKUT:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TABEL PRODUCTS
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  price REAL NOT NULL,
  stock INTEGER NOT NULL DEFAULT 0,
  description TEXT,
  image_url TEXT,
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL
);

-- Index untuk products
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_stock ON products(stock);

-- TABEL TECHNICIANS
CREATE TABLE technicians (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  specialization TEXT NOT NULL,
  experience_years INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL,
  created_at BIGINT NOT NULL,
  last_active BIGINT,
  rating REAL DEFAULT 0,
  total_services INTEGER DEFAULT 0,
  salary_type TEXT,
  salary_amount REAL,
  updated_at BIGINT NOT NULL
);

-- Index untuk technicians
CREATE INDEX idx_technicians_specialization ON technicians(specialization);
CREATE INDEX idx_technicians_status ON technicians(status);

-- TABEL VEHICLES
CREATE TABLE vehicles (
  id TEXT PRIMARY KEY,
  customer_name TEXT NOT NULL,
  vehicle_type TEXT NOT NULL,
  license_plate TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  problem_description TEXT NOT NULL,
  status TEXT NOT NULL,
  created_at BIGINT NOT NULL,
  estimated_completion BIGINT,
  estimated_cost REAL,
  payment_method TEXT,
  actual_cost REAL,
  is_paid BOOLEAN DEFAULT false,
  updated_at BIGINT NOT NULL
);

-- Index untuk vehicles
CREATE INDEX idx_vehicles_customer ON vehicles(customer_name);
CREATE INDEX idx_vehicles_plate ON vehicles(license_plate);
CREATE INDEX idx_vehicles_status ON vehicles(status);

-- TABEL TRANSACTIONS
CREATE TABLE transactions (
  id TEXT PRIMARY KEY,
  vehicle_id TEXT REFERENCES vehicles(id),
  customer_name TEXT NOT NULL,
  services TEXT NOT NULL,
  total_amount REAL NOT NULL,
  payment_method TEXT NOT NULL,
  status TEXT NOT NULL,
  created_at BIGINT NOT NULL,
  paid_at BIGINT,
  cash_amount REAL,
  change_amount REAL,
  is_debt BOOLEAN DEFAULT false,
  debt_amount REAL DEFAULT 0,
  debt_paid_amount REAL DEFAULT 0,
  debt_status TEXT DEFAULT 'paid',
  payment_due_date BIGINT,
  branch_id TEXT DEFAULT 'MAIN',
  invoice_number TEXT,
  updated_at BIGINT NOT NULL
);

-- Index untuk transactions
CREATE INDEX idx_transactions_vehicle ON transactions(vehicle_id);
CREATE INDEX idx_transactions_customer ON transactions(customer_name);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_payment_method ON transactions(payment_method);
CREATE INDEX idx_transactions_debt ON transactions(is_debt);
CREATE INDEX idx_transactions_created ON transactions(created_at);

-- TABEL SERVICE_ITEMS
CREATE TABLE service_items (
  id TEXT PRIMARY KEY,
  transaction_id TEXT NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
  product_id TEXT REFERENCES products(id),
  name TEXT NOT NULL,
  price REAL NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at BIGINT NOT NULL
);

-- Index untuk service_items
CREATE INDEX idx_service_items_transaction ON service_items(transaction_id);
CREATE INDEX idx_service_items_product ON service_items(product_id);

-- TABEL BOOKINGS
CREATE TABLE bookings (
  id TEXT PRIMARY KEY,
  customer_name TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  email TEXT,
  vehicle_type TEXT NOT NULL,
  license_plate TEXT NOT NULL,
  service_type TEXT NOT NULL,
  preferred_date BIGINT NOT NULL,
  preferred_time TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  notes TEXT,
  created_at BIGINT NOT NULL,
  confirmed_at BIGINT,
  completed_at BIGINT,
  technician_id TEXT,
  estimated_duration INTEGER,
  reminder_sent BOOLEAN DEFAULT false,
  updated_at BIGINT NOT NULL
);

-- Index untuk bookings
CREATE INDEX idx_bookings_customer ON bookings(customer_name);
CREATE INDEX idx_bookings_date ON bookings(preferred_date);
CREATE INDEX idx_bookings_status ON bookings(status);

-- TABEL NOTIFICATIONS
CREATE TABLE notifications (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  recipient_type TEXT NOT NULL,
  recipient_id TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  related_id TEXT,
  related_type TEXT,
  priority TEXT NOT NULL DEFAULT 'medium',
  created_at BIGINT NOT NULL,
  sent_at BIGINT,
  read_at BIGINT
);

-- Index untuk notifications
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_notifications_created ON notifications(created_at);

-- TABEL DEBT_PAYMENTS
CREATE TABLE debt_payments (
  id TEXT PRIMARY KEY,
  transaction_id TEXT NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
  amount REAL NOT NULL,
  payment_method TEXT NOT NULL,
  paid_at BIGINT NOT NULL,
  notes TEXT,
  created_at BIGINT NOT NULL
);

-- Index untuk debt_payments
CREATE INDEX idx_debt_payments_transaction ON debt_payments(transaction_id);
CREATE INDEX idx_debt_payments_date ON debt_payments(paid_at);
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

4️⃣ JALANKAN QUERY
   • Klik tombol "RUN" atau tekan Ctrl+Enter
   • Tunggu hingga semua query berhasil dieksekusi

5️⃣ VERIFIKASI
   • Klik menu "Table Editor" di sidebar
   • Pastikan semua tabel terlihat: products, technicians, vehicles, transactions, service_items, bookings, notifications, debt_payments

✅ SELESAI! Tabel siap digunakan.

💡 TIPS:
• Jika ada error, cek sintaks SQL dan pastikan tidak ada tabel dengan nama yang sama
• Untuk data sample, gunakan tombol "Isi Data Contoh" di aplikasi
• API key error akan teratasi setelah tabel dibuat manual
''';

  /// Data sample yang bisa dimasukkan setelah tabel dibuat
  static List<Map<String, dynamic>> getSampleProducts() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      {
        'id': 'P001_${now}',
        'name': 'Oli Mesin 10W-40',
        'category': 'Oli & Pelumas',
        'price': 85000,
        'stock': 50,
        'description': 'Oli mesin sintetik untuk kendaraan',
        'image_url': null,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'P002_${now}',
        'name': 'Kampas Rem Depan',
        'category': 'Rem',
        'price': 180000,
        'stock': 30,
        'description': 'Kampas rem berkualitas tinggi',
        'image_url': null,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'P003_${now}',
        'name': 'Filter Udara',
        'category': 'Filter',
        'price': 45000,
        'stock': 25,
        'description': 'Filter udara untuk mesin',
        'image_url': null,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
    ];
  }

  static List<Map<String, dynamic>> getSampleVehicles() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      {
        'id': 'V001_${now}',
        'customer_name': 'Budi Santoso',
        'vehicle_type': 'Honda Beat',
        'license_plate': 'B 1234 ABC',
        'phone_number': '081234567890',
        'problem_description': 'Mesin berisik, perlu service rutin',
        'status': 'inProgress',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'estimated_completion': null,
        'estimated_cost': null,
        'payment_method': null,
        'actual_cost': null,
        'is_paid': false,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'V002_${now}',
        'customer_name': 'Siti Nurhaliza',
        'vehicle_type': 'Yamaha Mio',
        'license_plate': 'B 5678 DEF',
        'phone_number': '082345678901',
        'problem_description': 'Rem depan bunyi, minta dicek',
        'status': 'completed',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'estimated_completion': null,
        'estimated_cost': null,
        'payment_method': null,
        'actual_cost': null,
        'is_paid': false,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
    ];
  }

  static List<Map<String, dynamic>> getSampleTransactions() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      {
        'id': 'T001_${now}',
        'vehicle_id': 'V001_${now}',
        'customer_name': 'Budi Santoso',
        'services': 'Service Ringan|75000|1,Oli Mesin 1L|85000|1',
        'total_amount': 160000,
        'payment_method': 'cash',
        'status': 'paid',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'paid_at': DateTime.now().millisecondsSinceEpoch,
        'cash_amount': 160000,
        'change_amount': 0,
        'is_debt': false,
        'debt_amount': 0,
        'debt_paid_amount': 0,
        'debt_status': 'paid',
        'payment_due_date': null,
        'branch_id': 'MAIN',
        'invoice_number': 'INV001',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'T002_${now}',
        'vehicle_id': 'V002_${now}',
        'customer_name': 'Siti Nurhaliza',
        'services': 'Kampas Rem Depan|120000|1,Ganti Ban|50000|1',
        'total_amount': 170000,
        'payment_method': 'cash',
        'status': 'paid',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'paid_at': DateTime.now().millisecondsSinceEpoch,
        'cash_amount': 170000,
        'change_amount': 0,
        'is_debt': false,
        'debt_amount': 0,
        'debt_paid_amount': 0,
        'debt_status': 'paid',
        'payment_due_date': null,
        'branch_id': 'MAIN',
        'invoice_number': 'INV002',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
    ];
  }
}
