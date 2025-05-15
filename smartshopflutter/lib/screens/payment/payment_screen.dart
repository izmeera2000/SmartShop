import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartshopflutter/constants.dart';
import '../../models/Cart.dart';
import '../../models/Product.dart';
import 'components/pay_now_card.dart';
import 'package:smartshopflutter/components/save_details.dart'; // Assuming this is where getUserID() is defined.

class PaymentScreen extends StatefulWidget {
  static String routeName = "/payment";
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<Cart> cartItems = [];
  bool isLoading = true;
  int selectedIndex = -1; // Store selected index for outlining effect

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
    debugPrint(
        'Cart items loaded: ${items.length} items'); // Logging number of items loaded
    setState(() {
      cartItems = items;
      isLoading = false;
    });
  }

  Future<void> removeCartItem(String userId, String productId) async {
    debugPrint(
        'Removing product with ID: $productId from cart for user: $userId'); // Logging product removal attempt
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart');

    final cartDocs =
        await cartRef.where('productId', isEqualTo: productId).get();
    if (cartDocs.docs.isEmpty) {
      debugPrint(
          'No matching products found for product ID: $productId'); // Logging if no product was found
    }

    for (var doc in cartDocs.docs) {
      await doc.reference.delete();
      debugPrint(
          'Product with ID: $productId removed from Firestore'); // Logging successful removal
    }
  }

  int getTotalQuantity() {
    int totalQuantity = 0;
    for (var cartItem in cartItems) {
      totalQuantity += cartItem.numOfItem; // Assuming 'quantity' is an int
    }
    return totalQuantity;
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
        title: const Text("Payment", style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Touch `n Go eWallet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                child: Image.asset('assets/images/qr.jpg'),
              ),
              SizedBox(height: 16),
              // Column(
              //   children: [
              //     Text(
              //       'Cart Items',
              //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              //     ),
              //     Text(
              //       "$totalQuantity items", // Display total quantity here
              //       style: Theme.of(context).textTheme.bodySmall,
              //     ),
              //   ],
              // ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PaidCard(
          totalPrice: totalPrice,
          totalQuantity: totalQuantity), // Pass total price and quantity
    );
  }
}
