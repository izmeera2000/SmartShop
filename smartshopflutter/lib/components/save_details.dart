import 'package:shared_preferences/shared_preferences.dart';

// Save user email & uid for profile screen display
Future<void> saveUserData({required String email, required String uid}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userEmail', email);
  await prefs.setString('userID', uid);
}

// Save login credentials for auto-login (when remember me checked)
Future<void> saveLoginCredentials({
  required String email,
  required String password,
  required bool remember,
}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (remember) {
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setBool('remember', true);
  } else {
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.setBool('remember', false);
  }
}

// Retrieve stored user email for profile screen
Future<String?> getUserEmail() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('userEmail');
  return email;
}

// Retrieve stored user ID for profile screen if needed
Future<String?> getUserID() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userID');
}

// Check if user wants to be remembered for auto-login
Future<bool> isRemembered() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('remember') ?? false;
}

// Get saved login credentials for auto-login
Future<Map<String, String?>> getLoginCredentials() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'email': prefs.getString('email'),
    'password': prefs.getString('password'),
  };
}
