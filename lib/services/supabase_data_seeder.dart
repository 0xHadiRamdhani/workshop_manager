import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/vehicle.dart';
import '../models/technician.dart';
import 'supabase_service.dart';

class SupabaseDataSeeder {
  final SupabaseService _supabaseService = SupabaseService();

  // Generate ID untuk Supabase
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Data produk contoh
  final List<Map<String, dynamic>> sampleProductsData = [
    {
      'name': 'Oli Mesin 1L',
      'category': 'Oli & Pelumas',
      'price': 85000,
      'stock': 50,
      'description': 'Oli mesin berkualitas tinggi untuk kendaraan',
    },
    {
      'name': 'Filter Oli',
      'category': 'Filter',
      'price': 25000,
      'stock': 30,
      'description': 'Filter oli original untuk mesin',
    },
    {
      'name': 'Ban Depan 17 inch',
      'category': 'Ban & Velg',
      'price': 450000,
      'stock': 15,
      'description': 'Ban berkualitas untuk kendaraan roda dua',
    },
    {
      'name': 'Kampas Rem Depan',
      'category': 'Rem',
      'price': 120000,
      'stock': 20,
      'description': 'Kampas rem depan untuk motor',
    },
    {
      'name': 'Service Ringan',
      'category': 'Jasa Service',
      'price': 75000,
      'stock': 999,
      'description': 'Service ringan termasuk ganti oli dan filter',
    },
    {
      'name': 'Tune Up Mesin',
      'category': 'Jasa Service',
      'price': 150000,
      'stock': 999,
      'description': 'Tune up mesin lengkap dengan diagnosis',
    },
    {
      'name': 'Ganti Ban',
      'category': 'Jasa Service',
      'price': 50000,
      'stock': 999,
      'description': 'Jasa ganti ban dengan balancing',
    },
    {
      'name': 'Cuci Motor',
      'category': 'Jasa Cuci',
      'price': 25000,
      'stock': 999,
      'description': 'Cuci motor lengkap dengan vacuum',
    },
  ];

  // Data kendaraan contoh
  final List<Map<String, dynamic>> sampleVehiclesData = [
    {
      'customerName': 'Budi Santoso',
      'licensePlate': 'B 1234 ABC',
      'vehicleType': 'Honda Beat',
      'phoneNumber': '081234567890',
      'problemDescription': 'Mesin berisik, perlu service rutin',
      'status': VehicleStatus.inProgress,
    },
    {
      'customerName': 'Siti Nurhaliza',
      'licensePlate': 'B 5678 DEF',
      'vehicleType': 'Yamaha Mio',
      'phoneNumber': '082345678901',
      'problemDescription': 'Rem depan bunyi, minta dicek',
      'status': VehicleStatus.completed,
    },
    {
      'customerName': 'Ahmad Rahman',
      'licensePlate': 'B 9012 GHI',
      'vehicleType': 'Suzuki Nex',
      'phoneNumber': '083456789012',
      'problemDescription': 'Ganti oli dan filter, tune up',
      'status': VehicleStatus.delivered,
    },
    {
      'customerName': 'Rina Wulandari',
      'licensePlate': 'B 3456 JKL',
      'vehicleType': 'Honda Vario',
      'phoneNumber': '084567890123',
      'problemDescription': 'Ban bocor, ganti ban baru',
      'status': VehicleStatus.inProgress,
    },
    {
      'customerName': 'Dedi Kurniawan',
      'licensePlate': 'B 7890 MNO',
      'vehicleType': 'Kawasaki Ninja',
      'phoneNumber': '085678901234',
      'problemDescription': 'Service besar, ganti kampas rem',
      'status': VehicleStatus.waiting,
    },
  ];

  // Data teknisi contoh
  final List<Map<String, dynamic>> sampleTechniciansData = [
    {
      'name': 'Joko Prasetyo',
      'specialization': 'Mesin & Tune Up',
      'phone': '081234567890',
      'email': 'joko@workshop.com',
      'experienceYears': 8,
      'status': TechnicianStatus.active,
      'rating': 4.8,
      'totalServices': 150,
    },
    {
      'name': 'Agus Wibowo',
      'specialization': 'Listrik & Kelistrikan',
      'phone': '082345678901',
      'email': 'agus@workshop.com',
      'experienceYears': 6,
      'status': TechnicianStatus.active,
      'rating': 4.6,
      'totalServices': 120,
    },
    {
      'name': 'Bambang Sutrisno',
      'specialization': 'Ban & Suspensi',
      'phone': '083456789012',
      'email': 'bambang@workshop.com',
      'experienceYears': 10,
      'status': TechnicianStatus.active,
      'rating': 4.9,
      'totalServices': 200,
    },
  ];

