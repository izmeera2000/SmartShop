import 'package:flutter/material.dart';
import 'package:smartshopflutter/screens/init_screen.dart';
import 'package:smartshopflutter/screens/splash/splash_screen.dart';
import 'routes.dart';
import 'theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartshopflutter/components/save_details.dart'; // Import save_details.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");

  // Initialize Firebase App Check (with token caching)
  await initializeFirebaseAppCheck();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  final settings = InitializationSettings(android: android);
  await flutterLocalNotificationsPlugin.initialize(settings);

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Foreground message listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint(
        "Received a message while app is in the foreground: ${message.messageId}");
    if (message.notification != null) {
      debugPrint('Notification Title: ${message.notification!.title}');
      debugPrint('Notification Body: ${message.notification!.body}');

      // Show local notification when a message is received in the foreground
      _showNotification(
        flutterLocalNotificationsPlugin,
        message.notification!,
      );
    }
  });

  // Check if user is remembered, and navigate accordingly
  bool remembered = await isRemembered();

  runApp(MyApp(isRemembered: remembered));
}

Future<void> initializeFirebaseAppCheck() async {
  try {
    // Check if the App Check token exists, and fetch a new one if necessary
    String? cachedToken = await getAppCheckToken();

    if (cachedToken == null) {
      await FirebaseAppCheck.instance.activate(
        androidProvider:
            AndroidProvider.debug, // Use Play Integrity in production
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

class MyApp extends StatelessWidget {
  final bool isRemembered;

  const MyApp({super.key, required this.isRemembered});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Shop',
      theme: AppTheme.lightTheme(context),
      initialRoute:
          isRemembered ? InitScreen.routeName : SplashScreen.routeName,
      routes: routes,
      
    );
  }
}

Future<void> _showNotification(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  RemoteNotification notification,
) async {
  try {
    const androidDetails = AndroidNotificationDetails(
      'chat', // This is your custom channel ID (must be unique)
      'High Importance Notifications', // This is the name of your channel
      channelDescription:
          'This channel is used for important notifications.', // Description of the channel
      importance:
          Importance.max, // Maximum importance for high-priority notifications
      priority: Priority.high, // High priority for the notification
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    // Show the notification
    await flutterLocalNotificationsPlugin.show(
      0, // notification id
      notification.title, // title
      notification.body, // body
      platformDetails, // notification details
    );

    debugPrint('Notification shown successfully.');
  } catch (e) {
    // If an error occurs, log it
    debugPrint('Error showing notification: $e');
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
  // Add your custom logic here
}
