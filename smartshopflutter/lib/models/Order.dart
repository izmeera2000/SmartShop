// models/Order.dart

class OrderItem {
  final String productId;
  final String title;
  final double price;
  final int quantity;
  final String productUserId; // Seller ID
  final String status; // Status for this specific item (e.g., pending, shipped)

  OrderItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.productUserId,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'title': title,
        'price': price,
        'quantity': quantity,
        'productUserId': productUserId,
        'status': status,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        productId: map['productId'],
        title: map['title'],
        price: (map['price'] as num).toDouble(),
        quantity: map['quantity'],
        productUserId: map['productUserId'],
        status: map['status'] ?? 'pending',
      );
}

class Orders {
  final String id;
  final String userId;
  final String deliveryAddress;
  final double totalPrice;
  final String status;
  final String notes;
  final DateTime date;
  final DateTime estimatedDeliveryDate;
  final List<OrderItem> items;

  Orders({
    required this.id,
    required this.userId,
    required this.deliveryAddress,
    required this.totalPrice,
    required this.status,
    required this.notes,
    required this.date,
    required this.estimatedDeliveryDate,
    required this.items,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'deliveryAddress': deliveryAddress,
        'totalPrice': totalPrice,
        'status': status,
        'notes': notes,
        'date': date.toIso8601String(),
        'estimatedDeliveryDate': estimatedDeliveryDate.toIso8601String(),
        'items': items.map((item) => item.toMap()).toList(),
      };

  factory Orders.fromMap(Map<String, dynamic> map) => Orders(
        id: map['id'] ?? '',
        userId: map['userId'],
        deliveryAddress: map['deliveryAddress'],
        totalPrice: (map['totalPrice'] as num).toDouble(),
        status: map['status'],
        notes: map['notes'],
        date: DateTime.parse(map['date']),
        estimatedDeliveryDate: DateTime.parse(map['estimatedDeliveryDate']),
        items: (map['items'] as List)
            .map((itemMap) => OrderItem.fromMap(itemMap))
            .toList(),
      );
}
