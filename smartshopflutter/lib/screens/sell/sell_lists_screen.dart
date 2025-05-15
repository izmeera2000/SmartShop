import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartshopflutter/components/save_details.dart';
import 'package:smartshopflutter/models/Product.dart';
import 'package:smartshopflutter/components/product_card.dart';
import 'package:smartshopflutter/screens/sell/sell_edit_screen.dart';
import 'package:smartshopflutter/screens/sell/sell_screen.dart'; // Import the upload screen

class SellListScreen extends StatelessWidget {
  static const String routeName = "/sell_list";
  const SellListScreen({Key? key})
      : super(key: key); // ✅ make constructor const

  Future<List<Product>> fetchProducts() async {
    String? userId = await getUserID();

    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('userId', isEqualTo: userId) // 🔥 filter by userId
        .get();
    return snapshot.docs
        .map((doc) => Product.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product List")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Product>>(
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

            return GridView.builder(
              shrinkWrap: true,
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.7,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                // debugPrint(product.images[0]);
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
        onPressed: () {
          // Navigate to the Upload Product screen
          Navigator.pushNamed(context, SellScreen.routeName);
        },
        child: const Icon(Icons.add),
        tooltip: "Upload New Product",
      ),
    );
  }
}
