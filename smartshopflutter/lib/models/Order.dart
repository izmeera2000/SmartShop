// models/Order.dart

class OrderItem {
  final String productId;
  final String title;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'quantity': quantity,
    };
  }
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

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'deliveryAddress': deliveryAddress,
      'totalPrice': totalPrice,
      'status': status,
      'notes': notes,
      'date': date,
      'estimatedDeliveryDate': estimatedDeliveryDate,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}
