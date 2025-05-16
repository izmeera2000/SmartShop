// lib/screens/products/products_screen.dart

import 'package:flutter/material.dart';
import 'package:smartshopflutter/components/product_card.dart';
import 'package:smartshopflutter/models/Product.dart';
import 'package:smartshopflutter/repositories/products_repository.dart';
import '../details/details_screen.dart';

class ProductsScreen extends StatelessWidget {
  static const String routeName = "/products";
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force refresh
              ProductsRepository.clearCache();
              (context as Element).reassemble();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: ProductsRepository.fetchAllProducts(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }
          final products = snap.data;
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
