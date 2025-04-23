import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartshopflutter/components/product_card.dart';
import 'package:smartshopflutter/models/Product.dart';
import '../details/details_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProductsScreen extends StatelessWidget {
  static const String routeName = "/products";
  const ProductsScreen({super.key});

  Future<List<Product>> fetchProducts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .get();

    // Ensure you're passing both data and docId for each product
    return snapshot.docs
        .map((doc) => Product.fromFirestore(doc.data(), doc.id))
        .toList();
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
