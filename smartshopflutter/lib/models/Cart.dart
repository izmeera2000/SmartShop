import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Product.dart';

class Cart {
  final Product product;
  final int numOfItem;

  Cart({required this.product, required this.numOfItem});
}

Future<List<Cart>> fetchCartItemsFromFirestore(String userId) async {
  final cartSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('cart')
      .get();

  List<Cart> cartItems = [];

  for (var doc in cartSnapshot.docs) {
    final cartData = doc.data();
    final productId = cartData['productId'];
    final numOfItem = cartData['numOfItem'];

    // Fetch product details
    final productDoc = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();

    if (productDoc.exists) {
      final data = productDoc.data()!;
      final product = Product(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        images: List<String>.from(data['images']),
        colors: (data['colors'] as List)
            .map((hex) => Color(int.parse(hex)))
            .toList(),
        rating: (data['rating'] as num).toDouble(),
        price: (data['price'] as num).toDouble(),
        isFavourite: data['isFavourite'],
        isPopular: data['isPopular'],
      );

      cartItems.add(Cart(product: product, numOfItem: numOfItem));
    }
  }

  return cartItems;
}
