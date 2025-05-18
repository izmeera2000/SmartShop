import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  _EditProfileFormState createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String?> errors = [];

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  File? profileImage;
  File? bankImage;
  String? profileImageUrl;
  String? bankImageUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _phoneController.text = data['phoneNumber'] ?? '';
        _addressController.text = data['address'] ?? '';
        profileImageUrl = data['profileImage'];
        bankImageUrl = data['bankImage'];
      });
    }
  }

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
        } else {
          bankImage = File(pickedFile.path);
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

  Future<void> _saveToPrefs({
    required String userID,
    required String email,
    required String? profileImage,
    required String? bankImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userID', userID);
    await prefs.setString('email', email);
    if (profileImage != null) await prefs.setString('profileImage', profileImage);
    if (bankImage != null) await prefs.setString('bankImage', bankImage);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _firstNameController,
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
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: "Last Name",
              hintText: "Enter your last name",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
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
          TextFormField(
            controller: _addressController,
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
              suffixIcon: CustomSurffixIcon(
                svgIcon: "assets/icons/Location point.svg",
              ),
            ),
          ),
          const SizedBox(height: 20),

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
          if (profileImage != null)
            Image.file(profileImage!, height: 100)
          else if (profileImageUrl != null)
            Image.network(profileImageUrl!, height: 100),

          const SizedBox(height: 10),

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
          if (bankImage != null)
            Image.file(bankImage!, height: 100)
          else if (bankImageUrl != null)
            Image.network(bankImageUrl!, height: 100),

          const SizedBox(height: 20),
          FormError(errors: errors),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User not logged in")),
                    );
                    return;
                  }

                  String? token = await FirebaseMessaging.instance.getToken();
                  DocumentSnapshot userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get();

                  Map<String, dynamic> userData =
                      userDoc.exists ? userDoc.data() as Map<String, dynamic> : {};
                  List<String> fcmTokens =
                      List<String>.from(userData['fcmTokens'] ?? []);

                  if (!fcmTokens.contains(token)) {
                    fcmTokens.add(token!);
                  }

                  // Upload images if changed
                  String? profileUrl = profileImage != null
                      ? await uploadImage(profileImage!, 'users/${user.uid}/profile.jpg')
                      : profileImageUrl;

                  String? bankUrl = bankImage != null
                      ? await uploadImage(bankImage!, 'users/${user.uid}/bank.jpg')
                      : bankImageUrl;

                  // Update Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({
                    'firstName': _firstNameController.text.trim(),
                    'lastName': _lastNameController.text.trim(),
                    'phoneNumber': _phoneController.text.trim(),
                    'address': _addressController.text.trim(),
                    'fcmTokens': fcmTokens,
                    'profileImage': profileUrl,
                    'bankImage': bankUrl,
                  });

                  // Save to SharedPreferences
                  await _saveToPrefs(
                    userID: user.uid,
                    email: user.email ?? '',
                    profileImage: profileUrl,
                    bankImage: bankUrl,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile updated successfully")),
                  );

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              }
            },
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }
}
