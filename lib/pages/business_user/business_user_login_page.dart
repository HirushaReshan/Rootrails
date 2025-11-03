import 'package:flutter/material.dart';
import 'package:rootrails/services/auth_service.dart';
import 'package:rootrails/utils/custom_text_field.dart';
import 'package:rootrails/pages/business_user/business_user_registration_page.dart';
import 'package:rootrails/pages/business_user/business_user_home_page.dart';

const Color kPrimaryGreen = Color(0xFF4C7D4D);
const Color kCardColor = Colors.white;
const Color kGradientStart = Color(0xFF7CB342);
const Color kGradientEnd = Color(0xFF4CAF50); 
const Color kBusinessIconColor = Colors.deepOrange; 


class TopRoundedClipper extends CustomClipper<Path> {
  final double radius;

  TopRoundedClipper(this.radius);

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, radius)
      ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius))
      ..lineTo(size.width - radius, 0)
      ..arcToPoint(Offset(size.width, radius), radius: Radius.circular(radius))
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class BusinessUserLoginPage extends StatefulWidget {
  const BusinessUserLoginPage({super.key});

  @override
  State<BusinessUserLoginPage> createState() => _BusinessUserLoginPageState();
}

class _BusinessUserLoginPageState extends State<BusinessUserLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        // Navigate to Business User Home Page
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const BusinessUserHomePage()),
          (Route<dynamic> route) => false,
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login Failed: ${e.toString().split(':').last.trim()}',
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const double headerHeight = 0.35;
    const double overlapOffset = 0.05;

    return Scaffold(
      backgroundColor: kPrimaryGreen,
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
                    const SizedBox(height: 20),
                    
                    const Icon(
                      Icons.directions_bus,
                      size: 80,
                      color: kBusinessIconColor,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Business Access',
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

            //MAIN LOGIN CARD
            Container(
              margin: EdgeInsets.only(
                top: screenHeight * (headerHeight - overlapOffset),
              ),
              child: ClipPath(
                clipper: TopRoundedClipper(30),
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
                          'Driver/Service Sign In',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 30),

                        // Email Field
                        const Text(
                          'Business Email',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'business@email.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              v!.isEmpty ? 'Email is required' : null,
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
                        const SizedBox(height: 30),

                        // Login Button
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
                                    onTap: _login,
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Center(
                                      child: Text(
                                        'Sign In to Dashboard',
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

                        const SizedBox(height: 20),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('New Safari Service?'),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BusinessUserRegistrationPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Register Here',
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
