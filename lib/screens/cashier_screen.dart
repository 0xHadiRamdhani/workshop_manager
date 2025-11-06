import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/vehicle.dart';
import '../models/cart_item.dart';
import '../database/database_helper.dart';
import 'cash_input_screen.dart';
import 'receipt_screen.dart';
import 'add_product_screen.dart';
import 'transaction_history_screen.dart';
import 'qris_payment_screen.dart';
import 'edit_product_screen.dart';

// Enum untuk state navigasi yang lebih jelas
enum NavigationState {
  idle,
  navigatingToAddProduct,
  navigatingToTransactionHistory,
  navigatingToCashInput,
  navigatingToQRISPayment,
  navigatingToBankTransfer,
  navigatingToReceipt,
  processingPayment,
}

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  List<Product> _products = [];
  final List<ShoppingCartItem> _cartItems = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _isLoading = true;
  NavigationState _navigationState = NavigationState.idle;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _databaseHelper.getProducts();
      if (!mounted) return;

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Tampilkan pesan error ke user
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error Memuat Produk'),
            content: Text('Gagal memuat data produk: ${e.toString()}'),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('OK'),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Kasir'),
          backgroundColor: CupertinoColors.darkBackgroundGray,
        ),
        child: SafeArea(child: Center(child: CupertinoActivityIndicator())),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Kasir'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.add, color: _getAddProductIconColor()),
              onPressed: _getAddProductOnPressed(),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                CupertinoIcons.clock,
                color: _getTransactionHistoryIconColor(),
              ),
              onPressed: _getTransactionHistoryOnPressed(),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSearchAndFilterSection(),
            _buildCartSummary(),
            Expanded(child: _buildProductGrid()),
            _buildCheckoutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CupertinoTextField(
            controller: _searchController,
            placeholder: 'Cari produk...',
            prefix: const Icon(
              CupertinoIcons.search,
              color: CupertinoColors.systemGrey,
            ),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(8),
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('Semua'),
                _buildCategoryChip('Oli'),
                _buildCategoryChip('Rem'),
                _buildCategoryChip('Mesin'),
                _buildCategoryChip('Transmisi'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isSelected
            ? CupertinoColors.systemBlue
            : CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(20),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? CupertinoColors.white : CupertinoColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        onPressed: () {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
    );
  }

  Widget _buildCartSummary() {
    final totalItems = _cartItems.fold(0, (sum, item) => sum + item.quantity);
    final totalPrice = _cartItems.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.cart, color: CupertinoColors.systemBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalItems item',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Rp ${totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: CupertinoColors.systemBlue,
            borderRadius: BorderRadius.circular(8),
            child: const Text(
              'Lihat Cart',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: _showCartDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    final filteredProducts = _getFilteredProducts();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  _getProductIcon(product.category),
                  size: 48,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stok: ${product.stock}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: CupertinoColors.systemBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        child: const Text(
                          'Detail',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onPressed: () => _showProductDetail(product),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: CupertinoColors.systemGreen,
                        borderRadius: BorderRadius.circular(8),
                        child: const Text(
                          '+ Tambah',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => _addToCart(product),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    final totalPrice = _cartItems.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
    final totalItems = _cartItems.fold(0, (sum, item) => sum + item.quantity);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Bayar',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    Text(
                      'Rp ${totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                    Text(
                      '$totalItems item',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Metode Bayar',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(8),
                    child: Text(
                      _getPaymentMethodText(_selectedPaymentMethod),
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: _showPaymentMethodDialog,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: CupertinoColors.systemGreen,
              borderRadius: BorderRadius.circular(12),
              child: const Text(
                'PROSES BAYAR',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _cartItems.isEmpty ? null : _processPayment,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Product> _getFilteredProducts() {
    var filtered = _products;

    if (_selectedCategory != 'Semua') {
      filtered = filtered
          .where((p) => p.category == _selectedCategory)
          .toList();
    }

    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (p) => p.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    return filtered;
  }

  IconData _getProductIcon(String category) {
    switch (category) {
      case 'Oli':
        return CupertinoIcons.drop;
      case 'Rem':
        return CupertinoIcons.stop_circle;
      case 'Mesin':
        return CupertinoIcons.settings;
      case 'Transmisi':
        return CupertinoIcons.arrow_2_circlepath;
      default:
        return CupertinoIcons.cube_box;
    }
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.transfer:
        return 'Transfer Bank';
      case PaymentMethod.card:
        return 'Kartu Debit/Kredit';
      case PaymentMethod.qris:
        return 'QRIS';
    }
  }

  // Helper methods untuk state navigasi
  Color _getAddProductIconColor() {
    return _navigationState == NavigationState.navigatingToAddProduct
        ? CupertinoColors.systemGrey
        : CupertinoColors.systemBlue;
  }

  VoidCallback? _getAddProductOnPressed() {
    return _navigationState == NavigationState.navigatingToAddProduct
        ? null
        : _showAddProductDialog;
  }

  Color _getTransactionHistoryIconColor() {
    return _navigationState == NavigationState.navigatingToTransactionHistory
        ? CupertinoColors.systemGrey
        : CupertinoColors.systemBlue;
  }

  VoidCallback? _getTransactionHistoryOnPressed() {
    return _navigationState == NavigationState.navigatingToTransactionHistory
        ? null
        : _showTransactionHistory;
  }

  void _addToCart(Product product) {
    if (product.stock <= 0) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Stok Habis'),
          content: const Text('Produk ini sudah habis stoknya'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );
      if (existingIndex >= 0) {
        // Buat instance baru dengan quantity yang diupdate
        final existingItem = _cartItems[existingIndex];
        _cartItems[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + 1,
        );
      } else {
        _cartItems.add(ShoppingCartItem(product: product));
      }
    });
  }

  void _showCartDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: CupertinoColors.darkBackgroundGray,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              _buildCartHeader(),
              Expanded(child: _buildCartItems(setState)),
              _buildCartFooter(setState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartHeader() {
    final totalItems = _cartItems.fold(0, (sum, item) => sum + item.quantity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey4.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Keranjang Belanja',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const Spacer(),
          Text(
            '$totalItems item',
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems([StateSetter? dialogSetState]) {
    if (_cartItems.isEmpty) {
      return const Center(
        child: Text(
          'Keranjang kosong',
          style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return _buildShoppingCartItem(item, dialogSetState);
      },
    );
  }

  Widget _buildShoppingCartItem(
    ShoppingCartItem item, [
    StateSetter? dialogSetState,
  ]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
                Text(
                  'Rp ${item.product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.all(4),
                minSize: 32,
                borderRadius: BorderRadius.circular(16),
                child: const Icon(CupertinoIcons.minus, size: 16),
                onPressed: () =>
                    _updateQuantityInDialog(item, -1, dialogSetState),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.all(4),
                minSize: 32,
                borderRadius: BorderRadius.circular(16),
                child: const Icon(CupertinoIcons.plus, size: 16),
                onPressed: () =>
                    _updateQuantityInDialog(item, 1, dialogSetState),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartFooter([StateSetter? dialogSetState]) {
    final totalPrice = _cartItems.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        border: Border(
          top: BorderSide(color: CupertinoColors.systemGrey4.withOpacity(0.3)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
              ),
              const Spacer(),
              Text(
                'Rp ${totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: CupertinoColors.systemGreen,
              borderRadius: BorderRadius.circular(8),
              child: const Text(
                'LANJUTKAN PEMBAYARAN',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                _processPayment();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(ShoppingCartItem item, int change) {
    if (!mounted) return;

    setState(() {
      final newQuantity = item.quantity + change;
      if (newQuantity <= 0) {
        _cartItems.remove(item);
      } else {
        // Temukan index item dan replace dengan instance baru
        final index = _cartItems.indexOf(item);
        if (index >= 0) {
          _cartItems[index] = item.copyWith(quantity: newQuantity);
        }
      }
    });
  }

  void _updateQuantityInDialog(
    ShoppingCartItem item,
    int change,
    StateSetter? dialogSetState,
  ) {
    if (!mounted) return;

    // Update quantity di list utama
    setState(() {
      final newQuantity = item.quantity + change;
      if (newQuantity <= 0) {
        _cartItems.remove(item);
      } else {
        // Temukan index item dan replace dengan instance baru
        final index = _cartItems.indexOf(item);
        if (index >= 0) {
          _cartItems[index] = item.copyWith(quantity: newQuantity);
        }
      }
    });

    // Trigger rebuild pada dialog jika tersedia
    if (dialogSetState != null) {
      dialogSetState(() {});
    }
  }

  void _showProductDetail(Product product) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: CupertinoColors.darkBackgroundGray,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: CupertinoColors.white,
                  ),
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Kategori', product.category),
            _buildDetailRow('Harga', 'Rp ${product.price.toStringAsFixed(0)}'),
            _buildDetailRow('Stok', '${product.stock}'),
            if (product.description != null)
              _buildDetailRow('Deskripsi', product.description!),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: CupertinoColors.systemOrange,
                    borderRadius: BorderRadius.circular(12),
                    child: const Text(
                      'EDIT',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _editProduct(product),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: CupertinoColors.systemRed,
                    borderRadius: BorderRadius.circular(12),
                    child: const Text(
                      'HAPUS',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _confirmDeleteProduct(product),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: CupertinoColors.systemGreen,
                    borderRadius: BorderRadius.circular(12),
                    child: const Text(
                      'BELI',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                      _addToCart(product);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: 280, // Tambah height dari 250 ke 280
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: CupertinoColors.darkBackgroundGray,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Metode Pembayaran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                // Gunakan Expanded untuk mengisi ruang yang tersedia
                child: Column(
                  children: [
                    _buildPaymentOption('Tunai', PaymentMethod.cash, setState),
                    const SizedBox(height: 8), // Tambah spacing antar opsi
                    _buildPaymentOption('QRIS', PaymentMethod.qris, setState),
                    const SizedBox(height: 8),
                    _buildPaymentOption(
                      'Transfer Bank',
                      PaymentMethod.transfer,
                      setState,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String title,
    PaymentMethod method, [
    StateSetter? dialogSetState,
  ]) {
    final isSelected = _selectedPaymentMethod == method;
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ), // Kurangi padding vertical
      child: Container(
        padding: const EdgeInsets.all(10), // Kurangi padding container
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.systemBlue.withOpacity(0.2)
              : CupertinoColors.darkBackgroundGray,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? CupertinoColors.systemBlue
                : CupertinoColors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
              color: isSelected
                  ? CupertinoColors.systemBlue
                  : CupertinoColors.white.withOpacity(0.6),
              size: 20, // Kurangi ukuran icon
            ),
            const SizedBox(width: 10), // Kurangi spacing
            Text(
              title,
              style: TextStyle(
                fontSize: 15, // Kurangi ukuran font
                color: isSelected
                    ? CupertinoColors.white
                    : CupertinoColors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      onPressed: () {
        if (!mounted) return;

        // Update state utama
        setState(() {
          _selectedPaymentMethod = method;
        });

        // Update state dialog jika tersedia
        if (dialogSetState != null) {
          dialogSetState(() {});
        }

        // Tutup dialog dengan aman
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  void _showAddProductDialog() {
    if (!mounted) return;

    setState(() {
      _navigationState = NavigationState.navigatingToAddProduct;
    });

    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const AddProductScreen()),
    ).then((_) {
      if (!mounted) return;

      setState(() {
        _navigationState = NavigationState.idle;
      });
      // Refresh produk setelah kembali dari AddProductScreen
      _loadProducts();
    });
  }

  void _showTransactionHistory() {
    if (!mounted) return;

    setState(() {
      _navigationState = NavigationState.navigatingToTransactionHistory;
    });

    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => TransactionHistoryScreen()),
    ).then((_) {
      if (!mounted) return;

      setState(() {
        _navigationState = NavigationState.idle;
      });
    });
  }

  void _processPayment() {
    if (_cartItems.isEmpty) return;

    final totalPrice = _cartItems.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    // Handle berbagai metode pembayaran
    if (_selectedPaymentMethod == PaymentMethod.cash) {
      _showCashInputScreen(totalPrice);
    } else if (_selectedPaymentMethod == PaymentMethod.qris) {
      _showQRISPaymentScreen(totalPrice);
    } else if (_selectedPaymentMethod == PaymentMethod.transfer) {
      _showBankTransferScreen(totalPrice);
    } else {
      // Untuk metode pembayaran lainnya, langsung konfirmasi
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Konfirmasi Pembayaran'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total: Rp ${totalPrice.toStringAsFixed(0)}'),
              Text('Metode: ${_getPaymentMethodText(_selectedPaymentMethod)}'),
              const SizedBox(height: 8),
              const Text('Lanjutkan pembayaran?'),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Batal'),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Bayar'),
              onPressed: () async {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                await _completePayment();
              },
            ),
          ],
        ),
      );
    }
  }

  void _showCashInputScreen(double totalPrice) {
    if (!mounted) return;

    setState(() {
      _navigationState = NavigationState.navigatingToCashInput;
    });

    // Tutup dialog payment method terlebih dahulu
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // Tunggu sebentar sebelum navigasi ke cash input screen
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => CashInputScreen(
            totalAmount: totalPrice,
            cartItems: List<ShoppingCartItem>.from(_cartItems),
            paymentMethod: _selectedPaymentMethod,
          ),
        ),
      ).then((result) {
        if (!mounted) return;

        setState(() {
          _navigationState = NavigationState.idle;
        });

        if (result != null && result is Map<String, dynamic>) {
          final cashAmount = result['cashAmount'] as double;
          final change = result['change'] as double;
          _completePayment(cashAmount: cashAmount, change: change);
        }
      });
    });
  }

  void _showQRISPaymentScreen(double totalPrice) {
    if (!mounted) return;

    setState(() {
      _navigationState = NavigationState.navigatingToQRISPayment;
    });

    // Tutup dialog payment method terlebih dahulu
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // Tunggu sebentar sebelum navigasi ke QRIS screen
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => QRISPaymentScreen(
            totalAmount: totalPrice,
            cartItems: List<ShoppingCartItem>.from(_cartItems),
          ),
        ),
      ).then((result) {
        if (!mounted) return;

        setState(() {
          _navigationState = NavigationState.idle;
        });

        if (result != null && result == true) {
          // QRIS payment successful, complete the transaction
          print('DEBUG: QRIS payment returned true, calling _completePayment');
          _completePayment(paymentMethod: PaymentMethod.qris);
        } else {
          print('DEBUG: QRIS payment result: $result');
        }
      });
    });
  }

  void _showBankTransferScreen(double totalPrice) {
    if (!mounted) return;

    setState(() {
      _navigationState = NavigationState.navigatingToBankTransfer;
    });

    // Tutup dialog payment method terlebih dahulu
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // Tunggu sebentar sebelum menampilkan dialog transfer bank
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Transfer Bank'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Silakan transfer ke rekening berikut:'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.darkBackgroundGray,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: CupertinoColors.systemGrey4,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bank: BCA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.white,
                        ),
                      ),
                      const Text(
                        'No. Rekening: 1234567890',
                        style: TextStyle(color: CupertinoColors.white),
                      ),
                      const Text(
                        'Atas Nama: Workshop Manager',
                        style: TextStyle(color: CupertinoColors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jumlah: Rp ${totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.systemGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Setelah transfer, klik "Sudah Transfer" untuk melanjutkan.',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  if (mounted) {
                    setState(() {
                      _navigationState = NavigationState.idle;
                    });
                  }
                },
                child: const Text('Batal'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  if (mounted) {
                    setState(() {
                      _navigationState = NavigationState.idle;
                    });
                    print(
                      'DEBUG: Bank transfer confirmed, calling _completePayment',
                    );
                    _completePayment(paymentMethod: PaymentMethod.transfer);
                  }
                },
                child: const Text('Sudah Transfer'),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> _completePayment({
    double? cashAmount,
    double? change,
    PaymentMethod? paymentMethod,
  }) async {
    if (!mounted) return;

    setState(() {
      _navigationState = NavigationState.processingPayment;
    });

    final totalPrice = _cartItems.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    // Create transaction
    final transaction = Transaction(
      id: 'T${DateTime.now().millisecondsSinceEpoch}',
      vehicleId: 'CASHIER',
      customerName: 'Pelanggan Umum',
      services: _cartItems
          .map(
            (item) => ServiceItem(
              name: item.product.name,
              price: item.product.price,
              quantity: item.quantity,
            ),
          )
          .toList(),
      totalAmount: totalPrice,
      paymentMethod: paymentMethod ?? _selectedPaymentMethod,
      status: TransactionStatus.paid,
      createdAt: DateTime.now(),
      paidAt: DateTime.now(),
      cashAmount: cashAmount,
      changeAmount: change,
    );

    // Update stock in database
    try {
      for (final item in _cartItems) {
        final productIndex = _products.indexWhere(
          (p) => p.id == item.product.id,
        );
        if (productIndex >= 0) {
          final updatedProduct = _products[productIndex].copyWith(
            stock: _products[productIndex].stock - item.quantity as int,
          );
          await _databaseHelper.updateProduct(updatedProduct);
          _products[productIndex] = updatedProduct;
        }
      }
    } catch (e) {
      if (!mounted) return;

      // Tampilkan error jika gagal update stok
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error Update Stok'),
          content: Text('Gagal update stok produk: ${e.toString()}'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      );

      setState(() {
        _navigationState = NavigationState.idle;
      });
      return;
    }

    setState(() {
      _cartItems.clear();
    });

    // Simpan transaksi ke database
    try {
      print('DEBUG: Attempting to save transaction to database...');
      final result = await _databaseHelper.insertTransaction(transaction);
      print('DEBUG: Transaction saved successfully with result: $result');
    } catch (e) {
      print('DEBUG: Error saving transaction: $e');
      if (!mounted) return;

      // Tampilkan error jika gagal menyimpan transaksi
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error Transaksi'),
          content: Text('Gagal menyimpan transaksi: ${e.toString()}'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      );

      setState(() {
        _navigationState = NavigationState.idle;
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _navigationState = NavigationState.navigatingToReceipt;
    });

    // Tampilkan receipt screen dan kembali ke cashier setelah selesai
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ReceiptScreen(
          transaction: transaction,
          cashAmount: _selectedPaymentMethod == PaymentMethod.cash
              ? cashAmount
              : null,
          change: _selectedPaymentMethod == PaymentMethod.cash ? change : null,
        ),
      ),
    ).then((result) {
      if (!mounted) return;

      setState(() {
        _navigationState = NavigationState.idle;
      });
      // Jika user menekan selesai, kembali ke dashboard dengan aman
      if (result == 'completed') {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  void _editProduct(Product product) {
    // Tutup dialog detail dulu
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // Navigasi ke layar edit produk
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    ).then((_) {
      // Refresh daftar produk setelah edit
      _loadProducts();
    });
  }

  void _confirmDeleteProduct(Product product) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Hapus Produk'),
        content: Text(
          'Apakah Anda yakin ingin menghapus produk "${product.name}"?',
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Batal'),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Hapus'),
            onPressed: () async {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              await _deleteProduct(product);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      // Cek apakah produk ada di keranjang
      final isInCart = _cartItems.any((item) => item.product.id == product.id);
      if (isInCart) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Produk di Keranjang'),
            content: Text(
              'Produk "${product.name}" sedang ada di keranjang. Hapus dari keranjang terlebih dahulu.',
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('OK'),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
        return;
      }

      // Hapus produk dari database
      await _databaseHelper.deleteProduct(product.id);

      // Tutup dialog detail produk
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Refresh daftar produk
      await _loadProducts();

      // Tampilkan pesan sukses
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Berhasil'),
          content: Text('Produk "${product.name}" berhasil dihapus.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      );
    } catch (e) {
      // Tampilkan pesan error
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Gagal menghapus produk: ${e.toString()}'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      );
    }

    void _editProduct(Product product) {
      // Tutup dialog detail dulu
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Navigasi ke layar edit produk
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => EditProductScreen(product: product),
        ),
      ).then((_) {
        // Refresh daftar produk setelah edit
        _loadProducts();
      });
    }
  }
}
