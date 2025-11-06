import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_manager/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('should create Product instance correctly', () {
      final product = Product(
        id: 'P001',
        name: 'Oli Motor',
        category: 'Oli',
        price: 45000,
        stock: 50,
        description: 'Oli motor premium',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(product.id, 'P001');
      expect(product.name, 'Oli Motor');
      expect(product.category, 'Oli');
      expect(product.price, 45000);
      expect(product.stock, 50);
      expect(product.description, 'Oli motor premium');
      expect(product.createdAt, DateTime(2024, 1, 1));
    });

    test('should create Product with null imageUrl and description', () {
      final product = Product(
        id: 'P002',
        name: 'Kampas Rem',
        category: 'Rem',
        price: 120000,
        stock: 25,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(product.imageUrl, isNull);
      expect(product.description, isNull);
    });

    test('copyWith should create new instance with updated values', () {
      final originalProduct = Product(
        id: 'P001',
        name: 'Oli Motor',
        category: 'Oli',
        price: 45000,
        stock: 50,
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedProduct = originalProduct.copyWith(
        name: 'Oli Motor Premium',
        price: 50000,
        stock: 60,
      );

      expect(updatedProduct.id, 'P001'); // Unchanged
      expect(updatedProduct.name, 'Oli Motor Premium'); // Updated
      expect(updatedProduct.category, 'Oli'); // Unchanged
      expect(updatedProduct.price, 50000); // Updated
      expect(updatedProduct.stock, 60); // Updated
      expect(updatedProduct.createdAt, DateTime(2024, 1, 1)); // Unchanged
    });

    test('copyWith should not modify original product', () {
      final originalProduct = Product(
        id: 'P001',
        name: 'Oli Motor',
        category: 'Oli',
        price: 45000,
        stock: 50,
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedProduct = originalProduct.copyWith(name: 'Oli Motor Baru');

      expect(originalProduct.name, 'Oli Motor');
      expect(updatedProduct.name, 'Oli Motor Baru');
    });
  });

  group('CartItem Model Tests', () {
    test('should create CartItem instance correctly', () {
      final product = Product(
        id: 'P001',
        name: 'Oli Motor',
        category: 'Oli',
        price: 45000,
        stock: 50,
        createdAt: DateTime(2024, 1, 1),
      );

      final cartItem = CartItem(product: product, quantity: 2);

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

      final cartItem = CartItem(product: product, quantity: 3);

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

      final cartItem = CartItem(product: product);

      expect(cartItem.quantity, 1);
      expect(cartItem.totalPrice, 45000); // 45000 * 1
    });
  });
}
