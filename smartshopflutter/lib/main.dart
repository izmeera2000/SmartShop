import 'package:flutter/material.dart';
import 'package:smartshopflutter/screens/splash/splash_screen.dart';
import 'routes.dart';
import 'theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local notifications plugin
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  final settings = InitializationSettings(android: android);
  await flutterLocalNotificationsPlugin.initialize(settings);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Activate Firebase App Check (optional for security)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // Use Play Integrity for production
  );

  // Initialize Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request notification permissions for iOS devices
  await messaging.requestPermission();

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

  // Get FCM token (for testing purposes)
  String? token = await FirebaseMessaging.instance.getToken();
  debugPrint("FCM Token: $token");

  runApp(const MyApp());
}

// Show local notification
Future<void> _showNotification(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  RemoteNotification notification,
) async {
  try {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // This is your custom channel ID (must be unique)
      'High Importance Notifications', // This is the name of your channel
      channelDescription:
          'This channel is used for important notifications.', // Description of the channel
      importance: Importance.max, // Maximum importance for high-priority notifications
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
