import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for getting current user
import 'package:smartshopflutter/screens/payment/payment_screen.dart';
import 'package:smartshopflutter/screens/chat/chat_screen.dart';

class OrderDetailsUser extends StatelessWidget {
  final String orderId;
  static String routeName = "/orders_details_user";

  const OrderDetailsUser({Key? key, required this.orderId}) : super(key: key);

  String _getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '$uid1\_$uid2' : '$uid2\_$uid1';
  }

  Future<String?> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<void> _startChat(BuildContext context, String sellerId) async {
    final currentUserId = await getCurrentUserId();

    if (currentUserId == null || currentUserId == sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot chat with yourself.")),
      );
      return;
    }

    final chatId = _getChatId(currentUserId, sellerId);
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final chatSnapshot = await chatRef.get();

    if (!chatSnapshot.exists) {
      await chatRef.set({
        'participants': [currentUserId, sellerId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': null,
      });
    }

    Navigator.pushNamed(
      context,
      ChatScreen.routeName,
      arguments: {
        'chatId': chatId,
        'otherUserId': sellerId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderDoc =
        FirebaseFirestore.instance.collection('orders').doc(orderId);

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: orderDoc.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'];
          final userId = data['userId'];
          final items = data['items'] as List<dynamic>;

          // Group items by sellerId
          final Map<String, List<dynamic>> itemsBySeller = {};
          for (var item in items) {
            final sellerId = item['productUserId'] as String?;
            if (sellerId != null) {
              itemsBySeller.putIfAbsent(sellerId, () => []).add(item);
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Order ID: $orderId',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('User ID: $userId'),
              Text('Total Price: RM${data['totalPrice']}'),
              Text('Status: $status'),
              Text('Delivery Address: ${data['deliveryAddress']}'),
              const SizedBox(height: 16),

              // Display grouped items by seller
              ...itemsBySeller.entries.map((entry) {
                final sellerId = entry.key;
                final sellerItems = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seller: $sellerId',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // List items from this seller
                    ...sellerItems.map((item) {
                      final itemStatus = item['status'] ?? 'pending';
                      return ListTile(
                        title: Text(item['title'] ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quantity: ${item['quantity']}'),
                            Text('Status: $itemStatus'),
                          ],
                        ),
                        trailing: Text('RM${item['price']}'),
                      );
                    }).toList(),

                    // Chat button per seller (skip if seller == user)
                    if (sellerId != userId)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ElevatedButton.icon(
                          onPressed: () => _startChat(context, sellerId),
                          icon: const Icon(Icons.chat),
                          label: const Text("Chat with Seller"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),

                    const Divider(height: 32),
                  ],
                );
              }).toList(),

              if (status == 'pending')
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      PaymentScreen.routeName,
                      arguments: {'orderId': orderId},
                    );
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text("Go to Payment"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
