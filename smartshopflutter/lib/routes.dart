import 'package:flutter/widgets.dart';
import 'package:smartshopflutter/models/Product.dart';
import 'package:smartshopflutter/screens/payment/payment_screen.dart';
import 'package:smartshopflutter/screens/products/products_screen.dart';

import 'screens/cart/cart_screen.dart';
import 'screens/complete_profile/complete_profile_screen.dart';
import 'screens/details/details_screen.dart';
import 'screens/forgot_password/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/init_screen.dart';
import 'screens/login_success/login_success_screen.dart';
import 'screens/otp/otp_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/sign_in/sign_in_screen.dart';
import 'screens/sign_up/sign_up_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/sell/sell_screen.dart';
import 'screens/sell/sell_lists_screen.dart';
import 'screens/sell/sell_edit_screen.dart';
import 'screens/checkout/checkout_screen.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  InitScreen.routeName: (context) => const InitScreen(),
  SplashScreen.routeName: (context) => const SplashScreen(),
  SignInScreen.routeName: (context) => const SignInScreen(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  LoginSuccessScreen.routeName: (context) => const LoginSuccessScreen(),
  SignUpScreen.routeName: (context) => const SignUpScreen(),
  CompleteProfileScreen.routeName: (context) => const CompleteProfileScreen(),
  OtpScreen.routeName: (context) => const OtpScreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  ProductsScreen.routeName: (context) => const ProductsScreen(),
  DetailsScreen.routeName: (context) => const DetailsScreen(),
  CartScreen.routeName: (context) => const CartScreen(),
  CheckoutScreen.routeName: (context) => const CheckoutScreen(),
  PaymentScreen.routeName: (context) => const PaymentScreen(),
  ProfileScreen.routeName: (context) => const ProfileScreen(),
  SellScreen.routeName: (context) => const SellScreen(),
  SellListScreen.routeName: (context) => const SellListScreen(),
  SellEditScreen.routeName: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Product?;
    return SellEditScreen(product: args);
  },
};
