import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final List<Color> colors;
  final double rating;
  final double price;
  final bool isFavourite;
  final bool isPopular;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.colors,
    required this.rating,
    required this.price,
    required this.isFavourite,
    required this.isPopular,
  });

  // Method to parse hex color string to Color with error handling
  static Color hexToColor(String hex) {
    try {
      final colorString = hex.replaceAll('#', ''); // Remove hash if present
      if (colorString.length == 6) {
        return Color(int.parse('0xFF$colorString', radix: 16)); // Add 0xFF for full opacity
      } else {
        throw FormatException('Invalid hex color format');
      }
    } catch (e) {
      // Return a default color if the hex is invalid
      print("Error parsing hex color: $e");
      return Colors.grey; // Default fallback color
    }
  }

  // Factory method to create Product from Firestore document
  factory Product.fromFirestore(Map<String, dynamic> data, String docId) {
    // Safely convert colors from Firestore to List<Color>
    List<Color> colors = (data['colors'] as List<dynamic>)
        .map((hex) => hexToColor(hex.toString())) // Convert hex to Color
        .toList();

    return Product(
      id: docId,
      title: data['title'] ?? 'Untitled', // Default title if not found
      description: data['description'] ?? 'No description available',
      images: List<String>.from(data['images'] ?? []), // Default empty list if no images
      colors: colors,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0, // Default rating if null
      price: (data['price'] as num?)?.toDouble() ?? 0.0,  // Default price if null
      isFavourite: data['isFavourite'] ?? false, // Default false if not found
      isPopular: data['isPopular'] ?? false,   // Default false if not found
    );
  }
}
