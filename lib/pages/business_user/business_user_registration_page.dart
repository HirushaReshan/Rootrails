import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/models/park.dart'; // <-- IMPORT PARK MODEL
import 'package:rootrails/services/auth_service.dart';
import 'package:rootrails/utils/custom_text_field.dart';
import 'package:rootrails/pages/business_user/business_user_home_page.dart';
import 'package:rootrails/models/business.dart'; // <-- IMPORT BUSINESS MODEL

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

  // State for parks dropdown
  List<Park> _parksList = [];
  Park? _selectedPark;
  bool _isParkLoading = true;

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchParks();
  }

  Future<void> _fetchParks() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('parks') // <-- Reads from your manual 'parks' collection
          .get();
      _parksList = snapshot.docs.map((doc) => Park.fromFirestore(doc)).toList();
      setState(() {
        _isParkLoading = false;
      });
    } catch (e) {
      setState(() {
        _isParkLoading = false;
      });
      print("Error fetching parks: $e");
      // Handle error, e.g., show a snackbar
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPark == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a park.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService().signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null) {
        // 1. Create the Business object using the model
        final newBusinessProfile = Business(
          uid: user.uid,
          email: _emailController.text.trim(),
          role: 'business_user',
          businessName: _businessNameController.text.trim(),
          businessDescription: _descriptionController.text.trim(),
          pricePerSafari: double.tryParse(_priceController.text) ?? 0.0,
          safariDurationHours: 3.0, // Default value
          locationInfo: 'Main Park Entrance', // Default value
          isOpen: false, // Starts as closed
          businessType: 'park', // Default to 'park' type
          parkId: _selectedPark!.id, // <-- USE SELECTED PARK ID
          rating: 0.0,
          businessImageUrl:
              'https://via.placeholder.com/300/FFA000/FFFFFF?text=Safari+Service',
          driverImageUrl:
              'https://via.placeholder.com/150/FF9800/FFFFFF?text=Driver',
        );

        // 2. Save business details to the correct 'drivers' collection
        await FirebaseFirestore.instance
            .collection('drivers') // <-- SAVES TO 'drivers'
            .doc(user.uid)
            .set(newBusinessProfile.toFirestore());

        // 3. Save minimum user document for role checking
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': _emailController.text.trim(),
          'role': 'business_user',
          'first_name': _businessNameController.text.trim(),
          'last_name': '',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registration successful! Please update your full profile.',
              ),
            ),
          );
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

                // --- Park Dropdown ---
                _isParkLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<Park>(
                        value: _selectedPark,
                        hint: const Text('Select Your Park'),
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.park),
                        ),
                        items: _parksList.map((Park park) {
                          return DropdownMenuItem<Park>(
                            value: park,
                            child: Text(park.name),
                          );
                        }).toList(),
                        onChanged: (Park? newValue) {
                          setState(() {
                            _selectedPark = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Park is required' : null,
                      ),
                const SizedBox(height: 20),
                // --- End Park Dropdown ---

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

                // Price
                CustomTextField(
                  controller: _priceController,
                  hintText: 'Price per Safari (e.g., 150.00)',
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty || double.tryParse(v) == null
                      ? 'Enter a valid price'
                      : null,
                ),
                const SizedBox(height: 20),

                // Description
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
