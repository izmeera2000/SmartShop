import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartshopflutter/constants.dart';
import 'package:smartshopflutter/helper/compress_image.dart';
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
  final _stockController = TextEditingController(); // ✅ Added for stock input
  bool _isPopular = false; // ✅ Added for popular toggle

  // Upload function (modified below)

  Future<void> uploadProduct() async {
    if (_image == null ||
        _titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty) {
      // ✅ Validate stock too
      debugPrint("All fields are required!");
      return;
    }

    try {
      String? userId = await getUserID();
      List<String> imagePaths = [];
      bool hasError = false;

      if (_image is List<File>) {
        for (var image in _image!) {
          try {
            final compressedImage = await compressImage(image);
            if (compressedImage == null) {
              debugPrint("Error compressing image: $image");
              hasError = true; // Set flag if error happens during compression
              break; // Break the loop as we don't want to continue uploading
            }

            final filePath =
                'products/${DateTime.now().millisecondsSinceEpoch}.jpg';
            final storageRef = FirebaseStorage.instance.ref().child(filePath);
            final uploadTask = storageRef.putFile(compressedImage);
            await uploadTask;
            imagePaths.add(filePath);
          } catch (e) {
            debugPrint("Error processing image: $e");
            hasError = true; // Set flag if any error occurs during upload
            break; // Stop the process on error
          }
        }
      }

      if (hasError) {
        debugPrint("Upload aborted due to image error");
        return; // Exit the function if an error occurs
      }

      final productData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'stock':
            int.tryParse(_stockController.text) ?? 0, // ✅ Save stock as int
        'popular': _isPopular, // ✅ Save popular as bool
        'images': imagePaths,
        'userId': userId,
      };

      await FirebaseFirestore.instance.collection('products').add(productData);

      debugPrint("Product uploaded successfully!");

      // Clear form fields
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _stockController.clear();
      setState(() {
        _image = null;
        _isPopular = false;
      });
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint("Error uploading product: $e");
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    await requestPermissions();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _image = pickedFiles.map((file) => File(file.path)).toList();
      });
    } else {
      debugPrint("No images selected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Product")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  const SizedBox(height: 10),
                  const Text("Add Product", style: headingStyle),
                  const Text(
                    "Complete your details of the product  \nwith social media",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 200,
                      color: const Color.fromARGB(255, 238, 238, 238),
                      child: _image == null
                          ? const Center(child: Text("Tap to pick image"))
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
                    decoration:
                        const InputDecoration(labelText: "Product Title"),
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
                    decoration:
                        const InputDecoration(labelText: "Product Price"),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _stockController, // ✅ Added stock input field
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "Stock Quantity"),
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
                    onPressed: uploadProduct,
                    child: const Text("Upload Product"),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
