import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartshopflutter/screens/orders/orders_details_seller.dart';
import 'package:smartshopflutter/screens/orders/orders_details_user.dart';

class OrdersListSeller extends StatelessWidget {
  const OrdersListSeller({super.key});
  static String routeName = "/orders_list_seller";

  Future<String?> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Seller Orders'),
      ),
      body: FutureBuilder<String?>(
        future: getCurrentUserId(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sellerId = userSnapshot.data!;
          final ordersStream = FirebaseFirestore.instance
              .collection('orders')
              .where('sellerIds',
                  arrayContains: sellerId) // Server-side filtering
              .orderBy('date', descending: true)
              .snapshots();

          return StreamBuilder<QuerySnapshot>(
            stream: ordersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No orders found.'));
              }

              final sellerOrders = snapshot.data!.docs;

              return ListView.builder(
                itemCount: sellerOrders.length,
                itemBuilder: (context, index) {
                  final orderDoc = sellerOrders[index];
                  final orderData = orderDoc.data() as Map<String, dynamic>;

                  final rawDate = orderData['date'];
                  final date = rawDate is Timestamp
                      ? rawDate.toDate()
                      : DateTime.tryParse(rawDate.toString());

                  final status = orderData['status'] ?? 'Pending';
                  final total = orderData['totalPrice'] ?? 0;

                  // Only show the seller's items
                  final items = (orderData['items'] as List<dynamic>)
                      .where((item) =>
                          item['productUserId'] != null &&
                          item['productUserId'] == sellerId)
                      .toList();

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text('Order #${orderDoc.id.substring(0, 6)}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (date != null)
                            Text(
                                'Date: ${date.toLocal().toString().split(' ')[0]}'),
                          Text('Status: $status'),
                          const SizedBox(height: 8),
                          Text('Your Items:'),
                          ...items.map((item) => Text(
                              '${item['title']} x${item['quantity']} - RM${item['price']}')),
                        ],
                      ),
                      trailing: Text('RM${total.toStringAsFixed(2)}'),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          OrderDetailsSeller.routeName,
                          arguments: {'orderId': orderDoc.id},
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
