import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartshopflutter/components/save_details.dart';

import '../../models/Product.dart';
import 'components/color_dots.dart';
import 'components/product_description.dart';
import 'components/product_images.dart';
import 'components/top_rounded_container.dart';

class DetailsScreen extends StatefulWidget {
  static String routeName = "/details";

  const DetailsScreen({super.key});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int quantity = 1;
  bool _isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ProductDetailsArguments;
    final product = args.product;

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
            onPressed: () => Navigator.pop(context),
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
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
      body: ListView(
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
                  child: ColorDots(
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
                ),
                
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: TopRoundedContainer(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ElevatedButton(
              onPressed: _isAddingToCart ? null : () async {
                setState(() {
                  _isAddingToCart = true;
                });

                try {
                  String? userId = await getUserID();
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please login to add items to your cart')),
                    );
                    setState(() {
                      _isAddingToCart = false;
                    });
                    return;
                  }

                  FirebaseFirestore firestore = FirebaseFirestore.instance;
                  var cartRef = firestore.collection('users').doc(userId).collection('cart').doc(product.id);
                  DocumentSnapshot cartSnapshot = await cartRef.get();

                  if (cartSnapshot.exists) {
                    int currentQuantity = cartSnapshot.get('quantity') ?? 0;
                    await cartRef.update({'quantity': currentQuantity + quantity});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Quantity updated to ${currentQuantity + quantity}')),
                    );
                  } else {
                    Map<String, dynamic> cartItem = {
                      'productId': product.id,
                      'title': product.title,
                      'price': product.price,
                      'images': product.images.isNotEmpty ? product.images : [],
                      'quantity': quantity,
                    };
                    await cartRef.set(cartItem);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added $quantity item(s) to cart')),
                    );
                  }

                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add/update product in cart: $e')),
                  );
                } finally {
                  setState(() {
                    _isAddingToCart = false;
                  });
                }
              },
              child: _isAddingToCart
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text("Add To Cart"),
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

 