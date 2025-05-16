import 'package:flutter/material.dart';

import 'components/categories.dart';
import 'components/discount_banner.dart';
import 'components/home_header.dart';
import 'components/popular_product.dart';
import 'components/special_offers.dart';
import '../../repositories/products_repository.dart';
import 'package:smartshopflutter/models/Product.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _popularProductsFuture;

  @override
  void initState() {
    super.initState();
    _popularProductsFuture = ProductsRepository.fetchPopularProducts();
  }

  Future<void> _handleRefresh() async {
    // Clear any cached data in repository
    ProductsRepository.clearCache();
    // Refresh the future and rebuild widget
    setState(() {
      _popularProductsFuture = ProductsRepository.fetchPopularProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                HomeHeader(),
                DiscountBanner(),
                Categories(),
                SpecialOffers(),
                const SizedBox(height: 20),
                PopularProducts(future: _popularProductsFuture),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
