import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth for user ID

import '../../../components/product_card.dart';
import '../../../models/Product.dart';
import '../../details/details_screen.dart';
import '../../products/products_screen.dart';
import 'section_title.dart';

class PopularProducts extends StatelessWidget {
  const PopularProducts({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user's ID
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
            title: "Popular Products",
            press: () {
              Navigator.pushNamed(context, ProductsScreen.routeName);
            },
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('isPopular', isEqualTo: true) // Fetch all popular products
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(child: Text("No popular products found."));
            }

            // Filter the products to exclude those that belong to the current user
            final popularProducts = docs.map((doc) {
              final data = doc.data()! as Map<String, dynamic>;
              return Product.fromFirestore(data, doc.id);
            }).toList();

            // Filter out products that belong to the current user
            final filteredProducts = popularProducts.where((product) {
              return product.userId != userId;  // Exclude the current user's products
            }).toList();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (filteredProducts.isEmpty) 
                    const Center(child: Text("No popular products available"))
                  else
                    ...filteredProducts.map((product) => Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: ProductCard(
                            product: product,
                            onPress: () => Navigator.pushNamed(
                              context,
                              DetailsScreen.routeName,
                              arguments: ProductDetailsArguments(product: product),
                            ),
                          ),
                        )),
                  const SizedBox(width: 20),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
