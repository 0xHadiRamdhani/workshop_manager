import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cashier_controller.dart';
import '../controllers/main_controller.dart';
import '../models/product.dart';

class CashierScreen extends StatelessWidget {
  const CashierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CashierController controller = Get.put(CashierController());

    return Obx(() {
      if (controller.isLoading.value) {
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
          leading: IconButton(
            onPressed: () {
              // Gunakan controller untuk membuka drawer
              final mainController = Get.find<MainController>();
              mainController.openDrawer();
            },
            icon: Icon(CupertinoIcons.bars),
          ),
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
                child: Icon(
                  CupertinoIcons.refresh,
                  color: CupertinoColors.systemBlue,
                ),
                onPressed: controller.refreshProducts,
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.add,
                  color: CupertinoColors.systemBlue,
                ),
                onPressed: controller.showAddProductDialog,
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchAndFilterSection(controller),
              _buildCartSummary(controller),
              Expanded(child: _buildProductGrid(controller)),
              _buildCheckoutSection(controller),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSearchAndFilterSection(CashierController controller) {
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
            controller: controller.searchController,
            placeholder: 'Cari produk...',
            prefix: const Icon(
              CupertinoIcons.search,
              color: CupertinoColors.systemGrey,
            ),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(8),
            ),
            onChanged: (value) => controller.update(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('Semua', controller),
                _buildCategoryChip('Oli', controller),
                _buildCategoryChip('Rem', controller),
                _buildCategoryChip('Mesin', controller),
                _buildCategoryChip('Transmisi', controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, CashierController controller) {
    return Obx(() {
      final isSelected = controller.selectedCategory.value == category;
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
          onPressed: () => controller.selectedCategory.value = category,
        ),
      );
    });
  }

  Widget _buildCartSummary(CashierController controller) {
    return Obx(() {
      final totalItems = controller.totalCartItems;
      final totalPrice = controller.totalCartPrice;

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
              onPressed: () => _showCartDialog(controller),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProductGrid(CashierController controller) {
    return Obx(() {
      final filteredProducts = controller.filteredProducts;

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
          return _buildProductCard(product, controller);
        },
      );
    });
  }

  Widget _buildProductCard(Product product, CashierController controller) {
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
                        onPressed: () =>
                            _showProductDetail(product, controller),
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
                        onPressed: () => controller.addToCart(product),
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

  Widget _buildCheckoutSection(CashierController controller) {
    return Obx(() {
      final totalPrice = controller.totalCartPrice;
      final totalItems = controller.totalCartItems;

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
                    Obx(
                      () => CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(8),
                        child: Text(
                          _getPaymentMethodText(
                            controller.selectedPaymentMethod.value,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onPressed: () => _showPaymentMethodDialog(controller),
                      ),
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
                onPressed: controller.cartItems.isEmpty
                    ? null
                    : controller.processPayment,
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showCartDialog(CashierController controller) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: CupertinoColors.darkBackgroundGray,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            _buildCartHeader(controller),
            Expanded(child: _buildCartItems(controller)),
            _buildCartFooter(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildCartHeader(CashierController controller) {
    final totalItems = controller.totalCartItems;

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

  Widget _buildCartItems(CashierController controller) {
    if (controller.cartItems.isEmpty) {
      return const Center(
        child: Text(
          'Keranjang kosong',
          style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.cartItems.length,
      itemBuilder: (context, index) {
        final item = controller.cartItems[index];
        return _buildShoppingCartItem(item, controller);
      },
    );
  }

  Widget _buildShoppingCartItem(item, CashierController controller) {
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
                onPressed: () => controller.updateQuantity(item, -1),
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
                onPressed: () => controller.updateQuantity(item, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartFooter(CashierController controller) {
    final totalPrice = controller.totalCartPrice;

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
                Get.back();
                controller.processPayment();
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showProductDetail(Product product, CashierController controller) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.5,
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
                  onPressed: () => Get.back(),
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
                    onPressed: () => controller.editProduct(product),
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
                    onPressed: () => controller.deleteProduct(product),
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
                      Get.back();
                      controller.addToCart(product);
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

  void _showPaymentMethodDialog(CashierController controller) {
    Get.bottomSheet(
      Container(
        height: 350,
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
              child: Column(
                children: [
                  _buildPaymentOption('Tunai', PaymentMethod.cash, controller),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    'Transfer Bank',
                    PaymentMethod.transfer,
                    controller,
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption('Hutang', PaymentMethod.debt, controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String title,
    PaymentMethod method,
    CashierController controller,
  ) {
    return Obx(() {
      final isSelected = controller.selectedPaymentMethod.value == method;
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(10),
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
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
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
          controller.selectedPaymentMethod.value = method;
          Get.back();
        },
      );
    });
  }

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
      case PaymentMethod.debt:
        return 'Hutang';
    }
  }
}
