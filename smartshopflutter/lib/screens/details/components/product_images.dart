import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';  // Import cached_network_image

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

  Future<String> getImageUrl(String path) async {
    final storageRef = FirebaseStorage.instance.ref(path);
    return await storageRef.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 238,
          child: AspectRatio(
            aspectRatio: 1,
            child: FutureBuilder<String>(
              future: getImageUrl(widget.product.images[selectedImage]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Icon(Icons.broken_image, size: 60));
                } else {
                  return ClipRRect(
                    child: CachedNetworkImage(
                      imageUrl: snapshot.data!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 60),
                         cacheKey:
                          snapshot.data!, 
                    ),
                  );
                }
              },
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
              imageUrl: widget.product.images[index],
            ),
          ),
        ),
      ],
    );
  }
}

class SmallProductImage extends StatelessWidget {
  const SmallProductImage({
    super.key,
    required this.isSelected,
    required this.press,
    required this.imageUrl,
  });

  final bool isSelected;
  final VoidCallback press;
  final String imageUrl;

  Future<String> getImageUrl(String path) async {
    final storageRef = FirebaseStorage.instance.ref(path);
    return await storageRef.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: AnimatedContainer(
        duration: defaultDuration,
        margin: const EdgeInsets.only(right: 16),
        // padding: const EdgeInsets.all(8),
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: kPrimaryColor.withOpacity(isSelected ? 1 : 0),
          ),
        ),
        child: FutureBuilder<String>(
          future: getImageUrl(imageUrl),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Icon(Icons.broken_image, size: 24);
            } else {
              return ClipRRect(
                borderRadius: BorderRadius.circular(
                              10), //
                child: CachedNetworkImage(
                  imageUrl: snapshot.data!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 24),
                     cacheKey:
                          snapshot.data!, 
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
