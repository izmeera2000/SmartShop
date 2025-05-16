import 'package:flutter/material.dart';
import 'package:smartshopflutter/screens/products/products_screen.dart'; // Import ProductsScreen

import 'search_field.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  _HomeHeaderState createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SearchField(
              onSubmitted: (query) {
                // Navigate to ProductsScreen with the search query as an argument
                if (query.isNotEmpty) {
                  Navigator.pushNamed(
                    context,
                    ProductsScreen.routeName,
                    arguments: query, // Passing the search query as argument
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
