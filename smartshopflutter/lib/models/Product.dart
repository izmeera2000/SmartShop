import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final double rating;
  final double price;
  final bool isFavourite;
  final bool isPopular;
  final String userId;
  final int stock; // ✅ Add stock field

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.rating,
    required this.price,
    required this.isFavourite,
    required this.isPopular,
    required this.userId,
    required this.stock, // ✅ Include in constructor
  });

  // Optional: If you use color strings in Firestore
  static Color hexToColor(String hex) {
    try {
      final colorString = hex.replaceAll('#', '');
      if (colorString.length == 6) {
        return Color(int.parse('0xFF$colorString', radix: 16));
      } else {
        throw FormatException('Invalid hex color format');
      }
    } catch (e) {
      debugPrint("Error parsing hex color: $e");
      return Colors.grey;
    }
  }

  factory Product.fromFirestore(Map<String, dynamic> data, String docId) {
    return Product(
      id: docId,
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? 'No description available',
      images: List<String>.from(data['images'] ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      isFavourite: data['isFavourite'] ?? false,
      isPopular: data['isPopular'] ?? false,
      userId: data['userId'] ?? '',
      stock: (data['stock'] as num?)?.toInt() ?? 0, // ✅ Parse stock safely
    );
  }
}
