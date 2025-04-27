import 'package:shared_preferences/shared_preferences.dart';
// Function to save user data
Future<void> saveUserData({required String email, required String uid}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userEmail', email);
  await prefs.setString('userID', uid);
}

// Function to retrieve stored user data
Future<String?> getUserEmail() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userEmail');
}
Future<String?> getUserID() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userID');
}


