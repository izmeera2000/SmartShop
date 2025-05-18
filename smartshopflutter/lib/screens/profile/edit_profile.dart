import 'package:flutter/material.dart';

import '../../constants.dart';
import 'components/edit_profile_form.dart';

class EditProfileScreen extends StatelessWidget {
  static String routeName = "/edit_profile";

  const EditProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text("Edit Profile", style: headingStyle),
                  const Text(
                    "Edit your details ",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const EditProfileForm(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
