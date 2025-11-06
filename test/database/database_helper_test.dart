import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workshop_manager/database/database_helper.dart';
import 'package:workshop_manager/models/product.dart';
import 'package:workshop_manager/models/vehicle.dart';
import 'package:workshop_manager/models/transaction.dart' as app_transaction;

void main() {
  // Initialize sqflite_ffi for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      dbHelper = DatabaseHelper.instance;
      // Use in-memory database for testing
      await dbHelper.close();
    });

    tearDown(() async {
      await dbHelper.close();
    });

    group('Product CRUD Operations', () {
      test('should insert and retrieve product', () async {
        final product = Product(
          id: 'TEST001',
          name: 'Test Product',
          category: 'Test',
          price: 100000,
          stock: 10,
          description: 'Test product description',
          createdAt: DateTime.now(),
        );

        // Insert product
        final insertResult = await dbHelper.insertProduct(product);
        expect(insertResult, 1);

        // Retrieve products
        final products = await dbHelper.getProducts();
        expect(products.length, greaterThan(0));

        final retrievedProduct = products.firstWhere((p) => p.id == 'TEST001');
        expect(retrievedProduct.name, 'Test Product');
        expect(retrievedProduct.price, 100000);
        expect(retrievedProduct.stock, 10);
      });

      test('should update product', () async {
        final product = Product(
          id: 'TEST002',
          name: 'Original Product',
          category: 'Test',
          price: 50000,
          stock: 5,
          createdAt: DateTime.now(),
        );

        await dbHelper.insertProduct(product);

        final updatedProduct = product.copyWith(
          name: 'Updated Product',
          price: 75000,
          stock: 8,
        );

        final updateResult = await dbHelper.updateProduct(updatedProduct);
        expect(updateResult, 1);

        final products = await dbHelper.getProducts();
        final retrievedProduct = products.firstWhere((p) => p.id == 'TEST002');
        expect(retrievedProduct.name, 'Updated Product');
        expect(retrievedProduct.price, 75000);
        expect(retrievedProduct.stock, 8);
      });

      test('should delete product', () async {
        final product = Product(
          id: 'TEST003',
          name: 'Product to Delete',
          category: 'Test',
          price: 25000,
          stock: 3,
          createdAt: DateTime.now(),
        );

        await dbHelper.insertProduct(product);

        // Verify product exists
        final productsBefore = await dbHelper.getProducts();
        expect(productsBefore.any((p) => p.id == 'TEST003'), true);

        // Delete product
        final deleteResult = await dbHelper.deleteProduct('TEST003');
        expect(deleteResult, 1);

        // Verify product is deleted
        final productsAfter = await dbHelper.getProducts();
        expect(productsAfter.any((p) => p.id == 'TEST003'), false);
      });

      test('should get products by category', () async {
        final product1 = Product(
          id: 'CAT001',
          name: 'Product A',
          category: 'Category1',
          price: 10000,
          stock: 5,
          createdAt: DateTime.now(),
        );

        final product2 = Product(
          id: 'CAT002',
          name: 'Product B',
          category: 'Category2',
          price: 20000,
          stock: 3,
          createdAt: DateTime.now(),
        );

        await dbHelper.insertProduct(product1);
        await dbHelper.insertProduct(product2);

        final category1Products = await dbHelper.getProductsByCategory(
          'Category1',
        );
        expect(category1Products.length, 1);
        expect(category1Products.first.name, 'Product A');

        final category2Products = await dbHelper.getProductsByCategory(
          'Category2',
        );
        expect(category2Products.length, 1);
        expect(category2Products.first.name, 'Product B');
      });

      test('should search products', () async {
        final product1 = Product(
          id: 'SEARCH001',
          name: 'Special Product Alpha',
          category: 'Test',
          price: 15000,
          stock: 2,
          createdAt: DateTime.now(),
        );

        final product2 = Product(
          id: 'SEARCH002',
          name: 'Regular Product Beta',
          category: 'Test',
          price: 25000,
          stock: 4,
          createdAt: DateTime.now(),
        );

        await dbHelper.insertProduct(product1);
        await dbHelper.insertProduct(product2);

        final searchResults = await dbHelper.searchProducts('Special');
        expect(searchResults.length, 1);
        expect(searchResults.first.name, 'Special Product Alpha');

        final searchResults2 = await dbHelper.searchProducts('Product');
        expect(searchResults2.length, 2);
      });
    });

    group('Vehicle CRUD Operations', () {
      test('should insert and retrieve vehicle', () async {
        final vehicle = Vehicle(
          id: 'VEH001',
          customerName: 'John Doe',
          vehicleType: 'Honda Beat',
          licensePlate: 'B 1234 ABC',
          phoneNumber: '081234567890',
          problemDescription: 'Motor tidak bisa starter',
          status: VehicleStatus.waiting,
          createdAt: DateTime.now(),
          estimatedCompletion: DateTime.now().add(Duration(days: 2)),
          estimatedCost: 150000,
          paymentMethod: app_transaction.PaymentMethod.cash,
          actualCost: 175000,
          isPaid: true,
        );

        // Insert vehicle
        final insertResult = await dbHelper.insertVehicle(vehicle);
        expect(insertResult, 1);

        // Retrieve vehicles
        final vehicles = await dbHelper.getVehicles();
        expect(vehicles.length, greaterThan(0));

        final retrievedVehicle = vehicles.firstWhere((v) => v.id == 'VEH001');
        expect(retrievedVehicle.customerName, 'John Doe');
        expect(retrievedVehicle.vehicleType, 'Honda Beat');
        expect(retrievedVehicle.licensePlate, 'B 1234 ABC');
        expect(retrievedVehicle.status, VehicleStatus.waiting);
        expect(retrievedVehicle.isPaid, true);
      });

      test('should update vehicle', () async {
        final vehicle = Vehicle(
          id: 'VEH002',
          customerName: 'Jane Smith',
          vehicleType: 'Yamaha Mio',
          licensePlate: 'B 5678 DEF',
          phoneNumber: '089876543210',
          problemDescription: 'Ganti oli',
          status: VehicleStatus.waiting,
          createdAt: DateTime.now(),
        );

        await dbHelper.insertVehicle(vehicle);

        final updatedVehicle = vehicle.copyWith(
          status: VehicleStatus.completed,
          actualCost: 125000,
          isPaid: true,
        );

        final updateResult = await dbHelper.updateVehicle(updatedVehicle);
        expect(updateResult, 1);

        final vehicles = await dbHelper.getVehicles();
        final retrievedVehicle = vehicles.firstWhere((v) => v.id == 'VEH002');
        expect(retrievedVehicle.status, VehicleStatus.completed);
        expect(retrievedVehicle.actualCost, 125000);
        expect(retrievedVehicle.isPaid, true);
      });

      test('should delete vehicle', () async {
        final vehicle = Vehicle(
          id: 'VEH003',
          customerName: 'Test Customer',
          vehicleType: 'Test Vehicle',
          licensePlate: 'B 9999 XYZ',
          phoneNumber: '081111111111',
          problemDescription: 'Test problem',
          status: VehicleStatus.waiting,
          createdAt: DateTime.now(),
        );

        await dbHelper.insertVehicle(vehicle);

        // Verify vehicle exists
        final vehiclesBefore = await dbHelper.getVehicles();
        expect(vehiclesBefore.any((v) => v.id == 'VEH003'), true);

        // Delete vehicle
        final deleteResult = await dbHelper.deleteVehicle('VEH003');
        expect(deleteResult, 1);

        // Verify vehicle is deleted
        final vehiclesAfter = await dbHelper.getVehicles();
        expect(vehiclesAfter.any((v) => v.id == 'VEH003'), false);
      });
    });

    group('Transaction CRUD Operations', () {
      test('should insert and retrieve transaction', () async {
        final services = [
          app_transaction.ServiceItem(
            name: 'Service A',
            price: 50000,
            quantity: 1,
          ),
          app_transaction.ServiceItem(
            name: 'Service B',
            price: 75000,
            quantity: 2,
          ),
        ];

        final transaction = app_transaction.Transaction(
          id: 'TRANS001',
          vehicleId: 'VEH001',
          customerName: 'John Doe',
          services: services,
          totalAmount: 200000,
          paymentMethod: app_transaction.PaymentMethod.cash,
          status: app_transaction.TransactionStatus.paid,
          createdAt: DateTime.now(),
          paidAt: DateTime.now(),
          cashAmount: 250000,
          changeAmount: 50000,
        );

        // Insert transaction
        final insertResult = await dbHelper.insertTransaction(transaction);
        expect(insertResult, 1);

        // Retrieve transactions
        final transactions = await dbHelper.getTransactions();
        expect(transactions.length, greaterThan(0));

        final retrievedTransaction = transactions.firstWhere(
          (t) => t.id == 'TRANS001',
        );
        expect(retrievedTransaction.customerName, 'John Doe');
        expect(retrievedTransaction.totalAmount, 200000);
        expect(
          retrievedTransaction.paymentMethod,
          app_transaction.PaymentMethod.cash,
        );
        expect(
          retrievedTransaction.status,
          app_transaction.TransactionStatus.paid,
        );
        expect(retrievedTransaction.cashAmount, 250000);
        expect(retrievedTransaction.changeAmount, 50000);
        expect(retrievedTransaction.services.length, 2);
      });

      test('should get transactions by status', () async {
        final pendingTransaction = app_transaction.Transaction(
          id: 'TRANS002',
          vehicleId: 'VEH002',
          customerName: 'Jane Smith',
          services: [
            app_transaction.ServiceItem(
              name: 'Service',
              price: 50000,
              quantity: 1,
            ),
          ],
          totalAmount: 50000,
          paymentMethod: app_transaction.PaymentMethod.cash,
          status: app_transaction.TransactionStatus.pending,
          createdAt: DateTime.now(),
        );

        final paidTransaction = app_transaction.Transaction(
          id: 'TRANS003',
          vehicleId: 'VEH003',
          customerName: 'Bob Johnson',
          services: [
            app_transaction.ServiceItem(
              name: 'Service',
              price: 75000,
              quantity: 1,
            ),
          ],
          totalAmount: 75000,
          paymentMethod: app_transaction.PaymentMethod.transfer,
          status: app_transaction.TransactionStatus.paid,
          createdAt: DateTime.now(),
        );

        await dbHelper.insertTransaction(pendingTransaction);
        await dbHelper.insertTransaction(paidTransaction);

        final pendingTransactions = await dbHelper.getTransactionsByStatus(
          app_transaction.TransactionStatus.pending,
        );
        expect(pendingTransactions.length, greaterThan(0));
        expect(pendingTransactions.any((t) => t.id == 'TRANS002'), true);

        final paidTransactions = await dbHelper.getTransactionsByStatus(
          app_transaction.TransactionStatus.paid,
        );
        expect(paidTransactions.length, greaterThan(0));
        expect(paidTransactions.any((t) => t.id == 'TRANS003'), true);
      });

      test('should get transactions by date range', () async {
        final transaction1 = app_transaction.Transaction(
          id: 'DATE001',
          vehicleId: 'VEH001',
          customerName: 'Test 1',
          services: [
            app_transaction.ServiceItem(
              name: 'Service',
              price: 50000,
              quantity: 1,
            ),
          ],
          totalAmount: 50000,
          paymentMethod: app_transaction.PaymentMethod.cash,
          status: app_transaction.TransactionStatus.paid,
          createdAt: DateTime(2024, 1, 15),
        );

        final transaction2 = app_transaction.Transaction(
          id: 'DATE002',
          vehicleId: 'VEH002',
          customerName: 'Test 2',
          services: [
            app_transaction.ServiceItem(
              name: 'Service',
              price: 75000,
              quantity: 1,
            ),
          ],
          totalAmount: 75000,
          paymentMethod: app_transaction.PaymentMethod.cash,
          status: app_transaction.TransactionStatus.paid,
          createdAt: DateTime(2024, 1, 20),
        );

        await dbHelper.insertTransaction(transaction1);
        await dbHelper.insertTransaction(transaction2);

        final startDate = DateTime(2024, 1, 10);
        final endDate = DateTime(2024, 1, 25);

        final transactionsInRange = await dbHelper.getTransactionsByDateRange(
          startDate,
          endDate,
        );
        expect(transactionsInRange.length, greaterThanOrEqualTo(2));
      });

      test('should update transaction', () async {
        final transaction = app_transaction.Transaction(
          id: 'UPDATE001',
          vehicleId: 'VEH001',
          customerName: 'Original Customer',
          services: [
            app_transaction.ServiceItem(
              name: 'Service',
              price: 50000,
              quantity: 1,
            ),
          ],
          totalAmount: 50000,
          paymentMethod: app_transaction.PaymentMethod.cash,
          status: app_transaction.TransactionStatus.pending,
          createdAt: DateTime.now(),
        );

        await dbHelper.insertTransaction(transaction);

        final updatedTransaction = app_transaction.Transaction(
          id: transaction.id,
          vehicleId: transaction.vehicleId,
          customerName: 'Updated Customer',
          services: transaction.services,
          totalAmount: transaction.totalAmount,
          paymentMethod: transaction.paymentMethod,
          status: app_transaction.TransactionStatus.paid,
          createdAt: transaction.createdAt,
          paidAt: DateTime.now(),
          cashAmount: transaction.cashAmount,
          changeAmount: transaction.changeAmount,
        );

        final updateResult = await dbHelper.updateTransaction(
          updatedTransaction,
        );
        expect(updateResult, 1);

        final transactions = await dbHelper.getTransactions();
        final retrievedTransaction = transactions.firstWhere(
          (t) => t.id == 'UPDATE001',
        );
        expect(retrievedTransaction.customerName, 'Updated Customer');
        expect(
          retrievedTransaction.status,
          app_transaction.TransactionStatus.paid,
        );
        expect(retrievedTransaction.paidAt, isNotNull);
      });

      test('should delete transaction', () async {
        final transaction = app_transaction.Transaction(
          id: 'DELETE001',
          vehicleId: 'VEH001',
          customerName: 'Customer to Delete',
          services: [
            app_transaction.ServiceItem(
              name: 'Service',
              price: 50000,
              quantity: 1,
            ),
          ],
          totalAmount: 50000,
          paymentMethod: app_transaction.PaymentMethod.cash,
          status: app_transaction.TransactionStatus.paid,
          createdAt: DateTime.now(),
        );

        await dbHelper.insertTransaction(transaction);

        // Verify transaction exists
        final transactionsBefore = await dbHelper.getTransactions();
        expect(transactionsBefore.any((t) => t.id == 'DELETE001'), true);

        // Delete transaction
        final deleteResult = await dbHelper.deleteTransaction('DELETE001');
        expect(deleteResult, 1);

        // Verify transaction is deleted
        final transactionsAfter = await dbHelper.getTransactions();
        expect(transactionsAfter.any((t) => t.id == 'DELETE001'), false);
      });
    });

    group('Database Utility Methods', () {
      test('should check database connection', () async {
        final isConnected = await dbHelper.isDatabaseOpen();
        expect(isConnected, true);
      });

      test('should get database path', () async {
        final dbPath = await dbHelper.getDatabasePath();
        expect(dbPath, isNotNull);
        expect(dbPath!.contains('workshop_manager_v2.db'), true);
      });

      test('should get daily transactions', () async {
        final todayTransaction = app_transaction.Transaction(
          id: 'DAILY001',
          vehicleId: 'VEH001',
          customerName: 'Today Customer',
          services: [
            app_transaction.ServiceItem(
              name: 'Service',
              price: 50000,
              quantity: 1,
            ),
          ],
          totalAmount: 50000,
          paymentMethod: app_transaction.PaymentMethod.cash,
          status: app_transaction.TransactionStatus.paid,
          createdAt: DateTime.now(),
        );

        await dbHelper.insertTransaction(todayTransaction);

        final dailyTransactions = await dbHelper.getDailyTransactions();
        expect(dailyTransactions.length, greaterThan(0));
        expect(dailyTransactions.any((t) => t.id == 'DAILY001'), true);
      });

      test('should get daily revenue', () async {
        final transaction1 = app_transaction.Transaction(
          id: 'REV001',
          vehicleId: 'VEH001',
          customerName: 'Customer 1',
          services: [
            app_transaction.ServiceItem(
              name: 'Service',
              price: 100000,
              quantity: 1,
            ),
          ],
          totalAmount: 100000,
          paymentMethod: app_transaction.PaymentMethod.cash,
          status: app_transaction.TransactionStatus.paid,
          createdAt: DateTime.now(),
        );

        final transaction2 = app_transaction.Transaction(
          id: 'REV002',
          vehicleId: 'VEH002',
          customerName: 'Customer 2',
          services: [
            app_transaction.ServiceItem(
              name: 'Service',
              price: 150000,
              quantity: 1,
            ),
          ],
          totalAmount: 150000,
          paymentMethod: app_transaction.PaymentMethod.cash,
          status: app_transaction.TransactionStatus.paid,
          createdAt: DateTime.now(),
        );

        await dbHelper.insertTransaction(transaction1);
        await dbHelper.insertTransaction(transaction2);

        final dailyRevenue = await dbHelper.getDailyRevenue();
        expect(dailyRevenue, 250000); // 100000 + 150000
      });

      test('should get daily completed vehicles', () async {
        final completedVehicle = Vehicle(
          id: 'COMP001',
          customerName: 'Completed Customer',
          vehicleType: 'Honda Beat',
          licensePlate: 'B 1234 ABC',
          phoneNumber: '081234567890',
          problemDescription: 'Service completed',
          status: VehicleStatus.completed,
          createdAt: DateTime.now(),
        );

        await dbHelper.insertVehicle(completedVehicle);

        final dailyCompleted = await dbHelper.getDailyCompletedVehicles();
        expect(dailyCompleted, greaterThan(0));
      });
    });
  });
}
