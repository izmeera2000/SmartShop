import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../components/no_account_text.dart';
import '../../../constants.dart';

class ForgotPassForm extends StatefulWidget {
  const ForgotPassForm({super.key});

  @override
  _ForgotPassFormState createState() => _ForgotPassFormState();
}

class _ForgotPassFormState extends State<ForgotPassForm> {
  final _formKey = GlobalKey<FormState>();
  List<String> errors = [];
  String? email;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _sendPasswordResetEmail() async {
    // Check if the email is valid and not null
    if (email == null || email!.isEmpty) {
      _showMessage("Please enter a valid email address.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: email!);
      _showMessage("Password reset email sent! Please check your inbox.");
      // Optionally, navigate the user to the login screen after sending the email
      // Navigator.pushReplacementNamed(context, '/login'); // Example navigation
    } on FirebaseAuthException catch (e) {
      _showMessage("Error: ${e.message}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to show messages (could be a Snackbar or Dialog)
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            onSaved: (newValue) => email = newValue, // Save email when form is saved
            onChanged: (value) {
              // Remove errors if input is corrected
              if (value.isNotEmpty && errors.contains(kEmailNullError)) {
                setState(() {
                  errors.remove(kEmailNullError);
                });
              } else if (emailValidatorRegExp.hasMatch(value) &&
                  errors.contains(kInvalidEmailError)) {
                setState(() {
                  errors.remove(kInvalidEmailError);
                });
              }
            },
            validator: (value) {
              if (value!.isEmpty && !errors.contains(kEmailNullError)) {
                setState(() {
                  errors.add(kEmailNullError);
                });
                return ''; // Return empty string to show error
              } else if (!emailValidatorRegExp.hasMatch(value) &&
                  !errors.contains(kInvalidEmailError)) {
                setState(() {
                  errors.add(kInvalidEmailError);
                });
                return ''; // Return empty string to show error
              }
              return null; // Return null if no error
            },
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
            ),
          ),
          const SizedBox(height: 8),
          FormError(errors: errors),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isLoading
                ? null // Disable button when loading
                : () {
                    if (_formKey.currentState!.validate()) {
                      // Save the form and trigger password reset logic
                      _formKey.currentState!.save(); // Ensure onSaved is called
                      _sendPasswordResetEmail();
                    }
                  },
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Continue"),
          ),
          const SizedBox(height: 16),
          const NoAccountText(),
        ],
      ),
    );
  }
}
