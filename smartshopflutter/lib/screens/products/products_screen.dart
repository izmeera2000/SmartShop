import 'package:flutter/material.dart';
import 'package:smartshopflutter/components/product_card.dart';
import 'package:smartshopflutter/models/Product.dart';
import 'package:smartshopflutter/repositories/products_repository.dart';
import '../details/details_screen.dart';
import 'package:smartshopflutter/screens/home/components/search_field.dart';

class ProductsScreen extends StatefulWidget {
  static const String routeName = "/products";
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late Future<List<Product>> _productsFuture;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  String _searchQuery = '';
  bool _didLoadQuery = false;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductsRepository.fetchAllProducts();
    _productsFuture.then((products) {
      setState(() {
        _allProducts = products;
        _filteredProducts = _searchQuery.isEmpty
            ? products
            : _filterProducts(products, _searchQuery);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only load query once
    if (!_didLoadQuery) {
      final query = ModalRoute.of(context)?.settings.arguments as String?;
      if (query != null && query.isNotEmpty) {
        setState(() {
          _searchQuery = query;
          _filteredProducts = _filterProducts(_allProducts, _searchQuery);
        });
      }
      _didLoadQuery = true;
    }
  }

  List<Product> _filterProducts(List<Product> products, String query) {
    return products
        .where((product) =>
            product.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProducts = _filterProducts(_allProducts, query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ProductsRepository.clearCache();
              setState(() {
                _productsFuture = ProductsRepository.fetchAllProducts();
                _allProducts = [];
                _filteredProducts = [];
                _productsFuture.then((products) {
                  setState(() {
                    _allProducts = products;
                    _filteredProducts = _searchQuery.isEmpty
                        ? products
                        : _filterProducts(products, _searchQuery);
                  });
                });
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchField(
              initialValue: _searchQuery,
              onSubmitted: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }

          final products = _filteredProducts;

          if (products.isEmpty) {
            return const Center(child: Text("No products found"));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              key: const PageStorageKey<String>('productsGrid'),
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
                      DetailsScreen.routeName,
                      arguments: ProductDetailsArguments(product: product),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
