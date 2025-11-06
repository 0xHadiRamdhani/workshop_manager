import 'product.dart';

class ShoppingCartItem {
  final Product product;
  final int quantity;

  const ShoppingCartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;

  // Method untuk membuat copy dengan quantity baru
  ShoppingCartItem copyWith({int? quantity}) {
    return ShoppingCartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}
