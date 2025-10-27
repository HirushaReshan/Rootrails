import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/services/auth_service.dart';
import 'package:rootrails/utils/custom_text_field.dart';
import 'package:rootrails/pages/business_user/business_user_home_page.dart';

class BusinessUserRegistrationPage extends StatefulWidget {
  const BusinessUserRegistrationPage({super.key});

  @override
  State<BusinessUserRegistrationPage> createState() =>
      _BusinessUserRegistrationPageState();
}

class _BusinessUserRegistrationPageState
    extends State<BusinessUserRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService().signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null) {
        // 2. Save business details to Firestore in the 'parks' collection for listing
        await FirebaseFirestore.instance.collection('parks').doc(user.uid).set({
          'uid': user.uid,
          'email': _emailController.text.trim(),
          'role': 'business_user',
          'business_name': _businessNameController.text.trim(),
          'business_description': _descriptionController.text.trim(),
          'price_per_safari': double.tryParse(_priceController.text) ?? 0.0,
          'safari_duration_hours': 3.0, // Default value
          'location_info': 'Main Park Entrance', // Default value
          'is_open': false, // Starts as closed
          'business_type': 'park', // Default to 'park' type
          'park_id': 'default_park_id', // Placeholder
          'rating': 0.0,
          'business_image_url':
              'https://via.placeholder.com/300/FFA000/FFFFFF?text=Safari+Service',
          'driver_image_url':
              'https://via.placeholder.com/150/FF9800/FFFFFF?text=Driver',
          'created_at': FieldValue.serverTimestamp(),
        });

        // 3. Save minimum user document for role checking in main.dart
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': _emailController.text.trim(),
          'role': 'business_user',
          'full_name': _businessNameController.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registration successful! Please update your full profile.',
              ),
            ),
          );
          // Navigate to Home Page
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const BusinessUserHomePage(),
            ),
            (Route<dynamic> route) => false,
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration Failed: ${e.toString().split(':').last.trim()}',
            ),
          ),
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
      appBar: AppBar(title: const Text('Business Registration')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'List Your Safari Service',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 30),

                // Business Name
                CustomTextField(
                  controller: _businessNameController,
                  hintText: 'Business/Driver Name',
                  validator: (v) =>
                      v!.isEmpty ? 'Business name is required' : null,
                ),
                const SizedBox(height: 20),

                // Email Field
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty || !v.contains('@')
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 20),

                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: !_isPasswordVisible,
                  validator: (v) => v!.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Price and Description
                CustomTextField(
                  controller: _priceController,
                  hintText: 'Price per Safari (e.g., 150.00)',
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty || double.tryParse(v) == null
                      ? 'Enter a valid price'
                      : null,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  controller: _descriptionController,
                  hintText: 'Short Service Description',
                  maxLines: 3,
                  validator: (v) =>
                      v!.isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 30),

                // Register Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Register Service',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),

                const SizedBox(height: 20),

                // Login Link
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Already registered? Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
