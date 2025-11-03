import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/services/auth_service.dart';
import 'package:rootrails/utils/custom_text_field.dart';
import 'package:rootrails/pages/general_user/general_user_home_page.dart';

const Color kPrimaryGreen = Color(0xFF4C7D4D);
const Color kCardColor = Colors.white;
const Color kGradientStart = Color(0xFF7CB342);
const Color kGradientEnd = Color(0xFF4CAF50);

//Custom Clipper for the Rounded Card Shape
class TopRoundedClipper extends CustomClipper<Path> {
  final double radius;

  TopRoundedClipper(this.radius);

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, radius)
      // Curve from (0, radius) to (radius, 0)
      ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius))
      // Draw a line across the top
      ..lineTo(size.width - radius, 0)
      // Curve from (size.width - radius, 0) to (size.width, radius)
      ..arcToPoint(Offset(size.width, radius), radius: Radius.circular(radius))
      // Draw lines down and back to the start
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class GeneralUserRegistrationPage extends StatefulWidget {
  const GeneralUserRegistrationPage({super.key});

  @override
  State<GeneralUserRegistrationPage> createState() =>
      _GeneralUserRegistrationPageState();
}

class _GeneralUserRegistrationPageState
    extends State<GeneralUserRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _register() async {
    // Check for password mismatch before proceeding
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match!')),
        );
      }
      return;
    }

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
        // Save user role and details to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': _emailController.text.trim(),
          'role': 'general_user',
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'full_name': _firstNameController.text
              .trim(), // Using one field for display name
          'created_at': FieldValue.serverTimestamp(),
          'profile_image_url': 'https://via.placeholder.com/150',
          'phone_number': '',
          'bio': '',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          // Navigate to Home Page
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const GeneralUserHomePage(),
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Define the height of the green header section
    const double headerHeight = 0.35;
    // Define the overlap amount (how far the white card dips into the green)
    const double overlapOffset = 0.05;

    return Scaffold(
      backgroundColor: kPrimaryGreen,
      // The SingleChildScrollView now wraps the entire Stack content
      body: SingleChildScrollView(
        child: Stack(
          children: [
            //TOP BACKGROUND CONTAINER
            Container(
              height: screenHeight * headerHeight,
              width: double.infinity,
              color: kPrimaryGreen,
            ),

            //GREEN HEADER CONTENT
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Column(
                  children: [
                    // Custom Back Button
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: kCardColor,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Bear/Safari Icon Placeholder
                    const Icon(Icons.pets, size: 80, color: Colors.black),
                    const SizedBox(height: 10),
                    const Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kCardColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // MAIN REGISTRATION CARD
            Container(
              margin: EdgeInsets.only(
                top: screenHeight * (headerHeight - overlapOffset),
              ),
              child: ClipPath(
                clipper: TopRoundedClipper(30), // Rounded top corners
                child: Container(
                  color: kCardColor,

                  constraints: BoxConstraints(
                    minHeight:
                        screenHeight * (1.0 - (headerHeight - overlapOffset)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  width: double.infinity,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 40),

                        Text(
                          'Sign Up',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 30),

                        // Name Field
                        const Text(
                          'Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _firstNameController,
                          hintText: 'John Doe',
                          validator: (v) =>
                              v!.isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 20),

                        // Email Field
                        const Text(
                          'Email',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'example@gmail.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v!.isEmpty || !v.contains('@')
                              ? 'Enter a valid email'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        const Text(
                          'Password',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: '********',
                          obscureText: !_isPasswordVisible,
                          validator: (v) => v!.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: kPrimaryGreen,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password Field
                        const Text(
                          'Confirm Password',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: '********',
                          obscureText: !_isConfirmPasswordVisible,
                          validator: (v) => v!.isEmpty
                              ? 'Confirm password is required'
                              : null,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: kPrimaryGreen,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Register Button (Styled with Gradient and 'Next' Text)
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    colors: [kGradientStart, kGradientEnd],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: kGradientEnd.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _register,
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Center(
                                      child: Text(
                                        'Next',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                        const SizedBox(height: 30),

                        // OR Divider
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'or',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Social Icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google Icon
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Icon(
                                Icons.g_mobiledata,
                                size: 30,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 30),
                            // Facebook Icon
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Icon(
                                Icons.facebook,
                                size: 30,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account?'),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Go back to login page
                              },
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: kPrimaryGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
