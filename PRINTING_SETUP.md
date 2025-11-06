# Setup Pencetakan Struk

## Fitur Pencetakan Struk
Aplikasi Workshop Manager kini dilengkapi dengan fitur pencetakan struk fisik untuk transaksi.

## Cara Menggunakan

### Setup Printer (Pertama Kali)
1. Buka halaman **Dashboard**
2. Klik tombol **Printer** di pojok kanan atas
3. Klik **"Scan"** untuk mencari printer bluetooth yang tersedia
4. Pilih printer dari daftar dan klik **"Hubungkan"**
5. Klik **"Test Print"** untuk memastikan koneksi berhasil

### Mencetak Struk
1. Buka halaman **Histori Transaksi**
2. Klik tombol **"Cetak Struk"** pada transaksi yang ingin dicetak
3. Pilih **"Cetak via Bluetooth"**
4. Jika printer sudah terhubung, struk akan langsung dicetak
5. Jika belum terhubung, pilih printer dari daftar yang muncul
6. Struk akan dicetak dengan format lengkap

## Persiapan Printer

### Printer Bluetooth Thermal
1. Pastikan printer thermal bluetooth dalam keadaan menyala
2. Aktifkan bluetooth di perangkat Android
3. Pair printer bluetooth dengan perangkat
4. Printer akan muncul dalam daftar pilihan saat mencetak

### Format Struk
Struk akan mencetak informasi berikut:
- Nama bengkel, alamat, dan nomor telepon
- ID transaksi dan tanggal
- Nama pelanggan dan kendaraan
- Detail layanan yang dipesan
- Total pembayaran
- Metode pembayaran
- Uang cash dan kembalian (jika ada)
- Pesan terima kasih

## Konfigurasi untuk Developer

### Dependensi
Plugin yang digunakan:
- `blue_thermal_printer`: Untuk pencetakan bluetooth

### Permission Android
Permission berikut telah ditambahkan di `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### Service Pencetakan
File: `lib/services/print_service.dart`
- Method `printReceipt()`: Untuk mencetak struk
- Method `formatReceipt()`: Untuk memformat teks struk
- Method `scanPrinters()`: Untuk scan printer yang tersedia
- Method `connectPrinter()`: Untuk menghubungkan ke printer

## Halaman Pengaturan Printer
File: `lib/screens/printer_settings_screen.dart`
Fitur yang tersedia:
- **Scan Printer**: Mencari printer bluetooth yang tersedia
- **Connect/Disconnect**: Menghubungkan/memutuskan printer
- **Test Print**: Mencetak halaman test untuk memastikan koneksi
- **Status Printer**: Menampilkan printer yang terhubung
- **Daftar Printer**: Menampilkan semua printer yang tersedia

## Implementasi Lanjutan
Untuk implementasi pencetakan yang lebih lengkap, dapat menambahkan:
1. Plugin pencetakan USB untuk printer thermal USB
2. Plugin pencetakan network untuk printer WiFi/Ethernet
3. Preview struk sebelum mencetak
4. Format struk yang dapat dikustomisasi
5. Multiple printer support
6. Printer profiles untuk berbagai jenis printer

## Troubleshooting
- Jika printer tidak terdeteksi, pastikan bluetooth aktif dan printer dalam mode pairing
- Untuk Android 12+, pastikan location permission diizinkan
- Jika pencetakan gagal, coba restart printer dan perangkat