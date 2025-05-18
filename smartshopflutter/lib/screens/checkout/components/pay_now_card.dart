import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartshopflutter/screens/payment/payment_screen.dart';
import '../../../constants.dart';
import '../../../models/Cart.dart';
import '../../../models/Order.dart'; // Ensure this is the correct import
import '../../../components/save_details.dart';

class PayNowCard extends StatelessWidget {
  final double totalPrice;
  final int totalQuantity;
  final String selectedAddress;
  final List<Cart> cartItems;
  final VoidCallback onOrderComplete;

  const PayNowCard({
    Key? key,
    required this.totalPrice,
    required this.totalQuantity,
    required this.selectedAddress,
    required this.cartItems,
    required this.onOrderComplete,
  }) : super(key: key);

  Future<void> submitOrder(BuildContext context) async {
    final userId = await getUserID();
    if (userId == null || selectedAddress.isEmpty || cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Missing information: address, user, or cart.")),
      );
      return;
    }

    // Create OrderItem objects from cartItems
    List<OrderItem> orderItems = cartItems.map((item) {
      return OrderItem(
        productId: item.product.id,
        title: item.product.title,
        price: item.product.price,
        quantity: item.numOfItem,
      );
    }).toList();

    // Create Order object
    final order = Orders(
      id: '', // Firestore will assign the ID
      userId: userId,
      deliveryAddress: selectedAddress,
      totalPrice: totalPrice,
      status: 'pending',
      notes: '',
      date: DateTime.now(),
      estimatedDeliveryDate: DateTime.now().add(Duration(days: 5)),
      items: orderItems,
    );

    // Save the order to Firestore
    await FirebaseFirestore.instance.collection('orders').add(order.toMap());

    // 2. Remove items from the cart
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart');

    final cartDocs = await cartRef.get();
    for (var doc in cartDocs.docs) {
      await doc.reference.delete();
    }

    // 3. Clear local cart + show feedback
    onOrderComplete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order placed and cart cleared!")),
    );

    // 4. Navigate to payment
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -15),
            blurRadius: 20,
            color: const Color.fromARGB(255, 43, 41, 41).withOpacity(0.15),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: "Total:\n",
                  children: [
                    TextSpan(
                      text: "\RM${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () => submitOrder(context),
                child: const Text("Pay Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
