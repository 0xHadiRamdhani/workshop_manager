import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String? imageUrl;
  final String? description;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.description,
    required this.createdAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? imageUrl,
    String? description,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}
