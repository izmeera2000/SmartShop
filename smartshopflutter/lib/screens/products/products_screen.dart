import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartshopflutter/components/product_card.dart';
import 'package:smartshopflutter/models/Product.dart';
import '../details/details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductsScreen extends StatelessWidget {
  static const String routeName = "/products";
  const ProductsScreen({super.key});

  // Fetch products but exclude the ones belonging to the current user
  Future<List<Product>> fetchProducts() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        // If there's no user logged in, return an empty list
        return [];
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('userId', isNotEqualTo: userId)  // Exclude products by the current user
          .get();

      return snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      body: FutureBuilder<List<Product>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final products = snapshot.data;
          if (products == null || products.isEmpty) {
            return const Center(child: Text("No products available"));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.7,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onPress: () {
                    Navigator.pushNamed(
                      context,
                      DetailsScreen.routeName,
                      arguments: ProductDetailsArguments(product: product),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
