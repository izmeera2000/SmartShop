import 'package:flutter/material.dart';

import 'constants.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      fontFamily: "Muli",
      appBarTheme: const AppBarTheme(
          color: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black)),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: kTextColor),
        bodyMedium: TextStyle(color: kTextColor),
        bodySmall: TextStyle(color: kTextColor),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
        enabledBorder: outlineInputBorder,
        focusedBorder: outlineInputBorder,
        border: outlineInputBorder,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color.fromARGB(255, 255, 0, 0),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:
            Colors.white, // Set the background color of the nav bar
        // selectedItemColor: Colors.white, // Color for the selected item
        // unselectedItemColor: Colors.white60, // Color for the unselected items
        elevation: 5, // Add elevation for a subtle shadow
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color.fromARGB(255, 255, 0, 0), // Set FAB background color
        foregroundColor: Colors.white, // Set icon color inside FAB
        elevation: 6, // Add elevation for a shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ), // FAB with rounded edges (Stadium shape)
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: const Color.fromARGB(255, 255, 0, 0), // Change the color globally
        circularTrackColor:
            Colors.grey[200], // Background track color (optional)
      ),
          switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(const Color.fromARGB(255, 255, 0, 0)),
      trackColor: WidgetStateProperty.all(kPrimaryLightColor),
    ),
    );
  }
}

const OutlineInputBorder outlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(28)),
  borderSide: BorderSide(color: kTextColor),
  gapPadding: 10,
);
