import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/services/auth_service.dart';
import 'package:rootrails/utils/custom_text_field.dart';
import 'business_user_home_page.dart';

class BusinessUserRegistrationPage extends StatefulWidget {
  const BusinessUserRegistrationPage({super.key});

  @override
  State<BusinessUserRegistrationPage> createState() =>
      _BusinessUserRegistrationPageState();
}

class _BusinessUserRegistrationPageState
    extends State<BusinessUserRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Controllers for Business Details
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessDescController = TextEditingController();
  final TextEditingController _businessImageUrlController =
      TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _driverImageUrlController =
      TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _locationInfoController = TextEditingController();

  // Controllers for Auth Details
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _businessType = 'park'; // Default to 'park'
  final List<String> _businessTypes = ['park', 'other_business'];

  // Placeholder for Park ID selection (assuming a static list for now)
  String? _parkId = 'masai_mara';
  final List<Map<String, String>> _availableParks = [
    {'id': 'masai_mara', 'name': 'Masai Mara'},
    {'id': 'serengeti', 'name': 'Serengeti'},
    {'id': 'other', 'name': 'Other (No Park ID)'},
  ];

  Future<void> _registerBusiness() async {
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
        // 2. Create user/business document in Firestore
        // Note: For simplicity, storing driver/business details in the 'users' collection with role 'business_user'
        // and also creating a public entry in 'parks'/'businesses' for listing.

        final businessData = {
          'uid': user.uid,
          'email': _emailController.text.trim(),
          'role': 'business_user',

          // Business Details
          'business_name': _businessNameController.text.trim(),
          'business_description': _businessDescController.text.trim(),
          'business_image_url': _businessImageUrlController.text.trim(),
          'price_per_safari': double.tryParse(_priceController.text) ?? 0.0,
          'driver_image_url': _driverImageUrlController.text.trim(),
          'safari_duration_hours':
              double.tryParse(_durationController.text) ?? 0.0,
          'location_info': _locationInfoController.text.trim(),
          'business_type': _businessType,
          'park_id': _parkId == 'other' ? '' : _parkId,
          'is_open': false, // Starts as closed
          'rating': 0.0, // Initial rating
          'created_at': FieldValue.serverTimestamp(),
        };

        // Create the user document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(businessData);

        // Create the public park/business listing (using the user's UID as the document ID)
        await FirebaseFirestore.instance.collection('parks').doc(user.uid).set({
          ...businessData,
          'type': _businessType, // Public listing type
          'name': _businessNameController.text.trim(),
          'image_url': _businessImageUrlController.text.trim(),
          'open_time': 'Varies (Driver-controlled)',
        });

        if (mounted) {
          // Navigate to Business Home Page on success
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const BusinessUserHomePage(),
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
      appBar: AppBar(title: const Text('Business Registration')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Register Your Safari Service',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 30),

                // --- Business Details ---
                const Text(
                  'Business Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                CustomTextField(
                  controller: _businessNameController,
                  hintText: 'Business Name',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _businessDescController,
                  hintText: 'Business Description',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _businessImageUrlController,
                  hintText: 'Business Image URL (for listing)',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _driverImageUrlController,
                  hintText: 'Driver Image URL',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _priceController,
                  hintText: 'Price for a Booking (e.g., 150.00)',
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _durationController,
                  hintText: 'Safari Duration (Hours, e.g., 4.5)',
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _locationInfoController,
                  hintText: 'Location Info / Pickup Point',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 20),

                // Business Type Selection
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Business Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _businessType,
                  items: _businessTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type == 'park'
                            ? 'Park Driver/Guide'
                            : 'Other Business/Activity',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _businessType = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Park ID Selection (Only if type is 'park')
                if (_businessType == 'park')
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Primary Park',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: _parkId,
                    items: _availableParks.map((park) {
                      return DropdownMenuItem(
                        value: park['id'],
                        child: Text(park['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _parkId = value;
                      });
                    },
                    validator: (v) =>
                        v!.isEmpty ? 'Please select a primary park.' : null,
                  ),
                const SizedBox(height: 30),

                // --- Account Details ---
                const Text(
                  'Account Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Login Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty || !v.contains('@')
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  validator: (v) => v!.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                  validator: (v) => v != _passwordController.text
                      ? 'Passwords do not match'
                      : null,
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
                        onPressed: _registerBusiness,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Register Business',
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
