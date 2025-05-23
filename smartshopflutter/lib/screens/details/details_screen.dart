import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartshopflutter/components/save_details.dart';
import 'package:smartshopflutter/screens/cart/cart_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/Product.dart';
import 'components/color_dots.dart';
import 'components/product_description.dart';
import 'components/product_images.dart';
import 'components/top_rounded_container.dart';

class DetailsScreen extends StatelessWidget {
  static String routeName = "/details";

  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductDetailsArguments agrs =
        ModalRoute.of(context)!.settings.arguments as ProductDetailsArguments;
    final product = agrs.product;

    int quantity = 1; // Local variable, will be handled inside StatefulBuilder

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              elevation: 0,
              backgroundColor: Colors.white,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Text(
                      "4.7",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset("assets/icons/Star Icon.svg"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StatefulBuilder(
        // 👈 wrap body with StatefulBuilder
        builder: (context, setState) {
          return ListView(
            children: [
              ProductImages(product: product),
              TopRoundedContainer(
                color: Colors.white,
                child: Column(
                  children: [
                    ProductDescription(
                      product: product,
                      pressOnSeeMore: () {},
                    ),
                    TopRoundedContainer(
                      color: const Color(0xFFF6F7F9),
                      child: Column(
                        children: [
                          ColorDots(
                            product: product,
                            quantity: quantity,
                            incrementQuantity: () {
                              setState(() {
                                quantity++;
                              });
                            },
                            decrementQuantity: () {
                              setState(() {
                                if (quantity > 1) quantity--;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: TopRoundedContainer(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  String? userId = await getUserID();
                  if (userId == null) {
                    debugPrint('❌ No user ID found');
                    return;
                  }

                  FirebaseFirestore firestore = FirebaseFirestore.instance;

                  // Reference to the product in the user's cart
                  var cartRef = firestore
                      .collection('users')
                      .doc(userId)
                      .collection('cart')
                      .doc(product.id);

                  // Get the current cart item
                  DocumentSnapshot cartSnapshot = await cartRef.get();

                  if (cartSnapshot.exists) {
                    // If the product already exists in the cart, increment the quantity
                    int currentQuantity = cartSnapshot.get('quantity') ?? 0;
                    cartRef.update({
                      'quantity':
                          currentQuantity + quantity, // Increment the quantity
                    });

                    debugPrint(
                        '✅ Updated quantity to: ${currentQuantity + quantity}');
                  } else {
                    // If the product doesn't exist, add it to the cart with the current quantity
                    Map<String, dynamic> cartItem = {
                      'productId': product.id,
                      'title': product.title,
                      'price': product.price,
                      'images': product.images.isNotEmpty ? product.images : [],
                      'quantity': quantity, // Add the initial quantity
                    };

                    await cartRef.set(cartItem);
                    debugPrint('✅ Product added to cart with quantity: $quantity');
                  }
                } catch (e) {
                  debugPrint('❌ Failed to add/update product in cart: $e');
                }
              },
              child: const Text("Add To Cart"),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductDetailsArguments {
  final Product product;

  ProductDetailsArguments({required this.product});
}
