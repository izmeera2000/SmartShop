import 'package:flutter/material.dart';
import 'package:smartshopflutter/models/Product.dart';
import 'package:smartshopflutter/components/product_card.dart';
import '../../details/details_screen.dart';
import '../../products/products_screen.dart';

import 'package:smartshopflutter/repositories/products_repository.dart';
import 'section_title.dart';

class PopularProducts extends StatelessWidget {
  final Future<List<Product>> future;

  const PopularProducts({Key? key, required this.future}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
            title: "Popular Products",
            press: () {
              Navigator.pushNamed(context, ProductsScreen.routeName);
            },
          ),
        ),
        FutureBuilder<List<Product>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height:  140,
                child: const Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final products = snapshot.data ?? [];
            if (products.isEmpty) {
              return const Center(child: Text("No popular products found."));
            }

            return SingleChildScrollView(
              key: const PageStorageKey<String>('popular_products_scroll'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(products.length, (index) {
                  final p = products[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ProductCard(
                      product: p,
                      onPress: () {
                        Navigator.pushNamed(
                          context,
                          DetailsScreen.routeName,
                          arguments: ProductDetailsArguments(product: p),
                        );
                      },
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }
}
