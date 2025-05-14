// checkout_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartshopflutter/constants.dart';
import '../../models/Cart.dart';
import 'components/cart_card.dart';
import 'components/pay_now_card.dart';
import 'package:smartshopflutter/components/save_details.dart'; // for getUserID()

class CheckoutScreen extends StatefulWidget {
  static String routeName = "/checkout";
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<Cart> cartItems = [];
  bool isLoading = true;
  int selectedIndex = -1;

  List<String> deliveryAddresses = [
    "H-R-56, West street, Pennsylvania, USA.",
    "H-R-57, West street, Pennsylvania, USA."
  ];

  @override
  void initState() {
    super.initState();
    getUserID().then((userId) {
      if (userId != null) {
        loadCartFromFirestore(userId);
      }
    });
  }

  Future<void> loadCartFromFirestore(String userId) async {
    final items = await fetchCartItemsFromFirestore(userId);
    setState(() {
      cartItems = items;
      isLoading = false;
    });
  }

  Future<void> removeCartItem(String userId, String productId) async {
    debugPrint('Removing product with ID: $productId from cart for user: $userId'); // Logging product removal attempt
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart');

    final cartDocs = await cartRef.where('productId', isEqualTo: productId).get();
    if (cartDocs.docs.isEmpty) {
      debugPrint('No matching products found for product ID: $productId'); // Logging if no product was found
    }

    for (var doc in cartDocs.docs) {
      await doc.reference.delete();
      debugPrint('Product with ID: $productId removed from Firestore'); // Logging successful removal
    }
  }


  int getTotalQuantity() {
    return cartItems.fold(0, (sum, item) => sum + item.numOfItem);
  }

  double getTotalPrice() {
    return cartItems.fold(0, (sum, item) => sum + item.product.price * item.numOfItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout", style: TextStyle(color: Colors.black))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delivery Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(deliveryAddresses.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selectedIndex == index ? kPrimaryColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * 0.6,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.all(8.0),
                        child: Text(deliveryAddresses[index]),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 16),
              Text('Cart Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("${getTotalQuantity()} items"),
              SizedBox(height: 8),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Dismissible(
                            key: Key(cartItems[index].product.id.toString()),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) async {
                              final productId = cartItems[index].product.id;
                              final userId = await getUserID();
                              if (userId != null) {
                                setState(() => cartItems.removeAt(index));
                                await removeCartItem(userId, productId);
                              }
                            },
                            background: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            child: CartCard(cart: cartItems[index]),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PayNowCard(
        totalPrice: getTotalPrice(),
        totalQuantity: getTotalQuantity(),
        selectedAddress: selectedIndex != -1 ? deliveryAddresses[selectedIndex] : "",
        cartItems: cartItems,
        onOrderComplete: () {
          setState(() {
            cartItems.clear();
          });
        },
      ),
    );
  }
}
