import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/services/auth_service.dart';
import 'package:rootrails/utils/custom_text_field.dart';
import 'general_user_home_page.dart';

class GeneralUserRegistrationPage extends StatefulWidget {
  const GeneralUserRegistrationPage({super.key});

  @override
  State<GeneralUserRegistrationPage> createState() =>
      _GeneralUserRegistrationPageState();
}

class _GeneralUserRegistrationPageState
    extends State<GeneralUserRegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Register user in Firebase Auth
      final user = await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null) {
        // 2. Create user document in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'user_name': _usernameController.text.trim(),
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': 'general_user', // Key for identifying user type
          'created_at': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          // Navigate to Home Page on success
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const GeneralUserHomePage(),
            ),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General User Registration')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 30),

                // User Name
                CustomTextField(
                  controller: _usernameController,
                  hintText: 'User Name',
                  validator: (value) =>
                      value!.isEmpty ? 'Enter a username' : null,
                ),
                const SizedBox(height: 15),

                // First Name and Last Name
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _firstNameController,
                        hintText: 'First Name',
                        validator: (value) =>
                            value!.isEmpty ? 'Enter first name' : null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: CustomTextField(
                        controller: _lastNameController,
                        hintText: 'Last Name',
                        validator: (value) =>
                            value!.isEmpty ? 'Enter last name' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Email
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@'))
                      return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Password
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 6)
                      return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Confirm Password
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text)
                      return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Register Button
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
