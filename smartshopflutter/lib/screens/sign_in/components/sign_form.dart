import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool remember = false; // default false
  final List<String?> errors = [];

  @override
  void initState() {
    super.initState();
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



  Future<void> _signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Save user data for profile screen
        await saveUserData(email: user.email!, uid: user.uid);

        // Save login credentials for future auto-login if remember is checked
        if (remember) {
          await saveLoginCredentials(email: email, password: password, remember: true);
        }

        // Handle FCM token update
        String? token = await FirebaseMessaging.instance.getToken();

        if (token != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          Map<String, dynamic> userData = userDoc.exists
              ? userDoc.data() as Map<String, dynamic>
              : {};

          List<String> fcmTokens = List<String>.from(userData['fcmTokens'] ?? []);

          if (!fcmTokens.contains(token)) {
            fcmTokens.add(token);
          }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'email': user.email,
            'uid': user.uid,
            'lastLogin': FieldValue.serverTimestamp(),
            'fcmTokens': fcmTokens,
          }, SetOptions(merge: true));
        }

        // Navigate to success screen after login
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login_success', // update to your route
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email input
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            onSaved: (newValue) => email = newValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: 'Email cannot be empty');
              }
              // Add your email validation here if needed
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError(error: 'Email cannot be empty');
                return "";
              }
              // Add your email regex check here if needed
              return null;
            },
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
            ),
          ),
          const SizedBox(height: 20),

          // Password input
          TextFormField(
            obscureText: !_isPasswordVisible,
            onSaved: (newValue) => password = newValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: 'Password cannot be empty');
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
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

          // Remember me checkbox
          Row(
            children: [
              Checkbox(
                value: remember,
                onChanged: (value) {
                  setState(() {
                    remember = value ?? false;
                  });
                },
              ),
              const Text("Remember me"),
            ],
          ),

          // Errors display (simple example)
          if (errors.isNotEmpty)
            ...errors.map((e) => Text(e ?? '', style: TextStyle(color: Colors.red))),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (email != null && password != null) {
                  await _signInWithEmailPassword(email!, password!);
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
