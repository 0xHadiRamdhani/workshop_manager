# Workshop Manager & Kasir

Aplikasi manajemen workshop dan kasir untuk bengkel dengan desain bergaya iOS minimalis dan bercahaya. Dikembangkan menggunakan Flutter untuk platform iOS.

## Fitur Utama

### 🏠 Dashboard
- Ringkasan harian kendaraan aktif, pendapatan, dan transaksi
- Tampilan kendaraan terbaru dengan status real-time
- Tampilan transaksi terbaru dengan status pembayaran

### 🔧 Workshop Management
- Daftar kendaraan dengan filter berdasarkan status (Menunggu, Proses, Selesai)
- Detail kendaraan lengkap (pelanggan, kendaraan, keluhan, estimasi)
- Update status kendaraan secara real-time
- Tambah kendaraan baru

### 💰 Kasir & Transaksi
- Ringkasan transaksi harian dengan total pendapatan
- Daftar transaksi dengan status pembayaran
- Proses pembayaran untuk transaksi pending
- Pilih kendaraan untuk membuat transaksi baru

### 🌓 Dark Mode & Light Mode
- Toggle tema gelap dan terang di setiap halaman
- Desain yang konsisten di kedua tema
- Warna yang disesuaikan untuk kenyamanan mata

## Teknologi

- **Framework**: Flutter
- **Bahasa**: Dart
- **UI Style**: iOS Cupertino Design
- **State Management**: Stateful Widget
- **Platform**: iOS

## Instalasi

1. Clone repository ini
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## Struktur Proyek

```
lib/
├── main.dart              # Entry point aplikasi
├── models/
│   ├── vehicle.dart       # Model data kendaraan
│   └── transaction.dart   # Model data transaksi
└── screens/
    ├── dashboard_screen.dart  # Halaman dashboard
    ├── workshop_screen.dart   # Halaman manajemen workshop
    └── cashier_screen.dart    # Halaman kasir
```

## Fitur Dark Mode

Aplikasi mendukung dark mode yang dapat diaktifkan melalui tombol di pojok kanan atas setiap halaman. Tema akan berlaku untuk seluruh aplikasi dan disesuaikan dengan warna yang nyaman untuk mata.

## Desain

Aplikasi ini dirancang dengan gaya iOS minimalis yang bercahaya, menggunakan:
- Warna-warna cerah dan kontras yang baik
- Shadow dan efek visual yang halus
- Typography yang clean dan modern
- Spacing yang konsisten
- Animasi smooth untuk transisi

## Kontribusi

Silakan berkontribusi untuk mengembangkan aplikasi ini lebih lanjut. Fork repository ini dan buat pull request dengan fitur atau perbaikan yang Anda inginkan.

## Lisensi

Proyek ini open source dan dapat digunakan secara bebas.
