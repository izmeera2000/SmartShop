import 'package:shared_preferences/shared_preferences.dart';
// Function to save user data
Future<void> saveUserData(String email) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userEmail', email);
}
// Function to retrieve stored user data
Future<String?> getUserEmail() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userEmail');
}
