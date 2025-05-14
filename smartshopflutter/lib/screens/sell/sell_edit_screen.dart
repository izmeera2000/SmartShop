import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartshopflutter/components/cache_manager.dart';
import 'dart:io';

import 'package:smartshopflutter/constants.dart';
import 'package:smartshopflutter/helper/compress_image.dart';
import 'package:smartshopflutter/models/Product.dart';
import 'package:smartshopflutter/components/save_details.dart';
import '../../../helper/permission.dart';

class SellEditScreen extends StatefulWidget {
  static const String routeName = "/sell_edit";

  final Product? product;

  const SellEditScreen({super.key, this.product});

  @override
  _SellEditScreenState createState() => _SellEditScreenState();
}

class _SellEditScreenState extends State<SellEditScreen> {
  List<File>? _image;
  final picker = ImagePicker();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  bool _isPopular = false;
  List<String> _existingImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _titleController.text = widget.product!.title;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _isPopular = widget.product!.isPopular;
      _existingImages = widget.product!.images; // Load existing images
    }
  }

  Future<void> pickImage() async {
    await requestPermissions();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _image = pickedFiles.map((file) => File(file.path)).toList();
      });
    } else {
      print("No images selected.");
    }
  }

  Future<void> updateProduct() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty) {
      print("All fields are required!");
      return;
    }

    try {
      final productId = widget.product?.id;
      List<String> imagePaths =
          List.from(_existingImages); // Start with existing images

      if (_image != null && _image!.isNotEmpty) {
        for (var image in _image!) {
          final compressedImage = await compressImage(image);
          if (compressedImage != null) {
            final filePath =
                'products/${DateTime.now().millisecondsSinceEpoch}.jpg';
            final storageRef = FirebaseStorage.instance.ref().child(filePath);
            final uploadTask = storageRef.putFile(compressedImage);
            await uploadTask;
            imagePaths.add(filePath); // Add new images
          }
        }
      }

      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'stock': int.tryParse(_stockController.text) ?? 0,
        'isPopular': _isPopular,
        'images': imagePaths,
      });

      print("Product updated successfully!");
      Navigator.pop(context);
    } catch (e) {
      print("Error updating product: $e");
    }
  }

  Widget buildImage(String imagePath) {
    return FutureBuilder<String>(
      future: FirebaseStorage.instance.ref(imagePath).getDownloadURL(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Icon(Icons.broken_image));
        } else {
          final imageUrl = snapshot.data!;
          return CachedNetworkImage(
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            imageUrl: imageUrl,
            cacheManager: CustomImageCacheManager.instance,
            errorWidget: (context, url, error) =>
                const Icon(Icons.broken_image),
            fit: BoxFit.cover,
            cacheKey: imageUrl,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text("Edit Product", style: headingStyle),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 200,
                  color: const Color.fromARGB(255, 238, 238, 238),
                  child: (_image == null || _image!.isEmpty)
                      ? _existingImages.isNotEmpty
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _existingImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: buildImage(_existingImages[index]),
                                );
                              },
                            )
                          : const Center(child: Text("Tap to pick image"))
                      : GridView.builder(
                          itemCount: _image!.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemBuilder: (context, index) {
                            return Image.file(
                              _image![index],
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Product Title"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: "Product Description"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Product Price"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Stock Quantity"),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Popular Product?"),
                  Switch(
                    value: _isPopular,
                    onChanged: (value) {
                      setState(() {
                        _isPopular = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateProduct,
                child: const Text("Update Product"),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
