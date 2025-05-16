import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/Cart.dart';
import '../../models/Product.dart';
import 'components/cart_card.dart';
import 'components/check_out_card.dart';
import 'package:smartshopflutter/components/save_details.dart'; // For getUserID()

class CartScreen extends StatefulWidget {
  static String routeName = "/cart";
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  /// Stream that listens to the cart collection and resolves Product data
  Stream<List<Cart>> cartStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Cart> cartItems = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(data['productId'])
            .get();

        if (productDoc.exists) {
          final product = await _resolveProductWithUrls(productDoc);
          cartItems.add(Cart(product: product, numOfItem: data['quantity']));
        }
      }
      return cartItems;
    });
  }

  Future<Product> _resolveProductWithUrls(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data()!;
    final rawPaths = List<String>.from(data['images'] ?? []);
    final downloadUrls = await Future.wait(
      rawPaths
          .map((path) => FirebaseStorage.instance.ref(path).getDownloadURL()),
    );
    data['images'] = downloadUrls;
    return Product.fromFirestore(data, doc.id);
  }

  /// Remove a cart item by productId
  Future<void> removeCartItem(String userId, String productId) async {
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart');

    final cartDocs =
        await cartRef.where('productId', isEqualTo: productId).get();

    for (var doc in cartDocs.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getUserID(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Loading user ID
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final userId = snapshot.data!;
        return StreamBuilder<List<Cart>>(
          stream: cartStream(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Waiting for cart stream data
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              // Handle error
              return Scaffold(
                body: Center(
                    child: Text('Error loading cart: ${snapshot.error}')),
              );
            }

            final cartItems = snapshot.data ?? [];

            // Calculate totals
            double totalPrice = 0.0;
            int totalQuantity = 0;
            for (var item in cartItems) {
              totalPrice += item.product.price * item.numOfItem;
              totalQuantity += item.numOfItem;
            }

            return Scaffold(
              appBar: AppBar(
                title: Column(
                  children: [
                    const Text("Your Cart",
                        style: TextStyle(color: Colors.black)),
                    Text(
                      "$totalQuantity items",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              body: cartItems.isEmpty
                  ? const Center(child: Text("Your cart is empty."))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final cartItem = cartItems[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Dismissible(
                              key: Key(cartItem.product.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) async {
                                await removeCartItem(
                                    userId, cartItem.product.id);
                              },
                              background: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE6E6),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    SvgPicture.asset("assets/icons/Trash.svg"),
                                  ],
                                ),
                              ),
                              child: CartCard(cart: cartItem),
                            ),
                          );
                        },
                      ),
                    ),
              bottomNavigationBar: CheckoutCard(
                totalPrice: totalPrice,
                totalQuantity: totalQuantity,
              ),
            );
          },
        );
      },
    );
  }
}
