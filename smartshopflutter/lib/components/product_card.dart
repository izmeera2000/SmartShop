import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants.dart';
import '../models/Product.dart';
import 'cache_manager.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    Key? key,
    this.width = 140,
    this.aspectRatio = 1.02,
    required this.product,
    required this.onPress,
  }) : super(key: key);

  final double width, aspectRatio;
  final Product product;
  final VoidCallback onPress;

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String? _imageUrl;
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _resolveImageUrl();
  }

  Future<void> _resolveImageUrl() async {
    final raw = widget.product.images.isNotEmpty
        ? widget.product.images.first
        : null;

    if (raw == null) return;

    setState(() => _loading = true);

    try {
      if (raw.startsWith('http')) {
        // Already a download URL
        _imageUrl = raw;
      } else {
        // It's a storage path — fetch the real URL once
        _imageUrl = await FirebaseStorage.instance
            .ref(raw)
            .getDownloadURL();
      }
    } catch (e) {
      _error = e;
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

@override
Widget build(BuildContext context) {
  print("Building ProductCard for: ${widget.product.title}");

  return SizedBox(
    width: widget.width,
    child: GestureDetector(
      onTap: widget.onPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: Container(
              decoration: BoxDecoration(
                color: kSecondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : (_error != null || _imageUrl == null)
                        ? const Center(child: Icon(Icons.broken_image))
                        : CachedNetworkImage(
                            imageUrl: _imageUrl!,
                            cacheManager: CustomImageCacheManager.instance,
                            placeholder: (_, __) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                            fit: BoxFit.cover,
                          ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.title,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "RM${widget.product.price.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // InkWell(
              //   borderRadius: BorderRadius.circular(50),
              //   onTap: () {
              //     // Toggle favorite, etc.
              //   },
              //   child: const Padding(
              //     padding: EdgeInsets.all(6),
              //     child: Icon(Icons.favorite_border),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    ),
  );
}


}
