import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartshopflutter/screens/chat/chat_screen.dart';


class OrderDetailsSeller extends StatefulWidget {
  final String orderId;
  static String routeName = "/orders_details_seller";

  const OrderDetailsSeller({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailsSeller> createState() => _OrderDetailsSellerState();
}

class _OrderDetailsSellerState extends State<OrderDetailsSeller> {
  late Future<DocumentSnapshot> _orderFuture;

  @override
  void initState() {
    super.initState();
    _orderFuture = FirebaseFirestore.instance.collection('orders').doc(widget.orderId).get();
  }


  String _getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '$uid1\_$uid2' : '$uid2\_$uid1';
  }

  Future<String?> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<void> _startChat(BuildContext context, String buyerId) async {
    final currentUserId = await getCurrentUserId();

    if (currentUserId == null || currentUserId == buyerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot chat with yourself.")),
      );
      return;
    }

    final chatId = _getChatId(currentUserId, buyerId);
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final chatSnapshot = await chatRef.get();

    if (!chatSnapshot.exists) {
      await chatRef.set({
        'participants': [currentUserId, buyerId],
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
        'otherUserId': buyerId,
      },
    );
  }


  Future<void> _refreshOrder() async {
    setState(() {
      _orderFuture = FirebaseFirestore.instance.collection('orders').doc(widget.orderId).get();
    });
  }

  // your existing methods (_getChatId, getCurrentUserId, _startChat, _showUpdateStatusDialog)

Future<void> _showUpdateStatusDialog(BuildContext context, String productId) async {
  String selectedStatus = 'pending'; // initial value

  String? newStatus = await showDialog<String>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Update Item Status'),
            content: DropdownButton<String>(
              value: selectedStatus,
              items: ['pending', 'shipped', 'delivered', 'cancelled']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status[0].toUpperCase() + status.substring(1)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedStatus = value;
                  });
                }
              },
              isExpanded: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selectedStatus),
                child: const Text('Update'),
              ),
            ],
          );
        },
      );
    },
  );

  if (newStatus != null) {
    final orderRef = FirebaseFirestore.instance.collection('orders').doc(widget.orderId);
    final orderSnap = await orderRef.get();
    if (!orderSnap.exists) return;

    final orderData = orderSnap.data()! as Map<String, dynamic>;
    List items = List.from(orderData['items']);

    // Update the status of the specific product item
    for (int i = 0; i < items.length; i++) {
      if (items[i]['productId'] == productId) {
        items[i]['status'] = newStatus;
        break;
      }
    }

    // Check if all items have the same status after update
    bool allSameStatus = items.every((item) => item['status'] == newStatus);

    Map<String, dynamic> updateData = {'items': items};
    if (allSameStatus) {
      // Update overall order status if all item statuses are the same
      updateData['status'] = newStatus;
    }

    await orderRef.update(updateData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated to $newStatus')),
    );

    await _refreshOrder(); // refresh order data to update UI
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details (Seller)')),
      body: FutureBuilder<DocumentSnapshot>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'];
          final buyerId = data['userId']; // Buyer id
          final items = data['items'] as List<dynamic>;

          return FutureBuilder<String?>(
            future: getCurrentUserId(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final sellerId = userSnapshot.data!;
              final sellerItems = items
                  .where((item) =>
                      item['productUserId'] != null &&
                      item['productUserId'] == sellerId)
                  .toList();

              if (sellerItems.isEmpty) {
                return const Center(
                    child: Text('No items found for this seller.'));
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Order ID: ${widget.orderId}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Buyer ID: $buyerId'),
                  Text('Status: $status'),
                  Text('Delivery Address: ${data['deliveryAddress']}'),
                  const SizedBox(height: 16),
                  ...sellerItems.map((item) {
                    final itemStatus = item['status'] ?? 'pending';
                    final productId = item['productId'] ?? '';

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(item['title'] ?? 'Unknown',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('Quantity: ${item['quantity']}'),
                                Text('Status: $itemStatus'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 110,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('RM${item['price']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    if (productId.isNotEmpty) {
                                      _showUpdateStatusDialog(context, productId);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Product ID missing')),
                                      );
                                    }
                                  },
                                  child: const Text('Update Status'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  if (sellerId != buyerId)
                    ElevatedButton.icon(
                      onPressed: () => _startChat(context, buyerId),
                      icon: const Icon(Icons.chat),
                      label: const Text("Chat with Buyer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
