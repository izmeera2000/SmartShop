// payment_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/Order.dart';
import 'components/pay_now_card.dart';

class PaymentScreen extends StatefulWidget {
  static const String routeName = "/payment";
  final String orderId;

  const PaymentScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Orders? order;
  Map<String, String?> sellerBankImages = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderAndBankImages();
  }

  Future<void> _loadOrderAndBankImages() async {
    if (widget.orderId.trim().isEmpty) {
      debugPrint('Error: orderId is empty');
      setState(() => isLoading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .get();

    if (!doc.exists || doc.data() == null) {
      debugPrint('Order document does not exist!');
      setState(() => isLoading = false);
      return;
    }

    // Ensure items is always a List<Map>
    final data = doc.data()!;
    final rawItems = data['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    // Build Orders model
    order = Orders(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      deliveryAddress: data['deliveryAddress'] as String? ?? '',
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      date: DateTime.tryParse(data['date'] as String? ?? '') ?? DateTime.now(),
      estimatedDeliveryDate: DateTime.tryParse(
            data['estimatedDeliveryDate'] as String? ?? '',
          ) ??
          DateTime.now(),
      items: itemsList,
    );

    // Fetch each seller's bankImageUrl
    final sellerIds = order!.items
        .map((i) => i.productUserId)
        .where((id) => id.trim().isNotEmpty)
        .toSet();

    for (var sid in sellerIds) {
      if (sid.trim().isEmpty) {
        continue;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(sid) // ← ensure sid is a non-empty String
          .get();

      sellerBankImages[sid] =
          userDoc.exists ? (userDoc.data()?['bankImage'] as String?) : null;
    }

    setState(() => isLoading = false);
  }

  double getTotalPrice() {
    return order?.items.fold<double>(
          0.0,
          (sum, item) => sum + item.price * item.quantity,
        ) ??
        0.0;
  }

  int getTotalQuantity() {
    return order?.items.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (order == null) {
      return const Scaffold(
        body: Center(child: Text("Order not found.")),
      );
    }

    // Group items by seller
    final grouped = <String, List<OrderItem>>{};
    for (var itm in order!.items) {
      grouped.putIfAbsent(itm.productUserId, () => []).add(itm);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: grouped.entries.map((entry) {
          final sellerId = entry.key;
          final items = entry.value;
          final bankUrl = sellerBankImages[sellerId] ?? '';
          final sellerTotal =
              items.fold<double>(0.0, (sum, i) => sum + i.price * i.quantity);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Seller: $sellerId",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (bankUrl.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImageView(imageUrl: bankUrl),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(bankUrl, height: 150),
                  ),
                )
              else
                const Text("Bank image not available",
                    style: TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              ...items.map((i) => ListTile(
                    title: Text(i.title),
                    subtitle:
                        Text("${i.quantity} × RM${i.price.toStringAsFixed(2)}"),
                    trailing: Text(
                      "RM${(i.price * i.quantity).toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Subtotal: RM${sellerTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(thickness: 2),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
      bottomNavigationBar: PaidCard(
        totalPrice: getTotalPrice(),
        totalQuantity: getTotalQuantity(),
      ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1,
          maxScale: 4,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