  // Data transaksi contoh
  final List<Map<String, dynamic>> sampleTransactionsData = [
    {
      'vehicleId': '', // Akan diisi setelah membuat vehicle
      'customerName': 'Budi Santoso',
      'services': [
        {'name': 'Service Ringan', 'price': 75000, 'quantity': 1},
        {'name': 'Oli Mesin 1L', 'price': 85000, 'quantity': 1},
      ],
      'totalAmount': 160000,
      'paymentMethod': PaymentMethod.cash,
      'status': TransactionStatus.paid,
      'cashAmount': 160000,
      'changeAmount': 0,
      'isDebt': false,
      'debtAmount': 0,
      'debtPaidAmount': 0,
      'debtStatus': 'paid',
    },
    {
      'vehicleId': '', // Akan diisi setelah membuat vehicle
      'customerName': 'Siti Nurhaliza',
      'services': [
        {'name': 'Kampas Rem Depan', 'price': 120000, 'quantity': 1},
        {'name': 'Ganti Ban', 'price': 50000, 'quantity': 1},
      ],
      'totalAmount': 170000,
      'paymentMethod': PaymentMethod.cash,
      'status': TransactionStatus.paid,
      'cashAmount': 170000,
      'changeAmount': 0,
      'isDebt': false,
      'debtAmount': 0,
      'debtPaidAmount': 0,
      'debtStatus': 'paid',
    },
    {
      'vehicleId': '', // Akan diisi setelah membuat vehicle
      'customerName': 'Ahmad Rahman',
      'services': [
        {'name': 'Tune Up Mesin', 'price': 150000, 'quantity': 1},
        {'name': 'Filter Oli', 'price': 25000, 'quantity': 1},
      ],
      'totalAmount': 175000,
      'paymentMethod': PaymentMethod.cash,
      'status': TransactionStatus.paid,
      'cashAmount': 175000,
      'changeAmount': 0,
      'isDebt': false,
      'debtAmount': 0,
      'debtPaidAmount': 0,
      'debtStatus': 'paid',
    },
    {
      'vehicleId': '', // Akan diisi setelah membuat vehicle
      'customerName': 'Rina Wulandari',
      'services': [
        {'name': 'Ban Depan 17 inch', 'price': 450000, 'quantity': 1},
        {'name': 'Cuci Motor', 'price': 25000, 'quantity': 1},
      ],
      'totalAmount': 475000,
      'paymentMethod': PaymentMethod.debt,
      'status': TransactionStatus.pending,
      'cashAmount': 0,
      'changeAmount': 0,
      'isDebt': true,
      'debtAmount': 475000,
      'debtPaidAmount': 0,
      'debtStatus': 'pending',
      'paymentDueDate': DateTime.now().add(const Duration(days: 7)),
    },
  ];

  /// Method untuk seed data produk
  Future<void> seedProducts() async {
    try {
      print('🌱 Seeding products...');

      for (final productData in sampleProductsData) {
        final product = Product(
          id: _generateId(),
          name: productData['name'],
          category: productData['category'],
          price: productData['price'],
          stock: productData['stock'],
          description: productData['description'],
          createdAt: DateTime.now().subtract(
            Duration(days: sampleProductsData.indexOf(productData) * 3),
          ),
        );

        await _supabaseService.insertProduct(product);
      }

      print('✅ Products seeded successfully');
    } catch (e) {
      print('❌ Error seeding products: $e');
      rethrow;
    }
  }

  /// Method untuk seed data kendaraan
  Future<void> seedVehicles() async {
    try {
      print('🌱 Seeding vehicles...');

      for (final vehicleData in sampleVehiclesData) {
        final vehicle = Vehicle(
          id: _generateId(),
          customerName: vehicleData['customerName'],
          vehicleType: vehicleData['vehicleType'],
          licensePlate: vehicleData['licensePlate'],
          phoneNumber: vehicleData['phoneNumber'],
          problemDescription: vehicleData['problemDescription'],
          status: vehicleData['status'],
          createdAt: DateTime.now().subtract(
            Duration(days: sampleVehiclesData.indexOf(vehicleData) * 2),
          ),
        );

        await _supabaseService.insertVehicle(vehicle);
      }

      print('✅ Vehicles seeded successfully');
    } catch (e) {
      print('❌ Error seeding vehicles: $e');
      rethrow;
    }
  }

