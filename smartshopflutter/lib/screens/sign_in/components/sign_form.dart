import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';
import '../../../helper/keyboard.dart';
import '../../forgot_password/forgot_password_screen.dart';
import '../../login_success/login_success_screen.dart';

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
  bool? remember = false;  // Remember me checkbox
  final List<String?> errors = [];

  @override
  void initState() {
    super.initState();
    _checkRememberMe();  // Check if user should be auto-logged in
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

  // Add this method to check the SharedPreferences for login details
  void _checkRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isRemembered = prefs.getBool('remember') ?? false;

    if (isRemembered) {
      final String? storedEmail = prefs.getString('email');
      final String? storedPassword = prefs.getString('password');

      if (storedEmail != null && storedPassword != null) {
        // Auto login if remember is checked
        _signInWithEmailPassword(storedEmail, storedPassword);
      }
    }
  }

  // Auto login function
  Future<void> _signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // Get FCM token after login
        String? token = await FirebaseMessaging.instance.getToken();
        debugPrint("FCM Token: $token");

        if (token != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          List<String> fcmTokens =
              List.from(userData['fcmTokens'] ?? []);

          if (!fcmTokens.contains(token)) {
            fcmTokens.add(token);
          }

          await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
            {
              'email': user.email,
              'uid': user.uid,
              'lastLogin': FieldValue.serverTimestamp(),
              'fcmTokens': fcmTokens,
            },
            SetOptions(merge: true),
          );

          debugPrint('✅ User data and FCM tokens saved to Firestore: ${user.uid}');
        }

        // Navigate to success screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginSuccessScreen.routeName,
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Save user credentials in SharedPreferences
  Future<void> _saveLoginDetails(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('remember', remember ?? false);
    prefs.setString('email', email);
    prefs.setString('password', password);
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
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            obscureText: !_isPasswordVisible,
            onSaved: (newValue) => password = newValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: 'Password cannot be empty');
              } else if (value.length >= 8) {
                removeError(error: 'Password is too short');
              }
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
                    _isPasswordVisible = !_isPasswordVisible;
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
                onTap: () => Navigator.pushNamed(context, ForgotPasswordScreen.routeName),
                child: const Text("Forgot Password", style: TextStyle()),
              ),
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
                    // Save login details if 'Remember me' is checked
                    if (remember == true) {
                      await _saveLoginDetails(email!, password!);
                    }

                    // Get FCM token after login
                    String? token = await FirebaseMessaging.instance.getToken();
                    debugPrint("FCM Token: $token");

                    if (token != null) {
                      DocumentSnapshot userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .get();

                      Map<String, dynamic> userData =
                          userDoc.data() as Map<String, dynamic>;

                      List<String> fcmTokens =
                          List.from(userData['fcmTokens'] ?? []);

                      if (!fcmTokens.contains(token)) {
                        fcmTokens.add(token);
                      }

                      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
                        {
                          'email': user.email,
                          'uid': user.uid,
                          'lastLogin': FieldValue.serverTimestamp(),
                          'fcmTokens': fcmTokens,
                        },
                        SetOptions(merge: true),
                      );

                      debugPrint('✅ User data and FCM tokens saved to Firestore: ${user.uid}');
                    }

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
