import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_manager/models/product.dart';
import 'package:workshop_manager/models/cart_item.dart';

void main() {
  group('ShoppingCartItem Model Tests', () {
    test('should create ShoppingCartItem instance correctly', () {
      final product = Product(
        id: 'P001',
        name: 'Oli Motor',
        category: 'Oli',
        price: 45000,
        stock: 50,
        description: 'Oli motor premium',
        createdAt: DateTime(2024, 1, 1),
      );

      final cartItem = ShoppingCartItem(product: product, quantity: 2);

      expect(cartItem.product, product);
      expect(cartItem.quantity, 2);
    });

    test('should calculate total price correctly', () {
      final product = Product(
        id: 'P001',
        name: 'Oli Motor',
        category: 'Oli',
        price: 45000,
        stock: 50,
        createdAt: DateTime(2024, 1, 1),
      );

      final cartItem = ShoppingCartItem(product: product, quantity: 3);

      expect(cartItem.totalPrice, 135000); // 45000 * 3
    });

    test('should default quantity to 1', () {
      final product = Product(
        id: 'P001',
        name: 'Oli Motor',
        category: 'Oli',
        price: 45000,
        stock: 50,
        createdAt: DateTime(2024, 1, 1),
      );

      final cartItem = ShoppingCartItem(product: product);

      expect(cartItem.quantity, 1);
      expect(cartItem.totalPrice, 45000); // 45000 * 1
    });

    test('should handle quantity updates using copyWith', () {
      final product = Product(
        id: 'P001',
        name: 'Oli Motor',
        category: 'Oli',
        price: 45000,
        stock: 50,
        createdAt: DateTime(2024, 1, 1),
      );

      final cartItem = ShoppingCartItem(product: product, quantity: 1);

      // Update quantity using copyWith
      final updatedCartItem = cartItem.copyWith(quantity: 5);

      expect(updatedCartItem.quantity, 5);
      expect(updatedCartItem.totalPrice, 225000); // 45000 * 5
      expect(cartItem.quantity, 1); // Original should remain unchanged
    });

    test('should handle decimal prices correctly', () {
      final product = Product(
        id: 'P002',
        name: 'Kampas Rem',
        category: 'Rem',
        price: 125.75,
        stock: 25,
        createdAt: DateTime(2024, 1, 1),
      );

      final cartItem = ShoppingCartItem(product: product, quantity: 2);

      expect(cartItem.totalPrice, 251.50); // 125.75 * 2
    });

    test('should handle zero quantity', () {
      final product = Product(
        id: 'P001',
        name: 'Oli Motor',
        category: 'Oli',
        price: 45000,
        stock: 50,
        createdAt: DateTime(2024, 1, 1),
      );

      final cartItem = ShoppingCartItem(product: product, quantity: 0);

      expect(cartItem.quantity, 0);
      expect(cartItem.totalPrice, 0); // 45000 * 0
    });

    test('should not modify product when changing quantity with copyWith', () {
      final product = Product(
        id: 'P001',
        name: 'Oli Motor',
        category: 'Oli',
        price: 45000,
        stock: 50,
        createdAt: DateTime(2024, 1, 1),
      );

      final cartItem = ShoppingCartItem(product: product, quantity: 2);

      // Change quantity using copyWith
      final updatedCartItem = cartItem.copyWith(quantity: 4);

      // Product should remain unchanged
      expect(product.name, 'Oli Motor');
      expect(product.price, 45000);
      expect(updatedCartItem.product, product);
      expect(cartItem.quantity, 2); // Original should remain unchanged
    });

    test('copyWith should work correctly', () {
      final product = Product(
        id: 'P001',
        name: 'Oli Motor',
        category: 'Oli',
        price: 45000,
        stock: 50,
        createdAt: DateTime(2024, 1, 1),
      );

      final cartItem = ShoppingCartItem(product: product, quantity: 3);

      // Test copyWith with new quantity
      final updatedItem = cartItem.copyWith(quantity: 7);
      expect(updatedItem.quantity, 7);
      expect(updatedItem.product, product); // Product should be the same
      expect(updatedItem.totalPrice, 315000); // 45000 * 7

      // Test copyWith without parameters (should return identical copy)
      final sameItem = cartItem.copyWith();
      expect(sameItem.quantity, 3);
      expect(sameItem.product, product);
    });
  });
}
