import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Add this if not already imported
import 'package:cached_network_image/cached_network_image.dart'; // Import cached_network_image
import '../../../constants.dart';
import '../../../models/Cart.dart';

class CartCard extends StatelessWidget {
  const CartCard({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  Future<String> getImageUrl(String path) async {
    final storageRef = FirebaseStorage.instance.ref(path);
    return await storageRef.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: AspectRatio(
            aspectRatio: 0.88,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: FutureBuilder<String>(
                future: getImageUrl(cart.product.images[0]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return const Icon(Icons.broken_image, size: 50);
                  } else {
                    // Use CachedNetworkImage instead of Image.network
                    return CachedNetworkImage(
                      imageUrl: snapshot.data!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
                         cacheKey:
                          snapshot.data!, 
                    );
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cart.product.title,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: "\RM${cart.product.price}",
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Color.fromARGB(255, 0, 0, 0)),
                children: [
                  TextSpan(
                      text: " x${cart.numOfItem}",
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}
