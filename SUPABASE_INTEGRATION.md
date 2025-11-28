# Integrasi Supabase ke Workshop Manager

## Overview
Aplikasi Workshop Manager sekarang mendukung database cloud Supabase untuk sinkronisasi data secara real-time. Integrasi ini memungkinkan:

- **Sinkronisasi otomatis** data antara lokal dan cloud
- **Akses data real-time** dari berbagai perangkat
- **Backup otomatis** data ke cloud
- **Migrasi bertahap** dari SQLite lokal ke Supabase

## Fitur Utama

### 1. Mode Operasi Database
Aplikasi mendukung 3 mode operasi database:

#### a. **Local Mode**
- Hanya menggunakan SQLite lokal
- Cocok untuk penggunaan offline
- Tidak memerlukan koneksi internet

#### b. **Supabase Mode**
- Hanya menggunakan database cloud Supabase
- Memerlukan koneksi internet
- Data tersedia di semua perangkat

#### c. **Hybrid Mode** (Recommended)
- Menggabungkan SQLite lokal dan Supabase
- Sinkronisasi otomatis setiap 5 menit
- Fallback ke lokal jika Supabase tidak tersedia
- Prioritas pembacaan: Supabase → Lokal

### 2. Konfigurasi Supabase
```dart
// Konfigurasi di main.dart
await Supabase.initialize(
  url: 'https://wsutnrbmgqhrtwggpvhj.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndzdXRucmJtZ3FocnR3Z2dwdmhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2MDI2NDAsImV4cCI6MjA0ODE3ODY0MH0.0aMt1y1iP4qPQdIgQGz5mGqI7_0vVf3B7Cq8XsRt3L0',
);
```

### 3. Struktur Database Supabase

#### Tabel Products
```sql
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  price REAL NOT NULL,
  stock INTEGER NOT NULL,
  description TEXT,
  created_at BIGINT NOT NULL
);
```

#### Tabel Vehicles
```sql
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
  is_paid BOOLEAN DEFAULT FALSE
);
```

#### Tabel Technicians
```sql
CREATE TABLE technicians (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  specialization TEXT,
  experience_years INTEGER DEFAULT 0,
  status TEXT DEFAULT 'active',
  created_at BIGINT NOT NULL,
  last_active BIGINT,
  rating REAL DEFAULT 0,
  total_services INTEGER DEFAULT 0,
  salary_type TEXT DEFAULT 'daily',
  salary_amount REAL DEFAULT 0
);
```

#### Tabel Transactions
```sql
CREATE TABLE transactions (
  id TEXT PRIMARY KEY,
  vehicle_id TEXT NOT NULL,
  customer_name TEXT NOT NULL,
  services TEXT NOT NULL,
  total_amount REAL NOT NULL,
  payment_method TEXT NOT NULL,
  status TEXT NOT NULL,
  created_at BIGINT NOT NULL,
  paid_at BIGINT,
  cash_amount REAL,
  change_amount REAL,
  branch_id TEXT DEFAULT 'MAIN',
  invoice_number TEXT,
  payment_due_date BIGINT,
  is_debt BOOLEAN DEFAULT FALSE,
  debt_amount REAL DEFAULT 0,
  debt_paid_amount REAL DEFAULT 0,
  debt_status TEXT DEFAULT 'paid'
);
```

#### Tabel Bookings
```sql
CREATE TABLE bookings (
  id TEXT PRIMARY KEY,
  customer_name TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  email TEXT,
  vehicle_type TEXT NOT NULL,
  license_plate TEXT,
  service_type TEXT NOT NULL,
  preferred_date BIGINT NOT NULL,
  preferred_time TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  created_at BIGINT NOT NULL,
  confirmed_at BIGINT,
  completed_at BIGINT,
  technician_id TEXT,
  estimated_duration INTEGER,
  notes TEXT,
  reminder_sent BOOLEAN DEFAULT FALSE
);
```

#### Tabel Notifications
```sql
CREATE TABLE notifications (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  recipient_type TEXT NOT NULL,
  recipient_id TEXT,
  status TEXT DEFAULT 'pending',
  created_at BIGINT NOT NULL,
  sent_at BIGINT,
  read_at BIGINT,
  related_id TEXT,
  priority TEXT DEFAULT 'medium'
);
```

## Cara Penggunaan

### 1. Akses Pengaturan Supabase
- Buka menu drawer (☰) di kiri atas
- Pilih "Pengaturan Supabase"
- Pilih mode database yang diinginkan
- Klik "Sinkronkan Sekarang" untuk sync manual

