// lib/screens/sell/sell_list_screen.dart

import 'package:flutter/material.dart';
import 'package:smartshopflutter/components/product_card.dart';
import 'package:smartshopflutter/models/Product.dart';
import 'package:smartshopflutter/repositories/products_repository.dart';
import 'package:smartshopflutter/screens/sell/sell_edit_screen.dart';
import 'package:smartshopflutter/screens/sell/sell_screen.dart';

class SellListScreen extends StatelessWidget {
  static const String routeName = "/sell_list";
  const SellListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Products")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Product>>(
          future: ProductsRepository.fetchUserProducts(),
          builder: (ctx, snapshot) {
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

            return GridView.builder(
              itemCount: products.length,
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.7,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, idx) {
                final product = products[idx];
                return ProductCard(
                  product: product,
                  onPress: () {
                    Navigator.pushNamed(
                      context,
                      SellEditScreen.routeName,
                      arguments: product,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Upload New Product",
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, SellScreen.routeName);
        },
      ),
    );
  }
}
