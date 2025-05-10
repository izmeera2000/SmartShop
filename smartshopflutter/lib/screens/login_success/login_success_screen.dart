import 'package:flutter/material.dart';
import 'dart:async'; // 👈 For Timer
import 'package:smartshopflutter/screens/init_screen.dart';

class LoginSuccessScreen extends StatefulWidget {
  static String routeName = "/login_success";

  const LoginSuccessScreen({super.key});

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Wait 2 seconds then navigate automatically
 
    Timer(const Duration(seconds: 1), () {
Navigator.pushNamedAndRemoveUntil(
  context,
  InitScreen.routeName,
  (Route<dynamic> route) => false,
);
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
          Image.asset(
            "assets/images/success.png",
            height: MediaQuery.of(context).size.height * 0.4,
          ),
          const SizedBox(height: 16),
          const Text(
            "LOGIN SUCCESS",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const CircularProgressIndicator(),
          ), // Optional loading spinner
          const Spacer(),
        ],
      ),
    );
  }
}
