import 'package:flutter/material.dart';
import 'package:smartshopflutter/screens/splash/splash_screen.dart';
import 'routes.dart';
import 'theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Initialize Firebase App Check (with token caching)
  await initializeFirebaseAppCheck();

  // Initialize Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request notification permissions for iOS devices
  await messaging.requestPermission();

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Foreground message listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint("Received a message while app is in the foreground: ${message.messageId}");
    if (message.notification != null) {
      debugPrint('Notification Title: ${message.notification!.title}');
      debugPrint('Notification Body: ${message.notification!.body}');
      _showNotification(flutterLocalNotificationsPlugin, message.notification!);
    }
  });

  // Get FCM token (and cache it if needed)
  await getFCMToken();

  runApp(const MyApp());
}

// Show local notification
Future<void> _showNotification(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  RemoteNotification notification,
) async {
  try {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // Custom channel ID
      'High Importance Notifications', // Channel Name
      channelDescription:
          'This channel is used for important notifications.', // Description
      importance: Importance.max, // Maximum priority
      priority: Priority.high, // High priority
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    // Show notification
    await flutterLocalNotificationsPlugin.show(
      0, // notification ID
      notification.title, // Title
      notification.body, // Body
      platformDetails, // Notification Details
    );
  } catch (e) {
    debugPrint('Error showing notification: $e');
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
  // Add custom logic for handling background messages
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

Future<void> cacheAppCheckToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('appCheckToken', token);
}

Future<String?> getAppCheckToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('appCheckToken');
}

Future<String?> getFCMToken() async {
  try {
    // Check if the FCM token is already cached
    String? cachedToken = await getFCMTokenFromPrefs();

    if (cachedToken != null) {
      debugPrint("Using cached FCM token");
      return cachedToken;
    }

    // Fetch the new token
    String? token = await FirebaseMessaging.instance.getToken();
    debugPrint("FCM Token: $token");

    // Cache the new token
    await cacheFCMToken(token);

    return token;
  } catch (e) {
    debugPrint("Failed to get FCM token: $e");
    return null;
  }
}

Future<void> cacheFCMToken(String? token) async {
  final prefs = await SharedPreferences.getInstance();
  if (token != null) {
    await prefs.setString('fcmToken', token);
  }
}

Future<String?> getFCMTokenFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('fcmToken');
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