### 2. Mode Hybrid (Rekomendasi)
Mode hybrid adalah mode default yang direkomendasikan karena:
- **Keandalan**: Data tetap tersedia saat offline
- **Sinkronisasi**: Data otomatis sync ke cloud
- **Performa**: Pembacaan data cepat dari lokal
- **Backup**: Data otomatis tersimpan di cloud

### 3. Migrasi Data
Untuk migrasi dari lokal ke Supabase:
1. Pastikan koneksi internet aktif
2. Pilih mode "Hybrid"
3. Klik "Sinkronkan Sekarang"
4. Tunggu proses sinkronisasi selesai
5. Setelah selesai, bisa pindah ke mode "Supabase" jika diinginkan

## Struktur Kode

### 1. SupabaseService (`lib/services/supabase_service.dart`)
Service utama untuk operasi CRUD ke Supabase:
- `getProducts()` - Mendapatkan semua produk
- `insertProduct()` - Menambah produk baru
- `updateProduct()` - Update produk existing
- `deleteProduct()` - Hapus produk
- Dan method serupa untuk semua tabel lainnya

### 2. SupabaseDatabaseHelper (`lib/database/supabase_database_helper.dart`)
Wrapper yang menggabungkan SQLite lokal dan Supabase:
- Mode operasi: 'local', 'supabase', 'hybrid'
- Sinkronisasi otomatis setiap 5 menit
- Fallback mechanism
- Prioritas pembacaan: Supabase → Lokal

### 3. SupabaseSettingsScreen (`lib/screens/supabase_settings_screen.dart`)
Screen untuk konfigurasi Supabase:
- Pilihan mode database
- Tombol sinkronisasi manual
- Status koneksi
- Informasi konfigurasi

## Keamanan

### 1. API Key Security
- Menggunakan anon key untuk akses publik
- Row Level Security (RLS) diaktifkan di Supabase
- Setiap tabel memiliki kebijakan akses yang sesuai

### 2. Data Encryption
- Koneksi HTTPS untuk semua komunikasi
- Data sensitif dienkripsi di client side jika diperlukan

### 3. Akses Control
- RLS policies untuk membatasi akses data
- User authentication bisa ditambahkan di masa depan

## Troubleshooting

### 1. Koneksi Gagal
**Masalah**: Tidak bisa konek ke Supabase
**Solusi**: 
- Cek koneksi internet
- Verifikasi URL dan API key
- Cek status Supabase di dashboard

### 2. Sinkronisasi Gagal
**Masalah**: Data tidak sinkron
**Solusi**:
- Cek mode database (harus hybrid)
- Pastikan koneksi internet aktif
- Cek log error di console
- Coba sinkronisasi manual

### 3. Data Tidak Muncul
**Masalah**: Data tidak tampil di aplikasi
**Solusi**:
- Cek mode database yang aktif
- Refresh data dengan pull-to-refresh
- Cek koneksi internet untuk mode supabase/hybrid
- Cek log error untuk detail masalah

## Performance Optimization

### 1. Caching Strategy
- Data lokal sebagai cache utama
- Update incremental untuk sinkronisasi
- Lazy loading untuk data besar

### 2. Network Optimization
- Batch operations untuk multiple inserts
- Pagination untuk queries besar
- Connection pooling di Supabase

### 3. Database Indexing
- Index pada kolom yang sering diquery
- Primary key yang optimal
- Query optimization

## Future Enhancements

### 1. Real-time Features
- Subscribe ke perubahan data real-time
- Push notifications untuk update
- Live dashboard updates

### 2. Advanced Sync
- Conflict resolution
- Delta sync untuk efisiensi
- Offline-first architecture

### 3. Security Enhancements
- User authentication
- Role-based access control
- Data encryption at rest

## Support & Maintenance

### 1. Monitoring
- Log sinkronisasi di console
- Error tracking dan reporting
- Performance metrics

### 2. Backup Strategy
- Backup otomatis ke Supabase
- Export data untuk backup lokal
- Recovery procedures

### 3. Updates
- Update Supabase schema jika diperlukan
- Migrasi data untuk versi baru
- Compatibility testing

## Referensi

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Database Best Practices](https://supabase.com/docs/guides/database)

## Kontak
Untuk bantuan atau pertanyaan, hubungi:
- Email: hadiramdhani@gmail.com
- Issue Tracker: [GitHub Repository](https://github.com/hadiramdhani/workshop-manager)