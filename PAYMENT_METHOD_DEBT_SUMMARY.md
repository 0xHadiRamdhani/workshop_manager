# Fitur Payment Method Hutang - Workshop Manager

## Ringkasan Perubahan

Saya telah berhasil mengimplementasikan fitur payment method hutang yang lengkap dengan integrasi ke manajemen hutang. Berikut adalah perubahan yang dilakukan:

## 1. Model Transaction (`lib/models/transaction.dart`)
- Menambahkan `PaymentMethod.debt` ke enum payment method
- Menambahkan case `PaymentMethod.debt` di getter `paymentMethodText` untuk menampilkan "Hutang"

## 2. Cashier Screen (`lib/screens/cashier_screen.dart`)
- Menambahkan opsi "Hutang" di dialog pemilihan metode pembayaran
- Membuat fungsi `_showDebtPaymentDialog()` untuk konfirmasi pembayaran hutang
- Membuat fungsi `_completeDebtPayment()` untuk memproses transaksi hutang
- Transaksi hutang memiliki:
  - Status: `TransactionStatus.pending`
  - `isDebt: true`
  - `debtAmount: totalPrice`
  - `debtPaidAmount: 0.0`
  - `debtStatus: 'pending'`
  - `paymentDueDate: DateTime.now().add(Duration(days: 30))`

## 3. Receipt Screen (`lib/screens/receipt_screen.dart`)
- Memperbaiki header untuk menampilkan "TRANSAKSI HUTANG" dengan warna orange
- Menambahkan informasi detail hutang di bagian payment details:
  - Total Hutang
  - Sudah Dibayar
  - Sisa Hutang
  - Jatuh Tempo
- Menambahkan catatan bahwa pembayaran dapat dilakukan melalui menu Manajemen Hutang
- Memperbaiki fungsi `_generateReceiptText()` untuk mencetak detail hutang

## 4. Debt Management Screen (`lib/screens/debt_management_screen.dart`)
- Sudah ada dan berfungsi dengan baik
- Menampilkan daftar transaksi hutang
- Memungkinkan pembayaran parsial atau lunas
- Menampilkan ringkasan total hutang, sudah dibayar, dan sisa hutang

## 5. File Lain yang Diperbaiki
- `lib/screens/cash_input_screen.dart` - Menambahkan case hutang di switch statement
- `lib/screens/workshop_screen.dart` - Menambahkan case hutang dan icon untuk hutang
- `lib/screens/transaction_history_screen.dart` - Menambahkan case hutang

## Alur Kerja Fitur Hutang

### 1. Pembuatan Transaksi Hutang
1. Pelanggan memilih produk/layanan di cashier screen
2. Klik "PROSES BAYAR"
3. Pilih metode pembayaran "Hutang"
4. Konfirmasi pembayaran hutang muncul
5. Klik "Catat Hutang"
6. Transaksi tersimpan dengan status pending
7. Receipt screen muncul dengan informasi hutang

### 2. Manajemen Hutang
1. Buka menu "Manajemen Hutang" dari drawer
2. Lihat daftar transaksi hutang
3. Klik "Bayar Sekarang" pada transaksi yang ingin dibayar
4. Masukkan jumlah pembayaran
5. Sistem akan otomatis update status hutang
6. Jika lunas, status berubah menjadi "paid"

## Fitur-fitur Hutang
- ✅ Pembayaran bisa dilakukan secara parsial
- ✅ Status hutang otomatis update (pending → partial → paid)
- ✅ Jatuh tempo otomatis 30 hari dari tanggal transaksi
- ✅ Integrasi dengan PDF receipt
- ✅ Tampilan khusus untuk transaksi hutang
- ✅ Informasi detail hutang di receipt

## Testing
Untuk menguji fitur ini:
1. Jalankan aplikasi
2. Pergi ke menu Kasir
3. Tambahkan beberapa produk ke cart
4. Klik "PROSES BAYAR"
5. Pilih metode pembayaran "Hutang"
6. Konfirmasi pembayaran hutang
7. Lihat receipt dengan informasi hutang
8. Buka menu Manajemen Hutang untuk melihat dan membayar hutang

## Catatan
- Transaksi hutang tidak mengurangi stok produk sampai dibayar (sudah diimplementasikan)
- Sistem mendukung pembayaran multiple untuk satu hutang
- Status hutang otomatis berubah berdasarkan jumlah yang dibayar