import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartshopflutter/components/product_card.dart';
import 'package:smartshopflutter/models/Product.dart';
import 'package:smartshopflutter/repositories/products_repository.dart';
import 'package:smartshopflutter/screens/sell/sell_edit_screen.dart';
import 'package:smartshopflutter/screens/sell/sell_screen.dart';
import 'package:smartshopflutter/screens/profile/edit_profile.dart';

class SellListScreen extends StatefulWidget {
  static const String routeName = "/sell_list";
  const SellListScreen({Key? key}) : super(key: key);

  @override
  State<SellListScreen> createState() => _SellListScreenState();
}

class _SellListScreenState extends State<SellListScreen> {
  bool isLoading = true;
  bool hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkUserProfile();
  }

  Future<void> _checkUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();

    final requiredFields = [
      'firstName',
      'lastName',
      'phoneNumber',
      'address',
      'profileImage',
      'bankImage',
    ];

    final isComplete = data != null &&
        requiredFields.every((field) =>
            data[field] != null && data[field].toString().trim().isNotEmpty);

    if (!isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, EditProfileScreen.routeName);
      });
    } else {
      setState(() {
        hasProfile = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Your Products")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Product>>(
          stream: ProductsRepository.userProductsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final products = snapshot.data;
            if (products == null || products.isEmpty) {
              return const Center(child: Text("No products available"));
            }

            return GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.7,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onPress: () {
                    Navigator.pushNamed(
                      context,
                      SellEditScreen.routeName,
                      arguments: product,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Upload New Product",
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, SellScreen.routeName);
        },
      ),
    );
  }
}