  /// Method untuk seed data teknisi
  Future<void> seedTechnicians() async {
    try {
      print('🌱 Seeding technicians...');

      for (final technicianData in sampleTechniciansData) {
        final technician = Technician(
          id: _generateId(),
          name: technicianData['name'],
          phone: technicianData['phone'],
          email: technicianData['email'],
          specialization: technicianData['specialization'],
          experienceYears: technicianData['experienceYears'],
          status: technicianData['status'],
          createdAt: DateTime.now().subtract(
            Duration(days: sampleTechniciansData.indexOf(technicianData) * 5),
          ),
          rating: technicianData['rating'],
          totalServices: technicianData['totalServices'],
        );

        await _supabaseService.insertTechnician(technician);
      }

      print('✅ Technicians seeded successfully');
    } catch (e) {
      print('❌ Error seeding technicians: $e');
      rethrow;
    }
  }

  /// Method untuk seed data transaksi dengan relasi ke kendaraan
  Future<void> seedTransactions() async {
    try {
      print('🌱 Seeding transactions...');

      // Ambil data kendaraan yang sudah ada
      final vehicles = await _supabaseService.getVehicles();
      if (vehicles.isEmpty) {
        print('⚠️ No vehicles found. Please seed vehicles first.');
        return;
      }

      for (
        int i = 0;
        i < sampleTransactionsData.length && i < vehicles.length;
        i++
      ) {
        final transactionData = sampleTransactionsData[i];
        final vehicle = vehicles[i];

        // Konversi services ke ServiceItem
        final services =
            (transactionData['services'] as List<Map<String, dynamic>>)
                .map(
                  (service) => ServiceItem(
                    name: service['name'],
                    price: service['price'],
                    quantity: service['quantity'],
                  ),
                )
                .toList();

        final transaction = Transaction(
          id: _generateId(),
          vehicleId: vehicle.id,
          customerName: transactionData['customerName'],
          services: services,
          totalAmount: transactionData['totalAmount'],
          paymentMethod: transactionData['paymentMethod'],
          status: transactionData['status'],
          createdAt: DateTime.now().subtract(Duration(days: i * 2)),
          cashAmount: transactionData['cashAmount'],
          changeAmount: transactionData['changeAmount'],
          isDebt: transactionData['isDebt'],
          debtAmount: transactionData['debtAmount'],
          debtPaidAmount: transactionData['debtPaidAmount'],
          debtStatus: transactionData['debtStatus'],
          paymentDueDate: transactionData['paymentDueDate'],
        );

        await _supabaseService.insertTransaction(transaction);
      }

      print('✅ Transactions seeded successfully');
    } catch (e) {
      print('❌ Error seeding transactions: $e');
      rethrow;
    }
  }

  /// Method untuk seed semua data
  Future<void> seedAllData() async {
    try {
      print('🚀 Starting data seeding process...');

      await seedProducts();
      await seedTechnicians();
      await seedVehicles();
      await seedTransactions();

      print('🎉 All data seeded successfully!');
    } catch (e) {
      print('❌ Error during data seeding: $e');
      rethrow;
    }
  }

  /// Method untuk clear semua data (hati-hati menggunakan ini)
  Future<void> clearAllData() async {
    try {
      print('🧹 Clearing all data...');

      final supabase = Supabase.instance.client;

      // Hapus data dari tabel-tabel (urutan penting karena foreign key constraints)
      await supabase.from('service_items').delete().neq('id', 0);
      await supabase.from('debt_payments').delete().neq('id', 0);
      await supabase.from('transactions').delete().neq('id', 0);
      await supabase.from('vehicles').delete().neq('id', 0);
      await supabase.from('technicians').delete().neq('id', 0);
      await supabase.from('products').delete().neq('id', 0);

      print('✅ All data cleared successfully');
    } catch (e) {
      print('❌ Error clearing data: $e');
      rethrow;
    }
  }
}
