import 'package:flutter/material.dart';
import 'package:smartshopflutter/screens/init_screen.dart';
import 'package:smartshopflutter/screens/splash/splash_screen.dart';
import 'routes.dart';
import 'theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check (with token caching)
  await initializeFirebaseAppCheck();

  // Check if user is remembered, and navigate accordingly
  bool isRemembered = await _checkRememberMe();

  runApp(MyApp(isRemembered: isRemembered));
}

Future<void> initializeFirebaseAppCheck() async {
  try {
    // Check if the App Check token exists, and fetch a new one if necessary
    String? cachedToken = await getAppCheckToken();

    if (cachedToken == null) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug, // Use Play Integrity in production
      );
      String? token = await FirebaseAppCheck.instance.getToken();
      await cacheAppCheckToken(token!);
      debugPrint("App Check Token: $token");
    } else {
      debugPrint("Using cached App Check token");
    }
  } catch (e) {
    debugPrint("Failed to get App Check token: $e");
  }
}

Future<String?> getAppCheckToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('app_check_token');
}

Future<void> cacheAppCheckToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_check_token', token);
}


// Check if the user should be auto-logged in
Future<bool> _checkRememberMe() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('remember') ?? false;
}

class MyApp extends StatelessWidget {
  final bool isRemembered;

  const MyApp({super.key, required this.isRemembered});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Flutter Way - Template',
      theme: AppTheme.lightTheme(context),
      initialRoute: isRemembered ? InitScreen.routeName : SplashScreen.routeName,
      routes: routes,
    );
  }
}
