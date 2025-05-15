import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Product.dart';

class Cart {
  final Product product;
  final int numOfItem;

  Cart({required this.product, required this.numOfItem});
}

Future<List<Cart>> fetchCartItemsFromFirestore(String userId) async {
  try {
    // Fetch the cart collection for the given user directly
    final cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    List<Cart> cartItems = [];

    // Loop through all cart documents and add them to the cartItems list
    for (var doc in cartSnapshot.docs) {
      final cartData = doc.data() as Map<String, dynamic>;

      // Get the productId from the document ID (which is the product ID)
      final productId = doc.id;

      // Calculate the quantity from the cart document or default to 1
      final numOfItem = cartData['quantity'] ?? 1;

      // Log the cart data for debugging
      debugPrint('cartData: $cartData');

      if (productId != null) {
        // Safely get each field from cartData using null-aware operators
        final title = cartData['title'] ?? 'Unknown Title'; // Default value if null
        final description = cartData['description'] ?? 'No description available';

        // Debugging: log the 'images' field and its type
        debugPrint('images field: ${cartData['images']}');
        debugPrint('images field type: ${cartData['images'].runtimeType}');

        List<String> images = [];
        if (cartData['images'] is List) {
          images = List<String>.from(cartData['images']);
        } else if (cartData['images'] != null) {
          images = [cartData['images'].toString()];
        }
final stock = (cartData['stock'] as num?)?.toInt() ?? 0; // ✅ Default to 0 if null

        final rating = (cartData['rating'] as num?)?.toDouble() ?? 0.0; // Default to 0.0 if null
        final price = (cartData['price'] as num?)?.toDouble() ?? 0.00;  // Default to 0.0 if null
        final isFavourite = cartData['isFavourite'] ?? false; // Default to false if null
        final isPopular = cartData['isPopular'] ?? false;   // Default to false if null

        // Create a Product object directly from the cart data
    final product = Product(
  id: productId,
  title: title,
  description: description,
  images: images,
  rating: rating,
  price: price,
  isFavourite: isFavourite,
  isPopular: isPopular,
  userId: cartData['userId'] ?? '', // User ID
  stock: stock, // ✅ Add this line
);

        // Add the cart item to the cartItems list
        cartItems.add(Cart(product: product, numOfItem: numOfItem));
      } else {
        debugPrint('Missing productId in cart data');
      }
    }

    // Log the total number of items in the cart
    debugPrint('Total number of items in cart: ${cartItems.length}');

    return cartItems;
  } catch (e) {
    debugPrint('Error fetching cart items: $e');
    return [];
  }
}
