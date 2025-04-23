import 'package:flutter/material.dart';
import 'package:smartshopflutter/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartshopflutter/components/save_details.dart'; // Import save_details.dart

import 'components/profile_menu.dart';
import 'components/profile_pic.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getUserEmail(), // Retrieve saved email from SharedPreferences
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Profile"),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          String userEmail = snapshot.data ?? "Guest";

          return Scaffold(
            appBar: AppBar(
              title: const Text("Profile"),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const ProfilePic(),
                  const SizedBox(height: 20),
                  Text(userEmail, // Display the email retrieved from SharedPreferences
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 20),

                  ProfileMenu(
                    text: "My Account",
                    icon: "assets/icons/User Icon.svg",
                    press: () => {},
                  ),
                  ProfileMenu(
                    text: "Notifications",
                    icon: "assets/icons/Bell.svg",
                    press: () {},
                  ),
                  ProfileMenu(
                    text: "Settings",
                    icon: "assets/icons/Settings.svg",
                    press: () {},
                  ),
                  ProfileMenu(
                    text: "Help Center",
                    icon: "assets/icons/Question mark.svg",
                    press: () {},
                  ),
                  ProfileMenu(
                    text: "Log Out",
                    icon: "assets/icons/Log out.svg",
                    press: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        "/sign_in", // Redirect to sign-in screen after logout
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Profile"),
            ),
            body: Center(child: Text("Failed to load user data.")),
          );
        }
      },
    );
  }
}
