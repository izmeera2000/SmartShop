import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/Cart.dart';
import '../../models/Product.dart';
import 'components/cart_card.dart';
import 'components/check_out_card.dart';
import 'package:smartshopflutter/components/save_details.dart'; // Assuming this is where getUserID() is defined.

class CartScreen extends StatefulWidget {
  static String routeName = "/cart";
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Cart> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch the user ID first
    getUserID().then((userId) {
      if (userId != null) {
        debugPrint('User ID retrieved: $userId'); // Logging user ID
        loadCartFromFirestore(userId);
      } else {
        debugPrint("User ID is null, please log in.");
      }
    });
  }

  Future<void> loadCartFromFirestore(String userId) async {
    debugPrint('Loading cart for user: $userId'); // Logging cart load attempt
    final items = await fetchCartItemsFromFirestore(userId);
    debugPrint('Cart items loaded: ${items.length} items'); // Logging number of items loaded
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
    int totalQuantity = 0;
    for (var cartItem in cartItems) {
      totalQuantity += cartItem.numOfItem;  // Assuming 'quantity' is an int
    }
    return totalQuantity;
  }

  Future<void> _onRefresh() async {
    // Fetch the user ID first, then reload the cart data
    final userId = await getUserID();
    if (userId != null) {
      await loadCartFromFirestore(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0.0;
    int totalQuantity = 0;

    // Calculate total price and quantity
    for (var cartItem in cartItems) {
      totalPrice += cartItem.product.price * cartItem.numOfItem;
      totalQuantity += cartItem.numOfItem;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text("Your Cart", style: TextStyle(color: Colors.black)),
            Text(
              "$totalQuantity items", // Display total quantity here
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh, // Trigger the refresh function
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Dismissible(
                      key: Key(cartItems[index].product.id.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        final productId = cartItems[index].product.id;
                        debugPrint('Dismissed product with ID: $productId');

                        final userId = await getUserID();
                        if (userId != null) {
                          setState(() {
                            cartItems.removeAt(index);
                          });
                          removeCartItem(userId, productId);
                        } else {
                          debugPrint('Failed to remove item. User not logged in.');
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
            ),
      bottomNavigationBar: CheckoutCard(
        totalPrice: totalPrice,
        totalQuantity: totalQuantity,
      ), // Pass total price and quantity
    );
  }
}
