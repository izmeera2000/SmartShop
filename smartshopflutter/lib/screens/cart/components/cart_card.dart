import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import cached_network_image
import '../../../constants.dart';
import '../../../models/Cart.dart';

class CartCard extends StatelessWidget {
  const CartCard({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    // Get the image URL from the cart product
    String imageUrl = cart.product.images.isNotEmpty
        ? cart.product.images[0]  // Direct URL from the images list
        : '';  // Default value if image URL is empty

    // Print the image URL to the console
    print('Image URL: $imageUrl');

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
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(), // Placeholder while loading
                errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50), // Error icon if loading fails
                cacheKey: imageUrl.isNotEmpty ? imageUrl : null, // Cache image URL
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
              maxLines: 2, // Limit title to two lines
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: "RM${cart.product.price.toStringAsFixed(2)}", // Price of product
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: kPrimaryColor),
                children: [
                  TextSpan(
                      text: " x${cart.numOfItem}", // Quantity of product in cart
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
