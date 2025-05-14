import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartshopflutter/constants.dart';
import 'package:smartshopflutter/screens/favorite/favorite_screen.dart';
import 'package:smartshopflutter/screens/home/home_screen.dart';
import 'package:smartshopflutter/screens/profile/profile_screen.dart';
import 'package:smartshopflutter/screens/sell/sell_lists_screen.dart';
import 'package:smartshopflutter/screens/cart/cart_screen.dart';

const Color inActiveIconColor = Color(0xFFB6B6B6);

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  static String routeName = "/";

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  int currentSelectedIndex = 0;

  void updateCurrentIndex(int index) {
    setState(() {
      currentSelectedIndex = index;
    });
  }

  final pages = [
    const HomeScreen(),
    const SellListScreen(),
    const CartScreen(),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentSelectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: updateCurrentIndex,
        currentIndex: currentSelectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined, color: inActiveIconColor),
            activeIcon: Icon(Icons.store, color: kPrimaryColor),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined, color: inActiveIconColor),
            activeIcon: Icon(Icons.business, color: kPrimaryColor),
            label: "Sell",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined, color: inActiveIconColor),
            activeIcon: Icon(Icons.shopping_cart, color: kPrimaryColor),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined, color: inActiveIconColor),
            activeIcon: Icon(Icons.account_circle, color: kPrimaryColor),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
