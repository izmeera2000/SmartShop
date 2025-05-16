import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:smartshopflutter/helper/compress_image.dart';
import 'package:smartshopflutter/models/Product.dart';

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
  final _categoryController = TextEditingController();

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
      _categoryController.text = widget.product!.category ?? '';
      _isPopular = widget.product!.isPopular;
      _existingImages = widget.product!.images; // assumed URLs already
    }
  }

  Future<void> pickImage() async {
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _image = pickedFiles.map((file) => File(file.path)).toList();
      });
    } else {
      debugPrint("No images selected.");
    }
  }

  Future<void> updateProduct() async {
    // Validation simplified for demo
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty) {
      debugPrint("All fields are required!");
      return;
    }

    // You would add your Firestore upload logic here,
    // including uploading new _image files and updating doc with _existingImages + new uploads.

    debugPrint("Product updated successfully!");
    Navigator.of(context).pop();
  }

  Widget buildImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) =>
          const Icon(Icons.broken_image, size: 50, color: Colors.grey),
      fit: BoxFit.cover,
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
              const Text("Edit Product",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Image picker area
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
                          padding: const EdgeInsets.all(8),
                          itemCount: _image!.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemBuilder: (context, index) {
                            return Image.file(_image![index], fit: BoxFit.cover);
                          },
                        ),
                ),
              ),

              const SizedBox(height: 30),

              // Form fields
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Product Title"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Product Description"),
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
              const SizedBox(height: 16),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: "Category (optional)"),
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
