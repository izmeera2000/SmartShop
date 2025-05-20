import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';

class CompleteProfileForm extends StatefulWidget {
  const CompleteProfileForm({super.key});

  @override
  _CompleteProfileFormState createState() => _CompleteProfileFormState();
}

class _CompleteProfileFormState extends State<CompleteProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String?> errors = [];

  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? address;

  File? profileImage;
  File? bankImage;

  final ImagePicker _picker = ImagePicker();

  // Add these error constants to your constants.dart or define here
  static const String kProfileImageNullError = "Please upload a profile picture";
  static const String kBankImageNullError = "Please upload a bank QR image";

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  Future<void> pickImage(ImageSource source, bool isProfile) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          profileImage = File(pickedFile.path);
          removeError(error: kProfileImageNullError);
        } else {
          bankImage = File(pickedFile.path);
          removeError(error: kBankImageNullError);
        }
      });
    }
  }

  Future<String?> uploadImage(File image, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Image upload failed: $e");
      return null;
    }
  }

  bool validateImages() {
    bool valid = true;

    if (profileImage == null) {
      addError(error: kProfileImageNullError);
      valid = false;
    } else {
      removeError(error: kProfileImageNullError);
    }

    if (bankImage == null) {
      addError(error: kBankImageNullError);
      valid = false;
    } else {
      removeError(error: kBankImageNullError);
    }

    return valid;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // First Name
          TextFormField(
            onSaved: (newValue) => firstName = newValue,
            onChanged: (value) {
              if (value.isNotEmpty) removeError(error: kNamelNullError);
            },
            validator: (value) {
              if (value!.isEmpty) {
                addError(error: kNamelNullError);
                return "";
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "First Name",
              hintText: "Enter your first name",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
            ),
          ),
          const SizedBox(height: 20),

          // Last Name
          TextFormField(
            onSaved: (newValue) => lastName = newValue,
            decoration: const InputDecoration(
              labelText: "Last Name",
              hintText: "Enter your last name",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
            ),
          ),
          const SizedBox(height: 20),

          // Phone Number
          TextFormField(
            keyboardType: TextInputType.phone,
            onSaved: (newValue) => phoneNumber = newValue,
            onChanged: (value) {
              if (value.isNotEmpty) removeError(error: kPhoneNumberNullError);
            },
            validator: (value) {
              if (value!.isEmpty) {
                addError(error: kPhoneNumberNullError);
                return "";
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "Phone Number",
              hintText: "Enter your phone number",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
            ),
          ),
          const SizedBox(height: 20),

          // Address
          TextFormField(
            onSaved: (newValue) => address = newValue,
            onChanged: (value) {
              if (value.isNotEmpty) removeError(error: kAddressNullError);
            },
            validator: (value) {
              if (value!.isEmpty) {
                addError(error: kAddressNullError);
                return "";
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "Address",
              hintText: "Enter your address",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon:
                  CustomSurffixIcon(svgIcon: "assets/icons/Location point.svg"),
            ),
          ),
          const SizedBox(height: 20),

          // Profile Picture Picker
          Row(
            children: [
              const Expanded(child: Text("Profile Picture:")),
              TextButton.icon(
                icon: const Icon(Icons.upload),
                label: const Text("Choose"),
                onPressed: () => pickImage(ImageSource.gallery, true),
              ),
            ],
          ),
          if (profileImage != null) Image.file(profileImage!, height: 100),

          const SizedBox(height: 10),

          // Bank Picture Picker
          Row(
            children: [
              const Expanded(child: Text("QR:")),
              TextButton.icon(
                icon: const Icon(Icons.upload),
                label: const Text("Choose"),
                onPressed: () => pickImage(ImageSource.gallery, false),
              ),
            ],
          ),
          if (bankImage != null) Image.file(bankImage!, height: 100),

          const SizedBox(height: 20),

          FormError(errors: errors),

          const SizedBox(height: 20),

          // Submit Button
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() && validateImages()) {
                _formKey.currentState!.save();

                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    String? token = await FirebaseMessaging.instance.getToken();

                    DocumentSnapshot userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();

                    Map<String, dynamic> userData = userDoc.exists
                        ? userDoc.data() as Map<String, dynamic>
                        : {};

                    List<String> fcmTokens =
                        List<String>.from(userData['fcmTokens'] ?? []);

                    if (token != null && !fcmTokens.contains(token)) {
                      fcmTokens.add(token);
                    }

                    // Upload images
                    String? profileUrl;
                    String? bankUrl;

                    if (profileImage != null) {
                      profileUrl = await uploadImage(
                          profileImage!, 'users/${user.uid}/profile.jpg');
                    }

                    if (bankImage != null) {
                      bankUrl = await uploadImage(
                          bankImage!, 'users/${user.uid}/bank.jpg');
                    }

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .set({
                      'firstName': firstName,
                      'lastName': lastName,
                      'phoneNumber': phoneNumber,
                      'address': address,
                      'email': user.email,
                      'uid': user.uid,
                      'createdAt': FieldValue.serverTimestamp(),
                      'fcmTokens': fcmTokens,
                      'profileImage': profileUrl,
                      'bankImage': bankUrl,
                    });

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      "/sign_in",
                      (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User not logged in")),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error saving profile: $e")),
                  );
                }
              }
            },
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }
}
