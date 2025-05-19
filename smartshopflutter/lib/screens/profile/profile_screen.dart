import 'package:flutter/material.dart';
import 'package:smartshopflutter/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartshopflutter/screens/chat/chat_list_screen.dart';
import 'package:smartshopflutter/screens/orders/orders_list_seller.dart';
import 'package:smartshopflutter/screens/orders/orders_list_user.dart';

import 'components/profile_menu.dart';
import 'components/profile_pic.dart';
import 'package:smartshopflutter/screens/profile/edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = "/profile";

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userEmail;
  String? profileImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail') ?? 'Guest';
    final imageUrl = prefs.getString('profileImage') ?? '';
    print(imageUrl);
    if (mounted) {
      setState(() {
        userEmail = email;
        profileImageUrl = imageUrl.isNotEmpty ? imageUrl : null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text("Profile"),
          ),
      body: RefreshIndicator(
        onRefresh: _loadUserEmail, // Trigger the refresh method
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            Column(
              children: [
                ProfilePic(imageUrl: profileImageUrl),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        userEmail ?? "Guest",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                const SizedBox(height: 20),
                ProfileMenu(
                  text: "My Account",
                  icon: "assets/icons/User Icon.svg",
                  press: () {
                    Navigator.pushNamed(context, EditProfileScreen.routeName);
                  },
                ),
                ProfileMenu(
                  text: "Orders",
                  icon: "assets/icons/Chat bubble Icon.svg",
                  press: () {
                    Navigator.pushNamed(context, OrdersListUser.routeName);
                  },
                ),
                      ProfileMenu(
                  text: "Orders Seller",
                  icon: "assets/icons/Chat bubble Icon.svg",
                  press: () {
                    Navigator.pushNamed(context, OrdersListSeller.routeName);
                  },
                ),
                ProfileMenu(
                  text: "Chats",
                  icon: "assets/icons/Chat bubble Icon.svg",
                  press: () {
                    Navigator.pushNamed(context, ChatListScreen.routeName);
                  },
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
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, "/sign_in", (route) => false);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
