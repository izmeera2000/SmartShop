import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:smartshopflutter/models/Product.dart';
import 'package:smartshopflutter/components/product_card.dart';
import 'package:smartshopflutter/components/save_details.dart';
import '../details/details_screen.dart';
import '../../../helper/permission.dart';

class SellScreen extends StatefulWidget {
  static const String routeName = "/sell";
  const SellScreen({super.key});

  @override
  _SellScreenState createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  List<File>? _image;
  final picker = ImagePicker();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  Future<List<Product>> fetchProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();
    return snapshot.docs
        .map((doc) => Product.fromFirestore(doc.data(), doc.id))
        .toList();
  }

Future<void> uploadProduct() async {
  if (_image == null ||
      _titleController.text.isEmpty ||
      _descriptionController.text.isEmpty ||
      _priceController.text.isEmpty) {
    print("All fields are required!");
    return;
  }

  try {
    // Get the current user's UID (userId)
                  String? userId = await getUserID();

    // Create a list to store image paths
    List<String> imagePaths = [];

    // Check if _image is a List<File> (multiple images)
    if (_image is List<File>) {
      // Upload each image to Firebase Storage
      for (var image in _image!) {
        // Define the path for Firebase Storage
        final filePath = 'products/controller_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        // Get a reference to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child(filePath);
        
        // Upload the file to Firebase Storage
        final uploadTask = storageRef.putFile(image);
        await uploadTask;

        // Instead of getting the download URL, save only the file path
        imagePaths.add(filePath); // Add the storage path to the list
      }
    }

    // Add product data to Firestore
    final productData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'images': imagePaths, // Store the list of image paths in Firestore
      'userId': userId, // Add the userId to the product data
    };

    await FirebaseFirestore.instance.collection('products').add(productData);

    print("Product uploaded successfully!");

    // Clear form fields
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    setState(() {
      _image = null; // Clear selected images
    });
  } catch (e) {
    print("Error uploading product: $e");
  }
}

  // Updated to handle multiple image selections
  Future<void> pickImage() async {
    final picker = ImagePicker();

    // Request permissions first
    await requestPermissions();

    // Pick multiple images from the gallery
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        // Convert picked files into a list of File objects
        _image = pickedFiles.map((file) => File(file.path)).toList();
      });
    } else {
      print("No images selected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Product")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Product Title"),
            ),
            TextField(
              controller: _descriptionController,
              decoration:
                  const InputDecoration(labelText: "Product Description"),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Product Price"),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                color: Colors.grey[200],
                child: _image == null
                    ? const Center(child: Text("Tap to pick images"))
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadProduct,
              child: const Text("Upload Product"),
            ),
            const SizedBox(height: 20),
            const Text("Existing Products"),
            FutureBuilder<List<Product>>(
              future: fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                final products = snapshot.data;
                if (products == null || products.isEmpty) {
                  return const Center(child: Text("No products available"));
                }

                return GridView.builder(
                  shrinkWrap: true,
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
