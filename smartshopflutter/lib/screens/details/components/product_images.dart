import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import cached_network_image
import 'package:smartshopflutter/components/cache_manager.dart';

import '../../../constants.dart';
import '../../../models/Product.dart';

class ProductImages extends StatefulWidget {
  const ProductImages({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  _ProductImagesState createState() => _ProductImagesState();
}

class _ProductImagesState extends State<ProductImages> {
  int selectedImage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 238,
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              child: CachedNetworkImage(
                imageUrl: widget
                    .product.images[selectedImage], // Directly use the URL
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image,
                  size: 60,
                ),
                cacheKey: widget
                    .product.images[selectedImage], // Cache based on image URL
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.product.images.length,
            (index) => SmallProductImage(
              isSelected: index == selectedImage,
              press: () {
                setState(() {
                  selectedImage = index;
                });
              },
              imageUrl: widget.product
                  .images[index], // Pass the image URL to SmallProductImage
            ),
          ),
        ),
      ],
    );
  }
}

class SmallProductImage extends StatelessWidget {
  const SmallProductImage({
    Key? key,
    required this.isSelected,
    required this.press,
    required this.imageUrl,
  }) : super(key: key);

  final bool isSelected;
  final VoidCallback press;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: AnimatedContainer(
        duration: defaultDuration,
        margin: const EdgeInsets.only(right: 16),
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: kPrimaryColor.withOpacity(isSelected ? 1 : 0),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: imageUrl, // Directly use the URL passed in
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (context, url, error) => const Icon(
              Icons.broken_image,
              size: 24,
            ),
            cacheKey: imageUrl, // Cache the image based on its URL
          ),
        ),
      ),
    );
  }
}
