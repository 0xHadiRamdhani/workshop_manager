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

// Enum untuk state navigasi yang lebih jelas
enum NavigationState {
  idle,
  navigatingToAddProduct,
  navigatingToTransactionHistory,
  navigatingToCashInput,
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
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error - tampilkan pesan error atau gunakan data default
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
    final totalItems = _cartItems.fold(
      0,
      (sum, item) => sum + item.quantity as int,
    );
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
    final totalItems = _cartItems.fold(
      0,
      (sum, item) => sum + item.quantity as int,
    );

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
        return 'Transfer';
      case PaymentMethod.card:
        return 'Kartu';
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
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );
      if (existingIndex >= 0) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(ShoppingCartItem(product: product));
      }
    });
  }

  void _showCartDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: CupertinoColors.darkBackgroundGray,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            _buildCartHeader(),
            Expanded(child: _buildCartItems()),
            _buildCartFooter(),
          ],
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

  Widget _buildCartItems() {
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
        return _buildShoppingCartItem(item);
      },
    );
  }

  Widget _buildShoppingCartItem(ShoppingCartItem item) {
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
                onPressed: () => _updateQuantity(item as ShoppingCartItem, -1),
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
                onPressed: () => _updateQuantity(item as ShoppingCartItem, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartFooter() {
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
                Navigator.pop(context);
                _processPayment();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(ShoppingCartItem item, int change) {
    setState(() {
      item.quantity += change;
      if (item.quantity <= 0) {
        _cartItems.remove(item);
      }
    });
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
                  onPressed: () => Navigator.pop(context),
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
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: CupertinoColors.systemGreen,
                borderRadius: BorderRadius.circular(12),
                child: const Text(
                  'TAMBAH KE KERANJANG',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _addToCart(product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
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
            _buildPaymentOption('Tunai', PaymentMethod.cash),
            _buildPaymentOption('Transfer Bank', PaymentMethod.transfer),
            _buildPaymentOption('Kartu Debit/Kredit', PaymentMethod.card),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method;
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.systemBlue.withOpacity(0.2)
              : CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? CupertinoColors.systemBlue
                : CupertinoColors.systemGrey4,
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
                  : CupertinoColors.systemGrey,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isSelected
                    ? CupertinoColors.white
                    : CupertinoColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      onPressed: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showAddProductDialog() {
    setState(() {
      _navigationState = NavigationState.navigatingToAddProduct;
    });

    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const AddProductScreen()),
    ).then((_) {
      setState(() {
        _navigationState = NavigationState.idle;
      });
      // Refresh produk setelah kembali dari AddProductScreen
      _loadProducts();
    });
  }

  void _showTransactionHistory() {
    setState(() {
      _navigationState = NavigationState.navigatingToTransactionHistory;
    });

    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => TransactionHistoryScreen()),
    ).then((_) {
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

    // Jika metode pembayaran adalah cash, tampilkan input uang cash
    if (_selectedPaymentMethod == PaymentMethod.cash) {
      _showCashInputScreen(totalPrice);
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
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Bayar'),
              onPressed: () async {
                Navigator.pop(context);
                await _completePayment();
              },
            ),
          ],
        ),
      );
    }
  }

  void _showCashInputScreen(double totalPrice) {
    setState(() {
      _navigationState = NavigationState.navigatingToCashInput;
    });

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
      setState(() {
        _navigationState = NavigationState.idle;
      });

      if (result != null && result is Map<String, dynamic>) {
        final cashAmount = result['cashAmount'] as double;
        final change = result['change'] as double;
        _completePayment(cashAmount: cashAmount, change: change);
      }
    });
  }

  Future<void> _completePayment({double? cashAmount, double? change}) async {
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
      paymentMethod: _selectedPaymentMethod,
      status: TransactionStatus.paid,
      createdAt: DateTime.now(),
      paidAt: DateTime.now(),
      cashAmount: cashAmount,
      changeAmount: change,
    );

    // Update stock in database
    for (final item in _cartItems) {
      final productIndex = _products.indexWhere((p) => p.id == item.product.id);
      if (productIndex >= 0) {
        final updatedProduct = _products[productIndex].copyWith(
          stock: _products[productIndex].stock - item.quantity as int,
        );
        await _databaseHelper.updateProduct(updatedProduct);
        _products[productIndex] = updatedProduct;
      }
    }

    setState(() {
      _cartItems.clear();
    });

    // Simpan transaksi ke database
    await _databaseHelper.insertTransaction(transaction);

    setState(() {
      _navigationState = NavigationState.navigatingToReceipt;
    });

    // Tampilkan receipt screen dan kembali ke cashier setelah selesai
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ReceiptScreen(
          transaction: transaction,
          cashAmount: cashAmount,
          change: change,
        ),
      ),
    ).then((result) {
      setState(() {
        _navigationState = NavigationState.idle;
      });
      // Jika user menekan selesai, kembali ke dashboard
      if (result == 'completed') {
        Navigator.of(context).pop();
      }
    });
  }
}
