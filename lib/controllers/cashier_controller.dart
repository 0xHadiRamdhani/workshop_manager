import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../models/transaction.dart' as app_transaction;
import '../models/cart_item.dart';
import '../database/database_helper.dart';

enum PaymentMethod { cash, transfer, card, debt }

class CashierController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Observable variables
  var products = <Product>[].obs;
  var cartItems = <ShoppingCartItem>[].obs;
  var isLoading = false.obs;
  var selectedCategory = 'Semua'.obs;
  var selectedPaymentMethod = PaymentMethod.cash.obs;

  // Controllers
  final searchController = TextEditingController();

  // Computed properties
  List<Product> get filteredProducts {
    var filtered = products.toList();

    // Filter by category
    if (selectedCategory.value != 'Semua') {
      filtered = filtered
          .where((p) => p.category == selectedCategory.value)
          .toList();
    }

    // Filter by search
    if (searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (p) => p.name.toLowerCase().contains(
              searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    return filtered;
  }

  int get totalCartItems =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalCartPrice =>
      cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      final loadedProducts = await _dbHelper.getProducts();
      products.assignAll(loadedProducts);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat produk: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshProducts() {
    loadProducts();
  }

  void addToCart(Product product) {
    final existingItem = cartItems.firstWhereOrNull(
      (item) => item.product.id == product.id,
    );

    if (existingItem != null) {
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
      final index = cartItems.indexOf(existingItem);
      cartItems[index] = updatedItem;
    } else {
      cartItems.add(ShoppingCartItem(product: product));
    }

    Get.snackbar(
      'Berhasil',
      '${product.name} ditambahkan ke keranjang',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void updateQuantity(ShoppingCartItem item, int delta) {
    final currentQuantity = item.quantity;
    final newQuantity = currentQuantity + delta;

    if (newQuantity <= 0) {
      cartItems.remove(item);
    } else {
      final index = cartItems.indexOf(item);
      cartItems[index] = item.copyWith(quantity: newQuantity);
    }
  }

  void clearCart() {
    cartItems.clear();
  }

  Future<void> processPayment() async {
    if (cartItems.isEmpty) {
      Get.snackbar('Error', 'Keranjang kosong');
      return;
    }

    try {
      // Create transaction with required fields
      final transaction = app_transaction.Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vehicleId: 'CASHIER', // Special ID for cashier transactions
        customerName: 'Pelanggan Kasir',
        services: cartItems
            .map(
              (item) => app_transaction.ServiceItem(
                name: item.product.name,
                price: item.product.price,
                quantity: item.quantity,
              ),
            )
            .toList(),
        totalAmount: totalCartPrice,
        paymentMethod: _convertPaymentMethod(selectedPaymentMethod.value),
        status: app_transaction.TransactionStatus.paid,
        createdAt: DateTime.now(),
        paidAt: DateTime.now(),
        cashAmount: selectedPaymentMethod.value == PaymentMethod.cash
            ? totalCartPrice
            : null,
        changeAmount: 0.0,
        isDebt: selectedPaymentMethod.value == PaymentMethod.debt,
        debtAmount: selectedPaymentMethod.value == PaymentMethod.debt
            ? totalCartPrice
            : 0.0,
        debtPaidAmount: selectedPaymentMethod.value == PaymentMethod.debt
            ? 0.0
            : totalCartPrice,
        debtStatus: selectedPaymentMethod.value == PaymentMethod.debt
            ? 'pending'
            : 'paid',
      );

      // Save transaction
      await _dbHelper.insertTransaction(transaction);

      // Update product stock
      for (final item in cartItems) {
        final updatedProduct = Product(
          id: item.product.id,
          name: item.product.name,
          category: item.product.category,
          price: item.product.price,
          stock: item.product.stock - item.quantity,
          description: item.product.description,
          createdAt: item.product.createdAt,
        );
        await _dbHelper.updateProduct(updatedProduct);
      }

      // Clear cart and refresh products
      clearCart();
      await loadProducts();

      // Show success message
      Get.snackbar(
        'Berhasil',
        'Transaksi berhasil diproses',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Navigate to receipt screen
      Get.toNamed('/receipt', arguments: transaction);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memproses transaksi: $e');
    }
  }

  app_transaction.PaymentMethod _convertPaymentMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return app_transaction.PaymentMethod.cash;
      case PaymentMethod.transfer:
        return app_transaction.PaymentMethod.transfer;
      case PaymentMethod.card:
        return app_transaction.PaymentMethod.card;
      case PaymentMethod.debt:
        return app_transaction.PaymentMethod.debt;
    }
  }

  void showAddProductDialog() {
    Get.toNamed('/add-product');
  }

  void editProduct(Product product) {
    Get.toNamed('/edit-product', arguments: product);
  }

  Future<void> deleteProduct(Product product) async {
    final confirmed = await Get.dialog<bool>(
      CupertinoAlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus ${product.name}?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus'),
          ),
          CupertinoDialogAction(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deleteProduct(product.id!);
        await loadProducts();
        Get.snackbar('Berhasil', 'Produk berhasil dihapus');
      } catch (e) {
        Get.snackbar('Error', 'Gagal menghapus produk: $e');
      }
    }
  }
}
