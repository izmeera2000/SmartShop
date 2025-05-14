import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartshopflutter/components/product_card.dart';
import 'package:smartshopflutter/models/Product.dart';

import '../details/details_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Text(
            "Favorites",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          // Expanded(
          //   child: Padding(
          //     padding: const EdgeInsets.all(16),
          //     child: StreamBuilder<QuerySnapshot>(
          //       stream: FirebaseFirestore.instance
          //           .collection('products')
          //           .where('isFavourite', isEqualTo: true)
          //           .snapshots(),
          //       builder: (context, snapshot) {
          //         if (snapshot.connectionState == ConnectionState.waiting) {
          //           return const Center(child: CircularProgressIndicator());
          //         }

          //         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          //           return const Center(child: Text("No favorite products found."));
          //         }

          //         final favoriteProducts = snapshot.data!.docs.map((doc) {
          //           final data = doc.data() as Map<String, dynamic>;

          //           // Safely create Product instances, ensuring no null fields
          //           return Product(
          //             id: doc.id, // Use doc.id for the product ID
          //             title: data['title'] ?? 'Unknown Title',
          //             description: data['description'] ?? 'No description available',
          //             images: List<String>.from(data['images'] ?? []),
          //             rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          //             price: (data['price'] as num?)?.toDouble() ?? 0.0,
          //             isFavourite: data['isFavourite'] ?? false,
          //             isPopular: data['isPopular'] ?? false,
          //             userId: data['userId'] ?? '', // Include userId if needed
          //           );
          //         }).toList();

          //         return GridView.builder(
          //           itemCount: favoriteProducts.length,
          //           gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          //             maxCrossAxisExtent: 200,
          //             childAspectRatio: 0.7,
          //             mainAxisSpacing: 20,
          //             crossAxisSpacing: 16,
          //           ),
          //           itemBuilder: (context, index) => ProductCard(
          //             product: favoriteProducts[index],
          //             onPress: () => Navigator.pushNamed(
          //               context,
          //               DetailsScreen.routeName,
          //               arguments: ProductDetailsArguments(product: favoriteProducts[index]),
          //             ),
          //           ),
          //         );
          //       },
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
