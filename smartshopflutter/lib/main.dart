import 'package:flutter/material.dart';
import 'package:smartshopflutter/screens/splash/splash_screen.dart';

import 'routes.dart';
import 'theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';  
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
 
  );

  
  await FirebaseAppCheck.instance.activate(
     androidProvider: AndroidProvider.debug, // <== Use debug for Android
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Flutter Way - Template',
      theme: AppTheme.lightTheme(context),
      initialRoute: SplashScreen.routeName,
      routes: routes,
    );
  }
}
