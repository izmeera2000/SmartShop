import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';
import '../../../helper/keyboard.dart';
import '../../forgot_password/forgot_password_screen.dart';
import '../../login_success/login_success_screen.dart';
import 'package:smartshopflutter/components/save_details.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SignForm extends StatefulWidget {
  const SignForm({super.key});

  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
    bool _isPasswordVisible = false;

  bool? remember = false;
  final List<String?> errors = [];

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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            onSaved: (newValue) => email = newValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: kEmailNullError);
              } else if (emailValidatorRegExp.hasMatch(value)) {
                removeError(error: kInvalidEmailError);
              }
              return;
            },
            validator: (value) {
              if (value!.isEmpty) {
                addError(error: kEmailNullError);
                return "";
              } else if (!emailValidatorRegExp.hasMatch(value)) {
                addError(error: kInvalidEmailError);
                return "";
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
              // If  you are using latest version of flutter then lable text and hint text shown like this
              // if you r using flutter less then 1.20.* then maybe this is not working properly
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            obscureText:
                !_isPasswordVisible, // This is the toggle for visibility
            onSaved: (newValue) => password = newValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: 'Password cannot be empty');
              } else if (value.length >= 8) {
                removeError(error: 'Password is too short');
              }
              return;
            },
            validator: (value) {
              if (value!.isEmpty) {
                addError(error: 'Password cannot be empty');
                return "";
              } else if (value.length < 8) {
                addError(error: 'Password is too short');
                return "";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "Password",
              hintText: "Enter your password",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible =
                        !_isPasswordVisible; // Toggle visibility
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: remember,
                activeColor: const Color.fromARGB(255, 255, 0, 0),
                onChanged: (value) {
                  setState(() {
                    remember = value;
                  });
                },
              ),
              const Text("Remember me"),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, ForgotPasswordScreen.routeName),
                child: const Text("Forgot Password", style: TextStyle()),
              )
            ],
          ),
          FormError(errors: errors),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                KeyboardUtil.hideKeyboard(context);

                try {
                  // Sign in the user
                  final UserCredential userCredential =
                      await _auth.signInWithEmailAndPassword(
                    email: email!,
                    password: password!,
                  );

                  final user = userCredential.user;

                  if (user != null) {
                    // Get FCM token after login
                    String? token = await FirebaseMessaging.instance.getToken();
                    debugPrint("FCM Token: $token");

                    if (token != null) {
                      // Get the existing FCM tokens from Firestore (check if it exists)
                      DocumentSnapshot userDoc = await FirebaseFirestore
                          .instance
                          .collection('users')
                          .doc(user.uid)
                          .get();

                      // Initialize the fcmTokens field if it doesn't exist
                      // Safely cast the data to Map<String, dynamic>
                      Map<String, dynamic> userData =
                          userDoc.data() as Map<String, dynamic>;

// Initialize the fcmTokens field if it doesn't exist
                      List<String> fcmTokens =
                          List.from(userData['fcmTokens'] ?? []);

                      // Add the new token to the list (if it's not already present)
                      if (!fcmTokens.contains(token)) {
                        fcmTokens.add(
                            token); // Add the token if it's not already in the list
                      }

                      // Save the user data along with the updated FCM token list to Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .set({
                        'email': user.email,
                        'uid': user.uid,
                        'lastLogin': FieldValue.serverTimestamp(),
                        'fcmTokens': fcmTokens, // Save the list of FCM tokens
                      }, SetOptions(merge: true));

                      debugPrint(
                          '✅ User data and FCM tokens saved to Firestore: ${user.uid}');
                    }

                    // Save user data to SharedPreferences
                    await saveUserData(
                        email: user.email ?? "No Email", uid: user.uid);
                    debugPrint('✅ User data saved locally: ${user.uid}');

                    // Navigate to success screen
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      LoginSuccessScreen.routeName,
                      (Route<dynamic> route) => false,
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  String errorMessage;
                  if (e.code == 'user-not-found') {
                    errorMessage = 'No user found for that email.';
                  } else if (e.code == 'wrong-password') {
                    errorMessage = 'Wrong password provided.';
                  } else {
                    errorMessage = e.message ?? 'Authentication failed';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMessage)),
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
