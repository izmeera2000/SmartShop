import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartshopflutter/constants.dart';
import 'package:smartshopflutter/repositories/products_repository.dart';
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

  DateTime? _lastPressedAt;

  void updateCurrentIndex(int index) {
    setState(() {
      currentSelectedIndex = index;
    });
  }

@override
void initState() {
  super.initState();
  ProductsRepository.clearCache(); // clear cache at app start
  // then load products
}

  final pages = [
    const HomeScreen(),
    const SellListScreen(),
    const CartScreen(),
    const ProfileScreen()
  ];

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      // If back button is pressed again within 2 seconds, exit the app
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Press back again to exit')),
      );
      return Future.value(false); // Prevent default back button action
    }
    return Future.value(true); // Allow exit after second back press
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: currentSelectedIndex,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: updateCurrentIndex,
          currentIndex: currentSelectedIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.store_outlined, color: inActiveIconColor),
              activeIcon: Icon(Icons.store,
                  color: const Color.fromARGB(255, 255, 0, 0)),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_outlined, color: inActiveIconColor),
              activeIcon: Icon(Icons.business,
                  color: const Color.fromARGB(255, 255, 0, 0)),
              label: "Sell",
            ),
            BottomNavigationBarItem(
              icon:
                  Icon(Icons.shopping_cart_outlined, color: inActiveIconColor),
              activeIcon: Icon(Icons.shopping_cart,
                  color: const Color.fromARGB(255, 255, 0, 0)),
              label: "Cart",
            ),
            BottomNavigationBarItem(
              icon:
                  Icon(Icons.account_circle_outlined, color: inActiveIconColor),
              activeIcon: Icon(Icons.account_circle,
                  color: const Color.fromARGB(255, 255, 0, 0)),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
