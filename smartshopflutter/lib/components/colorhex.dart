import 'package:flutter/material.dart';


// Function to convert a hex color string to a Color object
Color hexToColor(String hexString) {
  final hexColor = hexString.replaceAll('#', '');  // Remove # if present
  return Color(int.parse('0xFF$hexColor'));  // Add 0xFF for full opacity and parse
}