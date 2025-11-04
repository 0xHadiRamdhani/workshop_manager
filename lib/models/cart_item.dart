import 'product.dart';

class ShoppingCartItem {
  final Product product;
  int quantity;

  ShoppingCartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}
