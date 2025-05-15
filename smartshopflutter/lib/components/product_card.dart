import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import the CachedNetworkImage package

import '../constants.dart';
import '../models/Product.dart';
import 'cache_manager.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key? key,
    this.width = 140,
    this.aspectRetio = 1.02,
    required this.product,
    required this.onPress,
  }) : super(key: key);

  final double width, aspectRetio;
  final Product product;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onPress,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.02,
                child: Container(
                  // padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kSecondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FutureBuilder<String>(
                    future: FirebaseStorage.instance
                        .ref(product.images[0])
                        .getDownloadURL(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return const Center(child: Icon(Icons.broken_image));
                      } else {
                        final imageUrl = snapshot.data!;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(
                              12), // Apply the same borderRadius
                          child: CachedNetworkImage(
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            imageUrl: imageUrl,
                            cacheManager: CustomImageCacheManager.instance,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image),
                            fit: BoxFit.cover,
                            cacheKey:
                                imageUrl, // or a unique identifier of the product/image
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.title,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\RM${product.price}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {},
                    child: Container(
                        // padding: const EdgeInsets.all(6),
                        // height: 24,
                        // width: 24,
                        // decoration: BoxDecoration(
                        //   color: product.isFavourite
                        //       ? kPrimaryColor.withOpacity(0.15)
                        //       : kSecondaryColor.withOpacity(0.1),
                        //   shape: BoxShape.circle,
                        // ),
                        // child: SvgPicture.asset(
                        //   "assets/icons/Heart Icon_2.svg",
                        //   colorFilter: ColorFilter.mode(
                        //       product.isFavourite
                        //           ? const Color.fromARGB(255, 255, 0, 0)
                        //           : const Color(0xFFDBDEE4),
                        //       BlendMode.srcIn),
                        // ),
                        ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
